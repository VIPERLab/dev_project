//
//  AudioUnitRecorder.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-12.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CAudioUnitRecorder_h
#define KwSing_CAudioUnitRecorder_h

#include <AudioUnit/AudioUnit.h>
#include <AudioUnit/AUComponent.h>
#include <AudioUnit/AudioComponent.h>
#import <AudioToolbox/ExtendedAudioFile.h>

#ifndef KwSing_AudioEffectType_h
#include "AudioEffectType.h"
#endif

//#include "speex_preprocess.h"

#include <vector>

class CAudioUnitRecorder{
public:
    CAudioUnitRecorder();
    virtual ~CAudioUnitRecorder();
    bool initAudioUnit(NSString* str_record_path, bool b_is_decrease_noise = true);
    OSStatus startRecord();
    OSStatus pauseRecord();
    OSStatus stopRecord();
    void setRecordMode(bool b_is_freesing);
    unsigned short getCurVolume();
    int getCurrentTime();
    void dispose();
    void setHeadStatus(bool b_has_headset);
    bool SetEchoType(EAudioEchoEffect e_echo_type);
    bool SetReplayVolume(float f_volume);
    
private:
    static OSStatus recordCallback(void* in_ref_con, AudioUnitRenderActionFlags* io_action_flags, const AudioTimeStamp* in_time_stamp, UInt32 un_bus_num, UInt32 un_frame_num, AudioBufferList* io_buf_list);
    static OSStatus playbackCallBack(void* in_ref_con, AudioUnitRenderActionFlags* io_action_flags, const AudioTimeStamp* in_time_stamp, UInt32 un_bus_num, UInt32 un_frame_num, AudioBufferList* io_buf_list);
    
private:
    char* m_AudioBuffer;
    ExtAudioFileRef m_ExtAudioFile;
    RevSettings m_EchoPara;
    freeverb* m_pEchoProcessor;
    float m_fReplayVolume;
    std::vector<float> m_fVolumeVec;
//    SpeexPreprocessState* m_pNoiseProcessor;
    bool m_bIsDecrease_noise;
    int m_nEscapeBytes;
};

#endif
