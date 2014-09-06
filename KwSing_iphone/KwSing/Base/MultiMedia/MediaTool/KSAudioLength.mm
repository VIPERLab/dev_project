//
//  KSAudioLength.m
//  KwSing
//
//  Created by 永杰 单 on 12-9-12.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSAudioLength.h"
#import "KSRecordTempPath.h"
#include "KwDir.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>

@implementation KSAudioLength

+(unsigned long)getFileLength : (std::string)str_file_path{
    FILE* p_file = fopen(str_file_path.c_str(), "r+b");
    if (NULL == p_file) {
        return 0;
    }
    fseek(p_file, 0, SEEK_END);
    unsigned long n_file_len = ftell(p_file);
    fseek(p_file, 0, SEEK_SET);
    fclose(p_file);
    p_file = NULL;
    
    return n_file_len;
}

+(float) getRecordAudioLength : (std::string)str_play_file_path{
    float f_audio_duration = 0.0;
    if (0 == str_play_file_path.size()) {
        std::string str_record_path = [KSRecordTempPath getRecordTempPath] + "/FreeSing.wav";
        AVURLAsset* asset_audio = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:str_record_path.c_str()]] options:nil];
        f_audio_duration = asset_audio.duration.value / asset_audio.duration.timescale;
        [asset_audio release];
        asset_audio = nil;
    }else {
        std::string str_file_name = str_play_file_path;
        str_file_name = KwTools::Dir::GetFileName(str_file_name);
        int n_index = str_file_name.rfind(".");
        str_file_name = str_file_name.substr(0, n_index);
        std::string str_record_path = [KSRecordTempPath getRecordTempPath] + "/" + str_file_name + "Record.wav";
        AVURLAsset* asset_audio = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:str_record_path.c_str()]] options:nil];
        f_audio_duration = asset_audio.duration.value / asset_audio.duration.timescale;
        [asset_audio release];
        asset_audio = nil;
    }
    
    return f_audio_duration * 1000;
}

@end
