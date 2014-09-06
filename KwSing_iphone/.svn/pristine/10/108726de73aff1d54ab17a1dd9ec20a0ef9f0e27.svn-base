//
//  IVideoStateObserver.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IVideoStateObserver_h
#define KwSing_IVideoStateObserver_h

#include "IMessageObserver.h"

enum KVideoStatus
{
    VIDEO_RECORDSTATUS_RECORDING,
    VIDEO_RECORDSTATUS_PAUSED,
    VIDEO_RECORDSTATUS_STOP,
    VIDEO_RECORDSTATUS_ERR,
    
    VIDEO_PLAYSTATUS_READY,
    VIDEO_PLAYSTATUS_NOTREADY,
    VIDEO_PLAYSTATUS_PLAYING,
    VIDEO_PLAYSTATUS_STOPED,
    VIDEO_PLAYSTATUS_PAUSED,
    VIDEO_PLAYSTATUS_ERR
};

@protocol IVideoStateObserver <NSObject>
@optional
-(void)IVideoStateObserver_RecordStatusRecording;
-(void)IVideoStateObserver_RecordStatusPaused;
-(void)IVideoStateObserver_RecordStatusStop;
-(void)IVideoStateObserver_RecordStatusErr;

-(void)IVideoStateObserver_PlayStatusPlaying;
-(void)IVideoStateObserver_PlayStatusPaused;
-(void)IVideoStateObserver_PlayStatusStop;
-(void)IVideoStateObserver_PlayStatusErr;
-(void)IVideoStateObserver_PlayStatusReady;
-(void)IVideoStateObserver_PlayStatusNotReady;
@end

class IVideoStateObserver:public IMessageObserver
{
public:
    //Recording
    virtual void IVideoStateObserver_RecordStatusRecording(){}
    //Paused Recording
    virtual void IVideoStateObserver_RecordStatusPaused(){}
    //Stop Recording
    virtual void IVideoStateObserver_RecordStatusStop(){}
    //Record Error
    virtual void IVideoStateObserver_RecordStatusErr(){}
    //Playing
    virtual void IVideoStateObserver_PlayStatusPlaying(){}
    //Paused Playing
    virtual void IVideoStateObserver_PlayStatusPaused(){}
    //Stop Playing
    virtual void IVideoStateObserver_PlayStatusStop(){}
    //Play Error
    virtual void IVideoStateObserver_PlayStatusErr(){}
    //Buffering
    virtual void IVideoStateObserver_PlayStatusReady(){}
    //Buffer not ready
    virtual void IVideoStateObserver_PlayStatusNotReady(){}
    
    enum eumMethod
    {
        Recording,
        RecordPaused,
        RecordStop,
        RecordErr,
        
        Playing,
        PlayPaused,
        PlayStop,
        PlayErr,
        PlayIsReady,
        PLayIsNotReady
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IVideoStateObserver)
    NOTIFY_CASE_ITEM(Recording,IVideoStateObserver_RecordStatusRecording,_0PARA);
    NOTIFY_CASE_ITEM(RecordPaused,IVideoStateObserver_RecordStatusPaused,_0PARA);
    NOTIFY_CASE_ITEM(RecordStop,IVideoStateObserver_RecordStatusStop,_0PARA);
    NOTIFY_CASE_ITEM(RecordErr,IVideoStateObserver_RecordStatusErr,_0PARA);
    
    NOTIFY_CASE_ITEM(Playing,IVideoStateObserver_PlayStatusPlaying,_0PARA);
    NOTIFY_CASE_ITEM(PlayPaused,IVideoStateObserver_PlayStatusPaused,_0PARA);
    NOTIFY_CASE_ITEM(PlayStop, IVideoStateObserver_PlayStatusStop, _0PARA);
    NOTIFY_CASE_ITEM(PlayErr, IVideoStateObserver_PlayStatusErr, _0PARA);
    NOTIFY_CASE_ITEM(PlayIsReady, IVideoStateObserver_PlayStatusReady, _0PARA);
    NOTIFY_CASE_ITEM(PLayIsNotReady,IVideoStateObserver_PlayStatusNotReady,_0PARA);
    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif
