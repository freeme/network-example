//
//  Only320Network.h
//  Only320Network
//
//  Created by he baochen on 12-3-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//



#import "TTURLRequestCachePolicy.h"
#import "TTErrorCodes.h"

// - Requests

#import "TTRequestLoader.h"
#import "TTURLRequest.h"
#import "TTURLRequestDelegate.h"

// - Responses
#import "TTURLResponse.h"
#import "TTURLDataResponse.h"
#import "TTURLImageResponse.h"

// - Classes
#import "TTUserInfo.h"
#import "TTURLRequestQueue.h"
#import "TTURLCache.h"


/**
 * Increment the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 *
 * @threadsafe
 */
void TTNetworkRequestStarted();

/**
 * Decrement the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 *
 * @threadsafe
 */
void TTNetworkRequestStopped();

///////////////////////////////////////////////////////////////////////////////////////////////////
// Images
