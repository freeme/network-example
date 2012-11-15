//
//  BTGlobalFeedController3.m
//  BTNetwork
//
//  Created by Gary on 12-11-11.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import "BTGlobalFeedController3.h"
#import "PostTableViewCell.h"
#import "BTDetailViewController.h"
#import "Post.h"
#import "User.h"
@interface BTGlobalFeedController3 ()

@end

@implementation BTGlobalFeedController3

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  PostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[PostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  Post *post = [_posts objectAtIndex:indexPath.row];
  cell.post = post;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //Navigation logic may go here. Create and push another view controller.
  
  //  BTGlobalFeedController3 *controller = [[BTGlobalFeedController3 alloc] init];
  //  // ...
  //  // Pass the selected object to the new view controller.
  //  [self.navigationController pushViewController:controller animated:YES];
  //  [controller release];
  
  BTDetailViewController *controller = [[BTDetailViewController alloc] init];
  // ...
  // Pass the selected object to the new view controller.
  Post *post = [_posts objectAtIndex:indexPath.row];
  controller.user = post.user;
  [self.navigationController pushViewController:controller animated:YES];
  [controller release];
  
}

@end
