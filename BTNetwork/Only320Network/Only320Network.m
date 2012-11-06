//
//  Only320Network.m
//  320NetworkDemo
//
//  Created by he baochen on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Only320Network.h"

// Core
#import "TTDebug.h"

#import <UIKit/UIKit.h>
#import <pthread.h>

static int              gNetworkTaskCount = 0;
static pthread_mutex_t  gMutex = PTHREAD_MUTEX_INITIALIZER;


///////////////////////////////////////////////////////////////////////////////////////////////////
void TTNetworkRequestStarted() {
    pthread_mutex_lock(&gMutex);
    
    if (0 == gNetworkTaskCount) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    gNetworkTaskCount++;
    
    pthread_mutex_unlock(&gMutex);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
void TTNetworkRequestStopped() {
    pthread_mutex_lock(&gMutex);
    
    --gNetworkTaskCount;
    // If this asserts, you don't have enough stop requests to match your start requests.
    TTDASSERT(gNetworkTaskCount >= 0);
    gNetworkTaskCount = MAX(0, gNetworkTaskCount);
    
    if (gNetworkTaskCount == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    pthread_mutex_unlock(&gMutex);
}
