//
//  ThemeModel.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/4.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeModel : NSObject

@property (nonatomic, strong) NSString *mid;
@property (nonatomic, strong) NSString *name;

- (void)setMid:(NSString *)mid name:(NSString *)name;

@end
