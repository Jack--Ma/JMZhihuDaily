//
//  AppDelegate.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/3.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

