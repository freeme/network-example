//
//  BTGlobalFeedController1.m
//  BTNetwork
//
//  Created by Gary on 12-11-8.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import "BTGlobalFeedController1.h"
#import "Post.h"
#import "User.h"
@interface BTGlobalFeedController1 ()

@end

@implementation BTGlobalFeedController1

- (void)dealloc {
  [_connectionDict release];
  [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
      _connectionDict = [[NSMutableDictionary alloc] initWithCapacity:16];
      self.title = @"Controller1";
    }

    return self;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  Post *post = [_posts objectAtIndex:indexPath.row];
  if (post.user.avatarImage == nil ) { //没有头像，发送请求
    NSArray *key = [_connectionDict allKeysForObject:post.user];
    if ([key count] == 0) { //没有请求正发送中
      NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:post.user.avatarImageURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
      NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
      [request release];
      [_connectionDict setValue:post.user forKey:[conn description]];
    } else {
      //已经发送过请求了，还没返回
      
    }
    cell.imageView.image = [UIImage imageNamed:@"profile-image-placeholder.png"];

  } else {
    cell.imageView.image = post.user.avatarImage;
  }
  cell.textLabel.text = post.user.username;
  return cell;
}

#pragma mark - NSURLRequestDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [_connectionDict removeObjectForKey:[connection description]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;{
  //检查返回的HTTP Status Code
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;{
  
  User *user = (User*)[_connectionDict objectForKey:[connection description]];
  if (user.tempData == nil) {
    user.tempData = [NSMutableData dataWithCapacity:0];
  }
  //从网络接收返回的数量，多次调用，直到数据全部下载完成
  [user.tempData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;{  
  User *user = (User*)[_connectionDict objectForKey:[connection description]];
  user.avatarImage = [UIImage imageWithData:user.tempData];
  //将临时数据请空
  user.tempData = nil;
  [_connectionDict removeObjectForKey:[connection description]];
  
  //让TableView重新加载一次数据
  [self.tableView reloadData];
}
#pragma mark -
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Navigation logic may go here. Create and push another view controller.
  
  BTGlobalFeedController1 *controller = [[BTGlobalFeedController1 alloc] init];
  // ...
  // Pass the selected object to the new view controller.
  [self.navigationController pushViewController:controller animated:YES];
  [controller release];
  
}

@end
