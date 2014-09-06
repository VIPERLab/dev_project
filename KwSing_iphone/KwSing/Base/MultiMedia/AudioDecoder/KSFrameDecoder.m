//
//  KSFrameDecoder.m
//  AACDecoder
//
//  Created by 单 永杰 on 12-11-21.
//  Copyright (c) 2012年 单 永杰. All rights reserved.
//
/*
#import "KSFrameDecoder.h"

@implementation KSFrameDecoder

@synthesize audioCodecContext_;
@synthesize audioBuffer_;

-(bool)initDecoder:(AVFormatContext *)p_format_context stream_index:(int)n_stream_index{
    if (bInitialized_) {
        return true;
    }
    audioCodecContext_ = p_format_context->streams[n_stream_index]->codec;
    
    AVCodec* codec = avcodec_find_decoder(audioCodecContext_->codec_id);
    if (NULL == codec) {
        //NSLog(@"Not found audio decoder.");
        return false;
    }
    
    if (0 > avcodec_open2(audioCodecContext_, codec, NULL)) {
        //NSLog(@"Could not open audio decoder");
        return false;
    }
    
    bInitialized_ = true;
    
    return true;
}

-(int)decode:(AVPacket*)packet{
    int decodedDataSize_ = -1;
    if (packet && 0 < (packet->size)) {
        if (audioBufferSize_ < FFMAX(packet->size * sizeof(*audioBuffer_), AVCODEC_MAX_AUDIO_FRAME_SIZE)) {
            audioBufferSize_ = FFMAX(packet->size * sizeof(*audioBuffer_), AVCODEC_MAX_AUDIO_FRAME_SIZE);
            audioBuffer_ = av_malloc(audioBufferSize_);
        }
    
        decodedDataSize_ = audioBufferSize_;
        NSInteger n_len = avcodec_decode_audio3(audioCodecContext_, audioBuffer_, &decodedDataSize_, packet);
    
        if (0 > n_len) {
            //NSLog(@"Could not decode audio packet.");
            return -1;
        }
    }
    
    return decodedDataSize_;
}

-(void)dealloc{
    if (NULL != audioCodecContext_) {
        avcodec_close(audioCodecContext_);
    }

    av_free(audioBuffer_);
    
    [super dealloc];
}

@end
*/