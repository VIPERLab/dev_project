//
//  AudioQueueStreamPlayer.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CAudioQueueStreamPlayer_h
#define KwSing_CAudioQueueStreamPlayer_h

#include <CoreFoundation/CoreFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <pthread.h>

#include "AutoLock.h"
#include "StreamFile.h"
#include "EAudioStreamState.h"
#include "EAudioStreamErrorCode.h"

typedef void(*AudioPlayerStateHandler) (AudioStreamState new_state, AudioStreamState old_state, void* handler_data);
typedef void(*AudioPlayerErrorHandler) (AudioStreamErrorCode err_code, void* handler_data);

#define kAQNumberBuffers 3
#define kAQDefaultBufSize 4096
#define kAQMaxPacketDescs 512

#define kBufferDurationSeconds 0.5f

#define kAudioStreamBufSize 1024

class CAudioQueueStreamPlayer {
public:
    CAudioQueueStreamPlayer();
    virtual ~CAudioQueueStreamPlayer();
    
public:
    BOOL Initialize();
    BOOL UnInitialize();
    
public:
    void SetEventHandler(AudioPlayerStateHandler state_handler, AudioPlayerErrorHandler err_handler, void* handler_data);
    
public:
    BOOL OpenStreamFile(CStreamFile* p_stream_file, AudioFileTypeID audio_file_type, UInt32 un_bitrate);
    BOOL InitCAQStreamPlayer(CStreamFile* p_stream_file, AudioFileTypeID audio_file_type, UInt32 un_bitrate);
    
    BOOL Play();
    BOOL Pause();
    BOOL ResumePlay();
    BOOL Stop();
    BOOL Seek(float f_time);
    
    Float64 GetSchedule();
    Float64 GetDuration();
    
    Float32 GetVolume()const;
    BOOL SetVolume(Float32 f_volume);
    
    AudioStreamState GetPlayState()const;
    
    BOOL IsOpen()const;
    BOOL IsBufferring()const;
    BOOL IsPlaying()const;
    BOOL IsPaused()const;
    
public:
    UInt32 GetBitrate()const;
    UInt32 GetFormatID()const;
    
    int GetBlockCount()const;
    uint64_t GetBlockTime()const;
    
    BOOL ParseStreamFormat();
    
private:
    BOOL OpenAudioStream(CStreamFile* p_stream_file, AudioFileTypeID audio_file_type);
    BOOL ReopenAudioStream();
    void CloseAudioStream();
    
    BOOL CreateAudioQueue();
    BOOL StartAudioQueue();
    BOOL PauseAudioQueue();
    BOOL StopAudioQueue(BOOL b_immediate);
    void ReleaseAudioQueue();
    
    BOOL CalculateBitRate();
    
    BOOL CalculateBufferSizeForTime(float f_time, UInt32* out_buf, UInt32* out_buf_size);
    BOOL CalculatePacketsSizeForSeekTime(float f_time, SInt64* out_pack_num, SInt64* out_bytes_offset);
    
private:
    void AudioQueueOutputProc(AudioQueueRef in_audio_queue, AudioQueueBufferRef in_buf);
    static void AudioQueueOutputCallback(void* in_user_data, AudioQueueRef in_audio_queue, AudioQueueBufferRef in_buf);
    
    void AudioQueueIsRunningProc(AudioQueueRef in_audio_queue, AudioQueuePropertyID in_id);
    static void AudioQueueIsRunningCallback(void* in_usr_data, AudioQueueRef in_audio_queue, AudioQueuePropertyID in_id);
    
    void AudioStreamPropertyListenerProc(AudioFileStreamID in_audio_file_stream, AudioFileStreamPropertyID in_property_id, UInt32* io_flags);
    static void AudioStreamPropertyListenerCallback(void* in_usr_data, AudioFileStreamID in_audio_file_stream, AudioFileStreamPropertyID in_property_id, UInt32* io_flags);
    
    void AudioStreamPacketsProc(UInt32 in_num_bytes, UInt32 in_num_packs, const void* in_input_data, AudioStreamPacketDescription* in_pack_desc);
    static void AudioStreamPacketsCallback(void* in_usr_data, UInt32 in_num_bytes, UInt32 in_num_packs, const void* in_input_data, AudioStreamPacketDescription* in_pack_desc);
    
private:
    void SetPlayState(AudioStreamState stream_state);
    
    void SetErrCode(AudioStreamErrorCode err_code);
    
    void NotifyStateChange(AudioStreamState new_state, AudioStreamState old_state);
    
    void NotifyError(AudioStreamErrorCode err_code);
    
private:
    BOOL Reset();
    
    BOOL ParseStreamData();
    
    BOOL FillStreamBufferPackets(AudioQueueBufferRef audio_buf, UInt32 un_vbr_pack_count, AudioStreamPacketDescription* p_vbr_pack_desc, UInt32 un_bytes, UInt32 un_packs, const void* p_pack_data, AudioStreamPacketDescription* p_pack_desc, UInt32& un_bytes_offset, UInt32& un_packet_start);
    
    UInt32 FillStreamBuffer();
    
    UInt32 FillStreamBufferFromCache();
    
    BOOL EnqueueStreamBuffer();
    
    int AddEmptyBuffer(AudioQueueBufferRef buffer);
    
    AudioQueueBufferRef GetEmptyBuffer(BOOL b_erase);
    
    BOOL ResetEmptyBuffer();
    
    BOOL IsAllBuffersEmpty()const;
    
private:
    AudioPlayerStateHandler m_StateHandler;
    AudioPlayerErrorHandler m_ErrorHandler;
    void* m_HandlerData;
    
    AudioQueueRef m_AudioQueue;
    
    BOOL m_bPlaying;
    
    CStreamFile* m_pStreamFile;
    
    AudioFileTypeID m_AudioTypeID;
    AudioFileStreamID m_AudioStreamID;
    AudioStreamBasicDescription m_AudioFormat;
    
    AudioQueueBufferRef m_AudioBuffers[kAQNumberBuffers + 1];
    AudioQueueBufferRef m_AudioBuffersEmpty[kAQNumberBuffers];
    UInt32 m_unEmptyBufferCount;
    
    AudioQueueBufferRef m_AudioBuffer;
    UInt32 m_unVbrPacketCount;
    AudioStreamPacketDescription m_VbrPacketDescs[kAQMaxPacketDescs];
    
    AudioQueueBufferRef m_AudioBufferCache;
    UInt32 m_unVbrPacketCountCache;
    AudioStreamPacketDescription m_VbrPacketDescsCache[kAQMaxPacketDescs];
    
    pthread_mutex_t m_BufferMutex;
    
    Float64 m_fSchedule;
    Float64 m_fDuration;
    Float64 m_fSeekTime;
    
    Float32 m_fVolume;
    
    UInt32 m_unDataOffset;
    UInt32 m_unAudioDataSize;
    UInt32 m_unMaxPacketSize;
    BOOL m_bReadyToProducePackets;
    
    UInt32 m_unBitRate;
    Float64 m_fSampleRate;
    Float64 m_fPacketDuration;
    UInt32 m_unNumberOfChannels;
    BOOL m_bIsVbr;
    
    AudioStreamState m_PlayState;
    BOOL m_bFlushEof;
    BOOL m_bBuffering;
    pthread_mutex_t m_BufferringMutex;
    pthread_cond_t m_BufferringCondition;
    
    BOOL m_bSeeking;
    BOOL m_bStoping;
    
    int m_nBlockCount;
    uint64_t m_unBlockTime;
    struct timeval m_TimeVal;
};

#endif
