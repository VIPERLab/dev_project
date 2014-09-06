//
//  StreamFile.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CStreamFile_h
#define KwSing_CStreamFile_h

#ifndef KwSing_CLock_h
#include "Lock.h"
#endif

#include <stdio.h>
#include <string>
#include <pthread.h>

#define AUTO_FILE_SIZE ((unsigned int)(-1))

class CStreamFile{
public:
    CStreamFile();
    virtual ~CStreamFile();
    
public:
    bool OpenFile(const char* str_file_path, unsigned int un_file_size = AUTO_FILE_SIZE);
    bool CloseFile();
    unsigned int Seek(int n_offset, int flag);
    unsigned int Read(void* p_buffer, unsigned int un_size);
    
public:
    const char* GetFilePath() const;
    
    unsigned int GetFileSize() const;
    unsigned int SetFileSize(unsigned int un_size);
    
    unsigned int GetFilePos() const;
    
    bool SetBuffering(bool b_buffering, unsigned int un_data_available = AUTO_FILE_SIZE);
    
    bool SetAvailableDataSize(unsigned int un_data_available);
    unsigned int GetAvailableDataSize() const;
    
    bool IsBufferReady(unsigned int un_data_require) const;
    
    float GetBufferingRate(unsigned int un_data_require) const;
    
    float GetBufferingProgress() const;
    
public:
    virtual bool IsOpen() const;
    virtual bool IsEndOfFile() const;
    virtual bool IsBuffering() const;
    virtual bool IsBufferingFailed() const;
    virtual int GetErrCode() const;
    
protected:
    std::string m_strFilePath;
    FILE* m_pFile;
    unsigned int m_unFileSize;
    unsigned int m_unDataAvailable;
    
    bool m_bBuffering;
    bool m_bBufferFailed;
    int m_nErrCode;
    mutable KwTools::CLock m_Lock;
};

#endif
