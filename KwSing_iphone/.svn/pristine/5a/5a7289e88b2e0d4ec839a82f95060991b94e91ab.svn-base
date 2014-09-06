//
//  AudioWaveToAAC.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-26.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "AudioWaveToAAC.h"
#include "MessageManager.h"
#include "IMediaSaveProcessObserver.h"

bool CAudioWaveToAAC::ConvertProcess(CFURLRef url_input_file, CFURLRef url_output_file, UInt32 un_out_bitrate){  
    ExtAudioFileRef file_source = NULL;
    AudioStreamBasicDescription format_source;
    ExtAudioFileOpenURL(url_input_file, &file_source);
    
    UInt32 un_size = sizeof(format_source);
    ExtAudioFileGetProperty(file_source, kExtAudioFileProperty_FileDataFormat, &un_size, &format_source);
    
    
    AudioStreamBasicDescription format_dest;
    memset(&format_dest, 0, sizeof(format_dest));
    format_dest.mChannelsPerFrame = format_source.mChannelsPerFrame;
    format_dest.mFormatID = kAudioFormatMPEG4AAC;
    format_dest.mSampleRate = 0.f;
  
    un_size = sizeof(AudioStreamBasicDescription);
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &un_size, &format_dest);
    
    ExtAudioFileRef file_dest;
    ExtAudioFileCreateWithURL(url_output_file, kAudioFileM4AType, &format_dest, NULL, kAudioFileFlags_EraseFile, &file_dest);
    
    AudioStreamBasicDescription format_client;
    memset(&format_client, 0, sizeof(format_client));
    
    format_client = format_source;
    un_size = sizeof(format_client);
    OSStatus err_ret = ExtAudioFileSetProperty(file_source, kExtAudioFileProperty_ClientDataFormat, un_size, &format_client);
    if (noErr != err_ret) {
        if (file_source) {
            ExtAudioFileDispose(file_source);
        }
        ExtAudioFileDispose(file_dest);
        return false;
    }
    
    UInt32 un_codec_manu = kAppleSoftwareAudioCodecManufacturer;
    ExtAudioFileSetProperty(file_dest, kExtAudioFileProperty_CodecManufacturer, sizeof(un_codec_manu), &un_codec_manu);
    
    un_size = sizeof(format_client);
    err_ret = ExtAudioFileSetProperty(file_dest, kExtAudioFileProperty_ClientDataFormat, un_size, &format_client);
    if (noErr != err_ret) {
        if (file_source) {
            ExtAudioFileDispose(file_source);
        }
        ExtAudioFileDispose(file_dest);
        return false;
    }
    
    AudioConverterRef audio_converter;
    un_size = sizeof(AudioConverterRef);
    ExtAudioFileGetProperty(file_dest, kExtAudioFileProperty_AudioConverter, &un_size, &audio_converter);
    AudioConverterSetProperty(audio_converter, kAudioConverterEncodeBitRate, sizeof(un_out_bitrate), &un_out_bitrate);
    
    SInt64 s_n_len_in_frames = 0;
    SInt64 s_n_processed_in_frames = 0;
    if (file_source) {
        un_size = sizeof(SInt64);
        ExtAudioFileGetProperty(file_source, kExtAudioFileProperty_FileLengthFrames, &un_size, &s_n_len_in_frames);
    }
    
    UInt32 un_buf_byte_size = 32768;
    char src_buffer[un_buf_byte_size];
    
    while (true) {
        AudioBufferList fill_buf_list;
        fill_buf_list.mNumberBuffers = 1;
        fill_buf_list.mBuffers[0].mNumberChannels = format_client.mChannelsPerFrame;
        fill_buf_list.mBuffers[0].mDataByteSize = un_buf_byte_size;
        fill_buf_list.mBuffers[0].mData = src_buffer;
        
        UInt32 un_num_frames = un_buf_byte_size / format_client.mBytesPerFrame;
        if (file_source) {
            if (noErr != ExtAudioFileRead(file_source, &un_num_frames, &fill_buf_list)) {
                ExtAudioFileDispose(file_source);
                ExtAudioFileDispose(file_dest);
                
                return false;
            }
        }
        
        if (0 == un_num_frames) {
            break;
        }
        
        s_n_processed_in_frames += un_num_frames;
        if (s_n_len_in_frames > s_n_processed_in_frames && 0 == s_n_processed_in_frames % 100) {
            SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveProgressChanged, 0.7 + 0.3 * (s_n_processed_in_frames) / s_n_len_in_frames);
        }
        
        ExtAudioFileWrite(file_dest, un_num_frames, &fill_buf_list);
    }
    
    if (file_source) {
        ExtAudioFileDispose(file_source);
    }
    ExtAudioFileDispose(file_dest);
    
    return true;
}
