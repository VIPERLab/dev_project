//
//  KSAVPlayer.m
//  OnlineMusicPlayer
//
//  Created by 永杰 单 on 12-9-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KSAVPlayer.h"
#import "AudioHelper.h"
#include "MessageManager.h"
#include "IAudioStateObserver.h"

@implementation KSAVPlayer

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_pAudioAVPlayer release];
    m_pAudioAVPlayer = nil;
    [m_pAudioURL release];
    m_pAudioURL = nil;
    
    [super dealloc];
}

- (BOOL) initWithURL : (NSURL*)audio_url{
//    m_pAVPlayer = [[AVPlayer alloc] initWithURL:audio_url];
//    m_pAVPlayer = [[AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:audio_url]] retain];
    m_pAudioAVPlayer = [[AVPlayer alloc] init];
    [m_pAudioAVPlayer replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:audio_url]];
    
    m_pAudioAVPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:[m_pAudioAVPlayer currentItem]];
    
    m_bPlaying = NO;
    
    m_pAudioURL = [audio_url copy];
    return YES;
}

- (BOOL) play{
    
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [m_pAudioAVPlayer play];
    m_bPlaying = YES;
    
    return YES;
}

- (BOOL) continuePlay{
//    sleep(1);
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [m_pAudioAVPlayer play];
    m_bPlaying = YES;
    //    NSLog(@"%f", m_pAVPlayer.rate);
    return YES;
}

- (BOOL) pause{
    [m_pAudioAVPlayer pause];
    m_bPlaying = NO;
    
    return YES;
}

- (BOOL) stop{
    [m_pAudioAVPlayer pause];
    [m_pAudioAVPlayer seekToTime:kCMTimeZero];
    m_bPlaying = NO;
    
    return YES;
}

- (BOOL) seek : (float)f_seek_time;{
//    [m_pAVPlayer pause];
    if ((f_seek_time >= (([self loadedData] - 2000) / (float)1000)) || (f_seek_time >= (([self duration] - 2000) / (float)1000))) {
        return NO;
    }
    CMTime new_time = CMTimeMakeWithSeconds(f_seek_time, NSEC_PER_SEC);
    
    [m_pAudioAVPlayer seekToTime:new_time];
    
    return YES;
}

- (void) setVolume : (float)f_volume{
    AVURLAsset* p_audio_asset = [AVURLAsset assetWithURL:m_pAudioURL];
    NSArray* audio_tracks = [p_audio_asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray* audio_paras = [NSMutableArray array];
    for (AVAssetTrack* track in audio_tracks) {
        AVMutableAudioMixInputParameters* audio_input_paras = [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audio_input_paras setVolume:f_volume atTime:kCMTimeZero];
        [audio_input_paras setTrackID:[track trackID]];
        [audio_paras addObject:audio_input_paras];
    }
    AVMutableAudioMix* audio_accompany_zero_mix = [AVMutableAudioMix audioMix];
    [audio_accompany_zero_mix setInputParameters:audio_paras];
    [m_pAudioAVPlayer.currentItem setAudioMix:audio_accompany_zero_mix];
}

- (unsigned long) currentTime{
    return 1000 * CMTimeGetSeconds([m_pAudioAVPlayer currentTime]);
}

- (unsigned long) duration{
    return 1000 * CMTimeGetSeconds(m_pAudioAVPlayer.currentItem.asset.duration);
}

- (unsigned long) loadedData{
    if (0 == [m_pAudioAVPlayer.currentItem.loadedTimeRanges count]) {
        return 0;
    }
    return 1000 * CMTimeGetSeconds([[m_pAudioAVPlayer.currentItem.loadedTimeRanges objectAtIndex:0] CMTimeRangeValue].duration);
}

- (BOOL) isPlaying{
    return m_bPlaying;
}

- (void) playFinished:(NSNotification*)notification{
    [m_pAudioAVPlayer pause];
    [m_pAudioAVPlayer seekToTime:kCMTimeZero];
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::OnlinePlayFinish);
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
}

@end
