//
//  MediaRecord.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CMediaRecord_h
#define KwSing_CMediaRecord_h

#ifndef KwSing_MediaStatus_h
#include "MediaStatus.h"
#endif

#ifndef KwSing_CMediaInterface_h
#include "MediaInterface.h"
#endif

#ifndef KwSing_AudioEffectType_h
#include "AudioEffectType.h"
#endif

#include <string>

class CMediaRecord : public CMediaInterface{
public:
    virtual ~CMediaRecord(){};
    
    virtual bool StartRecord(UIView* p_view = NULL) = 0;
    virtual bool PauseRecord() = 0;
    virtual bool ResumeRecord() = 0;
    virtual bool StopRecord() = 0;
    
    virtual int CurrentTime()const = 0;
    virtual int Duration()const = 0;
    virtual bool SwitchResource() = 0;
    virtual bool SetEchoType(EAudioEchoEffect e_echo_type) = 0;
    virtual bool SetAccompanyVolume(float f_volume) = 0;
    virtual bool SetSingVolume(float f_volume) = 0;
    virtual EMediaRecordStatus GetRecordStatus()const = 0;
    virtual unsigned int GetCurVolume() = 0;
    virtual bool IsFreeSing()const = 0;
};

#endif
