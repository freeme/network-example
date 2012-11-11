//
//  BTConsoleViewController.h
//  BTNetwork
//
//  Created by He baochen on 12-11-11.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTConsoleViewController : UIViewController {
  NSMutableDictionary *_valueUIDict;
  CGFloat _labelPosY;
  NSTimer *_refreshTimer;
  UIBarButtonItem *_openItem;
  UIBarButtonItem *_closeItem;
}

@property(nonatomic, readonly)     UIBarButtonItem *consoleItem;

+ (BTConsoleViewController*) sharedController;

- (void)open;
- (void)close;

@end
