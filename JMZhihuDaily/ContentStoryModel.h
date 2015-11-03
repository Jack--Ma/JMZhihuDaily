//
//  ContentStoryModel.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/3.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PastContentStoryItem.h"

@interface ContentStoryModel : NSObject <PastContentStoryItem>

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSString *mid;
@property (nonatomic, strong) NSString *title;

- (void)setImages:(NSMutableArray *)images mid:(NSString *)mid title:(NSString *)title;

@end
