//
//  SaveAudio.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-30.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "SaveAudio.h"
#include "WaveFileMerge.h"
#include "AudioWaveToAAC.h"
#include "MessageManager.h"
#include "KSRecordTempPath.h"
#include "IMediaSaveProcessObserver.h"
#include "KwDir.h"
#include "AudioFormatConvert.h"
#include "FreeSingFileEchoProcess.h"
#include "KSAACDecodInterface.h"
#include "KwConfigElements.h"
#include "KwConfig.h"
#import "KSAudioLength.h"
#include "RecordTask.h"
#include "MobClick.h"
#include "KwUMengElement.h"
#import "KSAudioMixer.h"

static long S_LN_SAVE_TIME = 0;

extern void ThreadStateInitalize();

bool CSaveAudio::SaveFile(){
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    S_LN_SAVE_TIME = time(NULL);
    
    [MobClick beginEvent:[NSString stringWithUTF8String:KS_SAVE_TIME]];
    
    if (CRecordTask::GetInstance()->m_bIsFreeSing) {
        std::string str_record_path = [KSRecordTempPath getRecordTempPath] + "/FreeSing.wav";
        KS_BLOCK_DECLARE{
            if(CAudioWaveToAAC::ConvertProcess((CFURLRef)[NSURL fileURLWithPath:[NSString stringWithUTF8String:str_record_path.c_str()]], (CFURLRef)[NSURL fileURLWithPath:[NSString stringWithUTF8String:CRecordTask::GetInstance()->m_strSaveFilePath.c_str()]], 48000)){
                
                SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveProgressChanged, 1.0);
                
                S_LN_SAVE_TIME = time(NULL) - S_LN_SAVE_TIME;
                SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveFinish, E_SAVE_SUCCESS, S_LN_SAVE_TIME);
            }
            
            [MobClick endEvent:[NSString stringWithUTF8String:KS_SAVE_TIME]];
            
            int n_saved_time = 0;
            KwConfig::GetConfigureInstance()->GetConfigIntValue(SECTION_COMMENT, NUM_SAVED_TIMES, n_saved_time);
            KwConfig::GetConfigureInstance()->SetConfigIntValue(SECTION_COMMENT, NUM_SAVED_TIMES, ++n_saved_time);
            
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
        KS_BLOCK_RUN_THREAD();
    }else {
        std::string str_file_name = CRecordTask::GetInstance()->m_strAccompanyPath;
        str_file_name = KwTools::Dir::GetFileName(str_file_name);
        int n_index = str_file_name.rfind(".");
        str_file_name = str_file_name.substr(0, n_index);
        std::string str_record_file_path = [KSRecordTempPath getRecordTempPath] + "/" + str_file_name + "Record.wav";
        std::string str_merge_file_path = [KSRecordTempPath getRecordTempPath] + "/" + str_file_name + "Mix.wav";

        KS_BLOCK_DECLARE{
            BOOL b_ret = [KSAudioMixer mixAudio:[NSString stringWithUTF8String:CRecordTask::GetInstance()->m_strAccompanyPath.c_str()] andAudio:[NSString stringWithUTF8String:str_record_file_path.c_str()] output:[NSString stringWithUTF8String:str_merge_file_path.c_str()]];
            if (YES != b_ret) {
                S_LN_SAVE_TIME = time(NULL) - S_LN_SAVE_TIME;
                SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveFinish, E_SAVE_FAIL, S_LN_SAVE_TIME * 1000);
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                return;
            }
            
            b_ret = CAudioWaveToAAC::ConvertProcess((CFURLRef)[NSURL fileURLWithPath:[NSString stringWithUTF8String:str_merge_file_path.c_str()]], (CFURLRef)[NSURL fileURLWithPath:[NSString stringWithUTF8String:CRecordTask::GetInstance()->m_strSaveFilePath.c_str()]], 48000);
            if (YES != b_ret) {
                S_LN_SAVE_TIME = time(NULL) - S_LN_SAVE_TIME;
                SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveFinish, E_SAVE_FAIL, S_LN_SAVE_TIME * 1000);
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                return;
            }
            
            S_LN_SAVE_TIME = time(NULL) - S_LN_SAVE_TIME;
            SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveFinish, E_SAVE_SUCCESS, S_LN_SAVE_TIME * 1000);
            
            int n_saved_time = 0;
            KwConfig::GetConfigureInstance()->GetConfigIntValue(SECTION_COMMENT, NUM_SAVED_TIMES, n_saved_time);
            KwConfig::GetConfigureInstance()->SetConfigIntValue(SECTION_COMMENT, NUM_SAVED_TIMES, ++n_saved_time);
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
        KS_BLOCK_RUN_THREAD();
    }
    
    return true;
}
