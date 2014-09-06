//
//  AudioQueuePlayer.mm
//  AudioQueuePlayer
//
//  Created by 永杰 单 on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include "AudioQueuePlayer.h"
#include "MessageManager.h"
#include "IAudioStateObserver.h"

#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVAudioSession.h>

//#include "AutoLock.h"
#include "freeverb.h"
#include "AudioEffectType.h"

//#include "Score.h"

//static KwTools::CLock s_lock_volume;
static float s_f_cur_time = 0.f;

static double s_f_cur_volume = 0;

void CAudioQueuePlayer::AudioQueueBufferCallback(void *in_usr_data, AudioQueueRef in_audio_queue, AudioQueueBufferRef complete_audio_queue_buf){
    CAudioQueuePlayer* p_this = (CAudioQueuePlayer*)in_usr_data;
    if (p_this->m_bIsDone) {
        return;
    }
    
    UInt32 un_num_bytes = 0;
    UInt32 un_num_packs = p_this->GetNumPacksToRead();
    AudioFileReadPackets(p_this->GetAudioFIleID(), false, &un_num_bytes, complete_audio_queue_buf->mPacketDescriptions, p_this->GetCurrentPack(), &un_num_packs, complete_audio_queue_buf->mAudioData);
    
    if (0 < un_num_packs) {
        complete_audio_queue_buf->mAudioDataByteSize = un_num_bytes;
        complete_audio_queue_buf->mPacketDescriptionCount = un_num_packs;
        
        short* audio_data = (short*) complete_audio_queue_buf->mAudioData;
        int n_data_len = un_num_bytes / 2;
        
        double f_temp_env = 0.;
        for (int n_itr = 0; n_itr < n_data_len; n_itr += 2) {
            double frame_amp = 0.;
            for (int j = n_itr; j < n_itr +  2; ++j) {
                frame_amp += audio_data[n_itr];
            }
            frame_amp /= 2;
            f_temp_env += frame_amp * frame_amp;
        }
        
        f_temp_env /= (n_data_len / 2);
        f_temp_env = ((f_temp_env > 1) ? log10(f_temp_env) : 0.) / 9;
        s_f_cur_volume = (f_temp_env < 0.5) ? 0.0 : ((f_temp_env - 0.5) * 2);
        s_f_cur_volume = s_f_cur_volume * s_f_cur_volume;
        
        if (p_this->m_bHasEchoEffect && (NULL != p_this->m_pVerbProcess)) {
            p_this->m_pVerbProcess->process(44100, 1, 2, audio_data, un_num_bytes / 2, false);
        }
        
        AudioQueueEnqueueBuffer(in_audio_queue, complete_audio_queue_buf, 0, NULL);
        
        s_f_cur_time = p_this->m_snCurPack / 44100;
        
        p_this->m_snCurPack = p_this->GetCurrentPack() + un_num_packs;
    }else {
        if (p_this->IsLooping()) {
            p_this->m_snCurPack = 0;
            AudioQueueBufferCallback(in_usr_data, in_audio_queue, complete_audio_queue_buf);
        }else {
            p_this->m_bIsDone = true;
            AudioQueueStop(in_audio_queue, false);
            if (p_this->m_bIsInitialized) {
                SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::PlayStop);
            }
        }
    }
    
}

void CAudioQueuePlayer::IsRunningProc(void *in_usr_data, AudioQueueRef in_audio_queue, AudioQueuePropertyID property_id){
    CAudioQueuePlayer* p_this = (CAudioQueuePlayer*) in_usr_data;
    UInt32 un_size = sizeof(p_this->m_unIsRunning);
    OSStatus ret_status = AudioQueueGetProperty(in_audio_queue, kAudioQueueProperty_IsRunning, &p_this->m_unIsRunning, &un_size);
    if ((noErr == ret_status) && (!p_this->m_unIsRunning)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"play stopped" object:nil];
    }
}

void CAudioQueuePlayer::CalculateBytesForTime(AudioStreamBasicDescription &data_desc, UInt32 un_max_pack_size, Float64 f_seconds, UInt32 *un_out_buf_size, UInt32 *un_num_packs){
    static const int s_n_max_buf_size = 0x10000;
    static const int s_n_min_buf_size = 0x4000;
    
    if (data_desc.mFramesPerPacket) {
        Float64 f_num_packs_for_time = data_desc.mSampleRate / data_desc.mFramesPerPacket * f_seconds;
        *un_out_buf_size = f_num_packs_for_time * s_n_max_buf_size;
    }else {
        *un_out_buf_size = s_n_max_buf_size > un_max_pack_size ? s_n_max_buf_size : un_max_pack_size;
    }
    
    if ((s_n_max_buf_size < *un_out_buf_size) && (un_max_pack_size < *un_out_buf_size)) {
        *un_out_buf_size = s_n_max_buf_size;
    }else {
        if (s_n_min_buf_size > *un_out_buf_size) {
            *un_out_buf_size = s_n_min_buf_size;
        }
    }
    
    *un_num_packs = *un_out_buf_size / un_max_pack_size;
}

CAudioQueuePlayer::CAudioQueuePlayer() : m_AudioQueue(0), m_AudioFile(0), m_strFilePath(NULL), m_unIsRunning(0), m_bIsInitialized(false), m_unNumPacksToRead(0), m_snCurPack(0), m_bIsDone(false), m_bIsLooping(false), m_bHasEchoEffect(false), m_pVerbProcess(NULL){
}

CAudioQueuePlayer::~CAudioQueuePlayer(){
    if(m_pVerbProcess){
        delete m_pVerbProcess;
        m_pVerbProcess = NULL;
    }
    DisposeQueue(true);
}


bool CAudioQueuePlayer::InitAudioQueue(CFStringRef str_file_path){
    AVAudioSession* audio_session = [AVAudioSession sharedInstance];
    [audio_session setActive:YES error:nil];
    
    UInt32 un_audio_override = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(un_audio_override), &un_audio_override);
    
    if (NULL == m_AudioQueue) {
        CreateQueueForFile(str_file_path);
    }
    
    m_bIsDone = false;
    
    m_snCurPack = 0;
    
    s_f_cur_volume = 0;
    
    for (int n_itr = 0; n_itr < NUM_BUFS; ++n_itr) {
        AudioQueueBufferCallback(this, m_AudioQueue, m_Buffers[n_itr]);
    }
    
    m_bIsInitialized = true;
    s_f_cur_time = 0.f;
    
    if (m_bIsDone) {
        return false;
    }
    
    return true;
}

OSStatus CAudioQueuePlayer::StartPlay(){
    AudioQueueCreateTimeline(m_AudioQueue, &m_AQTimeLine);
    return AudioQueueStart(m_AudioQueue, NULL);
}

OSStatus CAudioQueuePlayer::ResumePlay(){
    
    return AudioQueueStart(m_AudioQueue, NULL);
}

OSStatus CAudioQueuePlayer::StopPlay(){
    
    return AudioQueueStop(m_AudioQueue, true);
}

OSStatus CAudioQueuePlayer::PausePlay(){
    return AudioQueuePause(m_AudioQueue);
}

OSStatus CAudioQueuePlayer::Seek(float f_seek_time){

    UInt32 un_num_packs_to_read = m_DataFormat.mSampleRate * ((int)f_seek_time) / m_DataFormat.mFramesPerPacket;
    
    for (int n_itr = 0; n_itr < NUM_BUFS; ++n_itr){
        AudioQueueFreeBuffer(m_AudioQueue, m_Buffers[n_itr]);
    }
    
    UInt32 un_buf_byte_size = 0;
    UInt32 un_max_pack_size = 0;
    UInt32 un_size = sizeof(un_max_pack_size);
    AudioFileGetProperty(m_AudioFile, kAudioFilePropertyPacketSizeUpperBound, &un_size, &un_max_pack_size);
    CalculateBytesForTime(m_DataFormat, un_max_pack_size, SEC_BUF_DURATION, &un_buf_byte_size, &m_unNumPacksToRead);
    bool b_is_format_vbr = ((0 == m_DataFormat.mBytesPerPacket) || (0 == m_DataFormat.mFramesPerPacket));
    for (int n_itr = 0; n_itr < NUM_BUFS; ++n_itr) {
        AudioQueueAllocateBufferWithPacketDescriptions(m_AudioQueue, un_buf_byte_size, (b_is_format_vbr ? m_unNumPacksToRead : 0), &m_Buffers[n_itr]);
    }
    
    m_snCurPack = un_num_packs_to_read;
    
    for (int n_itr = 0; n_itr < NUM_BUFS; ++n_itr) {
        AudioQueueBufferCallback(this, m_AudioQueue, m_Buffers[n_itr]);
    }
    
    return noErr;
}

unsigned int CAudioQueuePlayer::GetCurVolume(){
//    float f_cur_volume(0.0);
//    KwTools::CAutoLock auto_lock(&s_lock_volume);
//    if (0 == m_fVolumeVec.size()) {
//        return f_cur_volume;
//    }
//    for (std::vector<float>::iterator itr = m_fVolumeVec.begin(); itr != m_fVolumeVec.end(); ++itr){
//        f_cur_volume += *itr;
//    }
//    return 100 * f_cur_volume / m_fVolumeVec.size();
    return 100 * s_f_cur_volume;
}

float CAudioQueuePlayer::GetCurrentTime(){
    
    return s_f_cur_time;

    if (!m_AudioQueue || 0 == m_DataFormat.mSampleRate) {
        return 0.0;
    }

    AudioTimeStamp time_stamp;
    AudioQueueGetCurrentTime(m_AudioQueue, m_AQTimeLine, &time_stamp, NULL);
    
    return time_stamp.mSampleTime / m_DataFormat.mSampleRate;
//    return 0.0;
}

void CAudioQueuePlayer::SetEchoType(EAudioEchoEffect echo_effect){
    if (NO_EFFECT != echo_effect) {
        m_EchoPara = arry_echo_para[echo_effect];
        m_bHasEchoEffect = true;
        if(m_pVerbProcess){
            delete m_pVerbProcess;
            m_pVerbProcess = NULL;
        }
        m_pVerbProcess = new freeverb(&m_EchoPara);
    }else {
        m_bHasEchoEffect = false;
    }
}

void CAudioQueuePlayer::CreateQueueForFile(CFStringRef str_file_path){
    CFURLRef sound_file = NULL;
    if (NULL == m_strFilePath) {
        m_bIsLooping = false;
        sound_file = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, str_file_path, kCFURLPOSIXPathStyle, false);
        if (!sound_file) {
            return;
        }
        
        AudioFileOpenURL(sound_file, kAudioFileReadPermission, 0, &m_AudioFile);
        
        UInt32 un_size = sizeof(m_DataFormat);
        AudioFileGetProperty(m_AudioFile, kAudioFilePropertyDataFormat, &un_size, &m_DataFormat);
        
        m_strFilePath = CFStringCreateCopy(kCFAllocatorDefault, str_file_path);
    }
    
    SetupNewQueue();
    
    if (sound_file) {
        CFRelease(sound_file);
    }
}

void CAudioQueuePlayer::SetupNewQueue(){
    AudioQueueNewOutput(&m_DataFormat, CAudioQueuePlayer::AudioQueueBufferCallback, this, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &m_AudioQueue);
    UInt32 un_buf_byte_size = 0;
    UInt32 un_max_pack_size = 0;
    UInt32 un_size = sizeof(un_max_pack_size);
    AudioFileGetProperty(m_AudioFile, kAudioFilePropertyPacketSizeUpperBound, &un_size, &un_max_pack_size);
    CalculateBytesForTime(m_DataFormat, un_max_pack_size, SEC_BUF_DURATION, &un_buf_byte_size, &m_unNumPacksToRead);
    
    un_size = sizeof(UInt32);
    OSStatus ret_status = AudioFileGetPropertyInfo(m_AudioFile, kAudioFilePropertyMagicCookieData, &un_size, NULL);
    if (!ret_status && un_size) {
        char* cookie = new char[un_size];
        AudioFileGetProperty(m_AudioFile, kAudioFilePropertyMagicCookieData, &un_size, cookie);
        AudioQueueSetProperty(m_AudioQueue, kAudioQueueProperty_MagicCookie, cookie, un_size);
        delete[] cookie;
    }
    
    ret_status = AudioFileGetPropertyInfo(m_AudioFile, kAudioFilePropertyChannelLayout, &un_size, NULL);
    if ((noErr == ret_status) && (0 < un_size)) {
        AudioChannelLayout* audio_channel_lay = (AudioChannelLayout*)malloc(un_size);
        AudioFileGetProperty(m_AudioFile, kAudioFilePropertyChannelLayout, &un_size, audio_channel_lay);
        AudioQueueSetProperty(m_AudioQueue, kAudioQueueProperty_ChannelLayout, audio_channel_lay, un_size);
        free(audio_channel_lay);
    }
    
    AudioQueueAddPropertyListener(m_AudioQueue, kAudioQueueProperty_IsRunning, IsRunningProc, this);
    bool b_is_format_vbr = ((0 == m_DataFormat.mBytesPerPacket) || (0 == m_DataFormat.mFramesPerPacket));
    for (int n_itr = 0; n_itr < NUM_BUFS; ++n_itr) {
        AudioQueueAllocateBufferWithPacketDescriptions(m_AudioQueue, un_buf_byte_size, (b_is_format_vbr ? m_unNumPacksToRead : 0), &m_Buffers[n_itr]);
    }
    AudioQueueSetParameter(m_AudioQueue, kAudioQueueParam_Volume, 1.0);
}

void CAudioQueuePlayer::DisposeQueue(Boolean b_dispose_file){
    if (b_dispose_file) {
        if (m_AudioFile) {
            AudioFileClose(m_AudioFile);
            m_AudioFile = 0;
        }
    }
    
    if (m_strFilePath) {
        CFRelease(m_strFilePath);
        m_strFilePath = NULL;
    }
    
    m_bIsInitialized = false;
    s_f_cur_volume = 0;
    AudioQueueDisposeTimeline(m_AudioQueue, m_AQTimeLine);
    
    if (m_AudioQueue) {
        AudioQueueDispose(m_AudioQueue, false);
        m_AudioQueue = NULL;
    }
}

void CAudioQueuePlayer::SetPlayVolume(float f_volume){
    AudioQueueSetParameter(m_AudioQueue, kAudioQueueParam_Volume, f_volume);
}
