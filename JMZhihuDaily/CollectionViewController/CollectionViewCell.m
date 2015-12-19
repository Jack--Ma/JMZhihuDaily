//
//  CollectionViewCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/19.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "CollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserModel.h"

#define StandardWidth [UIScreen mainScreen].bounds.size.width / 2.0
#define CellWidth (StandardWidth - 15.0)
#define CellHeight (CellWidth * 1.25)

@interface CollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) myUILabel *titleLabel;

@end

@implementation CollectionViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  //图片格式
  [self.imageView removeFromSuperview];
  self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CellWidth, CellHeight*0.6)];
  self.imageView.contentMode = UIViewContentModeScaleAspectFill;
  self.imageView.clipsToBounds = YES;
  if ([self.imageURLString isEqualToString:@"NoImage"]) {
    self.imageView.image = [UIImage imageNamed:@"Logo"];
  } else {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageURLString]];
  }
  [self.contentView addSubview:self.imageView];
  
  //文字居上分布
  [self.titleLabel removeFromSuperview];
  self.titleLabel = [[myUILabel alloc] initWithFrame:CGRectMake(0, CellHeight*0.6, CellWidth, CellHeight*0.3)];
  [self.titleLabel setVerticalAlignment:(VerticalAlignmentTop)];
  self.titleLabel.numberOfLines = 0;
  self.titleLabel.font = [UIFont systemFontOfSize:14.0];
  self.titleLabel.text = self.title;
  [self.contentView addSubview:self.titleLabel];
  
  //取消收藏的button
  [self.button removeFromSuperview];
  self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  self.button.frame = CGRectMake(0, CellHeight*0.9-10.0, CellWidth, CellHeight*0.1);
  [self.button setTitle:@"取消收藏" forState:UIControlStateNormal];
  [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [self.contentView addSubview:self.button];
  
  if (temp) {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.titleLabel.textColor = [UIColor blackColor];
    self.button.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:171.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
  } else {
    self.contentView.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:51.0/255.0 blue:55.0/255.0 alpha:1];
    self.titleLabel.textColor = [UIColor lightGrayColor];
    self.button.backgroundColor = [UIColor colorWithRed:69.0f/255.0f green:68.0f/255.0f blue:72.0f/255.0f alpha:1.0f];
  }
  
}

@end
