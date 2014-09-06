//
//  OrigionSongPlayer.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-31.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "OrigionSongPlayer.h"
#import "KSRecordTempPath.h"
#include "MessageManager.h"
#import "AudioHelper.h"
#include "HttpRequest.h"

#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioServices.h>

COrigionSongPlayer::COrigionSongPlayer(){
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    m_pAVPlayer = nil;
    m_CurPlayingStatus = PLAY_STATUS_NONE;
    
    UInt32 session_category = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(session_category), &session_category);
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    AudioSessionSetActive(true);
}

COrigionSongPlayer::~COrigionSongPlayer(){
    if (m_pAVPlayer) {
        [m_pAVPlayer pause];
        [m_pAVPlayer release];
        m_pAVPlayer = nil;
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

bool COrigionSongPlayer::Play(std::string str_song_rid){
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    
    CHttpRequest::CONVERT_URL_PARA para;
    para.strRid = str_song_rid;
    para.strBitrate = "";
    para.strContinueSig = "";
    para.bOnlyMusic = false;
    KS_BLOCK_DECLARE{
        std::string strFormat;
        std::string strBitrate;
        std::string strUrl;
        std::string strSig;
        CHttpRequest::ConvertUrl(para, strFormat, strBitrate, strUrl, strSig);
        NSString* str_http_url = [[NSString alloc] initWithUTF8String:strUrl.c_str()];
//      NSLog(@"%s", [str_http_url UTF8String]);
        m_pAVPlayer = [[KSAVPlayer alloc] init];
        [m_pAVPlayer initWithURL:[NSURL URLWithString:str_http_url]];
        m_CurPlayingStatus = PLAY_STATUS_PLAYING;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
            
        [m_pAVPlayer play];
        [str_http_url release];
        str_http_url = nil;
    }
    KS_BLOCK_RUN_THREAD();
    
    return true;
}

bool COrigionSongPlayer::Pause(){
    m_CurPlayingStatus = PLAY_STATUS_PAUSED;
//    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayPaused);
    
    return [m_pAVPlayer pause];
}

bool COrigionSongPlayer::ContinuePlay(){
    m_CurPlayingStatus = PLAY_STATUS_PLAYING;
//    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Playing);
    
    return [m_pAVPlayer play];
}

bool COrigionSongPlayer::Stop(){
    m_CurPlayingStatus = PLAY_STATUS_STOP;
//    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
    
    return [m_pAVPlayer stop];
}

bool COrigionSongPlayer::Seek(float f_time){
    if (PLAY_STATUS_PLAYING == m_CurPlayingStatus) {
        [m_pAVPlayer pause];
        if ([m_pAVPlayer seek:f_time]) {
            return [m_pAVPlayer play];
        }else {
            [m_pAVPlayer play];
            return false;
        }
    }else {
        return [m_pAVPlayer seek:f_time];
    }
}

int COrigionSongPlayer::CurrentTime()const{
    return [m_pAVPlayer currentTime];
}

int COrigionSongPlayer::Duration()const{
    return [m_pAVPlayer duration];
}

float COrigionSongPlayer::GetDownloadProgress()const{
    if (m_pAVPlayer && 0 != [m_pAVPlayer duration]) {
        return ((float)[m_pAVPlayer loadedData]) / [m_pAVPlayer duration];
    }else {
        return 0.0;
    }
    
}

EMediaPlayStatus COrigionSongPlayer::GetPlayingStatus()const{
    return m_CurPlayingStatus;
}

void COrigionSongPlayer::IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset){
    if (!bHasHeadset) {
        [m_pAVPlayer continuePlay];
    }
    UInt32 audio_route_override = bHasHeadset ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
}
