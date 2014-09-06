//
//  MessageManager.h
//  KwSing
//
//  Created by 永杰 单 on 12-9-18.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CMyMessageManager_h
#define KwSing_CMyMessageManager_h

#ifndef KwSing_CAutoLock_h
#include "AutoLock.h"
#endif

#include <string>

struct MyMessage {
    int n_NumTotalMessage;
    int n_NumNewSysNotification;
    int n_NumNewAttention;
    int n_NumNewComment;
    int n_NumNewFlower;
    int n_NumNewReply;
};

class CMyMessageManager {
private:
    CMyMessageManager();
    CMyMessageManager(CMyMessageManager&){}
    ~CMyMessageManager();
    
public:
    static CMyMessageManager* GetInstance();
    
    bool StartQuery();
    void StopQuery();
    
    int NumOfNewSysNotifications()const;
    int NumOfNewAttentions()const;
    int NumOfNewComments()const;
    int NumOfNewFlowers()const;
    int NumOfNewReplys()const;
    int NumOfNewMessages()const;
    void ResetMessage();

    
private:
    void ReadMessageInfo(MyMessage& message_info);
    void WriteMessageInfo();
    void DecodeHttpRet(const std::string& str_http_ret, MyMessage& message_info);
//    NSString* CreateReqStr();
    
private:
    bool m_bStop;
    MyMessage m_MyMessage;
    UIBackgroundTaskIdentifier task_id;
};

#endif
