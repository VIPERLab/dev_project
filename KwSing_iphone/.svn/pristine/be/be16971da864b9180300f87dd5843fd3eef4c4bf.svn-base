//
//  WaveFileMerge.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-25.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "WaveFileMerge.h"
#import<Foundation/Foundation.h>
#include "freeverb.h"
#include "MessageManager.h"
#include "IMediaSaveProcessObserver.h"

#define MERGE_BUFFER_LEN (88200)

int CWaveFileMerge::GetWaveDataLength(FILE* p_file){
    if (NULL == p_file) {
        return 0;
    }
    
    uint8_t head[44];
    fread(head, sizeof(uint8_t), 44, p_file);
    uint32_t* un_value_fllr = (uint32_t*)(head + 40);
    uint32_t un_size_fllr = *un_value_fllr;
    uint8_t fllr[un_size_fllr];
    fread(fllr, sizeof(uint8_t), un_size_fllr, p_file);
    
    uint8_t data[4];
    fread(data, sizeof(uint8_t), 4, p_file);
    
    uint8_t data_size[4];
    fread(data_size, sizeof(uint8_t), 4, p_file);
    uint32_t* p_data_size = (uint32_t*)data_size;
    uint32_t un_data_size = *p_data_size;
    
    return un_data_size / sizeof(short);
}

int CWaveFileMerge::GetRawDataLength(FILE* p_file){
    fseek(p_file, 0, SEEK_END);
    int n_file_len = ftell(p_file);
    fseek(p_file, 0, SEEK_SET);
    
    return n_file_len / sizeof(short);
}

bool CWaveFileMerge::MergeWaveFile(std::string str_accompany_file, std::string str_merge_file, float f_accompany_volume, float f_wav_volume){
    FILE* p_file_merge = NULL;
    FILE* p_file_accompany = NULL;
    
    short* data_record = new short[MERGE_BUFFER_LEN];
    short* data_accompany = new short[MERGE_BUFFER_LEN];
    
    int n_record_data_left(0);
    int n_record_data_len(0);
    int n_accompany_data_left(0);
    int n_accompany_data_len(0);
    
    if (NULL == data_record || NULL == data_accompany) {
        if (NULL != data_record) {
            delete [] data_record;
            data_record = NULL;
        }
        if (NULL != data_accompany) {
            delete [] data_accompany;
            data_accompany = NULL;
        }
        
        return false;
    }
    
    if (NULL == (p_file_merge = fopen(str_merge_file.c_str(), "r+b")) || (0 == (n_record_data_len = GetWaveDataLength(p_file_merge)))) {
        if (NULL != data_record) {
            delete [] data_record;
            data_record = NULL;
        }
        if (NULL != data_accompany) {
            delete [] data_accompany;
            data_accompany = NULL;
        }
        
        if (p_file_merge) {
            fclose(p_file_merge);
            p_file_merge = NULL;
        }
        
        return false;
    }
    
    if (NULL == (p_file_accompany = fopen(str_accompany_file.c_str(), "rb")) || (0 == (n_accompany_data_len = GetRawDataLength(p_file_accompany)))) {
        if (NULL != data_record) {
            delete [] data_record;
            data_record = NULL;
        }
        if (NULL != data_accompany) {
            delete [] data_accompany;
            data_accompany = NULL;
        }
        
        if (p_file_accompany) {
            fclose(p_file_accompany);
            p_file_accompany = NULL;
        }
        if (p_file_merge) {
            fclose(p_file_merge);
            p_file_merge = NULL;
        }
        
        return false;
    }
    
    n_record_data_left = n_record_data_len;
    n_accompany_data_left = n_accompany_data_len;
    
    while ((0 < n_accompany_data_left) && (0 < n_record_data_left)) {
        int n_read_buf_size = n_accompany_data_left < MERGE_BUFFER_LEN ? n_accompany_data_left : MERGE_BUFFER_LEN;
        n_read_buf_size = n_read_buf_size < n_record_data_left ? n_read_buf_size : n_record_data_left;
        if (n_read_buf_size != fread(data_record, sizeof(short), n_read_buf_size, p_file_merge)) {
            if (NULL != data_record) {
                delete [] data_record;
                data_record = NULL;
            }
            if (NULL != data_accompany) {
                delete [] data_accompany;
                data_accompany = NULL;
            }
            
            if (p_file_accompany) {
                fclose(p_file_accompany);
                p_file_accompany = NULL;
            }
            if (p_file_merge) {
                fclose(p_file_merge);
                p_file_merge = NULL;
            }
            
            return false;
        }
        
        if (n_read_buf_size != fread(data_accompany, sizeof(short), n_read_buf_size, p_file_accompany)) {
            if (NULL != data_record) {
                delete [] data_record;
                data_record = NULL;
            }
            if (NULL != data_accompany) {
                delete [] data_accompany;
                data_accompany = NULL;
            }
            
            if (p_file_accompany) {
                fclose(p_file_accompany);
                p_file_accompany = NULL;
            }
            if (p_file_merge) {
                fclose(p_file_merge);
                p_file_merge = NULL;
            }
            
            return false;
        }
        
        n_record_data_left -= n_read_buf_size;
        n_accompany_data_left -= n_read_buf_size;
        
//        if (0 < n_record_data_left && 0 == n_record_data_left % 10) {
            SYN_NOTIFY(OBSERVER_ID_MEDIA_SAVE_PROGRESS, IMediaSaveProcessObserver::SaveProgressChanged, 0.3 + 0.4 * (n_record_data_len - n_record_data_left) / n_record_data_len);
//        }
        
        for (int n_index = 0; n_index < n_read_buf_size; ++n_index) {
            int n_merge_value = ((int)data_accompany[n_index] * f_accompany_volume + ((int)data_record[n_index] * f_wav_volume));
            n_merge_value = n_merge_value > 32767 ? 32767 : n_merge_value;
            n_merge_value = n_merge_value < -32767 ? -32767 : n_merge_value;
            data_record[n_index] = (short)n_merge_value;
        }
        
        if (0 != fseek(p_file_merge, sizeof(short) * (-n_read_buf_size), SEEK_CUR)) {
            if (NULL != data_record) {
                delete [] data_record;
                data_record = NULL;
            }
            if (NULL != data_accompany) {
                delete [] data_accompany;
                data_accompany = NULL;
            }
            
            if (p_file_accompany) {
                fclose(p_file_accompany);
                p_file_accompany = NULL;
            }
            if (p_file_merge) {
                fclose(p_file_merge);
                p_file_merge = NULL;
            }
            
            return false;
        }
        
        if (n_read_buf_size != fwrite(data_record, sizeof(short), n_read_buf_size, p_file_merge)) {
            if (NULL != data_record) {
                delete [] data_record;
                data_record = NULL;
            }
            if (NULL != data_accompany) {
                delete [] data_accompany;
                data_accompany = NULL;
            }
            
            if (p_file_accompany) {
                fclose(p_file_accompany);
                p_file_accompany = NULL;
            }
            if (p_file_merge) {
                fclose(p_file_merge);
                p_file_merge = NULL;
            }
            
            return false;
        }
    }
    
    if (NULL != data_record) {
        delete [] data_record;
        data_record = NULL;
    }
    if (NULL != data_accompany) {
        delete [] data_accompany;
        data_accompany = NULL;
    }
    
    if (p_file_accompany) {
        fclose(p_file_accompany);
        p_file_accompany = NULL;
    }
    if (p_file_merge) {
        fclose(p_file_merge);
        p_file_merge = NULL;
    }
    
    return true;
}

