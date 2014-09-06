//
//  MediaModelFactory.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "MediaModelFactory.h"
#include "AudioWorkPlayer.h"
#include "VideoWorkPlayer.h"
#include "IAudioStateObserver.h"
#include "MessageManager.h"
#include "UMengLog.h"
#include "KwUMengElement.h"
#include "RecordTask.h"

CMediaModelFactory::CMediaModelFactory(){
    m_pMediaRecord = NULL;
    m_pMediaReplay = NULL;
    m_pMediaOnlinePlay = NULL;
    m_pMediaSaver = NULL;
    m_pOrigionSongPlayer = NULL;
    m_pLocalWorkPlayer = NULL;
}

CMediaModelFactory::~CMediaModelFactory(){
    if (m_pMediaRecord) {
        delete m_pMediaRecord;
        m_pMediaRecord = NULL;
    }
    
    if (m_pMediaReplay) {
        delete m_pMediaReplay;
        m_pMediaReplay = NULL;
    }
    
    if (m_pMediaOnlinePlay) {
        delete m_pMediaOnlinePlay;
        m_pMediaOnlinePlay = NULL;
    }
    if (m_pMediaSaver) {
        delete m_pMediaSaver;
        m_pMediaSaver = NULL;
    }
    if (m_pOrigionSongPlayer) {
        delete m_pOrigionSongPlayer;
        m_pOrigionSongPlayer = NULL;
    }
    if (m_pLocalWorkPlayer) {
        delete m_pLocalWorkPlayer;
        m_pLocalWorkPlayer = NULL;
    }
}

CMediaModelFactory* CMediaModelFactory::GetInstance(){
    static CMediaModelFactory s_media_model_factory;
    
    return &s_media_model_factory;
}

CMediaRecord* CMediaModelFactory::CreateMediaRecord(bool b_is_video){
    if (m_pMediaRecord) {
        delete m_pMediaRecord;
        m_pMediaRecord = NULL;
    }
    
    if (b_is_video) {
        return m_pMediaRecord = new CVideoRecorder;
    }else{
        return m_pMediaRecord = new CAudioRecord;
    }
}

void CMediaModelFactory::ReleaseMediaRecord(){
    if (m_pMediaRecord) {
        std::string str_record_volume;
        UMengLog(KS_RECORD_ACCOM_VOLUME, [[NSString stringWithFormat:@"%f", CRecordTask::GetInstance()->GetAccompanyVolume()] UTF8String]);
        UMengLog(KS_RECORD_SING_VOLUME, [[NSString stringWithFormat:@"%f", CRecordTask::GetInstance()->GetSingVolume()] UTF8String]);
        delete m_pMediaRecord;
        m_pMediaRecord = NULL;
    }
}

CMediaReplay* CMediaModelFactory::CreateMediaReplay(bool b_is_video){
    if (m_pMediaReplay) {
        delete m_pMediaReplay;
        m_pMediaReplay = NULL;
    }
    if (b_is_video) {
        return m_pMediaReplay = new CLocalVideoPlayer;
    }else{
        return m_pMediaReplay = new CAuditionPlay;
    }
}

void CMediaModelFactory::ReleaseMediaReplay(){
    if (m_pMediaReplay) {
        delete m_pMediaReplay;
        m_pMediaReplay = NULL;
    }
}

CMediaOnlinePlay* CMediaModelFactory::CreateMediaOnlinePlay(bool b_is_video){
    if (m_pMediaOnlinePlay) {
        delete m_pMediaOnlinePlay;
        m_pMediaOnlinePlay = NULL;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::OnlienObjectRelease);
    }
    if (b_is_video) {
        return m_pMediaOnlinePlay = new COnlineVideoPlayer;
    }else{
        return m_pMediaOnlinePlay = new COnlineAudioPlayer;
    }
}

void CMediaModelFactory::ReleaseMediaOnlinePlayer(){
    if (m_pMediaOnlinePlay) {
        delete m_pMediaOnlinePlay;
        m_pMediaOnlinePlay = NULL;
    }
}

CMediaSaveInterface* CMediaModelFactory::CreateMediaSaver(bool b_is_video){
    if (m_pMediaSaver) {
        delete m_pMediaSaver;
        m_pMediaSaver = NULL;
    }
    if (b_is_video) {
        return m_pMediaSaver = new CSaveVidio;
    }else {
        return m_pMediaSaver = new CSaveAudio;
    }
}

void CMediaModelFactory::ReleaseMediaSaver(){
    if (m_pMediaSaver) {
        delete m_pMediaSaver;
        m_pMediaSaver = NULL;
    }
}

COrigionSongPlayer* CMediaModelFactory::CreateOrigionSongPlayer(){
    if (m_pOrigionSongPlayer) {
        delete m_pOrigionSongPlayer;
        m_pOrigionSongPlayer = NULL;
    }
    return m_pOrigionSongPlayer = new COrigionSongPlayer;
}

void CMediaModelFactory::ReleaseOrigionSongPlayer(){
    if (m_pOrigionSongPlayer) {
        delete m_pOrigionSongPlayer;
        m_pOrigionSongPlayer = NULL;
    }
}

CMediaOnlinePlay* CMediaModelFactory::CreateLocalWorkPlayer(bool b_is_video){
    if (m_pLocalWorkPlayer) {
        delete m_pLocalWorkPlayer;
        m_pLocalWorkPlayer = NULL;
    }
    if (b_is_video) {
        return m_pLocalWorkPlayer = new CVideoWorkPlayer;
    }else {
        return m_pLocalWorkPlayer = new CAudioWorkPlayer;
    }
}

void CMediaModelFactory::ReleaseLocalWorkPlayer(){
    if (m_pLocalWorkPlayer) {
        delete m_pLocalWorkPlayer;
        m_pLocalWorkPlayer = NULL;
    }
}
