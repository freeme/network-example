//
//  TTNetImageView.m
//  320NetworkDemo
//
//  Created by he baochen on 12-3-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TTNetImageView.h"
#import "TTNetImageViewDelegate.h"

// Network
#import "TTURLCache.h"
#import "TTURLImageResponse.h"
#import "TTURLRequest.h"

#import "NSStringAdditions.h"

@interface TTNetImageView (Private)

- (BOOL) sendRequest;

@end

@implementation TTNetImageView

@synthesize urlPath             = _urlPath;
@synthesize defaultImage        = _defaultImage;
@synthesize request				= _request;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize autoDisplayActivityIndicator = _autoDisplayActivityIndicator;
@synthesize sendRequestOnClick = _sendRequestOnClick;

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      _autoDisplayActivityIndicator = NO;
      _sendRequestOnClick = NO;
    }
    return self;
}

- (void)dealloc {
  _delegate = nil;
  [_request cancel];
  TT_RELEASE_SAFELY(_request);
  TT_RELEASE_SAFELY(_urlPath);
  TT_RELEASE_SAFELY(_defaultImage);
  TT_RELEASE_SAFELY(_activityIndicatorView);
  
  [super dealloc];
}

#pragma mark -
#pragma mark TTURLRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidStartLoad:(TTURLRequest*)request {
  [_request release];
  _request = [request retain];
  
  [self imageViewDidStartLoad];
  if ([_delegate respondsToSelector:@selector(netImageViewDidStartLoad:)]) {
    [_delegate netImageViewDidStartLoad:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLImageResponse* response = request.response;
  [self setImage:response.image];
  NSLog(@"respondedFromCache = %d", request.respondedFromCache);

  [self imageViewDidLoadImage:response.image];
  if ([_delegate respondsToSelector:@selector(netImageView:didLoadImage:)]) {
    [_delegate netImageView:self didLoadImage:response.image];
  }
  TT_RELEASE_SAFELY(_request);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_request);
  
  [self imageViewDidFailLoadWithError:error];
  if ([_delegate respondsToSelector:@selector(netImageView:didFailLoadWithError:)]) {
    [_delegate netImageView:self didFailLoadWithError:error];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidCancelLoad:(TTURLRequest*)request {
  TT_RELEASE_SAFELY(_request);
  
  [self imageViewDidFailLoadWithError:nil];
  if ([_delegate respondsToSelector:@selector(netImageView:didFailLoadWithError:)]) {
    [_delegate netImageView:self didFailLoadWithError:nil];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return !!_request;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
  return nil != self.image && self.image != _defaultImage;
}

- (void) setSendRequestOnClick:(BOOL)isLoadOnClick {
  if (_sendRequestOnClick != isLoadOnClick) {
    _sendRequestOnClick = isLoadOnClick;
    self.userInteractionEnabled = _sendRequestOnClick;
  }
}

- (void)setAutoDisplayActivityIndicator:(BOOL) isAutoDisplay {
  if (_autoDisplayActivityIndicator!=isAutoDisplay) {
    _autoDisplayActivityIndicator = isAutoDisplay;
    if (_autoDisplayActivityIndicator) {
      [self addSubview:self.activityIndicatorView];
    } else {
      if (_activityIndicatorView) {
        [_activityIndicatorView removeFromSuperview];
        TT_RELEASE_SAFELY(_activityIndicatorView);
      }
    }
  }
}

- (UIActivityIndicatorView*) activityIndicatorView {
  if (_activityIndicatorView == nil) {
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
  }
  return _activityIndicatorView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
  if (nil == _request && nil != _urlPath) {
    UIImage* image = [[TTURLCache sharedCache] imageForURL:_urlPath];
    
    if (nil != image) {
      self.image = image;
      
    } else {
      BOOL send = NO;
      if (!_sendRequestOnClick) {
        send = [self sendRequest];
      }
      if (!send) {
        // Put the default image in place while waiting for the request to load
        if (_defaultImage && nil == self.image) {
          self.image = _defaultImage;
        }
      }
    }
  }
}

- (BOOL) sendRequest {
  TTURLRequest* request = [TTURLRequest requestWithURL:_urlPath delegate:self];
  request.response = [[[TTURLImageResponse alloc] init] autorelease];
  
  // Give the delegate one chance to configure the requester.
  if ([_delegate respondsToSelector:@selector(netImageView:willSendARequest:)]) {
    [_delegate netImageView:self willSendARequest:request];
  }
  return [request send];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopLoading {
  [_request cancel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidStartLoad {
  if (_autoDisplayActivityIndicator) {
    [_activityIndicatorView startAnimating];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidLoadImage:(UIImage*)image {
  if (_autoDisplayActivityIndicator) {
    [_activityIndicatorView stopAnimating];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidFailLoadWithError:(NSError*)error {
  if (_autoDisplayActivityIndicator) {
    [_activityIndicatorView stopAnimating];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unsetImage {
  [_activityIndicatorView stopAnimating];
  [self stopLoading];
  self.image = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDefaultImage:(UIImage*)theDefaultImage {
  if (_defaultImage != theDefaultImage) {
    [_defaultImage release];
    _defaultImage = [theDefaultImage retain];
  }
  if (nil == _urlPath || 0 == _urlPath.length) {
    //no url path set yet, so use it as the current image
    self.image = _defaultImage;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUrlPath:(NSString*)urlPath {
  // Check for no changes.
  if (nil != self.image && nil != _urlPath && [urlPath isEqualToString:_urlPath]) {
    return;
  }
  
  //[self stopLoading];
  [self unsetImage];
  {
    NSString* urlPathCopy = [urlPath copy];
    [_urlPath release];
    _urlPath = urlPathCopy;
  }
  
  if (nil == _urlPath || 0 == _urlPath.length) {
    // Setting the url path to an empty/nil path, so let's restore the default image.
    self.image = _defaultImage;
    
  } else {
    [self reload];
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!self.isLoading && !self.isLoaded) {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds,point)) {
      NSLog(@"%s",__FUNCTION__);
      [self sendRequest];
    }
  }
}

@end
