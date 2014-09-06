//
//  KSAVAudioRecorder.h
//  KwSing
//
//  Created by 永杰 单 on 12-7-18.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>

#ifndef KwSing_EnumRecordStatus_h
#include "EnumRecordStatus.h"
#endif

@interface KSAVAudioRecorder : NSObject <AVAudioRecorderDelegate> {
    AVAudioRecorder* m_AVRecorder;
    AVAudioSession* m_AVSession;
    NSMutableDictionary* m_RecordSettings;
}

@property (retain, nonatomic) AVAudioRecorder* m_AVRecorder;
@property (retain, nonatomic) AVAudioSession* m_AVSession;

- (void) initSettings;
- (void) stopRecord;
- (void) continueRecord;
- (void) pauseRecord;
- (enum ERecorderStatus) startRecord : (NSString*) str_file_path;
- (enum ERecorderStatus) startRecord : (NSString*) str_file_path withDuration : (NSTimeInterval) time_interval;
- (int) currentTime;
- (BOOL) isRecording;
@end
