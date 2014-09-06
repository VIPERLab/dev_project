//
//  KSMvRecord.h
//  KwSing
//
//  Created by 单 永杰 on 13-11-8.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "SongInfo.h"

@interface KSMvRecord : NSObject

- (void) initRecorder : (CSongInfoBase*) song_info withView : (UIView*)view;
- (bool) pause;
- (bool) resume;
- (bool) stop;

- (bool) setSingVolume : (float)f_sing_volume;
- (bool) setAcomVolume : (float)f_acom_volume;
- (bool) switchOrigAcom : (bool)b_Orig;

- (long) currentTime;
- (long) duration;

- (bool) reset;
@end
