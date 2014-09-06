//
//  OnlineMusicDownload.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "OnlineMusicDownload.h"

#include "KwTools.h"
#include "IAudioStateObserver.h"
#include "MessageManager.h"

COnlineMusicDownload* COnlineMusicDownload::GetInstance(){
    static COnlineMusicDownload s_download_instance;
    return &s_download_instance;
}

COnlineMusicDownload::COnlineMusicDownload(){
    m_pCurrentDownTask = NULL;
    m_bTaskChange = false;
    m_bTaskStart = false;
    m_bTaskStop = false;
    m_bTaskSuccessed = false;
}

COnlineMusicDownload::~COnlineMusicDownload(){
    if (m_pCurrentDownTask) {
        delete m_pCurrentDownTask;
        m_pCurrentDownTask = NULL;
    }
}

CDownTask* COnlineMusicDownload::GetCurrentTask()const{
    if (m_pCurrentDownTask) {
        return m_pCurrentDownTask;
    }else {
        return NULL;
    }
}

bool COnlineMusicDownload::StartDownload(MUSIC_RESOURCE* music_resource){
    if (m_pCurrentDownTask) {
        m_pCurrentDownTask->m_pHttpRequest->StopRequest();
        delete m_pCurrentDownTask;
        m_pCurrentDownTask = NULL;
    }
    
    m_pCurrentDownTask = new CDownTask;
    if (m_pCurrentDownTask) {
        m_pCurrentDownTask->m_MusicResource = *music_resource;
        m_bTaskChange = true;
    }else {
        return false;
    }
    
    RunDownTask();
    
    return true;
}

void COnlineMusicDownload::RunDownTask(){
    KS_BLOCK_DECLARE
    {
        if (m_pCurrentDownTask) {
            m_pCurrentDownTask->m_pHttpRequest = new CHttpRequest(m_pCurrentDownTask->m_MusicResource.strUrl);

            m_pCurrentDownTask->m_pHttpRequest->AsyncSendRequest(this, m_pCurrentDownTask->m_MusicResource.strLocalPath, TRUE);
        }
    }
    KS_BLOCK_RUN_THREAD();
}

bool COnlineMusicDownload::IsDowning()const{
    return (NULL == m_pCurrentDownTask);
}

bool COnlineMusicDownload::StopDownload(){
    if (m_pCurrentDownTask) {
        m_pCurrentDownTask->m_pHttpRequest->StopRequest();
        delete m_pCurrentDownTask;
        m_pCurrentDownTask = NULL;
        
        return true;
    }
    
    return false;
}

std::string COnlineMusicDownload::GetDownFilePath()const{
    if (!m_pCurrentDownTask) {
        return m_pCurrentDownTask->m_MusicResource.strLocalPath;
    }
    
    return NULL;
}

uint COnlineMusicDownload::GetDownFileSize()const{
    if (m_pCurrentDownTask) {
        return m_pCurrentDownTask->m_MusicResource.uiFileSize;
    }else {
        return 0;
    }
}

uint COnlineMusicDownload::GetCurFileSize()const{
    if (m_pCurrentDownTask) {
        return m_pCurrentDownTask->m_MusicResource.uiLocalSize;
    }else {
        return 0;
    }
}

MUSIC_FORMAT COnlineMusicDownload::GetMusicFormat()const{
    if (m_pCurrentDownTask) {
        return m_pCurrentDownTask->m_MusicResource.eumFormat;
    }else {
        return FMT_UNKNOWN;
    }
}

UInt32 COnlineMusicDownload::GetMusicBitRate()const{
    UInt32 un_bitrate = 0;
    if (m_pCurrentDownTask) {
        switch (m_pCurrentDownTask->m_MusicResource.eumFormat) {
            case FMT_AAC_24:
                un_bitrate = 24;
                break;
                
            case FMT_AAC_32:
                un_bitrate = 32;
                break;
                
            case FMT_AAC_48:
                un_bitrate = 48;
                break;
                
            case FMT_MP3_128:
                un_bitrate = 128;
                break;
                
            default:
                un_bitrate = 0;
                break;
        }
    }else {
        un_bitrate = 0;
    }
    
    return un_bitrate;
}

uint COnlineMusicDownload::GetMusicDuration()const{
    if (m_pCurrentDownTask) {
        return m_pCurrentDownTask->m_MusicResource.uiDuration;
    }else {
        return 0;
    }
}

bool COnlineMusicDownload::IsTaskStarted()const{
    return m_bTaskStart;
}

bool COnlineMusicDownload::IsTaskStoped()const{
    return m_bTaskStop;
}

bool COnlineMusicDownload::IsTaskSuccessed()const{
    return m_bTaskSuccessed;
}

void COnlineMusicDownload::IHttpNotify_DownStart(CHttpRequest *pRequest, long lTotalSize){
    if (m_pCurrentDownTask && m_pCurrentDownTask->m_pHttpRequest && (pRequest == m_pCurrentDownTask->m_pHttpRequest)) {
        m_pCurrentDownTask->m_DownStatus = Status_Downing;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::DownloadStatus, STATUS_DOWNING);
        m_pCurrentDownTask->m_MusicResource.uiFileSize = lTotalSize;
        m_bTaskStart = true;
    }
}

void COnlineMusicDownload::IHttpNotify_Process(CHttpRequest *pRequest, long lTotalSize, long lCurrentSize, long lSpeed){
    if (m_pCurrentDownTask && m_pCurrentDownTask->m_pHttpRequest && (pRequest == m_pCurrentDownTask->m_pHttpRequest)) {
        m_pCurrentDownTask->m_MusicResource.uiLocalSize = lCurrentSize;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::DownloadProgress);
    }
}

void COnlineMusicDownload::IHttpNotify_Stop(CHttpRequest *pRequest, BOOL bSuccess){
    if (m_pCurrentDownTask && m_pCurrentDownTask->m_pHttpRequest && (pRequest == m_pCurrentDownTask->m_pHttpRequest)) {
        if (bSuccess) {
            SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::DownloadStatus, STATUS_SUCCESS);
            m_pCurrentDownTask->m_DownStatus = Status_Finish;
            m_bTaskSuccessed = true;
        } else {
            SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::DownloadStatus, STATUS_FAILED);
            m_pCurrentDownTask->m_DownStatus = Status_Finish;
            m_bTaskSuccessed = false;
            if (m_pCurrentDownTask) {
                delete m_pCurrentDownTask;
                m_pCurrentDownTask = NULL;
            }
        }
        m_bTaskStop = true;
    }
}


