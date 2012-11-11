//
//  BTDetailViewController.h
//  BTNetwork
//
//  Created by He baochen on 12-11-11.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTNetImageView.h"
@class User;

@interface BTDetailViewController : UIViewController {
  User *_user;
  TTNetImageView *_avaterImageView;
  UILabel *_nameLabel;
  TTNetImageView *_coverImageView;
}

@property(nonatomic, retain) User* user;

@end
