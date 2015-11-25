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
    self.contentView.backgroundColor = [UIColor colorWithRed:1.0f/255.0f green:131.0f/255.0f blue:209.0f/255.0f alpha:1.0f];
  } else {
    self.contentView.backgroundColor = [UIColor grayColor];
  }
}

@end
