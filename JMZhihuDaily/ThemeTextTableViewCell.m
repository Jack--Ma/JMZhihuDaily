//
//  ThemeTextTableViewCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/5.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "ThemeTextTableViewCell.h"

@implementation ThemeTextTableViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
  
//  [self.themeTitleLabel setVerticalAlignment:(VerticalAlignmentTop)];
  //添加分割线
  UIView *btmLine = [[UIView alloc] initWithFrame:CGRectMake(15, 91, self.frame.size.width-30, 1)];
  btmLine.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/155.0f alpha:1];
  [self.contentView addSubview:btmLine];
}

@end
