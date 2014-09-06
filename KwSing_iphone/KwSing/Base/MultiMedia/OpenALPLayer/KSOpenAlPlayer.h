//
//  KSOpenAlPlayer.h
//  AACDecoder
//
//  Created by 单 永杰 on 12-11-20.
//  Copyright (c) 2012年 单 永杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface KSOpenAlPlayer : NSObject{
    ALCcontext* m_pContext;
    ALCdevice* m_pDevice;
    ALuint m_unSourceID;
    
    NSMutableDictionary* m_pSoundDictionary;
    NSMutableArray* m_pBufferStorageArray;
    
    ALuint m_unBuff;
    NSTimer* m_pTimer;
    
    int m_nSampleRate;
    int m_nChannels;
}

@property(nonatomic) ALCcontext* m_pContext;
@property(nonatomic) ALCdevice* m_pDevice;
@property(nonatomic, retain)NSMutableDictionary* m_pSoundDictionary;
@property(nonatomic, retain)NSMutableArray* m_pBufferStorageArray;

-(void)initOpenAL : (int)n_sample_rate channels : (int)n_channels;
-(void)openAudioFromQueue:(short*)buf_data dataSize:(UInt32)n_buf_size;
-(void)playSound;
-(void)playSound:(NSString*)str_sound_key;
-(void)pauseSound;
-(void)stopSound;
-(void)setVolume : (float)f_volume;
//-(void)stopSound:(NSString*)str_sound_key;
-(void)cleanUpOpenAL;

-(int)getQueuedBufNumber;
-(BOOL)updateQueueBuffer;

@end
