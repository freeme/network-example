//
//  BTGlobalFeedController1.h
//  BTNetwork
//
//  Created by Gary on 12-11-8.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTBaseFeedController.h"


@interface BTGlobalFeedController1 : BTBaseFeedController<NSURLConnectionDelegate> {
  NSMutableDictionary *_connectionDict;
}

@end
