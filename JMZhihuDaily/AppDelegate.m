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

@end

@implementation AppDelegate{

}

#pragma mark - about data
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
    
//    NSLog(@"数据获取成功：%@   %@", self.offsetYNumber[0], self.offsetYValue[0]);
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
  /*
   *昨天的数据获取
   */
  NSString *aDayBefore = [fmt stringFromDate:[NSDate date]];
  NSString *urlString = [NSString stringWithFormat:@"http://news.at.zhihu.com/api/4/news/before/%@", aDayBefore];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSDictionary *data = responseObject;
    //取得文章列表数据
    NSArray *contentStoryData = data[@"stories"];
    //昨天日期cell数据
    NSString *tempDateString = [NSString stringWithFormat:@"%@ %@", [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400]], @"昨天"];
//    NSLog(@"%@", tempDateString);
    //昨天的contentStoty
    self.pastContentStory = [[NSMutableArray alloc] initWithArray:contentStoryData copyItems:YES];
    //设置昨天Y坐标的长度和昨天的标题
    [self.offsetYNumber addObject:@([self.offsetYNumber.lastObject integerValue] + 30 + 93 * contentStoryData.count)];
    [self.offsetYValue addObject:tempDateString];
    
//    NSLog(@"%@   %@",self.offsetYNumber, self.offsetYValue);
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"数据获取失败");
    return;
  }];
  /*
   *前天的数据获取
   */
  NSString *twoDayDefore = [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400]];
  urlString = [NSString stringWithFormat:@"http://news.at.zhihu.com/api/4/news/before/%@", twoDayDefore];
  url = [NSURL URLWithString:urlString];
  request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation1.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSDictionary *data = responseObject;
    //取得文章列表数据
    NSArray *contentStoryData = data[@"stories"];
    //前一天日期cell数据
    NSString *tempDateString = [NSString stringWithFormat:@"%@ %@", [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400*2]], @"前天"];
//    NSLog(@"%@", tempDateString);
    //将前天的内容加入pastContentStory
    [self.pastContentStory addObjectsFromArray:contentStoryData];
    //设置前天Y坐标的长度和前天的标题
    [self.offsetYNumber addObject:@([self.offsetYNumber.lastObject integerValue] + 30 + 93 * contentStoryData.count)];
    [self.offsetYValue addObject:tempDateString];
//    NSLog(@"%@   %@", self.offsetYNumber, self.offsetYValue);
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"数据获取失败");
    return;
  }];
  /*
   *大前天的数据获取
   */
  NSString *threeDayDefore = [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400*2]];
  urlString = [NSString stringWithFormat:@"http://news.at.zhihu.com/api/4/news/before/%@", threeDayDefore];
  url = [NSURL URLWithString:urlString];
  request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation2 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation2.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSDictionary *data = responseObject;
    //取得文章列表数据
    NSArray *contentStoryData = data[@"stories"];
    //前一天日期cell数据
    NSString *tempDateString = [NSString stringWithFormat:@"%@ %@", [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400*3]], @"大前天"];
//    NSLog(@"%@", tempDateString);
    //将前天的内容加入pastContentStory
    [self.pastContentStory addObjectsFromArray:contentStoryData];
    //设置前天Y坐标的长度和前天的标题
    [self.offsetYNumber addObject:@([self.offsetYNumber.lastObject integerValue] + 30 + 93 * contentStoryData.count)];
    [self.offsetYValue addObject:tempDateString];
//    NSLog(@"%@   %@", self.offsetYNumber, self.offsetYValue);
    
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"数据获取失败");
    return;
  }];
  [queue addOperations:@[operation, operation1, operation2] waitUntilFinished:YES];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"pastDataGet" object:nil];
}
- (void)getThemesData{
  NSString *urlString = @"http://news-at.zhihu.com/api/4/themes";
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSArray *data = responseObject[@"others"];
    self.themes = [[NSMutableArray alloc] initWithArray:data copyItems:YES];
//    NSLog(@"%@", self.themes[0][@"description"]);
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"数据获取失败");
    return;
  }];
  
  [queue addOperation:operation];
}

#pragma mark -
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//  [self.window makeKeyAndVisible];
  queue = [[NSOperationQueue alloc] init];
  self.firstDisplay = YES;
  
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
