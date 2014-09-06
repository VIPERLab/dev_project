//
//  MessageQuery.mm
//  KwSing
//
//  Created by 永杰 单 on 12-9-18.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "MyMessageManager.h"
#include "MessageManager.h"
#include "KwConfig.h"
#include "KwConfigElements.h"
#include "KwTools.h"
#include "User.h"
#include "IMyMessageStateObserver.h"
#include "HttpRequest.h"

static KwTools::CLock s_MessageLock;

CMyMessageManager::CMyMessageManager(){
    m_MyMessage.n_NumNewSysNotification = 0;
    m_MyMessage.n_NumNewAttention = 0;
    m_MyMessage.n_NumNewComment = 0;
    m_MyMessage.n_NumNewFlower = 0;
    m_MyMessage.n_NumNewReply = 0;
    m_MyMessage.n_NumTotalMessage = 0;
    m_bStop = true;
}

CMyMessageManager::~CMyMessageManager(){
}

CMyMessageManager* CMyMessageManager::GetInstance(){
    static CMyMessageManager s_message_manager;
    
    return &s_message_manager;
}
 
bool CMyMessageManager::StartQuery(){

    m_MyMessage.n_NumNewSysNotification = 0;
    m_MyMessage.n_NumNewAttention = 0;
    m_MyMessage.n_NumNewComment = 0;
    m_MyMessage.n_NumNewFlower = 0;
    m_MyMessage.n_NumNewReply = 0;
    m_MyMessage.n_NumTotalMessage = 0;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if (User::GetUserInstance()->isOnline())
        ReadMessageInfo(m_MyMessage);
    
    if (!m_bStop) {
        return false;
    }else {
        KS_BLOCK_DECLARE{
            int n_query_period(600);
            //KwConfig::GetConfigureInstance()->GetConfigIntValue(MY_MESSAGE_GROUP, MY_MESSAGE_QUERY_PERIOD, n_query_period);
            
            KS_BLOCK_DECLARE{
                while (!m_bStop) {
//                    if (!User::GetUserInstance()->isOnline()) {
//                        sleep(300);
//                        continue;
//                    }

                    std::string str_query_req = "http://changba.kuwo.cn/kge/mobile/ChkNotice?uid=";
                    if (nil == User::GetUserInstance()->getUserId() || nil == User::GetUserInstance()->getSid()) {
                        sleep(120);
                        continue;
                    }
                    str_query_req += [User::GetUserInstance()->getUserId() UTF8String];
                    str_query_req += "&sid=";
                    str_query_req += [User::GetUserInstance()->getSid() UTF8String];

                    std::string str_query_ret;
                    BOOL b_ret = CHttpRequest::QuickSyncGet(str_query_req, str_query_ret);
                    
                    if (b_ret) {
                        s_MessageLock.Lock();
                        DecodeHttpRet(str_query_ret, m_MyMessage);
                        s_MessageLock.UnLock();
                        
                        if (99 < m_MyMessage.n_NumTotalMessage) {
                            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:99];
                        }else {
                            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:m_MyMessage.n_NumTotalMessage];
                        }
                        KS_BLOCK_DECLARE{
                            WriteMessageInfo();
                        }
                        KS_BLOCK_SYNRUN();
                        
                        if (m_MyMessage.n_NumTotalMessage) {
                            SYN_NOTIFY(OBSERVER_ID_MY_MESSAGE, IMyMessageStateObserver::MyMessageNumChanged);
                            sleep(n_query_period);
                        }
                    }
                    sleep(n_query_period);
                }
            }
            KS_BLOCK_RUN_THREAD();
            m_bStop = false;
        }
        KS_BLOCK_ASYNRUN(60000);

        return true;
    }
}

void CMyMessageManager::StopQuery(){
    m_bStop = true;
}

void CMyMessageManager::ReadMessageInfo(MyMessage& message_info){
    KwConfig::GetConfigureInstance()->GetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_SYS_NOTIFICATION, message_info.n_NumNewSysNotification);
    KwConfig::GetConfigureInstance()->GetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_ATTENTION, message_info.n_NumNewAttention);
    KwConfig::GetConfigureInstance()->GetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_COMMENT, message_info.n_NumNewComment);
    KwConfig::GetConfigureInstance()->GetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_FLOWER, message_info.n_NumNewFlower);
    KwConfig::GetConfigureInstance()->GetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_REPLY, message_info.n_NumNewReply);
    KwConfig::GetConfigureInstance()->GetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_TOTAL_MESSAGE, message_info.n_NumTotalMessage);
}

void CMyMessageManager::WriteMessageInfo(){
    KwConfig::GetConfigureInstance()->SetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_SYS_NOTIFICATION, m_MyMessage.n_NumNewSysNotification);
    KwConfig::GetConfigureInstance()->SetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_ATTENTION, m_MyMessage.n_NumNewAttention);
    KwConfig::GetConfigureInstance()->SetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_COMMENT, m_MyMessage.n_NumNewComment);
    KwConfig::GetConfigureInstance()->SetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_FLOWER, m_MyMessage.n_NumNewFlower);
    KwConfig::GetConfigureInstance()->SetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_REPLY, m_MyMessage.n_NumNewReply);
    KwConfig::GetConfigureInstance()->SetConfigIntValue(MY_MESSAGE_GROUP, NUM_NEW_TOTAL_MESSAGE, m_MyMessage.n_NumTotalMessage);
}

void CMyMessageManager::DecodeHttpRet(const std::string& str_http_ret, MyMessage& message_info){
    int n_right_index = str_http_ret.rfind("}");
    std::string str_http_ret_temp = str_http_ret.substr(1, n_right_index - 1);
    
    std::vector<std::string> vecDatas;
    KwTools::StringUtility::Tokenize(str_http_ret_temp,",",vecDatas);
    if (0 == vecDatas.size()) {
        return;
    }
    
    for (int i = 0; i < vecDatas.size(); ++i) {
        std::vector<std::string> vecKeyValue;
        KwTools::StringUtility::Tokenize(vecDatas[i],":",vecKeyValue);
        if (2 == vecKeyValue.size()) {
            if (vecKeyValue[0] == "\"result\"" && 0 != vecKeyValue[1].compare("\"ok\"")) {
                break;
            } else if(vecKeyValue[0] == "\"total\"") {
                message_info.n_NumTotalMessage = atoi(vecKeyValue[1].c_str());
            } else if(vecKeyValue[0] == "\"shenhe\"") {
                message_info.n_NumNewSysNotification = atoi(vecKeyValue[1].c_str());
            }else if (vecKeyValue[0] == "\"fav\"") {
                message_info.n_NumNewAttention = atoi(vecKeyValue[1].c_str());
            }else if (vecKeyValue[0] == "\"cmt\"") {
                message_info.n_NumNewComment = atoi(vecKeyValue[1].c_str());
            }else if (vecKeyValue[0] == "\"cmt_reply\"") {
                message_info.n_NumNewReply = atoi(vecKeyValue[1].c_str());
            }else if (vecKeyValue[0] == "\"flower\"") {
                message_info.n_NumNewFlower = atoi(vecKeyValue[1].c_str());
            }
        }
    }
}

int CMyMessageManager::NumOfNewSysNotifications()const{
    KwTools::CAutoLock auto_lock(&s_MessageLock);
    
    return m_MyMessage.n_NumNewSysNotification;
}

int CMyMessageManager::NumOfNewAttentions()const{
    KwTools::CAutoLock auto_lock(&s_MessageLock);
    
    return m_MyMessage.n_NumNewAttention;
}

int CMyMessageManager::NumOfNewComments()const{
    KwTools::CAutoLock auto_lock(&s_MessageLock);
    
    return m_MyMessage.n_NumNewComment;
}

int CMyMessageManager::NumOfNewFlowers()const{
    KwTools::CAutoLock auto_lock(&s_MessageLock);
    
    return m_MyMessage.n_NumNewFlower;
}

int CMyMessageManager::NumOfNewReplys()const{
    KwTools::CAutoLock auto_lock(&s_MessageLock);
    
    return m_MyMessage.n_NumNewReply;
}

int CMyMessageManager::NumOfNewMessages()const{
    //return 87;
    KwTools::CAutoLock auto_lock(&s_MessageLock);
    return m_MyMessage.n_NumTotalMessage;
}

void CMyMessageManager::ResetMessage(){
    s_MessageLock.Lock();
    
    m_MyMessage.n_NumNewSysNotification = 0;
    m_MyMessage.n_NumNewAttention = 0;
    m_MyMessage.n_NumNewComment = 0;
    m_MyMessage.n_NumNewFlower = 0;
    m_MyMessage.n_NumNewReply = 0;
    m_MyMessage.n_NumTotalMessage = 0;
    s_MessageLock.UnLock();
    SYN_NOTIFY(OBSERVER_ID_MY_MESSAGE, IMyMessageStateObserver::MyMessageNumChanged);
}
