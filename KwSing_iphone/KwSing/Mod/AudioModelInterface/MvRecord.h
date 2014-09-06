//
//  MvRecord.h
//  KwSing
//
//  Created by 单 永杰 on 13-11-8.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__MvRecord__
#define __KwSing__MvRecord__

#include <iostream>

#ifndef KwSing_CMediaRecord_h
#include "MediaRecord.h"
#endif

#import "KSMvRecord.h"

class CMvRecord :  CMediaRecord{
public:
    
    CMvRecord(){};
    virtual ~CMvRecord();
    
public:
    virtual bool StartRecord(UIView* p_view = NULL);
    virtual bool PauseRecord();
    virtual bool ResumeRecord();
    virtual bool StopRecord();
    
    virtual int CurrentTime()const;
    virtual int Duration()const;
    virtual bool SwitchResource();
    virtual bool SetEchoType(EAudioEchoEffect e_echo_type);
    virtual bool SetAccompanyVolume(float f_volume);
    virtual bool SetSingVolume(float f_volume);
    virtual EMediaRecordStatus GetRecordStatus()const;
    virtual unsigned int GetCurVolume(){
        return 0;
    };
    virtual bool IsFreeSing()const{
        return false;
    };
    bool SwitchResource(bool b_origion);
    void SetSongInfo(CSongInfoBase* p_song_info);
    
private:
    KSMvRecord* m_pMvRecorder;
    CSongInfoBase* m_pSongInfo;
};

#endif /* defined(__KwSing__MvRecord__) */
