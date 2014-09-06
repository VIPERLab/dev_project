//
//  KSVideoPlayer.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>

#ifndef KwSing_IVideoStateObserver_h
#include "IVideoStateObserver.h"
#endif

@interface KSVideoPlayer : NSObject{
    MPMoviePlayerController* m_pMoviePlayer;
    NSTimeInterval m_PauseTime;
    bool m_bPlaying;
}

- (bool)initVideoPlayer:(UIView*)p_view VideoFilePath:(const char*)str_video_path;
- (void)deinitVideoPlayer;
- (bool)start;
- (bool)stop;
- (bool)pause;
- (bool)resume;
- (bool)seek:(float)f_seek_time;

- (float)currentTime;
- (float)duration;
- (float)playableDuration;

- (void)MovieFinishedCallback:(NSNotification*)aNotification;

@end
