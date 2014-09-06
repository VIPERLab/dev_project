//
//  RecordTask.h
//  KwSing
//
//  Created by 单 永杰 on 13-2-25.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#ifndef KwSing_RecordTask_h
#define KwSing_RecordTask_h

#ifndef KwSing_AudioEffectType_h
#include "AudioEffectType.h"
#endif

#include <iostream>

class CSongInfoBase;

class CRecordTask {
public:
    virtual ~CRecordTask(){};
    
private:
    CRecordTask(){m_bIsAccompany = true;m_bIsHrbActivity = false;m_bIsOtherActivity=false;};
    
public:
    static CRecordTask* GetInstance();
    void Init(CSongInfoBase* p_song_info);
    
    void SetSingVolume(const float f_sing_volume);
    float GetSingVolume()const;
    
    void SetAccompanyVolume(const float f_accompany_volume);
    float GetAccompanyVolume()const;
    
    void SetEchoType(const EAudioEchoEffect e_echo_type);
    EAudioEchoEffect GetEchoType()const;
    
public:
    bool m_bTaskValid;
    
    bool m_bIsFreeSing;
    
    bool m_bIsAccompany;
    
    bool m_bIsHrbActivity;
    
    bool m_bIsOtherActivity;
    
    NSArray *m_ActivityArray;
    
    std::string activityId;
    
    std::string m_strAccompanyPath;
    std::string m_strOrigionPath;
    
    std::string m_strSaveFilePath;
    
private:
    float m_fAccompanyVolume;
    float m_fRecordVolume;
    EAudioEchoEffect m_eAudioEffect;
};

#endif
