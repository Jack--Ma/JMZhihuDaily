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
  [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:1.0f/255.0f green:131.0f/255.0f blue:209.0f/255.0f alpha:1.0f]];
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
  EditorsTableViewCell *cell = [[EditorsTableViewCell alloc]
                                initWithAvatar:self.editors[indexPath.row][@"avatar"]
                                andName:self.editors[indexPath.row][@"name"]
                                andDetail:self.editors[indexPath.row][@"bio"]];
  
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end