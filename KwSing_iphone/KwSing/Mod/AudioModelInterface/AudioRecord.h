//
//  AudioRecord.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-15.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CAudioRecord_h
#define KwSing_CAudioRecord_h

#include <string>

#ifndef KwSing_IAudioStateObserver_h
#include "IAudioStateObserver.h"
#endif

#ifndef KwSing_IObserverApp_h
#include "IObserverApp.h"
#endif

#import "KSAudioGraph.h"

#ifndef KwSing_CMediaRecord_h
#include "MediaRecord.h"
#endif

class CAudioRecord : public CMediaRecord, public IObserverApp, public IAudioStateObserver{
public:
    CAudioRecord();
    virtual ~CAudioRecord();
    
public:
    bool StartRecord(UIView* p_view = NULL);
    bool PauseRecord();
    bool ResumeRecord();
    bool StopRecord();
    
    int CurrentTime()const;
    int Duration()const;
    EMediaRecordStatus GetRecordStatus()const;
    unsigned int GetCurVolume();
    
    bool SwitchResource();
    
    virtual bool SetEchoType(EAudioEchoEffect e_echo_type);
    virtual bool SetAccompanyVolume(float f_volume);
    virtual bool SetSingVolume(float f_volume);
    virtual bool IsFreeSing()const;

    virtual void IAudioStateObserver_PlayStatusStop();
    virtual void IAudioStateObserver_PlayStatusErr();
    virtual void IAudioStateObserver_RecordStatusFinish();
    virtual void IAudioStateObserver_FreeSingFinish();
    virtual void IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset);
    virtual void IObserverApp_CallInComing();
    
private:
    KSAudioGraph* m_pAudioGraph;
    EMediaRecordStatus m_RecordStatus;
    int m_AudioDuration;
};

#endif
