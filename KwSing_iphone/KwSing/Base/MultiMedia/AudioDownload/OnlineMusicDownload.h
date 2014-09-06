//
//  OnlineMusicDownload.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_COnlineMusicDownload_h
#define KwSing_COnlineMusicDownload_h

#include <string>
#include "SongInfo.h"
#include "IHttpNotify.h"
#include "HttpRequest.h"

enum DownloadStatus {
    Status_Null = 0,
    Status_Downing,
    Status_Finish,
    Status_Pause
};

class CDownTask{
public:
    DownloadStatus m_DownStatus;
    CHttpRequest* m_pHttpRequest;
    MUSIC_RESOURCE m_MusicResource;
    
    CDownTask(){
        m_DownStatus = Status_Null;
        m_pHttpRequest = NULL;
    }
    
    ~CDownTask(){
        if (m_pHttpRequest) {
            delete m_pHttpRequest;
            m_pHttpRequest = NULL;
        }
        m_DownStatus = Status_Null;
    }
};

class COnlineMusicDownload : public IHttpRequestNotify{
public:
    static COnlineMusicDownload* GetInstance();
    
    CDownTask* GetCurrentTask()const;
    bool StartDownload(MUSIC_RESOURCE* music_resource);
    bool StopDownload();
    
    bool IsDowning()const;
    bool IsTaskStarted()const;
    bool IsTaskStoped()const;
    bool IsTaskSuccessed()const;
    
    std::string GetDownFilePath()const;
    uint GetDownFileSize()const;
    uint GetCurFileSize()const;
    MUSIC_FORMAT GetMusicFormat()const;
    UInt32 GetMusicBitRate()const;
    uint GetMusicDuration()const;
    
public:
    virtual void IHttpNotify_DownStart(CHttpRequest* pRequest,long lTotalSize);
    virtual void IHttpNotify_Process(CHttpRequest* pRequest,long lTotalSize,long lCurrentSize,long lSpeed);
    virtual void IHttpNotify_Stop(CHttpRequest* pRequest,BOOL bSuccess);
    
private:
    COnlineMusicDownload();
    ~COnlineMusicDownload();
    
    void RunDownTask();
    
protected:
    CDownTask* m_pCurrentDownTask;
    bool m_bTaskChange;
    bool m_bTaskStart;
    bool m_bTaskStop;
    bool m_bTaskSuccessed;
};

#endif
