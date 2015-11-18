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

@implementation StoryModel

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
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"%@", error);
    return;
  }];
  [operation start];
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
    //昨天的contentStoty
    self.pastContentStory = [[NSMutableArray alloc] initWithArray:contentStoryData copyItems:YES];
    //设置昨天Y坐标的长度和昨天的标题
    [self.offsetYNumber addObject:@([self.offsetYNumber.lastObject integerValue] + 44 + 93 * contentStoryData.count)];
    [self.offsetYValue addObject:tempDateString];
    /*
     *前天的数据获取
     */
    NSString *twoDayDefore = [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400]];
    NSString  *urlString = [NSString stringWithFormat:@"http://news.at.zhihu.com/api/4/news/before/%@", twoDayDefore];
    NSURL  *url = [NSURL URLWithString:urlString];
    NSURLRequest  *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation1.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation1 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
      NSDictionary *data = responseObject;
      //取得文章列表数据
      NSArray *contentStoryData = data[@"stories"];
      //前一天日期cell数据
      NSString *tempDateString = [NSString stringWithFormat:@"%@ %@", [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400*2]], @"前天"];
      //将前天的内容加入pastContentStory
      [self.pastContentStory addObjectsFromArray:contentStoryData];
      //设置前天Y坐标的长度和前天的标题
      [self.offsetYNumber addObject:@([self.offsetYNumber.lastObject integerValue] + 44 + 93 * contentStoryData.count)];
      [self.offsetYValue addObject:tempDateString];
      /*
       *大前天的数据获取
       */
      NSString *threeDayDefore = [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400*2]];
      NSString  *urlString = [NSString stringWithFormat:@"http://news.at.zhihu.com/api/4/news/before/%@", threeDayDefore];
      NSURL  *url = [NSURL URLWithString:urlString];
      NSURLRequest  *request = [NSURLRequest requestWithURL:url];
      
      AFHTTPRequestOperation *operation2 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
      operation2.responseSerializer = [AFJSONResponseSerializer serializer];
      [operation2 setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary *data = responseObject;
        //取得文章列表数据
        NSArray *contentStoryData = data[@"stories"];
        //前一天日期cell数据
        NSString *tempDateString = [NSString stringWithFormat:@"%@ %@", [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-86400*3]], @"大前天"];
        //将前天的内容加入pastContentStory
        [self.pastContentStory addObjectsFromArray:contentStoryData];
        //设置前天Y坐标的长度和前天的标题
        [self.offsetYNumber addObject:@([self.offsetYNumber.lastObject integerValue] + 30 + 93 * contentStoryData.count)];
        [self.offsetYValue addObject:tempDateString];
      } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        return;
      }];
      [queue addOperation:operation2];
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
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"%@", error);
    return;
  }];
  [operation start];
}

- (void)getData {
  queue = [[NSOperationQueue alloc] init];
  queue.maxConcurrentOperationCount = 1;
  [self getTodayData];
  [self getPastData];
  [self getThemesData];
  [queue waitUntilAllOperationsAreFinished];
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
