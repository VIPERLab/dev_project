//
//  KSAudioQueueRecord.m
//  KwSing
//
//  Created by 永杰 单 on 12-7-25.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSAudioQueueRecord.h"
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioServices.h>

#define SAMPLE_PER_SECOND 44100.0f

void DeriveBufferSize(AudioQueueRef audio_queue, AudioStreamBasicDescription audio_stream_desc, Float64 f_seconds, UInt32* un_out_buf_size){
    static const int s_n_max_buf_size = 0x10000;
    int n_max_pack_size = audio_stream_desc.mBytesPerPacket;
    if (0 == n_max_pack_size) {
        UInt32 n_vbr_max_pack_size = sizeof(n_max_pack_size);
        AudioQueueGetProperty(audio_queue, AUDIO_CONVERT_PROPERTY_MAX_OUTPUT_PACK_SIZE, &n_max_pack_size, &n_vbr_max_pack_size);
    }
    
    Float64 f_num_bytes_for_time = audio_stream_desc.mSampleRate * n_max_pack_size * f_seconds;
    *un_out_buf_size = (UInt32)((f_num_bytes_for_time < s_n_max_buf_size) ? f_num_bytes_for_time : s_n_max_buf_size);
}

static void HandleInputBuffer(void* audio_queue_data, AudioQueueRef audio_queue, AudioQueueBufferRef audio_queue_buf, const AudioTimeStamp* start_time, UInt32 un_num_packs, const AudioStreamPacketDescription* pack_desc){
    RecordState* p_record_state = (RecordState*)audio_queue_data;
    
    if ((0 == un_num_packs) && (0 != p_record_state->audio_format.mBytesPerPacket)) {
        un_num_packs = audio_queue_buf->mAudioDataByteSize / p_record_state->audio_format.mBytesPerPacket;
    }
    
    if (noErr == AudioFileWritePackets(p_record_state->audio_file, NO, audio_queue_buf->mAudioDataByteSize, pack_desc, p_record_state->cur_pack, &un_num_packs, audio_queue_buf->mAudioData)) {
        p_record_state->cur_pack += un_num_packs;
        if (0 == p_record_state->b_recording) {
            return;
        }
        
        AudioQueueEnqueueBuffer(p_record_state->audio_queue, audio_queue_buf, 0, NULL);
    }
}

@implementation KSAudioQueueRecord

- (id) init{
    if (self = [super init]) {
        m_RecordState.b_recording = NO;
    }
    
    return self;
}

- (void) setupAudioFormat:(AudioStreamBasicDescription *)stream_desc{
    memset(stream_desc, 0, sizeof(*stream_desc));
    stream_desc->mSampleRate = SAMPLE_PER_SECOND;
    stream_desc->mFormatID = kAudioFormatLinearPCM;
    stream_desc->mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    stream_desc->mFramesPerPacket = 1;
    stream_desc->mChannelsPerFrame = 2;
    stream_desc->mBytesPerFrame = stream_desc->mBytesPerPacket = stream_desc->mChannelsPerFrame * sizeof(SInt16);
    stream_desc->mBitsPerChannel = 16;
    stream_desc->mReserved = 0;
}

- (BOOL) startRecord:(NSString *)str_file_path{
    [self setupAudioFormat:&m_RecordState.audio_format];
    CFURLRef file_url = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8*)[str_file_path UTF8String], [str_file_path length], NO);
    OSStatus err_start = AudioQueueNewInput(&m_RecordState.audio_format, HandleInputBuffer, &m_RecordState, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &m_RecordState.audio_queue);
    if (err_start) {
        CFRelease(file_url);
        return NO;
    }
    
    err_start = AudioFileCreateWithURL(file_url, kAudioFileWAVEType, &m_RecordState.audio_format, kAudioFileFlags_EraseFile, &m_RecordState.audio_file);
    CFRelease(file_url);
    if (err_start) {
        return NO;
    }
    
    DeriveBufferSize(m_RecordState.audio_queue, m_RecordState.audio_format, 0.5, &m_RecordState.buf_byte_size);
    for (int n_itr = 0; n_itr < NUM_AUDIO_BUFFER; ++n_itr) {
        err_start = AudioQueueAllocateBuffer(m_RecordState.audio_queue, m_RecordState.buf_byte_size, &m_RecordState.audio_buf[n_itr]);
        if (err_start) {
            return NO;
        }
        
        err_start = AudioQueueEnqueueBuffer(m_RecordState.audio_queue, m_RecordState.audio_buf[n_itr], 0, NULL);
        if (err_start) {
            return NO;
        }
    }
    
    UInt32 un_enable_metering = YES;
    err_start = AudioQueueSetProperty(m_RecordState.audio_queue, kAudioQueueProperty_EnableLevelMetering, &un_enable_metering, sizeof(un_enable_metering));
    if (err_start) {
        return NO;
    }
    
    AVAudioSession* audio_session = [AVAudioSession sharedInstance];
    [audio_session setActive:YES error:nil];
    
    UInt32 un_audio_override = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(un_audio_override), &un_audio_override);
    
    un_audio_override = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(un_audio_override), &un_audio_override);
    
    err_start = AudioQueueStart(m_RecordState.audio_queue, NULL);
    if (err_start) {
        return NO;
    }
    
    m_RecordState.cur_pack = 0;
    m_RecordState.b_recording = YES;
    
    return YES;
}

- (float) averagePower{
    AudioQueueLevelMeterState state[1];
    UInt32 un_state_size = sizeof(state);
    OSStatus status_get_power = AudioQueueGetProperty(m_RecordState.audio_queue, kAudioQueueProperty_CurrentLevelMeter, &state, &un_state_size);
    if (status_get_power) {
        return 0.0f;
    }
    
    return state[0].mAveragePower;
}

- (float) peakPower{
    AudioQueueLevelMeterState state[1];
    UInt32 un_state_size = sizeof(state);
    OSStatus status_get_power = AudioQueueGetProperty(m_RecordState.audio_queue, kAudioQueueProperty_CurrentLevelMeter, &state, &un_state_size);
    if (status_get_power) {
        return 0.0f;
    }
    
    return state[0].mPeakPower;
}

- (void) stopRecord{
    AudioQueueFlush(m_RecordState.audio_queue);
    AudioQueueStop(m_RecordState.audio_queue, NO);
    m_RecordState.b_recording = NO;
    
    for (int n_itr = 0; n_itr < NUM_AUDIO_BUFFER; ++n_itr) {
        AudioQueueFreeBuffer(m_RecordState.audio_queue, m_RecordState.audio_buf[n_itr]);
    }
    AudioQueueDispose(m_RecordState.audio_queue, YES);
    AudioFileClose(m_RecordState.audio_file);
}

- (void) pauseRecord{
    if (!m_RecordState.audio_queue) {
        return;
    }
    OSStatus status_pause = AudioQueuePause(m_RecordState.audio_queue);
    if (status_pause) {
        return;
    }
}

- (BOOL) resumeRecord{
    if (!m_RecordState.audio_queue) {
        return NO;
    }
    
    OSStatus status_resume = AudioQueueStart(m_RecordState.audio_queue, NULL);
    if (status_resume) {
        return NO;
    }
    
    return YES;
}

- (float) currentTime{
    AudioTimeStamp time_stamp;
    OSStatus status_get_cur_time = AudioQueueGetCurrentTime(m_RecordState.audio_queue, NULL, &time_stamp, NULL);
    if (status_get_cur_time) {
        return 0.0f;
    }
    
    return time_stamp.mSampleTime / SAMPLE_PER_SECOND;
}

- (BOOL) isRecording{
    return m_RecordState.b_recording;
}

@end
