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
#define CACHE_IMAGE_COUNT @"缓存图片数量: "
#define CACHE_MEMO_COUNT @"缓存图片占内存: "
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
  _labelPosY = 0;
  self.view.backgroundColor= [UIColor darkGrayColor];
  self.view.alpha = 0.9;
  _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                                 selector:@selector(refreshUI) userInfo:nil repeats:YES];
  _valueUIDict = [[NSMutableDictionary dictionaryWithCapacity:8] retain];

  [self addKVLabelForKey:REQUEST_COUNT];
  UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button1.frame = CGRectMake(240, _labelPosY, 70, 20);
  [button1 setTitle:@"暂停" forState:UIControlStateNormal];
  [button1 addTarget:self action:@selector(suspendAction:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button1];
    _labelPosY += 20;
  [self addKVLabelForKey:WAITING_COUNT];
    _labelPosY += 20;
  [self addKVLabelForKey:TOTAL_COUNT];
    _labelPosY += 20;
  [self addKVLabelForKey:CACHE_IMAGE_COUNT];
   _labelPosY += 20;
  [self addKVLabelForKey:CACHE_MEMO_COUNT];
  UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button2.frame = CGRectMake(240, _labelPosY, 70, 20);
  [button2 setTitle:@"清内存" forState:UIControlStateNormal];
  [button2 addTarget:self action:@selector(clearMemory) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button2];
  _labelPosY+=20;
  [self addKVLabelForKey:@"禁用图片(内存)缓存"];
  UISwitch *switchControl1 = [[UISwitch alloc] initWithFrame:CGRectMake(150, _labelPosY, 0, 0)];
  [switchControl1 addTarget:self action:@selector(disableImageCache:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:switchControl1];
  [switchControl1 release];
  _labelPosY+=20;
  [self addKVLabelForKey:@"禁用本地缓存"];
  UISwitch *switchControl2 = [[UISwitch alloc] initWithFrame:CGRectMake(150, _labelPosY, 0, 0)];
  switchControl2.on = [TTURLCache sharedCache].disableDiskCache;
  [switchControl2 addTarget:self action:@selector(disableLocalCache:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:switchControl2];
  [switchControl2 release];
  UIButton *button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button3.frame = CGRectMake(240, _labelPosY, 70, 20);
  [button3 setTitle:@"清本地" forState:UIControlStateNormal];
  [button3 addTarget:self action:@selector(clearDisk) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button3];
   _labelPosY+=20;
  self.view.frame = CGRectMake(0, 480-_labelPosY, 320, _labelPosY);
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

- (void)clearMemory {
  TTURLCache *cache = [TTURLCache sharedCache];
  [cache removeAll:NO];
}

- (void)clearDisk {
  TTURLCache *cache = [TTURLCache sharedCache];
  [cache removeAll:YES];
}

- (void)disableImageCache:(id)sender {
  UISwitch *switchControl = (UISwitch*)sender;
  [TTURLCache sharedCache].disableImageCache = switchControl.on;
}

- (void)disableLocalCache:(id)sender {
  UISwitch *switchControl = (UISwitch*)sender;
  [TTURLCache sharedCache].disableDiskCache = switchControl.on;
}

- (void) addKVLabelForKey:(NSString *)key {
  //    TTURLRequestQueue *queue = [TTURLRequestQueue mainQueue];
  //    [queue addObserver:observer forKeyPath:keyPath];
  [self addKeyLabelWithY:_labelPosY text:key];
  [self addValueLabelWithY:_labelPosY key:key];

}

- (void) addKeyLabelWithY:(CGFloat)y text:(NSString*)text {
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 150, 20)];
  label.text = [NSString stringWithFormat:@"%@ ", text];
  label.font = [UIFont boldSystemFontOfSize:18];
  label.textColor = [UIColor whiteColor];
  label.shadowColor = [UIColor blackColor];
  label.shadowOffset = CGSizeMake(-1, -1);
  label.backgroundColor = [UIColor clearColor];
  [self.view addSubview:label];
  [label release];
}

- (void) addValueLabelWithY:(CGFloat)y key:(NSString*)key {
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(150, y, 100, 20)];
  label.font = [UIFont boldSystemFontOfSize:18];
  label.textColor = [UIColor whiteColor];
  label.shadowColor = [UIColor blackColor];
  label.backgroundColor = [UIColor clearColor];
  label.shadowOffset = CGSizeMake(-1, -1);
  [self.view addSubview:label];
  [_valueUIDict setValue:label forKey:key];
  [label release];
}

- (void) refreshUI {
  TTURLRequestQueue *queue = [TTURLRequestQueue mainQueue];
  TTURLCache *cache = [TTURLCache sharedCache];
  UILabel *label = [_valueUIDict objectForKey:WAITING_COUNT];
  label.text = [NSString stringWithFormat:@"%d", [queue.loaderQueue count]];
  
  label = [_valueUIDict objectForKey:TOTAL_COUNT];
  label.text = [NSString stringWithFormat:@"%d", [queue.loaders count]];
  
  label = [_valueUIDict objectForKey:REQUEST_COUNT];
  label.text = [NSString stringWithFormat:@"%d", queue.totalLoading];
  
  label = [_valueUIDict objectForKey:CACHE_IMAGE_COUNT];
  label.text = [NSString stringWithFormat:@"%d", cache.imageCountInMemory];
  
  label = [_valueUIDict objectForKey:CACHE_MEMO_COUNT];
  label.text = [NSString stringWithFormat:@"%.2f MB", (float)cache.totalPixelCount * 4 / 1024 / 1024];
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
