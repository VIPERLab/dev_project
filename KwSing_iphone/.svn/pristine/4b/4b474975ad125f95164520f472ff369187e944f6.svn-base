//
//  MvRecord.cpp
//  KwSing
//
//  Created by 单 永杰 on 13-11-8.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#include "MvRecord.h"

CMvRecord::~CMvRecord(){
    if (m_pMvRecorder) {
        [m_pMvRecorder release];
        m_pMvRecorder = nil;
    }
}

bool CMvRecord::StartRecord(UIView* p_view){
    m_pMvRecorder = [[KSMvRecord alloc] init];
    [m_pMvRecorder initRecorder:m_pSongInfo withView:p_view];
    
    return true;
}

void CMvRecord::SetSongInfo(CSongInfoBase* p_song_info){
    m_pSongInfo = p_song_info;
}

bool CMvRecord::PauseRecord(){
    return [m_pMvRecorder pause];
}

bool CMvRecord::ResumeRecord(){
    return [m_pMvRecorder resume];
}

bool CMvRecord::StopRecord(){
    return [m_pMvRecorder stop];
}

int CMvRecord::CurrentTime()const{
    return [m_pMvRecorder currentTime];
}

int CMvRecord::Duration()const{
    return [m_pMvRecorder duration];
}

bool CMvRecord::SwitchResource(){
    return true;
}

bool CMvRecord::SetEchoType(EAudioEchoEffect e_echo_type){
    return true;
}

bool CMvRecord::SetAccompanyVolume(float f_volume){
    return [m_pMvRecorder setAcomVolume:f_volume];
}

bool CMvRecord::SetSingVolume(float f_volume){
    return [m_pMvRecorder setSingVolume:f_volume];
}

EMediaRecordStatus CMvRecord::GetRecordStatus()const{
    return RECORD_STATUS_READY;
}

bool CMvRecord::SwitchResource(bool b_origion){
    return [m_pMvRecorder switchOrigAcom:b_origion];
}

