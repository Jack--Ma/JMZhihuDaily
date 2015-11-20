//
//  userInfoCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/14.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "UserInfoCell.h"

@implementation UserInfoCell

- (void)awakeFromNib {
  self.textLabel.textColor = [UIColor colorWithRed:19.0f/255.0f green:26.0f/255.0f blue:32.0f/255.0f alpha:1];
  //添加分割线
  UIView *btmLine = [[UIView alloc] initWithFrame:CGRectMake(20.0, 43.0, self.frame.size.width, 1.0)];
  btmLine.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1];
  [self.contentView addSubview:btmLine];
}

@end
