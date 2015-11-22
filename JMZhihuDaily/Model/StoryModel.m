//
//  StoryModel.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/17.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "StoryModel.h"

static NSOperationQueue *queue = nil;
static int dataNum = 0;

@implementation StoryModel

#pragma mark - 公共方法
- (void)getData {
  queue = [[NSOperationQueue alloc] init];
  queue.maxConcurrentOperationCount = 1;
  [self getTodayData];
  [self getThemesData];
  [queue waitUntilAllOperationsAreFinished];
}
- (void)refreshData {
  NSString *urlString = @"http://news-at.zhihu.com/api/4/news/latest";
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    //刷新本日头条和文章列表
    NSDictionary *data = responseObject;
    
    self.topStory = [[NSMutableArray alloc] initWithArray:data[@"top_stories"] copyItems:YES];
    self.contentStory = [[NSMutableArray alloc] initWithArray:data[@"stories"] copyItems:YES];
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    
  }];
  [operation start];
}
- (void)loadNewData {
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:dataNum]];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    [self setPastStory:responseObject Index:dataNum+1];
    dataNum++;
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"%@", error);
    return;
  }];
  [operation start];
}
#pragma mark - 私有方法
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
    [self getPastData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"todayDataGet" object:nil];
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"%@", error);
    return;
  }];
  [operation start];
}
- (void)getPastData {
  //昨天的数据获取
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:dataNum]];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    [self setPastStory:responseObject Index:dataNum+1];
    dataNum++;
    //前天的数据获取
    AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:dataNum]];
    operation1.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
      [self setPastStory:responseObject Index:dataNum+1];
      dataNum++;
      //发送pastDataGet通知
      [[NSNotificationCenter defaultCenter] postNotificationName:@"pastDataGet" object:nil];
      
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
      NSLog(@"%@", error);
      return;
    }];
    [queue addOperation:operation1];
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"%@", error);
    return;
  }];
  [queue addOperation: operation];
  
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
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"%@", error);
    return;
  }];
  [operation start];
}

- (NSURLRequest *)getRequest:(NSInteger)index {
  NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
  fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"];
  fmt.dateFormat = @"yyyyMMdd";
  
  NSString *aDayBefore = [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400*index]];
  NSString *urlString = [NSString stringWithFormat:@"http://news.at.zhihu.com/api/4/news/before/%@", aDayBefore];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  return request;
}
- (void)setPastStory:(NSData *)data Index:(NSInteger)index {
  NSDictionary *dic = (NSDictionary *)data;
  //取得文章列表数据
  NSArray *contentStoryData = dic[@"stories"];
  //日期cell数据
  NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
  fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"];
  fmt.dateFormat = @"MM'月'dd'日'";
  NSString *tempDateString = [self getWeek:[NSDate dateWithTimeIntervalSinceNow:-86400*index]];
  tempDateString = [NSString stringWithFormat:@"%@ %@", [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400*index]], tempDateString];
  //设置contentStoty和Number
  [self.pastContentStory addObjectsFromArray:contentStoryData];
  [self.pastStoryNumber addObject:@(contentStoryData.count)];
  //设置Y坐标的长度和标题
  [self.offsetYNumber addObject:@([self.offsetYNumber.lastObject integerValue] + 44 + 93 * contentStoryData.count)];
  [self.offsetYValue addObject:tempDateString];
}
- (NSString *)getWeek:(NSDate *)date {
  NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
  fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"];
  fmt.dateFormat = @"EEEE";
  
  return [fmt stringFromDate:date];
}

#pragma mark - 初始化
//类方法，用于获取唯一的Story对象
+ (instancetype)shareStory {
  static StoryModel *shareStory = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    shareStory = [[self alloc] initPrivate];
  });
  return shareStory;
}

//私有方法，用于创建唯一的对象
- (instancetype)initPrivate {
  if ((self = [super init])) {
    _pastContentStory = [NSMutableArray arrayWithCapacity:1];
    _pastStoryNumber = [NSMutableArray arrayWithCapacity:1];
    _themeContent = [[NSMutableArray alloc] init];
    _firstDisplay = YES;
  }
  return self;
}

//不允许使用init方法创建对象
- (instancetype)init {
  @throw [NSException exceptionWithName:@"init error" reason:@"Please use [StoryModel shareStory]" userInfo:nil];
  return nil;
}
@end
