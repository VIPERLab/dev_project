 //
//  User.mm
//  KwSing
//
//  Created by 改 熊 on 12-7-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "User.h"
#import "KwConfig.h"
#import "KSWebView.h"
#import "KwTools.h"
#import "KwConfigElements.h"
#import "HttpRequest.h"
#import "MessageManager.h"
#import "Block.h"
#import "IUserStatusObserver.h"
#import "KuwoLog.h"
#import "globalm.h"
#import "MyMessageManager.h"
#import "SBJson.h"
#include "UMengLog.h"
#include "KwUMengElement.h"

static long Encoding18030(0);
static KwTools::CLock s_User_Lock;
#define SYN_REG_SERVER "http://kzone.kuwo.cn/mlog/client/RegService"

User* User::GetUserInstance()
{
    static User g_User;
    return &g_User;
}

User::User()
{
    _isOnLine=false;
    //_type=ONLINE_TYPE_NONE;
    _UserId=nil;
    _UserPwd=nil;
    _UserName=nil;
    sid=nil;
    _bindInfo=0x00;
    _nickName=nil;
    _partInType = UNKNOWN;
    Encoding18030 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
}

#pragma mark
#pragma mark --login logout
//在login中写入配置文件，在onReturnStr中改变User的状态
LOGIN_RES User::Login()
{   
    NSString* loginStr=makeLoginUrl();
    //NSLog(@"login url;%@",loginStr);
    if (loginStr==nil) {
        return OTHER_ERROE;
    }
    SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::LoginStart,KUWO);

    string loginRetStr;
    BOOL res=CHttpRequest::QuickSyncGet([loginStr UTF8String], loginRetStr);
    if (!res) {
        return LINK_ERROE;
    }
    return onKWReturn(loginRetStr,false);
}
void User::autoLogin()
{
    NSString* url=makeAutologinUrl();
    //NSLog(@"autologinurl:%@",url);
    if (url==nil)
        return;
    SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::LoginStart,KUWO);
    __block string str;
    __block BOOL res(false);
    KS_BLOCK_DECLARE
    {
        res=CHttpRequest::QuickSyncGet([url UTF8String], str);
        onKWReturn(str, true);
    }KS_BLOCK_RUN_THREAD()
}
LOGIN_RES User::Login(NSString *userName, NSString *pwd)
{
    setUserName(userName);
    setUserPwd(pwd);
    return Login();
}

BOOL User::Logout()
{
    NSString* url=makeLogoutUrl();
    string str;
    
    BOOL res=CHttpRequest::QuickSyncGet([url UTF8String], str);
    
    if (!res) {
        return false;
    }
    //酷我离线，全部离线
    GetUserInstance()->_isOnLine=FALSE;
    KwConfig::GetConfigureInstance()->SetConfigBoolValue(USER_GROUP, USER_AUTOLOGIN, false);//注销了就不自动登录了
    GetUserInstance()->setNickName(nil);
    GetUserInstance()->setUserId(nil);
    GetUserInstance()->setSid(nil);
    GetUserInstance()->setUserName(nil);
    GetUserInstance()->setAddress(nil);
    GetUserInstance()->setBirthday(nil);
    GetUserInstance()->setHeadPic(nil);
    GetUserInstance()->setHometown(nil);
    GetUserInstance()->setQQName(nil);
    GetUserInstance()->setQQId(nil);
    GetUserInstance()->setSinaName(nil);
    GetUserInstance()->setSinaId(nil);
    GetUserInstance()->setTencentWeiboName(nil);
    GetUserInstance()->setTencentWeiboId(nil);
    GetUserInstance()->setRenrenName(nil);
    GetUserInstance()->setRenrenId(nil);
    GetUserInstance()->_bindInfo=0x00;
    GetUserInstance()->_partInType = UNKNOWN;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    CMyMessageManager::GetInstance()->ResetMessage();
    SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::Logout);
    return true;
}
#pragma mark
#pragma mark --regist
BOOL User::Regist(NSString *userName, NSString *pwd, NSString *sid, NSString *ver, NSString *src,NSString *&returnString)
{
    //分别编码name，pwd，ver
    int len = [userName lengthOfBytesUsingEncoding:Encoding18030];
    int tmpSize = KwTools::Base64::Base64EncodeLength([userName lengthOfBytesUsingEncoding:Encoding18030]) + 2;
    char* tmp = new char[tmpSize];
    memset(tmp, 0, tmpSize);
    int base64Ret = KwTools::Base64::Base64Encode([userName cStringUsingEncoding:Encoding18030], len, tmp, tmpSize);
    if (base64Ret == 0) {
        delete [] tmp;
        return nil;
    }
    NSString* base64Name = [[[NSString alloc ]initWithCString:tmp encoding:Encoding18030] autorelease];
    delete []tmp;

    len = [pwd lengthOfBytesUsingEncoding:Encoding18030];
    tmpSize = KwTools::Base64::Base64EncodeLength([pwd lengthOfBytesUsingEncoding:Encoding18030]) + 2;
    tmp = new char[tmpSize];
    memset(tmp, 0, tmpSize);
    base64Ret = KwTools::Base64::Base64Encode([pwd cStringUsingEncoding:Encoding18030], len, tmp, tmpSize);
    if (base64Ret == 0) {
        delete [] tmp;
        return false;
    }
    NSString* bas64Pwd = [[[NSString alloc ]initWithCString:tmp encoding:Encoding18030] autorelease];
    delete [] tmp;

    len = [ver lengthOfBytesUsingEncoding:Encoding18030];
    tmpSize = KwTools::Base64::Base64EncodeLength([ver lengthOfBytesUsingEncoding:Encoding18030]) + 2;
    tmp = new char[tmpSize];
    memset(tmp, 0, tmpSize);
    base64Ret = KwTools::Base64::Base64Encode([ver cStringUsingEncoding:Encoding18030], len, tmp, tmpSize);
    if (base64Ret == 0) {
        delete [] tmp;
        return false;
    }
    NSString* base64ver = [[[NSString alloc ]initWithCString:tmp encoding:Encoding18030] autorelease];
    delete [] tmp;

    NSArray *keys=[NSArray arrayWithObjects:@"name",@"pwd",@"ver",nil];
    NSArray *valuse=[NSArray arrayWithObjects:base64Name,bas64Pwd,base64ver,nil];
    NSDictionary *dic=[[NSDictionary alloc] initWithObjects:valuse forKeys:keys];

    CHttpRequest request(SYN_REG_SERVER,dic);
    BOOL res=request.SyncSendRequest();
    if (res) {
        //请求成功
        void * buf(NULL);
        unsigned l(0);
        request.ReadAll(buf, l);
        string str((char*)buf,l);
        returnString=[NSString stringWithUTF8String:str.c_str()];
        return true;
    }
    return false;
}

#pragma mark
#pragma mark --get mtthods
BOOL User::isOnline() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _isOnLine;
}

NSString* User::getUserId() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _UserId;
}
NSString* User::getUserName() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _UserName;
}
NSString* User::getUserPwd() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _UserPwd;
}
NSString* User::getSid() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return sid;
}
NSString* User::getNickName() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _nickName;
}
NSString* User::getHometown() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _hometown;
}
NSString* User::getAddress() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _address;
}
NSString* User::getBirthday() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _birthday;
}
NSString* User::getHeadPic() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _headPic;
}
User::sexType User::getSex() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _sex;
}
NSString* User::getQQName() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _QQName;
}
NSString* User::getQQId() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _QQId;
}
NSString* User::getSinaName() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _SinaName;
}
NSString* User::getSinaId() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _SinaId;
}
NSString* User::getTencentWeiboName() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _TencentWeiBoName;
}
NSString* User::getTencentWeiboId() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _TencentWeiboId;
}
NSString* User::getRenrenName() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _RenrenName;
}
NSString* User::getRenrenId() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _RenrenId;
}
char User::getBindInfo() const
{
    KwTools::CAutoLock auto_Lock(&s_User_Lock);
    return _bindInfo;
}
BOOL User::isQQBind() const
{
    return BIND_QQ & _bindInfo;
}
BOOL User::isSinaBind() const
{
    return BIND_SINA &_bindInfo;
}
BOOL User::isTencnetBind() const
{
    return BIND_TENCENT &_bindInfo;
}
BOOL User::isRenrenBind() const
{
    return BIND_RENREN & _bindInfo;
}
bool User::isQQValid() const
{
    if (!isQQBind()) {
        return false;
    }
    return _isQQValid;
}
bool User::isSinaValid() const
{
    if (!isSinaBind()) {
        return false;
    }
    return _isSinaValid;
}
bool User::isRenrenValid() const
{
    if (!isRenrenBind()) {
        return false;
    }
    return _isRenrenValid;
}
bool User::isTencentValid() const
{
    if (!isTencnetBind()) {
        return false;
    }
    return _isTencentValid;
}
PART_TYPE User::getPartInType() const
{
    return _partInType;
}
#pragma mark
#pragma mark --set mtthods


//BOOL User::setOnlineType(ONLINE_TYPE setType)
//{
//    if (setType<ONLINE_TYPE_NONE || setType>=ONLINE_TYPE_MAX) {
//        return false;
//    }
//    _type=setType;
//    if (setType) {
//        s_User_Lock.Lock();
//        GetUserInstance()->_isOnLine=YES;  //setType！=None就表示在线
//        s_User_Lock.UnLock();
//    }
//    return true;
//}

BOOL User::setIsOnline(BOOL isOnline)
{
    s_User_Lock.Lock();
    _isOnLine=isOnline;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setUserId(NSString *uid)
{
    if ([uid length]==0) {
        return false;
    }
    [uid retain];
    [_UserId release];
    s_User_Lock.Lock();
    _UserId=uid;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setUserPwd(NSString *pwd)
{
    [pwd retain];
    [_UserPwd release];
    s_User_Lock.Lock();
    _UserPwd=pwd;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setUserName(NSString *name)
{
    if (([name length]<MIN_USERNAME_LENGTH) || ([name length]>MAX_USERNAME_LENGTH)) {
        return false;
    }
    [name retain];
    [_UserName release];
    s_User_Lock.Lock();
    _UserName=name;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setSid(NSString *setSid)
{
    [setSid retain];
    [sid release];
    s_User_Lock.Lock();
    sid=setSid;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setNickName(NSString *setName)
{
    [setName retain];
    [_nickName release];
    s_User_Lock.Lock();
    _nickName=setName;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setHometown(NSString *setHometown)
{
    [setHometown retain];
    [_hometown release];
    s_User_Lock.Lock();
    _hometown=setHometown;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setAddress(NSString *setAddress)
{
    [setAddress retain];
    [_address release];
    s_User_Lock.Lock();
    _address = setAddress;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setBirthday(NSString *setBirthday)
{
    [setBirthday retain];
    [_birthday release];
    s_User_Lock.Lock();
    _birthday=setBirthday;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setHeadPic(NSString *setHeadPic)
{
    [setHeadPic retain];
    [_headPic release];
    s_User_Lock.Lock();
    _headPic=setHeadPic;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setSex(sexType setSex)
{
    s_User_Lock.Lock();
    _sex=setSex;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setSex(NSString *sexStr)
{
    if ([sexStr isEqualToString:@"0"]){
        GetUserInstance()->setSex(secret);
        return true;
    }
    if ([sexStr isEqualToString:@"1"]){
        GetUserInstance()->setSex(male);
        return true;
    }
    if ([sexStr isEqualToString:@"2"]){
        GetUserInstance()->setSex(female);
        return true;
    }
    return false;
}
BOOL User::setQQName(NSString *setName)
{
    [setName retain];
    [_QQName release];
    s_User_Lock.Lock();
    _QQName=setName;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setQQId(NSString *setId)
{
    [setId retain];
    [_QQId release];
    s_User_Lock.Lock();
    _QQId=setId;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setSinaName(NSString *setName)
{
    [setName retain];
    [_SinaName release];
    s_User_Lock.Lock();
    _SinaName=setName;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setSinaId(NSString *setId)
{
    [setId retain];
    [_SinaId release];
    s_User_Lock.Lock();
    _SinaId=setId;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setTencentWeiboName(NSString *setName)
{
    [setName retain];
    [_TencentWeiBoName release];
    s_User_Lock.Lock();
    _TencentWeiBoName=setName;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setTencentWeiboId(NSString *setId)
{
    [setId retain];
    [_TencentWeiboId release];
    s_User_Lock.Lock();
    _TencentWeiboId=setId;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setRenrenName(NSString *setName)
{
    [setName retain];
    [_RenrenName release];
    s_User_Lock.Lock();
    _RenrenName=setName;
    s_User_Lock.UnLock();
    return true;
}
BOOL User::setRenrenId(NSString *setId)
{
    [setId retain];
    [_RenrenId release];
    s_User_Lock.Lock();
    _RenrenId=setId;
    s_User_Lock.UnLock();
    return true;
}

bool User::setIsQQValid(bool isQQValid)
{
    if (!isQQBind()) {
        return false;
    }
    _isQQValid=isQQValid;
    return true;
}
bool User::setIsSinaValid(bool isSinaValid)
{
    if (!isSinaBind()) {
        return false;
    }
    _isSinaValid=isSinaValid;
    return true;
}
bool User::setIsRenrenValid(bool isRenrenValid)
{
    if (!isRenrenBind()) {
        return false;
    }
    _isRenrenValid = isRenrenValid;
    return true;
}
bool User::setIsTencentValid(bool isTencentValid)
{
    if (!isTencnetBind()) {
        return false;
    }
    _isTencentValid = isTencentValid;
    return true;
}
BOOL User::addBindInfo(BindType addType)
{
     s_User_Lock.Lock();
    _bindInfo|=addType;
    s_User_Lock.UnLock();
    return true;
}
//http://changba.kuwo.cn/kge/mobile/CancelBind?uid=xxx&sid=xxx&type=xx&id3=xxx
BOOL User::cancelBindInfo(User::BindType cancelType)
{
    NSString* baseCancelUrl=[NSString stringWithFormat:@"http://changba.kuwo.cn/kge/mobile/CancelBind?uid=%@&sid=%@",GetUserInstance()->getUserId(),GetUserInstance()->getSid()];
    NSString* cancelUrlStr;
    switch (cancelType) {
        case BIND_QQ:
            cancelUrlStr=[NSString stringWithFormat:@"%@&type=qq&id3=%@",baseCancelUrl,GetUserInstance()->getQQId()];
            break;
        case BIND_SINA:
            cancelUrlStr=[NSString stringWithFormat:@"%@&type=weibo&id3=%@",baseCancelUrl,GetUserInstance()->getSinaId()];
            break;
        case BIND_RENREN:
            cancelUrlStr=[NSString stringWithFormat:@"%@&type=renren&id3=%@",baseCancelUrl,GetUserInstance()->getRenrenId()];
            break;
        case BIND_TENCENT:
            cancelUrlStr=[NSString stringWithFormat:@"%@&type=tencentweibo&id3=%@",baseCancelUrl,GetUserInstance()->getTencentWeiboId()];
            break;
        default:
            break;
    }
    string resStr;
    BOOL res=CHttpRequest::QuickSyncGet([cancelUrlStr UTF8String], resStr);
    if (!res) {
        return false;
    }
    SBJsonParser *parser=[[SBJsonParser alloc] init];
    NSDictionary *retDic=[parser objectWithString:[NSString stringWithUTF8String:resStr.c_str()]];
    [parser release];
    NSString *result=[retDic objectForKey:@"result"];
    if ([result isEqualToString:@"err"]) {
        //NSLog(@"cancel fail,error:%@",[retDic objectForKey:@"errMsg"]);
        return false;
    }
    s_User_Lock.Lock();
    _bindInfo&=~cancelType;
    s_User_Lock.UnLock();
    return true;
}

bool User::setPartInType(PART_TYPE type)
{
    _partInType=type;
    return true;
}

#pragma mark
#pragma mark --make url
NSString* User::makeLoginUrl() const
{
    NSString* encodeName=KwTools::Encoding::UrlEncode(GetUserInstance()->getUserName());
    NSString* encodePwd=KwTools::Encoding::UrlEncode(GetUserInstance()->getUserPwd());
    NSString* dKey=KwTools::Encoding::UrlEncode(KwConfig::GetConfigureInstance()->GetDeviceId());
    NSString* devName=KwTools::Encoding::UrlEncode(DEV_NAME);
    
    NSString* reqStr = [NSString stringWithFormat:@"http://changba.kuwo.cn/kge/mobile/Login?uname=%@&pwd=%@&devKey=%@&devName=%@&pk=&reqEnc=utf8&respEnc=gbk",encodeName,encodePwd,dKey,devName];
    return reqStr;
}
NSString* User::makeAutologinUrl() const
{
    string sid;
    KwConfig::GetConfigureInstance()->GetConfigStringValue(USER_GROUP, USER_SID, sid);
    if (sid.empty())
        return nil;
    string uid;
    KwConfig::GetConfigureInstance()->GetConfigStringValue(USER_GROUP, USER_USERID, uid);
    if (uid.empty()) {
        return nil;
    }
    NSString *strSid=[NSString stringWithUTF8String:sid.c_str()];
    NSString *encodeSid=KwTools::Encoding::UrlEncode(strSid);
    NSString *strUid=[NSString stringWithUTF8String:uid.c_str()];
    NSString *encodeId=KwTools::Encoding::UrlEncode(strUid);
    NSString *reqStr=[NSString stringWithFormat:@"http://changba.kuwo.cn/kge/mobile/Login?autologin=1&userid=%@&sid=%@",encodeId,encodeSid];
    return reqStr;
}
NSString* User::makeLogoutUrl() const
{
    NSString *encodeId=KwTools::Encoding::UrlEncode(GetUserInstance()->getUserId());
    NSString *encodeSid=KwTools::Encoding::UrlEncode(GetUserInstance()->getSid());
    NSString *reqStr=[NSString stringWithFormat:@"http://changba.kuwo.cn/kge/mobile/Logout?uid=%@&sid=%@&reqEnc=utf8&respEnc=gbk",encodeId,encodeSid];
    return reqStr;
}
#pragma mark
#pragma mark --on return



//处理登录返回的结果
//成功：
//result=ok\r\n
//uid=xxx\r\n
//sid=xxx\r\n
//vip_info=xxxx\r\n    【vip的信息，使用base64_xor编码，解码后的格式为   "vip_level,vip_status"】
//
//失败：
//result=fail\r\n
//reason=xxxx\r\n     【失败码】
//
//失败码及原因列表：
//
//error_base64_decode     base64解码失败
//error_trans_code        转码失败。
//error_uname_empty       用户名为空
//error_uname_unexist     用户不存在
//error_pwd_invalid       密码不正确
//error_param_invalid     参数不合法，参数不够
//error_service_error     某些内部服务不正常，无法正常工作(连不上数据库或KSQL)


LOGIN_RES User::onKWReturn(std::string loginRetStr,BOOL isAutoLogin)
{
    NSString *retString=[NSString stringWithUTF8String:loginRetStr.c_str()];
    NSLog(@"login return :%@",retString);
    SBJsonParser *parser=[[SBJsonParser alloc] init];
    NSError *error=nil;
    NSDictionary *rootDic=[parser objectWithString:retString error:&error];
    [parser release];
    NSString *result=[rootDic objectForKey:@"result"];
    if ([result isEqualToString:@"ok"]) {
        //login success
        GetUserInstance()->setUserId([rootDic objectForKey:@"uid"]);
        GetUserInstance()->setUserName([rootDic objectForKey:@"uname"]);
        //[rootDic objectForKey:@"pwd"] 是加密后的密码，先不处理～
        GetUserInstance()->setSid([rootDic objectForKey:@"sid"]);
        GetUserInstance()->setNickName([rootDic objectForKey:@"nickname"]);
        GetUserInstance()->setSex([rootDic objectForKey:@"sex"]);
        GetUserInstance()->setHometown([rootDic objectForKey:@"birth_city"]);
        GetUserInstance()->setAddress([rootDic objectForKey:@"resident_city"]);
        GetUserInstance()->setBirthday([rootDic objectForKey:@"birthday"]);
        GetUserInstance()->setHeadPic([rootDic objectForKey:@"headpic"]);
        NSArray *bindInfoArr=[rootDic objectForKey:@"3rdInf"];
        for (NSDictionary *bindInfoDic in bindInfoArr) {
            NSString* bindType=[bindInfoDic objectForKey:@"type"];
            NSString* bindNickName=[bindInfoDic objectForKey:@"uname"];
            NSString* bindID=[bindInfoDic objectForKey:@"id"];
            NSString* bindExpire=[bindInfoDic objectForKey:@"expire"];//true for 过期
            if ([bindType isEqualToString:@"weibo"]) {
                //sina weibo
                GetUserInstance()->addBindInfo(BIND_SINA);
                GetUserInstance()->setSinaName(bindNickName);
                GetUserInstance()->setSinaId(bindID);
                if ([bindExpire isEqualToString:@"true"]) {
                    User::GetUserInstance()->setIsSinaValid(false);
                }
                else{
                    User::GetUserInstance()->setIsSinaValid(true);
                }
            }
            else if ([bindType isEqualToString:@"qq"]){
                //qq zone
                GetUserInstance()->addBindInfo(BIND_QQ);
                GetUserInstance()->setQQName(bindNickName);
                GetUserInstance()->setQQId(bindID);
                if ([bindExpire isEqualToString:@"true"]) {
                    User::GetUserInstance()->setIsQQValid(false);
                }
                else{
                    User::GetUserInstance()->setIsQQValid(true);
                }
            }
            else if ([bindType isEqualToString:@"renren"]){
                //renren
                GetUserInstance()->addBindInfo(BIND_RENREN);
                GetUserInstance()->setRenrenName(bindNickName);
                GetUserInstance()->setRenrenId(bindID);
                if ([bindExpire isEqualToString:@"true"]) {
                    User::GetUserInstance()->setIsRenrenValid(false);
                }
                else{
                    User::GetUserInstance()->setIsRenrenValid(true);
                }
            }
            else if ([bindType isEqualToString:@"tencentweibo"]){
                //tencent weibo
                GetUserInstance()->addBindInfo(BIND_TENCENT);
                GetUserInstance()->setTencentWeiboName(bindNickName);
                GetUserInstance()->setTencentWeiboId(bindID);
                if ([bindExpire isEqualToString:@"true"]) {
                    User::GetUserInstance()->setIsTencentValid(false);
                }
                else{
                    User::GetUserInstance()->setIsTencentValid(true);
                }
            }
        }
        GetUserInstance()->_isOnLine=true;
        SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::LoginFinish,KUWO,NOT_FIRST);
        if (!isAutoLogin) {
            KwConfig::GetConfigureInstance()->SetConfigStringValue(USER_GROUP, USER_NAME, [_UserName UTF8String]);
            bool checkAutoLogin(false);
            KwConfig::GetConfigureInstance()->GetConfigBoolValue(USER_GROUP, USER_AUTOLOGIN, checkAutoLogin);
            if (checkAutoLogin) {
                KwConfig::GetConfigureInstance()->SetConfigStringValue(USER_GROUP, USER_USERID, [GetUserInstance()->getUserId() UTF8String]);
                KwConfig::GetConfigureInstance()->SetConfigStringValue(USER_GROUP, USER_SID, [GetUserInstance()->getSid() UTF8String]);
                int len=[_UserPwd lengthOfBytesUsingEncoding:Encoding18030];
                int tmpSize=KwTools::Base64::Base64EncodeLength(len)+2;
                char* tmp=new char[tmpSize];
                memset(tmp, 0, tmpSize);
                KwTools::Base64::Base64Encode([_UserPwd cStringUsingEncoding:Encoding18030], len, tmp, tmpSize);
                NSString* base64Pwd=[[NSString alloc] initWithCString:tmp encoding:Encoding18030];
                delete []tmp;
                KwConfig::GetConfigureInstance()->SetConfigStringValue(USER_GROUP, USER_PWD, [base64Pwd UTF8String]);
                [base64Pwd release];
            }
            else{
                KwConfig::GetConfigureInstance()->SetConfigStringValue(USER_GROUP, USER_USERID, "");
                KwConfig::GetConfigureInstance()->SetConfigStringValue(USER_GROUP, USER_SID, "");
                KwConfig::GetConfigureInstance()->SetConfigStringValue(USER_GROUP, USER_PWD, "");
            }
            RTLog_Login(AR_SUCCESS, CHttpRequest::GetNetWorkProviderName().c_str(),
                                [User::GetUserInstance()->getUserId() UTF8String] ,
                                [User::GetUserInstance()->getUserName() UTF8String],
                                [GetCurTimeToString() UTF8String], false,"kuwo");
            UMengLog(KS_USER_LOGIN, "0");
        }
        else{
            RTLog_Login(AR_SUCCESS, CHttpRequest::GetNetWorkProviderName().c_str(),
                        [User::GetUserInstance()->getUserId() UTF8String] ,
                        [User::GetUserInstance()->getUserName() UTF8String],
                        [GetCurTimeToString() UTF8String], true,"kuwo");
            UMengLog(KS_USER_LOGIN, "0");
        }
        return SUCCESS;
    }
    else{
        //login fail
        //错误类型还没确定，未完成
        RTLog_Login (AR_FAIL, CHttpRequest::GetNetWorkProviderName().c_str(),
                     "" ,        //login fail,no uid
                     [User::GetUserInstance()->getUserName() UTF8String],
                     [GetCurTimeToString() UTF8String], true,"kuwo");
        UMengLog(KS_USER_LOGIN, "1");

        NSString *retMsg=[rootDic objectForKey:@"errMsg"];
        //NSLog(@"%@",retMsg);
        if ([retMsg isEqualToString:@"error_uname_unexist"] ) {
            return USER_NOT_EXIST;
        }
        if ([retMsg isEqualToString:@"error_pwd_invalid"]) {
            return PWD_ERROE;
        }
        return OTHER_ERROE;
    }
}


void User::updateUserInfoOnWeb(NSString *uNick, User::sexType uSex, NSString *uBirthCity, NSString *uResidentCity, NSString *uBirthday)
{
    uNick=KwTools::Encoding::UrlEncode(uNick);
    uBirthCity=KwTools::Encoding::UrlEncode(uBirthCity);
    uResidentCity=KwTools::Encoding::UrlEncode(uResidentCity);

    NSString* sendString=[NSString stringWithFormat:@"http://changba.kuwo.cn/kge/mobile/ModProfile?uid=%@&sid=%@",User::GetUserInstance()->getUserId(),User::GetUserInstance()->getSid()];
    if ([uNick length] > 0) {
        sendString=[sendString stringByAppendingFormat:@"&nickname=%@",uNick];
    }
    sendString=[sendString stringByAppendingFormat:@"&sex=%d",uSex];
    if ([uBirthCity length] > 0) {
        sendString=[sendString stringByAppendingFormat:@"&birth_city=%@",uBirthCity];
    }
    if ([uResidentCity length] > 0) {
        sendString=[sendString stringByAppendingFormat:@"&resident_city=%@",uResidentCity];
    }
    if ([uBirthday length] > 0) {
        sendString=[sendString stringByAppendingFormat:@"&birthday=%@",uBirthday];
    }
    //NSLog(@"alert user info: %@",sendString);
    __block string result;
    KS_BLOCK_DECLARE
    {
        std::string outString;
        BOOL returnRes=CHttpRequest::QuickSyncGet([sendString UTF8String], outString);
        
        //NSLog(@"alert user info return:%@",[NSString stringWithUTF8String:outString.c_str()]);
        KS_BLOCK_DECLARE
        {
            if(returnRes)
            {
                std::map<string, string> tokens;
                KwTools::StringUtility::TokenizeKeyValue(outString, tokens,",",":");
                result=tokens["{\"result\""];
                if (result == "\"ok\"}") {
                    SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::StateChange);
                }
            }
        }KS_BLOCK_SYNRUN()
    }KS_BLOCK_RUN_THREAD()
    
}