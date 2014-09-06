//
//  SaveVideo.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "SaveVideo.h"
#include "AudioWaveToAAC.h"
#include "MessageManager.h"
#include "KSRecordTempPath.h"
#include "IMediaSaveProcessObserver.h"
#include "KwDir.h"
#include "KSVideoMerge.h"
#include "KwConfig.h"
#include "KwConfigElements.h"
#include "RecordTask.h"
#include "MobClick.h"
#include "KwUMengElement.h"
#include "KSAudioMixer.h"

static long S_LN_SAVE_VIDEO_TIME = 0;

bool CSaveVidio::SaveFile(){
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    S_LN_SAVE_VIDEO_TIME = time(NULL);
    
    if (0 == CRecordTask::GetInstance()->m_strAccompanyPath.size()) {
        std::string str_record_audio_path = [KSRecordTempPath getRecordTempPath] + "/FreeSing.wav";
        std::string str_record_m4a_path = [KSRecordTempPath getRecordTempPath] + "/FreeSing.m4a";
        std::string str_record_video_path = [KSRecordTempPath getRecordTempPath] + "/FreeSing.mp4";
        KS_BLOCK_DECLARE{
            
            [MobClick beginEvent:[NSString stringWithUTF8String:KS_SAVE_TIME]];
            
            if(!CAudioWaveToAAC::ConvertProcess((CFURLRef)[NSURL fileURLWithPath:[NSString stringWithUTF8String:str_record_audio_path.c_str()]], (CFURLRef)[NSURL fileURLWithPath:[NSString stringWithUTF8String:str_record_m4a_path.c_str()]], 48000)) {
                S_LN_SAVE_VIDEO_TIME = time(NULL) - S_LN_SAVE_VIDEO_TIME;
                SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveFinish, E_SAVE_FAIL, S_LN_SAVE_VIDEO_TIME * 1000);

                [MobClick endEvent:[NSString stringWithUTF8String:KS_SAVE_TIME]];
                
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                return;
            }
            
            [KSVideoMerge mergeAVFile:[NSString stringWithUTF8String:str_record_m4a_path.c_str()] videoFilePath:[NSString stringWithUTF8String:str_record_video_path.c_str()] mergeFilePath:[NSString stringWithUTF8String:CRecordTask::GetInstance()->m_strSaveFilePath.c_str()] beginSaveTime:S_LN_SAVE_VIDEO_TIME];
            [MobClick endEvent:[NSString stringWithUTF8String:KS_SAVE_TIME]];
            
            S_LN_SAVE_VIDEO_TIME = time(NULL) - S_LN_SAVE_VIDEO_TIME;
            
            int n_saved_time = 0;
            KwConfig::GetConfigureInstance()->GetConfigIntValue(SECTION_COMMENT, NUM_SAVED_TIMES, n_saved_time);
            KwConfig::GetConfigureInstance()->SetConfigIntValue(SECTION_COMMENT, NUM_SAVED_TIMES, ++n_saved_time);
            
            //SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveFinish, E_SAVE_SUCCESS, S_LN_SAVE_VIDEO_TIME);
            
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
        KS_BLOCK_RUN_THREAD();
    }else {
        std::string str_file_name = CRecordTask::GetInstance()->m_strAccompanyPath;
        str_file_name = KwTools::Dir::GetFileName(str_file_name);
        int n_index = str_file_name.rfind(".");
        str_file_name = str_file_name.substr(0, n_index);
        std::string str_record_audio_path = [KSRecordTempPath getRecordTempPath] + "/" + str_file_name + "Record.wav";
        std::string str_merge_file_path = [KSRecordTempPath getRecordTempPath] + "/" + str_file_name + "Mix.wav";
        std::string str_convert_m4a_path = [KSRecordTempPath getRecordTempPath] + "/" + str_file_name + ".m4a";
        std::string str_record_video_path = [KSRecordTempPath getRecordTempPath] + "/" + str_file_name + ".mp4";
        
        KS_BLOCK_DECLARE{
            [MobClick beginEvent:[NSString stringWithUTF8String:KS_SAVE_TIME]];
            BOOL b_ret = [KSAudioMixer mixAudio:[NSString stringWithUTF8String:CRecordTask::GetInstance()->m_strAccompanyPath.c_str()] andAudio:[NSString stringWithUTF8String:str_record_audio_path.c_str()] output:[NSString stringWithUTF8String:str_merge_file_path.c_str()]];
            if (YES != b_ret) {
                S_LN_SAVE_VIDEO_TIME = time(NULL) - S_LN_SAVE_VIDEO_TIME;
                SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveFinish, E_SAVE_FAIL, S_LN_SAVE_VIDEO_TIME * 1000);
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                return;
            }
            
            if (!CAudioWaveToAAC::ConvertProcess((CFURLRef)[NSURL fileURLWithPath:[NSString stringWithUTF8String:str_merge_file_path.c_str()]], (CFURLRef)[NSURL fileURLWithPath:[NSString stringWithUTF8String:str_convert_m4a_path.c_str()]], 48000)) {
                
                S_LN_SAVE_VIDEO_TIME = time(NULL) - S_LN_SAVE_VIDEO_TIME;
                SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveFinish, E_SAVE_FAIL, S_LN_SAVE_VIDEO_TIME * 1000);

                [MobClick endEvent:[NSString stringWithUTF8String:KS_SAVE_TIME]];
                
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                return;
            }
            
            [KSVideoMerge mergeAVFile:[NSString stringWithUTF8String:str_convert_m4a_path.c_str()] videoFilePath:[NSString stringWithUTF8String:str_record_video_path.c_str()] mergeFilePath:[NSString stringWithUTF8String:CRecordTask::GetInstance()->m_strSaveFilePath.c_str()] beginSaveTime:S_LN_SAVE_VIDEO_TIME];
            
            [MobClick endEvent:[NSString stringWithUTF8String:KS_SAVE_TIME]];
            S_LN_SAVE_VIDEO_TIME = time(NULL) - S_LN_SAVE_VIDEO_TIME;
            
            int n_saved_time = 0;
            KwConfig::GetConfigureInstance()->GetConfigIntValue(SECTION_COMMENT, NUM_SAVED_TIMES, n_saved_time);
            KwConfig::GetConfigureInstance()->SetConfigIntValue(SECTION_COMMENT, NUM_SAVED_TIMES, ++n_saved_time);
            
            //SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveFinish, E_SAVE_SUCCESS, S_LN_SAVE_VIDEO_TIME);
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
        KS_BLOCK_RUN_THREAD();
    }
    
    return true;
}
