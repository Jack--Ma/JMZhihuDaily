//
//  MainTableViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/4.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "MainTableViewController.h"
#import "TableContentViewCell.h"
#import "TableSeparatorViewCell.h"
#import "WebViewController.h"

@interface MainTableViewController () <SDCycleScrollViewDelegate, ParallaxHeaderViewDelegate>

@end

@implementation MainTableViewController {
  int _number[256];//每一行的cell是否被点击
  
  ZFModalTransitionAnimator *_animator;
  SDCycleScrollView *_cycleScrollView;
}

#pragma mark - 初始化相关函数
- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  //SWRevealViewController提供了一个叫 revealViewController()的方法来从任何子控制器中拿到父控制器 SWRevealViewController；它还提供了一个叫 revealToggle: 的方法来显示或隐藏菜单栏，最后我们添加了一个手势。
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
  _cycleScrollView.titleLabelTextFont = [UIFont fontWithName:@"STHeitSC-Medium" size:34];
  _cycleScrollView.titleLabelBackgroundColor = [UIColor clearColor];
  _cycleScrollView.titleLabelHeight = 60;
  
  //alpha在未设置的状态下默认为0
  _cycleScrollView.titleLabelAlpha = 1;
  
  //将其添加到ParallaxView
  ParallaxHeaderView *headerSubview = [ParallaxHeaderView parallaxHeaderViewWithSubView:_cycleScrollView forSize:CGSizeMake(self.tableView.frame.size.width, 154)];
  headerSubview.delegate = self;
  
  //将ParallaxView设置为tableHeaderView
  [self.tableView setTableHeaderView:headerSubview];
  
  //是第一次加载
  if ([StoryModel shareStory].firstDisplay) {
    //生成第二启动页背景
    UIView *launchView = [[UIView alloc] initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height)];
    launchView.alpha = 0.99;
    
    //第二启动页的控制器
    UIViewController *launchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"launchViewController"];
    [self addChildViewController:launchViewController];
    [launchView addSubview:launchViewController.view];
    
    //加入进主View视图
    [self.view addSubview:launchView];
    
    //加载第二页的动画
    [UIView animateWithDuration:2.5 animations:^{
      launchView.alpha = 1;
    } completion:^(BOOL finished) {
      [self.navigationItem setTitle:@"今日热点"];
      [self.navigationItem setLeftBarButtonItem:leftButton animated:NO];
      [launchView removeFromSuperview];
    }];
    [StoryModel shareStory].firstDisplay = NO;
  } else {
    [self updateData];
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

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger num = [StoryModel shareStory].contentStory.count + 60;
  for (int i = 0; i < num; i++) {
    _number[i] = 0;
  }
  return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger pastIndex = indexPath.row - [StoryModel shareStory].contentStory.count;
  if (pastIndex == 0 || pastIndex == 20 || pastIndex == 40) {
    return 44.0f;
  }
  return 93.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  //今日内容的设置
  if (indexPath.row < [StoryModel shareStory].contentStory.count) {
    TableContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableContentViewCell"];
    NSDictionary *data = [StoryModel shareStory].contentStory[indexPath.row];
    if (_number[indexPath.row]) {
      cell.titleLabel.textColor = [UIColor lightGrayColor];
    } else {
      cell.titleLabel.textColor = [UIColor blackColor];
    }
    
    [cell.imagesView sd_setImageWithURL:data[@"images"][0]];
    cell.titleLabel.text = data[@"title"];
    
    return cell;
  }
  //分隔cell内容的设置
  NSInteger pastIndex = indexPath.row - [StoryModel shareStory].contentStory.count;
  if (pastIndex == 0 || pastIndex == 20 || pastIndex == 40) {
    TableSeparatorViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableSeparatorViewCell"];
    NSArray *data = [StoryModel shareStory].offsetYValue;
    cell.dateLabel.text = data[pastIndex / 20 + 1];
    return cell;
  }
  //过去三天内容的设置
  TableContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableContentViewCell"];
  NSDictionary *data = [StoryModel shareStory].pastContentStory[pastIndex - pastIndex/20 - 1];

  if (_number[indexPath.row]) {
    cell.titleLabel.textColor = [UIColor lightGrayColor];
  } else {
    cell.titleLabel.textColor = [UIColor blackColor];
  }
  [cell.imagesView sd_setImageWithURL:data[@"images"][0]];
  cell.titleLabel.text = data[@"title"];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  if ([cell isKindOfClass:[TableSeparatorViewCell class]]) {
    return;
  }
  //记录已被选中的indexPath并改变其textColor
  TableContentViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  _number[indexPath.row] = 1;
  selectedCell.titleLabel.textColor = [UIColor lightGrayColor];
  
  //新建webView
  WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
  webViewController.index = indexPath.row;
  
  //找到对应newsID
  if (indexPath.row < [StoryModel shareStory].contentStory.count) {
    //当天情况
    NSDictionary *story = [StoryModel shareStory].contentStory[indexPath.row];
    NSString *sid = [story objectForKey:@"id"];
    webViewController.newsId = [sid integerValue];
  } else {
    //过去几天情况，这里有问题，没有考虑前几天每天内容数量不同
    NSInteger i = (indexPath.row-[StoryModel shareStory].contentStory.count) / 20;
    NSInteger index = (indexPath.row-[StoryModel shareStory].contentStory.count) % 20 - 1 + i * 20 - i;
    NSDictionary *story = [StoryModel shareStory].pastContentStory[index];
    NSString *sid = [story objectForKey:@"id"];
    webViewController.newsId = [sid integerValue];
  }
  
  //对animator进行初始化
  _animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:webViewController];
  _animator.dragable = YES;
  _animator.bounces = NO;
  _animator.behindViewAlpha = 0.7;
  _animator.behindViewScale = 0.7;
  _animator.transitionDuration = 0.7;
  _animator.direction = ZFModalTransitonDirectionRight;
  
  //设置webViewController
  webViewController.transitioningDelegate = _animator;
  
   //跳转界面
  [self presentViewController:webViewController animated:YES completion:nil];
}
#pragma mark - SDCycleScrollViewDelegate & ParallaxHeaderViewDelegate
//collectionView点击事件
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
  //初始化webView
  WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
  webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  
  //初始化animator
  _animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:webViewController];
  _animator.dragable = YES;
  _animator.bounces = NO;
  _animator.behindViewAlpha = 0.7;
  _animator.behindViewScale = 0.7;
  _animator.transitionDuration = 0.7;
  _animator.direction = ZFModalTransitonDirectionRight;
  
  //设置webView
  webViewController.transitioningDelegate = _animator;
  webViewController.newsId = [[StoryModel shareStory].topStory[index][@"id"] integerValue];
  webViewController.isTopStory = YES;
  
  [self presentViewController:webViewController animated:YES completion:nil];
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
  for (int i = 1; i < [StoryModel shareStory].offsetYNumber.count; i++) {
    if (offsetY < [[StoryModel shareStory].offsetYNumber[0] intValue]) {
      [self.navigationItem setTitle:[StoryModel shareStory].offsetYValue[0]];
      return;
    }
    if (offsetY > [[StoryModel shareStory].offsetYNumber[3-i] intValue]) {
      [self.navigationItem setTitle:[StoryModel shareStory].offsetYValue[4-i]];
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
    [temp1 addObject:[StoryModel shareStory].topStory[i][@"image"]];
    [temp2 addObject:[StoryModel shareStory].topStory[i][@"title"]];
  }
  [_cycleScrollView setImageURLStringsGroup:temp1];
  [_cycleScrollView setTitlesGroup:temp2];

  [self.tableView reloadData];
}

#pragma mark - 一些全局设置函数
//拓展NavigationController以设置StatusBar
- (UIViewController *)childViewControllerForStatusBarStyle {
  return self.navigationController.topViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

@end
