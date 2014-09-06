//
//  RecordTask.mm
//  KwSing
//
//  Created by 单 永杰 on 13-2-25.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#include "RecordTask.h"
#include "SongInfo.h"
#include "KwConfig.h"
#include "KwConfigElements.h"
#include "KwTools.h"
#import "KSRecordTempPath.h"

CRecordTask* CRecordTask::GetInstance(){
    static CRecordTask cur_record_task;
    
    return &cur_record_task;
}

void CRecordTask::Init(CSongInfoBase* p_song_info){
    if (NULL == p_song_info) {
        m_strAccompanyPath = "";
        m_strOrigionPath = "";
        m_bIsFreeSing = true;
    }else {
        m_strAccompanyPath = p_song_info->accompanyRes.strLocalPath;
        m_strOrigionPath = p_song_info->originalRes.strLocalPath;
        m_bIsFreeSing = false;
    }
    
//    m_strSaveFilePath = ((CRecoSongInfo*)p_song_info)->recoRes.strLocalPath;
    
    m_fAccompanyVolume = 1.0;
    int n_accompany_volume = 100;
    KwConfig::GetConfigureInstance()->GetConfigIntValue(AUDIO_EFFECT_GROUP, VOLUME_ACCOMPANY, n_accompany_volume, 100);
    m_fAccompanyVolume = (float(n_accompany_volume)) / 100;
    
//    m_bIsAccompany = true;
    
    m_fRecordVolume = 1.0;
    int n_record_volume = 100;
    KwConfig::GetConfigureInstance()->GetConfigIntValue(AUDIO_EFFECT_GROUP, VOLUME_SING, n_record_volume, 100);
    m_fRecordVolume = ((float)n_record_volume) / 100;
    
    int n_audio_effect = 1;
    KwConfig::GetConfigureInstance()->GetConfigIntValue(AUDIO_EFFECT_GROUP, ECHO_TYPE, n_audio_effect, SMALL_ROOM_EFFECT);
    m_eAudioEffect = (EAudioEchoEffect)n_audio_effect;
}

void CRecordTask::SetAccompanyVolume(const float f_accompany_volume){
    m_fAccompanyVolume = f_accompany_volume;
    KwConfig::GetConfigureInstance()->SetConfigIntValue(AUDIO_EFFECT_GROUP, VOLUME_ACCOMPANY, (int)(f_accompany_volume * 100));
}

float CRecordTask::GetAccompanyVolume()const{
    return m_fAccompanyVolume;
}

void CRecordTask::SetSingVolume(const float f_sing_volume){
    m_fRecordVolume = f_sing_volume;
    KwConfig::GetConfigureInstance()->SetConfigIntValue(AUDIO_EFFECT_GROUP, VOLUME_SING, (int)(f_sing_volume * 100));
}

float CRecordTask::GetSingVolume()const{
    return m_fRecordVolume;
}

void CRecordTask::SetEchoType(const EAudioEchoEffect e_echo_type){
    m_eAudioEffect = e_echo_type;
}

EAudioEchoEffect CRecordTask::GetEchoType()const{
    return m_eAudioEffect;
}
