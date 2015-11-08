//
//  WebViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/8.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "WebViewController.h"
#import "AppDelegate.h"

@interface WebViewController () <UIScrollViewDelegate, UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIView *statusBarBackground;

@end

@implementation WebViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  //避免因含有navBar而对scrollInsets做自动调整
  //避免ScrollView莫名其妙不能在viewController划到顶
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  //避免wenScrollView的contentView过长，挡住底层View
  self.view.clipsToBounds = YES;
  
  //隐藏默认返回button但保留左划返回
  self.navigationItem.hidesBackButton = NO;
  self.navigationController.interactivePopGestureRecognizer.enabled = YES;
  self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
  
  //对webView做基本配置
  self.webView.delegate = self;
  self.webView.scrollView.delegate = self;
  self.webView.scrollView.clipsToBounds = NO;
  self.webView.scrollView.showsVerticalScrollIndicator = NO;
}

#pragma mark - 其他函数
- (AppDelegate*)getApp {
  return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}
@end
