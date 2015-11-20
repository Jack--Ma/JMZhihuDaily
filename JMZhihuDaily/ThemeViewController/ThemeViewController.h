//
//  ThemeViewController.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/5.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCPullRefreshViewController.h"

@interface ThemeViewController : SCPullRefreshViewController

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *tid;

@end
