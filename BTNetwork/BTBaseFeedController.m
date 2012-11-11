//
//  BTGlobalFeedController.m
//  BTNetwork
//
//  Created by He baochen on 12-11-6.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import "BTBaseFeedController.h"
#import "Post.h"

@interface BTBaseFeedController ()

@end

@implementation BTBaseFeedController

- (void)dealloc {
  [_posts release];
  [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
      _posts = [[NSMutableArray alloc] initWithCapacity:40];
      
      NSURL *url = [[NSBundle mainBundle] URLForResource:@"global0" withExtension:@"json"];
      NSData *data = [NSData dataWithContentsOfURL:url];
      id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
      NSArray *postsFromResponse = [responseJSON valueForKeyPath:@"data"];
      
      for (NSDictionary *attributes in postsFromResponse) {
        Post *post = [[Post alloc] initWithAttributes:attributes];
        [_posts addObject:post];
        [post release];
      }
      

      NSLog(@"Post count = %d", [_posts count]);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
  return [_posts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
