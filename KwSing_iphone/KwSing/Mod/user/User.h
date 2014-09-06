//
//  User.h
//  KwSing
//
//  Created by 改 熊 on 12-7-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//
#include <string>
#import <Foundation/Foundation.h>
#import "KSLoginDelegate.h"
//using std::string;

#ifndef KwSing_User_h
#define KwSing_User_h

#define MIN_USERNAME_LENGTH 2
#define MAX_USERNAME_LENGTH 20

#define MIN_USERPWD_LENGTH 6
#define MAX_USERPWD_LENGTH 16

#define DEV_NAME @"酷我K歌Iphone客户端"

#define UID_START_POSITION 15
#define UID_LENGTH 8
#define SID_START_POSITION 23
#define SID_LEGTH 9

typedef enum {
    KUWO = 0,
    SINA = 1,
    QQ,
    RENREN,
    TENCENTWEIBO,
    REPEAT_LOGIN,
    FAIL_LOGIN
} LOGIN_TYPE;


typedef enum 
{
    SUCCESS=0,
    LINK_ERROE,
    USER_NOT_EXIST,
    PWD_ERROE,
    OTHER_ERROE
}LOGIN_RES;

typedef enum{
    PARTIN=0,
    NO_PARTIN,
    UNKNOWN
} PART_TYPE;

class User
{
public:
    
    static User*  GetUserInstance();
    
    LOGIN_RES Login();
    LOGIN_RES Login(NSString *userId,NSString* pwd);
    
    void autoLogin();
    BOOL Logout();
    //注册，目前参数用到的就是name，pwd，ver
    BOOL Regist(NSString *userName, NSString *pwd, NSString *sid, NSString *ver, NSString *src,NSString *&returnString);
    
    //get methods
    BOOL isOnline() const;                //只是获取在线或者不在线
    NSString* getUserId() const;
    NSString* getUserName() const;
    NSString* getUserPwd() const;
    NSString* getSid() const;
    
    NSString* getNickName() const;
    NSString* getHometown() const;
    NSString* getAddress() const;
    NSString* getBirthday() const;
    
    NSString* getHeadPic() const;
    
    NSString* getQQName() const;
    NSString* getSinaName() const;
    NSString* getTencentWeiboName() const;
    NSString* getRenrenName() const;
    
    NSString* getQQId() const;
    NSString* getSinaId() const;
    NSString* getTencentWeiboId() const;
    NSString* getRenrenId() const;
    
    bool isQQValid() const;
    bool isSinaValid() const;
    bool isRenrenValid() const;
    bool isTencentValid() const;
    
    PART_TYPE getPartInType() const;
    
    enum BindType{
        BIND_QQ=0x01,
        BIND_SINA=0x01<<1,
        BIND_TENCENT=0x01<<2,
        BIND_RENREN=0x01<<3,
    };
    char getBindInfo() const;
    
    BOOL isQQBind() const;
    BOOL isSinaBind() const;
    BOOL isTencnetBind() const;
    BOOL isRenrenBind() const;
    
    enum sexType{
        secret=0,
        male,
        female,
    };
    sexType getSex() const;
    
    //set methods
    BOOL setIsOnline(BOOL isOnline);
    BOOL setUserId(NSString* uid);
    BOOL setUserPwd(NSString* pwd);
    BOOL setUserName(NSString* name);
    BOOL setSid(NSString* setSid);
    
    BOOL setNickName(NSString* setName);
    BOOL setHometown(NSString* setHometown);
    BOOL setAddress(NSString* setAddress);
    BOOL setBirthday(NSString* setBirthday);
    
    BOOL setHeadPic(NSString* setHeadPic);
    BOOL setSex(sexType setSex);
    BOOL setSex(NSString *sexStr);
    
    BOOL setQQName(NSString *setName);
    BOOL setSinaName(NSString *setName);
    BOOL setTencentWeiboName(NSString *setName);
    BOOL setRenrenName(NSString *setName);
    
    BOOL setQQId(NSString *setId);
    BOOL setSinaId(NSString *setId);
    BOOL setTencentWeiboId(NSString *setId);
    BOOL setRenrenId(NSString * setId);
    
    bool setIsQQValid(bool isQQValid);
    bool setIsSinaValid(bool isSinaValid);
    bool setIsRenrenValid(bool isRenrenValid);
    bool setIsTencentValid(bool isTencentValid);
    
    BOOL addBindInfo(BindType addType);
    BOOL cancelBindInfo(BindType cancelType);
    
    bool setPartInType(PART_TYPE type);
    
private:
    BOOL      _isOnLine;         //是否在线
    NSString* _UserId;     //均为kuwo的ID，kuwo注册记录写入uid，第三方登录写入uid
    NSString* _UserPwd;    
    NSString* _UserName;   //kuwo账号先登录登录，写入用户名，第三方登录不修改；第三方登录写入第三方昵称;仅仅用于显示
    NSString* sid;
    
    NSString* _nickName;
    NSString* _hometown;
    NSString* _address;
    NSString* _birthday;
    
    NSString* _OtherUserName;
    NSString* _headPic;
    sexType   _sex;
    
    NSString* _QQName;
    NSString* _SinaName;
    NSString* _TencentWeiBoName;
    NSString* _RenrenName;
    
    NSString *_QQId;
    NSString *_SinaId;
    NSString *_TencentWeiboId;
    NSString *_RenrenId;
    
    bool _isQQValid;
    bool _isSinaValid;
    bool _isRenrenValid;
    bool _isTencentValid;
    
    
    char _bindInfo;
    PART_TYPE _partInType;
private:
    User();
public:
    virtual ~User(){};
    
private:
    NSString* makeLoginUrl() const;
    NSString* makeAutologinUrl() const;
    NSString* makeLogoutUrl() const;
    
    LOGIN_RES onKWReturn(std::string loginRetStr,BOOL isAutoLogin);
public:
    void updateUserInfoOnWeb(NSString *uNick,sexType uSex,NSString* uBirthCity,NSString* uResidentCity,NSString* uBirthday);
    
};


#endif
