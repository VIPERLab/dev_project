//
//  AACDecoder.m
//  AACDecoder
//
//  Created by 单 永杰 on 12-11-7.
//  Copyright (c) 2012年 单 永杰. All rights reserved.
//
/*
#import "AACDecoder.h"

@implementation AACDecoder

@synthesize audioCodecContext_, audioBuffer_;

//unsigned long GetRawDataLength(FILE* p_file){
//    fseek(p_file, 0, SEEK_END);
//    unsigned long n_file_len = ftell(p_file);
//    fseek(p_file, 0, SEEK_SET);
//    
//    return n_file_len;
//}

- (id)init{
    if (self = [super init]) {
        av_register_all();
        
        audioStreamIndex_ = -1;
        audioBufferSize_ = AVCODEC_MAX_AUDIO_FRAME_SIZE;
        audioBuffer_ = av_malloc(audioBufferSize_);
        av_init_packet(&packet_);
        inBuffer_ = NO;
    }
    
    return self;
}

- (void)dealloc{
    if (NULL != audioCodecContext_) {
        avcodec_close(audioCodecContext_);
    }
    if (NULL != inputFormatContext_) {
        avformat_close_input(&inputFormatContext_);
    }
    av_free_packet(&packet_);
    av_free(audioBuffer_);
    
    [super dealloc];
}

- (NSInteger) loadFile:(NSString *)filePath{
    
//    FILE* p_input_file = fopen([filePath UTF8String], "rb");
//    m_unFileSize = GetRawDataLength(p_input_file);
//    fclose(p_input_file);
    
    int n_ret = avformat_open_input(&inputFormatContext_, [filePath UTF8String], NULL, NULL);
    
    if (0 != n_ret) {
        char str_error[255];
        memset(str_error, 0, 255);
        av_strerror(n_ret, str_error, 255);
        //NSLog(@"error code is %s", str_error);
        
        return -1;
    }
    
//    if (0 != avformat_open_input(&inputFormatContext_, [filePath UTF8String], NULL, NULL)) {
//        NSLog(@"Could not load input file.");
//        return -1;
//    }
    
    if (0 > avformat_find_stream_info(inputFormatContext_, NULL)) {
        //NSLog(@"The file format is not supported.");
        return -2;
    }
    
    for (NSInteger n_index = 0; n_index < inputFormatContext_->nb_streams; n_index++) {
        if (AVMEDIA_TYPE_AUDIO == inputFormatContext_->streams[n_index]->codec->codec_type) {
            audioStreamIndex_ = n_index;
            break;
        }
    }
    
    if (-1 == audioStreamIndex_) {
        //NSLog(@"Not found audio stream.");
        return -3;
    }else {
        audioStream_ = inputFormatContext_->streams[audioStreamIndex_];
        audioCodecContext_ = audioStream_->codec;
        //NSLog(@"%d___%d", audioCodecContext_->sample_rate, audioCodecContext_->channels);
        
        AVCodec* codec = avcodec_find_decoder(audioCodecContext_->codec_id);
        if (NULL == codec) {
            //NSLog(@"Not found audio decoder.");
            return -4;
        }
        
        if (0 > avcodec_open2(audioCodecContext_, codec, NULL)) {
            //NSLog(@"Could not open audio decoder");
            return -5;
        }
    }
    
    inputFilePath_ = filePath;
    
    return 0;
}

- (NSTimeInterval) duration{
    return (NULL == inputFormatContext_) ? 0.0f : ((NSTimeInterval)inputFormatContext_->duration / AV_TIME_BASE);
}

- (void)seekTime:(NSTimeInterval)seconds{
    inBuffer_ = NO;
    av_free_packet(&packet_);
    currentPacket_ = packet_;
    
    av_seek_frame(inputFormatContext_, -1, seconds * AV_TIME_BASE, 0);
}

- (AVPacket*)readPacket{
    if ((0 < currentPacket_.size) || inBuffer_) {
        return &currentPacket_;
    }
    
    av_free_packet(&packet_);
    for (; ; ) {
        NSInteger n_ret = av_read_frame(inputFormatContext_, &packet_);
        if (AVERROR(EAGAIN) == n_ret) {
            continue;
        }else if (0 > n_ret){
            return NULL;
        }
        
        if (packet_.stream_index != audioStreamIndex_) {
            av_free_packet(&packet_);
            continue;
        }
        
        if (AV_NOPTS_VALUE != packet_.dts) {
            packet_.dts += av_rescale_q(0, AV_TIME_BASE_Q, audioStream_->time_base);
        }
        
        if (AV_NOPTS_VALUE != packet_.pts) {
            packet_.pts += av_rescale_q(0, AV_TIME_BASE_Q, audioStream_->time_base);
        }
        
        break;
    }
    
    currentPacket_ = packet_;
    
    return &currentPacket_;
}

- (NSInteger) decodeAAC{
    if (inBuffer_) {
        return decodedDataSize_;
    }
    
    decodedDataSize_ = -1;
    AVPacket* packet = [self readPacket];
    while (packet && (0 < packet->size)) {
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
        
        packet->data += n_len;
        packet->size -= n_len;
        
        if (0 >= decodedDataSize_) {
            //NSLog(@"Decoding is completed.");
            packet = NULL;
            return 0;
        }
        
        inBuffer_ = YES;
        break;
    }
    
    return decodedDataSize_;
}

- (void)nextPacket{
    inBuffer_ = NO;
}

- (int) totalDecodedSize{
    if (nil != inputFormatContext_) {
        return ((NSTimeInterval)inputFormatContext_->duration / AV_TIME_BASE) * 44100 * 4;
    }else {
        return 0;
    }
}

@end
*/