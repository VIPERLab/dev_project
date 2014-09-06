//
//  KSAVAudioPlayer.m
//  KwSing
//
//  Created by 永杰 单 on 12-7-18.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSAVAudioPlayer.h"
#include "MessageManager.h"
#include "IAudioStateObserver.h"

@implementation KSAVAudioPlayer

- (id) init {
    self = [super init];
    m_AudioPlayer = [[AVAudioPlayer alloc] init];
    
//    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
    
    return self;
}

- (void) dealloc{
    [m_AudioPlayer release];
    
//    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
    
    [super dealloc];
}

- (enum EPlayStatus) initPlayer:(NSString *)str_file_path{
    NSURL* music_url = [NSURL fileURLWithPath:str_file_path];
    if (music_url) {
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [m_AudioPlayer initWithContentsOfURL:music_url error:nil];
        if (![m_AudioPlayer prepareToPlay]) {
            return PREPARE_ERR;
        }
        [m_AudioPlayer setDelegate:self];
    }else {
        return PREPARE_ERR;
    }
    
    return PREPARE_SUCCESS;
}

- (enum EPlayStatus) startPlay{
        
    if (![m_AudioPlayer play]) {
        return PLAY_ERR;
    }
        
    return PLAY_SUCESS;
}

- (void) pausePlay{
    if (m_AudioPlayer) {
        [m_AudioPlayer pause];
    }
}

- (enum EPlayStatus) continuePlay{
    if (m_AudioPlayer) {
        if ([m_AudioPlayer play]) {
            return PLAY_SUCESS;
        }else {
            return PLAY_ERR;
        }
    }else {
        return PLAY_ERR;
    }
}

- (void) stopPlay{
    if (m_AudioPlayer) {
        [m_AudioPlayer stop];
        [self seekPlayTime:0];
    }
}

- (enum EPlayStatus) seekPlayTime:(float)f_seek_time{
    if (m_AudioPlayer) {
        m_AudioPlayer.currentTime = f_seek_time;
        if (!m_AudioPlayer.isPlaying) {
            [m_AudioPlayer play];
            [m_AudioPlayer pause];
        }
        
        return SEEK_SUCESS;
    }else {
        
        return SEEK_ERR;
    }
}

- (BOOL) isPlaying{
    if (m_AudioPlayer) {
        return m_AudioPlayer.playing;
    }else {
        return NO;
    }
}

- (double) currentTime{
    if (m_AudioPlayer) {
        return m_AudioPlayer.currentTime;
    }else {
        return 0;
    }
}

- (double) totalTime{
    if (m_AudioPlayer) {
        return m_AudioPlayer.duration;
    }else {
        return 0;
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (player == m_AudioPlayer) {
        if (flag) {
            SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
        }else {
            SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayErr);
        }
        
    }
}

- (void) setVolume : (float)f_volume{ 
    m_AudioPlayer.volume = f_volume;
}

@end
