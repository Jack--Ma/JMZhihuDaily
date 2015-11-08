//
//  PaletteViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/8.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "PaletteViewController.h"

@implementation PaletteViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  GradientView *gradientMidView = [[GradientView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/3*2, self.view.frame.size.width, self.view.frame.size.height/3) type:TRANSPARENT_GRADIENT_TYPE];
  [self.view addSubview:gradientMidView];
  
}

@end
