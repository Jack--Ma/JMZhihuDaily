//
//  JMPullRefreshTableViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/20.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "JMPullRefreshTableViewController.h"
#import "SCBubbleRefreshView.h"

#define kBubbleAnimation
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

static CGFloat const kRefreshHeight = 44.0f;

@interface JMPullRefreshTableViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *tableFooterView;

@property (nonatomic, strong) SCBubbleRefreshView *loadMoreView;

@property (nonatomic, assign) BOOL isLoadingMore;

@property (nonatomic, assign) BOOL hadLoadMore;
@property (nonatomic, assign) CGFloat dragOffsetY;

@end

@implementation JMPullRefreshTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.isLoadingMore = NO;
    self.hadLoadMore = NO;
    
    self.tableViewInsertBottom = 0;
  }
  return self;
}

- (void)loadView {
  // bubble animation
  self.tableFooterView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
  self.loadMoreView = [[SCBubbleRefreshView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 44}];
  self.loadMoreView.timeOffset = 0.0;
  [self.tableFooterView addSubview:self.loadMoreView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // LoadMore
  if ((self.loadMoreBlock && scrollView.contentSizeHeight > 300) || !self.hadLoadMore) {
    self.loadMoreView.hidden = NO;
  } else {
    self.loadMoreView.hidden = YES;
  }
  
  if (scrollView.contentSizeHeight + scrollView.contentInsetTop < [UIScreen mainScreen].bounds.size.height) {
    return;
  }
  
  CGFloat loadMoreOffset = - (scrollView.contentSizeHeight - self.view.height - scrollView.contentOffsetY + scrollView.contentInsetBottom);
  
  if (loadMoreOffset > 0) {
    self.loadMoreView.timeOffset = MAX(loadMoreOffset / 60.0, 0);
  } else {
    self.loadMoreView.timeOffset = 0;
  }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  self.dragOffsetY = scrollView.contentOffsetY;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  // loadMore
  CGFloat loadMoreOffset = scrollView.contentSizeHeight - self.view.height - scrollView.contentOffsetY + scrollView.contentInsetBottom;
  if (loadMoreOffset < -60 && self.loadMoreBlock && !self.isLoadingMore && scrollView.contentSizeHeight > [UIScreen mainScreen].bounds.size.height) {
    [self beginLoadMore];
  }
}

#pragma mark - Public Methods
- (void)beginLoadMore {
  [self.loadMoreView beginRefreshing];
  
  self.isLoadingMore = YES;
  self.hadLoadMore = YES;
  
  if (self.loadMoreBlock) {
    self.loadMoreBlock();
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
      self.tableView.contentInsetBottom = kRefreshHeight + self.tableViewInsertBottom;
    } completion:^(BOOL finished){
      
    }];
  });
}

- (void)endLoadMore {
  [self.loadMoreView endRefreshing];
  self.isLoadingMore = NO;
  
  [UIView animateWithDuration:0.2 animations:^{
    self.tableView.contentInsetBottom =  + self.tableViewInsertBottom;
  }];
  
}

- (void)setLoadMoreBlock:(void (^)())loadMoreBlock {
  _loadMoreBlock = loadMoreBlock;
  
  if (self.loadMoreBlock && self.tableView) {
    self.tableView.tableFooterView = self.tableFooterView;
  }
}

@end
