//
//  StreamFile.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "StreamFile.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <algorithm>
#include "AutoLock.h"
#include "StreamFile.h"
#include "EAudioStreamErrorCode.h"

unsigned int get_file_size(FILE* fp_file){
    long ln_file_size = -1;
    if (fp_file) {
        long ln_cursor = ftell(fp_file);
        if (0 == fseek(fp_file, 0, SEEK_END)) {
            ln_file_size = ftell(fp_file);
        }
        fseek(fp_file, ln_cursor, SEEK_SET);
    }
    
    return ln_file_size;
}

CStreamFile::CStreamFile() : m_pFile(NULL), m_unFileSize(0), m_unDataAvailable(0), m_bBuffering(false), m_bBufferFailed(false), m_nErrCode(0){
}

CStreamFile::~CStreamFile(){
    CloseFile();
}

bool CStreamFile::OpenFile(const char *str_file_path, unsigned int un_file_size){
    KwTools::CAutoLock auto_lock(m_Lock);
    if (NULL != m_pFile) {
        CloseFile();
    }
    
    assert(NULL != str_file_path);
    
    m_pFile = fopen(str_file_path, "rb");
    if (NULL == m_pFile) {
        return false;
    }
    
    setvbuf(m_pFile, NULL, _IONBF, 0);
    m_strFilePath = str_file_path;
    m_unFileSize = (AUTO_FILE_SIZE != un_file_size) ? un_file_size : get_file_size(m_pFile);
    
    m_bBuffering = false;
    m_bBufferFailed = false;
    m_unDataAvailable = std::min(m_unFileSize, (unsigned int) get_file_size(m_pFile));
    assert(-1 != m_unDataAvailable);
    
    m_nErrCode = 0;
    
    return true;
}

bool CStreamFile::CloseFile(){
    KwTools::CAutoLock auto_lock(m_Lock);
    if(NULL != m_pFile){
        fclose(m_pFile);
        m_pFile = NULL;
    }
    m_unDataAvailable = 0;
    m_unFileSize = 0;
    m_strFilePath.clear();
    m_bBuffering = false;
    m_bBufferFailed = false;
    m_nErrCode = 0;
    
    return true;
}

unsigned int CStreamFile::Seek(int n_offset, int flag){
    KwTools::CAutoLock auto_lock(m_Lock);
    unsigned int un_cur_pos = ftell(m_pFile);
    switch (flag) {
        case SEEK_SET:
        {
            if (n_offset > m_unDataAvailable) {
                return 1;
            }
            if (0 != fseek(m_pFile, n_offset, SEEK_SET)) {
                return 1;
            }
            break;
        }
        case SEEK_CUR:
        {
            if ((un_cur_pos + n_offset) > m_unDataAvailable) {
                return 1;
            }
            if (0 != fseek(m_pFile, n_offset, SEEK_CUR)) {
                return 1;
            }
            break;
        }
        case SEEK_END:
        {
            if (AUTO_FILE_SIZE == m_unFileSize) {
                if (IsBuffering()) {
                    return 1;
                }else {
                    if (0 != fseek(m_pFile, n_offset, SEEK_END)) {
                        return 1;
                    }
                }
            }else {
                if ((m_unFileSize - n_offset) > m_unDataAvailable) {
                    return 1;
                }else {
                    if (0 != fseek(m_pFile, n_offset, SEEK_END)) {
                        return 1;
                    }
                }
            }
            break;
        }
        default:
        {
            assert(false);
            return 1;
        }
    }
    return 0;
}

unsigned int CStreamFile::Read(void *p_buffer, unsigned int un_size){
    if (0 == un_size) {
        return 0;
    }
    
    assert(NULL != p_buffer);
    
    KwTools::CAutoLock auto_lock(m_Lock);
    
    if(!IsOpen() || IsEndOfFile()){
        return 0;
    }
    
    unsigned int un_cur_pos = (unsigned int) ftell(m_pFile);
    unsigned int un_to_read = std::min((int) un_size, (int)(m_unDataAvailable - un_cur_pos));
    fflush(m_pFile);
    
    unsigned int un_read = (unsigned int) fread(p_buffer, 1, un_to_read, m_pFile);
    if((un_read < un_to_read) && !IsEndOfFile())
        m_nErrCode = ferror(m_pFile);
    
    return un_read;
}

const char* CStreamFile::GetFilePath()const{
    KwTools::CAutoLock auto_lock(m_Lock);
    return m_strFilePath.c_str();
}

unsigned int CStreamFile::SetFileSize(unsigned int un_size){
    KwTools::CAutoLock auto_lock(m_Lock);
    assert(m_bBuffering);
    return (m_unFileSize = un_size);
}

unsigned int CStreamFile::GetFileSize()const{
    KwTools::CAutoLock auto_lock(m_Lock);
    return m_unFileSize;
}

unsigned int CStreamFile::GetFilePos()const{
    KwTools::CAutoLock auto_lock(m_Lock);
    return ((unsigned int)ftell(m_pFile));
}

bool CStreamFile::SetBuffering(bool b_buffering, unsigned int un_data_available){
    KwTools::CAutoLock auto_lock(m_Lock);
    if (b_buffering) {
        SetAvailableDataSize(un_data_available);
        m_bBufferFailed = false;
    }else {
        if (AUTO_FILE_SIZE == m_unFileSize) {
            m_unFileSize = (unsigned int)get_file_size(m_pFile);
        }
        
        if (AUTO_FILE_SIZE == un_data_available) {
            m_unDataAvailable = m_unFileSize;
        }else {
            m_unDataAvailable = un_data_available;
        }
        
        if (m_bBuffering && (m_unDataAvailable < m_unFileSize)) {
            m_bBufferFailed = true;
        }else {
            m_bBufferFailed = false;
        }
    }
    
    m_bBuffering = b_buffering;
    
    return true;
}

bool CStreamFile::SetAvailableDataSize(unsigned int un_data_available){
    KwTools::CAutoLock auto_lock(m_Lock);
    assert(un_data_available <= m_unFileSize);
    m_unDataAvailable = un_data_available;
    
    return true;
}

unsigned int CStreamFile::GetAvailableDataSize()const{
    KwTools::CAutoLock auto_lock(m_Lock);
    return m_unDataAvailable;
}

bool CStreamFile::IsBufferReady(unsigned int un_data_require)const{
    KwTools::CAutoLock auto_lock(m_Lock);
    if (!m_pFile) {
        return false;
    }
    
    if (m_unDataAvailable >= m_unFileSize) {
        return true;
    }
    
    unsigned int un_cursor = (unsigned int)ftell(m_pFile);
    return (bool)(m_unDataAvailable - un_cursor >= un_data_require);
}


float CStreamFile::GetBufferingRate(unsigned int un_data_require)const{
    KwTools::CAutoLock auto_lock(m_Lock);
    if ((!m_unDataAvailable) || (!m_unFileSize)) {
        return 0.0;
    }
    
    unsigned int un_cursor(0);
    if (m_pFile) {
        un_cursor = (unsigned int)ftell(m_pFile);
    }
    float f_rate = (float)((m_unDataAvailable - un_cursor) / un_data_require);
    if ((0 != un_cursor) && (1.0 > f_rate)) {
        f_rate += 0.5;
    }
    
    if (1.0 < f_rate) {
        f_rate = 1.0;
    }
    
    return f_rate;
}

float CStreamFile::GetBufferingProgress()const{
    if (0 >= (int)m_unFileSize) {
        return 0.f;
    }
    
    return (double)m_unDataAvailable / m_unFileSize;
}

bool CStreamFile::IsOpen()const{
    KwTools::CAutoLock auto_lock(m_Lock);
    
    return (NULL != m_pFile);
}

bool CStreamFile::IsEndOfFile()const{
    KwTools::CAutoLock auto_lock(m_Lock);
    
    if (!IsOpen()) {
        assert(false);
        return true;
    }
    
    unsigned int un_cursor = (unsigned int)ftell(m_pFile);
    bool b_eof = feof(m_pFile);
    
    assert(m_unDataAvailable <= m_unFileSize);
    if (m_bBuffering) {
        return false;
    }else {
        assert(AUTO_FILE_SIZE != m_unFileSize);
        if (b_eof && (un_cursor < m_unFileSize)) {
            assert(false);
        }
        
        return b_eof || (un_cursor >= m_unDataAvailable);
    }
}

bool CStreamFile::IsBuffering()const{
    KwTools::CAutoLock auto_lock(m_Lock);
    
    return m_bBuffering;
}

bool CStreamFile::IsBufferingFailed()const{
    KwTools::CAutoLock auto_lock(m_Lock);
    
    return m_bBufferFailed;
}

int CStreamFile::GetErrCode()const{
    KwTools::CAutoLock auto_lock(m_Lock);
    
    return m_nErrCode;
}