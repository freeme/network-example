//
//  BTGlobalFeedController2.h
//  BTNetwork
//
//  Created by He baochen on 12-11-11.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import "BTBaseFeedController.h"
#import "Only320Network.h"

@interface BTGlobalFeedController2 : BTBaseFeedController<TTURLRequestDelegate> {
  NSMutableDictionary *_connectionDict;
}

@end
