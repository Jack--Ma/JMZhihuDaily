//
//  SideMenuViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/4.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "SideMenuViewController.h"
#import "AppDelegate.h"
#import "HomeSideCell.h"
#import "ContentSideCell.h"
#import "ThemeViewController.h"

@interface SideMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SideMenuViewController {
  GradientView *_backView;
}

#pragma mark - init
- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  
  //最下方的cell添加渐变的背景
  _backView = [[GradientView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 45 - 50, self.view.frame.size.width, 50) type:TRANSPARENT_ANOTHER_GRADIENT_TYPE];
  [self.view addSubview:_backView];
  
  [self.view setBackgroundColor:[UIColor colorWithRed:19.0f/255.0f green:26.0f/255.0f blue:32.0f/255.0f alpha:1]];
  [self.tableView setBackgroundColor:[UIColor colorWithRed:19.0f/255.0f green:26.0f/255.0f blue:32.0f/255.0f alpha:1]];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.showsVerticalScrollIndicator = NO;
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.rowHeight = 50.5f;
}

#pragma mark - other function
- (AppDelegate *)getApp {
  return [[UIApplication sharedApplication] delegate];
}

//设置StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self getApp].themes.count + 1 + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    HomeSideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeSideCell"];
    return cell;
  } else if (indexPath.row <= [self getApp].themes.count) {
    ContentSideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentSideCell"];
    cell.contentTitleLabel.text = [self getApp].themes[indexPath.row-1][@"name"];
    return cell;
  }
  //最后一行cell无法点击,由于上方加了渐变图片
  ContentSideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentSideCell"];
  cell.contentTitleLabel.text = @"更多日报内容";
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSInteger row = self.tableView.indexPathForSelectedRow.row;
  if (row != 0) {
    UINavigationController *nav = segue.destinationViewController;
    ThemeViewController *themeViewController = (ThemeViewController *)nav.topViewController;
    themeViewController.name = [self getApp].themes[row-1][@"name"];
    themeViewController.tid = [self getApp].themes[row-1][@"id"];
  }

}
@end
