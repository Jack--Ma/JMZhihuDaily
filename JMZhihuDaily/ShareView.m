//
//  ShareView.m
//  JMZhihuDaily
//
//  Created by JackMa on 15/12/21.
//  Copyright © 2015年 JackMa. All rights reserved.
//

#import "ShareView.h"
#import "JMCheckView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "WXApi.h"
#import <WeiboSDK/WeiboSDK.h>

@interface ShareView () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation ShareView {
  MFMessageComposeViewController *_messagePicker;
  MFMailComposeViewController *_mailPicker;
}

- (IBAction)weixinShare:(id)sender {
  UIButton *temp = (UIButton *)sender;
  SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
  
  WXWebpageObject *webObj = [WXWebpageObject object];
  webObj.webpageUrl = self.articleURL;

  WXMediaMessage *message = [WXMediaMessage message];
  message.description = self.articleTitle;
  message.mediaObject = webObj;
  if (self.articleImageURL) {
    //文章有主图片
    UIImage *image = self.articleImage;
    message.thumbData = UIImageJPEGRepresentation(image, 0.1);
  }
  if (temp.frame.origin.x == 37.0) {
    //分享到朋友
    message.title = @"嘿，我在这里发现一篇有意思的文章";
    req.scene = WXSceneSession;
  } else {
    //分享到朋友圈
    message.title = self.articleTitle;
    req.scene = WXSceneTimeline;
  }
  req.bText = NO;
  req.message = message;
  [WXApi sendReq:req];
}
- (IBAction)qqShare:(id)sender {
  
}
- (IBAction)weiboShare:(id)sender {
  //添加的图片
  WBImageObject *imageObj = [WBImageObject object];
  imageObj.imageData = UIImageJPEGRepresentation(self.articleImage, 0.5);
  
  //要发送的多媒体信息，不能发送多媒体信息，奇怪？？？
//  WBBaseMediaObject *mediaObj = [WBBaseMediaObject object];
//  mediaObj.objectID = [NSString stringWithFormat:@"share: %@", self.articleURL];
//  mediaObj.title = self.articleTitle;
//  mediaObj.thumbnailData = UIImageJPEGRepresentation(self.articleImage, 0.1);
//  mediaObj.scheme = self.articleURL;
  
  //发送的微博
  WBMessageObject *messageObj = [WBMessageObject message];
  messageObj.text = [NSString stringWithFormat:@"嘿，我在知乎日报发现一篇有意思的文章《%@》，你也看看：%@", self.articleTitle, self.articleURL];
  messageObj.imageObject = imageObj;
  
  //发送请求
  WBBaseRequest *wbreq = [WBSendMessageToWeiboRequest requestWithMessage:messageObj];
  [WeiboSDK sendRequest:wbreq];

}
- (IBAction)messageShare:(id)sender {
  _messagePicker = [[MFMessageComposeViewController alloc] init];
  _messagePicker.messageComposeDelegate = self;
  NSString *message = [NSString stringWithFormat:@"嘿，我在知乎日报发现一篇有意思的文章《%@》，你也看看：%@", self.articleTitle, self.articleURL];
  _messagePicker.body = message;
  //获取最上方的vc
  UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
  while (vc.presentedViewController) {
    vc = vc.presentedViewController;
  }
  [vc presentViewController:_messagePicker animated:YES completion:nil];
}
- (IBAction)emailShare:(id)sender {
  _mailPicker = [[MFMailComposeViewController alloc] init];
  _mailPicker.mailComposeDelegate = self;
  [_mailPicker setSubject:@"知乎日报分享"];
  NSString *mail = [NSString stringWithFormat:@"嘿，我在知乎日报发现一篇有意思的文章《%@》，你也看看：%@", self.articleTitle, self.articleURL];
  [_mailPicker setMessageBody:mail isHTML:NO];
  //获取最上方的vc
  UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
  while (vc.presentedViewController) {
    vc = vc.presentedViewController;
  }
  [vc presentViewController:_mailPicker animated:YES completion:nil];
}
- (IBAction)linkShare:(id)sender {
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  pasteboard.string = self.articleURL;
  
  [self shareSuccess:@"复制成功"];
}

- (void)shareSuccess: (NSString *)title {
  JMCheckView *checkView = [JMCheckView CheckInView:self.window];
  checkView.text = title;
  [self.window addSubview:checkView];
  checkView.alpha = 0.0f;
  checkView.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
  
  [UIView animateWithDuration:0.2 animations:^{
    checkView.alpha = 1.0f;
    checkView.transform = CGAffineTransformIdentity;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.3 delay:0.5 options:(UIViewAnimationOptionShowHideTransitionViews) animations:^{
      checkView.alpha = 0.0f;
    } completion:^(BOOL finished) {
      [checkView removeFromSuperview];
    }];
  }];
}
#pragma mark - MFMessageComposeViewControllerDelegate & MFMailComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
  [_messagePicker dismissViewControllerAnimated:YES completion:^{
    if (result == 1) {
      [self shareSuccess:@"发送成功"];
    }
  }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
  [_mailPicker dismissViewControllerAnimated:YES completion:^{
    if (result == 2) {
      [self shareSuccess:@"发送成功"];
    }
  }];
}

@end
