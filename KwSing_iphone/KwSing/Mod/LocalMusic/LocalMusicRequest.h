//
//  LocalMusic.h
//  KwSing
//
//  Created by Qian Hu on 12-8-6.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_LocalMusic_h
#define KwSing_LocalMusic_h
#include <string>
#include <vector>
#include "SongInfo.h"
#include "IHttpNotify.h"
#include "HttpRequest.h"
//#import <Foundation/Foundation.h>

enum TaskStatus
{
    TaskStatus_Null = 0,
    TaskStatus_Downing,
    TaskStatus_Finish,
    TaskStatus_Pause,
    TaskStatus_Fail
};

enum DowningStatus
{
    Status_DowningNull = 0,
    Status_DowningMusic,
    Status_DowningOriginSong
};

class CLocalTask : public CSongInfoBase
{
public:
    TaskStatus taskStatus;
    DowningStatus downStatus;
    CHttpRequest * pRequest;
    int nRetryCount;
    
    virtual void LoadFromDict(NSDictionary* dict);
    virtual void SaveToDict(NSMutableDictionary* dict);
    
    CLocalTask()
    {
        taskStatus = TaskStatus_Null;
        downStatus = Status_DowningNull;
        pRequest = NULL;
        nRetryCount = 0;
    }
    
    ~CLocalTask()
    {
        if(pRequest)
            delete pRequest;
    }
    
};

class CLocalMusicRequest : public IHttpRequestNotify, public IObserverApp
{
public:
    static CLocalMusicRequest * GetInstance();
    
    // 开始下载歌曲伴唱及其歌词的任务（加入到下载队列中，并不实际开始下载）songInfo中必备信息有：rid，歌曲名，歌手名
    BOOL StartDownTask(CSongInfoBase * songInfo);
    // 当前是否有正在下载的任务
    BOOL HasDowningTask();
    // 开始下载歌曲伴唱及其歌词的任务 (插入到下载队列对最前面，立即开始下载)songInfo中必备信息有：rid，歌曲名，歌手名
    BOOL DownTaskImmediately(CSongInfoBase * songInfo);
    // 获取列表中某个id对应对歌曲任务
    CSongInfoBase * GetLocalMusic(const std::string & strRid);
    // 获取任务列表
    std::vector<CSongInfoBase*>& GetLocalMusicVec()
    {

        return m_vecLocalTask;
    }
    // 各种对任务的操作接口
    BOOL StartAllTask();
    BOOL SaveAllTask();
    BOOL LoadAllTask();
    BOOL DeleteTask(const std::string & strRid);
    BOOL PauseDownTask(const std::string & strRid);
    BOOL PauseAllTasks();
    
    float GetTaskRadio(CSongInfoBase * pTask);
    // 关于任务的描述（曲库中与web的交互中会用到，其他地方不用）
    NSString * GetDowningTaskListString();
    NSString * GetLocalMusicListString();
    
public:
    virtual void IHttpNotify_DownStart(CHttpRequest* pRequest,long lTotalSize);
    
    virtual void IHttpNotify_Process(CHttpRequest* pRequest,long lTotalSize,long lCurrentSize,long lSpeed);
    
    virtual void IHttpNotify_Stop(CHttpRequest* pRequest,BOOL bSuccess);
    
    virtual void IObserverApp_EnterBackground();

    virtual void IObserverApp_EnterForeground();
    
    virtual void IObserverApp_NetWorkStatusChanged(KSNetworkStatus enumStatus);

protected:
    void DownTaskThread(CSongInfoBase * pSongInfo);
    void DownOriginSongThread(CSongInfoBase * pSongInfo);

    void UpdateDownTask();
    
protected:
    std::vector<CSongInfoBase *> m_vecLocalTask;
    std::vector<CSongInfoBase *> m_vecDowningTask;      // 记录在下载队列中的任务
    
    CLocalTask * m_pCurrentTask;                        // 记录当前
    bool m_bChangeData;
    
private:
    MUSIC_FORMAT stringToFormat(const std::string & strFormat,const std::string & strBitrate);
    
private:
    CLocalMusicRequest();
    ~CLocalMusicRequest();
};

#endif
