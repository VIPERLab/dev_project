//
//  AuditionPlay.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-17.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "AuditionPlay.h"
#include "MessageManager.h"
#include "KwDir.h"
#include "KSRecordTempPath.h"
#import "AudioHelper.h"
#include "KwConfigElements.h"
#include "KwConfig.h"
#include "RecordTask.h"

#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioServices.h>

CAuditionPlay::CAuditionPlay(){
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver);
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
    
    m_pSingPlayer = nil;
    m_pAcomPlayer = nil;
    m_nAudioDuration = 0;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

CAuditionPlay::~CAuditionPlay(){
    if (!CRecordTask::GetInstance()->m_bIsFreeSing && nil != m_pAcomPlayer) {
        [m_pAcomPlayer release];
        m_pAcomPlayer = nil;
    }
    
    if (m_pSingPlayer) {
        [m_pSingPlayer release];
        m_pSingPlayer = NULL;
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver);
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
}

bool CAuditionPlay::InitPlayer(UIView* p_view){
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        m_pAcomPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:CRecordTask::GetInstance()->m_strAccompanyPath.c_str()]] error:nil];
        [m_pAcomPlayer prepareToPlay];
        [m_pAcomPlayer setVolume:CRecordTask::GetInstance()->GetAccompanyVolume()];
    }
    
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    
    std::string record_file_path;
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        record_file_path = KwTools::Dir::GetFileName(CRecordTask::GetInstance()->m_strAccompanyPath);
        int n_index = record_file_path.rfind(".");
        record_file_path = [KSRecordTempPath getRecordTempPath] + "/" + record_file_path.substr(0, n_index) + "Record.wav";
    }else {
        record_file_path = [KSRecordTempPath getRecordTempPath] + "/FreeSing.wav";
    }
    
    m_pSingPlayer = [[KSAVAudioPlayer alloc] init];
    [m_pSingPlayer initPlayer:[NSString stringWithUTF8String:record_file_path.c_str()]];
    [m_pSingPlayer setVolume:CRecordTask::GetInstance()->GetSingVolume()];
    
    m_nAudioDuration = (int)(1000 * [m_pSingPlayer totalTime]);
    
    m_CurPlayStatus = PLAY_STATUS_NONE;
    
    if ([[AudioHelper getInstance] hasHeadset]) {
        UInt32 audio_route_override = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
        
    }else {
        UInt32 audio_route_override = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    }
    
    return true;
}

void CAuditionPlay::SetAudioEchoEffect(EAudioEchoEffect echo_effect){
    return;
}

bool CAuditionPlay::StartPlay(){        
    KS_BLOCK_DECLARE{
        [m_pSingPlayer startPlay];
        
        if (!CRecordTask::GetInstance()->m_bIsFreeSing && (nil != m_pAcomPlayer)) {
            [m_pAcomPlayer play];
        }
        
        m_CurPlayStatus = PLAY_STATUS_PLAYING;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
    }
    KS_BLOCK_ASYNRUN(0);
    
    return true;
}

bool CAuditionPlay::PausePlay(){
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        [m_pAcomPlayer pause];
    }
    [m_pSingPlayer pausePlay];
    m_CurPlayStatus = PLAY_STATUS_PAUSED;
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
    
    return true;
}

bool CAuditionPlay::ContinuePlay(){
    
    [m_pSingPlayer continuePlay];
    
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        [m_pAcomPlayer play];
    }

    m_CurPlayStatus = PLAY_STATUS_PLAYING;
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
    
    return true;
}

bool CAuditionPlay::Stop(){
    if(PLAY_STATUS_STOP == m_CurPlayStatus)
        return false;
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        [m_pAcomPlayer stop];
    }
    [m_pSingPlayer stopPlay];
    m_CurPlayStatus = PLAY_STATUS_STOP;
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
    
    return true;
}

bool CAuditionPlay::Seek(float f_seek_time){
    int n_seek_time = (int)f_seek_time / 1000;

    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        m_pAcomPlayer.currentTime = n_seek_time;
        if (!m_pAcomPlayer.isPlaying) {
            [m_pAcomPlayer play];
            [m_pAcomPlayer pause];
        }
    }
    
    if (nil != m_pSingPlayer) {
        [m_pSingPlayer seekPlayTime:(n_seek_time)];
    }
    
    return true;
}

int CAuditionPlay::CurrentTime()const{
    if (PLAY_STATUS_STOP == m_CurPlayStatus) {
        return 0.0;
    }
    
    if (m_pSingPlayer) {
        return 1000 * [m_pSingPlayer currentTime];
    }else {
        return 0;
    }
}

int CAuditionPlay::Duration()const{
    if (PLAY_STATUS_ERR == m_CurPlayStatus) {
        return 0;
    }
    
    return m_nAudioDuration;
}

EMediaPlayStatus CAuditionPlay::GetPlayStatus()const{
    return m_CurPlayStatus;
}

unsigned int CAuditionPlay::GetCurVolume(){
    return 0;
}

void CAuditionPlay::IAudioStateObserver_PlayStatusStop(){
    if (PLAY_STATUS_STOP == m_CurPlayStatus) {
        return;
    }
    
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        [m_pAcomPlayer stop];
    }
//    m_pQueuePlayer->StopPlay();
    [m_pSingPlayer stopPlay];
    
    m_CurPlayStatus = PLAY_STATUS_STOP;
}


void CAuditionPlay::IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset){
    
    UInt32 audio_route_override = bHasHeadset ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
}

void CAuditionPlay::IObserverApp_CallInComing(){
    if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
        [m_pAcomPlayer pause];
    }
    [m_pSingPlayer pausePlay];
    m_CurPlayStatus = PLAY_STATUS_PAUSED;
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
}
