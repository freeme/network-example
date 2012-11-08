//
//  BTRootViewController.m
//  BTNetwork
//
//  Created by He baochen on 12-11-6.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import "BTRootViewController.h"
#import "BTBaseFeedController.h"

@interface BTRootViewController ()

@end

@implementation BTRootViewController

- (void)dealloc {
  [_demoItems release];
  
  [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
      _demoItems = [[NSMutableArray alloc] initWithCapacity:4];
      [_demoItems addObject:@"GlobalFeed Demo 1"];
    }
    return self;
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
    return [_demoItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  cell.textLabel.text = [_demoItems objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == 0) {
    BTBaseFeedController *controller = [[BTBaseFeedController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
  }
}

@end
