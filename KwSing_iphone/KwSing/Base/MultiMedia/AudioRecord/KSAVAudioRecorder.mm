//
//  KSAVAudioRecorder.m
//  KwSing
//
//  Created by 永杰 单 on 12-7-18.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

//*********************question to be dealed: release m_AVRecorder*********************//

#import "KSAVAudioRecorder.h"

@implementation KSAVAudioRecorder

@synthesize m_AVRecorder;
@synthesize m_AVSession;

//*********************functions to be implemented***************************//

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
}

- (void) audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
}

- (void) audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
}

- (void) audioRecorderEndInterruption:(AVAudioRecorder *)recorder{
}

- (void) audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags{
}

//***************************************************************************//

- (id) init{
    self = [super init];
    m_AVRecorder = [[AVAudioRecorder alloc]init];
    if (!m_AVRecorder) {
        return nil;
    }
    [self initSettings];
    return self;
}

- (void) dealloc{
    [m_AVRecorder release];
    [super dealloc];
}

- (void) stopRecord{
    if (m_AVRecorder) {
        [m_AVRecorder stop];
    }
}

- (void) continueRecord{
    if (m_AVRecorder) {
        [m_AVRecorder record];
    }
}

- (void) pauseRecord{
    if (m_AVRecorder) {
        [m_AVRecorder pause];
    }
}

- (enum ERecorderStatus) startRecord : (NSString*) str_file_path{
    m_AVSession = [AVAudioSession sharedInstance];
    [m_AVSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [m_AVSession setActive:YES error:nil];
    if (!m_AVSession.inputIsAvailable) {
        return MICROPHONE_ERR;
    }
    
    NSURL* file_url = [NSURL fileURLWithPath:str_file_path];
    m_AVRecorder = [m_AVRecorder initWithURL:file_url settings:m_RecordSettings error:nil];
    
    if (!m_AVRecorder) {
        return RECORDER_ALLOC_ERR;
    }
    
    self.m_AVRecorder.delegate = self;
    if (![m_AVRecorder prepareToRecord]) {
        return RECORDER_PREPARE_ERR;
    }
    
    if (![m_AVRecorder record]) {
        return RECORDER_RECORD_ERR;
    }
    
    return RECORDER_SUCESS;
}

- (enum ERecorderStatus) startRecord : (NSString*) str_file_path withDuration : (NSTimeInterval) time_interval{
    m_AVSession = [AVAudioSession sharedInstance];
    [m_AVSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [m_AVSession setActive:YES error:nil];
    if (!m_AVSession.inputIsAvailable) {
        return MICROPHONE_ERR;
    }
    
    NSURL* file_url = [NSURL fileURLWithPath:str_file_path];
    m_AVRecorder = [[AVAudioRecorder alloc] initWithURL:file_url settings:m_RecordSettings error:nil];
    
    if (!m_AVRecorder) {
        return RECORDER_ALLOC_ERR;
    }
    
    self.m_AVRecorder.delegate = self;
    if (![m_AVRecorder prepareToRecord]) {
        return RECORDER_PREPARE_ERR;
    }
    
    if (![m_AVRecorder recordForDuration:time_interval]) {
        return RECORDER_RECORD_ERR;
    }
    
    return RECORDER_SUCESS;

}

- (BOOL) isRecording{
    if (m_AVRecorder) {
        return  [m_AVRecorder isRecording];
    }else {
        return NO;
    }
}

- (int) currentTime{
    if (m_AVRecorder) {
        return m_AVRecorder.currentTime;
    }else {
        return 0;
    }
}

- (void) initSettings{
    m_RecordSettings = [NSMutableDictionary dictionary];
    [m_RecordSettings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [m_RecordSettings setValue:[NSNumber numberWithInt:44100] forKey:AVSampleRateKey];
    [m_RecordSettings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    [m_RecordSettings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [m_RecordSettings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [m_RecordSettings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey]; 
}
@end
