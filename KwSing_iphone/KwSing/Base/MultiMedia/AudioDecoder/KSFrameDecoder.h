//
//  KSFrameDecoder.h
//  AACDecoder
//
//  Created by 单 永杰 on 12-11-21.
//  Copyright (c) 2012年 单 永杰. All rights reserved.
//
/*
#import <Foundation/Foundation.h>
#include "avformat.h"

@interface KSFrameDecoder : NSObject{
    AVCodecContext* audioCodecContext_;
    int16_t* audioBuffer_;
    NSUInteger audioBufferSize_;
    BOOL bInitialized_;
}

@property AVCodecContext* audioCodecContext_;
@property int16_t* audioBuffer_;

-(bool)initDecoder:(AVFormatContext*)p_format_context stream_index:(int)n_stream_index;
-(int)decode:(AVPacket*)packet;

@end
*/