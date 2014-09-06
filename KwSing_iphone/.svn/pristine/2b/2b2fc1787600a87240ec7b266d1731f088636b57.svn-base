//
//  IRtmpPlayStateObserver.h
//  KwSing
//
//  Created by 单 永杰 on 12-12-7.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IRtmpPlayStateObserver_h
#define KwSing_IRtmpPlayStateObserver_h

#include "IMessageObserver.h"
#include "KSRtmpPlayState.h"

@protocol IRtmpPlayStateObserver <NSObject>
@optional
-(void)IRtmpPlayStateObserver_Fail:(RTMP_ERR_TYPE)enum_status;
-(void)IRtmpPlayStateObserver_Play;
@end

class IRtmpPlayStateObserver:public IMessageObserver
{
public:
    //Play Fail
    virtual void IRtmpPlayStateObserver_Fail(RTMP_ERR_TYPE enum_status){}
    //Play Success
    virtual void IRtmpPlayStateObserver_Play(){}
    
    enum eumMethod
    {
        PlayFailed,
        PlaySuccess
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IRtmpPlayStateObserver)
    
    NOTIFY_CASE_ITEM(PlayFailed,IRtmpPlayStateObserver_Fail,_1PARA);
    NOTIFY_CASE_ITEM(PlaySuccess,IRtmpPlayStateObserver_Play,_0PARA);
    
    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif
