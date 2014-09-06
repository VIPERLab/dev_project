//
//  LocalBookRequest.h
//  kwbook
//
//  Created by 单 永杰 on 13-12-2.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#ifndef __kwbook__LocalBookRequest__
#define __kwbook__LocalBookRequest__

#include <iostream>
#include <string>
#include <vector>
#include <map>
#include "ChapterInfo.h"
#include "IHttpNotify.h"
#include "HttpRequest.h"
#include "IObserverFlowProtect.h"

#import "LocalTask.h"

class CLocalBookRequest : public IHttpRequestNotify, public IObserverApp, public IObserverFlowProtect
{
public:
    virtual~CLocalBookRequest();
    
    static CLocalBookRequest * GetInstance();
    
    // 开始下载歌曲伴唱及其歌词的任务（加入到下载队列中，并不实际开始下载）songInfo中必备信息有：rid，歌曲名，歌手名
    BOOL StartDownTask(CChapterInfo * chapterInfo);
    BOOL AddWaitingTask(CChapterInfo * chapterInfo);
    BOOL StartDownTasks(std::vector<CChapterInfo*>& vec_chapters);
    BOOL AddWaitingTasks(std::vector<CChapterInfo*>& vec_chapters);
    // 当前是否有正在下载的任务
    BOOL HasDowningTask();
    // 各种对任务的操作接口
    BOOL StartAllTask(std::string str_book_id);
    BOOL DeleteTask(CChapterInfo* chapter_info);
    BOOL DeleteTasks(std::string str_book_id);
    BOOL DeleteTasks(std::string str_book_id, bool b_finished);
    BOOL PauseDownTask(CChapterInfo* chapter_info);
    BOOL PauseAllTasks(std::string str_book_id);
    
    BOOL IsLocalChapter(unsigned un_rid);
    
public:
    virtual void IHttpNotify_DownStart(CHttpRequest* pRequest,long lTotalSize);
    
    virtual void IHttpNotify_Process(CHttpRequest* pRequest,long lTotalSize,long lCurrentSize,long lSpeed);
    
    virtual void IHttpNotify_Stop(CHttpRequest* pRequest,BOOL bSuccess);
    
    virtual void IObserverApp_EnterForeground();
    
    virtual void IObserverApp_NetWorkStatusChanged(KSNetworkStatus enumStatus);
    virtual void IObserverFlowProtectStatusChanged(bool b_protect_on);
    
protected:
    void DownTaskThread(CChapterInfo * pSongInfo);
    
    void UpdateDownTask();
    
protected:
    std::vector<CChapterInfo *> m_vecDowningTask;      // 记录在下载队列中的任务
    
    CLocalTask * m_pCurrentTask;                        // 记录当前
    bool m_bChangeData;
    
private:
    CLocalBookRequest();
};


#endif /* defined(__kwbook__LocalBookRequest__) */
