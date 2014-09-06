//
//  AudioFormatConvert.h
//  KwSing
//
//  Created by 永杰 单 on 12-7-27.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CAudioFormatConvert_h
#define KwSing_CAudioFormatConvert_h

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>

typedef struct {
    AudioFileID souce_file_id;
    SInt64 sn_src_file_pos;
    char* src_buf;
    UInt32 un_src_buf_size;
    AudioStreamBasicDescription src_format;
    UInt32 un_src_size_per_pack;
    UInt32 un_packs_per_read;
    AudioStreamPacketDescription* pack_format;
}AudioFileIO, *AudioFileIORef;

enum ThreadStates{
    STATE_THREAD_RUNNING,
    STATE_THREAD_PAUSED,
    STATE_THREAD_DONE
};

enum{ERR_AUDIO_CONVERT_CAN_NOT_RESUME_FORM_INTERRUPTION, ERR_END_OF_FILE = -39};

class CAudioFormatConvert{
public:
    static bool IsAACHardwareDecoderAvailable();
    static bool IsMP3HardwareDecoderAvailable();
    static OSStatus ConvertFormatToPCM(id infile_outfile, OSType output_format = kAudioFormatLinearPCM, Float64 f_out_sample_rate = 44100.f);
};

#endif
