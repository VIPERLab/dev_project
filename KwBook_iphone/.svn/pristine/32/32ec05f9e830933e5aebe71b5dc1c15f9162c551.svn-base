//
//  KBLocalAudioPlayer.m
//  kwbook
//
//  Created by 单 永杰 on 13-11-29.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import "KBLocalAudioPlayer.h"
#include "MessageManager.h"
#include "IObserverAudioPlayState.h"
#include "IObserverNetBufferringState.h"
#include "UMengLog.h"
#include "KwUMengElement.h"
#import "iToast.h"

static bool s_b_local_audio_interrupted = false;

@implementation KBLocalAudioPlayer

- (BOOL) resetPlayer : (CChapterInfo*) song_info{
    if (nil == m_AudioPlayer) {
        NSURL* audio_url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%s", song_info->m_strLocalPath.c_str()]];
        m_AudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audio_url error:nil];
        [m_AudioPlayer setDelegate:self];
        if ([m_AudioPlayer prepareToPlay]) {
            UMengLog(KB_PLAY_LOCAL, "Success");
            [m_AudioPlayer play];
            SYN_NOTIFY(OBSERVER_ID_PLAY_STATE, IObserverAudioPlayState::AudioPlayStatusChanged, E_AUDIO_PLAY_PLAYING);
            return YES;
        }else{
            UMengLog(KB_PLAY_LOCAL, "Fail");
            [iToast defaultShow:@"播放错误，请尝试删除下载文件，重新下载"];
            SYN_NOTIFY(OBSERVER_ID_PLAY_STATE, IObserverAudioPlayState::AudioPlayStatusChanged, E_AUDIO_PLAY_NONE);
            return NO;
        }
    }else {
        [m_AudioPlayer stop];
    
        NSURL* audio_url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%s", song_info->m_strLocalPath.c_str()]];
        m_AudioPlayer = [m_AudioPlayer initWithContentsOfURL:audio_url error:nil];
        [m_AudioPlayer setDelegate:self];
        if ([m_AudioPlayer prepareToPlay]) {
            [m_AudioPlayer play];
            SYN_NOTIFY(OBSERVER_ID_PLAY_STATE, IObserverAudioPlayState::AudioPlayStatusChanged, E_AUDIO_PLAY_PLAYING);
            return YES;
        }else{
            SYN_NOTIFY(OBSERVER_ID_PLAY_STATE, IObserverAudioPlayState::AudioPlayStatusChanged, E_AUDIO_PLAY_NONE);
            return NO;
        }
    }
    
    SYN_NOTIFY(OBSERVER_ID_BUFFER_STATE, IObserverNetBufferringState::BufferringRatioChanged, 1.0);
}

- (BOOL) pause{
    if (m_AudioPlayer.isPlaying) {
        [m_AudioPlayer pause];
    }
    
    SYN_NOTIFY(OBSERVER_ID_PLAY_STATE, IObserverAudioPlayState::AudioPlayStatusChanged, E_AUDIO_PLAY_PAUSE);
    
    return YES;
}

- (BOOL) resume{
    if (m_AudioPlayer.isPlaying) {
        return YES;
    }
    
    [m_AudioPlayer play];
    
    SYN_NOTIFY(OBSERVER_ID_PLAY_STATE, IObserverAudioPlayState::AudioPlayStatusChanged, E_AUDIO_PLAY_PLAYING);
    
    return YES;
}

- (BOOL) stop{
    if (!m_AudioPlayer) {
        return NO;
    }
    [m_AudioPlayer stop];
    
    SYN_NOTIFY(OBSERVER_ID_PLAY_STATE, IObserverAudioPlayState::AudioPlayStatusChanged, E_AUDIO_PLAY_STOP);
    
    return YES;
}

- (BOOL) seek : (float) f_seek_sec{
    m_AudioPlayer.currentTime = f_seek_sec;
    if (!m_AudioPlayer.isPlaying) {
        [m_AudioPlayer play];
        [m_AudioPlayer pause];
    }
    
    return YES;
}

- (float)currentTime{
    if (m_AudioPlayer) {
        return m_AudioPlayer.currentTime;
    }else {
        return 0.0;
    }
}

- (float)duration{
    if (m_AudioPlayer) {
        return m_AudioPlayer.duration;
    }else {
        return 0.0;
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (player == m_AudioPlayer) {
        if (flag) {
            SYN_NOTIFY(OBSERVER_ID_PLAY_STATE, IObserverAudioPlayState::AudioPlayStatusChanged, E_AUDIO_PLAY_FINISH);
        }else {
            SYN_NOTIFY(OBSERVER_ID_PLAY_STATE, IObserverAudioPlayState::AudioPlayStatusChanged, E_AUDIO_PLAY_NONE);
        }
        
    }
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    if (player == m_AudioPlayer && m_AudioPlayer) {
        s_b_local_audio_interrupted = true;
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    if (s_b_local_audio_interrupted && player == m_AudioPlayer && m_AudioPlayer) {
        [m_AudioPlayer play];
        s_b_local_audio_interrupted = false;
    }
}

@end
