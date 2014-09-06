//
//  IAudioStateObserver.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-15.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IAudioStateObserver_h
#define KwSing_IAudioStateObserver_h

#include "IMessageObserver.h"

enum KAudioStatus
{
    AUDIO_RECORDSTATUS_RECORDING,
    AUDIO_RECORDSTATUS_PAUSED,
    AUDIO_RECORDSTATUS_STOP,
    AUDIO_RECORDSTATUS_ERR,
    AUDIO_RECORDSTATUS_FINISH,
    
    AUDIO_PLAYSTATUS_PLAYING,
    AUDIO_PLAYSTATUS_PAUSED,
    AUDIO_PLAYSTATUS_STOP,
    AUDIO_PLAYSTATUS_ERR,
    AUDIO_PLAYSTATUS_BUFFERING
};

enum kDownloadStatus{
    STATUS_DOWNING,
    STATUS_SUCCESS,
    STATUS_FAILED
};

@protocol IAudioStateObserver <NSObject>
@optional
-(void)IAudioStateObserver_RecordStatusRecording;
-(void)IAudioStateObserver_RecordStatusPaused;
-(void)IAudioStateObserver_RecordStatusStop;
-(void)IAudioStateObserver_RecordStatusErr;
-(void)IAudioStateObserver_RecordStatusFinish;
-(void)IAudioStateObserver_FreeSingFinish;

-(void)IAudioStateObserver_PlayStatusPlaying;
-(void)IAudioStateObserver_PlayStatusPaused;
-(void)IAudioStateObserver_PlayStatusStop;
-(void)IAudioStateObserver_PlayStatusErr;
-(void)IAudioStateObserver_OnlinePlayFinish;
-(void)IAudioStateObserver_PlayStatusBuffering;
-(void)IAudioStateObserver_OnlineObjectRelease;

-(void)IAudioStateObserver_DownloadStatus:(kDownloadStatus)enum_status;
-(void)IAudioStateObserver_DownloadProgressChanged;
@end

class IAudioStateObserver:public IMessageObserver
{
public:
    //Recording
    virtual void IAudioStateObserver_RecordStatusRecording(){}
    //Paused Recording
    virtual void IAudioStateObserver_RecordStatusPaused(){}
    //Stop Recording
    virtual void IAudioStateObserver_RecordStatusStop(){}
    //Record Error
    virtual void IAudioStateObserver_RecordStatusErr(){}
    //Record Finish
    virtual void IAudioStateObserver_RecordStatusFinish(){}
    //Record Finish
    virtual void IAudioStateObserver_FreeSingFinish(){}
    //Playing
    virtual void IAudioStateObserver_PlayStatusPlaying(){}
    //Paused Playing
    virtual void IAudioStateObserver_PlayStatusPaused(){}
    //Stop Playing
    virtual void IAudioStateObserver_PlayStatusStop(){}
    //Play Error
    virtual void IAudioStateObserver_PlayStatusErr(){}
    //Online Play Finish
    virtual void IAudioStateObserver_OnlinePlayFinish(){}
    //Release Online Object
    virtual void IAudioStateObserver_OnlineObjectRelease(){}
    //Buffering
    virtual void IAudioStateObserver_PlayStatusBuffering(){}
    //Download Status
    virtual void IAudioStateObserver_DownloadStatus(kDownloadStatus enum_status){}
    //Download Progress Changed
    virtual void IAudioStateObserver_DownloadProgressChanged(){}
    
    enum eumMethod
    {
        Recording,
        RecordPaused,
        RecordStop,
        RecordErr,
        RecordFinish,
        FreeSingFinish,
        
        Playing,
        PlayPaused,
        PlayStop,
        PlayErr,
        PlayBuffering,
        OnlinePlayFinish,
        OnlienObjectRelease,
        
        DownloadStatus,
        DownloadProgress
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IAudioStateObserver)
        NOTIFY_CASE_ITEM(Recording,IAudioStateObserver_RecordStatusRecording,_0PARA);
        NOTIFY_CASE_ITEM(RecordPaused,IAudioStateObserver_RecordStatusPaused,_0PARA);
        NOTIFY_CASE_ITEM(RecordStop,IAudioStateObserver_RecordStatusStop,_0PARA);
        NOTIFY_CASE_ITEM(RecordErr,IAudioStateObserver_RecordStatusErr,_0PARA);
        NOTIFY_CASE_ITEM(RecordFinish,IAudioStateObserver_RecordStatusFinish,_0PARA);
        NOTIFY_CASE_ITEM(FreeSingFinish, IAudioStateObserver_FreeSingFinish, _0PARA);
        
        NOTIFY_CASE_ITEM(Playing,IAudioStateObserver_PlayStatusPlaying,_0PARA);
        NOTIFY_CASE_ITEM(PlayPaused,IAudioStateObserver_PlayStatusPaused,_0PARA);
        NOTIFY_CASE_ITEM(PlayStop, IAudioStateObserver_PlayStatusStop, _0PARA);
        NOTIFY_CASE_ITEM(PlayErr, IAudioStateObserver_PlayStatusErr, _0PARA);
        NOTIFY_CASE_ITEM(PlayBuffering, IAudioStateObserver_PlayStatusBuffering, _0PARA);
        NOTIFY_CASE_ITEM(OnlinePlayFinish, IAudioStateObserver_OnlinePlayFinish, _0PARA);
        NOTIFY_CASE_ITEM(OnlienObjectRelease, IAudioStateObserver_OnlineObjectRelease, _0PARA);
        
        NOTIFY_CASE_ITEM(DownloadStatus,IAudioStateObserver_DownloadStatus,_1PARA);
        NOTIFY_CASE_ITEM(DownloadProgress,IAudioStateObserver_DownloadProgressChanged,_0PARA);
    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif
