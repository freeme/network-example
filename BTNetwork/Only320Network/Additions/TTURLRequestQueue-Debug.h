//
//  TTURLRequestQueue-Debug.h
//  320NetworkDemo
//
//  Created by he baochen on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTURLRequestQueue.h"

@interface TTURLRequestQueue(Debug) 

@property(nonatomic, readonly) NSArray *loaderQueue;
@property(nonatomic, readonly) NSArray *runningLoaderQueue;
@property(nonatomic, readonly) NSDictionary*  loaders;
@property(nonatomic, readonly) NSInteger totalLoading;

@end
