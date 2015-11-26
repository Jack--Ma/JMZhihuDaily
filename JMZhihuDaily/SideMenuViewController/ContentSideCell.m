//
//  ContentSideCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/4.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "ContentSideCell.h"

@implementation ContentSideCell

- (void)awakeFromNib {
  [super awakeFromNib];
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  
  self.contentTitleLabel.textColor = [UIColor lightGrayColor];
  self.contentPlusImageView.tintColor = [UIColor lightGrayColor];
  //选中cell后的设置
  UIView *selectedBackView = [[UIView alloc] initWithFrame:self.bounds];
  self.selectedBackgroundView = selectedBackView;
  self.contentTitleLabel.highlightedTextColor = [UIColor whiteColor];
  if (temp) {
    self.contentView.backgroundColor = [UIColor colorWithRed:32.0f/255.0f green:42.0f/255.0f blue:52.0f/255.0f alpha:1];
    selectedBackView.backgroundColor = [UIColor colorWithRed:25.0f/255.0f green:35.0f/255.0f blue:45.0f/255.0f alpha:1];
  } else {
    self.contentView.backgroundColor = [UIColor colorWithRed:31.0f/255.0f green:30.0f/255.0f blue:34.0f/255.0f alpha:1];
    selectedBackView.backgroundColor = [UIColor colorWithRed:25.0f/255.0f green:24.0f/255.0f blue:28.0f/255.0f alpha:1];
  }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  
}
@end
