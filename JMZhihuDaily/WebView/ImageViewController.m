//
//  ImageViewController.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/29.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "ImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Photos/Photos.h>

@interface ImageViewController ()

@property (nonatomic, strong) DACircularProgressView *refreshImageView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ImageViewController

- (void)saveImage {
  //保存图片
  __block NSString *assetId = nil;
  // 1. 存储图片到"相机胶卷"
  [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    // 新建一个PHAssetCreationRequest对象
    // 返回PHAsset(图片)的字符串标识
    assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:self.imageView.image].placeholderForCreatedAsset.localIdentifier;
  } completionHandler:^(BOOL success, NSError * _Nullable error) {
    // 2. 获得相册对象
    PHAssetCollection *collection = [self getCollection];
    // 3. 将“相机胶卷”中的图片添加到新的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
      PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
      // 根据唯一标示获得相片对象
      PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
      // 添加图片到相册中
      [request addAssets:@[asset]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
//      NSLog(@"成功保存到相簿：%@", collection.localizedTitle);
    }];
  }];
}

- (PHAssetCollection *)getCollection {
  // 先获得之前创建过的相册
  PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
  for (PHAssetCollection *collection in collectionResult) {
    if ([collection.localizedTitle isEqualToString:@"知乎日报"]) {
      return collection;
    }
  }
  
  // 如果相册不存在,就创建新的相册(文件夹)
  __block NSString *collectionId = nil; // __block修改block外部的变量的值
  // 这个方法会在相册创建完毕后才会返回
  [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
    // 新建一个PHAssertCollectionChangeRequest对象, 用来创建一个新的相册
    collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"知乎日报"].placeholderForCreatedAssetCollection.localIdentifier;
  } error:nil];
  
  return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject;
}

#pragma mark - 手势的方法
- (void)viewDismiss {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)keepImage {
  UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"知乎日报" message:@"是否保存图片到本地？" preferredStyle:UIAlertControllerStyleActionSheet];
  UIAlertAction *keepAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self saveImage];
  }];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    [alertVC dismissViewControllerAnimated:YES completion:nil];
  }];
  [alertVC addAction:keepAction];
  [alertVC addAction:cancelAction];
  [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)changeScale:(UIPinchGestureRecognizer *)sender {
  UIView *view = sender.view;
  if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
    view.transform = CGAffineTransformScale(view.transform, sender.scale, sender.scale);
    sender.scale = 1.0;
  }
}

- (void)changePoint:(UIPanGestureRecognizer *)sender {
  UIView *view = sender.view;
  if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
    CGPoint translation = [sender translationInView:view.superview];
    [view setCenter:CGPointMake(view.centerX+translation.x, view.centerY+translation.y)];
    [sender setTranslation:CGPointZero inView:view.superview];
  }
}

- (void)rotateImage:(UIRotationGestureRecognizer *)sender {
  UIView *view = sender.view;
  if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
    view.transform = CGAffineTransformRotate(view.transform, sender.rotation);
    [sender setRotation:0];
  }
}

#pragma mark - init
- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
  
  //进度圆圈
  self.refreshImageView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
  self.refreshImageView.center = self.view.center;
  self.refreshImageView.roundedCorners = 15;
  self.refreshImageView.trackTintColor = [UIColor clearColor];
  self.refreshImageView.progressTintColor = [UIColor whiteColor];
  [self.view addSubview:self.refreshImageView];
  
  //要加载的image
  self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width*0.75)];
  self.imageView.center = self.view.center;
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  self.imageView.clipsToBounds = YES;
  [self.imageView sd_setImageWithPreviousCachedImageWithURL:self.imageURL andPlaceholderImage:nil options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    [self.refreshImageView setProgress:(CGFloat)receivedSize/(CGFloat)expectedSize animated:YES];
  } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    [self.refreshImageView removeFromSuperview];
    [self.view addSubview:self.imageView];
  }];

  //点击后退出该View
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDismiss)];
  [self.view addGestureRecognizer:tapGesture];
  
  //长按选择是否保存
  UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(keepImage)];
  [self.view addGestureRecognizer:longPressGesture];
  
  //图片放大缩小手势
  UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeScale:)];
  [self.imageView addGestureRecognizer:pinGesture];
  self.imageView.userInteractionEnabled = YES;
  self.imageView.multipleTouchEnabled = YES;
  
  //图片拖拉手势
  UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePoint:)];
  [self.imageView addGestureRecognizer:panGesture];
  
  //图片旋转手势
  UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateImage:)];
  [self.imageView addGestureRecognizer:rotationGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
