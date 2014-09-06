//
//  KSAudioMixer.m
//  KwSing
//
//  Created by 单 永杰 on 13-5-20.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import "KSAudioMixer.h"
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioToolbox.h>
#include "MessageManager.h"
#include "IMediaSaveProcessObserver.h"
#include "RecordTask.h"

@implementation KSAudioMixer

+(void) setDefaultAudioFormat : (AudioStreamBasicDescription*)audioForamt sampleRate : (Float64)f_sample_rate numChannels : (int)n_num_channels{
    memset(audioForamt, 0, sizeof(AudioStreamBasicDescription));
    audioForamt->mFormatID = kAudioFormatLinearPCM;
    audioForamt->mSampleRate = f_sample_rate;
    audioForamt->mChannelsPerFrame = n_num_channels;
    audioForamt->mBytesPerPacket = 2 * n_num_channels;
    audioForamt->mFramesPerPacket = 1;
    audioForamt->mBytesPerFrame = 2 * n_num_channels;
    audioForamt->mBitsPerChannel = 16;
    audioForamt->mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
}

+ (BOOL) mixAudio : (NSString*)str_acomp_path andAudio : (NSString*)str_sing_path output : (NSString*)str_output_path{
    
    float f_sing_volume = CRecordTask::GetInstance()->GetSingVolume();
    float f_acom_volume = CRecordTask::GetInstance()->GetAccompanyVolume();
    
    OSStatus ret_status = noErr;
    AudioStreamBasicDescription acomp_audio_format;
    AudioStreamBasicDescription sing_audio_format;
    AudioStreamBasicDescription client_format;
    AudioStreamBasicDescription output_audio_format;
    
    UInt32 un_property_size = sizeof(AudioStreamBasicDescription);
    ExtAudioFileRef acom_audio_file = NULL;
    ExtAudioFileRef sing_audio_file = NULL;
    ExtAudioFileRef output_audio_file = NULL;
    
    UInt64 un_sing_frames = 0;
    UInt64 un_processed_frames = 0;
    
    NSURL* acomp_url = [NSURL fileURLWithPath:str_acomp_path];
    NSURL* sing_url = [NSURL fileURLWithPath:str_sing_path];
    NSURL* output_url = [NSURL fileURLWithPath:str_output_path];
    
    ret_status = ExtAudioFileOpenURL((CFURLRef)acomp_url, &acom_audio_file);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        return NO;
    }
    
    ret_status = ExtAudioFileOpenURL((CFURLRef)sing_url, &sing_audio_file);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        return NO;
    }
    
    memset(&acomp_audio_format, 0, sizeof(AudioStreamBasicDescription));
    ret_status = ExtAudioFileGetProperty(acom_audio_file, kExtAudioFileProperty_FileDataFormat, &un_property_size, &acomp_audio_format);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        return NO;
    }
    
    memset(&sing_audio_format, 0, sizeof(AudioStreamBasicDescription));
    ret_status = ExtAudioFileGetProperty(sing_audio_file, kExtAudioFileProperty_FileDataFormat, &un_property_size, &sing_audio_format);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        return NO;
    }
    
    int n_num_channels = MAX(acomp_audio_format.mChannelsPerFrame, sing_audio_format.mChannelsPerFrame);
    Float64 f_sample_rate = MAX(acomp_audio_format.mSampleRate, sing_audio_format.mSampleRate);
    [self setDefaultAudioFormat:&client_format sampleRate:f_sample_rate numChannels:n_num_channels];
    
    ret_status = ExtAudioFileSetProperty(acom_audio_file, kExtAudioFileProperty_ClientDataFormat, un_property_size, &client_format);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        return NO;
    }
    
    ret_status = ExtAudioFileSetProperty(sing_audio_file, kExtAudioFileProperty_ClientDataFormat, un_property_size, &client_format);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        return NO;
    }
    
    memset(&output_audio_format, 0, sizeof(output_audio_format));
    [self setDefaultAudioFormat:&output_audio_format sampleRate:f_sample_rate numChannels:n_num_channels];
    
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &un_property_size, &output_audio_format);
    ret_status = ExtAudioFileCreateWithURL((CFURLRef)output_url, kAudioFileWAVEType, &output_audio_format, NULL, kAudioFileFlags_EraseFile, &output_audio_file);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        if (output_audio_file) {
            ExtAudioFileDispose(output_audio_file);
            output_audio_file = nil;
        }
        
        return NO;
    }
    
//    ExtAudioFileSetProperty(output_audio_file, kExtAudioFileProperty_ClientDataFormat, un_property_size, &client_format);
    
    ret_status = ExtAudioFileSetProperty(output_audio_file, kExtAudioFileProperty_ClientDataFormat, un_property_size, &client_format);
    if (noErr != ret_status) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        if (output_audio_file) {
            ExtAudioFileDispose(output_audio_file);
            output_audio_file = nil;
        }
        
        return NO;
    }
    
    UInt32 un_size = sizeof(un_sing_frames);
    ExtAudioFileGetProperty(sing_audio_file, kExtAudioFileProperty_FileLengthFrames, &un_size, &un_sing_frames);
    if (0 == un_sing_frames) {
        if (acom_audio_file) {
            ExtAudioFileDispose(acom_audio_file);
            acom_audio_file = nil;
        }
        
        if (sing_audio_file) {
            ExtAudioFileDispose(sing_audio_file);
            sing_audio_file = nil;
        }
        
        if (output_audio_file) {
            ExtAudioFileDispose(output_audio_file);
            output_audio_file = nil;
        }
        
        return YES;
    }
    
    UInt16 un_buf_size = 8192 * 10;
    AudioSampleType* buf_acomp = (AudioSampleType*)malloc(un_buf_size);
    AudioSampleType* buf_sing = (AudioSampleType*)malloc(un_buf_size);
    AudioSampleType* buf_output = (AudioSampleType*)malloc(un_buf_size);
    
    AudioBufferList convert_buf_acomp;
    convert_buf_acomp.mNumberBuffers = 1;
    convert_buf_acomp.mBuffers[0].mNumberChannels = acomp_audio_format.mChannelsPerFrame;
    convert_buf_acomp.mBuffers[0].mDataByteSize = un_buf_size;
    convert_buf_acomp.mBuffers[0].mData = buf_acomp;
    
    AudioBufferList convert_buf_sing;
    convert_buf_sing.mNumberBuffers = 1;
    convert_buf_sing.mBuffers[0].mNumberChannels = sing_audio_format.mChannelsPerFrame;
    convert_buf_sing.mBuffers[0].mDataByteSize = un_buf_size;
    convert_buf_sing.mBuffers[0].mData = buf_sing;
    
    AudioBufferList output_buf_list;
    output_buf_list.mNumberBuffers = 1;
    output_buf_list.mBuffers[0].mNumberChannels = n_num_channels;
    output_buf_list.mBuffers[0].mDataByteSize = un_buf_size;
    output_buf_list.mBuffers[0].mData = buf_output;
    
    UInt32 un_frames_read_per_time = INT_MAX;
    UInt8 un_bit_offset = 8 * sizeof(AudioSampleType);
    UInt64 un_bit_max = (UInt64)(pow(2, un_bit_offset));
    UInt64 un_bit_mid = un_bit_max / 2;
    
    while (true) {
        convert_buf_acomp.mBuffers[0].mDataByteSize = un_buf_size;
        convert_buf_sing.mBuffers[0].mDataByteSize = un_buf_size;
        output_buf_list.mBuffers[0].mDataByteSize = un_buf_size;
        
        UInt32 un_frame_count_acomp = un_frames_read_per_time;
        UInt32 un_frame_count_sing = un_frames_read_per_time;
        
        if (acomp_audio_format.mBytesPerFrame) {
            un_frame_count_acomp = un_buf_size / acomp_audio_format.mBytesPerFrame;
        }
        if (sing_audio_format.mBytesPerFrame) {
            un_frame_count_sing = un_buf_size / sing_audio_format.mBytesPerFrame;
        }
        
        ret_status = ExtAudioFileRead(acom_audio_file, &un_frame_count_acomp, &convert_buf_acomp);
        if (noErr != ret_status) {
            if (buf_acomp) {
                free(buf_acomp);
                buf_acomp = NULL;
            }
            
            if (buf_sing) {
                free(buf_sing);
                buf_sing = NULL;
            }
            
            if (buf_output) {
                free(buf_output);
                buf_output = NULL;
            }
            
            if (acom_audio_file) {
                ExtAudioFileDispose(acom_audio_file);
                acom_audio_file = nil;
            }
            
            if (sing_audio_file) {
                ExtAudioFileDispose(sing_audio_file);
                sing_audio_file = nil;
            }
            
            if (output_audio_file) {
                ExtAudioFileDispose(output_audio_file);
                output_audio_file = nil;
            }
            
            return NO;
        }
        
        ret_status = ExtAudioFileRead(sing_audio_file, &un_frame_count_sing, &convert_buf_sing);
        if (noErr != ret_status) {
            if (buf_acomp) {
                free(buf_acomp);
                buf_acomp = NULL;
            }
            
            if (buf_sing) {
                free(buf_sing);
                buf_sing = NULL;
            }
            
            if (buf_output) {
                free(buf_output);
                buf_output = NULL;
            }
            
            if (acom_audio_file) {
                ExtAudioFileDispose(acom_audio_file);
                acom_audio_file = nil;
            }
            
            if (sing_audio_file) {
                ExtAudioFileDispose(sing_audio_file);
                sing_audio_file = nil;
            }
            
            if (output_audio_file) {
                ExtAudioFileDispose(output_audio_file);
                output_audio_file = nil;
            }
            
            return NO;
        }
        
        if (0 == un_frame_count_acomp || 0 == un_frame_count_sing) {
            break;
        }
        
        UInt32 un_frame_count = MIN(un_frame_count_acomp, un_frame_count_sing);
        un_processed_frames += un_frame_count;
        
        output_buf_list.mBuffers[0].mDataByteSize = un_frame_count * 4;
        output_buf_list.mNumberBuffers = 1;
        output_buf_list.mBuffers[0].mNumberChannels = 2;
        
        UInt32 un_length = un_frame_count * 2;
        for (int n_index = 0; n_index < un_length; ++n_index) {
            SInt32 sn_value = 0;
            SInt16 sn_value_acomp = (SInt16)(*(buf_acomp + n_index));
            SInt16 sn_value_sing = (SInt16)(*(buf_sing + n_index));
            
            SInt8 sn_sign_acomp = (0 == sn_value_acomp) ? 0 : (abs(sn_value_acomp) / sn_value_acomp);
            SInt8 sn_sign_sing = (0 == sn_value_sing) ? 0 : (abs(sn_value_sing) / sn_value_sing);
            
            sn_value_acomp *= f_acom_volume;
            sn_value_sing *= f_sing_volume;
            
            if (sn_sign_acomp == sn_sign_sing) {
                UInt32 un_temp = ((sn_value_acomp * sn_value_sing) >> (un_bit_offset - 1));
                sn_value = sn_value_acomp + sn_value_sing - sn_sign_sing * un_temp;
                if (un_bit_mid <= abs(sn_value)) {
                    sn_value = sn_sign_sing * (un_bit_mid - 1);
                }
            }else {
                SInt32 sn_temp_acomp = sn_value_acomp + un_bit_mid;
                SInt32 sn_temp_sing = sn_value_sing + un_bit_mid;
                UInt32 un_temp = ((sn_temp_acomp * sn_temp_sing) >> (un_bit_offset - 1));
                if (sn_temp_acomp < un_bit_mid && sn_temp_sing < un_bit_mid) {
                    sn_value = un_temp;
                }else {
                    sn_value = 2 * (sn_temp_acomp + sn_temp_sing) - un_temp - un_bit_max;
                }
                
                sn_value -= un_bit_mid;
            }
            
            if (0 != sn_value && un_bit_mid <= abs(sn_value)) {
                SInt8 sn_sign_value = abs(sn_value) / sn_value;
                sn_value = sn_sign_value * (un_bit_mid - 1);
            }
            
            *(buf_output + n_index) = sn_value;
        }
        
        ret_status = ExtAudioFileWrite(output_audio_file, un_frame_count, &output_buf_list);
        if (noErr != ret_status) {
            if (buf_acomp) {
                free(buf_acomp);
                buf_acomp = NULL;
            }
            
            if (buf_sing) {
                free(buf_sing);
                buf_sing = NULL;
            }
            
            if (buf_output) {
                free(buf_output);
                buf_output = NULL;
            }
            
            if (acom_audio_file) {
                ExtAudioFileDispose(acom_audio_file);
                acom_audio_file = nil;
            }
            
            if (sing_audio_file) {
                ExtAudioFileDispose(sing_audio_file);
                sing_audio_file = nil;
            }
            
            if (output_audio_file) {
                ExtAudioFileDispose(output_audio_file);
                output_audio_file = nil;
            }
            
            return NO;
        }
        
        SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveProgressChanged, (0.7 * un_processed_frames) / un_sing_frames);
    }

    if (buf_acomp) {
        free(buf_acomp);
        buf_acomp = NULL;
    }
    
    if (buf_sing) {
        free(buf_sing);
        buf_sing = NULL;
    }
    
    if (buf_output) {
        free(buf_output);
        buf_output = NULL;
    }
    
    if (acom_audio_file) {
        ExtAudioFileDispose(acom_audio_file);
        acom_audio_file = nil;
    }
    
    if (sing_audio_file) {
        ExtAudioFileDispose(sing_audio_file);
        sing_audio_file = nil;
    }
    
    if (output_audio_file) {
        ExtAudioFileDispose(output_audio_file);
        output_audio_file = nil;
    }
    
    return YES;
}

@end
