//
//  TableSeparatorViewCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/4.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "TableSeparatorViewCell.h"

@implementation TableSeparatorViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  if (temp) {
    self.contentView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
  } else {
    self.contentView.backgroundColor = [UIColor colorWithRed:69.0/255.0 green:68.0/255.0 blue:71.0/255.0 alpha:1];
  }
}

@end
