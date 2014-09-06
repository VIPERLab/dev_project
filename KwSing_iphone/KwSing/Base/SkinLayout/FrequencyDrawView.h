//
//  FrequencyDrawView.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__FrequencyDrawView__
#define __KwSing__FrequencyDrawView__


#define FREQUENCY_VIEW_HEIGHT (IsIphone5()?179:91)

class CLyricInfo;
class CMediaInterface;

@interface KSFrequencyDrawView : UIView

- (void)setLyric:(CLyricInfo*)lyric recalculatePoints:(BOOL)recal;
- (void)setMediaInterface:(CMediaInterface*)media;
- (void)start;
- (void)stop;
- (void)continue;
- (unsigned)getTotalPoint;

@end


#endif
