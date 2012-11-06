//
//  TTURLRequestQueue-Debug.m
//  320NetworkDemo
//
//  Created by he baochen on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TTURLRequestQueue-Debug.h"

@implementation TTURLRequestQueue(Debug)

- (NSArray*)loaderQueue {
    return _loaderQueue;
}

- (NSArray*)runningLoaderQueue {
    return _runningLoaderQueue;
}

- (NSDictionary*)loaders {
    return _loaders;
}

- (NSInteger)totalLoading {
    return _totalLoading;
}

@end
