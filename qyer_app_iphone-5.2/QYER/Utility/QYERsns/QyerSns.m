//
//  QyerSns.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-8-8.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "QyerSns.h"
#import "WXApi.h"
#import "Toast+UIView.h"
#import "SinaWeibo.h"
#import "ASIFormDataRequest.h"
#import "NSString+SBJSON.h"
#import "sinaWeiboViewController.h"



#define kAppKey_sina             @"633031797"
#define kAppSecret_sina          @"79c3f31d1436cc1c5d4fdbefe0dd429d"
#define kAppRedirectURI_sina     @"http://www.sina.com"




#define kAppKey_Tencent          @"801358344"
#define kAppSecret_Tencent       @"3874c1692edff7432171dcc9dd0a51f1"
#define REDIRECTURI              @"http://app.qyer.com/guide/"


//#define WeiboApiAuthData         @"WeiboApiAuthData"

@implementation QyerSns
@synthesize sinaweibo;
@synthesize sinaVC;


-(void)dealloc
{
    [SMSVC release];
//    [_tencentVC release];
    [_text_tencentWeibo release];
    [_image_tencentWeibo release];
    [_title_sinaWeibo release];
    [_text_sinaWeibo release];
    [_image_sinaWeibo release];
    
    if(_shareVC && _shareVC.retainCount > 0)
    {
        [_shareVC release];
    }
    
    self.sinaweibo = nil;
    self.sinaVC = nil;
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- QyerSns 单例
static QyerSns *sharedQyerSns = nil;
+(id)sharedQyerSns
{
    if(!sharedQyerSns)
    {
        sharedQyerSns = [[self alloc] init];
        
        sharedQyerSns.wbapi = [[[WeiboApi alloc]initWithAppKey:kAppKey_Tencent andSecret:kAppSecret_Tencent andRedirectUri:REDIRECTURI andAuthModeFlag:0 andCachePolicy:0] autorelease];
        
        SinaWeibo *sinaWeibo_ = [[SinaWeibo alloc] initWithAppKey:kAppKey_sina appSecret:kAppSecret_sina appRedirectURI:kAppRedirectURI_sina andDelegate:sharedQyerSns];
        sharedQyerSns.sinaweibo = sinaWeibo_;
        [sinaWeibo_ release];
        
        [sharedQyerSns initSinaVC];
    }
    return sharedQyerSns;
}



#pragma mark -
#pragma mark --- 短信
-(BOOL)isCanSendSMS
{
    Class messageClass=(NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil)
    {
        if ([messageClass canSendText])
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    return -1;
}
-(void)shareWithShortMessage:(NSString *)SMSMessage inViewController:(UIViewController *)vc
{
    if(SMSVC)
    {
        [SMSVC release];
    }
    SMSVC = [vc retain];
    
    [self sendsms:SMSMessage];
}
-(void)sendsms:(NSString *)message
{
	Class messageClass=(NSClassFromString(@"MFMessageComposeViewController"));
	////NSLog(@"can send SMS [%d]", [messageClass canSendText]);
	if (messageClass != nil)
    {
        if ([messageClass canSendText])
        {
            [self displaySMS:message];
        }
        else
        {
			[self alertWithTitle:nil msg:@"设备没有短信功能"];
        }
	}
    else
    {
		[self alertWithTitle:nil msg:@"iOS版本过低，iOS4.0以上才支持程序内发送短信"];
	}
}
-(void)displaySMS:(NSString *)message
{
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	picker.delegate = self;
	picker.messageComposeDelegate = self;
	picker.navigationBar.tintColor = [UIColor blackColor];
	picker.body = message;
	//picker.recipients = [NSArray arrayWithObject:@""];
    
	//[SMSVC presentModalViewController:picker animated:YES];
    //[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:picker animated:YES];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:picker animated:YES completion:nil];
    
    
	[picker release];
}
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller
                didFinishWithResult:(MessageComposeResult)result
{
	NSString *msg = @"";
	
	switch (result)
    {
		case MessageComposeResultCancelled:
//			msg = @"发送取消";
			//[self alertWithTitle:nil msg:msg];
			break;
		case MessageComposeResultSent:
			msg = @"发送成功";
			[self alertWithTitle:nil msg:msg];
			break;
		case MessageComposeResultFailed:
			msg = @"发送失败";
			[self alertWithTitle:nil msg:msg];
			break;
		default:
			break;
	}
	//MYLog(@"短信发送结果: %@", msg);
	
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    //*** 这样不成功:
	//[[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissModalViewControllerAnimated:YES];
}
-(void)alertWithTitle:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark --- 邮件
+(NSInteger)canSendMail
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
            return 1;
		}
		else //设备不支持邮箱
		{
            return -1;
		}
	}
	else //尚未对设备配置邮箱账户
	{
        return 0;
	}
}
-(void)feedBackWithMailInfo:(NSDictionary *)dic_info
{
    MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    mailVC.mailComposeDelegate = self;
    
    
    [mailVC setSubject:[dic_info objectForKey:@"title"]];
    [mailVC setToRecipients:[dic_info objectForKey:@"mailaddress"]];
    [mailVC setMessageBody:[dic_info objectForKey:@"info"] isHTML:NO];
    
    
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:mailVC animated:YES completion:nil];
    [mailVC release];
}
-(void)shareToMailWithMailTitle:(NSString *)mailTitle andMailInfo:(NSString *)info_mail andImage:(UIImage *)image_mail inViewController:(UIViewController *)vc
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			MFMailComposeViewController *mailVC = [[[MFMailComposeViewController alloc] init] autorelease];
			mailVC.mailComposeDelegate = self;
            [mailVC.navigationBar setTintColor:[UIColor colorWithRed:24/255. green:121/255. blue:76/255. alpha:1]];
            
            
            
			//MYLog(@"mailTitle === %@",mailTitle);
			[mailVC setSubject:mailTitle]; //邮件标题
            //[mailVC setToRecipients:[NSArray arrayWithObject:@"mfb@qyer.com"]];       //收件人
            //[mailVC setCcRecipients:[NSArray arrayWithObject:@"qing.an@qyer.com"]];   //抄送
            //[mailVC setBccRecipients:[NSArray arrayWithObject:@"qing.an@go2eu.com"]]; //密送
            
            
            
            
            if(image_mail)
            {
                //添加图片:
                UIImage *SharePic;
                if(image_mail)
                {
                    SharePic = image_mail;
                }
                else
                {
                    SharePic = [UIImage imageNamed:@"Default@2x.png"];;
                }
                NSData *imageData = UIImagePNGRepresentation(SharePic); //png
                NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
                NSString *fileName = [NSString stringWithFormat:@"%@.png",appName];
                [mailVC addAttachmentData:imageData mimeType:@"image/png" fileName:fileName];
                //[mailVC setMessageBody:mailInfo isHTML:YES];
                [mailVC setMessageBody:info_mail isHTML:NO];
                //[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:mailVC animated:YES];
                
                //[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:mailVC animated:YES];
                
                if(_shareVC && _shareVC.retainCount > 0)
                {
                    [_shareVC release];
                }
                _shareVC = [vc retain];
                [_shareVC presentViewController:mailVC animated:YES completion:nil];
                
                //MYLog(@"mailInfo === %@",mailInfo);
            }
            else
            {
                [mailVC setMessageBody:info_mail isHTML:YES];
                //[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:mailVC animated:YES];
                //[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:mailVC animated:YES];
                if(_shareVC && _shareVC.retainCount > 0)
                {
                    [_shareVC release];
                }
                _shareVC = [vc retain];
                [_shareVC presentViewController:mailVC animated:YES completion:nil];
            }
            
		}
		else
		{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAlertLabel" object:nil userInfo:nil];
            
			UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"提示"
                                  message:@"您尚未对设备配置邮箱账户,请配置后再试"
                                  delegate:nil
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	else
	{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAlertLabel" object:nil userInfo:nil];
        
        
		UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示"
                              message:@"您尚未对设备配置邮箱账户,请配置后再试"
                              delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	if(result == MFMailComposeResultSent)
	{
        [controller.view hideToast];
        [controller.view makeToast:@"邮件发送成功" duration:1 position:@"center" isShadow:NO];
	}
    
    // MYLog(@"邮件发送成功");
    
	//[[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissModalViewControllerAnimated:YES];
	//[[[[[UIApplication sharedApplication] delegate] window] rootViewController] dismissModalViewControllerAnimated:YES];
    [_shareVC dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark -
#pragma mark --- 微信
//WXSceneSession  = 0  (微信好友)
//WXSceneTimeline = 1  (朋友圈)
-(BOOL)getIsWeixinInstalled
{
    return [WXApi isWXAppInstalled];
}
-(NSString *)getWeixinVerson
{
    //NSString *versonStr = [WXApi getWXAppSupportMaxApiVersion];
    NSString *versonStr = [WXApi getApiVersion];
    return versonStr;
}

//***(1.0)微信认证
-(void)onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        //[self onRequestAppMessage];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        //ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        //[self onShowMediaMessage:temp.message];
    }
}
-(void)onResp:(BaseResp*)resp
{
    NSString *strTitle = @"";
    
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        strTitle = [NSString stringWithFormat:@"发送成功"];
        if (resp.errCode==-2) {
            strTitle = [NSString stringWithFormat:@"发送取消"];
            
        }
        if (resp.errCode != -2 && resp.errCode !=0) {
            strTitle = [NSString stringWithFormat:@"发送失败"];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strTitle delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else
    {
        strTitle = [NSString stringWithFormat:@"发送失败"];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strTitle delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    
    
//    if([resp isKindOfClass:[SendMessageToWXResp class]])
//    {
//        NSString *strTitle = [NSString stringWithFormat:@"发送结果"];
//        NSString *strMsg = [NSString stringWithFormat:@"发送媒体消息结果:%d", resp.errCode];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
//    }
//    else if([resp isKindOfClass:[SendAuthResp class]])
//    {
//        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
//        NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
//    }
}


//*** (1.1.1)发送文字:
-(void)shareToWeixinWithTextOnly:(NSString *)text_weixin
{
    SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = YES;
    req.text = text_weixin;
    req.scene = WXSceneTimeline;
    [WXApi sendReq:req];
}


//*** (1.1.2)发送文字:
-(void)shareToWeixinFriendWithTextOnly:(NSString *)text_weixin
{
    SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = YES;
    req.text = text_weixin;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
}

//*** (1.2)发送图片(文字和图片不能同时发送!!  图片不能过大!!!):
-(void)shareToWeixinWithImageOnly:(UIImage *)image_weixin
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:image_weixin];
    WXImageObject *ext = [WXImageObject object];
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res2" ofType:@"jpg"];
    //ext.imageData = [NSData dataWithContentsOfFile:filePath];
    ext.imageData = UIImagePNGRepresentation(image_weixin);
    message.mediaObject = ext;
    SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = NO;  //发送消息的类型,包括文本消息和多媒体消息两种,两者只能选择其一,不能同时发送文本和多媒体消息
    req.message = message;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
    
}

//*** (1.3)发送音乐:
-(void)shareToWeixinWithMusic
{
//    WXMediaMessage *message = [WXMediaMessage message];
//    message.title = @"AQ<歌神安庆>";
//    message.description = weixinShareMusicDescription;
//    [message setThumbImage:weixinShareImage];
//    WXMusicObject *ext = [WXMusicObject object];
//    ext.musicUrl = weixinShareMusicUrl;
//    message.mediaObject = ext;
//    SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init]autorelease];
//    req.bText = NO;
//    req.message = message;
//    req.scene = _scene;
//    [WXApi sendReq:req];
}


//*** (1.4)发送app信息:
//-(void)shareToWeixinWithAPPTitle:(NSString *)title_weixin andDescription:(NSString *)description_weixin andImage:(UIImage *)image_weixin andUrl:(NSString *)url_weixin
//{
//    //NSLog(@"发送app信息:");
//    
//    WXMediaMessage *message = [WXMediaMessage message];
//    message.title = title_weixin;
//    message.description = description_weixin;
//    [message setThumbImage:image_weixin];
//    
//    WXAppExtendObject *ext = [WXAppExtendObject object];
//    ext.extInfo = @"<xml>TEST</xml>";
//    //NSLog(@"self.shareAppUrl ==== %@",self.shareAppUrl);
//    ext.url = url_weixin;
//    Byte *pBuffer = (Byte *)malloc(BUFFER_SIZE);
//    memset(pBuffer, 0, BUFFER_SIZE);
//    NSData *data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
//    free(pBuffer);
//    ext.fileData = data;
//    message.mediaObject = ext;
//    SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init] autorelease];
//    req.bText = NO;
//    req.message = message;
//    req.scene = WXSceneSession;
//    
//    [WXApi sendReq:req];
//}

//*** (1.5)
-(void)shareToWeixinWithAPPTitle:(NSString *)title_weixin andDescription:(NSString *)description_weixin andImage:(UIImage *)image_weixin  andUrl:(NSString *)url_weixin
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title_weixin;
    message.description = description_weixin;
    [message setThumbImage:image_weixin];
    
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url_weixin;
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
    
}
-(void)shareToWeixinFriendCircleWithAPPTitle:(NSString *)title_weixin andDescription:(NSString *)description_weixin andImage:(UIImage *)image_weixin  andUrl:(NSString *)url_weixin
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title_weixin;
    message.description = description_weixin;
    [message setThumbImage:image_weixin];
    
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url_weixin;
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}
#pragma mark
#pragma mark -- tencent


/**
 * 发布文字到腾讯微博
 *
 *  @param status 发送的文本
 */
-(void)shareToTencentWeibo:(NSString *)status{
    
    [self.sinaVC.view hideToast];
    [self.sinaVC.view makeToast:@"正在发布..." duration:0 position:@"center" isShadow:NO];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"json",@"format",
                                   status, @"content",
                                   nil];
    [self.wbapi requestWithParams:params apiName:@"t/add_pic" httpMethod:@"POST" delegate:self];
    [params release];
}
/**
 *  发送图片+文字到腾讯微博
 *
 *  @param status 发送的文本
 *  @param image  发送的图片
 */
-(void)shareToTencentWeibo:(NSString *)status andImage:(UIImage*)image{
    
    [self.sinaVC.view hideToast];
    [self.sinaVC.view makeToast:@"正在发布..." duration:0 position:@"center" isShadow:NO];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"json",@"format",
                                   status, @"content",
                                   image, @"pic",
                                   nil];
    [self.wbapi requestWithParams:params apiName:@"t/add_pic" httpMethod:@"POST" delegate:self];
    [params release];
    
}


#pragma mark -
#pragma mark --- 腾讯微博
/**
 *  登出腾讯微博
 */
-(void)loginOutTencentWeibo{
    
    [self.wbapi cancelAuth];
}
/**
 *  进入腾讯微博控制器
 */
-(void)pushTencentWeiboVC{
    
    if(!sinaVC)
    {
        [self initSinaVC];
    }
    sinaVC.type = 1;
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:sinaVC];
    navVC.navigationBar.hidden = YES;
   
    [_shareVC presentViewController:navVC animated:YES completion:nil];
    sinaVC.textV.text = _text_tencentWeibo;
    [sinaVC initTitle:_text_tencentWeibo];
    [sinaVC initImageView:_image_tencentWeibo];
    [sinaVC setShuziLabelNumber];
    [sinaVC.textV becomeFirstResponder];
    [navVC release];
    
}
-(void)shareToTencentWeiboWithText:(NSString *)text andImage:(UIImage *)image andDelegate:(UIViewController *)delegate{
    
    
    
    _text_tencentWeibo = [text retain];
    _image_tencentWeibo = [image retain];
    
    [self.wbapi checkAuthValid:0 andDelegete:self];
    _shareVC = [delegate retain];
}
#pragma mark
#pragma mark 检测腾讯授权是否到期
- (void)didCheckAuthValid:(BOOL)bResult suggest:(NSString*)strSuggestion{
    
    NSLog(@"bResult is %d",bResult);
    //有效，直接分享
    if (bResult == YES) {
        
        [self pushTencentWeiboVC];
        
    }else{//无效
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [self.wbapi loginWithDelegate:self andRootController:_shareVC];
   
        });

    }
}

#pragma mark WeiboAuthDelegate

/**
 * @brief   重刷授权成功后的回调
 * @param   INPUT   wbapi 成功后返回的WeiboApi对象，accesstoken,openid,refreshtoken,expires 等授权信息都在此处返回
 * @return  无返回
 */
- (void)DidAuthRefreshed:(WeiboApiObject *)wbobj
{
    
    
    
//    NSString *str = [[NSString alloc]initWithFormat:@"accesstoken = %@\r openid = %@\r appkey=%@ \r appsecret=%@\r",wbobj.accessToken, wbobj.openid, wbobj.appKey, wbobj.appSecret];
//    
//    NSLog(@"DidAuthRefreshed result = %@",str);
    
    [self pushTencentWeiboVC];
}

/**
 * @brief   重刷授权失败后的回调
 * @param   INPUT   error   标准出错信息
 * @return  无返回
 */
- (void)DidAuthRefreshFail:(NSError *)error
{
//    NSString *str = [[NSString alloc] initWithFormat:@"refresh token error, errcode = %@",error.userInfo];
//    NSLog(@"DidAuthRefreshFail str is %@",str);


}

/**
 * @brief   授权成功后的回调
 * @param   INPUT   wbapi 成功后返回的WeiboApi对象，accesstoken,openid,refreshtoken,expires 等授权信息都在此处返回
 * @return  无返回
 */
- (void)DidAuthFinished:(WeiboApiObject *)wbobj
{
//    NSString *str = [[NSString alloc]initWithFormat:@"accesstoken = %@\r\n openid = %@\r\n appkey=%@ \r\n appsecret=%@ \r\n refreshtoken=%@ ", wbobj.accessToken, wbobj.openid, wbobj.appKey, wbobj.appSecret, wbobj.refreshToken];
//    NSLog(@"DidAuthFinished result = %@",str);
    
    [self pushTencentWeiboVC];


}

/**
 * @brief   取消授权后的回调
 * @param   INPUT   wbapi   weiboapi 对象，取消授权后，授权信息会被清空
 * @return  无返回
 */
- (void)DidAuthCanceled:(WeiboApi *)wbapi_
{
    
}


/**
 * @brief   授权失败后的回调
 * @param   INPUT   error   标准出错信息
 * @return  无返回
 */
- (void)DidAuthFailWithError:(NSError *)error
{
//    NSString *str = [[NSString alloc] initWithFormat:@"get token error, errcode = %@",error.userInfo];
//    NSLog(@"DidAuthFailWithError str is %@",str);
}

#pragma mark WeiboRequestDelegate

/**
 * @brief   接口调用成功后的回调
 * @param   INPUT   data    接口返回的数据
 * @param   INPUT   request 发起请求时的请求对象，可以用来管理异步请求
 * @return  无返回
 */
- (void)didReceiveRawData:(NSData *)data reqNo:(int)reqno
{
    NSString *strResult = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
    NSLog(@"result = %@",strResult);
    
    //注意回到主线程，有些回调并不在主线程中，所以这里必须回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.sinaVC.view hideToast];
        [self.sinaVC.view makeToast:@"微博分享成功" duration:1 position:@"center" isShadow:NO];
        [self performSelector:@selector(hideSinaVC) withObject:nil afterDelay:1];
        
        NSLog(@"分享成功");
    });
    
    [strResult release];
    
}
/**
 * @brief   接口调用失败后的回调
 * @param   INPUT   error   接口返回的错误信息
 * @param   INPUT   request 发起请求时的请求对象，可以用来管理异步请求
 * @return  无返回
 */
- (void)didFailWithError:(NSError *)error reqNo:(int)reqno
{
    NSString *str = [[NSString alloc] initWithFormat:@"refresh token error, errcode = %@",error.userInfo];
    
    //注意回到主线程，有些回调并不在主线程中，所以这里必须回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([[error description] rangeOfString:@"error=repeat content"].location < [[error description] length])
        {
            //@"已经分享过啦";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"已经分享过啦" duration:1 position:@"center" isShadow:NO];
        }
        else if([[error description] rangeOfString:@"error=miss required parameter (status)"].location < [[error description] length])
        {
            //@"请完善微博文字";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"请完善微博文字" duration:1 position:@"center" isShadow:NO];
        }
        else if(sinaVC.isWordTooLong == 1)
        {
            //@"您发布的微博消息过长";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"您发布的微博消息过长" duration:1 position:@"center" isShadow:NO];
        }
        else if([[error description] rangeOfString:@"(WeiBoSDKErrorDomain error 100.)"].location < [[error description] length]) //原因是应用没通过审核之前需添加测试用户才可以成功读取发送微博
        {
            //@"应用没通过审核之前,需添加测试用户才可以发微博";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"应用没通过审核之前,需添加测试用户才可以发微博" duration:2 position:@"center" isShadow:NO];
        }
        else if([[error description] rangeOfString:@"似乎已断开与互联网的连接"].location < [[error description] length])
        {
            //@"请检查网络连接";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"请检查网络连接" duration:1 position:@"center" isShadow:NO];
        }
        else
        {
            //@"微博分享失败";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"微博分享失败" duration:1 position:@"center" isShadow:NO];
        }
    });
    [str release];
}

#pragma mark -
#pragma mark --- 新浪微博
-(void)shareToSinaWeiboWithTitle:(NSString *)title_sinaweibo andText:(NSString *)text_sinaweibo andImage:(UIImage *)image_sinaweibo inViewController:(UIViewController *)vc
{
    if(_title_sinaWeibo && ![_title_sinaWeibo isEqual:title_sinaweibo])
    {
        [_title_sinaWeibo release];
    }
    if(title_sinaweibo)
    {
        _title_sinaWeibo = [title_sinaweibo retain];
    }
    
    if(_text_sinaWeibo && ![_text_sinaWeibo isEqual:text_sinaweibo])
    {
        [_text_sinaWeibo release];
    }
    if(text_sinaweibo)
    {
        _text_sinaWeibo = [text_sinaweibo retain];
    }
    
    if(_image_sinaWeibo && ![_image_sinaWeibo isEqual:text_sinaweibo])
    {
        [_image_sinaWeibo release];
    }
    if(image_sinaweibo)
    {
        _image_sinaWeibo = [image_sinaweibo retain];
    }
    
    
    if(_shareVC && _shareVC.retainCount > 0)
    {
        [_shareVC release];
    }
    _shareVC = [vc retain];
    
    
    [self loginIn];
}
-(void)loginIn
{
    if([sharedQyerSns.sinaweibo isAuthValid])
    {
        MYLog(@"已经登录,还未失效 ~~~");
        [self pushMySinaWeiboVC];
    }
    else
    {
        MYLog(@"还未登录");
        [sharedQyerSns.sinaweibo logIn];
    }
}
-(void)loginOutSinaWeibo
{
    MYLog(@"登出");
    
    [sharedQyerSns.sinaweibo logOut];
}

- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}
- (void)storeAuthData
{
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sharedQyerSns.sinaweibo.accessToken, @"AccessTokenKey",
                              sharedQyerSns.sinaweibo.expirationDate, @"ExpirationDateKey",
                              sharedQyerSns.sinaweibo.userID, @"UserIDKey",
                              sharedQyerSns.sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 初始化VC和UITextView
-(void)initSinaVC
{
    [QyerSns sharedQyerSns];
    if(!sharedQyerSns.sinaVC)
    {
        sinaWeiboViewController *sinaWeiboVC = [[sinaWeiboViewController alloc] init];
        sharedQyerSns.sinaVC = sinaWeiboVC;
        [sinaWeiboVC release];
    }
    
    
    if(!sinaVC.textV)
    {
        if(iPhone5)
        {
            if(ios7)
            {
                sinaVC.textV = [[[UITextView alloc] initWithFrame:CGRectMake(5, 44+5+20, 310, 150+88)] autorelease];
            }
            else
            {
                sinaVC.textV = [[[UITextView alloc] initWithFrame:CGRectMake(5, 44+5, 310, 150+88)] autorelease];
            }
        }
        else
        {
            if(ios7)
            {
                sinaVC.textV = [[[UITextView alloc] initWithFrame:CGRectMake(5, 44+5+20, 310, 150)] autorelease];
            }
            else
            {
                sinaVC.textV = [[[UITextView alloc] initWithFrame:CGRectMake(5, 44+5, 310, 150)] autorelease];
            }
        }
        [sinaVC.textV.layer setBorderWidth:1];
        [sinaVC.textV.layer setBorderColor:[UIColor colorWithRed:214/255. green:214/255. blue:210/255. alpha:1].CGColor];
    }
    sinaVC.shareImage = nil;
}

// pushMySinaWeiboVC
-(void)pushMySinaWeiboVC
{
    if(!sinaVC)
    {
        [self initSinaVC];
    }
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:sinaVC];
    navVC.navigationBar.hidden = YES;
    //[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:navVC animated:YES];
    //[[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentModalViewController:navVC animated:YES];
    [_shareVC presentViewController:navVC animated:YES completion:nil];
    sinaVC.textV.text = _text_sinaWeibo;
    [sinaVC initTitle:_title_sinaWeibo];
    [sinaVC initImageView:_image_sinaWeibo];
    [sinaVC setShuziLabelNumber];
    [sinaVC.textV becomeFirstResponder];
    [navVC release];
}

// SinaWeibo Delegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    //MYLog(@"微博登录成功 userID = %@ ; accesstoken = %@ ; expirationDate = %@ ; refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
    
    [self storeAuthData];
    
    [self pushMySinaWeiboVC];
}
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    //MYLog(@"微博登出成功");
    [self removeAuthData];
    
    sinaVC.showImageView.image=nil;
    sinaVC.shareImage = nil;
    
    [sinaVC dismissViewControllerAnimated:YES completion:nil];
}
- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    //MYLog(@"取消微博登录");
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    // MYLog(@"微博登录失败: %@", error);
}
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    // MYLog(@"微博accessToken实效: %@", error);
    [self removeAuthData];
}

// 发布新微博
-(void)shareToWeiboWithStatus:(NSString *)status andImage:(UIImage*)shareImage andJingdu:(NSString *)jingdu andWeidu:(NSString *)weidu
{
    if(!shareImage)
    {
        if(!weidu || !jingdu)
        {
            [self shareToWeibo:status];
        }
        else
        {
            [self shareToWeiboWithPosition:status andJingdu:jingdu andWeidu:weidu];
        }
    }
    else
    {
        if(!weidu || !jingdu)
        {
            [self shareToWeibo:status andImage:shareImage];
        }
        else
        {
            [self shareToWeiboWithPosition:status andImage:shareImage andJingdu:jingdu andWeidu:weidu];
        }
    }
}

//***(1) 只发布文字
-(void)shareToWeibo:(NSString *)status
{
    [self.sinaVC.view hideToast];
    [self.sinaVC.view makeToast:@"正在发布..." duration:0 position:@"center" isShadow:NO];
    
    
    [[sharedQyerSns sinaweibo] requestWithURL:@"statuses/update.json"
                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:status, @"status", nil]
                   httpMethod:@"POST"
                     delegate:self];
}
//***(2) 发布文字和地理位置
-(void)shareToWeiboWithPosition:(NSString *)status andJingdu:(NSString *)jingdu andWeidu:(NSString *)weidu
{
    [self.sinaVC.view hideToast];
    [self.sinaVC.view makeToast:@"正在发布..." duration:0 position:@"center" isShadow:NO];
    
    
    NSString *urlStr = @"https://api.weibo.com/2/statuses/update.json";
    //NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
    //NSString *access_token = [myDefault valueForKey:@"sinaaccesstoken"];
    
    ASIFormDataRequest *myRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    myRequest.delegate = self;
    //MYLog(@"开始POST");
    [myRequest addPostValue:status forKey:@"status"];
    [myRequest addPostValue:sharedQyerSns.sinaweibo.accessToken forKey:@"access_token"];
    [myRequest addPostValue:weidu forKey:@"lat"];
    [myRequest addPostValue:jingdu forKey:@"long"];
    [myRequest startAsynchronous];
    // MYLog(@"POST结束");
}
//***(3) 发布文字和图片
-(void)shareToWeibo:(NSString *)status andImage:(UIImage*)image
{
    [self.sinaVC.view hideToast];
    [self.sinaVC.view makeToast:@"正在发布..." duration:0 position:@"center" isShadow:NO];
    
    
    [sharedQyerSns.sinaweibo requestWithURL:@"statuses/upload.json"
                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                               status, @"status",
                               image, @"pic", nil]
                   httpMethod:@"POST"
                     delegate:self];
}
//***(4) 发布文字和图片和地理位置
-(void)shareToWeiboWithPosition:(NSString *)status andImage:(UIImage*)image andJingdu:(NSString *)jingdu andWeidu:(NSString *)weidu
{
    [self.sinaVC.view hideToast];
    [self.sinaVC.view makeToast:@"正在发布..." duration:0 position:@"center" isShadow:NO];
    
    
    NSString *urlStr = @"https://upload.api.weibo.com/2/statuses/upload.json";
    NSData *data = UIImagePNGRepresentation(image);
    //NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
    //NSString *access_token = [myDefault valueForKey:@"sinaaccesstoken"];
    
    ASIFormDataRequest *myRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    myRequest.delegate = self;
    //MYLog(@"开始POST");
    [myRequest addPostValue:status forKey:@"status"];
    [myRequest addPostValue:sharedQyerSns.sinaweibo.accessToken forKey:@"access_token"];
    [myRequest addData:data forKey:@"pic"];
    [myRequest addPostValue:weidu forKey:@"lat"];
    [myRequest addPostValue:jingdu forKey:@"long"];
    [myRequest startAsynchronous];
    //MYLog(@"POST结束");
}
//*** ASIHTTPRequest的代理方法(发布含地理位置的信息时执行该代理方法)
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    // MYLog(@"requestFinished  :)  responseString : %@",responseString);
    NSMutableString *myResponseString = [[NSMutableString alloc] initWithString:responseString];
    
    NSDictionary *dic = [myResponseString JSONValue];
    if(dic)
    {
        // MYLog(@"%@",[dic objectForKey:@"error"]);
        
        if(![dic objectForKey:@"error"])
        {
            //@"微博分享成功";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"微博分享成功" duration:1 position:@"center" isShadow:NO];
            [self performSelector:@selector(hideSinaVC) withObject:nil afterDelay:1];
        }
        else if([[dic objectForKey:@"error"] rangeOfString:@"repeat content"].location < [[dic objectForKey:@"error"] length])
        {
            //@"已经分享过啦";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"已经分享过啦" duration:1 position:@"center" isShadow:NO];
        }
        else if([[dic objectForKey:@"error"] rangeOfString:@"miss required parameter (status)"].location < [[dic objectForKey:@"error"] length])
        {
            //@"请完善微博文字";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"请完善微博文字" duration:1 position:@"center" isShadow:NO];
        }
        else if(sinaVC.isWordTooLong == 1)
        {
            //@"您发布的微博消息过长";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"您发布的微博消息过长" duration:1 position:@"center" isShadow:NO];
        }
        else if([[dic objectForKey:@"error"] rangeOfString:@"(WeiBoSDKErrorDomain error 100.)"].location < [[dic objectForKey:@"error"] length]) //原因是应用没通过审核之前需添加测试用户才可以成功读取发送微博
        {
            //@"应用没通过审核之前,需添加测试用户才可以发微博";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"应用没通过审核之前,需添加测试用户才可以发微博" duration:1 position:@"center" isShadow:NO];
        }
        else if([[dic objectForKey:@"error"] rangeOfString:@"似乎已断开与互联网的连接"].location < [[dic objectForKey:@"error"] length])
        {
            //@"请检查网络连接";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"请检查网络连接" duration:1 position:@"center" isShadow:NO];
        }
        else
        {
            //@"微博分享失败";
            
            [self.sinaVC.view hideToast];
            [self.sinaVC.view makeToast:@"微博分享失败" duration:1 position:@"center" isShadow:NO];
        }
    }
    [myResponseString release];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSString *responseString = [request responseString];
    //MYLog(@"requestFailed  :(  responseString:%@",responseString);
    
    [self.sinaVC.view hideToast];
    [self.sinaVC.view makeToast:@"微博分享失败" duration:1 position:@"center" isShadow:NO];
}

// SinaWeiboRequest Delegate
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    // MYLog(@"didFailWithError %@", error);
    
    if([[error description] rangeOfString:@"error=repeat content"].location < [[error description] length])
    {
        //@"已经分享过啦";
        
        [self.sinaVC.view hideToast];
        [self.sinaVC.view makeToast:@"已经分享过啦" duration:1 position:@"center" isShadow:NO];
    }
    else if([[error description] rangeOfString:@"error=miss required parameter (status)"].location < [[error description] length])
    {
        //@"请完善微博文字";
        
        [self.sinaVC.view hideToast];
        [self.sinaVC.view makeToast:@"请完善微博文字" duration:1 position:@"center" isShadow:NO];
    }
    else if(sinaVC.isWordTooLong == 1)
    {
        //@"您发布的微博消息过长";
        
        [self.sinaVC.view hideToast];
        [self.sinaVC.view makeToast:@"您发布的微博消息过长" duration:1 position:@"center" isShadow:NO];
    }
    else if([[error description] rangeOfString:@"(WeiBoSDKErrorDomain error 100.)"].location < [[error description] length]) //原因是应用没通过审核之前需添加测试用户才可以成功读取发送微博
    {
        //@"应用没通过审核之前,需添加测试用户才可以发微博";
        
        [self.sinaVC.view hideToast];
        [self.sinaVC.view makeToast:@"应用没通过审核之前,需添加测试用户才可以发微博" duration:2 position:@"center" isShadow:NO];
    }
    else if([[error description] rangeOfString:@"似乎已断开与互联网的连接"].location < [[error description] length])
    {
        //@"请检查网络连接";
        
        [self.sinaVC.view hideToast];
        [self.sinaVC.view makeToast:@"请检查网络连接" duration:1 position:@"center" isShadow:NO];
    }
    else
    {
        //@"微博分享失败";
        
        [self.sinaVC.view hideToast];
        [self.sinaVC.view makeToast:@"微博分享失败" duration:1 position:@"center" isShadow:NO];
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    [self.sinaVC.view hideToast];
    [self.sinaVC.view makeToast:@"微博分享成功" duration:1 position:@"center" isShadow:NO];
    
    [self performSelector:@selector(hideSinaVC) withObject:nil afterDelay:1];
}
-(void)hideSinaVC
{
    [self.sinaVC dismissViewControllerAnimated:YES completion:nil];
    [self performSelector:@selector(releaseSinaVC) withObject:nil afterDelay:1];
}
-(void)releaseSinaVC
{
    self.sinaVC = nil;
}


@end
