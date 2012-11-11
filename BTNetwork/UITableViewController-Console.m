//
//  UIViewController-Console.m
//  BTNetwork
//
//  Created by He baochen on 12-11-11.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import "UITableViewController-Console.h"
#import "BTConsoleViewController.h"


@implementation UITableViewController(Console)

- (void)viewDidLoad {
  [super viewDidLoad];
  BTConsoleViewController *consoleController = [BTConsoleViewController sharedController];
  self.navigationItem.rightBarButtonItem = consoleController.consoleItem;
}

@end
