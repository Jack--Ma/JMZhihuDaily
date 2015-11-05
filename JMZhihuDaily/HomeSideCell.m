
//
//  HomeSideCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/4.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "HomeSideCell.h"

@implementation HomeSideCell

- (void)awakeFromNib {
  [super awakeFromNib];
  //设置cell初始状态
  self.contentView.backgroundColor = [UIColor colorWithRed:19.0f/255.0f green:26.0f/255.0f blue:32.0f/255.0f alpha:1];
  self.homeTitleLabel.textColor = [UIColor lightGrayColor];
  self.homeImageView.tintColor = [UIColor lightGrayColor];
  self.homeSwitchImageView.tintColor = [UIColor lightGrayColor];
  
  UIView *selectedBackView = [[UIView alloc] initWithFrame:self.bounds];
  selectedBackView.backgroundColor = [UIColor colorWithRed:12.0f/255.0f green:19.0f/255.0f blue:25.0f/255.0f alpha:1];
  self.selectedBackgroundView = selectedBackView;
  self.homeTitleLabel.highlightedTextColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  
}
@end
