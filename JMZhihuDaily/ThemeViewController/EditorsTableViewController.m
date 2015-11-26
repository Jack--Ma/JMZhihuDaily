//
//  EditorsTableViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/23.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "EditorsTableViewController.h"
#import "EditorsTableViewCell.h"

@interface EditorsTableViewController ()

@end

@implementation EditorsTableViewController

#pragma mark - 私有方法
- (void)backToLastView {
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 初始化
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
//  [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:1.0f/255.0f green:131.0f/255.0f blue:209.0f/255.0f alpha:1.0f]];
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (temp) {
    self.tableView.backgroundColor = [UIColor whiteColor];
  } else {
    self.tableView.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:51.0/255.0 blue:55.0/255.0 alpha:1];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  //设置navBar
  [self.navigationItem setTitle:@"栏目编辑"];
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(backToLastView)];
  leftBarButton.tintColor = [UIColor whiteColor];
  [self.navigationItem setLeftBarButtonItem:leftBarButton];
  
  self.navigationController.interactivePopGestureRecognizer.enabled = YES;
  self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.editors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EditorsTableViewCell *cell = [[EditorsTableViewCell alloc] init];
  cell.avatar = self.editors[indexPath.row][@"avatar"];
  cell.name = self.editors[indexPath.row][@"name"];
  cell.detail = self.editors[indexPath.row][@"bio"];
  [cell awakeFromNib];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  NSString *URLString = self.editors[indexPath.row][@"url"];
  NSURL *url = [NSURL URLWithString:URLString];
  
  [[UIApplication sharedApplication] openURL:url];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 50.0f;
}

@end
