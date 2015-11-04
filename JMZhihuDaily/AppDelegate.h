//
//  AppDelegate.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/3.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSMutableArray *topStory;
@property (nonatomic, strong) NSMutableArray *contentStory;
@property (nonatomic, strong) NSMutableArray *pastContentStory;
@property (nonatomic, strong) NSMutableArray *offsetYNumber;
@property (nonatomic, strong) NSMutableArray *offsetYValue;

@property (nonatomic, strong) NSMutableArray *themes;

@property (nonatomic, assign) BOOL firstDisplay;
@end

