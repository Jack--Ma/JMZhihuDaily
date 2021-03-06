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
#import "UserModel.h"
#import "ShareView.h"
#import "CommentsViewController.h"
#import "ImageViewController.h"

#define PHONEHEIGHT ([UIScreen mainScreen].bounds.size.height)
#define ISDAY ([[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"])

@interface WebViewController () <UIScrollViewDelegate, UIWebViewDelegate, ParallaxHeaderViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIView *statusBarBackground;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *collectButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *supportButton;
@property (nonatomic ,weak) IBOutlet UIBarButtonItem *commentButtom;
@property (nonatomic, weak) IBOutlet ShareView *shareView;

@end

@implementation WebViewController {
  //webHeader相关
  ParallaxHeaderView *_webHeaderView;
  UIImageView *_imageView;
  CGFloat _originalHeight;
  myUILabel *_titleLabel;
  UILabel *_sourceLabel;
  GradientView *_blurView;
  UIImageView *_refreshImageView;//加载上一篇的箭头
  UILabel *_refreshLabel;
  UIButton *_topImageButton;
  
  //webView相关
  BOOL _hasImage;
  BOOL _arrowState;//检测箭头方向
  BOOL _triggered;//检测下滑时手指是否按住屏幕
  BOOL _dragging;//检测手指是否在屏幕上滑动
  BOOL _statusBarFlat;
  
  //webFooter相关
  BOOL _isCollected;
  BOOL _isShare;
  UIView *_backView;
  NSString *_articleTitle;
  NSString *_articleImageURL;
  UIImage *_articleImage;
  NSString *_articleURL;
  BOOL _isSupport;
  NSInteger _supportCounts;
  NSInteger _longCommentCount;
  NSInteger _shortCommentCount;
  ZFModalTransitionAnimator *_animator;
}

- (void)viewDidLoad {
  [super viewDidLoad];
 
  _hasImage = YES;
  _triggered = NO;

  //避免因含有navBar而对scrollInsets做自动调整
  //避免ScrollView莫名其妙不能在viewController划到顶
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  //避免wenScrollView的contentView过长，挡住底层View
  self.view.clipsToBounds = YES;
  
  //隐藏默认返回button但保留左划返回，只在上一级存在navigation是有用
  self.navigationItem.hidesBackButton = YES;
  self.navigationController.interactivePopGestureRecognizer.enabled = YES;
  self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
  
  //对webView做基本配置
  self.webView.delegate = self;
  self.webView.scrollView.delegate = self;
  self.webView.scrollView.clipsToBounds = NO;
  self.webView.scrollView.showsVerticalScrollIndicator = YES;
  
  //夜间模式添加一个暗色图层
  [self switchTheme: ISDAY];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:animated];
  if (_refreshImageView) {
    return;
  }
  [self loadWebView:self.newsId];
  [self loadFooterView:self.newsId];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.navigationController setNavigationBarHidden:NO animated:animated];
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
    _articleTitle = titleString;
    _articleImageURL = image;
    _articleURL = data[@"share_url"];
    if (image && imageSource && titleString) {
      _hasImage = YES;
      [self loadParallaxHeader:image imageSource:imageSource titleString:titleString];
    } else {
      _hasImage = NO;
      self.statusBarBackground.backgroundColor = [UIColor whiteColor];
      [self loadNormalHeader];
    }
    NSString *js = [NSString stringWithFormat:@"<script type=\"text/javascript\">%@</script>", [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"ClickImage" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil]];
    NSString *html = [NSString stringWithFormat:@"<html><head>%@<link rel=\"stylesheet\" href=%@></head><body>%@</body></html>", js, css, body];
    if (!ISDAY) {
      //夜间下调用night样式的CSS
      html = [NSString stringWithFormat:@"<html><head>%@<link rel=\"stylesheet\" href=%@></head><body><div class=\"night\">%@</div></body></html>", js, css, body];
    }
    [self.webView loadHTMLString:html baseURL:nil];
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"%@", error);
  }];
  [operation start];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//  NSLog(@"%@", request.URL.pathExtension);
  //处理点击图片
  if ([request.URL.pathExtension containsString:@"jpg"] || [request.URL.pathExtension containsString:@"png"]) {
    ImageViewController *imageViewController = [[ImageViewController alloc] init];
    imageViewController.imageURL = request.URL;
    imageViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:imageViewController animated:YES completion:nil];
    return NO;
  }
  //处理点击链接，about:blank表示加载这个webView，return YES表示加载
  //其他情况均为点击链接，return NO表示不加载，之前进行Alert提示处理
  if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
    return YES;
  } else {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"知乎日报" message:@"如何处理该链接？" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [alertVC dismissViewControllerAnimated:YES completion:nil];
      [UIPasteboard generalPasteboard].URL = request.URL;
    }];
    UIAlertAction *safariAction = [UIAlertAction actionWithTitle:@"使用Safari打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [alertVC dismissViewControllerAnimated:YES completion:nil];
      [[UIApplication sharedApplication] openURL:request.URL];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
      [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:copyAction];
    [alertVC addAction:safariAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
    
    return NO;
  }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  if (!ISDAY) {
    self.webView.scrollView.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:51.0/255.0 blue:55.0/255.0 alpha:1.0];
  } else {
    self.webView.scrollView.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
  }
  [self.webView stringByEvaluatingJavaScriptFromString:@"set_image_click_function()"];
}

- (void)lockDirection {
  [self.webView.scrollView setContentOffset:CGPointMake(0, -85.0)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (_hasImage) {
    NSInteger incrementY = scrollView.contentOffset.y;
    if (incrementY < 0) {
      //不断设置titleLabel、sourceLabel和blurView以保证frame正确
      _titleLabel.frame = CGRectMake(15, _originalHeight-80-incrementY, self.view.frame.size.width-30, 60);
      _sourceLabel.frame = CGRectMake(15, _originalHeight-20-incrementY, self.view.frame.size.width-30, 15);
      _blurView.frame = CGRectMake(0, -85 - incrementY, self.view.frame.size.width, _originalHeight + 85);
      [_blurView.layer.sublayers[0] removeFromSuperlayer];
      [_blurView insertTwiceTransparentGradient];
      
      //调整箭头方向，同时判断是否加载上一篇
      if (incrementY <= -75.0f) {
        //箭头向上=0
        _arrowState = YES;
        if (_refreshImageView) {
          [UIView animateWithDuration:0.2 animations:^{
            _refreshImageView.transform = CGAffineTransformMakeRotation(M_PI);
          }];
        }
        //加载新文章
        if (!_dragging && !_triggered) {
          if (self.index != 0) {
            [self loadNewArticle];
            _triggered = YES;
          }
        }
      } else {
        //箭头向下
        _arrowState = NO;
        if (_refreshImageView) {
          [UIView animateWithDuration:0.2 animations:^{
            _refreshImageView.transform = CGAffineTransformIdentity;
          }];
        }
      }
    }
    
    //调整statusBar颜色
    if (incrementY >= 203) {
      [UIView animateWithDuration:0.2 animations:^{
        if (ISDAY) {
          self.statusBarBackground.backgroundColor = [UIColor whiteColor];
        } else {
          self.statusBarBackground.backgroundColor = [UIColor colorWithRed:68.0/255.0 green:67.0/255.0 blue:76.0/255.0 alpha:1.0];
        }
        _statusBarFlat = YES;
        [self setNeedsStatusBarAppearanceUpdate];
      }];
    } else {
      [UIView animateWithDuration:0.2 animations:^{
        self.statusBarBackground.backgroundColor = [UIColor clearColor];
        _statusBarFlat = NO;
        [self setNeedsStatusBarAppearanceUpdate];
      }];
    }
    
    [_imageView bringSubviewToFront:_titleLabel];
    [_imageView bringSubviewToFront:_sourceLabel];

    [_webHeaderView layoutWebHeaderViewForScrollViewOffset:CGPointMake(0, incrementY)];
  } else {
    //没有topImage的情况
    //调整箭头方向，同时判断是否加载上一篇
    if (self.webView.scrollView.contentOffset.y <= -35.0) {
      //箭头方向向上
      if (_refreshImageView) {
        [UIView animateWithDuration:0.2 animations:^{
          _refreshImageView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
      }
      //加载新文章
      if (!_dragging && !_triggered) {
        if (self.index != 0) {
          [self loadNewArticle];
          _triggered = YES;
        }
      }
    } else {
      //箭头方向向下
      if (_refreshImageView) {
        [UIView animateWithDuration:0.2 animations:^{
          _refreshImageView.transform = CGAffineTransformIdentity;
        }];
      }
    }
  }
}

//记录下拉时状态
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//  NSLog(@"333");
  _dragging = NO;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//  NSLog(@"111");
  _dragging = YES;
}

#pragma mark - webHeaderView
- (void)loadParallaxHeader:(NSString *)imageURL imageSource:(NSString *)imageSource titleString:(NSString *)titleString {
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  [_webHeaderView removeFromSuperview];
  //初始化图片
  _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 225)];
  _imageView.contentMode = UIViewContentModeScaleAspectFill;
  [_imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    _articleImage = image;
  }];
  
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
  if (self.index != 0) {
    _refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-47, 30, 15, 15)];
    refreshLabel.contentMode = UIViewContentModeScaleAspectFill;
    _refreshImageView.image = [UIImage imageNamed:@"arrow"];
    _refreshImageView.tintColor = [UIColor colorWithRed:215.0f/255.0f green:215.0f/255.0f blue:215.0f/255.0f alpha:1];
    [_blurView addSubview:_refreshImageView];
  }
  [_imageView addSubview:_blurView];
  //使Label不被遮挡
  [_imageView bringSubviewToFront:_titleLabel];
  [_imageView bringSubviewToFront:_sourceLabel];
  
  //设置ParallaxView，加入到webView的scrollView中
  _webHeaderView = [ParallaxHeaderView parallaxWebHeaderViewWithSubView:_imageView forSize:CGSizeMake(self.view.frame.size.width, 225)];
  _webHeaderView.delegate = self;
  [self.webView.scrollView addSubview:_webHeaderView];
  
  //添加点击TopImage查看图片的button，并设置白天夜晚不同颜色
  _topImageButton = [[UIButton alloc] initWithFrame:_blurView.frame];
  _topImageButton.y -= 20.0;
  [_topImageButton addTarget:self action:@selector(showTopImage) forControlEvents:UIControlEventTouchUpInside];
  if (ISDAY) {
    _topImageButton.backgroundColor = [UIColor clearColor];
  } else {
    _topImageButton.backgroundColor = [UIColor blackColor];
    _topImageButton.alpha = 0.2;
  }
  [self.webView.scrollView addSubview:_topImageButton];
}

- (void)loadNormalHeader {
  //更改statusBar的颜色
  _statusBarFlat = YES;
  self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
  [self setNeedsStatusBarAppearanceUpdate];
  if (ISDAY) {
    self.statusBarBackground.backgroundColor = [UIColor whiteColor];
  } else {
    self.statusBarBackground.backgroundColor = [UIColor colorWithRed:68.0/255.0 green:67.0/255.0 blue:76.0/255.0 alpha:1.0];
  }
  
  [_refreshLabel removeFromSuperview];
  _refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, -45, self.view.frame.size.width, 45)];
  _refreshLabel.text = @"载入上一篇";
  if (self.index == 0) {
    _refreshLabel.text = @"已经是第一篇了";
    _refreshLabel.frame = CGRectMake(0, -45, self.view.frame.size.width, 45);
  }
  _refreshLabel.textAlignment = NSTextAlignmentCenter;
  _refreshLabel.textColor = [UIColor colorWithRed:215.0f/255.0f green:215.0f/255.0f blue:215.0f/255.0f alpha:1];
  _refreshLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
  [self.webView.scrollView addSubview:_refreshLabel];
  
  [_refreshImageView removeFromSuperview];
  if (self.index != 0) {
    //载入上一篇的图片
    _refreshImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-47, -30, 15, 15)];
    _refreshImageView.contentMode = UIViewContentModeScaleAspectFill;
    _refreshImageView.image = [UIImage imageNamed:@"arrow"];
    _refreshImageView.tintColor = [UIColor colorWithRed:215.0f/255.0f green:215.0f/255.0f blue:215.0f/255.0f alpha:1];
    [self.webView.scrollView addSubview:_refreshImageView];
  }
}

#pragma mark - webFooterView
- (void)loadFooterView:(NSInteger)newsId {
  //设置toolBar的颜色
  if (!ISDAY) {
    self.toolBar.barTintColor = [UIColor colorWithRed:68.0/255.0 green:67.0/255.0 blue:76.0/255.0 alpha:1.0];
  }
  
  //设置收藏button的颜色
  NSString *urlString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/4/news/%ld", (long)newsId];
  NSArray *array = [UserModel currentUser].articlesList;
  _isCollected = NO;
  
  [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSString *string = (NSString *)obj;
    self.collectButton.tintColor = [UIColor lightGrayColor];
    if ([string isEqualToString:urlString]) {
      self.collectButton.tintColor = [UIColor orangeColor];
      _isCollected = YES;
      *stop = YES;
    }
  }];

  //退出分享界面的手势
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeCancel)];
  tap.delegate = self;
  tap.cancelsTouchesInView = NO;
  
  //点击分享后显示上层的暗色背景
  [_backView removeFromSuperview];
  _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 44.0)];
  _backView.backgroundColor = [UIColor blackColor];
  _backView.alpha = 0.0;
  [_backView addGestureRecognizer:tap];
  
  //设置分享界面
  _isShare = NO;
  self.shareView.hidden = YES;
  self.shareView.transform = CGAffineTransformMakeTranslation(0, 194.0);//移出屏幕
  
  //设置点赞与评论button
  _isSupport = NO;
  NSString *extraString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/4/story-extra/%ld", (long)self.newsId];
  NSURL *url = [NSURL URLWithString:extraString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSDictionary *dic = (NSDictionary *)responseObject;
    _supportCounts = [dic[@"popularity"] integerValue];
    NSInteger commentCounts = [dic[@"comments"] integerValue];
    _longCommentCount = [dic[@"long_comments"] integerValue];
    _shortCommentCount = [dic[@"short_comments"] integerValue];
    
    [self.supportButton setTitle: [NSString stringWithFormat:@"赞%ld", _supportCounts]];
    [self.commentButtom setTitle:[NSString stringWithFormat:@"评论%ld", (long)commentCounts]];
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"error: %@", [error userInfo]);
  }];
  [operation start];
}
- (IBAction)backToTop:(id)sender {
  [self.webView.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (IBAction)collectArticle:(id)sender {
  NSString *urlString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/4/news/%ld", (long)self.newsId];
  NSMutableArray *array = [UserModel currentUser].articlesList;
  if (!array) {
    //array为空表示未登录
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"登录后才能收藏文章哦" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
    return;
  }
  if (_isCollected) {
    self.collectButton.tintColor = [UIColor lightGrayColor];
    [array removeObject:urlString];
  } else {
    self.collectButton.tintColor = [UIColor orangeColor];
    [array addObject:urlString];
  }
  _isCollected = !_isCollected;
  [[UserModel currentUser] setObject:array forKey:@"articlesList"];
  [[UserModel currentUser] save];
}
- (IBAction)shareArticle:(id)sender {
  self.shareView.articleTitle = _articleTitle;
  self.shareView.articleImageURL = _articleImageURL;
  self.shareView.articleImage = _articleImage;
  self.shareView.articleURL = _articleURL;
  if (!_isShare) {
    //出现分享界面
    [UIView animateWithDuration:0.3 animations:^{
      _backView.alpha = 0.2;
      self.shareView.hidden = NO;
      self.shareView.transform = CGAffineTransformIdentity;
    }];
    [self.view insertSubview:_backView belowSubview:self.shareView];
  } else {
    //收回分享界面
    [UIView animateWithDuration:0.3 animations:^{
      self.shareView.transform = CGAffineTransformMakeTranslation(0, 194.0);
      _backView.alpha = 0.0;
    } completion:^(BOOL finished) {
      self.shareView.hidden = YES;
      [_backView removeFromSuperview];
    }];
  }
  _isShare = !_isShare;
}
- (IBAction)supportArticle:(id)sender {
  if (_isSupport) {
    _supportCounts--;
    [self.supportButton setTitle:[NSString stringWithFormat:@"赞%ld", (long)_supportCounts]];
    [self.supportButton setTintColor:[UIColor lightGrayColor]];
  } else {
    _supportCounts++;
    [self.supportButton setTitle:[NSString stringWithFormat:@"赞%ld", (long)_supportCounts]];
    [self.supportButton setTintColor:[UIColor orangeColor]];
  }
  _isSupport = !_isSupport;
}
- (IBAction)commentArticle:(id)sender {
  CommentsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsViewController"];
  vc.longCommentCounts = _longCommentCount;
  vc.shortCommentCounts = _shortCommentCount;
  vc.newsId = self.newsId;
  
  //类似push的动画效果，注意：_animator必须在全局声明，否则弹出的界面无法左滑返回
  _animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:vc];
  _animator.dragable = YES;
  _animator.bounces = NO;
  _animator.direction = ZFModalTransitonDirectionRight;
  _animator.behindViewAlpha = 1.0;
  _animator.behindViewScale = 1.0;
  _animator.transitionDuration = 0.7;
  
  vc.transitioningDelegate = _animator;
  
  [self presentViewController:vc animated:YES completion:nil];
}
//收回分享界面
- (void)makeCancel {
  [UIView animateWithDuration:0.3 animations:^{
    self.shareView.transform = CGAffineTransformMakeTranslation(0, 194.0);
    _backView.alpha = 0.0;
  } completion:^(BOOL finished) {
    self.shareView.hidden = YES;
    [_backView removeFromSuperview];
  }];
  _isShare = !_isShare;
}
//当触摸在_backView范围内，收回分享界面
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  if ([_backView isDescendantOfView:self.view]) {
    return touch.view == _backView;
  }
  return YES;
}

#pragma mark - 其他函数
- (void)showTopImage {
  ImageViewController *imageViewController = [[ImageViewController alloc] init];
  imageViewController.imageURL = [NSURL URLWithString:_articleImageURL];
  imageViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self presentViewController:imageViewController animated:YES completion:nil];
}

- (void)switchTheme:(BOOL)temp {

}
- (void)loadNewArticle {
//  NSLog(@"loadNewArticle");
  //生成动画初始位置
  CGAffineTransform offScreenUp = CGAffineTransformMakeTranslation(0, -self.view.frame.size.height);
  CGAffineTransform offScreenDown = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
  
  //生成新的webView
  WebViewController *newWebViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
  UIView *newView = newWebViewController.view;
  
  //传入相关数据
  if (self.isThemeStory == NO) {
    //不是theme中的文章
    self.index--;
    if (self.index < [StoryModel shareStory].contentStory.count) {
      //当前为今日的内容，上一篇也为今日的文章
      newWebViewController.index = self.index;
      newWebViewController.newsId = [[StoryModel shareStory].contentStory[self.index][@"id"] integerValue];
    } else if (self.index == [StoryModel shareStory].contentStory.count) {
      //当前为前一天的第一篇
      newWebViewController.index = self.index - 1;
      newWebViewController.newsId = [[StoryModel shareStory].contentStory[self.index-1][@"id"] integerValue];
    } else {
      //当前是过去三天的内容（除了昨天的第一篇）前一篇为过去三天的内容
      NSInteger newIndex = self.index - [StoryModel shareStory].contentStory.count;
      NSInteger day = newIndex / 20;//day表示当前文章是哪一天的，0=昨天，1=前天...
      newWebViewController.index = newIndex - 1 - day;
      newWebViewController.newsId = [[StoryModel shareStory].pastContentStory[newIndex-1-day][@"id"] integerValue];
    }
  } else {
    //是theme中的文章
    self.index--;
    newWebViewController.index = self.index;
    newWebViewController.newsId = [[StoryModel shareStory].themeContent[self.index][@"id"] integerValue];
  }
  
  //生成原View截图添加到主View上
  UIView *oldView = [self.view snapshotViewAfterScreenUpdates:YES];
  [self.view addSubview:oldView];
  
  //将newWebView放在屏幕外并添加进主View中
  [self addChildViewController:newWebViewController];
  NSLog(@"\n%@\n%@\n%@", self.parentViewController, self, self.childViewControllers);
  newView.transform = offScreenUp;
  [self.view addSubview:newView];
  
  //动画开始
  [UIView animateWithDuration:0.5 animations:^{
    //oldView下滑出屏幕，newWebView进入屏幕
    oldView.transform = offScreenDown;
    newView.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    //动画完成后清理底层webView、statusBarBackground，以及滑出屏幕的oldView
    //但每次加载新文章都会留一层UIView 待解决 这里有问题
    [self.webView removeFromSuperview];
    [self.statusBarBackground removeFromSuperview];
    [oldView removeFromSuperview];
  }];
}
//多次加载上一篇后，这个方法一直存在，且新的webView不加载自己的此方法，而是最底层View的这个方法
//！！！奇哉怪也
- (UIStatusBarStyle)preferredStatusBarStyle {
  if (_statusBarFlat) {
    return UIStatusBarStyleDefault;
  }
  return UIStatusBarStyleLightContent;
}
@end
