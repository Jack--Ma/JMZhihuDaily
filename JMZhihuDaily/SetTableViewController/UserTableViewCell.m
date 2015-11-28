//
//  UserTableViewCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/27.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "UserTableViewCell.h"
#import "UserModel.h"

@interface UserTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;

@end

@implementation UserTableViewCell

- (void)awakeFromNib {
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if ([UserModel currentUser]) {
    NSData *data = [[UserModel currentUser].avatar getData];
    UIImage *avatar = [UIImage imageWithData:data];
    self.avatarView.image = avatar;
    
    NSString *name = [UserModel currentUser].username;
    self.nameLabel.text = name;
    
    NSString *detail = [UserModel currentUser].selfDescription;
    self.detailLabel.text = detail;
  } else {
    self.nameLabel.text = @"我的资料";
    self.detailLabel.text = @"未登录";
  }
  self.avatarView.layer.cornerRadius = 30.0;
  self.contentMode = UIViewContentModeScaleAspectFill;
  self.avatarView.clipsToBounds = YES;
  
  if (temp) {
    self.backgroundColor = [UIColor whiteColor];
    self.nameLabel.textColor = [UIColor blackColor];
    
  } else {
    self.backgroundColor = [UIColor colorWithRed:61.0f/255.0f green:60.0f/255.0f blue:64.0f/255.0f alpha:1];
    self.nameLabel.textColor = [UIColor lightTextColor];
  }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
