//
//  CollectionTableViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/12.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "CollectionTableViewController.h"
#import "ThemeTextTableViewCell.h"
#import "ThemeTextWithImageTableViewCell.h"
#import "UserModel.h"
#import "WebViewController.h"

static NSOperationQueue *queue;
static NSMutableArray *imageArray;
static NSMutableArray *idArray;
static NSMutableArray *nameArray;

@interface CollectionTableViewController ()

@end

@implementation CollectionTableViewController {

}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (nameArray.count != [UserModel currentUser].articlesList.count) {
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    [queue waitUntilAllOperationsAreFinished];
    nameArray = [NSMutableArray arrayWithCapacity:0];
    imageArray = [NSMutableArray arrayWithCapacity:0];
    idArray = [NSMutableArray arrayWithCapacity:0];
    [self loadList];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source && delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (nameArray.count == 0) {
    return 0;
  }
  return nameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([imageArray[indexPath.row] isEqualToString:@"NoImage"]) {
    ThemeTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"themeTextTableViewCell"];
    [cell awakeFromNib];
    cell.themeTitleLabel.text = nameArray[indexPath.row];
    return cell;
  } else {
    ThemeTextWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"themeTextWithImageTableViewCell"];
    [cell awakeFromNib];
    cell.themeTitleLabel.text = nameArray[indexPath.row];
    [cell.themeImageView sd_setImageWithURL:[NSURL URLWithString:imageArray[indexPath.row]]];
    return cell;
  }
  return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  //跳转到WebView
  WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
  webViewController.isTopStory = YES;
  webViewController.newsId = [idArray[indexPath.row] integerValue];
  
  [self.navigationController pushViewController:webViewController animated:YES];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
  return @"取消收藏";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [nameArray removeObjectAtIndex:indexPath.row];
    [idArray removeObjectAtIndex:indexPath.row];
    [imageArray removeObjectAtIndex:indexPath.row];
    NSMutableArray *array = [UserModel currentUser].articlesList;
    [array removeObjectAtIndex:indexPath.row];
    [[UserModel currentUser] setObject:array forKey:@"articlesList"];
    [[UserModel currentUser] save];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}

#pragma mark - 私有方法
- (void)loadList {
  NSArray *array = [UserModel currentUser].articlesList;
  for (NSString *string in array) {
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
      NSDictionary *dict = (NSDictionary *)responseObject;
      NSString *name = dict[@"title"];
      NSString *articleId = dict[@"id"];
      NSString *imageURL = dict[@"image"];
      [nameArray addObject:name];
      [idArray addObject:articleId];
      if (imageURL) {
        [imageArray addObject:imageURL];
      } else {
        [imageArray addObject:@"NoImage"];
      }
      
      if (nameArray.count == [UserModel currentUser].articlesList.count) {
        [self.tableView reloadData];
      }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
      NSLog(@"%@", [error userInfo]);
    }];
    [queue addOperation:operation];
  }
}

@end
