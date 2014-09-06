//
//  VideoRecorder.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-22.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CVideoRecorder_h
#define KwSing_CVideoRecorder_h

#ifndef KwSing_CAudioUnitRecorder_h
#include "AudioUnitRecorder.h"
#endif

#import "KSAVAudioPlayer.h"

#ifndef KwSing_IObserverApp_h
#include "IObserverApp.h"
#endif

#ifndef KwSing_IAudioStateObserver_h
#include "IAudioStateObserver.h"
#endif

#import "KSVideoRecord.h"
#import "KSAudioGraph.h"

#ifndef KwSing_CMediaRecord_h
#include "MediaRecord.h"
#endif

class CVideoRecorder : public CMediaRecord, public IObserverApp, public IAudioStateObserver{
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
    virtual void IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset);
    virtual void IObserverApp_CallInComing();
//    virtual void IObserverApp_MicrophoneStatusChanged(BOOL bHasMicrophone);
    
private:
    KSVideoRecord* m_pVideoRecorder;
    EMediaRecordStatus m_RecordStatus;
    KSAudioGraph* m_pAudioGraph;
    int m_AudioDuration;
    
public:
    CVideoRecorder();
    ~CVideoRecorder();
};

#endif
