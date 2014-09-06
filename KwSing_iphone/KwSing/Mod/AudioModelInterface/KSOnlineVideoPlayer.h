//
//  KSOnlineVideoPlayer.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-22.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>

#ifndef KwSing_IObserverApp_h
#include "IObserverApp.h"
#endif

#ifndef KwSing_MediaStatus_h
#include "MediaStatus.h"
#endif

@interface KSOnlineVideoPlayer : NSObject<IObserverApp>{
    MPMoviePlayerController* m_pMoviePlayer;
    BOOL m_bIsMoviePlaying;
    EMediaPlayStatus m_CurPlayStatus;
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
- (EMediaPlayStatus)getCurPlayStatus;

- (void)MovieFinishedCallback:(NSNotification*)aNotification;
- (void)DownloadStatusChanged:(NSNotification*)aNotification;
@end
