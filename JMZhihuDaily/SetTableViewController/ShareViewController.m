//
//  ShareViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/28.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

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
  
  [self switchTheme];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
