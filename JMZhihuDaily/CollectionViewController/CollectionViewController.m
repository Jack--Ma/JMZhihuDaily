//
//  CollectionViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/11.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionTableViewController.h"
#import "CollectionCollectionViewController.h"
#import "UserModel.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController {
  CollectionTableViewController *_collectionTableViewController;
  CollectionCollectionViewController *_collectionCollectionViewController;
  
  BOOL _isTable;
}

#pragma mark - 私有方法
- (void)switchTheme {
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (temp) {
    self.view.backgroundColor = [UIColor whiteColor];
    _collectionTableViewController.tableView.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
  } else {
    self.view.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    _collectionTableViewController.tableView.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:69.0f/255.0f green:68.0f/255.0f blue:72.0f/255.0f alpha:1.0f]];
  }
  [_collectionTableViewController.tableView reloadData];
}

- (void)switchFormat {
  if (_isTable) {
    [UIView animateWithDuration:0.3 animations:^{
      [_collectionTableViewController.view setHidden:YES];
    }];
  } else {
    [UIView animateWithDuration:0.3 animations:^{
      [_collectionTableViewController.view setHidden:NO];
    }];
  }
  _isTable = !_isTable;
}

#pragma mark - 初始化
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

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
  
  _collectionTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectionTableViewController"];
  [self addChildViewController:_collectionTableViewController];
  [self.view addSubview:_collectionTableViewController.view];
  _isTable = YES;
  
  [self switchTheme];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchTheme) name:@"switchTheme" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
