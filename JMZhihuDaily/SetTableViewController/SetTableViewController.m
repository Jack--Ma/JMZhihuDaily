//
//  SetTableViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/27.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "SetTableViewController.h"
#import "SwitchTableViewCell.h"
#import "SetTableViewCell.h"
#import "UserInfoViewController.h"
#import "ShareViewController.h"

@interface SetTableViewController ()

@end

@implementation SetTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //设置navBav格式
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  
  //设置返回button和title
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftArrow"] style:(UIBarButtonItemStylePlain) target:self.revealViewController action:@selector(revealToggle:)];
  leftBarButton.tintColor = [UIColor whiteColor];
  [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
  [self.navigationItem setLeftBarButtonItem:leftBarButton];
  [self.navigationItem setTitle:@"设置"];
  
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.scrollEnabled = NO;
  [self switchTheme];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchTheme) name:@"switchTheme" object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - 私有方法
- (void)switchTheme {
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (temp) {
    self.view.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
  } else {
    self.view.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:69.0f/255.0f green:68.0f/255.0f blue:72.0f/255.0f alpha:1.0f]];
  }
  [self.tableView reloadData];
}
- (void)showPicture:(id)sender {
  UISwitch *switchch = sender;

}
- (void)sendNotification:(id)sender {
  UISwitch *switchch = sender;
  
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 1;
  } else if (section == 1) {
    return 2;
  } else if (section == 2) {
    return 1;
  }
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 && indexPath.row == 0) {
    return 81.0f;
  }
  return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userTableViewCell"];
    [cell awakeFromNib];
    return cell;
  } else if (indexPath.section == 1) {
    SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switchTableViewCell"];
    [cell awakeFromNib];
    if (indexPath.row == 0) {
      cell.label.text = @"移动网络下不显示图片";
      cell.switchch.on = NO;
      [cell.switchch addTarget:self action:@selector(showPicture:) forControlEvents:UIControlEventValueChanged];
      return cell;
    } else if (indexPath.row == 1) {
      cell.label.text = @"推送消息";
      cell.switchch.on = NO;
      [cell.switchch addTarget:self action:@selector(sendNotification:) forControlEvents:UIControlEventValueChanged];
      return cell;
    }
  } else if (indexPath.section == 2) {
    SetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setTableViewCell"];
    [cell awakeFromNib];
    cell.label.text = @"分享应用";
    return cell;
  }
 
  return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    UserInfoViewController *userInfoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userInfoViewController"];;
    [self.navigationController pushViewController:userInfoViewController animated:YES];
  } else if (indexPath.section == 2) {
    ShareViewController *shareViewController = [[ShareViewController alloc] init];
    [self.navigationController pushViewController:shareViewController animated:YES];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
