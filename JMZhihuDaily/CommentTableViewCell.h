//
//  CommentTableViewCell.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/25.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *commentDic;
@property (nonatomic, assign) BOOL isLast;

@end
