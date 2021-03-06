//
//  TableContentViewCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/4.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "TableContentViewCell.h"

@implementation TableContentViewCell {
  UIView *_btmLine;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  
  //添加分割线
  [_btmLine removeFromSuperview];
  _btmLine = [[UIView alloc] initWithFrame:CGRectMake(20, 92.6f, self.frame.size.width - 30, 1)];
  if (temp) {
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    _btmLine.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/155.0f alpha:1];
  } else {
    [self.contentView setBackgroundColor:[UIColor colorWithRed:52.0/255.0 green:51.0/255.0 blue:55.0/255.0 alpha:1]];
    _btmLine.backgroundColor = [UIColor colorWithRed:49.0/255.0 green:48.0/255.0 blue:52.0/255.0 alpha:1];
  }
  [self.contentView addSubview:_btmLine];
  //图片格式设置
  self.imagesView.contentMode = UIViewContentModeScaleAspectFit;
}

@end
