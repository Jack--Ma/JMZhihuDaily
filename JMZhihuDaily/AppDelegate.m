//
//  AppDelegate.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/3.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import "StoryModel.h"

static NSOperationQueue *queue = nil;

@interface AppDelegate ()

@property (nonatomic, strong) NSMutableArray *topStory;
@property (nonatomic, strong) NSMutableArray *contentStory;
@property (nonatomic, strong) NSMutableArray *pastContentStory;
@property (nonatomic, strong) NSMutableArray *offsetYNumber;
@property (nonatomic, strong) NSMutableArray *offsetYValue;

@end

@implementation AppDelegate{

}

//获取数据函数
- (void)getTodayData {
  NSString *urlString = @"http://news-at.zhihu.com/api/4/news/latest";
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    //本日头条和文章列表
    NSDictionary *data = responseObject;
    
    self.topStory = [[NSMutableArray alloc] initWithArray:data[@"top_stories"] copyItems:YES];
    self.contentStory = [[NSMutableArray alloc] initWithArray:data[@"stories"] copyItems:YES];
    
    self.offsetYNumber = [[NSMutableArray alloc] initWithCapacity:1];
    self.offsetYValue = [[NSMutableArray alloc] initWithCapacity:1];
    [self.offsetYNumber addObject:@(self.contentStory.count * 93 + 120)];
    [self.offsetYValue addObject:@"今日热点"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"todayDataGet" object:nil];
    [self getPastData];
    
    NSLog(@"数据获取成功：%@   %@", self.offsetYNumber[0], self.offsetYValue[0]);
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"数据获取失败");
    return;
  }];
  
  [queue addOperation:operation];
}
- (void)getPastData {
  NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
  fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"];
  fmt.dateFormat = @"yyyyMMdd";
  //当前年月日
  NSString *aDayBefore = [fmt stringFromDate:[NSDate date]];
  //获取昨天的相关内容
  NSString *urlString = [NSString stringWithFormat:@"http://news.at.zhihu.com/api/4/news/before/%@", aDayBefore];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSDictionary *data = responseObject;
    NSArray *contentStoryData = data[@"stories"];
    
    NSString *tempDateString = [NSString stringWithFormat:@"%@ %@", [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400]], @"星期一"];
    NSLog(@"%@", tempDateString);
//    [self.pastContentStory addObject:tempDateString];
    
    self.pastContentStory = [[NSMutableArray alloc] initWithArray:contentStoryData copyItems:YES];
  
    [self.offsetYNumber addObject:@([self.offsetYNumber.lastObject integerValue] + 30 + 93 * contentStoryData.count)];
    [self.offsetYValue addObject:tempDateString];
    NSLog(@"%@   %@",self.offsetYNumber, self.offsetYValue[1]);
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"数据获取失败");
    return;
  }];
  
  [queue addOperation:operation];
}
- (void)getThemesData{
  
}

#pragma mark -
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//  [self.window makeKeyAndVisible];
  queue = [[NSOperationQueue alloc] init];
  
  [self getTodayData];
  [self getThemesData];
  return YES;
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
}

#pragma mark - other function

@end
