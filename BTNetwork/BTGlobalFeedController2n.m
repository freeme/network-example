//
//  BTGlobalFeedController2n.m
//  BTNetwork
//
//  Created by He baochen on 12-11-11.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import "BTGlobalFeedController2n.h"
#import "Post.h"

@interface BTGlobalFeedController2n ()

@end

@implementation BTGlobalFeedController2n

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    _posts = [[NSMutableArray alloc] initWithCapacity:40];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"global1" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    NSArray *postsFromResponse = [responseJSON valueForKeyPath:@"data"];
    
    for (NSDictionary *attributes in postsFromResponse) {
      Post *post = [[Post alloc] initWithAttributes:attributes];
      [_posts addObject:post];
      [post release];
    }
    
    self.title = @"Controller2";
    NSLog(@"Post count = %d", [_posts count]);
  }
  return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
