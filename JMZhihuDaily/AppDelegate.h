//
//  AppDelegate.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/3.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import <WeiboSDK/WeiboSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate, WeiboSDKDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

