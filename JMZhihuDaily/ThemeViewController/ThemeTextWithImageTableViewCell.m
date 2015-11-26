//
//  ThemeTextWithImageTableViewCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/5.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "ThemeTextWithImageTableViewCell.h"

@implementation ThemeTextWithImageTableViewCell {
  UIView *_btmLine;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  //文字居上分布
  [self.themeTitleLabel setVerticalAlignment:(VerticalAlignmentTop)];
  
  //添加分割线设置背景颜色
  UIView *btmLine = [[UIView alloc] initWithFrame:CGRectMake(15, 91, self.frame.size.width-30, 1)];
  if (temp) {
    self.contentView.backgroundColor = [UIColor whiteColor];
    _btmLine.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/155.0f alpha:1];
  } else {
    self.contentView.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:51.0/255.0 blue:55.0/255.0 alpha:1];
    _btmLine.backgroundColor = [UIColor colorWithRed:49.0/255.0 green:48.0/255.0 blue:52.0/255.0 alpha:1];
  }
  [self.contentView addSubview:btmLine];
  
  //图片格式
  self.themeImageView.contentMode = UIViewContentModeScaleAspectFit;
  self.themeImageView.clipsToBounds = YES;
}

@end
