//
//  UserInfoViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/14.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "UserInfoViewController.h"
#import "UserInfoCell.h"
#import "UserModel.h"

@interface UserInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *logoutButton;
@property (nonatomic, weak) IBOutlet UIButton *avatarImageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation UserInfoViewController

- (IBAction)doLogout:(id)sender {
  [UserModel logOut];
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - init
- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
  
  //设置navBav格式
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
  
  //设置返回button和title
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftArrow"] style:(UIBarButtonItemStylePlain) target:self.revealViewController action:@selector(revealToggle:)];
  leftBarButton.tintColor = [UIColor whiteColor];
  [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
  [self.navigationItem setLeftBarButtonItem:leftBarButton];
  [self.navigationItem setTitle:@"个人信息"];
  
  //头像的设置
  [self.avatarImageView setImage:[UIImage imageNamed:@"avatarExample"] forState:UIControlStateNormal];
  self.avatarImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
  self.avatarImageView.layer.cornerRadius = 52;
  self.avatarImageView.clipsToBounds = YES;
  
  //圆角的登出button
  self.logoutButton.layer.cornerRadius = 8;
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.scrollEnabled = NO;
  self.tableView.showsVerticalScrollIndicator = NO;
  
  [UserModel currentUser].selfDescription = [[UserModel currentUser] objectForKey:@"selfDescription"];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 4;
  }
  return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 22.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return @"个人信息";
  }
  return @"帐号信息";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userTableViewCell"];
  if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      cell = [cell initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"userTableViewCell"];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textLabel.text = @"昵称";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [UserModel currentUser].username];
    }
    if (indexPath.row == 1) {
      cell = [cell initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"userTableViewCell"];
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.textLabel.text = @"性别";
      cell.detailTextLabel.text = @"男";
    }
    if (indexPath.row == 2) {
      cell = [cell initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"userTableViewCell"];
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.textLabel.text = @"生日";
      cell.detailTextLabel.text = @"2015年10月10日";
    }
    if (indexPath.row == 3) {
      cell = [cell initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"userTableViewCell"];
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      cell.textLabel.text = @"签名";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [UserModel currentUser].selfDescription];
    }
  }
  if (indexPath.section == 1) {
    cell = [cell initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"userTableViewCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"密码";
    cell.detailTextLabel.text = @"修改密码";
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
