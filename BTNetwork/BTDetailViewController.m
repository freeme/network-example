//
//  BTDetailViewController.m
//  BTNetwork
//
//  Created by He baochen on 12-11-11.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import "BTDetailViewController.h"
#import "User.h"
@interface BTDetailViewController ()

@end

@implementation BTDetailViewController

- (void)dealloc {
  self.user = nil;
  [_avaterImageView release];
  [_nameLabel release];
  [_coverImageView release];
  [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
  _avaterImageView = [[TTNetImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
  _avaterImageView.defaultImage = [UIImage imageNamed:@"profile-image-placeholder.png"];
  _avaterImageView.clipsToBounds = YES;
  _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 200, 100)];
  _coverImageView = [[TTNetImageView alloc] initWithFrame:CGRectMake(10, 120, 300, 300)];
  _coverImageView.clipsToBounds = YES;
  _coverImageView.defaultImage = [UIImage imageNamed:@"profile-image-placeholder.png"];
  
  [self.view addSubview:_avaterImageView];
  [self.view addSubview:_nameLabel];
  [self.view addSubview:_coverImageView];
  _avaterImageView.urlPath = self.user.avatarImageURL;
  _nameLabel.text = [NSString stringWithFormat:@"%@%@",self.user.username,NSStringFromCGSize(_user .coverImageSize)];
  _coverImageView.urlPath = self.user.coverImageURL;
}

@end
