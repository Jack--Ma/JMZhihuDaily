//
//  MainTableViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/4.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "MainTableViewController.h"
#import "AppDelegate.h"
#import "TableContentViewCell.h"
#import "TableSeparatorViewCell.h"

@interface MainTableViewController () <SDCycleScrollViewDelegate, ParallaxHeaderViewDelegate>

@end

@implementation MainTableViewController {
  NSMutableArray *_selectedIndex;
  
  ZFModalTransitionAnimator *_animator;
  SDCycleScrollView *_cycleScrollView;
}

#pragma mark - 初始化相关函数
- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  //设置左barButton和手势
  UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:(UIBarButtonItemStylePlain) target:self.revealViewController action:@selector(revealToggle:)];
  leftButton.tintColor = [UIColor whiteColor];
  [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
  
  //配置无限循环的scrollView
  _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 154) imagesGroup:nil];

  _cycleScrollView.infiniteLoop = YES;
  _cycleScrollView.delegate = self;
  _cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
  _cycleScrollView.autoScrollTimeInterval = 6.0;
  _cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
  _cycleScrollView.titleLabelTextFont = [UIFont fontWithName:@"STHeitSC-Medium" size:21];
  _cycleScrollView.titleLabelBackgroundColor = [UIColor clearColor];
  _cycleScrollView.titleLabelHeight = 60;
  
  //alpha在未设置的状态下默认为0
  _cycleScrollView.titleLabelAlpha = 1;
  
  //将其添加到ParallaxView
  ParallaxHeaderView *headerSubview = [ParallaxHeaderView parallaxHeaderViewWithSubView:_cycleScrollView forSize:CGSizeMake(self.tableView.frame.size.width, 154)];
  headerSubview.delegate = self;
  
  //将ParallaxView设置为tableHeaderView
  [self.tableView setTableHeaderView:headerSubview];
  
  //不是第一次加载
  if (![self getApp].firstDisplay) {
    [self.navigationItem setLeftBarButtonItem:leftButton animated:NO];
    [self updateData];
  } else {
    [self.navigationItem setLeftBarButtonItem:leftButton animated:NO];
  }
  
  //透明的NavigationBar
  [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
  self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
  
  //tableView基础设置
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.showsVerticalScrollIndicator = NO;//取消竖直上右侧的滚动条
  self.tableView.rowHeight = UITableViewAutomaticDimension;//ios8后加入的动态调整cell高度
  self.tableView.estimatedRowHeight = 50;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:@"todayDataGet" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"pastDataGet" object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self getApp].contentStory.count + [self getApp].contentStory.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  //今日内容的设置
  if (indexPath.row < [self getApp].contentStory.count) {
    TableContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableContentViewCell"];
    NSDictionary *data = [self getApp].contentStory[indexPath.row];
    
    if (_selectedIndex[indexPath.row]) {
      cell.titleLabel.textColor = [UIColor lightGrayColor];
    } else {
      cell.titleLabel.textColor = [UIColor blackColor];
    }
    
    [cell.imagesView sd_setImageWithURL:data[@"images"][0]];
    cell.titleLabel.text = data[@"title"];
    
    return cell;
  }
  //分隔cell内容的设置
  if (indexPath.row == [self getApp].contentStory.count) {
    TableSeparatorViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableSeparatorViewCell"];
    NSArray *data = [self getApp].offsetYValue;
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:1.0f/255.0f green:131.0f/255.0f blue:209.0f/255.0f alpha:1.0f];
//    NSLog(@"%@", data);
    cell.dateLabel.text = data[1];
    return cell;
  }
  //过去三天内容的设置
  NSInteger pastIndex = indexPath.row - [self getApp].contentStory.count;
  TableContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableContentViewCell"];
  NSDictionary *data = [self getApp].pastContentStory[pastIndex];
  
  if (_selectedIndex[indexPath.row]) {
    cell.titleLabel.textColor = [UIColor lightGrayColor];
  } else {
    cell.titleLabel.textColor = [UIColor blackColor];
  }
  [cell.imagesView sd_setImageWithURL:data[@"images"][0]];
  cell.titleLabel.text = data[@"title"];
  
  return cell;
}

#pragma mark - SDCycleScrollViewDelegate & ParallaxHeaderViewDelegate
//collectionView点击事件
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
  
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  //Parallax效果
  ParallaxHeaderView *header = (ParallaxHeaderView *)self.tableView.tableHeaderView;
  [header layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
  //NavBar及titleLabel透明度渐变
  UIColor *color = [UIColor colorWithRed:1.0f/255.0f green:131.0f/255.0f blue:209.0f/255.0f alpha:1.0f];
  CGFloat offsetY = scrollView.contentOffset.y;
  CGFloat prelude = 90;
  
  if (offsetY >= -64) {
    CGFloat alpha = MIN(1, (64 + offsetY) / (64 + prelude));
    //titleLabel透明度渐变
    ((SDCycleScrollView *)header.subviews[0].subviews[0]).titleLabelAlpha = 1 - alpha;
    [((UICollectionView *)header.subviews[0].subviews[0].subviews[0]) reloadData];
    //NavigationBar透明度渐变
    [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
  } else {
    [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
  }
  //依据contentOffsetY设置titleView的标题
  for (int i = 0; i < [self getApp].offsetYNumber.count; i++) {
    if (offsetY > [[self getApp].offsetYNumber[i] intValue]) {
      self.titleLabel.text = [self getApp].offsetYValue[1];
      return;
    }
  }
  
}
//根据scrollView修改tableView偏移量
- (void)lockDirection {
  [self.tableView setContentOffset:CGPointMake(0, -154)];
}
#pragma mark - 获取数据
- (void)updateData {
  NSMutableArray *temp1 = [NSMutableArray arrayWithCapacity:5];
  NSMutableArray *temp2 = [NSMutableArray arrayWithCapacity:5];
  for (int i = 0; i < 5; i++) {
    [temp1 addObject:[self getApp].topStory[i][@"image"]];
    [temp2 addObject:[self getApp].topStory[i][@"title"]];
  }
  [_cycleScrollView setImageURLStringsGroup:temp1];
  [_cycleScrollView setTitlesGroup:temp2];

  [self.tableView reloadData];
}

#pragma mark - 一些全局设置函数
//获取总代理
- (AppDelegate *)getApp {
  return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

//拓展NavigationController以设置StatusBar
- (UIViewController *)childViewControllerForStatusBarStyle {
  return self.navigationController.topViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

//- (UIViewController *)childViewControllerForStatusBarHidden {
//  return self.navigationController.topViewController;
//}
@end
