//
//  WebViewController.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/8.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger newsId;
@property (nonatomic, assign) BOOL isTopStory;
@property (nonatomic, assign) BOOL isThemeStory;

@end
