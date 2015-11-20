//
//  StoryModel.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/17.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoryModel : NSObject

@property (nonatomic, strong) NSMutableArray *topStory;
@property (nonatomic, strong) NSMutableArray *contentStory;
@property (nonatomic, strong) NSMutableArray *pastContentStory;
@property (nonatomic, strong) NSMutableArray *offsetYNumber;
@property (nonatomic, strong) NSMutableArray *offsetYValue;

@property (nonatomic, strong) NSMutableArray *themes;
@property (nonatomic, strong) NSMutableArray *themeContent;
@property (nonatomic, assign) BOOL firstDisplay;

+ (instancetype)shareStory;
- (void)getData;

@end
