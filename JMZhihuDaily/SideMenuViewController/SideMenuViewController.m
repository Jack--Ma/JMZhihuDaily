//
//  SideMenuViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/4.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

#import "SideMenuViewController.h"
#import "HomeSideCell.h"
#import "ContentSideCell.h"
#import "ThemeViewController.h"

#import "LoginViewController.h"
#import "UserInfoViewController.h"

#import "UserModel.h"

@interface SideMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *headImageView;
@property (nonatomic, weak) IBOutlet UIImageView *footImageView;

@property (nonatomic, weak) IBOutlet UIButton *userAvator;
@property (nonatomic, weak) IBOutlet UIButton *userName;
@property (weak, nonatomic) IBOutlet UIButton *switchView;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;

@end

@implementation SideMenuViewController {
  GradientView *_backView;
  UIView *_rightView;
}

#pragma mark - 私有方法
- (IBAction)doLogin:(id)sender {
  if ([UserModel currentUser]) {
    //已登录，直接跳转到个人信息界面
    return;
  } else {
    //未登录，进入登录界面
    LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
  }
}

- (IBAction)setNightOrDay:(id)sender {
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  temp = !temp;
  if (!temp) {
    [self.view setBackgroundColor:[UIColor colorWithRed:31.0f/255.0f green:30.0f/255.0f blue:34.0f/255.0f alpha:1]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:31.0f/255.0f green:30.0f/255.0f blue:34.0f/255.0f alpha:1]];
    [self.headImageView setTintColor:[UIColor colorWithRed:31.0f/255.0f green:30.0f/255.0f blue:34.0f/255.0f alpha:1]];
    [self.footImageView setTintColor:[UIColor colorWithRed:31.0f/255.0f green:30.0f/255.0f blue:34.0f/255.0f alpha:1]];
    [self.switchView setImage:[UIImage imageNamed:@"sun"] forState:UIControlStateNormal];
    [self.switchButton setTitle:@"白天" forState:UIControlStateNormal];
  } else {
    [self.view setBackgroundColor:[UIColor colorWithRed:32.0f/255.0f green:42.0f/255.0f blue:52.0f/255.0f alpha:1]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:32.0f/255.0f green:42.0f/255.0f blue:52.0f/255.0f alpha:1]];
    [self.headImageView setTintColor:[UIColor colorWithRed:32.0f/255.0f green:42.0f/255.0f blue:52.0f/255.0f alpha:1]];
    [self.footImageView setTintColor:[UIColor colorWithRed:32.0f/255.0f green:42.0f/255.0f blue:52.0f/255.0f alpha:1]];
    [self.switchView setImage:[UIImage imageNamed:@"night"] forState:UIControlStateNormal];
    [self.switchButton setTitle:@"夜间" forState:UIControlStateNormal];
  }
  [[NSUserDefaults standardUserDefaults] setBool:temp forKey:@"isDay"];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"switchTheme" object:nil];
  [self.tableView reloadData];
  [_backView refreshView];
}

- (void)takeSide {
  
}
#pragma mark - init
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  //设置头像和用户名
  self.userAvator.contentMode = UIViewContentModeScaleAspectFill;
  self.userAvator.layer.cornerRadius = 17.5;
  self.userAvator.clipsToBounds = YES;
  if ([UserModel currentUser]) {
    NSData *data = [[UserModel currentUser].avatar getData];
    UIImage *image = [UIImage imageWithData:data];
    if (data == nil) {
      image = [UIImage imageNamed:@"noneHead"];
    }
    [self.userAvator setImage:image forState:UIControlStateNormal];
    [self.userName setTitle:[NSString stringWithFormat:@"%@", [UserModel currentUser].username] forState:UIControlStateNormal];
  } else {
    [self.userAvator setImage:[UIImage imageNamed:@"noneHead"] forState:UIControlStateNormal];
    [self.userName setTitle:@"未登录" forState:UIControlStateNormal];
  }
  //设置白天夜晚切换的button
  [self.switchView setTintColor:[UIColor lightGrayColor]];
  //设置点击右边界面返回
  UITapGestureRecognizer *tap;
  tap = [self.revealViewController tapGestureRecognizer];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  
  //添加一条分割线
  UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 125, 225, 1)];
  seperatorView.backgroundColor = [UIColor colorWithRed:25.0f/255.0f green:35.0f/255.0f blue:45.0f/255.0f alpha:1];
  [self.view addSubview:seperatorView];
  
  //最下方的cell添加渐变的背景
  _backView = [[GradientView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 45 - 50, self.view.frame.size.width, 50) type:TRANSPARENT_ANOTHER_GRADIENT_TYPE];
  [self.view addSubview:_backView];
  
  [self.view setBackgroundColor:[UIColor colorWithRed:32.0f/255.0f green:42.0f/255.0f blue:52.0f/255.0f alpha:1]];
  [self.tableView setBackgroundColor:[UIColor colorWithRed:32.0f/255.0f green:42.0f/255.0f blue:52.0f/255.0f alpha:1]];
  
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.showsVerticalScrollIndicator = NO;
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.rowHeight = 50.5f;
}

#pragma mark - other function
//设置StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [StoryModel shareStory].themes.count + 1 + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    HomeSideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeSideCell"];
    [cell awakeFromNib];
    return cell;
  } else if (indexPath.row <= [StoryModel shareStory].themes.count) {
    ContentSideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentSideCell"];
    [cell awakeFromNib];
    cell.contentTitleLabel.text = [StoryModel shareStory].themes[indexPath.row-1][@"name"];
    return cell;
  }
  //最后一行cell无法点击,由于上方加了渐变图片
  ContentSideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentSideCell"];
  [cell awakeFromNib];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.contentTitleLabel.text = @"更多日报内容";
  cell.userInteractionEnabled = NO;//设置不可点击
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSInteger row = self.tableView.indexPathForSelectedRow.row;
  if (row != 0 && row != [StoryModel shareStory].themes.count+1) {
    UINavigationController *nav = segue.destinationViewController;
    ThemeViewController *themeViewController = (ThemeViewController *)nav.topViewController;
    themeViewController.name = [StoryModel shareStory].themes[row-1][@"name"];
    themeViewController.tid = [StoryModel shareStory].themes[row-1][@"id"];
  }

}
@end
