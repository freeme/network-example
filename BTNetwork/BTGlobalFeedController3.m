//
//  BTGlobalFeedController3.m
//  BTNetwork
//
//  Created by Gary on 12-11-11.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import "BTGlobalFeedController3.h"
#import "PostTableViewCell.h"

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


@end
