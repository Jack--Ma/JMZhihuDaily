//
//  CollectionViewCell.h
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/19.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *title;

@end
