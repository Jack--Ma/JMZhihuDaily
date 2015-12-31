//
//  SetTableViewCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/28.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "SetTableViewCell.h"

@implementation SetTableViewCell

- (void)awakeFromNib {
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (temp) {
    self.backgroundColor = [UIColor whiteColor];
    self.label.textColor = [UIColor blackColor];
  } else {
    self.backgroundColor = [UIColor colorWithRed:61.0f/255.0f green:60.0f/255.0f blue:64.0f/255.0f alpha:1];;
    self.label.textColor = [UIColor lightGrayColor];
  }
}

@end
