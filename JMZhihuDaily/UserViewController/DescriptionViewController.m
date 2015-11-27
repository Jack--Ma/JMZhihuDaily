//
//  DescriptionViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/16.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "DescriptionViewController.h"
#import "UserInfoViewController.h"
#import "UserModel.h"

@interface DescriptionViewController () <UITextViewDelegate, UITextInputTraits>

@end

@implementation DescriptionViewController {
  UITextView *_textView;
  UILabel *_numberLabel;
}

- (void)backtoLastView {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)makesure{
  if (_textView.text.length > 50) {
    [self hintAnimation];
    return;
  }
  [_textView resignFirstResponder];
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"签名" message:@"确定修改签名吗？" preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    self.signature = _textView.text;
    [UserModel currentUser].selfDescription = self.signature;
    [[UserModel currentUser] setObject:self.signature forKey:@"selfDescription"];
    [[UserModel currentUser] saveInBackground];
    [self.navigationController popViewControllerAnimated:YES];
  }];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    [alert dismissViewControllerAnimated:YES completion:nil];
  }];
  [alert addAction:cancel];
  [alert addAction:ok];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)hintAnimation {
  UIButton *hintButton = [UIButton buttonWithType:UIButtonTypeCustom];
  hintButton.frame = CGRectMake(0, -64, self.view.frame.size.width, 64);
  hintButton.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
  [hintButton setTitle:@"签名不能超过50个字符" forState:UIControlStateNormal];
  [hintButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  hintButton.titleLabel.textAlignment = NSTextAlignmentCenter;
  hintButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:19];
  [self.navigationController.view addSubview:hintButton];

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

#pragma mark - UITextViewDelegate
- (void) textViewDidBeginEditing:(UITextView *)textView {
  NSInteger num = 50 - textView.text.length;
  _numberLabel.text = [NSString stringWithFormat:@"%ld", (long)num];
}

- (void) textViewDidChange:(UITextView *)textView {
  NSInteger num = 50 - textView.text.length;
  _numberLabel.text = [NSString stringWithFormat:@"%ld", (long)num];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  //禁止输入换行符
  if ([text isEqualToString:@"\n"]) {
    [self makesure];
    return NO;
  }
  return YES;
}

#pragma mark - init
- (void)viewDidLoad {
  [super viewDidLoad];
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (temp) {
    self.view.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    _textView.textColor = [UIColor blackColor];
  } else {
    self.view.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorWithRed:69.0f/255.0f green:68.0f/255.0f blue:72.0f/255.0f alpha:1.0f]];
    _textView.textColor = [UIColor lightGrayColor];
  }
  
  //设置navBav格式
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  //设置返回button，手势，确定button和title
  UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftArrow"] style:(UIBarButtonItemStylePlain) target:self action:@selector(backtoLastView)];
  leftBarButton.tintColor = [UIColor whiteColor];
  [self.navigationItem setLeftBarButtonItem:leftBarButton];
  
  self.navigationController.interactivePopGestureRecognizer.enabled = YES;
  self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
  
  UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(makesure)];
  rightButton.tintColor = [UIColor whiteColor];
  [self.navigationItem setRightBarButtonItem:rightButton];
  
  [self.navigationItem setTitle:@"修改签名"];
  
  //设置签名的TextView
  _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 75, self.view.frame.size.width-20, 120) textContainer:nil];
  _textView.text = self.signature;
  _textView.font = [UIFont systemFontOfSize:15];
  _textView.scrollEnabled = NO;
  _textView.delegate = self;
  _textView.returnKeyType = UIReturnKeyDone;
  _textView.keyboardAppearance = UIKeyboardAppearanceDark;
  if (temp) {
    _textView.keyboardAppearance = UIKeyboardAppearanceLight;
  }
  [self.view addSubview:_textView];
  [_textView becomeFirstResponder];
  
  //夜间时设置textView为黑色背景白色字体
  if (!temp) {
    _textView.backgroundColor = [UIColor colorWithRed:69.0f/255.0f green:68.0f/255.0f blue:72.0f/255.0f alpha:1.0f];
    _textView.textColor = [UIColor whiteColor];
  }
  
  //设置字数统计Label
  _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(_textView.frame.size.width-40, _textView.frame.size.height-35, 40, 35)];
  _numberLabel.textColor = [UIColor lightGrayColor];
  _numberLabel.font = [UIFont systemFontOfSize:17];
  _numberLabel.textAlignment = NSTextAlignmentCenter;
  [_textView addSubview:_numberLabel];
  
  //设置字数提醒Label
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 150, 20)];
  label.text = @"注：请不要超过最大长度50";
  label.font = [UIFont systemFontOfSize:11];
  label.textColor = [UIColor lightGrayColor];
  [self.view addSubview:label];
}

@end
