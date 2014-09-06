//
//  AudioQueueStreamPlayer.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "AudioQueueStreamPlayer.h"
#include "MessageManager.h"
#include "IAudioStateObserver.h"
#include <sys/time.h>
#include <algorithm>


CAudioQueueStreamPlayer::CAudioQueueStreamPlayer(){
    m_nBlockCount = 0;
    m_unBlockTime = 0;
    Initialize();
}

CAudioQueueStreamPlayer::~CAudioQueueStreamPlayer(){
    UnInitialize();
}

BOOL CAudioQueueStreamPlayer::Initialize(){
    m_StateHandler = NULL;
    m_ErrorHandler = NULL;
    m_HandlerData = NULL;
    
    pthread_mutex_init(&m_BufferMutex, NULL);
    pthread_mutex_init(&m_BufferringMutex, NULL);
    pthread_cond_init(&m_BufferringCondition, NULL);
    
    m_fVolume = 1.0;
    
    Reset();
    
    return TRUE;
}

BOOL CAudioQueueStreamPlayer::UnInitialize(){
    Stop();
    
    pthread_mutex_destroy(&m_BufferMutex);
    pthread_mutex_destroy(&m_BufferringMutex);
    pthread_cond_destroy(&m_BufferringCondition);
    
    return TRUE;
}

void CAudioQueueStreamPlayer::SetEventHandler(AudioPlayerStateHandler state_handler, AudioPlayerErrorHandler err_handler, void *handler_data){
    m_ErrorHandler = err_handler;
    m_StateHandler = state_handler;
    m_HandlerData = handler_data;
}

BOOL CAudioQueueStreamPlayer::OpenStreamFile(CStreamFile *p_stream_file, AudioFileTypeID audio_file_type, UInt32 un_bitrate){
    if (IsPlaying() || IsPaused()) {
        Stop();
    }
    
    CloseAudioStream();
    
    if (!OpenAudioStream(p_stream_file, audio_file_type)) {
        return FALSE;
    }
    
    m_nBlockCount = 0;
    m_unBlockTime = 0;
    
    return ParseStreamFormat();
}

BOOL CAudioQueueStreamPlayer::InitCAQStreamPlayer(CStreamFile *p_stream_file, AudioFileTypeID audio_file_type, UInt32 un_bitrate){
    if (IsPlaying() || IsPaused()) {
        Stop();
    }
    
    CloseAudioStream();
    
    if (!OpenAudioStream(p_stream_file, audio_file_type)) {
        return FALSE;
    }
    
    m_nBlockCount = 0;
    m_unBlockTime = 0;
    
    return YES;
}

BOOL CAudioQueueStreamPlayer::Play(){
    if (!m_pStreamFile || !m_pStreamFile->IsOpen()) {
        return FALSE;
    }
    
    if (!m_AudioQueue && !CreateAudioQueue()) {
        SetPlayState(STATE_FAILED);
        return FALSE;
    }
    
    if (m_bBuffering) {
        struct timeval time_val;
        gettimeofday(&time_val, NULL);
        uint64_t time_elapsed = 1000 * (time_val.tv_sec - m_TimeVal.tv_sec);
        m_unBlockTime += time_elapsed / 1000;
    }
    
    pthread_mutex_lock(&m_BufferMutex);
    assert(NULL != m_AudioQueue);
    assert(NULL != m_AudioBuffer);
    
    while (NULL != (m_AudioBuffer = GetEmptyBuffer(FALSE))) {
        UInt32 un_size = FillStreamBuffer();
        if (0 == un_size) {
            m_AudioBuffer = NULL;
            break;
        }
        
        if (!EnqueueStreamBuffer()) {
            ResetEmptyBuffer();
            pthread_mutex_unlock(&m_BufferMutex);
            SetPlayState(STATE_FAILED);
            
            return FALSE;
        }
        
        GetEmptyBuffer(TRUE);
    }
    
    pthread_mutex_unlock(&m_BufferMutex);
    
    if (IsAllBuffersEmpty()) {
        if (IsBufferring() && m_bBuffering) {
            SetPlayState(STATE_BUFFERING);
        }else {
            Stop();
        }
        
        return TRUE;
    }
    
    m_bBuffering = FALSE;
    
    return StartAudioQueue();
}

BOOL CAudioQueueStreamPlayer::Pause(){
    if (!PauseAudioQueue()) {
        return FALSE;
    }
    
    SetPlayState(STATE_PAUSED);
    
    return TRUE;
}

BOOL CAudioQueueStreamPlayer::ResumePlay(){
    if ((NULL == m_AudioQueue)) {
        SetPlayState(STATE_FAILED);
        return NO;
    }

    if(noErr == AudioQueueStart(m_AudioQueue, NULL)){
        SetPlayState(STATE_PLAYING);
        return YES;
    }else {
        SetPlayState(STATE_FAILED);
        return NO;
    }
}

BOOL CAudioQueueStreamPlayer::Stop(){
    if (m_bPlaying) {
        m_bStoping = TRUE;
        StopAudioQueue(TRUE);
        
        while (m_bPlaying) {
            usleep(10 * 1000);
        }
        
        m_bStoping = FALSE;
    }
    
    BOOL b_is_buffering_fail = (m_pStreamFile && m_pStreamFile->IsOpen()) ? (m_pStreamFile->IsEndOfFile() && m_pStreamFile->IsBufferingFailed()) : FALSE;
    
    CloseAudioStream();
    ReleaseAudioQueue();
    
    if (IsBufferring() || IsPlaying() || IsPaused()) {
        if (b_is_buffering_fail) {
            SetPlayState(STATE_BUFFERING_FAILED);
        }else {
            SetPlayState(STATE_STOPPED);
        }
    }
    
    Reset();
    
    return TRUE;
}

BOOL CAudioQueueStreamPlayer::Seek(float f_time){
    if (!m_AudioQueue) {
        return FALSE;
    }
    
    if (!m_fPacketDuration) {
        return FALSE;
    }
    
    SInt64 sn_seek_bytes_offset = 0;
    SInt64 sn_seek_num_packets = 0;
    
    if (!CalculatePacketsSizeForSeekTime(f_time, &sn_seek_num_packets, &sn_seek_bytes_offset)) {
        SetErrCode(E_AUDIO_FILE_SEEK_ERR);
        return FALSE;
    }
    
    SInt64 sn_seek_file_offset = sn_seek_bytes_offset + m_unDataOffset;
    
    pthread_mutex_lock(&m_BufferringMutex);
    if (sn_seek_file_offset > m_pStreamFile->GetAvailableDataSize()) {
        pthread_mutex_unlock(&m_BufferringMutex);
        return FALSE;
    }
    
    pthread_mutex_unlock(&m_BufferringMutex);
    
    m_bSeeking = TRUE;
    
    if (!StopAudioQueue(TRUE)) {
        SetErrCode(E_AUDIO_QUEUE_STOP_ERR);
        return FALSE;
    }
    
    while (m_bPlaying) {
        usleep(10 * 1000);
    }
    
    pthread_mutex_lock(&m_BufferringMutex);
    ResetEmptyBuffer();
    m_pStreamFile->Seek(sn_seek_file_offset, SEEK_SET);
    m_fSeekTime = sn_seek_bytes_offset * 8.0 / m_unBitRate;
    m_bSeeking = FALSE;
    m_fSchedule = m_fSeekTime;
    pthread_mutex_unlock(&m_BufferringMutex);
    
    if (IsPlaying() || IsBufferring()) {
        return Play();
    }
    
    return TRUE;
}

Float64 CAudioQueueStreamPlayer::GetSchedule(){
    if (!m_bReadyToProducePackets || (0.f == m_fSampleRate) || !m_AudioQueue) {
        return 0.f;
    }
    
    if (!IsPlaying() && !IsBufferring()) {
        return m_fSchedule;
    }
    
    AudioTimeStamp queue_time;
    Boolean b_discontinue;
    OSStatus err = AudioQueueGetCurrentTime(m_AudioQueue, NULL, &queue_time, &b_discontinue);
    if (noErr != err) {
        return m_fSchedule;
    }
    
    Float64 f_schedule = m_fSeekTime + queue_time.mSampleTime / m_fSampleRate;
    m_fSchedule = f_schedule > 0.f ? f_schedule : 0.f;
    
    return m_fSchedule;
}

Float64 CAudioQueueStreamPlayer::GetDuration(){
    if (0.f == m_fDuration) {
        if (!m_bReadyToProducePackets || (0 == m_unBitRate)) {
            return 0.f;
        }
        
        m_fDuration = (Float64)m_unAudioDataSize * 8 / m_unBitRate;
    }
    
    return m_fDuration;
}

Float32 CAudioQueueStreamPlayer::GetVolume()const{
    return m_fVolume;
}

BOOL CAudioQueueStreamPlayer::SetVolume(Float32 f_volume){
    if (0 > f_volume) {
        f_volume = 0;
    }else if (1 < f_volume) {
        f_volume = 1.0;
    }
    
    if (m_AudioQueue) {
        AudioQueueSetParameter(m_AudioQueue, kAudioQueueParam_Volume, f_volume);
    }
    
    m_fVolume = f_volume;
    
    return TRUE;
}

AudioStreamState CAudioQueueStreamPlayer::GetPlayState()const{
    return m_PlayState;
}

BOOL CAudioQueueStreamPlayer::IsOpen()const{
    return (NULL != m_pStreamFile);
}

BOOL CAudioQueueStreamPlayer::IsBufferring()const{
    if (m_pStreamFile) {
        return m_pStreamFile->IsBuffering();
    }
    
    return (STATE_BUFFERING == m_PlayState);
}

BOOL CAudioQueueStreamPlayer::IsPaused()const{
    return (STATE_PAUSED == m_PlayState);
}

BOOL CAudioQueueStreamPlayer::IsPlaying()const{
    return (STATE_PLAYING == m_PlayState);
}

UInt32 CAudioQueueStreamPlayer::GetBitrate()const{
    return m_unBitRate;
}

UInt32 CAudioQueueStreamPlayer::GetFormatID()const{
    return m_AudioFormat.mFormatID;
}

int CAudioQueueStreamPlayer::GetBlockCount()const{
    return m_nBlockCount;
}

uint64_t CAudioQueueStreamPlayer::GetBlockTime()const{
    return m_unBlockTime;
}

BOOL CAudioQueueStreamPlayer::OpenAudioStream(CStreamFile *p_stream_file, AudioFileTypeID audio_file_type){
    assert(!m_AudioStreamID);
    assert(NULL == m_pStreamFile);
    
    if (!p_stream_file || !p_stream_file->IsOpen()) {
        return FALSE;
    }
    
    m_pStreamFile = p_stream_file;
    OSStatus err = AudioFileStreamOpen(this, AudioStreamPropertyListenerCallback, AudioStreamPacketsCallback, audio_file_type, &m_AudioStreamID);
    if (noErr != err) {
        SetErrCode(E_AUDIO_STREAM_OPEN_ERR);
        return FALSE;
    }
    
    return TRUE;
}

void CAudioQueueStreamPlayer::CloseAudioStream(){
    pthread_mutex_lock(&m_BufferringMutex);
    if (m_AudioStreamID) {
        AudioFileStreamClose(m_AudioStreamID);
        m_AudioStreamID = NULL;
    }
    
    m_pStreamFile = NULL;
    memset(&m_AudioFormat, 0, sizeof(m_AudioFormat));
    m_unAudioDataSize = 0;
    m_bReadyToProducePackets = FALSE;
    m_bBuffering = FALSE;
    pthread_mutex_unlock(&m_BufferringMutex);
}

BOOL CAudioQueueStreamPlayer::CreateAudioQueue(){
    m_fSampleRate = m_AudioFormat.mSampleRate;
    m_fPacketDuration = m_AudioFormat.mFramesPerPacket / m_fSampleRate;
    m_unNumberOfChannels = m_AudioFormat.mChannelsPerFrame;
    
    OSStatus err = AudioQueueNewOutput(&m_AudioFormat, CAudioQueueStreamPlayer::AudioQueueOutputCallback, this, NULL, NULL, 0, &m_AudioQueue);
    if (noErr != err) {
        SetErrCode(E_AUDIO_QUEUE_CREATE_ERR);
        return FALSE;
    }
    
    err = AudioQueueAddPropertyListener(m_AudioQueue, kAudioQueueProperty_IsRunning, CAudioQueueStreamPlayer::AudioQueueIsRunningCallback, this);
    if (noErr != err) {
        ReleaseAudioQueue();
        SetErrCode(E_AUDIO_QUEUE_ADD_LISTENER_ERR);
        return FALSE;
    }
    
    UInt32 un_packet_buffer_size = 0;
    UInt32 un_buffer_size = 0;
    if (this->CalculateBufferSizeForTime(kBufferDurationSeconds, NULL, &un_buffer_size)) {
        un_packet_buffer_size = un_buffer_size;
    }else {
        un_packet_buffer_size = kAQDefaultBufSize;
    }
    
    for (unsigned int un_itr = 0; un_itr < kAQNumberBuffers + 1; ++un_itr) {
        err = AudioQueueAllocateBuffer(m_AudioQueue, un_packet_buffer_size, &m_AudioBuffers[un_itr]);
        if (noErr != err) {
            ReleaseAudioQueue();
            SetErrCode(E_AUDIO_QUEUE_BUFFER_ALLOC_ERR);
            return FALSE;
        }
    }
    
    ResetEmptyBuffer();
    
    UInt32 un_cookie_size = 0;
    Boolean b_writable;
    err = AudioFileStreamGetPropertyInfo(m_AudioStreamID, kAudioFileStreamProperty_MagicCookieData, &un_cookie_size, &b_writable);
    if (noErr == err) {
        if (void* cookie_data = malloc(un_cookie_size)) {
            err = AudioFileStreamGetProperty(m_AudioStreamID, kAudioFileStreamProperty_MagicCookieData, &un_cookie_size, cookie_data);
            if (noErr == err) {
                AudioQueueSetProperty(m_AudioQueue, kAudioQueueProperty_MagicCookie
                                            , cookie_data, un_cookie_size);
            }
            free(cookie_data);
        }
    }
    
    AudioQueueSetParameter(m_AudioQueue, kAudioQueueParam_Volume, m_fVolume);
    
    return TRUE;
}

BOOL CAudioQueueStreamPlayer::StartAudioQueue(){
    if (!m_AudioQueue) {
        return FALSE;
    }
    
    int n_retry(3);
    while (true) {
        OSStatus err;
        UInt32 un_codec = kAudioQueueHardwareCodecPolicy_PreferHardware;
        AudioQueueSetProperty(m_AudioQueue, kAudioQueueProperty_HardwareCodecPolicy, &un_codec, sizeof(un_codec));
        
        err = AudioQueueStart(m_AudioQueue, NULL);
        if (noErr == err) {
            break;
        }
        
        if (--n_retry > 0) {
            usleep(10 * 1000);
            continue;
        }
        
        SetErrCode(E_AUDIO_QUEUE_START_ERR);
        return FALSE;
    }
    
    SetPlayState(STATE_PLAYING);
    
    return TRUE;
}

BOOL CAudioQueueStreamPlayer::PauseAudioQueue(){
    if (!m_AudioQueue) {
        return FALSE;
    }
    
    OSStatus err = AudioQueuePause(m_AudioQueue);
    if (noErr != err) {
        SetErrCode(E_AUDIO_QUEUE_PAUSE_ERR);
        return FALSE;
    }
    
    SetPlayState(STATE_PAUSED);
    
    return TRUE;
}

BOOL CAudioQueueStreamPlayer::StopAudioQueue(BOOL b_immediate){
    if (!m_AudioQueue) {
        return FALSE;
    }
    
    AudioQueuePause(m_AudioQueue);
    
    OSStatus err = AudioQueueStop(m_AudioQueue, b_immediate);
    if (noErr != err) {
        SetErrCode(E_AUDIO_QUEUE_STOP_ERR);
    }
    
    return !err;
}

void CAudioQueueStreamPlayer::ReleaseAudioQueue(){
    if (m_AudioQueue) {
        AudioQueueDispose(m_AudioQueue, TRUE);
        m_AudioQueue = NULL;
    }
    
    memset(m_AudioBuffers, 0, sizeof(m_AudioBuffers));
    memset(m_AudioBuffersEmpty, 0, sizeof(m_AudioBuffersEmpty));
    m_unVbrPacketCount = 0;
    m_unVbrPacketCountCache = 0;
}

BOOL CAudioQueueStreamPlayer::CalculateBitRate(){
    if (!m_AudioStreamID) {
        return FALSE;
    }
    
    if (0 != m_unBitRate) {
        return TRUE;
    }
    
    UInt32 un_bit_rate = 0;
    UInt32 un_bit_rate_size = sizeof(un_bit_rate);
    OSStatus err = AudioFileStreamGetProperty(m_AudioStreamID, kAudioFileStreamProperty_BitRate, &un_bit_rate_size, &un_bit_rate);
    if (noErr == err) {
        m_unBitRate = un_bit_rate;
        if (m_unBitRate % 1000) {
            assert(1000 > m_unBitRate);
            m_unBitRate *= 1000;
        }
    }else {
        un_bit_rate = 8 * m_AudioFormat.mSampleRate * m_AudioFormat.mBytesPerPacket * m_AudioFormat.mFramesPerPacket;
        if (0 != un_bit_rate) {
            m_unBitRate = un_bit_rate;
        }else {
            return FALSE;
        }
    }
    
    return TRUE;
}

BOOL CAudioQueueStreamPlayer::CalculateBufferSizeForTime(float f_time, UInt32 *out_buf, UInt32 *out_buf_size){
    CalculateBitRate();
    if (0 == m_unBitRate) {
        return FALSE;
    }
    
    if (out_buf) {
        *out_buf = ceil(f_time / m_fPacketDuration);
    }
    
    if (out_buf_size) {
        *out_buf_size = m_unBitRate / 8 * f_time;
    }
    
    return TRUE;
}

BOOL CAudioQueueStreamPlayer::CalculatePacketsSizeForSeekTime(float f_time, SInt64 *out_pack_num, SInt64 *out_bytes_offset){
    UInt32 io_flags = 0;
    SInt64 sn_seek_bytes_offset = 0;
    SInt64 sn_seek_packets_num = (SInt64)floor(f_time / m_fPacketDuration);
    
    OSStatus err = AudioFileStreamSeek(m_AudioStreamID, sn_seek_packets_num, &sn_seek_bytes_offset, &io_flags);
    if (noErr != err) {
        return FALSE;
    }
    
    if (out_pack_num) {
        *out_pack_num = sn_seek_packets_num;
    }
    if (out_bytes_offset) {
        *out_bytes_offset = sn_seek_bytes_offset;
    }
    
    return TRUE;
}

void CAudioQueueStreamPlayer::AudioQueueOutputProc(AudioQueueRef in_audio_queue, AudioQueueBufferRef in_buf){
    GetSchedule();
    pthread_mutex_lock(&m_BufferMutex);
    if (m_bSeeking || m_bStoping) {
        AddEmptyBuffer(in_buf);
        pthread_mutex_unlock(&m_BufferMutex);
        return;
    }
    
    m_AudioBuffer = in_buf;
    UInt32 un_size = FillStreamBuffer();
    if (0 == un_size || !EnqueueStreamBuffer()) {
        AddEmptyBuffer(in_buf);
        m_AudioBuffer = NULL;
    }
    
    m_AudioBuffer = NULL;
    pthread_mutex_unlock(&m_BufferMutex);
    
    if (m_bBuffering) {
        PauseAudioQueue();
        SetPlayState(STATE_PAUSED);
        ++m_nBlockCount;
        gettimeofday(&m_TimeVal, NULL);
    }
    
    if (IsAllBuffersEmpty()) {
        if (m_bBuffering) {
            PauseAudioQueue();
            SetPlayState(STATE_BUFFERING);
            ++m_nBlockCount;
            gettimeofday(&m_TimeVal, NULL);
        }else if (m_bSeeking) {
            
        }else {
            StopAudioQueue(TRUE);
            m_bPlaying = FALSE;
            Stop();
        }
    }
}

void CAudioQueueStreamPlayer::AudioQueueOutputCallback(void *in_user_data, AudioQueueRef in_audio_queue, AudioQueueBufferRef in_buf){
    CAudioQueueStreamPlayer* p_this = (CAudioQueueStreamPlayer*)in_user_data;
    p_this->AudioQueueOutputProc(in_audio_queue, in_buf);
}

void CAudioQueueStreamPlayer::AudioQueueIsRunningProc(AudioQueueRef in_audio_queue, AudioQueuePropertyID in_id){
    if (kAudioQueueProperty_IsRunning != in_id) {
        return;
    }
    
    assert(in_audio_queue == m_AudioQueue);
    
    UInt32 un_playing = 0;
    UInt32 un_playing_size = sizeof(un_playing);
    AudioQueueGetProperty(in_audio_queue, kAudioQueueProperty_IsRunning, &un_playing, &un_playing_size);
    m_bPlaying = (BOOL)(0 != un_playing);
}

void CAudioQueueStreamPlayer::AudioQueueIsRunningCallback(void *in_usr_data, AudioQueueRef in_audio_queue, AudioQueuePropertyID in_id){
    CAudioQueueStreamPlayer* p_this = (CAudioQueueStreamPlayer*)in_usr_data;
    p_this->AudioQueueIsRunningProc(in_audio_queue, in_id);
}

void CAudioQueueStreamPlayer::AudioStreamPropertyListenerProc(AudioFileStreamID in_audio_file_stream, AudioFileStreamPropertyID in_property_id, UInt32 *io_flags){
    assert(in_audio_file_stream == m_AudioStreamID);
    
    OSStatus err = noErr;
    switch (in_property_id) {
        case kAudioFileStreamProperty_ReadyToProducePackets:
        {
            m_bReadyToProducePackets = TRUE;
            break;
        }
        case kAudioFileStreamProperty_DataOffset:
        {
            UInt64 un_offset = 0;
            UInt32 un_offset_size = sizeof(un_offset);
            err = AudioFileStreamGetProperty(in_audio_file_stream, kAudioFileStreamProperty_DataOffset, &un_offset_size, &un_offset);
            if (err) {
                SetErrCode(E_AUDIO_STREAM_GET_PROPERTY_ERR);
                return;
            }
            m_unDataOffset = un_offset;
            m_unAudioDataSize = m_pStreamFile->GetFileSize() - m_unDataOffset;
            break;
        }
        case kAudioFileStreamProperty_AudioDataByteCount:
        {
            UInt64 un_data_byte_count = 0;
            UInt32 un_data_byte_count_size = sizeof(un_data_byte_count);
            err = AudioFileStreamGetProperty(in_audio_file_stream, kAudioFileStreamProperty_AudioDataByteCount, &un_data_byte_count_size, &un_data_byte_count);
            if (err) {
                SetErrCode(E_AUDIO_STREAM_GET_PROPERTY_ERR);
                return;
            }
            
            if (m_pStreamFile->GetFileSize() - m_unDataOffset > un_data_byte_count) {
                m_unAudioDataSize = un_data_byte_count;
            }
            break;
        }
        case kAudioFileStreamProperty_DataFormat:
        {
            if (0 == m_AudioFormat.mSampleRate) {
                UInt32 un_fromat_size = sizeof(m_AudioFormat);
                err = AudioFileStreamGetProperty(in_audio_file_stream, kAudioFileStreamProperty_DataFormat, &un_fromat_size, &m_AudioFormat);
                if (err) {
                    SetErrCode(E_AUDIO_STREAM_GET_PROPERTY_ERR);
                    return;
                }
                m_fSampleRate = m_AudioFormat.mSampleRate;
            }
            break;
        }
        case kAudioFileStreamProperty_FileFormat:
        {
            UInt32 un_type;
            UInt32 un_type_size = sizeof(un_type);
            err = AudioFileStreamGetProperty(in_audio_file_stream, kAudioFileStreamProperty_FileFormat, &un_type_size, &un_type);
            if (err) {
                SetErrCode(E_AUDIO_STREAM_GET_PROPERTY_ERR);
                return;
            }
            m_AudioTypeID = un_type;
            break;
        }
        case kAudioFileStreamProperty_BitRate:
        {
            UInt32 un_bit_rate;
            UInt32 un_bit_rate_size = sizeof(un_bit_rate);
            err = AudioFileStreamGetProperty(in_audio_file_stream, kAudioFileStreamProperty_BitRate, &un_bit_rate_size, &un_bit_rate);
            if (err) {
                SetErrCode(E_AUDIO_STREAM_GET_PROPERTY_ERR);
                return;
            }
            
            m_unBitRate = un_bit_rate;
            if (m_unBitRate % 1000) {
                assert(1000 > m_unBitRate);
                m_unBitRate *= 1000;
            }
            break;
        }
        case kAudioFileStreamProperty_FormatList:
        {
            Boolean b_out_writable;
            UInt32 un_format_list_size;
            err = AudioFileStreamGetPropertyInfo(in_audio_file_stream, kAudioFileStreamProperty_FormatList, &un_format_list_size, &b_out_writable);
            if (err) {
                SetErrCode(E_AUDIO_STREAM_GET_PROPERTY_ERR);
                return;
            }
            
            AudioFormatListItem* format_list = (AudioFormatListItem*) malloc(un_format_list_size);
            err = AudioFileStreamGetProperty(in_audio_file_stream, kAudioFileStreamProperty_FormatList, &un_format_list_size, format_list);
            if (err) {
                free(format_list);
                SetErrCode(E_AUDIO_STREAM_GET_PROPERTY_ERR);
                return;
            }
            
            for (int n_itr = 0; n_itr * sizeof(AudioFormatListItem) < un_format_list_size; n_itr += sizeof(AudioFormatListItem)) {
                AudioStreamBasicDescription basic_desc = format_list[n_itr].mASBD;
                if (kAudioFormatMPEG4AAC_HE_V2 == basic_desc.mFormatID) {
                    m_AudioFormat = basic_desc;
                    break;
                }else if (kAudioFormatMPEG4AAC_HE == basic_desc.mFormatID) {
                    m_AudioFormat = basic_desc;
                    break;
                }
            }
            
            free(format_list);
        }
            
        default:
            break;
    }
}

void CAudioQueueStreamPlayer::AudioStreamPropertyListenerCallback(void *in_usr_data, AudioFileStreamID in_audio_file_stream, AudioFileStreamPropertyID in_property_id, UInt32 *io_flags){
    CAudioQueueStreamPlayer* p_this = (CAudioQueueStreamPlayer*)in_usr_data;
    p_this->AudioStreamPropertyListenerProc(in_audio_file_stream, in_property_id, io_flags);
}

void CAudioQueueStreamPlayer::AudioStreamPacketsProc(UInt32 in_num_bytes, UInt32 in_num_packs, const void *in_input_data, AudioStreamPacketDescription *in_pack_desc){
    if (!m_bReadyToProducePackets) {
        m_bReadyToProducePackets = TRUE;
    }
    
    if (in_pack_desc) {
        m_bIsVbr = TRUE;
    }
    
    if (!m_unBitRate) {
        CalculateBitRate();
    }
    
    if (!m_AudioQueue && !CreateAudioQueue()) {
        return;
    }
    
    UInt32 un_bytes_offset = 0;
    UInt32 un_packet_start = 0;
    
    if (m_AudioBuffer && (0 == m_AudioBufferCache->mAudioDataByteSize)) {
        if (!FillStreamBufferPackets(m_AudioBuffer, m_unVbrPacketCount, m_VbrPacketDescs, in_num_bytes, in_num_packs, in_input_data, in_pack_desc, un_bytes_offset, un_packet_start)) {
            return;
        }
    }
    
    if (in_num_bytes > un_bytes_offset) {
        if (!FillStreamBufferPackets(m_AudioBufferCache, m_unVbrPacketCountCache, m_VbrPacketDescsCache, in_num_bytes, in_num_packs, in_input_data, in_pack_desc, un_bytes_offset, un_packet_start)) {
            return;
        }
    }
    
    if (in_num_bytes > un_bytes_offset) {
        assert(false);
    }
}

void CAudioQueueStreamPlayer::AudioStreamPacketsCallback(void *in_usr_data, UInt32 in_num_bytes, UInt32 in_num_packs, const void *in_input_data, AudioStreamPacketDescription *in_pack_desc){
    CAudioQueueStreamPlayer* p_this = (CAudioQueueStreamPlayer*)in_usr_data;
    p_this->AudioStreamPacketsProc(in_num_bytes, in_num_packs, in_input_data, in_pack_desc);
}

void CAudioQueueStreamPlayer::SetPlayState(AudioStreamState stream_state){
    if (stream_state == m_PlayState) {
        return;
    }
    
    AudioStreamState state_old = m_PlayState;
    m_PlayState = stream_state;
    NotifyStateChange(m_PlayState, state_old);
}

void CAudioQueueStreamPlayer::SetErrCode(AudioStreamErrorCode err_code){
    NotifyError(err_code);
}

void CAudioQueueStreamPlayer::NotifyStateChange(AudioStreamState new_state, AudioStreamState old_state){
    if (m_StateHandler) {
        (*m_StateHandler)(new_state, old_state, m_HandlerData);
    }
}

void CAudioQueueStreamPlayer::NotifyError(AudioStreamErrorCode err_code){
    if (m_ErrorHandler) {
        (*m_ErrorHandler)(err_code, m_HandlerData);
    }
}

BOOL CAudioQueueStreamPlayer::Reset(){
    m_AudioQueue = NULL;
    m_bPlaying = FALSE;
    m_PlayState = STATE_STOPPED;
    
    m_bReadyToProducePackets = FALSE;
    
    m_pStreamFile = NULL;
    m_AudioTypeID = 0;
    m_AudioStreamID = NULL;
    memset(&m_AudioFormat, 0, sizeof(m_AudioFormat));
    memset(m_AudioBuffers, 0, sizeof(m_AudioBuffers));
    memset(m_AudioBuffersEmpty, 0, sizeof(m_AudioBuffersEmpty));
    
    m_unEmptyBufferCount = 0;
    
    m_AudioBuffer = NULL;
    m_unVbrPacketCount = 0;
    
    m_AudioBufferCache = NULL;
    m_unVbrPacketCountCache = 0;
    
    m_fSchedule = 0.f;
    m_fDuration = 0.f;
    m_fSeekTime = 0.f;
    
    m_unDataOffset = 0;
    m_unAudioDataSize = 0;
    m_unMaxPacketSize = 0;
    
    m_unBitRate = 0;
    m_fSampleRate = 0.f;
    m_fPacketDuration = 0.f;
    m_unNumberOfChannels = 0;
    m_bIsVbr = FALSE;
    
    m_bSeeking = FALSE;
    m_bStoping = FALSE;
    
    m_nBlockCount = 0;
    m_unBlockTime = 0;
    
    return TRUE;
}

BOOL CAudioQueueStreamPlayer::ParseStreamFormat(){
    while (!m_bReadyToProducePackets) {
        BOOL b_ret = ParseStreamData();
        if (!b_ret) {
            break;
        }
    }
    
    return m_bReadyToProducePackets;
}

BOOL CAudioQueueStreamPlayer::ParseStreamData(){
    if (!m_AudioStreamID || !m_pStreamFile || !m_pStreamFile->IsOpen()) {
        return FALSE;
    }
    
    const int n_buf_size = kAudioStreamBufSize;
    Byte pbBuffer[n_buf_size];
    UInt32 un_size = n_buf_size;
    
    int n_len = m_pStreamFile->Read(pbBuffer, un_size);
    if (0 < n_len) {
        UInt32 un_flag = m_bReadyToProducePackets ? 0 : kAudioFileStreamParseFlag_Discontinuity;
        OSStatus err = AudioFileStreamParseBytes(m_AudioStreamID, n_len, pbBuffer, un_flag);
        if (err) {
            SetErrCode(E_AUDIO_STREAM_PHASE_BYTES_ERR);
            return FALSE;
        }
    }
    
    if (m_AudioBuffer && m_pStreamFile->IsBuffering() && !m_pStreamFile->IsBufferReady(m_AudioBuffer->mAudioDataBytesCapacity)) {
        m_bBuffering = TRUE;
        m_bFlushEof = FALSE;
    }
    
    if (n_len < un_size) {
        if (m_pStreamFile->IsBuffering()) {
            m_bBuffering = TRUE;
            m_bFlushEof = FALSE;
        }else if (m_pStreamFile->IsEndOfFile()) {
            m_bBuffering = FALSE;
            m_bFlushEof = TRUE;
            SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
        }
    }
    
    return (BOOL)(0 < n_len);
}

UInt32 CAudioQueueStreamPlayer::FillStreamBuffer(){
    assert(NULL != m_AudioBuffer);
    assert(0 == m_unVbrPacketCount);
    if (!m_AudioBuffer) {
        return 0;
    }
    
    m_AudioBuffer->mAudioDataByteSize = 0;
    m_AudioBuffer->mPacketDescriptionCount = 0;
    
    FillStreamBufferFromCache();
    while ((0 == m_AudioBufferCache->mAudioDataByteSize) && (m_AudioBuffer->mAudioDataByteSize < m_AudioBuffer->mAudioDataBytesCapacity) && (m_unVbrPacketCount < kAQMaxPacketDescs)) {
        if (!ParseStreamData()) {
            break;
        }
    }
    
    return m_AudioBuffer->mAudioDataByteSize;
}

BOOL CAudioQueueStreamPlayer::FillStreamBufferPackets(AudioQueueBufferRef audio_buf, UInt32 un_vbr_pack_count, AudioStreamPacketDescription *p_vbr_pack_desc, UInt32 un_bytes, UInt32 un_packs, const void *p_pack_data, AudioStreamPacketDescription *p_pack_desc, UInt32 &un_bytes_offset, UInt32 &un_packet_start){
    assert(NULL != audio_buf);
    if (p_pack_desc) {
        int n_packet_index = un_packet_start;
        while (n_packet_index < un_packs) {
            SInt64 sn_packet_offset = p_pack_desc[n_packet_index].mStartOffset;
            SInt64 sn_packet_size = p_pack_desc[n_packet_index].mDataByteSize;
            if (sn_packet_size > (audio_buf->mAudioDataBytesCapacity - audio_buf->mAudioDataByteSize) || (un_vbr_pack_count > kAQMaxPacketDescs)) {
                break;
            }
            
            memcpy((Byte*)audio_buf->mAudioData + audio_buf->mAudioDataByteSize, (const Byte*)p_pack_data + sn_packet_offset, sn_packet_size);
            
            p_vbr_pack_desc[un_vbr_pack_count] = p_pack_desc[n_packet_index];
            p_vbr_pack_desc[un_vbr_pack_count].mStartOffset = audio_buf->mAudioDataByteSize;
            audio_buf->mAudioDataByteSize += sn_packet_size;
            un_vbr_pack_count++;
            ++n_packet_index;
            un_bytes_offset = sn_packet_offset + sn_packet_size;
            ++un_packet_start;
        }
    }else {
        assert(un_bytes >= un_bytes_offset);
        UInt32 un_copy_size = std::min(un_bytes - un_bytes_offset, audio_buf->mAudioDataBytesCapacity - audio_buf->mAudioDataByteSize);
        memcpy((Byte*)audio_buf->mAudioData + audio_buf->mAudioDataByteSize, (const Byte*)p_pack_data + un_bytes_offset, un_copy_size);
        audio_buf->mAudioDataByteSize += un_copy_size;
        un_bytes_offset += un_copy_size;
    }
    
    return TRUE;
}

UInt32 CAudioQueueStreamPlayer::FillStreamBufferFromCache(){
    assert(NULL != m_AudioBuffer);
    assert(NULL != m_AudioBufferCache);
    
    if (0 == m_AudioBufferCache->mAudioDataByteSize) {
        return 0;
    }
    
    AudioQueueBufferRef temp_buf = m_AudioBuffer;
    
    m_AudioBuffer = m_AudioBufferCache;
    m_unVbrPacketCount = m_unVbrPacketCountCache;
    memcpy(m_VbrPacketDescs, m_VbrPacketDescsCache, sizeof(m_VbrPacketDescs[0]) * m_unVbrPacketCountCache);
    m_AudioBufferCache = temp_buf;
    m_unVbrPacketCountCache = 0;
    
    return m_AudioBuffer->mAudioDataByteSize;
}

BOOL CAudioQueueStreamPlayer::EnqueueStreamBuffer(){
    assert(NULL != m_AudioQueue);
    assert(NULL != m_AudioBuffer);
    
    OSStatus err = AudioQueueEnqueueBuffer(m_AudioQueue, m_AudioBuffer, m_unVbrPacketCount, m_VbrPacketDescs);
    if (noErr != err) {
        SetErrCode(E_AUDIO_QUEUE_ENQUEUE_ERR);
        return FALSE;
    }
    
    m_AudioBuffer = NULL;
    m_unVbrPacketCount = 0;
    
    return TRUE;
}


//Return number of empty buffer
int CAudioQueueStreamPlayer::AddEmptyBuffer(AudioQueueBufferRef buffer){
    assert(m_unEmptyBufferCount < kAQNumberBuffers);
    buffer->mAudioDataByteSize = 0;
    buffer->mPacketDescriptionCount = 0;
    m_AudioBuffersEmpty[m_unEmptyBufferCount++] = buffer;
    return m_unEmptyBufferCount;
}

AudioQueueBufferRef CAudioQueueStreamPlayer::GetEmptyBuffer(BOOL b_erase){
    AudioQueueBufferRef buffer = m_AudioBuffersEmpty[0];
    if (NULL != buffer && b_erase) {
        assert((0 < m_unEmptyBufferCount) && (kAQNumberBuffers >= m_unEmptyBufferCount));
        --m_unEmptyBufferCount;
        int n_index(0);
        while (n_index < m_unEmptyBufferCount) {
            m_AudioBuffersEmpty[n_index] = m_AudioBuffersEmpty[n_index + 1];
            ++n_index;
        }
        m_AudioBuffersEmpty[m_unEmptyBufferCount] = NULL;
    }
    
    return buffer;
}

BOOL CAudioQueueStreamPlayer::ResetEmptyBuffer(){
    for (unsigned int un_itr = 0; un_itr < m_unEmptyBufferCount + 1; ++un_itr) {
        if (AudioQueueBufferRef buffer = m_AudioBuffers[un_itr]) {
            buffer->mAudioDataByteSize = 0;
            buffer->mPacketDescriptionCount = 0;
        }
    }
    
    memcpy(m_AudioBuffersEmpty, m_AudioBuffers, sizeof(m_AudioBuffersEmpty));
    m_unEmptyBufferCount = kAQNumberBuffers;
    m_AudioBuffer = NULL;
    m_unVbrPacketCount = 0;
    m_AudioBufferCache = m_AudioBuffers[kAQNumberBuffers];
    m_unVbrPacketCountCache = 0;
    
    return TRUE;
}

BOOL CAudioQueueStreamPlayer::IsAllBuffersEmpty()const{
    return kAQNumberBuffers == m_unEmptyBufferCount;
}
