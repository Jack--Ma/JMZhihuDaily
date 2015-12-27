//
//  AppDelegate.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/3.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <AVOSCloud/AVOSCloud.h>
#import "UserModel.h"
#import "JMCheckView.h"

#define AVOSCloudAppID  @"uSM1CbTx40OXA9r3BmhGMlj7"
#define AVOSCloudAppKey @"BT076YAKsGX6qkemmdVAya6d"

#define WeChatAppID @"wxd590c71b8bdb8dc3"
#define WeiboAppID @"1369443078"

@implementation AppDelegate{

}

#pragma mark -
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  //设置AVOSCloud
  [UserModel registerSubclass];
  [AVOSCloud setApplicationId:AVOSCloudAppID clientKey:AVOSCloudAppKey];
  
  //统计应用启动情况
  [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
  
  //获取用户信息
  if ([UserModel currentUser]) {
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    AVObject *post = [query getObjectWithId:[[UserModel currentUser] objectId]];
    [UserModel currentUser].age = [[post objectForKey:@"age"] integerValue];
    [UserModel currentUser].birthday = [post objectForKey:@"birthday"];
    [UserModel currentUser].gender = [[post objectForKey:@"gender"] integerValue];
    [UserModel currentUser].selfDescription = [post objectForKey:@"selfDescription"];
    [UserModel currentUser].avatar = [post objectForKey:@"avatar"];
    NSArray *array = [post objectForKey:@"articlesList"];
    [UserModel currentUser].articlesList = [NSMutableArray arrayWithArray:array];
  }
  
  //注册微信分享
  [WXApi registerApp:WeChatAppID];
  
  //注册微博分享
//  [WeiboSDK enableDebugMode:YES];
  [WeiboSDK registerApp:WeiboAppID];

  //单例获取本日所有内容
  [[StoryModel shareStory] getData];
  
  //设置应用启动浏览模式
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  [[NSUserDefaults standardUserDefaults] setBool:temp forKey:@"isDay"];
  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//  NSLog(@"%@", url);
  if ([url.scheme isEqualToString:@"wxd590c71b8bdb8dc3"]) {
    return [WXApi handleOpenURL:url delegate:self];
  }
  if ([url.scheme isEqualToString:@"wb1369443078"]) {
    return [WeiboSDK handleOpenURL:url delegate:self];
  }
  return nil;
}

- (void)onResp:(BaseResp *)resp {
  if (resp.errCode == 0) {
    [self shareSuccess:@"分享成功"];
  } else {
    NSLog(@"error: %d", resp.errCode);
  }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
  
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
  if (response.statusCode == 0) {
    [self shareSuccess:@"分享成功"];
  } else {
    NSLog(@"error: %ld", (long)response.statusCode);
  }
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  BOOL temp = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDay"];
  [[NSUserDefaults standardUserDefaults] setBool:temp forKey:@"isDay"];
}

- (void)shareSuccess: (NSString *)title {
  JMCheckView *checkView = [JMCheckView CheckInView:self.window];
  checkView.text = title;
  [self.window addSubview:checkView];
  checkView.alpha = 0.0f;
  checkView.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
  
  [UIView animateWithDuration:0.2 delay:0.7 options:(UIViewAnimationOptionLayoutSubviews) animations:^{
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
@end
