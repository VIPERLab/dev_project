//
//  COnlineVideoPlayer.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "COnlineVideoPlayer.h"

COnlineVideoPlayer::COnlineVideoPlayer(){
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    m_pMoviePlayer = [[KSOnlineVideoPlayer alloc] init];
    m_fCurDownload = 0.f;
}

COnlineVideoPlayer::~COnlineVideoPlayer(){
    if (m_pMoviePlayer) {
        [m_pMoviePlayer deinitVideoPlayer];
        [m_pMoviePlayer release];
        m_pMoviePlayer = nil;
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

bool COnlineVideoPlayer::InitPlayer(MUSIC_RESOURCE *music_resource, UIView* p_view){
    if (m_pMoviePlayer) {
        return [m_pMoviePlayer initVideoPlayer:p_view VideoFilePath:music_resource->strUrl.c_str()];
    }
    else {
        return false;
    }
}

bool COnlineVideoPlayer::Play(){
    if (m_pMoviePlayer) {
        return [m_pMoviePlayer start];
    }else {
        return false;
    }
}

bool COnlineVideoPlayer::Pause(){
    if (m_pMoviePlayer) {
        return [m_pMoviePlayer pause];
    }else {
        return false;
    }
}

bool COnlineVideoPlayer::ContinuePlay(){
    if (m_pMoviePlayer) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        return [m_pMoviePlayer resume];
    }else {
        return false;
    }
}

bool COnlineVideoPlayer::Stop(){
    if (m_pMoviePlayer) {
        return [m_pMoviePlayer stop];
    }else {
        return false;
    }
}

bool COnlineVideoPlayer::Seek(float f_time){
    if (m_pMoviePlayer) {
        return [m_pMoviePlayer seek:(f_time / 1000)];
    }else {
        return false;
    }
}

int COnlineVideoPlayer::CurrentTime()const{
    if (m_pMoviePlayer && 0 < m_pMoviePlayer.duration) {
        return [m_pMoviePlayer currentTime];
    }else {
        return 0.0;
    }
}

int COnlineVideoPlayer::Duration()const{
    if (m_pMoviePlayer) {
        return [m_pMoviePlayer duration];
    }else {
        return 0.0;
    }
}

EMediaPlayStatus COnlineVideoPlayer::GetPlayingStatus()const{
    if (m_pMoviePlayer) {
        return [m_pMoviePlayer getCurPlayStatus];
    }else {
        return PLAY_STATUS_NONE;
    }
}

float COnlineVideoPlayer::GetDownloadProgress(){
    if (m_pMoviePlayer && (0.0 != [m_pMoviePlayer duration])) {
        float f_cur_progress = (((float)[m_pMoviePlayer playableDuration]) / [m_pMoviePlayer duration]);
        m_fCurDownload = f_cur_progress > m_fCurDownload ? f_cur_progress : m_fCurDownload;
        return m_fCurDownload;
    }else {
        return 0;
    }
}
