//
//  userInfoCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/14.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "UserInfoCell.h"

@implementation UserInfoCell {
  UIView *_btnLine;
}

- (void)awakeFromNib {
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  //添加分割线
  [_btnLine removeFromSuperview];
  _btnLine = [[UIView alloc] initWithFrame:CGRectMake(20.0, 43.0, [UIScreen mainScreen].bounds.size.width-35, 1.0)];
  [self.contentView addSubview:_btnLine];
  if (temp) {
    _btnLine.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1];
    self.textLabel.textColor = [UIColor colorWithRed:19.0f/255.0f green:26.0f/255.0f blue:32.0f/255.0f alpha:1];
    self.backgroundColor = [UIColor whiteColor];
  } else {
    _btnLine.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1];
    self.textLabel.textColor = [UIColor lightGrayColor];
    self.backgroundColor = [UIColor colorWithRed:61.0f/255.0f green:60.0f/255.0f blue:64.0f/255.0f alpha:1];
  }
}

@end
