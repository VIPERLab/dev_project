//
//  PcmResample.mm
//  KwSing
//
//  Created by 单 永杰 on 13-1-15.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#include "PcmResample.h"
#include "samplerate.h"
#include "KwDir.h"
#include <iostream>

bool CPcmResample::ResampleProcess(const char *str_file_path, const int n_src_sample_rate, const int n_dest_sample_rate){
    if (n_src_sample_rate == n_dest_sample_rate) {
        return true;
    }
    
    std::string str_result_file_path = str_file_path;
    int n_dot_pos = str_result_file_path.rfind(".");
    str_result_file_path = str_result_file_path.substr(0, n_dot_pos);
    str_result_file_path += "resample.wav";
    
    FILE* p_src_file = fopen(str_file_path, "rb");
    if (NULL == p_src_file) {
        return false;
    }
    FILE* p_dest_file = fopen(str_result_file_path.c_str(), "wb+");
    if (NULL == p_dest_file) {
        fclose(p_src_file);
        p_src_file = NULL;
        
        return false;
    }
    
    unsigned long un_file_byte_len = 0;
    fseek(p_src_file, 0, SEEK_END);
    un_file_byte_len = ftell(p_src_file);
    fseek(p_src_file, 0, SEEK_SET);

    const int n_buf_len = 1024;
    int n_buf_frame_num = n_buf_len / (2 * 2);
    
    int n_error = 0;
    SRC_STATE* src_state_left = src_new(SRC_LINEAR, 1, &n_error);
    if (NULL == src_state_left) {
        fclose(p_src_file);
        p_src_file = NULL;
        
        fclose(p_dest_file);
        p_dest_file = NULL;
        
        return false;
    }
    SRC_STATE* src_state_right = src_new(SRC_LINEAR, 1, &n_error);
    if (NULL == src_state_right) {
        fclose(p_src_file);
        p_src_file = NULL;
        
        fclose(p_dest_file);
        p_dest_file = NULL;
        
        src_delete(src_state_left);
        src_state_left = NULL;
        
        return false;
    }
    
    short* p_buf_left = new short[n_buf_frame_num];
    short* p_buf_right = new short[n_buf_frame_num];
    char* p_buf = new char[n_buf_len];
    
    unsigned long un_left_byte_len = un_file_byte_len;
    double f_rate = n_dest_sample_rate / (double)n_src_sample_rate;
    
    SRC_DATA src_data_left;
    float* buf_input_left = new float[n_buf_frame_num];
    float* buf_output_left = new float[f_rate > 1 ? (long(n_buf_frame_num * f_rate + 100)) : (n_buf_frame_num)];
    src_data_left.end_of_input = 0;
    src_data_left.input_frames = 0;
    src_data_left.src_ratio = f_rate;
    src_data_left.data_in = buf_input_left;
    src_data_left.data_out = buf_output_left;
    src_data_left.output_frames = n_buf_len;
    
    SRC_DATA src_data_right;
    float* buf_input_right = new float[n_buf_frame_num];
    float* buf_output_right = new float[f_rate > 1 ? (long(n_buf_frame_num * f_rate + 100)) : (n_buf_frame_num)];
    src_data_right.end_of_input = 0;
    src_data_right.input_frames = 0;
    src_data_right.src_ratio = f_rate;
    src_data_right.data_in = buf_input_right;
    src_data_right.data_out = buf_output_right;
    src_data_right.output_frames = n_buf_len;
    
    float* buf_out_left_and_right = new float[2 * (f_rate > 1 ? (long(n_buf_frame_num * f_rate + 100)) : (n_buf_frame_num))];
    
    while (0 < un_left_byte_len) {
        memset(p_buf_left, 0, sizeof(short) * n_buf_frame_num);
        memset(p_buf_right, 0, sizeof(short) * n_buf_frame_num);
        memset(buf_out_left_and_right, 0, sizeof(float) * 2 * (f_rate > 1 ? (long(n_buf_frame_num * f_rate + 100)) : (n_buf_frame_num)));
        
        int n_len = un_left_byte_len > n_buf_len ? n_buf_len : un_left_byte_len;
        src_data_left.end_of_input = un_left_byte_len > n_buf_len ? false : true;
        src_data_right.end_of_input = un_left_byte_len > n_buf_len ? false : true;
        
        fread(p_buf, sizeof(char), n_len, p_src_file);
        short* p_buf_copy = (short*)p_buf;
        
        int n_cur_pos = 0;
        
        for (int n_index = 0; n_index < n_len / 2; n_index += 2) {
            int k = n_cur_pos++;
            p_buf_left[k] = p_buf_copy[n_index];
            p_buf_right[k] = p_buf_copy[n_index + 1];
        }
        
        src_data_left.input_frames = n_cur_pos;
        src_short_to_float_array(p_buf_left, buf_input_left, src_data_left.input_frames);
        if (src_process(src_state_left, &src_data_left)) {
            fclose(p_src_file);
            p_src_file = NULL;
            
            fclose(p_dest_file);
            p_dest_file = NULL;
            
            src_delete(src_state_left);
            src_state_left = NULL;
            
            src_delete(src_state_right);
            src_state_right = NULL;
            
            delete [] p_buf_left;
            p_buf_left = NULL;
            
            delete [] p_buf_right;
            p_buf_right = NULL;
            
            delete [] p_buf;
            p_buf = NULL;
            
            delete [] buf_input_left;
            buf_input_left = NULL;
            
            delete [] buf_input_right;
            buf_input_right = NULL;
            
            delete [] buf_output_left;
            buf_output_left = NULL;
            
            delete [] buf_output_right;
            buf_output_right = NULL;
            
            delete [] buf_out_left_and_right;
            buf_out_left_and_right = NULL;
            
            return false;
        }
        src_data_right.input_frames = n_cur_pos;
        src_short_to_float_array(p_buf_right, buf_input_right, src_data_right.input_frames);
        if (src_process(src_state_right, &src_data_right)) {
            fclose(p_src_file);
            p_src_file = NULL;
            
            fclose(p_dest_file);
            p_dest_file = NULL;
            
            src_delete(src_state_left);
            src_state_left = NULL;
            
            src_delete(src_state_right);
            src_state_right = NULL;
            
            delete [] p_buf_left;
            p_buf_left = NULL;
            
            delete [] p_buf_right;
            p_buf_right = NULL;
            
            delete [] p_buf;
            p_buf = NULL;
            
            delete [] buf_input_left;
            buf_input_left = NULL;
            
            delete [] buf_input_right;
            buf_input_right = NULL;
            
            delete [] buf_output_left;
            buf_output_left = NULL;
            
            delete [] buf_output_right;
            buf_output_right = NULL;
            
            delete [] buf_out_left_and_right;
            buf_out_left_and_right = NULL;
            
            return false;
        }
        
        int n_pos = 0;
        short buf_result[2 * src_data_right.output_frames_gen];
        memset(buf_result, 0, 2 * src_data_right.output_frames_gen);
        for (int n_index = 0; n_index < src_data_right.output_frames_gen; ++n_index) {
            buf_out_left_and_right[n_pos++] = buf_output_left[n_index];
            buf_out_left_and_right[n_pos++] = buf_output_right[n_index];
        }
        
        src_float_to_short_array(buf_out_left_and_right, buf_result, 2 * src_data_right.output_frames_gen);
        
        fwrite(buf_result, sizeof(short), 2 * src_data_right.output_frames_gen, p_dest_file);
        
        un_left_byte_len -= n_len;
    }
    
    fclose(p_src_file);
    p_src_file = NULL;
    
    fclose(p_dest_file);
    p_dest_file = NULL;
    
    src_delete(src_state_left);
    src_state_left = NULL;
    
    src_delete(src_state_right);
    src_state_right = NULL;
    
    delete [] p_buf_left;
    p_buf_left = NULL;
    
    delete [] p_buf_right;
    p_buf_right = NULL;
    
    delete [] p_buf;
    p_buf = NULL;
    
    delete [] buf_input_left;
    buf_input_left = NULL;
    
    delete [] buf_input_right;
    buf_input_right = NULL;
    
    delete [] buf_output_left;
    buf_output_left = NULL;
    
    delete [] buf_output_right;
    buf_output_right = NULL;
    
    delete [] buf_out_left_and_right;
    buf_out_left_and_right = NULL;
    
    if(KwTools::Dir::DeleteDir(str_file_path)){
        if(KwTools::Dir::MoveFile(str_result_file_path, str_file_path)){
            return true;
        }
        else{
            return false;
        }
    }else{
        return false;
    }
}