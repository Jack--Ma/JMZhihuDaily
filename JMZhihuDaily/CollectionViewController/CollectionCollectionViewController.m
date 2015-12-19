//
//  CollectionCollectionViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/12.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "CollectionCollectionViewController.h"
#import "CollectionViewCell.h"
#import "UserModel.h"
#import "WebViewController.h"

#define StandardWidth [UIScreen mainScreen].bounds.size.width / 2.0
#define CellWidth (StandardWidth - 15.0)
#define CellHeight (CellWidth * 1.25)

static NSString * const reuseIdentifier = @"UICollectionViewCell";
extern NSMutableArray *imageArray;
extern NSMutableArray *idArray;
extern NSMutableArray *nameArray;

@interface CollectionCollectionViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation CollectionCollectionViewController {
//  NSIndexPath *_indexPath;
}

//- (void)viewDidAppear:(BOOL)animated {
//  [super viewDidAppear:animated];
//  if (nameArray.count != [UserModel currentUser].articlesList.count && _indexPath) {
//    NSLog(@"%ld", _indexPath.row);
//    NSIndexPath *indexPath = _indexPath;
//    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
//  }
//}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
  [[NSNotificationCenter defaultCenter] addObserver:self.collectionView selector:@selector(reloadData) name:@"refreshData" object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self.collectionView];
}
//取消收藏的方法，利用button中的tag
- (void)cancelCollection:(id)sender {
  UIButton *temp = (UIButton *)sender;
  NSIndexPath *indexPath = [NSIndexPath indexPathForItem:temp.tag inSection:0];
  NSLog(@"%ld", (long)indexPath.row);
  [nameArray removeObjectAtIndex:indexPath.row];
  [idArray removeObjectAtIndex:indexPath.row];
  [imageArray removeObjectAtIndex:indexPath.row];
  NSMutableArray *array = [UserModel currentUser].articlesList;
  [array removeObjectAtIndex:indexPath.row];
  [[UserModel currentUser] setObject:array forKey:@"articlesList"];
  [[UserModel currentUser] save];
  [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake(CellWidth, CellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return nameArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
  
  cell.imageURLString = imageArray[indexPath.row];
  cell.title = nameArray[indexPath.row];
  [cell awakeFromNib];
  cell.button.tag = indexPath.row;
  [cell.button addTarget:self action:@selector(cancelCollection:) forControlEvents:UIControlEventTouchUpInside];

  return cell;
}


#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  //跳转到WebView
  WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
  webViewController.isTopStory = YES;
  webViewController.newsId = [idArray[indexPath.row] integerValue];
  
  [self.navigationController pushViewController:webViewController animated:YES];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

@end
