//
//  JMCheckView.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/11.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "JMCheckView.h"

@implementation JMCheckView

+ (instancetype)CheckInView:(UIView *)view {
  JMCheckView *checkView = [[JMCheckView alloc] initWithFrame:view.frame];
  checkView.backgroundColor = [UIColor clearColor];
  return checkView;
}

- (void)drawRect:(CGRect)rect {
  const CGFloat boxWidth = 96.0f;//矩形的长和宽
  const CGFloat boxHeight = 96.0f;
  //确定矩形的位置
  CGRect boxRect =  CGRectMake(roundf(self.bounds.size.width - boxWidth)/2.0f,
                               roundf(self.bounds.size.height - boxHeight)/2.0f, boxWidth, boxHeight);
  //绘制圆角矩形，提供原始矩形和边缘的角度
  UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
  [[UIColor colorWithWhite:0.3f alpha:0.5f] setFill];
  [roundedRect fill];
  
  //放入图片
  UIImage *image = [UIImage imageNamed:@"Checkmark"];
  CGPoint imagePoint = CGPointMake(self.center.x - roundf(image.size.width/2.0f),
                                   self.center.y - roundf(image.size.height/2.0f) - boxHeight/8.0f);
  [image drawAtPoint:imagePoint];
  //放入label
  NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                               NSForegroundColorAttributeName: [UIColor whiteColor]};
  CGSize textSize = [self.text sizeWithAttributes:attributes];
  CGPoint textPoint = CGPointMake(self.center.x - roundf(textSize.width/2.0f),
                                  self.center.y - roundf(textSize.height/2.0f) + boxHeight/4.0f);
  [self.text drawAtPoint:textPoint withAttributes:attributes];
}

@end
