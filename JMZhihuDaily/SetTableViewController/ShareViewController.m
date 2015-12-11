//
//  ShareViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/28.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "ShareViewController.h"
#import "WXApi.h"

@interface ShareViewController () <WXApiDelegate>

@end

@implementation ShareViewController

- (void)backToLastView {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)switchTheme {
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (temp) {
    self.view.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
  } else {
    self.view.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:69.0f/255.0f green:68.0f/255.0f blue:72.0f/255.0f alpha:1.0f]];
  }
}

- (UIButton *)createShareButton: (CGRect)rect {
  UIButton *button = [[UIButton alloc] initWithFrame:rect];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  button.layer.cornerRadius = rect.size.height / 3.0;
  button.layer.borderColor = [UIColor whiteColor].CGColor;
  button.layer.borderWidth = 1.0f;
  
  return button;
}

#pragma mark - WX Share && WXApiDelegate
- (void)weixinShare:(id)sender {
  WXImageObject *imageObj = [WXImageObject object];
  imageObj.imageUrl = @"http://ac-usm1cbtx.clouddn.com/TPdC2sIHcRbsSTarVKCTHEA.jpeg";
  
  WXWebpageObject *webObj = [WXWebpageObject object];
  webObj.webpageUrl = @"http://ac-usm1cbtx.clouddn.com/TPdC2sIHcRbsSTarVKCTHEA.jpeg";
  
  WXMediaMessage *message = [WXMediaMessage message];
  message.title = @"JM日报 看见世界";
  message.description = @"看他人分享知识 经验 见解";
  message.mediaObject = webObj;
  UIImage *image = [UIImage imageNamed:@"app-icon-180"];
  message.thumbData = UIImageJPEGRepresentation(image, 1.0);
  
  SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
  UIButton *temp = (UIButton *)sender;
  if (temp.viewOrigin.y == 84.0) {
    req.scene = WXSceneSession;
  } else {
    req.scene = WXSceneTimeline;
  }
  req.bText = NO;
  req.message = message;

  [WXApi sendReq:req];
}

#pragma mark - 初始化
- (void)viewDidLoad {
  [super viewDidLoad];
  //设置navBav格式
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

  //设置返回button和title
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftArrow"] style:(UIBarButtonItemStylePlain) target:self action:@selector(backToLastView)];
  leftBarButton.tintColor = [UIColor whiteColor];
  self.navigationController.interactivePopGestureRecognizer.enabled = YES;
  self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
  
  [self.navigationItem setLeftBarButtonItem:leftBarButton];
  [self.navigationItem setTitle:@"分享"];
  
  //分享到微信朋友
  UIButton *weixin = [self createShareButton:CGRectMake(20, 84, self.view.width-40, 44)];
  [weixin setBackgroundColor:[UIColor colorWithRed:160.0/255.0 green:237.0/255.0 blue:121.0/255.0 alpha:1.0]];
  [weixin setTitle:@"分享到微信" forState:UIControlStateNormal];
  [weixin addTarget:self action:@selector(weixinShare:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:weixin];
  
  //分享到朋友圈
  UIButton *weixinCircle = [self createShareButton:CGRectMake(20, 148, self.view.width-40, 44)];
  [weixinCircle setBackgroundColor:[UIColor colorWithRed:160.0/255.0 green:237.0/255.0 blue:121.0/255.0 alpha:1.0]];
  [weixinCircle setTitle:@"分享到朋友圈" forState:UIControlStateNormal];
  [weixinCircle addTarget:self action:@selector(weixinShare:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:weixinCircle];
  
  [self switchTheme];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
