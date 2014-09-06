//
//  KSOpenAlPlayer.m
//  AACDecoder
//
//  Created by 单 永杰 on 12-11-20.
//  Copyright (c) 2012年 单 永杰. All rights reserved.
//

#import "KSOpenAlPlayer.h"

@implementation KSOpenAlPlayer

@synthesize m_pContext;
@synthesize m_pDevice;
@synthesize m_pBufferStorageArray;
@synthesize m_pSoundDictionary;

-(void)initOpenAL : (int)n_sample_rate channels : (int)n_channels{
    m_nChannels = n_channels;
    m_nSampleRate = n_sample_rate;
    
    m_pDevice = alcOpenDevice(NULL);
    if (m_pDevice) {
        m_pContext = alcCreateContext(m_pDevice, NULL);
        alcMakeContextCurrent(m_pContext);
    }
    
    m_pSoundDictionary = [[NSMutableDictionary alloc] init];
    m_pBufferStorageArray = [[NSMutableArray alloc] init];
    
    alGenSources(1, &m_unSourceID);
    
    alSpeedOfSound(1.0);
    alDopplerVelocity(1.0);
    alDopplerFactor(1.0);
    
    alSourcef(m_unSourceID, AL_PITCH, 1.0f);
    alSourcef(m_unSourceID, AL_GAIN, 1.0f);
    
    alSourcef(m_unSourceID, AL_LOOPING, AL_FALSE);
    alSourcef(m_unSourceID, AL_SOURCE_TYPE, AL_STREAMING);
    
    m_pTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(updateQueueBuffer) userInfo:nil repeats:YES];
}

-(BOOL)updateQueueBuffer{
    ALint un_state_value = 0;
    int n_processed = 0;
    int n_queued = 0;
    
    alGetSourcei(m_unSourceID, AL_SOURCE_STATE, &un_state_value);
    if ((AL_STOPPED == un_state_value) || (AL_PAUSED == un_state_value) || (AL_INITIAL == un_state_value)) {
        [self playSound];
        return NO;
    }
    
    alGetSourcei(m_unSourceID, AL_BUFFERS_PROCESSED, &n_processed);
    alGetSourcei(m_unSourceID, AL_BUFFERS_QUEUED, &n_queued);
    
    while (n_processed--) {
        alSourceUnqueueBuffers(m_unSourceID, 1, &m_unBuff);
        alDeleteBuffers(1, &m_unBuff);
    }
    
    return YES;
}

-(id)init{
    self = [super init];
    return self;
}

-(void)openAudioFromQueue:(short *)buf_data dataSize:(UInt32)n_buf_size{
    NSAutoreleasePool* p_pool = [[NSAutoreleasePool alloc] init];
    NSCondition* ticket_condition = [[NSCondition alloc] init];
    
    [ticket_condition lock];
    ALuint un_buf_id = 0;
    alGenBuffers(1, &un_buf_id);
    
    NSData* temp_data = [NSData dataWithBytes:buf_data length:n_buf_size];
    if (2 == m_nChannels) {
        alBufferData(un_buf_id, AL_FORMAT_STEREO16, (short*)[temp_data bytes], (ALsizei)[temp_data length], m_nSampleRate);
    }else {
        alBufferData(un_buf_id, AL_FORMAT_MONO16, (short*)[temp_data bytes], (ALsizei)[temp_data length], m_nSampleRate);
    }
    alSourceQueueBuffers(m_unSourceID, 1, &un_buf_id);
    
    [self updateQueueBuffer];
    
    ALint n_state_value;
    alGetSourcei(m_unSourceID, AL_SOURCE_STATE, &n_state_value);
    
    [ticket_condition unlock];
    [ticket_condition release];
    ticket_condition = nil;
    
    [p_pool release];
    p_pool = nil;
}

-(void)playSound{
    alSourcePlay(m_unSourceID);
}

-(void)pauseSound{
    alSourceStop(m_unSourceID);
}

-(void)stopSound{
//    [m_pTimer invalidate];
//    m_pTimer = nil;
    alSourceStop(m_unSourceID);
}

-(int)getQueuedBufNumber{
    int n_queued_buf_num = 0;
    alGetSourcei(m_unSourceID, AL_BUFFERS_QUEUED, &n_queued_buf_num);
    int n_proceed_buf_num = 0;
    alGetSourcei(m_unSourceID, AL_BUFFERS_PROCESSED, &n_proceed_buf_num);
    
    return (n_queued_buf_num - n_proceed_buf_num);
}

-(void)cleanUpOpenAL{
    alDeleteSources(1, &m_unSourceID);
    alDeleteBuffers(1, &m_unBuff);
    alcDestroyContext(m_pContext);
    alcCloseDevice(m_pDevice);
}

-(void)playSound:(NSString *)str_sound_key{
    NSNumber* num_val = [m_pSoundDictionary objectForKey:str_sound_key];
    if (nil == num_val) {
        return;
    }
    
    NSUInteger source_id = [num_val unsignedIntValue];
    alSourceStop(source_id);
}

-(void)setVolume : (float)f_volume{
    alSourcef(m_unSourceID, AL_GAIN, f_volume);
}

-(void)dealloc{
    [self cleanUpOpenAL];
    [m_pSoundDictionary release];
    [m_pBufferStorageArray release];
    [super dealloc];
}


@end
