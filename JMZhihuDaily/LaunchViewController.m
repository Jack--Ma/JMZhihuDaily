//
//  LaunchViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/8.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "LaunchViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface LaunchViewController () <JSAnimatedImagesViewDataSource>

@property (nonatomic, weak) IBOutlet JSAnimatedImagesView *animatedImagesView;
@property (nonatomic, weak) IBOutlet UILabel *text;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //如果已有下载好的文字则使用
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"launchTextKey"]) {
    self.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"launchTextKey"];
  }
  
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://news-at.zhihu.com/api/4/start-image/1080*1776"]];
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  operation.responseSerializer = [AFJSONResponseSerializer serializer];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    NSDictionary *data = responseObject;
    //拿到text并保存
    NSString *test = data[@"text"];
    self.text.text = test;
    [[NSUserDefaults standardUserDefaults] setObject:test forKey:@"launchTextKey"];
    
    //拿到图像URL后取出图像并保存
    NSString *img = data[@"img"];
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:img]];
    AFHTTPRequestOperation *imgOperation = [[AFHTTPRequestOperation alloc] initWithRequest:imgRequest];
    [imgOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
      NSData *data = responseObject;
      [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"launchImgKey"];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
      NSLog(@"%@", error);
      return;
    }];
    [imgOperation start];
  } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    NSLog(@"%@", error);
    return;
  }];
  [operation start];
  
  //设置自己为JSAnimatedImagesView的数据源
  self.animatedImagesView.dataSource = self;
  
  //半透明遮罩层
  UIView *blurView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 3 * 2, self.view.frame.size.width, self.view.frame.size.height / 3)];
  [self.animatedImagesView addSubview: blurView];
  
  //渐变遮罩层
  GradientView *gradientView = [[GradientView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 3 * 2, self.view.frame.size.width, self.view.frame.size.height / 3) type:TRANSPARENT_GRADIENT_TYPE];
  [self.animatedImagesView addSubview:gradientView];
  
  //遮罩层透明度渐变
  [UIView animateWithDuration:2.5 animations:^{
    blurView.backgroundColor = [UIColor clearColor];
  }];
}

- (NSUInteger)animatedImagesNumberOfImages:(JSAnimatedImagesView *)animatedImagesView {
  return 2;
}

- (UIImage *)animatedImagesView:(JSAnimatedImagesView *)animatedImagesView imageAtIndex:(NSUInteger)index {
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"launchImgKey"]) {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"launchImgKey"];
    return [UIImage imageWithData:data];
  }
  return [UIImage imageNamed:@"DemoLaunchImage"];
}
@end
