//
//  VideoWorkPlayer.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-31.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "VideoWorkPlayer.h"
#include "MessageManager.h"
#include "IAudioStateObserver.h"
#import "AudioHelper.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

CVideoWorkPlayer::CVideoWorkPlayer(){
    m_pVideoPlayer = [[KSVideoPlayer alloc] init];
    m_CurStatus = PLAY_STATUS_NONE;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_VIDEOSTATUS, IVideoStateObserver);
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
}

CVideoWorkPlayer::~CVideoWorkPlayer(){
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_VIDEOSTATUS, IVideoStateObserver);
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
    DeinitPlayer();
    m_CurStatus = PLAY_STATUS_NONE;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

bool CVideoWorkPlayer::InitPlayer(MUSIC_RESOURCE *music_resource, UIView* p_view){
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    UInt32 session_category = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(session_category), &session_category);
    
    if ([m_pVideoPlayer initVideoPlayer:p_view VideoFilePath:music_resource->strLocalPath.c_str()]) {
        return true;
    }else {
        m_CurStatus = PLAY_STATUS_ERR;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
        return false;
    }
}

bool CVideoWorkPlayer::Play(){
    if ([m_pVideoPlayer start]) {
        m_CurStatus = PLAY_STATUS_PLAYING;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
        return true;
    }else {
        m_CurStatus = PLAY_STATUS_ERR;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
        return false;
    }
}

bool CVideoWorkPlayer::Pause(){
    if ([m_pVideoPlayer pause]) {
        m_CurStatus = PLAY_STATUS_PAUSED;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
        return true;
    }else {
        m_CurStatus = PLAY_STATUS_ERR;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
        return false;
    }
}

bool CVideoWorkPlayer::ContinuePlay(){
    if ([m_pVideoPlayer resume]) {
        m_CurStatus = PLAY_STATUS_PLAYING;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
        return true;
    }else {
        m_CurStatus = PLAY_STATUS_ERR;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
        return false;
    }
}

bool CVideoWorkPlayer::Stop(){
    if ([m_pVideoPlayer stop]) {
        m_CurStatus = PLAY_STATUS_STOP;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
        return true;
    }else {
        m_CurStatus = PLAY_STATUS_ERR;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
        return false;
    }
}

bool CVideoWorkPlayer::Seek(float f_seek_time){
    if ([m_pVideoPlayer seek:(f_seek_time / 1000)]) {
        return true;
    }else {
        return false;
    }
}

bool CVideoWorkPlayer::DeinitPlayer(){
    if (m_pVideoPlayer) {
        [m_pVideoPlayer deinitVideoPlayer];
        [m_pVideoPlayer release];
        m_pVideoPlayer = nil;
    }
    
    return true;
}

int CVideoWorkPlayer::CurrentTime()const{
    return 1000 * [m_pVideoPlayer currentTime];
}

int CVideoWorkPlayer::Duration()const{
    return 1000 * [m_pVideoPlayer duration];
}

EMediaPlayStatus CVideoWorkPlayer::GetPlayingStatus()const{
    return m_CurStatus;
}

void CVideoWorkPlayer::IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset){
    if (!bHasHeadset) {
        sleep(1);
        [m_pVideoPlayer start];
    }
    UInt32 audio_route_override = bHasHeadset ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
}

void CVideoWorkPlayer::IObserverApp_ResignActive(){
    [m_pVideoPlayer pause];
    m_CurStatus = PLAY_STATUS_PAUSED;
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
}

void CVideoWorkPlayer::IVideoStateObserver_PlayStatusStop(){
    m_CurStatus = PLAY_STATUS_STOP;
    [m_pVideoPlayer stop];
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
}

void CVideoWorkPlayer::IObserverApp_CallInComing(){
    if ([m_pVideoPlayer pause]) {
        m_CurStatus = PLAY_STATUS_PAUSED;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
    }else {
        m_CurStatus = PLAY_STATUS_ERR;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
    }
}
