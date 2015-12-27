//
//  CommentTableViewCell.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/25.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "CommentTableViewCell.h"
#import "JMCheckView.h"

@interface CommentTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet myUILabel *commentLabel;
@property (nonatomic, strong) UIMenuController *menuController;

@end

@implementation CommentTableViewCell {
  BOOL _isLike;
  UIView *_lineView;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  
  [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.commentDic[@"avatar"]]];
  self.nameLabel.text = self.commentDic[@"author"];
  NSString *dateString = [self switchDate:(self.commentDic[@"time"])];
  self.timeLabel.text = dateString;
  self.likesLabel.text = [NSString stringWithFormat:@"%d", (int)(self.commentDic[@"likes"])];
  self.commentLabel.text = self.commentDic[@"content"];
  self.commentLabel.verticalAlignment = VerticalAlignmentTop;
  
  //添加手势，单出menuItem列表
  _isLike = NO;
  UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
  [self addGestureRecognizer:tapGest];
  
  //下方添加分割线
  //待实现
  
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  if (!temp) {
    self.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:51.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
    self.nameLabel.textColor = [UIColor lightGrayColor];
    self.timeLabel.textColor = [UIColor darkGrayColor];
    self.likesLabel.textColor = [UIColor darkGrayColor];
    self.commentLabel.textColor = [UIColor lightGrayColor];
  }
}

- (NSString *)switchDate:(NSNumber *)dateNum {
  NSTimeInterval time = dateNum.longValue;
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  df.dateFormat = @"YYYY-MM-dd HH:mm:ss";
  NSTimeZone *zone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
  df.timeZone = zone;
  
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
  return [df stringFromDate:date];
}

#pragma mark - menuController
- (void)tapAction:(UITapGestureRecognizer *)gesture {
  [self becomeFirstResponder];
  self.menuController = [UIMenuController sharedMenuController];
  UIMenuItem *likeItem = [[UIMenuItem alloc] initWithTitle:@"点赞" action:@selector(likeComment)];
  UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyComment)];
  if (_isLike) {
    [likeItem setTitle:@"取消点赞"];
  }
  self.menuController.menuItems = @[likeItem, copyItem];
  [self.menuController setTargetRect:gesture.view.frame inView:gesture.view.superview];
  [self.menuController setMenuVisible:YES animated:YES];
}

- (void)likeComment {
  if (_isLike) {
    self.likesLabel.text = [NSString stringWithFormat:@"%d", (int)(self.commentDic[@"likes"])];
    self.likesLabel.textColor = [UIColor lightGrayColor];
    BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
    if (!temp) {
      self.likesLabel.textColor = [UIColor darkGrayColor];
    }
  } else {
    self.likesLabel.text = [NSString stringWithFormat:@"%d", (int)(self.commentDic[@"likes"])+1];
    self.likesLabel.textColor = [UIColor orangeColor];
  }
  _isLike = !_isLike;
}

- (void)copyComment {
  [UIPasteboard generalPasteboard].string = self.commentLabel.text;
  
  JMCheckView *checkView = [JMCheckView CheckInView:self.window];
  checkView.text = @"复制成功";
  [self.window addSubview:checkView];
  checkView.alpha = 0.0f;
  checkView.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
  
  [UIView animateWithDuration:0.2 animations:^{
    checkView.alpha = 1.0f;
    checkView.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.3 delay:0.5 options:(UIViewAnimationOptionShowHideTransitionViews) animations:^{
      checkView.alpha = 0.0f;
    } completion:^(BOOL finished) {
      [checkView removeFromSuperview];
    }];
  }];
}

- (BOOL)canBecomeFirstResponder {
  return YES;
}

//设置只显示点赞与复制Item
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  if (action == @selector(likeComment)) {
    return YES;
  }
  if (action == @selector(copyComment)) {
    return YES;
  }
  return NO;
}

@end
