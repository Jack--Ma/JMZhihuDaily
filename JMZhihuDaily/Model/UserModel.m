//
//  UserModel.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/13.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

@dynamic avatar, gender, birthday, age, selfDescription;

+(NSString *)parseClassName {
  return @"_User";
}

@end
