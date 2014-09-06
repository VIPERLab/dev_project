//
//  KSAVPlayer.h
//  OnlineMusicPlayer
//
//  Created by 永杰 单 on 12-9-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface KSAVPlayer : NSObject{
    AVPlayer* m_pAudioAVPlayer;
    BOOL m_bPlaying;
    NSURL* m_pAudioURL;
}

- (BOOL) initWithURL : (NSURL*)audio_url;
- (BOOL) play;
- (BOOL) continuePlay;
- (BOOL) pause;
- (BOOL) seek : (float)f_seek_time;
- (BOOL) stop;
- (unsigned long) currentTime;
- (unsigned long) duration;
- (void) setVolume : (float)f_volume;
- (BOOL) isPlaying;

- (unsigned long) loadedData;
- (void) playFinished:(NSNotification*)notification;

@end
