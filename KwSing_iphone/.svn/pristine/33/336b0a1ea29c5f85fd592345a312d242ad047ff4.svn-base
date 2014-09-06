//
//  OnlineAudioPlayer.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-15.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "OnlineAudioPlayer.h"
#include "MessageManager.h"
#import "AudioHelper.h"

#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioServices.h>

#define FIRST_CACHE_TIME 10 //in Seconds
#define INTERRUPT_CACHE_TIME 15 //in Seconds

COnlineAudioPlayer::COnlineAudioPlayer(){
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver);
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
    
    m_pAVPlayer = [[KSAVPlayer alloc] init];
    m_CurPlayingStatus = PLAY_STATUS_NONE;
    m_fDownloadRange = 0.f;
    
    UInt32 session_category = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(session_category), &session_category);
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    AudioSessionSetActive(true);
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

COnlineAudioPlayer::~COnlineAudioPlayer(){
    AudioSessionSetActive(false);
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver);
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
    
    if (m_pAVPlayer) {
        [m_pAVPlayer release];
        m_pAVPlayer = nil;
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

int COnlineAudioPlayer::Duration()const{
    if (m_pAVPlayer) {
        return [m_pAVPlayer duration];
    }else {
        return 0;
    }
}

int COnlineAudioPlayer::CurrentTime()const{
    if (m_pAVPlayer) {
        return [m_pAVPlayer currentTime];
    }else {
        return 0;
    }
}

float COnlineAudioPlayer::GetDownloadProgress(){
    if (m_pAVPlayer && 0 != [m_pAVPlayer duration]) {
        float f_down_progress = ((float)[m_pAVPlayer loadedData]) / [m_pAVPlayer duration];
        m_fDownloadRange = (f_down_progress > m_fDownloadRange) ? f_down_progress : m_fDownloadRange;
        return m_fDownloadRange;
    }else {
        return 0.0;
    }
}

EMediaPlayStatus COnlineAudioPlayer::GetPlayingStatus()const{
    return m_CurPlayingStatus;
}

bool COnlineAudioPlayer::InitPlayer(MUSIC_RESOURCE *music_resource, UIView* p_view){
    return [m_pAVPlayer initWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:music_resource->strUrl.c_str()]]];
}

bool COnlineAudioPlayer::Play(){
    m_CurPlayingStatus = PLAY_STATUS_PLAYING;
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
    
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    return [m_pAVPlayer play];
}

bool COnlineAudioPlayer::Pause(){
    m_CurPlayingStatus = PLAY_STATUS_PAUSED;
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
    return [m_pAVPlayer pause];
}

bool COnlineAudioPlayer::ContinuePlay(){    
    m_CurPlayingStatus = PLAY_STATUS_PLAYING;
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    return [m_pAVPlayer play];
}

bool COnlineAudioPlayer::Stop(){
    m_CurPlayingStatus = PLAY_STATUS_STOP;
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
    
    return [m_pAVPlayer stop];
}

bool COnlineAudioPlayer::Seek(float f_time){
    if (m_pAVPlayer.isPlaying) {
        [m_pAVPlayer pause];
        if([m_pAVPlayer seek:(f_time / 1000)]){
            return [m_pAVPlayer play];
        }else {
            [m_pAVPlayer play];
            return false;
        }
    }else {
        return [m_pAVPlayer seek:f_time];
    }
}

void COnlineAudioPlayer::IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset){
    if (!bHasHeadset && PLAY_STATUS_PLAYING == m_CurPlayingStatus) {
        sleep(1);
        [m_pAVPlayer continuePlay];
    }
    
    UInt32 audio_route_override = bHasHeadset ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

void COnlineAudioPlayer::IObserverApp_CallInComing(){
    m_CurPlayingStatus = PLAY_STATUS_PAUSED;
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
    [m_pAVPlayer pause];
}
