//
//  TopStoryModel.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/3.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopStoryModel : NSObject

@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *mid;
@property (nonatomic, strong) NSString *title;

- (void)setImage:(NSString *)image mid:(NSString *)mid title:(NSString *)title;

@end
