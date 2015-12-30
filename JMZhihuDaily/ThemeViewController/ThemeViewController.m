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
#import "EditorsTableViewController.h"

@interface ThemeViewController () <UITableViewDelegate, UITableViewDataSource, ParallaxHeaderViewDelegate>

@end

@implementation ThemeViewController {
  UIImageView *_navImageView;
  ParallaxHeaderView *_themeSubview;
  UIView *_nightModeView;
  CGFloat _navBarAlpha;
  
  DACircularProgressView *_refreshImageView;
  UIImageView *_loadingImageView;
  
  BOOL _isDragging;
  BOOL _isLoading;
  
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
  [self.navigationController setNavigationBarHidden:NO animated:animated];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
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
  UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"up_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(backToTop)];
  rightButton.tintColor = [UIColor whiteColor];
  [self.navigationItem setRightBarButtonItem:rightButton animated:YES];
  [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

  //配置下拉刷新的View
  _refreshImageView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(self.view.width/2-10, 60, 20, 20)];
  _refreshImageView.roundedCorners = 10;
  _refreshImageView.trackTintColor = [UIColor clearColor];
  _refreshImageView.progressTintColor = [UIColor whiteColor];
  
  //设置下拉后刷新的旋转动画
  UIImage *loadingImage = [UIImage imageNamed:@"Loading"];
  loadingImage = [loadingImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  _loadingImageView = [[UIImageView alloc] initWithImage:loadingImage];
  _loadingImageView.frame = _refreshImageView.frame;
  _loadingImageView.tintColor = [UIColor whiteColor];
  _loadingImageView.hidden = YES;
  _loadingImageView.layer.allowsEdgeAntialiasing = YES;
  _isDragging = NO;
  _isLoading = NO;
  
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
  [_navImageView addSubview:_refreshImageView];
  [_navImageView addSubview:_loadingImageView];
  
  //设置背景透明
  [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
  self.navigationController.navigationBar.shadowImage = [UIImage new];
  
  //tableView基础设置
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
  self.tableView.showsVerticalScrollIndicator = NO;
  
  self.thisTableView = self.tableView;

  //设置底部的上拉加载新内容
  __weak typeof(SCPullRefreshViewController) *weakSelf = self;
  self.loadMoreBlock = ^{
    __strong typeof(SCPullRefreshViewController) *strongSelf = weakSelf;
    [strongSelf performSelector:@selector(endLoadMore) withObject:strongSelf afterDelay:2.0];
  };
  
  //设置主题变更观察
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchTheme) name:@"switchTheme" object:nil];
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
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (indexPath.row == 0) {
    ThemeEditorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"themeEditorTableViewCell"];
    [cell awakeFromNib];
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
    [cell awakeFromNib];
    if (temp) {
      if (_selectedIndex[indexPath.row-1]) {
        cell.themeTitleLabel.textColor = [UIColor lightGrayColor];
      } else {
        cell.themeTitleLabel.textColor = [UIColor blackColor];
      }
    } else {
      if (_selectedIndex[indexPath.row-1]) {
        cell.themeTitleLabel.textColor = [UIColor darkGrayColor];
      } else {
        cell.themeTitleLabel.textColor = [UIColor lightGrayColor];
      }
    }
    cell.themeTitleLabel.text = tempThemeStory[@"title"];
    [cell.themeImageView sd_setImageWithURL:[NSURL URLWithString:tempThemeStory[@"images"][0]]];
    return cell;
  } else {
    //不存在图片情况
    ThemeTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"themeTextTableViewCell"];
    [cell awakeFromNib];
    if (temp) {
      if (_selectedIndex[indexPath.row-1]) {
        cell.themeTitleLabel.textColor = [UIColor lightGrayColor];
      } else {
        cell.themeTitleLabel.textColor = [UIColor blackColor];
      }
    } else {
      if (_selectedIndex[indexPath.row-1]) {
        cell.themeTitleLabel.textColor = [UIColor darkGrayColor];
      } else {
        cell.themeTitleLabel.textColor = [UIColor lightGrayColor];
      }
    }
    cell.themeTitleLabel.text = tempThemeStory[@"title"];
    return cell;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  
  if (indexPath.row == 0) {
    EditorsTableViewController *editorsTableViewController = [EditorsTableViewController new];
    editorsTableViewController.editors = _editors;
    [self.navigationController pushViewController:editorsTableViewController animated:YES];
  } else {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ThemeTextTableViewCell class]]) {
      ThemeTextTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
      if (temp) {
        cell.themeTitleLabel.textColor = [UIColor lightGrayColor];
      } else {
        cell.themeTitleLabel.textColor = [UIColor darkGrayColor];
      }
    } else {
      ThemeTextWithImageTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
      if (temp) {
        cell.themeTitleLabel.textColor = [UIColor lightGrayColor];
      } else {
        cell.themeTitleLabel.textColor = [UIColor darkGrayColor];
      }
    }
    //跳转到WebView
    WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
    webViewController.index = indexPath.row - 1;
    webViewController.isThemeStory = YES;
    webViewController.newsId = [[StoryModel shareStory].themeContent[indexPath.row-1][@"id"] integerValue];
    
    [self.navigationController pushViewController:webViewController animated:YES];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ParallaxHeaderViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  //先执行父类的scrollViewDidScroll方法
  [super scrollViewDidScroll:scrollView];
  //Parallax效果
  ParallaxHeaderView *header = (ParallaxHeaderView *)self.tableView.tableHeaderView;
  [header layoutThemeHeaderViewForScrollViewOffset:scrollView.contentOffset];
  UIColor *color;
  if (temp) {
    color = [UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
  } else {
    color = [UIColor colorWithRed:68.0/255.0 green:67.0/255.0 blue:71.0/255.0 alpha:1];
  }
  CGFloat offsetY = scrollView.contentOffset.y;
  
  //若isLoading为YES则加载Loading动画
  if (_isLoading) {
    _isLoading = NO;
    _loadingImageView.hidden = NO;
    _refreshImageView.hidden = YES;
    [_loadingImageView.layer addAnimation:[self createRotationAnimation] forKey:@"LoadingAnimation"];
  }
  //下拉到刷新点，并且已经手已经放开，则设置_isLoading
  if (offsetY  >= -125.0 && offsetY <= -110.0 && !_isDragging) {
    _isLoading = YES;
  }
  //下拉时显示刷新View动画
  if (offsetY <= -64.0) {
    CGFloat i = -(offsetY+64.0) / (125.0-64.0);
    _refreshImageView.hidden = NO;
    [_refreshImageView setProgress:i animated:YES];
  }
  
  if (offsetY >= -64) {
    _refreshImageView.hidden = YES;
    CGFloat alpha = MIN(1, (64 + offsetY) / (64));
    _navBarAlpha = alpha;
    //NavigationBar透明度渐变
    [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:alpha]];
  } else {
    [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:0]];
  }
}

//记录下拉时状态
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
  _isDragging = NO;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
  _isDragging = YES;
}

//滑动极限
- (void)lockDirection {
  [self.tableView setContentOffset:CGPointMake(0.0f, -125.0f)];
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

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (flag) {
    _refreshImageView.hidden = NO;
    _loadingImageView.hidden = YES;
    [_loadingImageView.layer removeAllAnimations];
    [self.tableView reloadData];
  }
}
#pragma mark - 私有函数
- (void)switchTheme {
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  
  //设置图片遮蔽罩
  [_nightModeView removeFromSuperview];
  _nightModeView = [[UIView alloc] initWithFrame:_navImageView.frame];
  _nightModeView.backgroundColor = [UIColor blackColor];
  _nightModeView.alpha = 0.2;
  _nightModeView.userInteractionEnabled = NO;
  if (temp) {
    [_nightModeView removeFromSuperview];
  } else {
    [_navImageView addSubview:_nightModeView];
  }
  //设置navBar背景颜色
  UIColor *color;
  if (temp) {
    color = [UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
  } else {
    color = [UIColor colorWithRed:68.0/255.0 green:67.0/255.0 blue:71.0/255.0 alpha:1];
  }
  [self.navigationController.navigationBar lt_setBackgroundColor:[color colorWithAlphaComponent:_navBarAlpha]];
  
  [self.tableView reloadData];
}

- (void)backToTop {
  [self.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
}

//拓展NavigationController以设置StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}
@end
