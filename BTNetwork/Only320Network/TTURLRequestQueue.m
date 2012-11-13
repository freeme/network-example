//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "TTURLRequestQueue.h"

// Network
#import "Only320Network.h"
#import "TTURLRequest.h"
#import "TTURLRequestDelegate.h"
#import "TTUserInfo.h"
#import "TTURLResponse.h"
#import "TTURLCache.h"

// Network (Private)
#import "TTRequestLoader.h"

// Core
#import "TTGlobalCore.h"
#import "TTGlobalCorePaths.h"
#import "TTDebugFlags.h"
#import "TTDebug.h"

static const NSTimeInterval kFlushDelay = 0.3; //1.3;
static const NSTimeInterval kTimeout = 10.0;
static const NSInteger kMaxConcurrentLoads = 2;
static NSUInteger kDefaultMaxContentLength = 5*1024*1024; //2M

static TTURLRequestQueue* gMainQueue = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLRequestQueue

@synthesize maxContentLength        = _maxContentLength;
@synthesize userAgent               = _userAgent;
@synthesize suspended               = _suspended;
@synthesize imageCompressionQuality = _imageCompressionQuality;
@synthesize defaultTimeout          = _defaultTimeout;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTURLRequestQueue*)mainQueue {
  if (!gMainQueue) {
    gMainQueue = [[TTURLRequestQueue alloc] init];
  }
  return gMainQueue;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setMainQueue:(TTURLRequestQueue*)queue {
  if (gMainQueue != queue) {
    [gMainQueue release];
    gMainQueue = [queue retain];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [super init];
  if (self) {
    _loaders = [[NSMutableDictionary alloc] init];
    _loaderQueue = [[NSMutableArray alloc] init];
    _runningLoaderQueue = [[NSMutableArray alloc] init];
    _maxContentLength = kDefaultMaxContentLength;
    _imageCompressionQuality = 0.75;
    _defaultTimeout = kTimeout;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_loaderQueueTimer invalidate];
  TT_RELEASE_SAFELY(_loaders);
  TT_RELEASE_SAFELY(_loaderQueue);
  TT_RELEASE_SAFELY(_runningLoaderQueue);
  TT_RELEASE_SAFELY(_userAgent);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadRequestFromCache:(TTURLRequest*)request {
  if (!request.cacheKey) {
    request.cacheKey = [[TTURLCache sharedCache] keyForURL:request.urlPath];
  }

  if (IS_MASK_SET(request.cachePolicy, TTURLRequestCachePolicyEtag)) {
    // Etags always make the request. The request headers will then include the etag.
    // - If there is new data, server returns 200 with data.
    // - Otherwise, returns a 304, with empty request body.
    return NO;

  } else if (request.cachePolicy & (TTURLRequestCachePolicyDisk|TTURLRequestCachePolicyMemory)) {
    id data = nil;
    NSDate* timestamp = nil;
    NSError* error = nil;

    if ([[TTURLCache sharedCache] loadFromCache:request.urlPath cacheKey:request.cacheKey
              expires:request.cacheExpirationAge
              fromDisk:!_suspended && (request.cachePolicy & TTURLRequestCachePolicyDisk)
              data:&data error:&error timestamp:&timestamp]) {
      
      if (([request.response isKindOfClass:[TTURLImageResponse class]]
           && [data isKindOfClass:[UIImage class]])
          && ([request.response isKindOfClass:[TTURLDataResponse class]]
              && [data isKindOfClass:[NSData class]])
          ) {
        request.isLoading = NO;
        
        if (!error) {
          //TODO: fix bug, ImageResponse缓存后，再用DataResponse请求，可以得到Image类型的
          error = [request.response request:request processResponse:nil data:data];
        }
        
        if (error) {
          for (id<TTURLRequestDelegate> delegate in request.delegates) {
            if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
              [delegate request:request didFailLoadWithError:error];
            }
          }
          
        } else {
          request.timestamp = timestamp ? timestamp : [NSDate date];
          request.respondedFromCache = YES;
          
          for (id<TTURLRequestDelegate> delegate in request.delegates) {
            if ([delegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
              [delegate requestDidFinishLoad:request];
            }
          }
        }
        
        return YES;
      }
    }
  }

  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)executeLoader:(TTRequestLoader*)loader {
  id data = nil;
  NSDate* timestamp = nil;
  NSError* error = nil;

  if ((loader.cachePolicy & (TTURLRequestCachePolicyDisk|TTURLRequestCachePolicyMemory))
      && [[TTURLCache sharedCache] loadFromCache:loader.urlPath cacheKey:loader.cacheKey
               expires:loader.cacheExpirationAge
               fromDisk:loader.cachePolicy & TTURLRequestCachePolicyDisk
               data:&data error:&error timestamp:&timestamp]) {
    [_loaders removeObjectForKey:loader.cacheKey];

    if (!error) {
      error = [loader processResponse:nil data:data];
    }
    if (error) {
      [loader dispatchError:error];

    } else {
      //Gary modify
      [loader dispatchLoaded:timestamp loadFromCache:YES];
    }

  } else {
    ++_totalLoading;
    [_runningLoaderQueue addObject:loader];
    [loader load:[NSURL URLWithString:loader.urlPath]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadNextInQueueDelayed {
  if (!_loaderQueueTimer) {
    _loaderQueueTimer = [NSTimer scheduledTimerWithTimeInterval:kFlushDelay target:self
      selector:@selector(loadNextInQueue) userInfo:nil repeats:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadNextInQueue {
  _loaderQueueTimer = nil;
  
  for (int i = 0;
       i < kMaxConcurrentLoads && _totalLoading < kMaxConcurrentLoads
       && _loaderQueue.count && !_suspended;
       ++i) { //Gary fix bug in Three20Network: add &&!_suspended
    TTRequestLoader* loader = [[_loaderQueue objectAtIndex:0] retain];
    [_loaderQueue removeObjectAtIndex:0];
    [self executeLoader:loader];
    [loader release];
  }
  
  if (_totalLoading < kMaxConcurrentLoads && _loaderQueue.count && !_suspended) {
    [self loadNextInQueueDelayed];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeLoader:(TTRequestLoader*)loader {
  --_totalLoading;
  [_runningLoaderQueue removeObject:loader];
  [_loaders removeObjectForKey:loader.cacheKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSuspended:(BOOL)isSuspended {
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"SUSPEND LOADING %d", isSuspended);
  _suspended = isSuspended;

  if (!_suspended) {
    [self loadNextInQueue];

  } else if (_loaderQueueTimer) {
    [_loaderQueueTimer invalidate];
    _loaderQueueTimer = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)sendRequest:(TTURLRequest*)request {
  if ([self loadRequestFromCache:request]) {
    return YES;
  }

  //TODO: move these code into the request
  for (id<TTURLRequestDelegate> delegate in request.delegates) {
    if ([delegate respondsToSelector:@selector(requestDidStartLoad:)]) {
      [delegate requestDidStartLoad:request];
    }
  }

  // If the url is empty, fail.
  if (!request.urlPath.length) {
    //TODO: move these code into the request
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [delegate request:request didFailLoadWithError:error];
      }
    }
    return NO;
  }

  request.isLoading = YES;

  TTRequestLoader* loader = nil;

  // If we're not POSTing or PUTting data, let's see if we can jump on an existing request.
  if (![request.httpMethod isEqualToString:@"POST"]
      && ![request.httpMethod isEqualToString:@"PUT"]) {
    // Next, see if there is an active loader for the URL and if so join that bandwagon.
    loader = [_loaders objectForKey:request.cacheKey];
    if (loader) {
      [loader addRequest:request];
      return NO;
    }
  }

  // Finally, create a new loader and hit the network (unless we are suspended)
  loader = [[TTRequestLoader alloc] initForRequest:request queue:self];
  [_loaders setObject:loader forKey:request.cacheKey];
  if (_suspended || _totalLoading == kMaxConcurrentLoads) {
    [_loaderQueue addObject:loader];

  } else {
    ++_totalLoading;
    [loader load:[NSURL URLWithString:request.urlPath]];
  }
  [loader release];

  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)sendSynchronousRequest:(TTURLRequest*)request {
  if ([self loadRequestFromCache:request]) {
    return YES;
  }

  for (id<TTURLRequestDelegate> delegate in request.delegates) {
    if ([delegate respondsToSelector:@selector(requestDidStartLoad:)]) {
      [delegate requestDidStartLoad:request];
    }
  }

  if (!request.urlPath.length) {
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
    for (id<TTURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [delegate request:request didFailLoadWithError:error];
      }
    }
    return NO;
  }

  request.isLoading = YES;

  // Finally, create a new loader and hit the network (unless we are suspended)
  TTRequestLoader* loader = [[TTRequestLoader alloc] initForRequest:request queue:self];

  // Should be decremented eventually by loadSynchronously
  ++_totalLoading;

  [loader loadSynchronously:[NSURL URLWithString:request.urlPath]];
  TT_RELEASE_SAFELY(loader);

  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelRequest:(TTURLRequest*)request {
  if (request) {
    TTRequestLoader* loader = [_loaders objectForKey:request.cacheKey];
    if (loader) {
      [loader retain];
      if (![loader cancel:request]) {
        [_loaderQueue removeObject:loader];
      }
      [loader release];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelRequestsWithDelegate:(id)delegate {
  NSMutableArray* requestsToCancel = nil;

  for (TTRequestLoader* loader in [_loaders objectEnumerator]) {
    for (TTURLRequest* request in loader.requests) {
      for (id<TTURLRequestDelegate> requestDelegate in request.delegates) {
        if (delegate == requestDelegate) {
          if (!requestsToCancel) {
            requestsToCancel = [NSMutableArray array];
          }
          [requestsToCancel addObject:request];
          break;
        }
      }

      if ([request.userInfo isKindOfClass:[TTUserInfo class]]) {
        TTUserInfo* userInfo = request.userInfo;
        if (userInfo.weakRef && userInfo.weakRef == delegate) {
          if (!requestsToCancel) {
            requestsToCancel = [NSMutableArray array];
          }
          [requestsToCancel addObject:request];
        }
      }
    }
  }

  for (TTURLRequest* request in requestsToCancel) {
    [self cancelRequest:request];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelAllRequests {
  for (TTRequestLoader* loader in [[[_loaders copy] autorelease] objectEnumerator]) {
    [loader cancel];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURLRequest*)createNSURLRequest:(TTURLRequest*)request URL:(NSURL*)URL {
  if (!URL) {
    URL = [NSURL URLWithString:request.urlPath];
  }
  
  NSTimeInterval usedTimeout = request.timeoutInterval;
  
  if (usedTimeout < 0.0 || request == nil) {
    usedTimeout = self.defaultTimeout;
  }
  
  NSMutableURLRequest* URLRequest = [NSMutableURLRequest requestWithURL:URL
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:usedTimeout];

  if (self.userAgent) {
      [URLRequest setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
  }

  if (request) {
    [URLRequest setHTTPShouldHandleCookies:request.shouldHandleCookies];

    NSString* method = request.httpMethod;
    if (method) {
      [URLRequest setHTTPMethod:method];
    }

    NSString* contentType = request.contentType;
    if (contentType) {
      [URLRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }

    NSData* body = request.httpBody;
    if (body) {
      [URLRequest setHTTPBody:body];
    }

    NSDictionary* headers = request.headers;
    for (NSString *key in [headers keyEnumerator]) {
      [URLRequest setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }

    if (![[TTURLCache sharedCache] disableDiskCache]
        && IS_MASK_SET(request.cachePolicy, TTURLRequestCachePolicyEtag)) {
      NSString* etag = [[TTURLCache sharedCache] etagForKey:request.cacheKey];
      TTDCONDITIONLOG(TTDFLAG_ETAGS, @"Etag: %@", etag);

      if (TTIsStringWithAnyText(etag)
          && [[TTURLCache sharedCache] cacheDataExists: request.urlPath
                          cacheKey: request.cacheKey
                           expires: request.cacheExpirationAge
                          fromDisk: !_suspended
                                    && (request.cachePolicy & TTURLRequestCachePolicyDisk)]) {
        // By setting the etag here, we let the server know what the last "version" of the file
        // was that we saw. If the file has changed since this etag, we'll get data back in our
        // response. Otherwise we'll get a 304.
        [URLRequest setValue:etag forHTTPHeaderField:@"If-None-Match"];
      }
    }
  }

  return URLRequest;
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTURLRequestQueue (TTRequestLoader)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)     loader: (TTRequestLoader*)loader
    didLoadResponse: (NSHTTPURLResponse*)response
               data: (id)data {
  [loader retain];
  [self removeLoader:loader];

  NSError* error = [loader processResponse:response data:data];
  if (error) {
    [loader dispatchError:error];

  } else {
    if (!(loader.cachePolicy & TTURLRequestCachePolicyNoCache)) {
      NSLog(@"----------------");
      // Store the etag key if the etag cache policy has been requested.
      if (![[TTURLCache sharedCache] disableDiskCache]
          && IS_MASK_SET(loader.cachePolicy, TTURLRequestCachePolicyEtag)) {
        NSDictionary* headers = [response allHeaderFields];

        // First, try to use the casing as defined by the standard for ETag headers.
        // http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
        NSString* etag = [headers objectForKey:@"ETag"];
        if (nil == etag) {
          // Some servers don't use the standard casing (e.g. twitter).
          etag = [headers objectForKey:@"Etag"];
        }

        // Still no etag?
        if (nil == etag) {
          TTDWARNING(@"Etag expected, but none found.");
          TTDWARNING(@"Here are the headers: %@", headers);

        } else {
          // At last, we have our etag. Let's cache it.

          // First, let's pull out the etag key. This is necessary due to some servers who append
          // information to the etag, such as -gzip for a gzipped request. However, the etag
          // standard states that etags are defined as a quoted string, and that is all.
          NSRange firstQuote = [etag rangeOfString:@"\""];
          NSRange secondQuote = [etag rangeOfString: @"\""
                                            options: 0
                                              range: NSMakeRange(firstQuote.location + 1,
                                                                 etag.length
                                                                 - (firstQuote.location + 1))];
          if (0 == firstQuote.length || 0 == secondQuote.length ||
              firstQuote.location == secondQuote.location) {
            TTDWARNING(@"Invalid etag format. Unable to find a quoted key.");

          } else {
            NSRange keyRange;
            keyRange.location = firstQuote.location;
            keyRange.length = (secondQuote.location - firstQuote.location) + 1;
            NSString* etagKey = [etag substringWithRange:keyRange];
            TTDCONDITIONLOG(TTDFLAG_ETAGS, @"Response etag: %@", etagKey);
            [[TTURLCache sharedCache] storeEtag:etagKey forKey:loader.cacheKey];
          }
        }
      }

      [[TTURLCache sharedCache] storeData:data forKey:loader.cacheKey];
    }
    //Gary modify
    [loader dispatchLoaded:[NSDate date] loadFromCache:NO];
  }
  [loader release];

  [self loadNextInQueue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)               loader:(TTRequestLoader*)loader
    didLoadUnmodifiedResponse:(NSHTTPURLResponse*)response {
  [loader retain];
  [self removeLoader:loader];

  NSData* data = nil;
  NSError* error = nil;
  NSDate* timestamp = nil;
  if ([[TTURLCache sharedCache] loadFromCache:loader.urlPath cacheKey:loader.cacheKey
                  expires:TT_CACHE_EXPIRATION_AGE_NEVER
                 fromDisk:!_suspended && (loader.cachePolicy & TTURLRequestCachePolicyDisk)
                     data:&data error:&error timestamp:&timestamp]) {

    if (nil == error) {
      error = [loader processResponse:response data:data];
    }

    if (nil == error) {
      //Gary delete
//      for (TTURLRequest* request in loader.requests) {
//        request.respondedFromCache = YES;
//      }
      //Gary modify
      [loader dispatchLoaded:[NSDate date] loadFromCache:YES];
    }
  }

  if (nil != error) {
    [loader dispatchError:error];
  }

  [loader release];

  [self loadNextInQueue]; 
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)                       loader: (TTRequestLoader*)loader
    didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge*) challenge {
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"CHALLENGE: %@", challenge);
  [loader dispatchAuthenticationChallenge:challenge];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loader:(TTRequestLoader*)loader didFailLoadWithError:(NSError*)error {
  TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"ERROR: %@", error);
  [self removeLoader:loader];
  [loader dispatchError:error];
  [self loadNextInQueue]; 
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loaderDidCancel:(TTRequestLoader*)loader wasLoading:(BOOL)wasLoading {
  if (wasLoading) {
    [self removeLoader:loader];
    [self loadNextInQueue]; 

  } else {
    [_loaders removeObjectForKey:loader.cacheKey];
  }
}


@end
