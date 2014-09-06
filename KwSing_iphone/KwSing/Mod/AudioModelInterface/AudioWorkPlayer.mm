//
//  AudioWorkPlayer.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-31.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "AudioWorkPlayer.h"
#include "MessageManager.h"
#include "IAudioStateObserver.h"
#import "AudioHelper.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

CAudioWorkPlayer::CAudioWorkPlayer(){
    m_pAudioPlayer = [[KSAVPlayer alloc] init];
    m_nAudioLenInMiliSeconds = 0;
    m_CurStatus = PLAY_STATUS_NONE;
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

CAudioWorkPlayer::~CAudioWorkPlayer(){
    if (m_pAudioPlayer) {
        [m_pAudioPlayer release];
        m_pAudioPlayer = nil;
    }
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

bool CAudioWorkPlayer::InitPlayer(MUSIC_RESOURCE *music_resource, UIView* p_view){
    [m_pAudioPlayer initWithURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:music_resource->strLocalPath.c_str()]]];
    UInt32 session_category = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(session_category), &session_category);
    
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    
    return true;
}

bool CAudioWorkPlayer::Play(){
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if ([m_pAudioPlayer play]) {
        m_CurStatus = PLAY_STATUS_PLAYING;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
        return true;
    }else {
        m_CurStatus = PLAY_STATUS_ERR;
        [m_pAudioPlayer stop];
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
        return false;
    }
}

bool CAudioWorkPlayer::Pause(){
    if ([m_pAudioPlayer pause]) {
        m_CurStatus = PLAY_STATUS_PAUSED;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
        return true;
    }else {
        m_CurStatus = PLAY_STATUS_ERR;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
        return false;
    }
}

bool CAudioWorkPlayer::ContinuePlay(){
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if ([m_pAudioPlayer play]) {
        m_CurStatus = PLAY_STATUS_PLAYING;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
        return true;
    }else {
        m_CurStatus = PLAY_STATUS_ERR;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
        return false;
    }
}

bool CAudioWorkPlayer::Stop(){
    if ([m_pAudioPlayer stop]) {
        m_CurStatus = PLAY_STATUS_STOP;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
        return true;
    }else {
        m_CurStatus = PLAY_STATUS_ERR;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
        return false;
    }
}

bool CAudioWorkPlayer::Seek(float f_seek_time){
    if (m_pAudioPlayer.isPlaying) {
        [m_pAudioPlayer pause];
        if ([m_pAudioPlayer seek:(f_seek_time / 1000)]) {
            [m_pAudioPlayer play];
            return true;
        }else {
            [m_pAudioPlayer play];
            return false;
        }
    }else {
        return [m_pAudioPlayer seek:f_seek_time];
    }
}

int CAudioWorkPlayer::CurrentTime()const{
    return [m_pAudioPlayer currentTime];
}

int CAudioWorkPlayer::Duration()const{
    return [m_pAudioPlayer duration];
}

EMediaPlayStatus CAudioWorkPlayer::GetPlayingStatus()const{
    return m_CurStatus;
}

void CAudioWorkPlayer::IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset){
    if (!bHasHeadset) {
        sleep(1);
        [m_pAudioPlayer continuePlay];
    }
    
    UInt32 audio_route_override = bHasHeadset ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

void CAudioWorkPlayer::IObserverApp_CallInComing(){
    if ([m_pAudioPlayer pause]) {
        m_CurStatus = PLAY_STATUS_PAUSED;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
    }else {
        m_CurStatus = PLAY_STATUS_ERR;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
    }
}
