//
//  ILiveBroadcastObserver.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-11-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_ILiveBroadcastObserver_h
#define KwSing_ILiveBroadcastObserver_h

#include "IMessageObserver.h"

typedef enum {
    GIVE_FLOWER_SUCCESS
    ,GIVE_FLOWER_NOUSER
    ,GIVE_FLOWER_NOMONEY
    ,GIVE_FLOWER_OTHER
}GIVE_FLOWER_STATUS;

typedef enum {
    ENTER_ROOM_SUCCESS
    ,ENTER_ROOM_STATUS_ERROR
    ,ENTER_ROOM_IDENTITY_ERROR
    ,ENTER_ROOM_FULL
    ,ENTER_ROOM_NO_EXIST
    ,ENTER_ROOM_OTHER
} ENTER_ROOM_ERROR;

@protocol ILiveBroadcastObserver <NSObject>
@optional
- (void)ILiveBroadcast_EnterHall:(BOOL)bSuccess;
- (void)ILiveBroadcast_EnterRoom:(ENTER_ROOM_ERROR)err;
- (void)ILiveBroadcast_GiveFlower:(GIVE_FLOWER_STATUS)status;
- (void)ILiveBroadcast_SendMessage:(BOOL)bSuccess;
- (void)ILiveBroadcast_RefreshHall;
- (void)ILiveBroadcast_RefreshNowRoom;
- (void)ILiveBroadcast_ChangeDJ;
- (void)ILiveBroadcast_UpdateFlowerNum:(int)num;
- (void)ILiveBroadcast_ServerRestart;
- (void)ILiveBroadcast_KickOut;
- (void)ILiveBroadcast_StopByError;
@end

class ILiveBroadcastObserver:public IMessageObserver
{
public:
    virtual void ILiveBroadcast_EnterHall(BOOL bSuccess){}
    virtual void ILiveBroadcast_EnterRoom(ENTER_ROOM_ERROR err){}
    virtual void ILiveBroadcast_GiveFlower(GIVE_FLOWER_STATUS status){}
    virtual void ILiveBroadcast_SendMessage(BOOL bSuccess){}
    virtual void ILiveBroadcast_RefreshHall(){}
    virtual void ILiveBroadcast_RefreshNowRoom(){}
    virtual void ILiveBroadcast_ChangeDJ(){}
    virtual void ILiveBroadcast_UpdateFlowerNum(int num){}
    virtual void ILiveBroadcast_ServerRestart(){}
    virtual void ILiveBroadcast_KickOut(){}
    virtual void ILiveBroadcast_StopByError(){}
    
    enum eumMethod
    {
        EnterHall
        ,EnterRoom
        ,GiveFlower
        ,SendMessage
        ,RefreshHall
        ,RefreshNowRoom
        ,ChangeDJ
        ,UpdateFlowerNum
        ,ServerRestart
        ,KickOut
        ,StopByError
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(ILiveBroadcastObserver)
        NOTIFY_CASE_ITEM(EnterHall,ILiveBroadcast_EnterHall,_1PARA);
        NOTIFY_CASE_ITEM(EnterRoom,ILiveBroadcast_EnterRoom,_1PARA);
        NOTIFY_CASE_ITEM(GiveFlower,ILiveBroadcast_GiveFlower,_1PARA);
        NOTIFY_CASE_ITEM(SendMessage,ILiveBroadcast_SendMessage,_1PARA);
        NOTIFY_CASE_ITEM(RefreshHall,ILiveBroadcast_RefreshHall,_0PARA);
        NOTIFY_CASE_ITEM(RefreshNowRoom,ILiveBroadcast_RefreshNowRoom,_0PARA);
        NOTIFY_CASE_ITEM(ChangeDJ,ILiveBroadcast_ChangeDJ,_0PARA);
        NOTIFY_CASE_ITEM(UpdateFlowerNum,ILiveBroadcast_UpdateFlowerNum,_1PARA);
        NOTIFY_CASE_ITEM(ServerRestart,ILiveBroadcast_ServerRestart,_0PARA);
        NOTIFY_CASE_ITEM(KickOut,ILiveBroadcast_KickOut,_0PARA);
        NOTIFY_CASE_ITEM(StopByError,ILiveBroadcast_StopByError,_0PARA);
    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif
