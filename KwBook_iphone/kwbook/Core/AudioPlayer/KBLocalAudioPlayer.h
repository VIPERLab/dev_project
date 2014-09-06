//
//  KBLocalAudioPlayer.h
//  kwbook
//
//  Created by 单 永杰 on 13-11-29.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include "ChapterInfo.h"

@interface KBLocalAudioPlayer : NSObject <AVAudioPlayerDelegate>{
    AVAudioPlayer* m_AudioPlayer;
}

- (BOOL) resetPlayer : (CChapterInfo*) song_info;
- (BOOL) pause;
- (BOOL) resume;
- (BOOL) stop;
- (BOOL) seek : (float) f_seek_sec;

- (float)currentTime;
- (float)duration;

@end
