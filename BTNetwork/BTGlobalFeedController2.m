//
//  BTGlobalFeedController2.m
//  BTNetwork
//
//  Created by He baochen on 12-11-11.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import "BTGlobalFeedController2.h"
#import "BTGlobalFeedController2n.h"
#import "BTConsoleViewController.h"
#import "BTDetailViewController.h"
#import "Post.h"
#import "User.h"

@interface BTGlobalFeedController2 ()

@end

@implementation BTGlobalFeedController2

- (void)dealloc {
  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
  [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
    _connectionDict = [[NSMutableDictionary alloc] initWithCapacity:16];
    self.title = @"Controller2";
  }
  return self;
}

- (void)viewDidDisappear:(BOOL)animated {
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  
  Post *post = [_posts objectAtIndex:indexPath.row];
  if (post.user.avatarImage == nil ) { //没有头像，发送请求
    
    //NSArray *key = [_connectionDict allKeysForObject:post.user];
    Post *requestPost = [_connectionDict objectForKey:post.user.avatarImageURL];
    
    if (requestPost == nil) { //没有请求正发送中
      TTURLRequest *request = [[TTURLRequest alloc] initWithURL:post.user.avatarImageURL delegate:self];
      request.response = [[[TTURLDataResponse alloc] init] autorelease];
      [[TTURLRequestQueue mainQueue] sendRequest:request];
      [_connectionDict setValue:post.user forKey:request.urlPath];
      [request autorelease];
    } else {
      //已经发送过请求了，还没返回
      
    }
    cell.imageView.image = [UIImage imageNamed:@"profile-image-placeholder.png"];
    
  } else {
    cell.imageView.image = post.user.avatarImage;
  }
  cell.textLabel.text = post.user.username;
  cell.detailTextLabel.text = post.user.coverImageURL;
  return cell;
}

#pragma mark - TTURLRequestDelegate

- (void)requestDidFinishLoad:(TTURLRequest*)request;{
  
  User *user = (User*)[_connectionDict objectForKey:request.urlPath];
  TTURLDataResponse *dataResponse = request.response;
  user.avatarImage = [UIImage imageWithData:dataResponse.data];
  [_connectionDict removeObjectForKey:request.urlPath];
  
  //让TableView重新加载一次数据
  [self.tableView reloadData];
}


/**
 * The request failed to load.
 */
- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error;{
  [_connectionDict removeObjectForKey:request.urlPath];
}

/**
 * The request was canceled.
 */
- (void)requestDidCancelLoad:(TTURLRequest*)request;{
  [_connectionDict removeObjectForKey:request.urlPath];
}

#pragma mark -
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //Navigation logic may go here. Create and push another view controller.
  
//  BTGlobalFeedController2 *controller = [[BTGlobalFeedController2 alloc] init];
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
