//
//  CollectionViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/11.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "CollectionViewController.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController

#pragma mark - 私有方法
- (void)switchTheme {
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (temp) {
    self.view.backgroundColor = [UIColor whiteColor];
//    self.tableView.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
  } else {
    self.view.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
//    self.tableView.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:69.0f/255.0f green:68.0f/255.0f blue:72.0f/255.0f alpha:1.0f]];
  }
//  [self.tableView reloadData];
}

- (void)switchFormat {
  
}

#pragma mark - 初始化
- (void)viewDidLoad {
  [super viewDidLoad];
  //设置navBav格式
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  
  //设置返回button和title
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftArrow"] style:(UIBarButtonItemStylePlain) target:self.revealViewController action:@selector(revealToggle:)];
  leftBarButton.tintColor = [UIColor whiteColor];
  [self.navigationItem setLeftBarButtonItem:leftBarButton];
  UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(switchFormat)];
  rightBarButton.tintColor = [UIColor whiteColor];
  [self.navigationItem setRightBarButtonItem:rightBarButton];
  [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
  [self.navigationItem setTitle:@"收藏"];
  
  [self switchTheme];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchTheme) name:@"switchTheme" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
