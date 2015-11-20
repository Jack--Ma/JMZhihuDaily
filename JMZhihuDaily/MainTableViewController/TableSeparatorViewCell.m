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
  
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  self.contentView.backgroundColor = [UIColor colorWithRed:1.0f/255.0f green:131.0f/255.0f blue:209.0f/255.0f alpha:1.0f];
}

@end
