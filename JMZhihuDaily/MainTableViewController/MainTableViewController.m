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
  UIView *_nightModeView;//放置在_cycleScrollView上的夜间模式遮蔽罩
  CGFloat _navBarAlpha;//记录navBar背景颜色alpha值
  
  DACircularProgressView *_refreshImageView;
  UIImageView *_loadingImageView;
  
  BOOL _isDragging;//手指是否从屏幕上拿走
  BOOL _isLoading;//是否加载loadingImageView;
}

#pragma mark - 初始化相关函数
- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  //SWRevealViewController提供了一个叫 revealViewController()的方法来从任何子控制器中拿到父控制器 SWRevealViewController；它还提供了一个叫 revealToggle: 的方法来显示或隐藏菜单栏，最后我们添加了一个手势。
  UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self.revealViewController action:@selector(revealToggle:)];
  leftButton.tintColor = [UIColor whiteColor];
  UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"up_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(backToTop)];
  rightButton.tintColor = [UIColor whiteColor];
  
  [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
  
  //配置下拉刷新的View
  _refreshImageView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(self.view.width/2-10, 60, 20, 20)];
  _refreshImageView.roundedCorners = 10;
  _refreshImageView.trackTintColor = [UIColor clearColor];
  _refreshImageView.progressTintColor = [UIColor whiteColor];
  
  //配置下拉后刷新的旋转动画
  UIImage *loadingImage = [UIImage imageNamed:@"Loading"];
  loadingImage = [loadingImage imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
  _loadingImageView = [[UIImageView alloc] initWithImage:loadingImage];
  _loadingImageView.frame = _refreshImageView.frame;
  _loadingImageView.tintColor = [UIColor whiteColor];
  _loadingImageView.hidden = YES;
  _loadingImageView.layer.allowsEdgeAntialiasing = YES;//旋转是美化边缘，防止出现锯齿
  _isDragging = NO;
  _isLoading = NO;
  
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
  [_cycleScrollView addSubview:_refreshImageView];
  [_cycleScrollView addSubview:_loadingImageView];
  
  //是第一次加载先加载启动动画
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
      [self.navigationItem setRightBarButtonItem:rightButton animated:NO];
      [launchView removeFromSuperview];
    }];
    [StoryModel shareStory].firstDisplay = NO;
  } else {
    [self updateData];
    [self.navigationItem setLeftBarButtonItem:leftButton animated:NO];
    [self.navigationItem setRightBarButtonItem:rightButton animated:NO];
  }
  
  //透明的NavigationBar
  [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
  self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
  
  //tableView基础设置
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.showsVerticalScrollIndicator = NO;//取消竖直上右侧的滚动条
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  //设置最下端的上拉动画
  __weak typeof(JMPullRefreshTableViewController) *weakSelf = self;
  self.loadMoreBlock = ^{
    __strong typeof(JMPullRefreshTableViewController) *strongSelf = weakSelf;
    [strongSelf performSelector:@selector(endLoadMore) withObject:strongSelf afterDelay:2.0];
  };
  
  [self switchTheme];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:@"todayDataGet" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"pastDataGet" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchTheme) name:@"switchTheme" object:nil];
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger num = [StoryModel shareStory].contentStory.count + [StoryModel shareStory].pastContentStory.count + [StoryModel shareStory].pastStoryNumber.count;
  for (int i = 0; i < num; i++) {
    _number[i] = 0;
  }
  return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger pastIndex = indexPath.row - [StoryModel shareStory].contentStory.count;
  if (pastIndex == 0) {
    return 44.0f;
  }
  for (int i = 0; i < [StoryModel shareStory].pastStoryNumber.count-1; i++) {
    pastIndex = pastIndex - [[StoryModel shareStory].pastStoryNumber[i] integerValue];
    if (pastIndex == i+1) {
      return 44.0f;
    }
  }
  return 93.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  //今日内容的设置
  if (indexPath.row < [StoryModel shareStory].contentStory.count) {
    TableContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableContentViewCell"];
    NSDictionary *data = [StoryModel shareStory].contentStory[indexPath.row];
    [cell awakeFromNib];
    if (temp) {
      //白天
      if (_number[indexPath.row]) {
        cell.titleLabel.textColor = [UIColor lightGrayColor];
      } else {
        cell.titleLabel.textColor = [UIColor blackColor];
      }
    } else {
      //夜间
      if (_number[indexPath.row]) {
        cell.titleLabel.textColor = [UIColor darkGrayColor];
      } else {
        cell.titleLabel.textColor = [UIColor lightGrayColor];
      }
    }
    [cell.imagesView sd_setImageWithURL:data[@"images"][0]];
    cell.titleLabel.text = data[@"title"];
    
    return cell;
  }
  //分隔cell内容的设置
  NSInteger pastIndex = indexPath.row - [StoryModel shareStory].contentStory.count;
  NSArray *data = [StoryModel shareStory].offsetYValue;
  if (pastIndex == 0) {
    TableSeparatorViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableSeparatorViewCell"];
    cell.dateLabel.text = data[1];
    [cell awakeFromNib];
    return cell;
  }
  for (int i = 0; i < [StoryModel shareStory].pastStoryNumber.count-1; i++) {
    pastIndex = pastIndex - [[StoryModel shareStory].pastStoryNumber[i] integerValue];
    if (pastIndex == i+1) {
      TableSeparatorViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableSeparatorViewCell"];
      cell.dateLabel.text = data[i+2];
      [cell awakeFromNib];
      return cell;
    }
  }
  //过去三天内容的设置
//  pastIndex = indexPath.row - [StoryModel shareStory].contentStory.count;
  TableContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableContentViewCell"];
  [cell awakeFromNib];
  NSDictionary *Dic = [StoryModel shareStory].pastContentStory[[self findPastStoryIndex:indexPath.row]];
  if (temp) {
    //白天
    if (_number[indexPath.row]) {
      cell.titleLabel.textColor = [UIColor lightGrayColor];
    } else {
      cell.titleLabel.textColor = [UIColor blackColor];
    }
  } else {
    //夜间
    if (_number[indexPath.row]) {
      cell.titleLabel.textColor = [UIColor darkGrayColor];
    } else {
      cell.titleLabel.textColor = [UIColor lightGrayColor];
    }
  }

  [cell.imagesView sd_setImageWithURL:Dic[@"images"][0]];
  cell.titleLabel.text = Dic[@"title"];

  return cell;
}
//从当前的index.row找到对用pastStory的序号
- (NSInteger)findPastStoryIndex:(NSInteger)row {
  NSInteger pastIndex = row - [StoryModel shareStory].contentStory.count;
  int j = 1;
  for (int i = 1; i < [StoryModel shareStory].pastStoryNumber.count; i++) {
    pastIndex = pastIndex - [[StoryModel shareStory].pastStoryNumber[i-1] integerValue] - i + 1;
    if (pastIndex > 0) { j++; }
  }
  return row - [StoryModel shareStory].contentStory.count - j;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  if ([cell isKindOfClass:[TableSeparatorViewCell class]]) {
    return;
  }
  //记录已被选中的indexPath并改变其textColor
  TableContentViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  _number[indexPath.row] = 1;
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (temp) {
    selectedCell.titleLabel.textColor = [UIColor lightGrayColor];
  } else {
    selectedCell.titleLabel.textColor = [UIColor darkGrayColor];
  }
  
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
    //过去几天情况
    NSInteger index = [self findPastStoryIndex:indexPath.row];
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
  [super scrollViewDidScroll:scrollView];
  //Parallax效果
  ParallaxHeaderView *header = (ParallaxHeaderView *)self.tableView.tableHeaderView;
  [header layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  UIColor *color;
  if (temp) {
    color = [UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
  } else {
    color = [UIColor colorWithRed:68.0/255.0 green:67.0/255.0 blue:71.0/255.0 alpha:1];
  }
  CGFloat offsetY = scrollView.contentOffset.y;
  CGFloat prelude = 90;
  
  //若isLoading为YES则加载Loading动画
  if (_isLoading) {
    _isLoading = NO;
    _loadingImageView.hidden = NO;
    _refreshImageView.hidden = YES;
    [_loadingImageView.layer addAnimation:[self createRotationAnimation] forKey:@"LoadingAnimation"];
  }
  //下拉到刷新点，并且已经手已经放开，则设置_isLoading
  if (offsetY >= -125.0 && offsetY <= -110.0 && !_isDragging) {
    _isLoading = YES;
  }
  //下拉时显示刷新图标，这里的offsetY从-64.0开始
  if (offsetY <= -64.0) {
    CGFloat i = -(scrollView.contentOffsetY+64.0) / (125.0 - 64.0);
    _refreshImageView.hidden = NO;
    [_refreshImageView setProgress:i animated:YES];
  }
  
  //NavBar及titleLabel透明度渐变
  if (offsetY >= -64) {
    _refreshImageView.hidden = YES;
    CGFloat alpha = MIN(1, (64 + offsetY) / (64 + prelude));
    _navBarAlpha = alpha;
    //titleLabel透明度渐变
    ((SDCycleScrollView *)header.subviews[0].subviews[0]).titleLabelAlpha = 1 - alpha;
    [((UICollectionView *)header.subviews[0].subviews[0].subviews[0]) reloadData];
    //NavigationBar透明度渐变
    [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
  } else {
    [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
  }
  //依据contentOffsetY设置titleView的标题
  NSInteger j = [StoryModel shareStory].pastStoryNumber.count;
  for (int i = 1; i < [StoryModel shareStory].offsetYNumber.count; i++) {
    if (offsetY < [[StoryModel shareStory].offsetYNumber[0] intValue]) {
      [self.navigationItem setTitle:[StoryModel shareStory].offsetYValue[0]];
      return;
    }
    if (offsetY > [[StoryModel shareStory].offsetYNumber[j-i] intValue]) {
      [self.navigationItem setTitle:[StoryModel shareStory].offsetYValue[j+1-i]];
      return;
    }
  }
  
}

//记录下拉时状态
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
  _isDragging = NO;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
  _isDragging = YES;
}

//根据scrollView修改tableView偏移量
- (void)lockDirection {
  [self.tableView setContentOffset:CGPointMake(0, -125)];
}

#pragma mark - 其他函数
- (void)switchTheme {
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  
  //设置图片遮蔽罩
  [_nightModeView removeFromSuperview];
  _nightModeView = [[UIView alloc] initWithFrame:_cycleScrollView.frame];
  _nightModeView.backgroundColor = [UIColor blackColor];
  _nightModeView.alpha = 0.2;
  _nightModeView.userInteractionEnabled = NO;
  if (!temp) {
    [_cycleScrollView addSubview:_nightModeView];
  }
  
  //设置navBar背景颜色
  UIColor *color;
  if (temp) {
    self.tableView.backgroundColor = [UIColor whiteColor];
    color = [UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
  } else {
    self.tableView.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    color = [UIColor colorWithRed:68.0/255.0 green:67.0/255.0 blue:71.0/255.0 alpha:1];
  }
  [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:_navBarAlpha]];
  
  [self.tableView reloadData];
}

- (void)updateData {
  NSMutableArray *temp1 = [NSMutableArray arrayWithCapacity:5];
  NSMutableArray *temp2 = [NSMutableArray arrayWithCapacity:5];
  
  for (int i = 0; i < 5; i++) {
    [temp1 addObject:[StoryModel shareStory].topStory[i][@"image"]];
    [temp2 addObject:[StoryModel shareStory].topStory[i][@"title"]];
  }
  [_cycleScrollView setImageURLStringsGroup:temp1];
  [_cycleScrollView setTitlesGroup:temp2];
}

- (void)backToTop {
  //-64为Table的Head修正量
  [self.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
}

- (CAAnimation *)createRotationAnimation {
  
  CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  [rotationAnimation setValue:@"LoadingAnimation" forKey:@"id"];
  rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
  rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
  rotationAnimation.duration = 0.8f;
  rotationAnimation.repeatCount = 3;
  rotationAnimation.speed = 1.0f;
  rotationAnimation.removedOnCompletion = YES;
  rotationAnimation.delegate = self;
  
  return rotationAnimation;
}

- (void)animationDidStart:(CAAnimation *)anim {
  [[StoryModel shareStory] refreshData];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (flag) {
    _refreshImageView.hidden = NO;
    _loadingImageView.hidden = YES;
    [_loadingImageView.layer removeAllAnimations];
    [self updateData];
    [self.tableView reloadData];
  }
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
