//
//  KSAudioQueueRecord.h
//  KwSing
//
//  Created by 永杰 单 on 12-7-25.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

#define NUM_AUDIO_BUFFER 3
#define AUDIO_CONVERT_PROPERTY_MAX_OUTPUT_PACK_SIZE 'xops'

typedef struct{
    AudioFileID audio_file;
    AudioStreamBasicDescription audio_format;
    AudioQueueRef audio_queue;
    AudioQueueBufferRef audio_buf[NUM_AUDIO_BUFFER];
    UInt32 buf_byte_size;
    SInt64 cur_pack;
    BOOL b_recording;
}RecordState;

@interface KSAudioQueueRecord : NSObject{
    RecordState m_RecordState;
}

- (BOOL) isRecording;
- (void) setupAudioFormat : (AudioStreamBasicDescription*) stream_desc;
- (float) averagePower;
- (float) peakPower;
- (float) currentTime;
- (BOOL) startRecord : (NSString*) str_file_path;
- (void) pauseRecord;
- (BOOL) resumeRecord;
- (void) stopRecord;

@end
