//
//  KSAVAudioPlayer.h
//  KwSing
//
//  Created by 永杰 单 on 12-7-18.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#ifndef KwSing_EnumPlayStatus_h
#include "EnumPlayStatus.h"
#endif

@interface KSAVAudioPlayer : NSObject <AVAudioPlayerDelegate> {
    AVAudioPlayer* m_AudioPlayer;
}

- (enum EPlayStatus) initPlayer : (NSString*) str_file_path;
- (enum EPlayStatus) startPlay;
- (void) pausePlay;
- (enum EPlayStatus) continuePlay;
- (void) stopPlay;
- (enum EPlayStatus) seekPlayTime : (float)f_seek_time;
- (BOOL) isPlaying;
- (double) currentTime;
- (double) totalTime;
- (void) setVolume : (float)f_volume;

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
@end
