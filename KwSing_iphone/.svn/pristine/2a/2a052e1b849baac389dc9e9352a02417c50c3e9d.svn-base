//
//  IInviteFriendObserver.h
//  KwSing
//
//  Created by 单 永杰 on 13-11-15.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IInviteFriendObserver_h
#define KwSing_IInviteFriendObserver_h

#include "IMessageObserver.h"

enum kInviteResult{
    INVITE_SUCCESS,
    INVITE_FAILED
};

@protocol IInviteStateObserver <NSObject>
@optional
-(void)IInviteStateObserver_Result : (kInviteResult) invite_result;

@end

class IInviteStateObserver:public IMessageObserver
{
public:
    virtual void IInviteStateObserver_Result(kInviteResult invite_result){};
    
    enum eumMethod
    {
        InviteProcess
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IInviteStateObserver)

        NOTIFY_CASE_ITEM(InviteProcess,IInviteStateObserver_Result,_1PARA);

    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif
