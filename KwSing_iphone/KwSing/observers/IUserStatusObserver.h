//
//  IUserStatusObserver.h
//  KwSing
//
//  Created by 改 熊 on 12-8-28.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IUserStatusObserver_h
#define KwSing_IUserStatusObserver_h

#include "IMessageObserver.h"
#include "User.h"

enum LOGIN_TIME{
    IS_FIRST,
    NOT_FIRST
} ;
enum BIND_RES{
    BIND_SUCCESS,
    BIND_FAIL,
    BIND_REPEAT
};
@protocol IUserStatusObserver <NSObject>

@optional
-(void)IUserStatusObserver_LoginStart :(LOGIN_TYPE) type;
-(void)IUserStatusObserver_LoginFinish:(LOGIN_TYPE) type :(LOGIN_TIME)first;
-(void)IUserStatusObserver_Logout;
-(void)IUserStatusObserver_StateChange;
-(void)IUserStatusObserver_AddBind:(LOGIN_TYPE)type :(BIND_RES)bindRes;
@end

class IUserStatusObserver:public IMessageObserver {
   
    
public:
    virtual void IUserStatusObserver_LoginStart(LOGIN_TYPE _type){}
    virtual void IUserStatusObserver_LoginFinish(LOGIN_TYPE _type,LOGIN_TIME _time){}
    virtual void IUserStatusObserver_Logout(){}
    virtual void IUserStatusObserver_StateChange(){}
    virtual void IUserStatusObserver_AddBind(LOGIN_TYPE type,BIND_RES _bindRes){}
    
    enum enumMethod
    {
        LoginStart,
        LoginFinish,
        Logout,
        StateChange,
        AddBind
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IUserStatusObserver)
        NOTIFY_CASE_ITEM(LoginStart,IUserStatusObserver_LoginStart,_1PARA);
        NOTIFY_CASE_ITEM(LoginFinish,IUserStatusObserver_LoginFinish,_2PARA);
        NOTIFY_CASE_ITEM(Logout,IUserStatusObserver_Logout,_0PARA);
        NOTIFY_CASE_ITEM(StateChange,IUserStatusObserver_StateChange,_0PARA);
        NOTIFY_CASE_ITEM(AddBind,IUserStatusObserver_AddBind,_2PARA);
    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif
