//
//  CityLoginViewController.m
//  CityGuide
//
//  Created by lide on 13-3-9.
//  Copyright (c) 2013年 com.qyer. All rights reserved.
//




#import "CityLoginViewController.h"
#import <CommonCrypto/CommonDigest.h>   //md5
#import "ASIFormDataRequest.h"
#import "CityRegisterViewController.h"
#import "RegisterByPhoneViewController.h"
#import "ThirdLoginViewController.h"
#import "EditUserNameRegisterViewController.h"
#import "UserNameLogInViewController.h"
#import "PhoneGetPassWordViewController.h"
#import "Toast+UIView.h"
#import "NSString+SBJSON.h"
#import "MobClick.h"
#import "CalloutButton.h"
#import <QuartzCore/QuartzCore.h>
#import "LinkControl.h"
#import "Reachability.h"
#import "Account.h"
#import "QyerSns.h"
#import "WXApi.h"
#import "WeiboApi.h"
#import "QYIMObject.h"

#import "Toast+UIView.h"

#define     getdatamaxtime          10      //登录时-请求超时时间


@interface CityLoginViewController ()<EditUserNameSuccessDelegate>

@end

@implementation CityLoginViewController
@synthesize guideViewCell=_guideViewCell;
@synthesize commontFlag;
@synthesize type;
@synthesize _weixinCode;
@synthesize _weixinUserToken;
@synthesize _weixinUserName;
@synthesize _weixinOpenID;
@synthesize _sinaUserID;
@synthesize _sinaUserToken;
@synthesize _sinaUserName;

#pragma mark -
#pragma mark --- viewWillAppear 和 viewWillDisappear
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"登录"];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MobClick endLogPageView:@"登录"];
    
    [self.view hideToast];
    [self.view hideToastActivity];
}




#pragma mark - private

- (NSString *)encodeAccountWithName:(NSString*)username password:(NSString *)password
{
    NSRange range;
    range.length = 2;
    range.location = 0;
    NSString *s1 = [username substringWithRange:range];
    NSString *s2 = [password substringWithRange:range];
    range.length = 2;
    range.location = [username length]-2;
    NSString *s3 = [username substringWithRange:range];
    
    range.length = 2;
    range.location = [password length]-2;
    NSString *s4 = [password substringWithRange:range];
    
    
    NSString *myOnlyString = [NSString stringWithFormat:@"%@%@%@%@",s1,s2,s3,s4];
    NSString *str = [self md5:myOnlyString];
    NSString *outStr = [self md5:str];
    return outStr;
    
}
-(NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr,strlen(cStr), result );
    
    NSString *outStr = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        result[0], result[1], result[2], result[3],
                        result[4], result[5], result[6], result[7],
                        result[8], result[9], result[10], result[11],
                        result[12], result[13], result[14], result[15]
                        ];
    return outStr;
}

- (void)clickCancelButton
{
    signFlag = 0;
    
    [self.view hideToast];
    [MobClick event:@"loginCancel"];
    
    //*** 'from_comment_to_login'的值为2时表示登录成功
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"from_comment_to_login"] isEqualToString:@"1"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"from_comment_to_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"from_comment_to_login"] isEqualToString:@"1"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:@"from_comment_to_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    
    
    if(_flag_logSuccess == YES)
    {
        [QYIMObject getInstance].connectStatus = QYIMConnectStatusOffLine;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logininsuccess" object:nil userInfo:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    if(commontFlag == 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginToCommentClick" object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginToCommentClick2" object:nil];
    }
    
    commontFlag = 0;
    
}

//注册:
- (void)clickRegisterButton:(id)sender
{
    if(signFlag == 0)
    {
        [MobClick event:@"signupClickSignup"];
        
//        RegisterByPhoneViewController *cityRegisterVC = [[RegisterByPhoneViewController alloc] init];
//        [self.navigationController pushViewController:cityRegisterVC animated:YES];
//        [cityRegisterVC release];
        
        CityRegisterViewController * cityRegisterVC = [[CityRegisterViewController alloc]init];
        [self.navigationController pushViewController:cityRegisterVC animated:YES];
        [cityRegisterVC release];
    }
}

//微信登陆:
-(void)clickWeixinLoginButton:(id)sender
{
    BOOL installedflag = [WXApi isWXAppInstalled];
    BOOL supportedflag = [WXApi isWXAppSupportApi];
    
    if (installedflag && supportedflag)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weixinLogIn:) name:@"DidWeixinLogIn" object:nil];
        
        SendAuthReq * req = [[[SendAuthReq alloc]init]autorelease];
        req.scope = @"snsapi_userinfo";
        req.state = @"qyer";
        [WXApi sendReq:req];
    }
    
    else{
        if (!installedflag) {
            [self.view makeToast:@"你的设备未安装微信客户端" duration:1.2f position:@"center" isShadow:NO];
        }
        else if(!supportedflag){
            [self.view makeToast:@"微信版本不支持联合登录" duration:1.2f position:@"center" isShadow:NO];
        }
    }    

}

-(void)weixinLogIn:(NSNotification *)notification
{
    NSString * str = [NSString stringWithFormat:@"%@",[notification object]];
 
    
    if ([str rangeOfString:@"code="].length > 0) {
        
        NSString * strrrr = [[str componentsSeparatedByString:@"code="]objectAtIndex:1];
        NSString * code = [[strrrr componentsSeparatedByString:@"&"]objectAtIndex:0];
        
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DidWeixinLogIn" object:nil];
        
        if ([code isEqualToString:@"authdeny"] || [code isEqualToString:@""]) {
            [self.view makeToast:@"取消微信授权" duration:1.2f position:@"center" isShadow:NO];
        }
        else{
            [self getWeixinAccessToken:code];
        }
    }
    
    else{
        [self.view makeToast:@"取消微信授权" duration:1.2f position:@"center" isShadow:NO];
    }
    
}

-(void)getWeixinAccessToken:(NSString *)code
{
    _weixinCode = code;
    
    NSString * stringgg = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WeixinAppID,WeixinAppSecret,_weixinCode];
    
    ASIHTTPRequest * requst = [[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:stringgg]]autorelease];

    [requst setDelegate:self];
    [requst setRequestMethod:@"POST"];
    [requst setDidFinishSelector:@selector(didGetWeixinTokenSuccess:)];
    [requst setDidFailSelector:@selector(didGetWeixinTokenFailed:)];
    [requst startAsynchronous];
}

-(void)didGetWeixinTokenSuccess:(ASIHTTPRequest *)request
{
    NSString *result = [request responseString];
    if (result.length > 0) {
        
        NSDictionary * dicttt = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:nil];
        
        _weixinUserToken = [[dicttt objectForKey:@"access_token"] retain];
        
        [self getWeixinUserInfoWithToken:[dicttt objectForKey:@"access_token"] andID:[dicttt objectForKey:@"openid"]];
    }

}

-(void)didGetWeixinTokenFailed:(ASIHTTPRequest *)request
{
    [self.view makeToast:@"网络错误，请重试" duration:1.2f position:@"center" isShadow:NO];
}


-(void)getWeixinUserInfoWithToken:(NSString *)token andID:(NSString *)openId
{
    NSString * stringgg = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",token,openId];
    
    ASIHTTPRequest * requst = [[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:stringgg]]autorelease];
    [requst setDelegate:self];
    [requst setRequestMethod:@"POST"];
   
    [requst setDidFailSelector:@selector(getWeixinUserInfoDidFailed:)];
    [requst setDidFinishSelector:@selector(getWeixinUserInfoDidSuccess:)];
    
    [requst startAsynchronous];
}

-(void)getWeixinUserInfoDidSuccess:(ASIHTTPRequest *)requst
{
    NSString *result = [requst responseString];
    if (result.length > 0) {
        NSDictionary * dicttt = [NSJSONSerialization JSONObjectWithData:[requst responseData] options:NSJSONReadingMutableContainers error:nil];
        
        _weixinUserName = [[dicttt objectForKey:@"nickname"] retain];
        _weixinOpenID = [[dicttt objectForKey:@"openid"] retain];
        
        [self sendWeixinUserIDToServer];
        
        
//        if (_weixinUserName.length < 2) {
//            [self.view makeToast:@"昵称字数小于2位" duration:1.0f position:@"center" isShadow:NO];
//            [self performSelector:@selector(shouldEditWeixinUserName) withObject:nil afterDelay:1.5];
//        }
//        
//        if (_weixinUserName.length > 15) {
//            [self.view makeToast:@"昵称字数大于15位" duration:1.0f position:@"center" isShadow:NO];
//            [self performSelector:@selector(shouldEditWeixinUserName) withObject:nil afterDelay:1.5];
//        }
//        
//        else if(_weixinUserName.length >= 2 && _weixinUserName.length <= 15){
//            [self sendWeixinUserIDToServer];
//        }
        
    }
}

-(void)getWeixinUserInfoDidFailed:(ASIHTTPRequest *)request
{
    [self.view makeToast:@"网络错误，请重试" duration:1.2f position:@"center" isShadow:NO];
}



//-(void)shouldEditWeixinUserName
//{
//    [[NSUserDefaults standardUserDefaults]setValue:_weixinUserName forKey:@"weixinUserName"];
//    [self weixinUserNameAlreadyExitsWithUserName:_weixinUserName UserID:_weixinOpenID UserToken:_weixinUserToken];
//}

-(void)sendWeixinUserIDToServer
{
    [self.view makeToastActivity];
    
    for (UIButton * btn in self.view.subviews) {
        if ([btn isEqual:_cancelButton]) {
            [btn setEnabled:YES];
        }
        else{
            [btn setEnabled:NO];
        }
    }
    [_titleLabel setEnabled:YES];
        
   [[QYAPIClient sharedAPIClient]sendSNSToServerWithType:@"weixin"
                                            Access_Token:_weixinUserToken
                                                     UID:_weixinOpenID
                                            SNS_Username:_weixinUserName
                                                 success:^(NSDictionary *dic) {
                                                     
                                                     [self.view hideToastActivity];
                                                     
                                                     for (UIButton * btn in self.view.subviews) {
                                                         [btn setEnabled:YES];
                                                     }
                                                     
                                                     NSInteger statusType = [[dic objectForKey:@"status"]integerValue];
                                                     
                                                     if (statusType == 1) {
                                                         
                                                         [self.view makeToast:@"微信登录成功" duration:1.2f position:@"center" isShadow:NO];
                                                         
                                                         NSDictionary * userInfo = [dic objectForKey:@"data"];
                                                         NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
                                                         
                                                         [myDefault setObject:[NSNumber numberWithBool:YES] forKey:@"qyerlogin"];
                                                         [myDefault setValue:[userInfo valueForKey:@"access_token"] forKey:@"user_access_token"];
                                                         [myDefault setObject:[userInfo objectForKey:@"user_id"] forKey:@"userid"];
                                                         [myDefault setValue:[userInfo objectForKey:@"username"] forKey:@"username"];
                                                         [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"usericon"];
                                                         [myDefault setValue:[userInfo objectForKey:@"title"] forKey:@"title"];
                                                         
                                                         if (![[userInfo objectForKey:@"im_user_id"] isEqual:[NSNull null]]) {
                                                             [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"userid_im"];
                                                             [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"im_user_id"];
                                                         }
                                                         [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"avatar"];
                                                         [myDefault synchronize];
                                                         
                                                         [[Account sharedAccount] initAccountWithDic:[dic objectForKey:@"data"]];
                                                         _flag_logSuccess = YES;
                                                         
                                                         [self performSelector:@selector(clickCancelButton) withObject:nil afterDelay:1];
                                                     }
                                                     
                                                     else{
                                                         NSString * infooo = [dic objectForKey:@"info"];
                                                         
                                                          [self weixinUserNameAlreadyExitsWithUserName:_weixinUserName UserID:_weixinOpenID UserToken:_weixinUserToken Info:infooo];
                                                     }
                                                     
                                                     
//                                                     NSDictionary * dicttt = [dic objectForKey:@"data"];
//                                                     NSInteger resultType = [[dicttt objectForKey:@"result"]integerValue];
//                                                     
//                                                     if (resultType == 0) {
//                                                         [self.view makeToast:@"授权失败" duration:1.2f position:@"center" isShadow:NO];
//                                                     }
//                                                     
//                                                     if (resultType == 1) {
//                                                         [self.view makeToast:@"微信登录成功" duration:1.2f position:@"center" isShadow:NO];
//                                                     
//                                                         NSDictionary * userInfo = [[dic objectForKey:@"data"] objectForKey:@"user"];
//                                                     
//                                                         NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
//                                                         [myDefault setObject:[NSNumber numberWithBool:YES] forKey:@"qyerlogin"];
//                                                         [myDefault setValue:[userInfo valueForKey:@"access_token"] forKey:@"user_access_token"];
//                                                         [myDefault setObject:[userInfo objectForKey:@"user_id"] forKey:@"userid"];
//                                                         [myDefault setValue:[userInfo objectForKey:@"username"] forKey:@"username"];
//                                                         [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"usericon"];
//                                                         [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"userid_im"];
//                                                         [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"im_user_id"];
//                                                         [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"avatar"];
//                                                         [myDefault synchronize];
//                                                         
//                                                         [[Account sharedAccount] initAccountWithDic:[dic objectForKey:@"data"]];
//                                                         _flag_logSuccess = YES;
//                                                         
//                                                         [self performSelector:@selector(clickCancelButton) withObject:nil afterDelay:1];
//                                                     }
//                                                     
//                                                     if (resultType == 2) {
////                                                         [self.view makeToast:@"授权用户名已存在" duration:1.2f position:@"center" isShadow:NO];
//                                                         
//                                                         [self.view makeToast:@"微信登录成功" duration:1.2f position:@"center" isShadow:NO];
//                                                         
//                                                         NSDictionary * userInfo = [[dic objectForKey:@"data"] objectForKey:@"user"];
//                                                         
//                                                         NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
//                                                         [myDefault setObject:[NSNumber numberWithBool:YES] forKey:@"qyerlogin"];
//                                                         [myDefault setValue:[userInfo valueForKey:@"access_token"] forKey:@"user_access_token"];
//                                                         [myDefault setObject:[userInfo objectForKey:@"user_id"] forKey:@"userid"];
//                                                         [myDefault setValue:[userInfo objectForKey:@"username"] forKey:@"username"];
//                                                         [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"usericon"];
//                                                         [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"userid_im"];
//                                                         [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"im_user_id"];
//                                                         [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"avatar"];
//                                                         [myDefault synchronize];
//                                                         
//                                                         [[Account sharedAccount] initAccountWithDic:[dic objectForKey:@"data"]];
//                                                         _flag_logSuccess = YES;
//                                                         
//                                                         [self performSelector:@selector(clickCancelButton) withObject:nil afterDelay:1];
//                                                         
//                                                         [self weixinUserNameAlreadyExitsWithUserName:_weixinUserName UserID:_weixinOpenID UserToken:_weixinUserToken];
//                                                     }
                                                    
                                                 } failed:^{
                                                     
                                                     for (UIButton * btn in self.view.subviews) {
                                                         [btn setEnabled:YES];
                                                     }
                                                     
                                                     [self.view hideToastActivity];
                                                     [self.view makeToast:@"网络错误，请稍后重试" duration:1.2f position:@"center" isShadow:NO];
                                                 }];
}


//Weibo登陆:
- (void)clickWeiboLoginButton:(id)sender
{
    [_qyer loginOutSinaWeibo];
    
    [_qyer.sinaweibo logIn];
    
    [MobClick event:@"loginClickweibologin"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"weibologin"];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"qqlogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    [_qyer storeAuthData];
    
    _sinaUserID = sinaweibo.userID;
    _sinaUserToken = sinaweibo.accessToken;
    
    [self getWeiboUserInfo:sinaweibo.userID];
}

-(void)getWeiboUserInfo:(NSString *)uid
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setValue:uid forKeyPath:@"uid"];
    
    [self.view makeToastActivity];
    
    [_qyer.sinaweibo requestWithURL:@"users/show.json" params:dict httpMethod:@"GET" delegate:self];
}

- (void)request:(SinaWeiboRequest *)request didReceiveRawData:(NSData *)data
{
    [_sinaRequestData appendData:data];
}

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error;
{
    [self.view hideToastActivity];
    [self.view makeToast:@"网络错误，请稍后重试" duration:1.2f position:@"center" isShadow:NO];
}

-(void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result;
{
    [self.view hideToastActivity];
    
    NSDictionary * dict = (NSDictionary *)result;
    _sinaUserName = [dict objectForKey:@"name"];
        
    if (![_sinaUserName isEqualToString:@""]) {
        
        [self sendWeiboUserIDToServer];
    }
}


-(void)sendWeiboUserIDToServer
{
    [self.view makeToastActivity];
    
    for (UIButton * btn in self.view.subviews) {
        if ([btn isEqual:_cancelButton]) {
            [btn setEnabled:YES];
        }
        else{
            [btn setEnabled:NO];
        }
    }
    
    [[QYAPIClient sharedAPIClient]sendSNSToServerWithType:@"sina"
                                             Access_Token:_sinaUserToken
                                                      UID:_sinaUserID
                                             SNS_Username:_sinaUserName
                                                  success:^(NSDictionary *dic) {
                                                      
                                                      [self.view hideToastActivity];
                                                      
                                                      for (UIButton * btn in self.view.subviews) {
                                                          [btn setEnabled:YES];
                                                      }
                                                      
                                                      NSInteger statusType = [[dic objectForKey:@"status"]integerValue];
                                                      
                                                      if (statusType == 1) {
                                                          
                                                          [self.view makeToast:@"微博登录成功" duration:1.2f position:@"center" isShadow:NO];
                                                          
                                                          NSDictionary * userInfo = [dic objectForKey:@"data"];
                                                          NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
                                                          
                                                          [myDefault setObject:[NSNumber numberWithBool:YES] forKey:@"qyerlogin"];
                                                          [myDefault setValue:[userInfo valueForKey:@"access_token"] forKey:@"user_access_token"];
                                                          [myDefault setObject:[userInfo objectForKey:@"user_id"] forKey:@"userid"];
                                                          [myDefault setValue:[userInfo objectForKey:@"username"] forKey:@"username"];
                                                          [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"usericon"];
                                                          [myDefault setValue:[userInfo objectForKey:@"title"] forKey:@"title"];
                                                          
                                                          if (![[userInfo objectForKey:@"im_user_id"] isEqual:[NSNull null]]) {
                                                              [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"userid_im"];
                                                              [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"im_user_id"];
                                                          }
                                                          
                                                          [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"avatar"];
                                                          [myDefault synchronize];
                                                          
                                                          [[Account sharedAccount] initAccountWithDic:[dic objectForKey:@"data"]];
                                                          _flag_logSuccess = YES;
                                                          
                                                          [self performSelector:@selector(clickCancelButton) withObject:nil afterDelay:1];
                                                      }
                                                      
                                                      else{
                                                          NSString * infooo = [dic objectForKey:@"info"];
                                                          
                                                          [self sinaUserNameAlreadyExitsWithUserName:_sinaUserName UserID:_sinaUserID UserToken:_sinaUserToken Info:infooo];
                                                      }

                                                      
                                                  } failed:^{
                                                      [self.view hideToastActivity];
                                                      
                                                      for (UIButton * btn in self.view.subviews) {
                                                          [btn setEnabled:YES];
                                                      }
                                                      
                                                      [self.view makeToast:@"网络错误，请稍后重试" duration:1.2f position:@"center" isShadow:NO];
                                                  }];
}



-(void)weixinUserNameAlreadyExitsWithUserName:(NSString *)name UserID:(NSString *)uid UserToken:(NSString *)token Info:(NSString *)info
{    
    EditUserNameRegisterViewController * editVC = [[EditUserNameRegisterViewController alloc]init];
    editVC.delegate = self;
    [editVC.infoDictionary setValue:uid forKey:@"userID"];
    [editVC.infoDictionary setValue:name forKey:@"userName"];
    [editVC.infoDictionary setValue:token forKey:@"userToken"];
    [editVC.infoDictionary setValue:@"weixin" forKey:@"type"];
    [editVC.infoDictionary setValue:info forKey:@"errorInfo"];
    
    [self presentViewController:editVC animated:YES completion:nil];
    [editVC release];
}

-(void)sinaUserNameAlreadyExitsWithUserName:(NSString *)name UserID:(NSString *)uid UserToken:(NSString *)token Info:(NSString *)infooo
{
    EditUserNameRegisterViewController * editVC = [[EditUserNameRegisterViewController alloc]init];
    editVC.delegate = self;
    NSString * sinaName = [[NSUserDefaults standardUserDefaults]valueForKey:@"sinaUserName"];
    [editVC.infoDictionary setValue:uid forKey:@"userID"];
    [editVC.infoDictionary setValue:sinaName forKey:@"userName"];
    [editVC.infoDictionary setValue:token forKey:@"userToken"];
    [editVC.infoDictionary setValue:@"sina" forKey:@"type"];
    [editVC.infoDictionary setValue:infooo forKey:@"errorInfo"];
    [self presentViewController:editVC animated:YES completion:nil];
    [editVC release];
}

-(void)didEditUserNameSuccess
{
    _flag_logSuccess = YES;
    [self.view makeToast:@"登录成功" duration:1.0f position:@"center" isShadow:NO];
    [self performSelector:@selector(clickCancelButton) withObject:nil afterDelay:1.0f];
}


//qq登陆:
- (void)clickQQLoginButton:(id)sender
{
    [MobClick event:@"loginClickqqlogin"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"qqlogin"];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"weibologin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    ThirdLoginViewController *thirdLoginVC = [[ThirdLoginViewController alloc] init];
    thirdLoginVC.titleText = @"QQ登录";
    thirdLoginVC.loginURL = [NSString stringWithFormat:@"http://login.qyer.com/login.php?action=qq&ismobile=1&client=%@&client_secret=%@", ClientId_QY, ClientSecret_QY];
    [self.navigationController pushViewController:thirdLoginVC animated:YES];
    //[self presentModalViewController:thirdLoginVC animated:YES];
    [thirdLoginVC release];
}

//点击登陆按钮:
- (void)clickLoginButton:(id)sender
{
    if([_usernameTextField.text length]<2 || [_passwordTextField.text length] == 0)
    {
        [self.view hideToast];
        [self.view makeToast:@"请完整填写" duration:1.0 position:@"center" isShadow:NO];
        
    }
    else if([_passwordTextField.text length] < 6 || [_passwordTextField.text length] > 16)
    {
        [self.view hideToast];
        [self.view makeToast:@"密码长度:6~16位" duration:1.0 position:@"center" isShadow:NO];
        
    }
    else
    {
        if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)
        {
            if(signFlag == 0)
            {
                signFlag = 1;
                
                [self.view hideToast];
                [self.view makeToast:@"正在登录..." duration:0.0 position:@"center" isShadow:NO];
                [self performSelector:@selector(doLogin) withObject:nil afterDelay:0];
            }
        }
        else
        {
            [self.view hideToast];
            [self.view makeToast:@"请检查网络连接" duration:1.0 position:@"center" isShadow:NO];
        }
    }
}

-(void)doLogin
{
    _flag_logSuccess = NO;
    
    //NSString *urlStr = @"http://open.qyer.com/user/login";
    NSString *urlStr = [NSString stringWithFormat:@"%@/qyer/user/login",DomainName];
    
    
    urlStr = [[QYAPIClient sharedAPIClient]addTrackInfoWithUrlString:urlStr];
    
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *account_s = [self encodeAccountWithName:_usernameTextField.text password:_passwordTextField.text];
    ASIFormDataRequest *_loginRequest  = [[ASIFormDataRequest alloc] initWithURL:url];
    _loginRequest.delegate = self;
    _loginRequest.shouldRedirect = YES; //网页自动跳转[例:从'go2eu'跳转到'qyer']!!
    _loginRequest.timeOutSeconds = getdatamaxtime;
    _loginRequest.requestMethod = @"POST";
    [_loginRequest addPostValue:ClientId_QY forKey:@"client_id"];
    [_loginRequest addPostValue:ClientSecret_QY forKey:@"client_secret"];
    [_loginRequest addPostValue:_usernameTextField.text forKey:@"username"];
    [_loginRequest addPostValue:_passwordTextField.text forKey:@"password"];
    [_loginRequest addPostValue:@"password" forKey:@"grant_type"];
    [_loginRequest addPostValue:account_s forKey:@"account_s"];
    
    NSString *lat_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lat_user"]];
    NSString *lon_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lon_user"]];
    if (![lat_user isEqualToString:@""] && ![lon_user isEqualToString:@""]) {
        [_loginRequest setPostValue:lat_user forKey:@"lat"];
        [_loginRequest setPostValue:lon_user forKey:@"lon"];
    }
    
    
    [_loginRequest setDidFailSelector:@selector(loginRequestDidFailed:)];
    [_loginRequest setDidFinishSelector:@selector(loginRequestDidSuccess:)];
    
    [_loginRequest startAsynchronous];
}

- (void)loginRequestDidSuccess:(ASIHTTPRequest *)request
{
    //***(1)Use when fetching text data
    NSString *responseString2 = [request responseString];
    NSMutableString *responseString = [[NSMutableString alloc] initWithString:responseString2];
    
    signFlag = 0;
    
    NSMutableDictionary *dic = [responseString JSONValue];
    
    NSString *result = [NSString stringWithFormat:@"%@",[dic valueForKey:@"access_token"]];
    
    if([[dic valueForKey:@"info"] isEqualToString:@"账号或密码错误"])
    {
        [self.view hideToast];
        [self.view makeToast:@"您的账号和密码不符,请再试一次." duration:1 position:@"center" isShadow:NO];
    }
    else if([[dic valueForKey:@"error"] length] > 0)
    {
        [self.view hideToast];
        [self.view makeToast:@"您的账号和密码不符,请再试一次." duration:1 position:@"center" isShadow:NO];
    }
    else if([responseString rangeOfString:@"timed out"].location != NSNotFound)
    {
        [self.view hideToast];
        [self.view makeToast:@"登录失败" duration:1 position:@"center" isShadow:NO];
    }
    else if([result length] > 1)
    {
        [self.view hideToast];
        [self.view makeToast:@"登录成功" duration:1 position:@"center" isShadow:NO];
        
        [MobClick event:@"loginSucceed"];
        
        dic = [dic objectForKey:@"data"];
        NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
        [myDefault setObject:[NSNumber numberWithBool:YES] forKey:@"qyerlogin"];
        [myDefault setValue:[dic objectForKey:@"access_token"] forKey:@"user_access_token"];
        [myDefault setValue:[dic objectForKey:@"user_id"] forKey:@"userid"];
        [myDefault setValue:[dic objectForKey:@"username"] forKey:@"username"];
        [myDefault setValue:[dic objectForKey:@"avatar"] forKey:@"usericon"];
        [myDefault setValue:[dic objectForKey:@"title"] forKey:@"title"];
        if (![[dic objectForKey:@"im_user_id"] isEqual:[NSNull null]]) {
            [myDefault setValue:[dic objectForKey:@"im_user_id"] forKey:@"userid_im"];
            [myDefault setValue:[dic objectForKey:@"im_user_id"] forKey:@"im_user_id"];
        }
        [myDefault synchronize];
        
        
        
        [[Account sharedAccount] initAccountWithDic:dic];
        
        _flag_logSuccess = YES;
        
        signFlag = 0;
        
        [self doSomethingAfterLoginSuccessed];
        [self performSelector:@selector(clickCancelButton) withObject:nil afterDelay:1];
    }
    else
    {
        [self.view hideToast];
        [self.view makeToast:@"登录失败" duration:1.0 position:@"center" isShadow:NO];
    }
    [responseString release];
}

- (void)loginRequestDidFailed:(ASIHTTPRequest *)request
{
//    NSString *responseString2 = [request responseString];
    
    [self.view hideToast];
    [self.view makeToast:@"登录失败" duration:1 position:@"center" isShadow:NO];
    
    signFlag = 0;
}

- (void)doSomethingAfterLoginSuccessed
{
    
}

#pragma mark - super

- (id)init
{
    self = [super init];
    if(self != nil)
    {
    
    }
    return self;
}

- (void)dealloc
{
    QY_SAFE_RELEASE(_sinaRequestData);
    
    QY_SAFE_RELEASE(_qyer);
    
    QY_VIEW_RELEASE(_scrollView);
    QY_VIEW_RELEASE(_cancelButton);
    QY_VIEW_RELEASE(_registerButton);
    QY_VIEW_RELEASE(_weixinLoginButton);
    QY_VIEW_RELEASE(_weiboLoginButton);
    QY_VIEW_RELEASE(_qqLoginButton);
    QY_VIEW_RELEASE(_lineImageView);
    QY_VIEW_RELEASE(_usernameTextField);
    QY_VIEW_RELEASE(_passwordTextField);
    QY_VIEW_RELEASE(_loginLabel);
    
    self.type = nil;
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    _flag_logSuccess = NO;
    
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
    if(ios7)
    {
        _headView.frame = CGRectMake(0, 0, 320, 46+20);
    }
    _headView.backgroundColor = [UIColor clearColor];
//    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, 200, 30)];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    if(ios7)
    {
        _titleLabel.frame = CGRectMake(60, 10+20, 200, 26);
    }
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];
    
    
    _backButton.hidden = YES;
    _titleLabel.text = @"帐号登录";
    
 
    
    
    if(ios7)
    {
        _scrollView = [[UIView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, [[UIScreen mainScreen] bounds].size.height-_headView.frame.size.height)];
    }
    else
    {
        _scrollView = [[UIView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, ([[UIScreen mainScreen] bounds].size.height-20)-_headView.frame.size.height)];
    }
    _scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollView];
    [self.view bringSubviewToFront:_headView];
    
    
    _cancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_cancelButton setExclusiveTouch:YES];
    _cancelButton.frame = CGRectMake(6, 6, 47, 33);
    if(ios7)
    {
        _cancelButton.frame = CGRectMake(6, 6+20, 47, 33);
    }
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_more_cancel.png"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(clickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    if(self.type && [self.type isEqualToString:@"mineinfo"])
    {
        _cancelButton.hidden = YES;
    }
    [self.view addSubview:_cancelButton];

    
    UIButton *button_register = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_register setExclusiveTouch:YES];
    button_register.frame = CGRectMake( 244, 7 , 66, 30);
    if (ios7) {
        button_register.frame = CGRectMake( 244, 27 , 66, 30);
    }
    button_register.backgroundColor = [UIColor clearColor];
    [button_register setBackgroundImage:[UIImage imageNamed:@"loginVC_sign_up"] forState:UIControlStateNormal];
    [button_register setBackgroundImage:[UIImage imageNamed:@"loginVC_sign_up_pressed"] forState:UIControlStateHighlighted];
    [button_register addTarget:self action:@selector(clickRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_register];
    
    
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [_scrollView addSubview:control];
    control.backgroundColor = [UIColor clearColor];
    [control addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [control release];
    
    
    UIView *qyerLoginViewBG = [[UIView alloc] initWithFrame:CGRectMake(13, (194-128)/2, 294, 88)];
    qyerLoginViewBG.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:qyerLoginViewBG];
    qyerLoginViewBG.userInteractionEnabled = YES;
    
    
//    UILabel * countryNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 55, 44)];
//    [countryNumberLabel setTag:789789];
//    [countryNumberLabel setUserInteractionEnabled:YES];
//    [countryNumberLabel setBackgroundColor:[UIColor clearColor]];
//    [countryNumberLabel setTextAlignment:NSTextAlignmentCenter];
//    [countryNumberLabel setTextColor:[UIColor whiteColor]];
//    [countryNumberLabel setFont:[UIFont systemFontOfSize:17]];
//    [countryNumberLabel setText:@"+86"];
//    [qyerLoginViewBG addSubview:countryNumberLabel];
//    [countryNumberLabel release];
//    
//    UITapGestureRecognizer * countryTappp = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseCountry:)];
//    [countryNumberLabel addGestureRecognizer:countryTappp];
//    [countryTappp release];
//
//    UIButton * chooseCountrtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [chooseCountrtBtn setBackgroundColor:[UIColor clearColor]];
//    [chooseCountrtBtn setFrame:CGRectMake(56, 10, 24, 24)];
//    [chooseCountrtBtn setBackgroundImage:[UIImage imageNamed:@"loginVC_arrow"] forState:UIControlStateNormal];
//    [chooseCountrtBtn setBackgroundImage:[UIImage imageNamed:@"loginVC_arrow_pressed"] forState:UIControlStateHighlighted];
//    [chooseCountrtBtn addTarget:self action:@selector(chooseCountry:) forControlEvents:UIControlEventTouchUpInside];
//    [qyerLoginViewBG addSubview:chooseCountrtBtn];
    
    UIImageView * userIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 24, 24)];
    [userIcon setBackgroundColor:[UIColor clearColor]];
    [userIcon setImage:[UIImage imageNamed:@"loginVC_user"]];
    [qyerLoginViewBG addSubview:userIcon];
    [userIcon release];

//    UILabel * userLabel = [[UILabel alloc]initWithFrame:CGRectMake(32, 10, 85, 24)];
//    [userLabel setBackgroundColor:[UIColor orangeColor]];
//    [userLabel setTextAlignment:NSTextAlignmentLeft];
//    [userLabel setTextColor:[UIColor whiteColor]];
//    [userLabel setFont:[UIFont systemFontOfSize:15]];
//    [userLabel setText:@"邮箱/用户名"];
//    [qyerLoginViewBG addSubview:userLabel];
//    [userLabel release];
    
    NSAttributedString *attributeStrName = [[NSAttributedString alloc] initWithString:@"邮箱/用户名" attributes:@{NSForegroundColorAttributeName: RGB(113, 213, 175)}];
    
    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(32, 12, 294 -42, 20)];
    [_usernameTextField setExclusiveTouch:YES];
    _usernameTextField.delegate = self;
    _usernameTextField.attributedPlaceholder = attributeStrName;
    _usernameTextField.textColor = [UIColor whiteColor];
    _usernameTextField.font = [UIFont systemFontOfSize:17];
    [_usernameTextField setTextAlignment:NSTextAlignmentLeft];
    _usernameTextField.returnKeyType = UIReturnKeyNext;
    [_usernameTextField setKeyboardAppearance:UIKeyboardAppearanceLight];
    _usernameTextField.backgroundColor = [UIColor clearColor];
    _usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [qyerLoginViewBG addSubview:_usernameTextField];
    [attributeStrName release];
    
    
    //电话号码下的白线
    UIView * topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 43, 294, 1)];
    [topLine setBackgroundColor:[UIColor whiteColor]];
    [topLine setAlpha:0.8];
    [qyerLoginViewBG addSubview:topLine];
    [topLine release];
    
    
    UIImageView * passWordIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 54, 24, 24)];
    [passWordIcon setBackgroundColor:[UIColor clearColor]];
    [passWordIcon setImage:[UIImage imageNamed:@"loginVC_password"]];
    [qyerLoginViewBG addSubview:passWordIcon];
    [passWordIcon release];
    
//    UILabel * secretLabel = [[UILabel alloc]initWithFrame:CGRectMake(32, 54, 100, 24)];
//    [secretLabel setBackgroundColor:[UIColor clearColor]];
//    [secretLabel setTextAlignment:NSTextAlignmentLeft];
//    [secretLabel setTextColor:[UIColor whiteColor]];
//    [secretLabel setFont:[UIFont systemFontOfSize:15]];
//    [secretLabel setText:@"密码"];
//    [qyerLoginViewBG addSubview:secretLabel];
//    [secretLabel release];
    
    NSAttributedString *attributeStrPWD = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSForegroundColorAttributeName: RGB(113, 213, 175)}];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(32, 56, 294 -42, 20)];
    [_passwordTextField setExclusiveTouch:YES];
    _passwordTextField.delegate = self;
    _passwordTextField.backgroundColor = [UIColor clearColor];
    _passwordTextField.attributedPlaceholder = attributeStrPWD;
    [_passwordTextField setTextAlignment:NSTextAlignmentLeft];
    _passwordTextField.textColor = [UIColor whiteColor];
    _passwordTextField.font = [UIFont systemFontOfSize:17];
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.returnKeyType = UIReturnKeyDone;
    [_passwordTextField setKeyboardType:UIKeyboardTypeASCIICapable];
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [qyerLoginViewBG addSubview:_passwordTextField];
    [attributeStrPWD release];
    
    
    //密码下的白线
    UIView * bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 87, 294, 1)];
    [bottomLine setBackgroundColor:[UIColor whiteColor]];
    [bottomLine setAlpha:0.8];
    [qyerLoginViewBG addSubview:bottomLine];
    [bottomLine release];
    
    
    UIButton * forgetPasswordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgetPasswordBtn setExclusiveTouch:YES];
    [forgetPasswordBtn setFrame:CGRectMake(247, qyerLoginViewBG.frame.origin.y+qyerLoginViewBG.frame.size.height+18, 65, 20)];
    forgetPasswordBtn.backgroundColor = [UIColor clearColor];
    [forgetPasswordBtn setTitle:@"忘记密码？" forState:UIControlStateNormal];
    [forgetPasswordBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [forgetPasswordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [forgetPasswordBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [forgetPasswordBtn addTarget:self action:@selector(linkForgetPasswordPage) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:forgetPasswordBtn];
    
    
//    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(248.5, forgetPasswordBtn.frame.origin.y+forgetPasswordBtn.frame.size.height-2, 56, 1)];
//    line.backgroundColor = [UIColor whiteColor];
//    line.alpha = 0.8;
//    [_scrollView addSubview:line];

    
    UIButton * button_login = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_login setExclusiveTouch:YES];
    button_login.frame = CGRectMake(70, qyerLoginViewBG.frame.origin.y+qyerLoginViewBG.frame.size.height+126/2, 180, 40);
    button_login.backgroundColor = [UIColor clearColor];
    [button_login setBackgroundImage:[UIImage imageNamed:@"loginVC_login"] forState:UIControlStateNormal];
    [button_login setBackgroundImage:[UIImage imageNamed:@"loginVC_login_pressed"] forState:UIControlStateHighlighted];
    [button_login addTarget:self action:@selector(clickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button_login];
    
    
//    UIButton * userNameLogInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [userNameLogInBtn setFrame:CGRectMake( 70, button_login.frame.origin.y+button_login.frame.size.height+20, 180, 20)];
//    userNameLogInBtn.backgroundColor = [UIColor clearColor];
//    [userNameLogInBtn setTitle:@"或：邮箱/用户名登录" forState:UIControlStateNormal];
//    [userNameLogInBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
//    [userNameLogInBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [userNameLogInBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [userNameLogInBtn addTarget:self action:@selector(userNameLogIn) forControlEvents:UIControlEventTouchUpInside];
//    [_scrollView addSubview:userNameLogInBtn];
    
    
    UIImageView * thirdLogImgView = [[UIImageView alloc]initWithFrame:CGRectMake(68, [_scrollView bounds].size.height- 84 -20, 184, 20)];
    [thirdLogImgView setBackgroundColor:[UIColor clearColor]];
    [thirdLogImgView setImage:[UIImage imageNamed:@"ThirdLogImg"]];
    [_scrollView addSubview:thirdLogImgView];
    [thirdLogImgView release];
    
    
    _weiboLoginButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_weiboLoginButton setExclusiveTouch:YES];
    _weiboLoginButton.frame = CGRectMake(68, [_scrollView bounds].size.height-70, 50, 50);
    [_weiboLoginButton setBackgroundImage:[UIImage imageNamed:@"loginVC_weibo"] forState:UIControlStateNormal];
    [_weiboLoginButton setBackgroundImage:[UIImage imageNamed:@"loginVC_weibo_pressed"] forState:UIControlStateHighlighted];
    _weiboLoginButton.backgroundColor = [UIColor clearColor];
    [_weiboLoginButton addTarget:self action:@selector(clickWeiboLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_weiboLoginButton];
    
    
    _qqLoginButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_qqLoginButton setExclusiveTouch:YES];
    _qqLoginButton.frame = CGRectMake(135, [_scrollView bounds].size.height-70, 50, 50);
    [_qqLoginButton setBackgroundImage:[UIImage imageNamed:@"loginVC_QQ"] forState:UIControlStateNormal];
    [_qqLoginButton setBackgroundImage:[UIImage imageNamed:@"loginVC_QQ_pressed"] forState:UIControlStateNormal];
    _qqLoginButton.backgroundColor = [UIColor clearColor];
    [_qqLoginButton addTarget:self action:@selector(clickQQLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_qqLoginButton];

    
    _weixinLoginButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_weixinLoginButton setExclusiveTouch:YES];
    _weixinLoginButton.frame = CGRectMake(202, [_scrollView bounds].size.height-70, 50, 50);
    [_weixinLoginButton setBackgroundImage:[UIImage imageNamed:@"loginVC_weixin"] forState:UIControlStateNormal];
    [_weixinLoginButton setBackgroundImage:[UIImage imageNamed:@"loginVC_weixin_pressed"] forState:UIControlStateNormal];
    _weixinLoginButton.backgroundColor = [UIColor clearColor];
    [_weixinLoginButton addTarget:self action:@selector(clickWeixinLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_weixinLoginButton];
    
    [qyerLoginViewBG release];
}


-(void)chooseCountry:(id)sender
{
    CountryNumberViewController * countryVC = [[CountryNumberViewController alloc]init];
    [countryVC setDelegate:self];
    [self presentViewController:countryVC animated:YES completion:nil];
    [countryVC release];
}

-(void)didChooseCountry:(NSString *)country Number:(NSString *)number//用户选择国家及编码
{
    [_usernameTextField setText:@""];
    [_usernameTextField setPlaceholder:country];
    
    UILabel * countryNumberLabel = (UILabel *)[self.view viewWithTag:789789];
    [countryNumberLabel setText:country];
}


//-(void)userNameLogIn
//{
//    UserNameLogInViewController * userNameLogVC = [[UserNameLogInViewController alloc]init];
//    [userNameLogVC setDelegate:self];
//    [self.navigationController pushViewController:userNameLogVC animated:YES];
//    [userNameLogVC release];
//}

-(void)UserNameDidLogInSuccess
{
    [self.view makeToastActivity];
    [self performSelector:@selector(userNameDidLogIn) withObject:nil afterDelay:1.0f];
}

-(void)userNameDidLogIn
{
    [self.view hideToastActivity];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)linkForgetPasswordPage
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://login.qyer.com/getpass.php"]];
    
//    NSArray *array = [NSArray arrayWithObjects:@"手机找回密码",@"邮箱找回密码",nil];
//    CCActiotSheet *sheet = [[CCActiotSheet alloc] initWithTitle:nil andDelegate:self andArrayData:array];
//    [sheet setTag:500001];
//    [sheet show];
//    [sheet release];
}

//- (void)ccActionSheet:(CCActiotSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (actionSheet.tag == 500001) {
//        if (buttonIndex == 1) {
//            PhoneGetPassWordViewController * getPassWordVC = [[PhoneGetPassWordViewController alloc]init];
//            [self.navigationController pushViewController:getPassWordVC animated:YES];
//            [getPassWordVC release];
//        }
//        
//        if (buttonIndex == 2) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://login.qyer.com/getpass.php"]];
//        }
//    }
//}


-(void)viewDidLoad
{
    [super viewDidLoad];    
 
    [self.view setMultipleTouchEnabled:NO];

    _weixinCode = [NSString string];
    _weixinUserToken = [NSString string];
    _weixinUserName = [NSString string];
    _weixinOpenID = [NSString string];

    _sinaRequestData = [[NSMutableData alloc]init];
    _sinaUserID = [NSString string];
    _sinaUserName = [NSString string];
    _sinaUserToken = [NSString string];

    _qyer = [[QyerSns sharedQyerSns]retain];
    [_qyer.sinaweibo setDelegate:self];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginWithUserinfo:) name:@"REGISTER_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thirdLoginSuccess:) name:@"THIRD_LOGIN_SUCCESS" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark --- tap
-(void)tap:(id)sender
{
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

#pragma mark -
#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == _usernameTextField)
    {
        [_passwordTextField becomeFirstResponder];
    }
    else
    {
        [self clickLoginButton:nil];
    }
    
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    if(ios7)
//    {
//        if(iPhone5)
//        {
//            [UIView animateWithDuration:0.2 animations:^{
//                CGRect frame = _scrollView.frame;
//                frame.origin.y = -90;
//                _scrollView.frame = frame;
//            } completion:^(BOOL finished){
//                
//            }];
//        }
//        else
//        {
//            [UIView animateWithDuration:0.2 animations:^{
//                CGRect frame = _scrollView.frame;
//                frame.origin.y = -126;
//                _scrollView.frame = frame;
//            } completion:^(BOOL finished){
//                
//            }];
//        }
//    }
//    else
//    {
//        [UIView animateWithDuration:0.2 animations:^{
//            CGRect frame = _scrollView.frame;
//            frame.origin.y = -106;
//            _scrollView.frame = frame;
//        } completion:^(BOOL finished){
//        }];
//    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

-(void)loginWithUserinfo:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    _usernameTextField.text = [userInfo objectForKey:@"username"];
    _passwordTextField.text = [userInfo objectForKey:@"password"];
    
    [self.view hideToast];
    [self.view makeToast:@"正在登录..." duration:0 position:@"center" isShadow:NO];
    
    [self doLogin];
    
}

- (void)thirdLoginSuccess:(NSNotification *)notification
{
    [self.view hideToast];
    [self.view makeToast:@"登录成功" duration:1 position:@"center" isShadow:NO];
    
    [QYIMObject getInstance].connectStatus = QYIMConnectStatusOffLine;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logininsuccess" object:nil userInfo:nil];
    
    [MobClick event:@"loginSucceed"];
    
    signFlag = 0;
    
    [self doSomethingAfterLoginSuccessed];
    [self performSelector:@selector(clickCancelButton) withObject:nil afterDelay:1];
}

@end
