//
//  ThemeViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/5.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "ThemeViewController.h"
#import "AppDelegate.h"
#import "ThemeEditorTableViewCell.h"
#import "ThemeTextWithImageTableViewCell.h"
#import "ThemeTextTableViewCell.h"

@interface ThemeViewController () <UITableViewDelegate, UITableViewDataSource, ParallaxHeaderViewDelegate>

@end

@implementation ThemeViewController {
  UIImageView *_navImageView;
  ParallaxHeaderView *_themeSubview;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

  //添加左返回按钮和手势
  UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftArrow"] style:(UIBarButtonItemStylePlain) target:self.revealViewController action:@selector(revealToggle:)];
  leftButton.tintColor = [UIColor whiteColor];
  [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
  [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
  //设置nav的背景图片_navImageView
  _navImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
  _navImageView.image = [UIImage imageNamed:@"ThemeImage"];
  _navImageView.contentMode = UIViewContentModeScaleAspectFill;
  _navImageView.clipsToBounds = YES;
  //将其添加到ParallaxView
  _themeSubview = [ParallaxHeaderView parallaxThemeHeaderViewWithSubView:_navImageView forSize:CGSizeMake(self.view.frame.size.width, 64) andImage:_navImageView.image];
  _themeSubview.delegate = self;
  //将ParallaxView设置为tableHeaderView，主View添加tableView
  self.tableView.tableHeaderView = _themeSubview;
  [self.view addSubview:self.tableView];
  //设置背景透明
  [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
  self.navigationController.navigationBar.shadowImage = [UIImage new];
  
  //tableView基础设置
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
  self.tableView.showsVerticalScrollIndicator = NO;
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self getApp].themeContent.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    return 45.0f;
  }
  return 93.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ThemeEditorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"themeEditorTableViewCell"];
  cell.contentView.backgroundColor = [UIColor lightGrayColor];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
}

#pragma mark - ParallaxHeaderViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  ParallaxHeaderView *header = (ParallaxHeaderView *)self.tableView.tableHeaderView;
  [header layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
}

- (void)lockDirection {
  [self.tableView setContentOffset:CGPointMake(0.0f, -95.0f)];
}
#pragma mark - 一些全局设置函数
//获取总代理
- (AppDelegate *)getApp {
  return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

//拓展NavigationController以设置StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}
@end
