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

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, weak) IBOutlet UITextField *idTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

#pragma mark - other function
- (IBAction)doLogin:(id)sender {
  NSString *userName = self.idTextField.text;
  NSString *password = self.passwordTextField.text;

  [UserModel logInWithUsernameInBackground:userName password:password block:^(AVUser *user, NSError *error) {
    if (user) {
      [self dismissViewControllerAnimated:YES completion:nil];
    }
  }];
}

- (void)doCancel {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - textFieldDelegate
- (IBAction)idEndEdit:(id)sender {
  [self.passwordTextField becomeFirstResponder];
}

- (IBAction)passwordEndEdit:(id)sender {
  [self.passwordTextField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  return YES;
}

#pragma mark - init
- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:(UIBarButtonItemStylePlain) target:self action:@selector(doCancel)];
  [self.navigationItem setLeftBarButtonItem:leftBarButton animated:YES];
  
  self.idTextField.delegate = self;
  self.passwordTextField.delegate = self;
  
  self.loginButton.layer.cornerRadius = 8.0;
}




@end
