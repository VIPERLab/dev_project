//
//  AudioQueuePlayer.h
//  AudioQueuePlayer
//
//  Created by 永杰 单 on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef _CAudioQueuePlayer_H
#define _CAudioQueuePlayer_H

#include <AudioToolbox/AudioFile.h>
#include <AudioToolbox/AudioQueue.h>

#ifndef KwSing_AudioEffectType_h
#include "AudioEffectType.h"
#endif

#include <vector>

#define NUM_BUFS 3
#define SEC_BUF_DURATION 0.005

class freeverb;

class CAudioQueuePlayer {
public:
    CAudioQueuePlayer();
    virtual ~CAudioQueuePlayer();
    
    bool InitAudioQueue(CFStringRef str_file_path);
    OSStatus StartPlay();
    OSStatus ResumePlay();
    OSStatus StopPlay();
    OSStatus PausePlay();
    OSStatus Seek(float f_seek_time);
    
    unsigned int GetCurVolume();
    void SetPlayVolume(float f_volume);
    float GetCurrentTime();
    
    void SetEchoType(EAudioEchoEffect echo_effect);
    
    AudioQueueRef Queue()const {return m_AudioQueue;}
    AudioStreamBasicDescription DataFormat()const {return m_DataFormat;}
    Boolean IsRunning()const {return m_unIsRunning ? true : false;}
    Boolean IsInitialized()const {return m_bIsInitialized;}
    CFStringRef GetFilePath()const {return m_strFilePath ? m_strFilePath : CFSTR("");}
    Boolean IsLooping()const {return m_bIsLooping;}
    
    void SetLooping(Boolean b_is_looping){m_bIsLooping = b_is_looping;}
    void CreateQueueForFile(CFStringRef str_file_path);
    void DisposeQueue(Boolean b_dispose_file);
    
private:
    UInt32 GetNumPacksToRead()const {return m_unNumPacksToRead;}
    SInt64 GetCurrentPack()const {return m_snCurPack;}
    AudioFileID GetAudioFIleID()const {return m_AudioFile;}
    void SetCurrentPack(SInt64 sn_pack_index) {m_snCurPack = sn_pack_index;}
    void SetupNewQueue();
    
private:
    AudioQueueRef m_AudioQueue;
    AudioQueueBufferRef m_Buffers[NUM_BUFS];
    AudioFileID m_AudioFile;
    CFStringRef m_strFilePath;
    AudioStreamBasicDescription m_DataFormat;
    Boolean m_bIsInitialized;
    UInt32 m_unNumPacksToRead;
    SInt64 m_snCurPack;
    UInt32 m_unIsRunning;
    Boolean m_bIsDone;
    Boolean m_bIsLooping;
    
    freeverb* m_pVerbProcess;
    
    std::vector<float> m_fVolumeVec;
    
    bool m_bHasEchoEffect;
    RevSettings m_EchoPara;
    
    AudioQueueTimelineRef m_AQTimeLine;
    
    static void IsRunningProc(void* in_usr_data, AudioQueueRef in_audio_queue, AudioQueuePropertyID property_id);
    static void AudioQueueBufferCallback(void* in_usr_data, AudioQueueRef in_audio_queue, AudioQueueBufferRef complete_audio_queue_buf);
    void CalculateBytesForTime(AudioStreamBasicDescription& data_desc, UInt32 un_max_pack_size, Float64 f_seconds, UInt32* un_out_buf_size, UInt32* un_num_packs);
};

#endif
