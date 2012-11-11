//
//  BTConsoleViewController.m
//  BTNetwork
//
//  Created by He baochen on 12-11-11.
//  Copyright (c) 2012年 He baochen. All rights reserved.
//

#import "BTConsoleViewController.h"
#import "Only320Network.h"
#import "TTURLRequestQueue-Debug.h"
#import "TTRequestLoader-Debug.h"

#define REQUEST_COUNT @"正在请求: "
#define WAITING_COUNT @"正在等待: "
#define TOTAL_COUNT @"总数   : "
static BTConsoleViewController * instance;

@interface BTConsoleViewController ()

@end

@implementation BTConsoleViewController

+ (BTConsoleViewController*) sharedController {
  @synchronized (self) {
    if (instance == nil) {
      instance = [[BTConsoleViewController alloc] init];
    }
    return instance;
  }
}

- (void) dealloc {
  [_valueUIDict release];
  [_refreshTimer invalidate];
  [_refreshTimer release];
  
  [super dealloc];
}

- (id) init {
  self = [super init];
  if (self) {

  }
  return self;
}

- (UIBarButtonItem*) consoleItem {
  if (_openItem == nil) {
    _openItem = [[UIBarButtonItem alloc] initWithTitle:@"Console" style:UIBarButtonItemStylePlain target:self action:@selector(open)];
  }
  if (self.view.superview) {
    _openItem.style = UIBarButtonItemStyleDone;
    _openItem.action = @selector(close);
  } else {
    _openItem.style = UIBarButtonItemStylePlain;
    _openItem.action = @selector(open);
  }
  return _openItem;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  self.view.frame = CGRectMake(0, 400, 320, 80);
  self.view.backgroundColor= [UIColor blackColor];
  _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                                 selector:@selector(refreshUI) userInfo:nil repeats:YES];
  _valueUIDict = [[NSMutableDictionary dictionaryWithCapacity:8] retain];
  [self addObserver:self
         forKeyPath:REQUEST_COUNT];
  [self addObserver:self
         forKeyPath:WAITING_COUNT];
  [self addObserver:self
         forKeyPath:TOTAL_COUNT];
  
  UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button1.frame = CGRectMake(170, 60, 100, 20);
  [button1 setTitle:@"暂停" forState:UIControlStateNormal];
  [button1 addTarget:self action:@selector(suspendAction:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button1];
}

- (void)suspendAction:(id)sender {
  TTURLRequestQueue *queue = [TTURLRequestQueue mainQueue];
  queue.suspended = !queue.suspended;
  if (queue.suspended) {
    [sender setTitle:@"继续" forState:UIControlStateNormal];
  } else {
    [sender setTitle:@"暂停" forState:UIControlStateNormal];
  }
}

- (void) addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
  //    TTURLRequestQueue *queue = [TTURLRequestQueue mainQueue];
  //    [queue addObserver:observer forKeyPath:keyPath];
  [self addKeyLabelWithY:_labelPosY text:keyPath];
  [self addValueLabelWithY:_labelPosY key:keyPath];
  _labelPosY += 20;
}

- (void) addKeyLabelWithY:(CGFloat)y text:(NSString*)text {
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 200, 20)];
  label.text = [NSString stringWithFormat:@"%@ ", text];
  label.textColor = [UIColor whiteColor];
  label.backgroundColor = [UIColor blackColor];
  [self.view addSubview:label];
  [label release];
}

- (void) addValueLabelWithY:(CGFloat)y key:(NSString*)key {
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(210, y, 100, 20)];
  label.textColor = [UIColor whiteColor];
  label.backgroundColor = [UIColor blackColor];
  [self.view addSubview:label];
  [_valueUIDict setValue:label forKey:key];
  [label release];
}

- (void) refreshUI {
  TTURLRequestQueue *queue = [TTURLRequestQueue mainQueue];
  UILabel *label = [_valueUIDict objectForKey:WAITING_COUNT];
  label.text = [NSString stringWithFormat:@"%d", [queue.loaderQueue count]];
  
  label = [_valueUIDict objectForKey:TOTAL_COUNT];
  label.text = [NSString stringWithFormat:@"%d", [queue.loaders count]];
  
  label = [_valueUIDict objectForKey:REQUEST_COUNT];
  label.text = [NSString stringWithFormat:@"%d", queue.totalLoading];
  
}

- (void)open {
  UIApplication* appDelegate = [UIApplication sharedApplication];
  [appDelegate.keyWindow addSubview:self.view];
  _openItem.style = UIBarButtonItemStyleDone;
  _openItem.action = @selector(close);
}

- (void)close {
  [self.view removeFromSuperview];
  _openItem.style = UIBarButtonItemStylePlain;
  _openItem.action = @selector(open);
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;{
//  NSLog(@"%s",__FUNCTION__);
//}
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;{
//  NSLog(@"%s",__FUNCTION__);
//}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//  NSLog(@"%s",__FUNCTION__);
//}
@end
