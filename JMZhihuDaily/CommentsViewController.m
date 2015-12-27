//
//  CommentsViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/24.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "CommentsViewController.h"
#import "CommentTableViewCell.h"
#import "UserModel.h"
#import "LoginViewController.h"
#import "JMCheckView.h"

@interface CommentsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIView *textView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;

@property (nonatomic, strong) NSArray *longCommentArray;
@property (nonatomic, strong) NSArray *shortCommentArray;

@end

@implementation CommentsViewController {
  UITableViewHeaderFooterView *_longCommentHeaderView;
  UITableViewHeaderFooterView *_shortCommentHeaderView;

  UIImageView *_longArrow;
  UIImageView *_shortArrow;
  BOOL _isLongHide;
  BOOL _isShortHide;
}

- (void)dismissView {
  [self dismissViewControllerAnimated:YES completion:nil];
}

//中部table相关
- (void)loadComments {
  //加载长评
  NSString *longString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/4/story/%ld/long-comments", (long)self.newsId];
  NSURL *longURL = [NSURL URLWithString:longString];
  NSURLRequest *longRequest = [NSURLRequest requestWithURL:longURL];
  
  AFHTTPRequestOperation *longOperation = [[AFHTTPRequestOperation alloc] initWithRequest:longRequest];
  longOperation.responseSerializer = [AFJSONResponseSerializer serializer];
  [longOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    self.longCommentArray = (NSArray *)responseObject[@"comments"];
    //加载短评
    NSString *shortString = [NSString stringWithFormat:@"http://news-at.zhihu.com/api/4/story/%ld/short-comments", (long)self.newsId];
    NSURL *shortURL = [NSURL URLWithString:shortString];
    NSURLRequest *shortRequest = [NSURLRequest requestWithURL:shortURL];
    
    AFHTTPRequestOperation *shortOperation = [[AFHTTPRequestOperation alloc] initWithRequest:shortRequest];
    shortOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [shortOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
      self.shortCommentArray = (NSArray *)responseObject[@"comments"];
      //收回activityView后刷新界面
      [self.activityView stopAnimating];
      [self.activityView removeFromSuperview];
      _isLongHide = NO;
      _isShortHide = NO;
      [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
      NSLog(@"%@", [error userInfo]);
    }];
    [shortOperation start];
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"%@", [error userInfo]);
  }];
  [longOperation start];
}

- (void)showLongTable {
  if (_isLongHide) {
    [UIView animateWithDuration:0.3 animations:^{
      _longArrow.transform = CGAffineTransformIdentity;
    }];
  } else {
    [UIView animateWithDuration:0.3 animations:^{
      _longArrow.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }];
  }
  _isLongHide = !_isLongHide;
  [self.tableView reloadData];
}

- (void)showShortTable {
  if (_isShortHide) {
    [UIView animateWithDuration:0.3 animations:^{
      _shortArrow.transform = CGAffineTransformIdentity;
    }];
  } else {
    [UIView animateWithDuration:0.3 animations:^{
      _shortArrow.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }];
  }
  _isShortHide = !_isShortHide;
  [self.tableView reloadData];
}

#pragma mark - 底部相关实现函数
- (IBAction)login:(id)sender {
  //未登录，进入登录界面
  LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
  [self presentViewController:loginViewController animated:YES completion:nil];
}

- (IBAction)comment:(id)sender {
  JMCheckView *checkView = [JMCheckView CheckInView:self.view];
  checkView.text = @"评论成功";
  [self.view addSubview:checkView];
  checkView.alpha = 0.0f;
  checkView.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
  
  [UIView animateWithDuration:0.2 animations:^{
    checkView.alpha = 1.0f;
    checkView.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.3 delay:0.5 options:(UIViewAnimationOptionShowHideTransitionViews) animations:^{
      checkView.alpha = 0.0f;
    } completion:^(BOOL finished) {
      [checkView removeFromSuperview];
    }];
  }];
  self.textField.text = @"";
  [self.textField resignFirstResponder];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
  //计算键盘高度
  if ([notification.name isEqualToString:@"UIKeyboardWillHideNotification"]) {
    [self adjustPanelsWithKeybordHeight:0.0];
  } else {
    NSValue *keyboardFrameValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = keyboardFrameValue.CGRectValue;
    [self adjustPanelsWithKeybordHeight:keyboardFrame.size.height];
  }
}

- (void)adjustPanelsWithKeybordHeight:(float)height {
  if (height > 0) {
    [UIView animateWithDuration:0.3 animations:^{
      self.textView.transform = CGAffineTransformMakeTranslation(0, -height);
    }];
  } else {
    [UIView animateWithDuration:0.3 animations:^{
      self.textView.transform = CGAffineTransformIdentity;
    }];
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  [self.textField resignFirstResponder];
}

//滑动时收起键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self.textField resignFirstResponder];
}

#pragma mark - init
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if ([UserModel currentUser]) {
    self.loginButton.hidden = YES;
    self.textView.hidden = NO;
  } else {
    self.loginButton.hidden = NO;
    self.textView.hidden = YES;
  }
}

- (void)viewDidLoad {
  //设置Bar的title
  [self.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:171.0/255.0 blue:255.0/255.0 alpha:1.0]];
  [self.navigationBar.topItem setTitle:[NSString stringWithFormat:@"%ld条评论", (long)(self.longCommentCounts+self.shortCommentCounts)]];
  
  //设置返回button
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
  [leftBarButton setImageInsets:UIEdgeInsetsMake(0, 5.0, 0, 0)];
  [self.navigationBar.topItem setLeftBarButtonItem:leftBarButton];
  
  //tableView相关
  self.tableView.backgroundColor = [UIColor whiteColor];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  self.activityView.frame = CGRectMake(0, 0, 20, 20);//其实大小固定为20*20
  self.activityView.center = self.view.center;
  [self.view addSubview:self.activityView];
  [self.activityView startAnimating];
  [self loadComments];
  
  //长评的header
  _isLongHide = YES;
  _longCommentHeaderView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0)];
  _longArrow = [[UIImageView alloc] initWithFrame:CGRectMake(20, 11, 22, 22)];
  _longArrow.image = [UIImage imageNamed:@"down_arrow"];
  [_longArrow setTintColor:[UIColor blackColor]];
  UILabel *longNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 11.0, 100.0, 22.0)];
  longNameLabel.text = [NSString stringWithFormat:@"%ld条长评论", (long)self.longCommentCounts];
  [_longCommentHeaderView addSubview:_longArrow];
  [_longCommentHeaderView addSubview:longNameLabel];
  
  UIButton *longButton = [UIButton buttonWithType:UIButtonTypeCustom];
  longButton.frame = _longCommentHeaderView.frame;
  [longButton addTarget:self action:@selector(showLongTable) forControlEvents:UIControlEventTouchUpInside];
  [_longCommentHeaderView addSubview:longButton];
  _longCommentHeaderView.contentView.backgroundColor = [UIColor whiteColor];
  
  //短评的Header
  _isShortHide = YES;
  _shortCommentHeaderView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0)];
  _shortArrow = [[UIImageView alloc] initWithFrame:CGRectMake(20, 11, 22, 22)];
  _shortArrow.image = [UIImage imageNamed:@"down_arrow"];
  [_shortArrow setTintColor:[UIColor blackColor]];
  UILabel *shortNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 11.0, 100.0, 22.0)];
  shortNameLabel.text = [NSString stringWithFormat:@"%ld条短评论", (long)self.shortCommentCounts];
  [_shortCommentHeaderView addSubview:_shortArrow];
  [_shortCommentHeaderView addSubview:shortNameLabel];
  
  UIButton *shortButton = [UIButton buttonWithType:UIButtonTypeCustom];
  shortButton.frame = _shortCommentHeaderView.frame;
  [shortButton addTarget:self action:@selector(showShortTable) forControlEvents:UIControlEventTouchUpInside];
  [_shortCommentHeaderView addSubview:shortButton];
  _shortCommentHeaderView.contentView.backgroundColor = [UIColor whiteColor];
  
  //textFied相关
  self.textField.delegate = self;
  self.textField.keyboardAppearance = UIKeyboardAppearanceDark;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillHideNotification object:nil];
  
  //设置评论button
  self.commentButton.layer.cornerRadius = 3.0;
  self.commentButton.layer.borderWidth = 1.0;
  self.commentButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
  
  //夜间模式的设置
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (!temp) {
    [self.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:69.0f/255.0f green:68.0f/255.0f blue:72.0f/255.0f alpha:1.0f]];
    self.tableView.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    _longCommentHeaderView.contentView.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    [_longArrow setTintColor:[UIColor whiteColor]];
    [longNameLabel setTextColor:[UIColor whiteColor]];
    _shortCommentHeaderView.contentView.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    [_shortArrow setTintColor:[UIColor whiteColor]];
    [shortNameLabel setTextColor:[UIColor whiteColor]];
    _textView.backgroundColor = [UIColor colorWithRed:69.0f/255.0f green:68.0f/255.0f blue:72.0f/255.0f alpha:1.0f];
    _textField.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    [_textField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    _textField.textColor = [UIColor lightGrayColor];
    [self.commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  } else {
    self.textField.keyboardAppearance = UIKeyboardAppearanceLight;
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return 200.0;
  }
  return 100.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return _longCommentHeaderView;
  } else if (section == 1) {
    return _shortCommentHeaderView;
  }
  return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    if (_isLongHide) {
      _longArrow.transform = CGAffineTransformMakeRotation(-M_PI_2);
      return 0;
    }
    if (self.longCommentArray.count != 0) {
      _longArrow.transform = CGAffineTransformIdentity;
      return self.longCommentArray.count;
    }
  } else if (section == 1) {
    if (_isShortHide) {
      _shortArrow.transform = CGAffineTransformMakeRotation(-M_PI_2);
      return 0;
    }
    if (self.shortCommentArray.count != 0) {
      _shortArrow.transform = CGAffineTransformIdentity;
      return self.shortCommentArray.count;
    }
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"longCommentCell"];
  if (indexPath.section == 0) {
    cell.commentDic = self.longCommentArray[indexPath.row];
  } else {
    cell.commentDic = self.shortCommentArray[indexPath.row];
  }
  [cell awakeFromNib];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
