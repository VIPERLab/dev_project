//
//  FreeSingFileEchoProcess.mm
//  KwSing
//
//  Created by 永杰 单 on 12-9-2.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "FreeSingFileEchoProcess.h"
#include "WaveFileMerge.h"
#include "freeverb.h"
#include "MessageManager.h"
#include "IMediaSaveProcessObserver.h"

#define ECHO_PROCESS_BUF_LEN 88200

void CFreeSingFileEchoProcess::EchoProcess(std::string str_merge_file, EAudioEchoEffect echo_effect){
    
    if (NO_EFFECT == echo_effect) {
        return;
    }
    
    FILE* p_file_merge = NULL;
    int n_record_data_len(0);
    if(NULL == (p_file_merge = fopen(str_merge_file.c_str(), "r+b")) || (0 == (n_record_data_len = CWaveFileMerge::GetWaveDataLength(p_file_merge)))){
        if (p_file_merge) {
            fclose(p_file_merge);
            p_file_merge = NULL;
        }
        return;
    }
    
    int n_record_data_left = n_record_data_len;
    short* data_record = new short[ECHO_PROCESS_BUF_LEN];
    RevSettings echo_para = arry_echo_para[echo_effect];
    freeverb* p_verb = new freeverb(&echo_para);
    
    while (0 < n_record_data_left) {
        int n_read_buf_size = n_record_data_left < ECHO_PROCESS_BUF_LEN ? n_record_data_left : ECHO_PROCESS_BUF_LEN;
        if (n_read_buf_size != fread(data_record, sizeof(short), n_read_buf_size, p_file_merge)) {
            if (NULL != data_record) {
                delete [] data_record;
                data_record = NULL;
            }
            
            if (p_file_merge) {
                fclose(p_file_merge);
                p_file_merge = NULL;
            }
            
            return;
        }
        
        n_record_data_left -= n_read_buf_size;
        
        //Echo Process
        p_verb->process(44100, 1, 2, data_record, n_read_buf_size, false);
        
        if (0 < n_record_data_left && 0 == ((n_record_data_len - n_record_data_left) % 10)) {
            SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveProgressChanged, 0.5 * (n_record_data_len - n_record_data_left) / n_record_data_len);
        }
        
        if (0 != fseek(p_file_merge, sizeof(short) * (-n_read_buf_size), SEEK_CUR)) {
            if (NULL != data_record) {
                delete [] data_record;
                data_record = NULL;
            }
            
            if (p_file_merge) {
                fclose(p_file_merge);
                p_file_merge = NULL;
            }
            
            return;
        }
        
        if (n_read_buf_size != fwrite(data_record, sizeof(short), n_read_buf_size, p_file_merge)) {
            if (NULL != data_record) {
                delete [] data_record;
                data_record = NULL;
            }
            
            if (p_file_merge) {
                fclose(p_file_merge);
                p_file_merge = NULL;
            }
            
            return;
        }
    }
    
    if (NULL != data_record) {
        delete [] data_record;
        data_record = NULL;
    }

    if (p_file_merge) {
        fclose(p_file_merge);
        p_file_merge = NULL;
    }
}
