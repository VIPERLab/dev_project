//
//  LocalVideoPlayer.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "LocalVideoPlayer.h"
#include "MessageManager.h"
#include "KwDir.h"
#include "KSRecordTempPath.h"
#include "IAudioStateObserver.h"
#include "KwConfig.h"
#include "KwConfigElements.h"
#include "RecordTask.h"

#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioServices.h>

CLocalVideoPlayer::CLocalVideoPlayer(){
    m_pSingPlayer = nil;
    m_pAcomPlayer = nil;
    m_pMoviePlayer = nil;
    m_CurPlayStatus = PLAY_STATUS_NONE;

    m_nMovieDuration = 0;
    m_strRecordFilePath = "";
    m_bStoped = false;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_VIDEOSTATUS, IVideoStateObserver);
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver);
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
}

CLocalVideoPlayer::~CLocalVideoPlayer(){
    m_strRecordFilePath = "";
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_VIDEOSTATUS, IVideoStateObserver);
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver);
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
    DeinitPlayer();
}

bool CLocalVideoPlayer::InitPlayer(UIView* p_view){    
    if (nil != p_view) {
        m_pMoviePlayer = [[KSVideoPlayer alloc] init];
    }
    
    std::string str_movie_file_name;
    bool b_init_success = false;
    m_nMovieDuration = 0;
    
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        std::string record_file_path = KwTools::Dir::GetFileName(CRecordTask::GetInstance()->m_strAccompanyPath);
        int n_index = record_file_path.rfind(".");
        record_file_path = [KSRecordTempPath getRecordTempPath] + "/" + record_file_path.substr(0, n_index);

        m_strRecordFilePath = record_file_path + "Record.wav";
        str_movie_file_name = record_file_path + ".mp4";
    }else {
        m_strRecordFilePath = [KSRecordTempPath getRecordTempPath] + "/FreeSing.wav";
        str_movie_file_name = [KSRecordTempPath getRecordTempPath] + "/FreeSing.mp4";
    }
    
    if (nil != p_view) {
        b_init_success = [m_pMoviePlayer initVideoPlayer:p_view VideoFilePath:str_movie_file_name.c_str()];
        [m_pMoviePlayer start];
        [m_pMoviePlayer pause];
    }else {
        b_init_success = true;
    }
    
    if (!b_init_success) {
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
    }
    
    return b_init_success;
}

void CLocalVideoPlayer::SetAudioEchoEffect(EAudioEchoEffect echo_effect){
//    if (m_pQueuePlayer) {
//        m_pQueuePlayer->SetEchoType(echo_effect);
//    }
}

bool CLocalVideoPlayer::StartPlay(){
    m_bStoped = false;
    
    m_pSingPlayer = [[KSAVAudioPlayer alloc] init];

    [m_pSingPlayer initPlayer:[NSString stringWithUTF8String:m_strRecordFilePath.c_str()]];
    
    KS_BLOCK_DECLARE{
        int n_sing_volume(100);
        KwConfig::GetConfigureInstance()->GetConfigIntValue(AUDIO_EFFECT_GROUP, VOLUME_SING, n_sing_volume, 100);
        
        int n_accompany_volume(100);
        KwConfig::GetConfigureInstance()->GetConfigIntValue(AUDIO_EFFECT_GROUP, VOLUME_ACCOMPANY, n_accompany_volume, 100);
        
        if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
            m_pAcomPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:(CRecordTask::GetInstance()->m_strAccompanyPath.c_str())]] error:nil];
            [m_pAcomPlayer prepareToPlay];
        }
        
        if (nil != m_pMoviePlayer) {
            [m_pMoviePlayer start];
        }
        
        [m_pSingPlayer startPlay];
        if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
            [m_pAcomPlayer play];
            [m_pAcomPlayer setVolume : n_accompany_volume / (float)100];
        }
        
        [m_pSingPlayer setVolume : (n_sing_volume / (float)100) ];
        
        m_nMovieDuration = 1000 * [m_pMoviePlayer duration];

        m_CurPlayStatus = PLAY_STATUS_PLAYING;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
    }
    KS_BLOCK_ASYNRUN(100);
    
    return true;
}

bool CLocalVideoPlayer::Stop(){
    if (m_pMoviePlayer) {
        [m_pMoviePlayer stop];
    }
    
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        [m_pAcomPlayer stop];
    }
    [m_pSingPlayer stopPlay];
    
    m_CurPlayStatus = PLAY_STATUS_STOP;
    m_bStoped = true;
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
    
    return true;
}

bool CLocalVideoPlayer::PausePlay(){
    if (m_pMoviePlayer) {
        [m_pMoviePlayer pause];
    }
    
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        [m_pAcomPlayer pause];
    }
    [m_pSingPlayer pausePlay];
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
    m_CurPlayStatus = PLAY_STATUS_PAUSED;
    
    return true;
}

bool CLocalVideoPlayer::ContinuePlay(){
    if (m_pMoviePlayer) {
        [m_pMoviePlayer resume];
    }
    
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        [m_pAcomPlayer play];
    }
    
    [m_pSingPlayer continuePlay];
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
    m_CurPlayStatus = PLAY_STATUS_PLAYING;
    
    return true;
}

bool CLocalVideoPlayer::Seek(float f_seek_time){
    int n_seek_time = f_seek_time / 1000;
    
    if (PLAY_STATUS_PLAYING != m_CurPlayStatus) {
        return false;
    }
    
    if (NULL != m_pMoviePlayer && n_seek_time >= [m_pMoviePlayer playableDuration]) {
        return false;
    }
    
    if (m_pMoviePlayer) {
        [m_pMoviePlayer seek:n_seek_time];
    }
    
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        m_pAcomPlayer.currentTime = n_seek_time;
        if (!m_pAcomPlayer.isPlaying) {
            [m_pAcomPlayer play];
            [m_pAcomPlayer pause];
        }
    }
    
    [m_pSingPlayer seekPlayTime:n_seek_time];
    
    return true;
}

int CLocalVideoPlayer::CurrentTime()const{
    if (m_pSingPlayer) {
        return 1000 * [m_pSingPlayer currentTime];
    }
    
    return 0;
}

int CLocalVideoPlayer::Duration()const{

     return 1000 * [m_pMoviePlayer duration];
}

EMediaPlayStatus CLocalVideoPlayer::GetPlayStatus()const{
    return m_CurPlayStatus;
}

unsigned int CLocalVideoPlayer::GetCurVolume(){
//    if (m_pQueuePlayer && m_bPlayStarted) {
//        return m_pQueuePlayer->GetCurVolume();
//    }else {
//        return 0;
//    }
    return 0;
}

bool CLocalVideoPlayer::DeinitPlayer(){
    if (m_pMoviePlayer) {
        [m_pMoviePlayer deinitVideoPlayer];
        [m_pMoviePlayer release];
        m_pMoviePlayer = nil;
    }
    
    if (m_pAcomPlayer) {
        [m_pAcomPlayer release];
        m_pAcomPlayer = nil;
    }
    
    if (m_pSingPlayer) {
        [m_pSingPlayer release];
        m_pSingPlayer = nil;
    }
    
    return true;
}
//
//void CLocalVideoPlayer::IVideoStateObserver_PlayStatusStop(){
//    Stop();
//}

void CLocalVideoPlayer::IAudioStateObserver_PlayStatusStop(){
    if (!m_bStoped) {
        m_bStoped = true;
        Stop();
    }
}

void CLocalVideoPlayer::IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset){
    if (!bHasHeadset && m_pMoviePlayer) {
        [m_pMoviePlayer start];
    }
    
    UInt32 audio_route_override = bHasHeadset ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
}

void CLocalVideoPlayer::IObserverApp_CallInComing(){
    if (m_pMoviePlayer) {
        [m_pMoviePlayer pause];
    }
    
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        [m_pAcomPlayer pause];
    }
    [m_pSingPlayer pausePlay];
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
    m_CurPlayStatus = PLAY_STATUS_PAUSED;
}
