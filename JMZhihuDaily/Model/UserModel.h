//
//  UserModel.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/11/13.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "AVUser.h"

typedef enum : NSUInteger {
  GenderUnkonwn = 0,
  GenderMale = 1,
  GenderFamale = 2,
} GenderType;

@interface UserModel : AVUser <AVSubclassing>

@property (nonatomic, strong) AVFile *avatar;
@property (nonatomic, assign) GenderType gender;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSString *selfDescription;
@property (nonatomic, strong) NSMutableArray *articlesList;

@end
