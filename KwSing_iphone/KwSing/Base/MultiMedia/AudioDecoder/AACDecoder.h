//
//  AACDecoder.h
//  AACDecoder
//
//  Created by 单 永杰 on 12-11-7.
//  Copyright (c) 2012年 单 永杰. All rights reserved.
//
/*
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "avformat.h"
#include "avcodec.h"
#include "swscale.h"

@interface AACDecoder : NSObject{
    AVFormatContext* inputFormatContext_;
    AVCodecContext* audioCodecContext_;
    AVStream* audioStream_;
    AVPacket packet_, currentPacket_;
    
    NSString* inputFilePath_;
    NSInteger audioStreamIndex_, decodedDataSize_;
    int16_t* audioBuffer_;
    NSUInteger audioBufferSize_;
    BOOL inBuffer_;
}

@property AVCodecContext* audioCodecContext_;
@property int16_t* audioBuffer_;

- (NSInteger) loadFile : (NSString*)filePath;
- (NSTimeInterval) duration;
- (void) seekTime : (NSTimeInterval)seconds;
- (AVPacket*) readPacket;
- (NSInteger) decodeAAC;
- (void) nextPacket;
- (int) totalDecodedSize;

@end
*/