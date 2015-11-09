//
//  WebViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/8.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "WebViewController.h"
#import "AppDelegate.h"

@interface WebViewController () <UIScrollViewDelegate, UIWebViewDelegate, ParallaxHeaderViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIView *statusBarBackground;

@end

@implementation WebViewController {
  ParallaxHeaderView *_webHeaderView;
  UIImageView *_imageView;
  CGFloat _originalHeight;
  myUILabel *_titleLabel;
  UILabel *_sourceLabel;
  GradientView *_blurView;
  
  BOOL _hasImage;
  BOOL _arrowState;//检测箭头方向
  BOOL _triggered;//检测下滑时手指是否按住屏幕
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithRed:249.0f/255.0f green:249.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
  self.webView.backgroundColor = [UIColor colorWithRed:249.0f/255.0f green:249.0f/255.0f blue:249.0f/255.0f alpha:1];
  _hasImage = YES;
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  //避免因含有navBar而对scrollInsets做自动调整
  //避免ScrollView莫名其妙不能在viewController划到顶
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  //避免wenScrollView的contentView过长，挡住底层View
  self.view.clipsToBounds = YES;
  
  //隐藏默认返回button但保留左划返回
  self.navigationItem.hidesBackButton = YES;
  self.navigationController.interactivePopGestureRecognizer.enabled = YES;
  self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
  
  //对webView做基本配置
  self.webView.delegate = self;
  self.webView.scrollView.delegate = self;
  self.webView.scrollView.clipsToBounds = NO;
  self.webView.scrollView.showsVerticalScrollIndicator = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [self loadWebView:self.newsId];
}

#pragma mark - webView
- (void)loadWebView:(NSInteger)newsId {
  NSString *urlString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/4/news/%ld", (long)newsId];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSDictionary *data = responseObject;
    
    NSString *body = data[@"body"];
    NSString *css = data[@"css"][0];

    NSString *image = data[@"image"];
    NSString *imageSource = data[@"image_source"];
    NSString *titleString = data[@"title"];
    if (image && imageSource && titleString) {
      _hasImage = YES;
      [self loadParallaxHeader:image imageSource:imageSource titleString:titleString];
    } else {
      _hasImage = NO;
      self.statusBarBackground.backgroundColor = [UIColor whiteColor];
      [self loadNormalHeader];
    }
    NSString *html = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" href=%@></head><body>%@</body></html>", css, body];
    [self.webView loadHTMLString:html baseURL:nil];
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"%@", error);
  }];
  [operation start];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  //暂时的处理方法，只允许查看文章内容 而不允许点击其中链接跳转，待修改
  //修改后应为打开知乎客户端
  if (!webView.request) {
    return YES;
  }
  if (request != webView.request) {
    return NO;
  }
  return YES;
}

- (void)lockDirection {
  [self.webView.scrollView setContentOffset:CGPointMake(0, -155.0)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (_hasImage) {
    NSInteger incrementY = scrollView.contentOffset.y;
    if (incrementY < 0) {
      //下拉，不断设置titleLabel及sourceLabel以保证frame正确
      _titleLabel.frame = CGRectMake(15, _originalHeight-80-incrementY, self.view.frame.size.width-30, 60);
      _sourceLabel.frame = CGRectMake(15, _originalHeight-20-incrementY, self.view.frame.size.width-30, 15);
      //不断添加删除blurView.layer.sublayers![0]以保证frame正确
      _blurView.frame = CGRectMake(0, -85 - incrementY, self.view.frame.size.width, _originalHeight + 85);
      [_blurView.layer.sublayers[0] removeFromSuperlayer];
      [_blurView insertTwiceTransparentGradient];
      
      if (incrementY <= -65) {
        _arrowState = YES;
//        return;
      } else {
        _arrowState = NO;
      }
      
      [_imageView bringSubviewToFront:_titleLabel];
      [_imageView bringSubviewToFront:_sourceLabel];
    }
    if (incrementY > 223) {
      
    }
    [_webHeaderView layoutHeaderViewForScrollViewOffset:CGPointMake(0, incrementY)];
  }
}

#pragma mark - webHeaderView
- (void)loadParallaxHeader:(NSString *)imageURL imageSource:(NSString *)imageSource titleString:(NSString *)titleString {
  //初始化图片
  _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 223)];
  _imageView.contentMode = UIViewContentModeScaleAspectFill;
  [_imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
  
  //保存初始frame
  _originalHeight = _imageView.frame.size.height;
  
  //设置image上的titleLabel
  _titleLabel = [[myUILabel alloc] initWithFrame:CGRectMake(15, _originalHeight-80, self.view.frame.size.width-30, 60)];
  _titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:21.0];
  _titleLabel.textColor = [UIColor whiteColor];
  _titleLabel.shadowColor = [UIColor blackColor];
  _titleLabel.shadowOffset = CGSizeMake(0, 1);
  _titleLabel.verticalAlignment = VerticalAlignmentBottom;
  _titleLabel.numberOfLines = 0;
  _titleLabel.text = titleString;
  [_imageView addSubview:_titleLabel];
  
  //设置imageView上的Image_sourceLabel
  _sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, _originalHeight-22, self.view.frame.size.width-30, 15)];
  _sourceLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9.0];
  _sourceLabel.textColor = [UIColor lightTextColor];
  _sourceLabel.textAlignment = NSTextAlignmentRight;
  NSString *sourceLabelText = imageSource;
  _sourceLabel.text = [NSString stringWithFormat:@"图片：%@", sourceLabelText];
  [_imageView addSubview:_sourceLabel];
  
  //设置blurView
  _blurView = [[GradientView alloc] initWithFrame:CGRectMake(0, -85, self.view.frame.size.width, _originalHeight+85) type:TRANSPARENT_GRADIENT_TWICE_TYPE];
  
  //添加载入上一篇的文本
  UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 15, self.view.frame.size.width, 45)];
  refreshLabel.text = @"载入上一篇";
  if (self.index == 0 || self.isTopStory) {
    refreshLabel.text = @"已经是第一篇";
    refreshLabel.frame = CGRectMake(0, 15, self.view.frame.size.width, 45);
  }
  refreshLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
  refreshLabel.textColor = [UIColor colorWithRed:215.0f/255.0f green:215.0f/255.0f blue:215.0f/255.0f alpha:1];
  refreshLabel.textAlignment = NSTextAlignmentCenter;
  [_blurView addSubview:refreshLabel];
  
  //添加载入上一篇的图片
  if (self.index == 1) {
    UIImageView *refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-47, 30, 15, 15)];
    refreshLabel.contentMode = UIViewContentModeScaleAspectFill;
    refreshImageView.image = [UIImage imageNamed:@"arrow"];
    refreshImageView.tintColor = [UIColor colorWithRed:215.0f/255.0f green:215.0f/255.0f blue:215.0f/255.0f alpha:1];
    [_blurView addSubview:refreshImageView];
  }
  [_imageView addSubview:_blurView];
  //使Label不被遮挡
  [_imageView bringSubviewToFront:_titleLabel];
  [_imageView bringSubviewToFront:_sourceLabel];
  
  //添加进ParallaxView
  _webHeaderView = [ParallaxHeaderView parallaxWebHeaderViewWithSubView:_imageView forSize:CGSizeMake(self.view.frame.size.width, 223)];
  _webHeaderView.delegate = self;
  
  //将parallaxHeaderView加入到webView中
  [self.webView.scrollView addSubview:_webHeaderView];
}

- (void)loadNormalHeader {
  //更改statusBar的颜色
  self.navigationController.navigationBar.hidden = YES;
  self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
  [self setNeedsStatusBarAppearanceUpdate];
  self.statusBarBackground.backgroundColor = [UIColor colorWithRed:249.0f/255.0f green:249.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
  
  UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, -45, self.view.frame.size.width, 45)];
  refreshLabel.text = @"载入上一篇";
  if (self.index == 0) {
    refreshLabel.text = @"已经是第一篇了";
    refreshLabel.frame = CGRectMake(0, -45, self.view.frame.size.width, 45);
  }
  refreshLabel.textAlignment = NSTextAlignmentCenter;
  refreshLabel.textColor = [UIColor colorWithRed:215.0f/255.0f green:215.0f/255.0f blue:215.0f/255.0f alpha:1];
  refreshLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
  [self.webView.scrollView addSubview:refreshLabel];
  
  if (self.index == 1) {
    //载入上一篇的图片
    UIImageView *refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-47, -30, 15, 15)];
    refreshImageView.contentMode = UIViewContentModeScaleAspectFill;
    refreshImageView.image = [UIImage imageNamed:@"arrow"];
    refreshImageView.tintColor = [UIColor colorWithRed:215.0f/255.0f green:215.0f/255.0f blue:215.0f/255.0f alpha:1];
    [self.webView.scrollView addSubview:refreshImageView];
  }
}

#pragma mark - 其他函数
- (AppDelegate*)getApp {
  return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  if (_hasImage == NO) {
    return UIStatusBarStyleDefault;
  }
  return UIStatusBarStyleLightContent;
}
@end
