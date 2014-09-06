//
//  KSLoginDelegate.m
//  KwSing
//
//  Created by 改 熊 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSLoginDelegate.h"
#import "KwConfig.h"
#import "KSAppDelegate.h"
#import "MessageManager.h"
#import "IUserStatusObserver.h"
#import "User.h"
#import "KwConfigElements.h"
#import "KwTools.h"
#import "HttpRequest.h"
#import "KuwoLog.h"
#import "globalm.h"
#import "SBJson.h"

static long Encoding18030 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);

NSString *LOGIN_RESULT=@"LoginResult";
NSString *GET_DEV_KEY=@"GetDevKey";
NSString *GET_DEV_NAME=@"GetDevName";

@implementation KSLoginDelegate
@synthesize delegate;
/*
    参数解析说明：
    sync——首先解析出sync，如果有sync表示是同步分享的操作，没有表示是登录操作
        sync存在时，同步分享，r表示结果
                r=1表示调用成功
                        sync=1表示绑定成功
                        sync=2表示第三方账号已经绑定了其它酷我账号
                r=0，表示调用失败，原因是给的kuwoID不在线
        sync不存在时，登录操作，
                r=1表示登录成功
                    result表示登录结果，成功记录相应信息
                r=0表示登录失败，可能很小，原因是服务器问题
                r=2表示第三方账号已经和其它kuwo账号绑定了，提示失败
    
 */
-(void)webViewRunActionWithParam:(KSWebView *)view action:(NSString *)act parameter:(NSDictionary *)paras
{
    NSLog(@"%@",[paras description]);
    
    if ([act isEqualToString:LOGIN_RESULT]) {
        NSString* isSync=[paras objectForKey:@"sync"];          
        if (isSync) {
            //有sync表示是同步绑定
            [self dealWithBindRes:paras];
        }
        else{
            //没有sync表示是登录
            [self dealWithLoginRes:paras];
        }
    }
    else if([act isEqualToString:GET_DEV_KEY]){
        SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::LoginStart,SINA);//sina 只是为了表示是第三方登录开始，弹出等待的框
        NSString *para=[NSString stringWithFormat:@"result=ok&value=%@",KwConfig::GetConfigureInstance()->GetUserUUID()];
        [view executeJavaScriptFunc:@"setDevKey" parameter:para];
    }
    else if([act isEqualToString:GET_DEV_NAME]){

        [view executeJavaScriptFunc:@"setDevName" parameter:@"result=ok&value=酷我K歌_ios"];
    }
    else if([act isEqualToString:@"Return"]){
        [[self delegate] onReturn];
    }
}
-(void)dealWithBindRes:(NSDictionary *)retDic
{
    NSString *isSync=[retDic objectForKey:@"sync"];
    NSString *r=[retDic objectForKey:@"r"];                  //r=1表示本次的调用正确，如果发送了uid，sid但是这个uid没有在线，就会r=0
    if ([r isEqualToString:@"1"]){
        NSString* addBindType=[retDic objectForKey:@"type"];
        NSString* bindName=[retDic objectForKey:@"name"];
        if ([isSync isEqualToString:@"1"]) {
            //同步设置成功
            if ([addBindType isEqualToString:@"weibo"]) {
                User::GetUserInstance()->addBindInfo(User::BIND_SINA);
                User::GetUserInstance()->setSinaName(bindName);
                User::GetUserInstance()->setIsSinaValid(true);
                SYN_NOTIFY(OBSERVER_ID_USERSTATUS, IUserStatusObserver::AddBind,SINA,BIND_SUCCESS);
            }
            else if ([addBindType isEqualToString:@"qq"]){
                User::GetUserInstance()->addBindInfo(User::BIND_QQ);
                User::GetUserInstance()->setQQName(bindName);
                User::GetUserInstance()->setIsQQValid(true);
                SYN_NOTIFY(OBSERVER_ID_USERSTATUS, IUserStatusObserver::AddBind,QQ,BIND_SUCCESS);
            }
            else if ([addBindType isEqualToString:@"renren"]){
                User::GetUserInstance()->setRenrenName(bindName);
                User::GetUserInstance()->addBindInfo(User::BIND_RENREN);
                User::GetUserInstance()->setIsRenrenValid(true);
                SYN_NOTIFY(OBSERVER_ID_USERSTATUS, IUserStatusObserver::AddBind,RENREN,BIND_SUCCESS);
            }
            else if ([addBindType isEqualToString:@"tencentweibo"]){
                User::GetUserInstance()->setTencentWeiboName(bindName);
                User::GetUserInstance()->addBindInfo(User::BIND_TENCENT);
                User::GetUserInstance()->setIsTencentValid(true);
                SYN_NOTIFY(OBSERVER_ID_USERSTATUS, IUserStatusObserver::AddBind,TENCENTWEIBO,BIND_SUCCESS);
            }
            
        }
        else if ([isSync isEqualToString:@"2"]){
            //同步设置的第三方账号已被其它kuwo账号绑定
            SYN_NOTIFY(OBSERVER_ID_USERSTATUS, IUserStatusObserver::AddBind,KUWO,BIND_REPEAT);
        }
    }
    else if([r isEqualToString:@"0"]){
        //同步设置失败
        SYN_NOTIFY(OBSERVER_ID_USERSTATUS, IUserStatusObserver::AddBind,KUWO,BIND_FAIL);
    }
}
-(void)dealWithLoginRes:(NSDictionary *)retDic
{
    NSString* r=[retDic objectForKey:@"r"];
    if ([r isEqualToString:@"1"]) {
        //成功
        NSString* retData=[retDic objectForKey:@"data"];
        retData=KwTools::Encoding::UrlDecode(retData);
        NSLog(@"retdata:%@",retData);
        int nLength=KwTools::Base64::Base64DecodeLength([retData length]);
        char *pRetData=new char[nLength];
        memset(pRetData, 0, nLength);
        KwTools::Base64::Base64Decode(retData, pRetData, nLength);
        SBJsonParser *parser=[[SBJsonParser alloc] init];
        NSDictionary *parserDic=[parser objectWithString:[NSString stringWithUTF8String:pRetData]];
        [parser release];
        NSLog(@"parserDic:%@",[parserDic description]);
        NSString* result=[parserDic objectForKey:@"result"];
        if ([result isEqualToString:@"ok"]) {
            //login  ok
            User::GetUserInstance()->setIsOnline(YES);
            User::GetUserInstance()->setUserId([parserDic objectForKey:@"uid"]);
            User::GetUserInstance()->setUserName([parserDic objectForKey:@"uname"]);
            User::GetUserInstance()->setSid([parserDic objectForKey:@"sid"]);
            User::GetUserInstance()->setNickName([parserDic objectForKey:@"nickname"]);
            User::GetUserInstance()->setSex([parserDic objectForKey:@"sex"]);
            User::GetUserInstance()->setHometown([parserDic objectForKey:@"birth_city"]);
            User::GetUserInstance()->setAddress([parserDic objectForKey:@"resident_city"]);
            User::GetUserInstance()->setBirthday([parserDic objectForKey:@"birthday"]);
            User::GetUserInstance()->setHeadPic([parserDic objectForKey:@"headpic"]);
            
            bool needAutoLogin(false);
            KwConfig::GetConfigureInstance()->GetConfigBoolValue(USER_GROUP, USER_AUTOLOGIN, needAutoLogin);
            if (needAutoLogin) {
                KwConfig::GetConfigureInstance()->SetConfigStringValue(USER_GROUP, USER_USERID, [User::GetUserInstance()->getUserId() UTF8String]);
                KwConfig::GetConfigureInstance()->SetConfigStringValue(USER_GROUP, USER_SID, [User::GetUserInstance()->getSid() UTF8String]);
                
            }
            
            NSArray *bindInfArr=[parserDic objectForKey:@"3rdInf"];
            for (NSDictionary *bindInfDic in bindInfArr) {
                NSString* bindType=[bindInfDic objectForKey:@"type"];
                NSString* bindName=[bindInfDic objectForKey:@"uname"];
                NSString* bindId=[bindInfDic objectForKey:@"id"];
                if ([bindType isEqualToString:@"weibo"]) {
                    User::GetUserInstance()->addBindInfo(User::BIND_SINA);
                    User::GetUserInstance()->setSinaName(bindName);
                    User::GetUserInstance()->setSinaId(bindId);
                    User::GetUserInstance()->setIsSinaValid(true);
                }
                else if ([bindType isEqualToString:@"qq"]){
                    User::GetUserInstance()->addBindInfo(User::BIND_QQ);
                    User::GetUserInstance()->setQQName(bindName);
                    User::GetUserInstance()->setQQId(bindId);
                    User::GetUserInstance()->setIsQQValid(true);
                }
                else if ([bindType isEqualToString:@"renren"]){
                    User::GetUserInstance()->addBindInfo(User::BIND_RENREN);
                    User::GetUserInstance()->setRenrenName(bindName);
                    User::GetUserInstance()->setRenrenId(bindId);
                    User::GetUserInstance()->setIsRenrenValid(true);
                }
            }
            
            NSString* fillInf=[parserDic objectForKey:@"fillInf"];         //是否需要补充资料
            NSString* strLoginType=[parserDic objectForKey:@"type"];
            LOGIN_TYPE  loginType;
            LOGIN_TIME  loginTime;
            if ([strLoginType isEqualToString:@"weibo"]) 
                loginType=SINA;
            else if ([strLoginType isEqualToString:@"qq"])
                loginType=QQ;
            else if ([strLoginType isEqualToString:@"renren"])
                loginType=RENREN;
            
            if ([fillInf isEqualToString:@"1"]) 
                loginTime=IS_FIRST;
            else
                loginTime=NOT_FIRST;
            
            SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::LoginFinish,loginType,loginTime);
        }
        else{
            //login fail
            SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::LoginFinish,FAIL_LOGIN,IS_FIRST);
        }

    }
    else if ([r isEqualToString:@"2"]){
        //已经被绑定
        //NSLog(@"alread bind another kuwo id");
        SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::LoginFinish,REPEAT_LOGIN,IS_FIRST);
    }
    else{
        //失败
        SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::LoginFinish,FAIL_LOGIN,IS_FIRST);
    }
}
@end
