//
//  EditorsTableViewCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/23.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "EditorsTableViewCell.h"

@interface EditorsTableViewCell ()

@end

@implementation EditorsTableViewCell {
  UIView *_btmLine;
}

- (void)awakeFromNib {
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];

  //分割线
  [_btmLine removeFromSuperview];
  _btmLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, 49.5, [UIScreen mainScreen].bounds.size.width-10, 0.5)];
  [self.contentView addSubview:_btmLine];
  
  //头像
  UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 38, 38)];
  avatar.contentMode = UIViewContentModeScaleAspectFill;
  avatar.layer.cornerRadius = 19;
  avatar.clipsToBounds = YES;
  [avatar sd_setImageWithURL:[NSURL URLWithString:self.avatar]];
  [self.contentView addSubview:avatar];
  
  //ID
  UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 200, 20)];
  [label1 setText:self.name];
  [label1 setFont:[UIFont systemFontOfSize:15]];
  [self.contentView addSubview:label1];
  
  //detail
  UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(60, 28, 200, 20)];
  [label2 setText:self.detail];
  [label2 setFont:[UIFont systemFontOfSize:12]];
  [label2 setTextColor:[UIColor lightGrayColor]];
  [self.contentView addSubview:label2];
  
  //右向箭头
  UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width -30, 15, 20, 20)];
  [arrow setTintColor:[UIColor lightGrayColor]];
  [arrow setImage:[UIImage imageNamed:@"switch"]];
  [self.contentView addSubview:arrow];
  
  if (temp) {
    self.contentView.backgroundColor = [UIColor whiteColor];
    [_btmLine setBackgroundColor:[UIColor lightGrayColor]];
  } else {
    [label1 setTextColor:[UIColor whiteColor]];
    self.contentView.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:51.0/255.0 blue:55.0/255.0 alpha:1];
    [_btmLine setBackgroundColor:[UIColor colorWithRed:49.0/255.0 green:48.0/255.0 blue:52.0/255.0 alpha:1]];
  }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

}

@end
