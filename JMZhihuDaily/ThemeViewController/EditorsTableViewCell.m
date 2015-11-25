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

@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;

@end

@implementation EditorsTableViewCell

- (id)initWithAvatar:(NSString *)avatar andName:(NSString *)name andDetail:(NSString *)detail {
  self = [super init];
  self.avatar = avatar;
  self.name = name;
  self.detail = detail;
  [self awakeFromNib];
  return self;
}

- (void)awakeFromNib {
  self.selectionStyle = UITableViewCellSelectionStyleGray;
  
  //分割线
  UIImageView *separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, 49.5, [UIScreen mainScreen].bounds.size.width-10, 0.5)];
  [separatorLine setBackgroundColor:[UIColor lightGrayColor]];
  [self.contentView addSubview:separatorLine];
  
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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

}

@end
