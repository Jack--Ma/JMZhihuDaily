//
//  ThemeViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/5.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "ThemeViewController.h"
#import "ThemeEditorTableViewCell.h"
#import "ThemeTextWithImageTableViewCell.h"
#import "ThemeTextTableViewCell.h"
#import "WebViewController.h"

@interface ThemeViewController () <UITableViewDelegate, UITableViewDataSource, ParallaxHeaderViewDelegate>

@end

@implementation ThemeViewController {
  UIImageView *_navImageView;
  ParallaxHeaderView *_themeSubview;
  
  NSMutableArray *_selectedIndex;
  NSArray *_editors;
}

- (void)refreshData {
  NSString *urlString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/4/theme/%@", self.tid];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSDictionary *data = responseObject;
    NSArray *storyData = data[@"stories"];
    _editors = [[NSArray alloc] initWithArray:data[@"editors"] copyItems:YES];
    
    [StoryModel shareStory].themeContent = [storyData copy];
    //更新背景图片
    [_navImageView sd_setImageWithURL:data[@"background"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
      _themeSubview.blurViewImage = image;
      [_themeSubview refreshBlurViewForNewImage];
    }];
    
    [self.tableView reloadData];
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"%@", [error userInfo]);
    return;
  }];
  [operation start];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  //清空原数据
  [StoryModel shareStory].themeContent = nil;
  
  //拿到新数据
  [self refreshData];
  
  //添加左返回按钮和手势
  [self.navigationItem setTitle: self.name];
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
  return [StoryModel shareStory].themeContent.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    return 45.0f;
  }
  return 93.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    ThemeEditorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"themeEditorTableViewCell"];
    for (int i = 0; i < _editors.count; i++) {
      //加入小编们的头像
      UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(62+37*i, 12.5, 20, 20)];
      avatar.contentMode = UIViewContentModeScaleAspectFill;
      avatar.layer.cornerRadius = 10;
      avatar.clipsToBounds = YES;//超出上一层View的地方剪掉
      [avatar sd_setImageWithURL:[NSURL URLWithString:_editors[i][@"avatar"]]];
      [cell.contentView addSubview:avatar];
    }
    return cell;
  }
  //当前对应的story
  NSDictionary *tempThemeStory = ([StoryModel shareStory].themeContent)[indexPath.row-1];
  if (tempThemeStory[@"images"][0]) {
    //存在图片情况
    ThemeTextWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"themeTextWithImageTableViewCell"];
    if (_selectedIndex[indexPath.row-1]) {
      cell.themeTitleLabel.textColor = [UIColor lightGrayColor];
    } else {
      cell.themeTitleLabel.textColor = [UIColor blackColor];
    }
    cell.themeTitleLabel.text = tempThemeStory[@"title"];
    [cell.themeImageView sd_setImageWithURL:[NSURL URLWithString:tempThemeStory[@"images"][0]]];
    return cell;
  } else {
    //不存在图片情况
    ThemeTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"themeTextTableViewCell"];
    if (_selectedIndex[indexPath.row-1]) {
      cell.themeTitleLabel.textColor = [UIColor lightGrayColor];
    } else {
      cell.themeTitleLabel.textColor = [UIColor blackColor];
    }
    cell.themeTitleLabel.text = tempThemeStory[@"title"];
    return cell;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    return;
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  if ([cell isKindOfClass:[ThemeTextTableViewCell class]]) {
    ThemeTextTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.themeTitleLabel.textColor = [UIColor lightGrayColor];
  } else {
    ThemeTextWithImageTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.themeTitleLabel.textColor = [UIColor lightGrayColor];
  }
  //跳转到WebView
  WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
  webViewController.index = indexPath.row - 1;
  webViewController.isThemeStory = YES;
  webViewController.newsId = [[StoryModel shareStory].themeContent[indexPath.row-1][@"id"] integerValue];
  
  [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - ParallaxHeaderViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  //Parallax效果
  ParallaxHeaderView *header = (ParallaxHeaderView *)self.tableView.tableHeaderView;
  [header layoutThemeHeaderViewForScrollViewOffset:scrollView.contentOffset];
  //NavBar透明度渐变
  UIColor *color = [UIColor colorWithRed:1.0f/255.0f green:131.0f/255.0f blue:209.0f/255.0f alpha:1.0f];
  CGFloat offsetY = scrollView.contentOffset.y;
  
  if (offsetY >= -64) {
    CGFloat alpha = MIN(1, (64 + offsetY) / (64));
    //NavigationBar透明度渐变
    [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
  } else {
    [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
  }
}

- (void)lockDirection {
  //滑动极限
  [self.tableView setContentOffset:CGPointMake(0.0f, -95.0f)];
}
#pragma mark - 一些全局设置函数
//拓展NavigationController以设置StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}
@end
