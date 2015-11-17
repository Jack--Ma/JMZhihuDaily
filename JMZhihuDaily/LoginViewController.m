//
//  LoginViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/13.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "LoginViewController.h"
#import "UserModel.h"

@interface LoginViewController ()

@property (nonatomic, weak) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *idTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *inOrOutButton;

@end

@implementation LoginViewController {
  BOOL _inOrOut;//YES表示登录
}

#pragma mark - other function
- (IBAction)doLogin:(id)sender {
  NSString *userName = self.nameTextField.text;
  NSString *userId = self.idTextField.text;
  NSString *password = self.passwordTextField.text;
  
  if (_inOrOut) {
    [UserModel logInWithUsernameInBackground:userId password:password block:^(AVUser *user, NSError *error) {
      if (user) {
        [self dismissViewControllerAnimated:YES completion:nil];
      } else {
        NSString *aString = @"发生了错误";
        if ([[error userInfo][@"code"] integerValue] == 210) {
          aString = @"用户名与密码不匹配";
        } else if ([[error userInfo][@"code"] integerValue] == 211) {
          aString = @"找不到该用户";
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:aString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
          [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
      }
    }];
  } else {
    UserModel *user = [UserModel user];
    user.username = userName;
    user.password = password;
    if ([userId containsString:@"@"]) {
      user.email = userId;
    } else {
      user.mobilePhoneNumber = userId;
    }
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      if (succeeded) {
        [self hintAnimation:@"注册成功"];
        [AVUser logInWithUsername:user.username password:user.password error:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
      } else {
        [self hintAnimation:[error userInfo][@"error"]];
      }
    }];
  }
  
}

- (IBAction)inOrOut:(id)sender {
  _inOrOut = !_inOrOut;
  self.nameTextField.hidden = _inOrOut;
  if (_inOrOut) {
    [self.idTextField becomeFirstResponder];
    [self.navigationItem setTitle:@"登录"];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [self.inOrOutButton setTitle:@"还未注册？点击" forState:UIControlStateNormal];
  } else {
    [self.nameTextField becomeFirstResponder];
    [self.navigationItem setTitle:@"注册"];
    [self.loginButton setTitle:@"注册" forState:UIControlStateNormal];
    [self.inOrOutButton setTitle:@"已经注册？点击" forState:UIControlStateNormal];
  }
}

- (void)doCancel {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hintAnimation:(NSString *)hint {
  UIButton *hintButton = [UIButton buttonWithType:UIButtonTypeCustom];
  hintButton.frame = CGRectMake(0, -64, self.view.frame.size.width, 64);
  hintButton.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
  [hintButton setTitle:hint forState:UIControlStateNormal];
  [hintButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  hintButton.titleLabel.textAlignment = NSTextAlignmentCenter;
  hintButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:19];
  [self.view addSubview:hintButton];
  
  [UIView animateWithDuration:0.2 animations:^{
    hintButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.2 delay:2.0 options:(UIViewAnimationOptionBeginFromCurrentState) animations:^{
      hintButton.frame = CGRectMake(0, -64, self.view.frame.size.width, 64);
    } completion:^(BOOL finished){
      [hintButton removeFromSuperview];
    }];
  }];
}
#pragma mark - textFieldDelegate
- (IBAction)nameEndEdit:(id)sender {
  [self.idTextField becomeFirstResponder];
}

- (IBAction)idEndEdit:(id)sender {
  [self.passwordTextField becomeFirstResponder];
}

- (IBAction)passwordEndEdit:(id)sender {
  [self.passwordTextField resignFirstResponder];
}

#pragma mark - init
- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:(UIBarButtonItemStylePlain) target:self action:@selector(doCancel)];
  [self.navigationItem setLeftBarButtonItem:leftBarButton animated:YES];
  
  _inOrOut = YES;
  self.nameTextField.hidden = _inOrOut;
  self.loginButton.layer.cornerRadius = 8.0;
}




@end
