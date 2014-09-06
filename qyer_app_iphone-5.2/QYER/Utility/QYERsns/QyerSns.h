//
//  QyerSns.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-8-8.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SinaWeibo.h"
#import "SinaWeiboRequest.h"
#import <MessageUI/MessageUI.h>
#import "WeiboApi.h"
@class SinaWeibo;
@class sinaWeiboViewController;


@interface QyerSns : NSObject <SinaWeiboDelegate, SinaWeiboRequestDelegate,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate,WeiboRequestDelegate,WeiboAuthDelegate>
{
    UIViewController        *SMSVC;
    UIViewController        *_shareVC;
    
    UIViewController        *_tencentVC;
    NSString                *_text_tencentWeibo;
    UIImage                 *_image_tencentWeibo;
    
    
    NSString                *_title_sinaWeibo;
    NSString                *_text_sinaWeibo;
    UIImage                 *_image_sinaWeibo;
    
}
@property (nonatomic,retain) WeiboApi    *wbapi;
@property (nonatomic,retain) SinaWeibo   *sinaweibo;
@property (nonatomic,retain) sinaWeiboViewController *sinaVC;

/**
 *  insert by yihui
 */
/**
 * 发布文字到腾讯微博
 *
 *  @param status 发送的文本
 */
-(void)shareToTencentWeibo:(NSString *)status;
/**
 *  发送图片+文字到腾讯微博
 *
 *  @param status 发送的文本
 *  @param image  发送的图片
 */
-(void)shareToTencentWeibo:(NSString *)status andImage:(UIImage*)image;
/**
 *  登出腾讯微博
 */
-(void)loginOutTencentWeibo;

+(id)sharedQyerSns;

//存储微博信息
- (void)storeAuthData;

-(BOOL)isCanSendSMS;
+(NSInteger)canSendMail;
-(BOOL)getIsWeixinInstalled;
-(NSString *)getWeixinVerson;
-(void)feedBackWithMailInfo:(NSDictionary *)dic_info;

-(void)shareToSinaWeiboWithTitle:(NSString *)title_sinaweibo andText:(NSString *)text_sinaweibo andImage:(UIImage *)image_sinaweibo inViewController:(UIViewController *)vc;
-(void)shareToTencentWeiboWithText:(NSString *)text andImage:(UIImage *)image andDelegate:(UIViewController *)delegate;
-(void)shareToMailWithMailTitle:(NSString *)mailTitle andMailInfo:(NSString *)info_mail andImage:(UIImage *)image_mail inViewController:(UIViewController *)vc;
-(void)shareWithShortMessage:(NSString *)SMSMessage inViewController:(UIViewController *)vc;
-(void)shareToWeixinWithTextOnly:(NSString *)text_weixin;
-(void)shareToWeixinFriendWithTextOnly:(NSString *)text_weixin;
-(void)shareToWeixinWithAPPTitle:(NSString *)title_weixin andDescription:(NSString *)description_weixin andImage:(UIImage *)image_weixin andUrl:(NSString *)url_weixin;
-(void)shareToWeixinFriendCircleWithAPPTitle:(NSString *)title_weixin andDescription:(NSString *)description_weixin andImage:(UIImage *)image_weixin  andUrl:(NSString *)url_weixin;
-(void)loginOutSinaWeibo;


//***(1) 只发布文字:
-(void)shareToWeibo:(NSString *)status;
//***(3) 发布文字和图片:
-(void)shareToWeibo:(NSString *)status andImage:(UIImage*)image;


@end

