//
//  ThemeEditorTableViewCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/5.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "ThemeEditorTableViewCell.h"

@implementation ThemeEditorTableViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
  
  self.accessorySign.tintColor = [UIColor colorWithRed:216.0f/255.0f green:216.0f/255.0f blue:216.0f/155.0f alpha:1];
  //添加分割线
  UIView *btmLine = [[UIView alloc] initWithFrame:CGRectMake(0, 44.5, self.frame.size.width, 0.5)];
  btmLine.backgroundColor = [UIColor colorWithRed:216.0f/255.0f green:216.0f/255.0f blue:216.0f/155.0f alpha:1];
  [self.contentView addSubview:btmLine];
}

@end
