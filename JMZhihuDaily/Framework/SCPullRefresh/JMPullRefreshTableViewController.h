//
//  JMPullRefreshTableViewController.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/20.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMPullRefreshTableViewController : UITableViewController

@property (nonatomic, assign) CGFloat tableViewInsertBottom;
@property (nonatomic, copy) void (^loadMoreBlock)();

- (void)beginLoadMore;
- (void)endLoadMore;

@end
