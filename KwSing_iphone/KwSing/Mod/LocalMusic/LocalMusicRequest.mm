//
//  LocalMusic.cpp
//  KwSing
//
//  Created by Qian Hu on 12-8-6.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "LocalMusicRequest.h"
#include "KwTools.h"
#include "MessageManager.h"
#include "HttpRequest.h"
#include "IMusicLibObserver.h"
#include "LyricRequest.h"
#include "KuwoLog.h"
#include "KwConfig.h"
#include "KwConfigElements.h"
#include "KwUMengElement.h"
#include "UMengLog.h"
#include "MobClick.h"

#define FILENAME_LOCALMUSIC         @"localmusic.plist"
#define DOWN_LYRIC_RETRY_COUNT             3
#define DOWN_MUSIC_RETRY_COUNT             1

inline void __ReadFromDict(NSDictionary* dict,NSString* strKey,unsigned& n)
{
    id v=[dict objectForKey:strKey];
    if (v && [[v class] isSubclassOfClass:[NSNumber class]]) {
        NSNumber* num=(NSNumber*)v;
        n=[num unsignedIntValue];
    }
}

inline void __SaveToDict(unsigned n,NSString* strKey,NSMutableDictionary* dict)
{
    if(n) [dict setObject:[NSNumber numberWithUnsignedInt:n] forKey:strKey];
}

void CLocalTask::LoadFromDict(NSDictionary* dict)
{
    CSongInfoBase::LoadFromDict(dict);
    
    @autoreleasepool {
        __ReadFromDict(dict, @"taskstatus", (unsigned&)taskStatus);
       // __ReadFromDict(dict, @"downingstatus", (unsigned&)downStatus);
    }
}

void CLocalTask::SaveToDict(NSMutableDictionary* dict)
{
    CSongInfoBase::SaveToDict(dict);
    
    @autoreleasepool {
        __SaveToDict(taskStatus, @"taskstatus", dict);
       // __SaveToDict(downStatus, @"downingstatus", dict);
    }
}

///////////////////////////////////////////////////////////
CLocalMusicRequest * CLocalMusicRequest::GetInstance()
{
    static CLocalMusicRequest sInstance;
    return &sInstance;
}

CLocalMusicRequest::CLocalMusicRequest()
{
    m_pCurrentTask = NULL;
    m_bChangeData = FALSE;
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_APP,IObserverApp);
    
}

CLocalMusicRequest::~CLocalMusicRequest()
{
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_APP,IObserverApp);
}

//点歌，没有下载或者暂停或者下载失败的歌曲放入下载队列，若是已经下载的歌曲发送开始录制通知
BOOL CLocalMusicRequest::StartDownTask(CSongInfoBase * songInfo)
{
    if(songInfo->strRid == "0")
    {
        // 自由清唱
        SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::RecordMusic,"");
        return true;
    }
    CLocalTask * localinfo = (CLocalTask*)GetLocalMusic(songInfo->strRid);
    if(localinfo)
    {
        if(localinfo->taskStatus == TaskStatus_Downing)
        {
            c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"StartDownTask:Task has already exist:rid=%s",localinfo->strRid.c_str());
            return FALSE;
        }
        else if(localinfo->taskStatus == TaskStatus_Finish)
        {
            c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"StartKSong:Task rid=%s,path=%s",localinfo->strRid.c_str(),localinfo->accompanyRes.strLocalPath.c_str());
            SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::RecordMusic,localinfo->strRid);
            return FALSE;
        }
        else if(localinfo->taskStatus == TaskStatus_Pause || localinfo->taskStatus == TaskStatus_Fail)
        {
            localinfo->taskStatus = TaskStatus_Downing;
            SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::StartTask,localinfo->strRid);
            m_vecDowningTask.push_back(localinfo);
        }
    }
    else {
        c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"StartDownTask:New Task is created:rid=%s",songInfo->strRid.c_str());
        localinfo = new CLocalTask;
        localinfo->taskStatus = TaskStatus_Downing;
        *((CSongInfoBase*)localinfo) = *songInfo;
        m_vecLocalTask.push_back(localinfo);
        m_vecDowningTask.push_back(localinfo);
        SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::AddTask,songInfo->strRid);
        m_bChangeData = true;
        //新点一首歌要保存列表
        SaveAllTask();
    }
    
    UpdateDownTask();
    return TRUE;
}

//插入下载任务，已经下载的歌曲发送录制通知，未下载的歌曲立即开始下载
BOOL CLocalMusicRequest::DownTaskImmediately(CSongInfoBase * songInfo)
{
    if(songInfo->strRid == "0" || songInfo->strRid == "" )
    {
        // 自由清唱
        SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::RecordMusic,"");
        return true;
    }
    
    if (m_pCurrentTask && m_pCurrentTask->strRid == songInfo->strRid) {
        return TRUE;
    }
    
    CLocalTask * localtask = (CLocalTask*)GetLocalMusic(songInfo->strRid);
    if(localtask) //该任务已在已点歌曲中,提到下载队列对最前
    {
        if(localtask->taskStatus == TaskStatus_Finish)
        {
            SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::RecordMusic,localtask->strRid);
            return TRUE;
        }
        else if(localtask->taskStatus == TaskStatus_Pause || localtask->taskStatus == TaskStatus_Fail)
        {
            localtask->taskStatus = TaskStatus_Downing;
            m_vecDowningTask.insert(m_vecDowningTask.begin(), localtask);
        }
        else if(localtask->taskStatus == TaskStatus_Downing) 
        {
            for (std::vector<CSongInfoBase *>::iterator iter = m_vecDowningTask.begin(); iter!= m_vecDowningTask.end(); iter++) {
                if(localtask->strRid == (*iter)->strRid)
                {
                    m_vecDowningTask.erase(iter);
                    break;
                }
            }
            m_vecDowningTask.insert(m_vecDowningTask.begin(), localtask); 
        }

    }
    else {
        localtask = new CLocalTask;
        localtask->taskStatus = TaskStatus_Downing;
        *((CSongInfoBase*)localtask) = *songInfo;
        m_vecLocalTask.push_back(localtask);
        m_vecDowningTask.insert(m_vecDowningTask.begin(), localtask); 
        SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::AddTask,localtask->strRid);
        //新点一首歌要保存列表
        m_bChangeData = TRUE;
        SaveAllTask();

    }

    if(m_pCurrentTask)  //当前有下载任务，停止当前任务
    {
        if(m_pCurrentTask->pRequest)
        {
            m_pCurrentTask->pRequest->StopRequest();
            delete m_pCurrentTask->pRequest;
            m_pCurrentTask->pRequest = NULL;
        }
        m_pCurrentTask = NULL;
    }

    
    UpdateDownTask(); 
    

    return TRUE;
}

MUSIC_FORMAT CLocalMusicRequest::stringToFormat(const std::string & strFormat,const std::string & strBitrate)
{
    std::string strLowerFormat = KwTools::StringUtility::Str2Lower(strFormat);
    std::string strLowerBitrate = KwTools::StringUtility::Str2Lower(strBitrate);
    if( strLowerFormat == "mp3" )
    {
        if(strLowerBitrate == "128" )
            return FMT_MP3_128;
    }
    else if ( strLowerFormat == "aac" )
    {
        if( strLowerBitrate == "24" )
            return FMT_AAC_24;
        else if( strLowerBitrate == "32" )
            return FMT_AAC_32;
        else if( strLowerBitrate == "48" )
            return FMT_MP3_128;
    }
    return FMT_UNKNOWN;
}



void CLocalMusicRequest::DownTaskThread(CSongInfoBase * pSongInfo)
{
    std::string strFormat;
    std::string strBitrate;
    std::string strUrl;
    std::string strSig;
    // 请求歌词
    std::string strpath;
    KwTools::Dir::GetPath(KwTools::Dir::PATH_LYRIC,strpath);
    strpath += "/ac";
    strpath += pSongInfo->strRid;
    strpath += ".lrc";
    if(!KwTools::Dir::IsExistFile(strpath))
    {
        CLyricRequest lyricRequest(pSongInfo);
        bool bret = false;
        for (int i = 0; i < DOWN_LYRIC_RETRY_COUNT && !bret; i++) {
            bret = lyricRequest.SyncRequestLyric(true);
        }
        if(bret)
        {
            CLyricInfo & lyricinfo = lyricRequest.GetLyricInfo();
            lyricinfo.WriteToFile(strpath);
            RTLog_DownloadLyric(AR_SUCCESS,CHttpRequest::GetNetWorkProviderName().c_str(),
                                pSongInfo->strSongName.c_str(),pSongInfo->strSongName.c_str(),pSongInfo->strRid.c_str(),lyricinfo.GetLyricType());
            UMengLog(KS_DOWN_LYRIC, "0");
        }
        else 
        {
            RTLog_DownloadLyric(AR_FAIL,CHttpRequest::GetNetWorkProviderName().c_str(),
                                pSongInfo->strSongName.c_str(),pSongInfo->strSongName.c_str(),pSongInfo->strRid.c_str(),0);
            UMengLog(KS_DOWN_LYRIC, "1");
        }
        
    }
 
    CHttpRequest::CONVERT_URL_PARA para;
    para.strRid = pSongInfo->strRid;
    para.strBitrate = "";
    bool bret = false;

    if(pSongInfo->accompanyRes.uiFileSize && pSongInfo->accompanyRes.uiFileSize == pSongInfo->accompanyRes.uiLocalSize)
    {
        // 伴唱下载完成，接着下载原唱就ok
        para.strContinueSig = pSongInfo->originalRes.strSig;
        para.bOnlyMusic = false;
        bret = CHttpRequest::ConvertUrl(para,strFormat,strBitrate,strUrl,strSig);
        int n_retry_times(0);
        while ((!bret) && (2 > n_retry_times)) {
            bret = CHttpRequest::ConvertUrl(para,strFormat,strBitrate,strUrl,strSig);
            ++n_retry_times;
        }
        pSongInfo->originalRes.strUrl = strUrl;
        pSongInfo->originalRes.eumFormat = stringToFormat(strFormat,strBitrate);
        pSongInfo->originalRes.strSig = strSig;
    }
    else
    {
        para.strContinueSig = pSongInfo->accompanyRes.strSig;
        para.bOnlyMusic = true;
        bret = CHttpRequest::ConvertUrl(para,strFormat,strBitrate,strUrl,strSig);
        int n_retry_times(0);
        while ((!bret) && (3 > n_retry_times)) {
            bret = CHttpRequest::ConvertUrl(para,strFormat,strBitrate,strUrl,strSig);
            ++n_retry_times;
        }
        pSongInfo->accompanyRes.strUrl = strUrl;
        pSongInfo->accompanyRes.eumFormat = stringToFormat(strFormat,strBitrate);
        pSongInfo->accompanyRes.strSig = strSig;
    }
    
    {
        // 以下在主线程中执行
        KS_BLOCK_DECLARE
        {
            if(m_pCurrentTask && m_pCurrentTask->strRid == pSongInfo->strRid)
            {
                if(bret)
                {
                    if(para.bOnlyMusic)
                    {
                        m_pCurrentTask->accompanyRes.eumFormat = pSongInfo->accompanyRes.eumFormat;
                        m_pCurrentTask->pRequest = new CHttpRequest(pSongInfo->accompanyRes.strUrl);
                        m_pCurrentTask->accompanyRes.strSig = pSongInfo->accompanyRes.strSig;
                        std::string strlocal;
                        KwTools::Dir::GetPath(KwTools::Dir::PATH_LOCALMUSIC,strlocal);
                        strlocal += "/";
                        strlocal += m_pCurrentTask->strRid;
                        std::string strex = strUrl.substr(strUrl.rfind("."),-1);
                        m_pCurrentTask->accompanyRes.strLocalPath = strlocal + strex;
                        c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"DownTaskThread:Task really start,down accompany music:rid=%s",m_pCurrentTask->strRid.c_str());
                        m_pCurrentTask->pRequest->AsyncSendRequest(this,m_pCurrentTask->accompanyRes.strLocalPath,TRUE);
                        m_pCurrentTask->downStatus = Status_DowningMusic;
                    }
                    else
                    {
                        m_pCurrentTask->originalRes.eumFormat = pSongInfo->originalRes.eumFormat;
                        m_pCurrentTask->pRequest = new CHttpRequest(pSongInfo->originalRes.strUrl);
                        m_pCurrentTask->originalRes.strSig = pSongInfo->originalRes.strSig;
                        std::string strlocal;
                        KwTools::Dir::GetPath(KwTools::Dir::PATH_LOCALMUSIC,strlocal);
                        strlocal += "/or_";
                        strlocal += m_pCurrentTask->strRid;
                        std::string strex = strUrl.substr(strUrl.rfind("."),-1);
                        m_pCurrentTask->originalRes.strLocalPath = strlocal + strex;
                        c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"DownTaskThread:Task really start,down original song:rid=%s",m_pCurrentTask->strRid.c_str());
                        m_pCurrentTask->pRequest->AsyncSendRequest(this,m_pCurrentTask->originalRes.strLocalPath,TRUE);
                        m_pCurrentTask->downStatus = Status_DowningOriginSong;
                    }
                }
                else {
                    // 失败的任务从下载队列中删除
                    c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"DownTaskThread:ConvertUrl failed:rid=%s",m_pCurrentTask->strRid.c_str());
                    //DeleteTask(m_pCurrentTask->strRid);
                    m_pCurrentTask->taskStatus = TaskStatus_Fail;
                    SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::TaskFail,m_pCurrentTask->strRid);
                    m_pCurrentTask = NULL;
                    UpdateDownTask();
                }
            }
            else {
                c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"DownTaskThread:Task has been canceled:rid=%s",pSongInfo->strRid.c_str());
            }            
        }
         KS_BLOCK_SYNRUN();
    }
}

BOOL CLocalMusicRequest::HasDowningTask()
{
    return (m_pCurrentTask!=NULL) ? TRUE : FALSE;
//    return (m_vecDowningTask.size() > 0) ? TRUE : FALSE;
//    for (std::vector<CSongInfoBase *>::iterator iter = m_vecLocalTask.begin(); iter!= m_vecLocalTask.end(); iter++) {
//        if(((CLocalTask*)(*iter))->taskStatus == Status_Downing)
//            return TRUE;
//    }
//    return FALSE;
}

//启动程序时加载点歌列表信息，包括失败的任务设置为“点歌”，其他的任务根据文件大小变成“暂停”或“完成”,这是因为程序启动的时候所有任务都为暂停的状态
BOOL CLocalMusicRequest::LoadAllTask()
{
    c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"LoadAllTask start");
    m_vecLocalTask.clear();
    NSString *filepath = KwTools::Dir::GetPath(KwTools::Dir::PATH_DUCUMENT);
    filepath = [filepath stringByAppendingPathComponent:FILENAME_LOCALMUSIC];
    NSMutableArray *arrLocalTask;
    if(KwTools::Dir::IsExistFile(filepath))
    {
        @autoreleasepool {
            arrLocalTask = [NSMutableArray arrayWithContentsOfFile:filepath];
            for (NSDictionary *dict in arrLocalTask)
            {
                CSongInfoBase * songInfo = new CLocalTask;
                ((CLocalTask*)songInfo)->LoadFromDict(dict);
                
                // 文件放在library下，可能被删除
                int n_index(0);
                n_index = songInfo->accompanyRes.strLocalPath.rfind("/");
                std::string str_acco_filename = songInfo->accompanyRes.strLocalPath.substr(n_index + 1);
                songInfo->accompanyRes.strLocalPath = "";
                songInfo->accompanyRes.strLocalPath = songInfo->accompanyRes.strLocalPath + [KwTools::Dir::GetPath(KwTools::Dir::PATH_LOCALMUSIC) UTF8String] + "/" + str_acco_filename;
                
                n_index = songInfo->originalRes.strLocalPath.rfind("/");
                std::string str_orig_filename = songInfo->originalRes.strLocalPath.substr(n_index + 1);
                songInfo->originalRes.strLocalPath = "";
                songInfo->originalRes.strLocalPath = songInfo->originalRes.strLocalPath + [KwTools::Dir::GetPath(KwTools::Dir::PATH_LOCALMUSIC) UTF8String] + "/" + str_orig_filename;
                
                if(!KwTools::Dir::IsExistFile(songInfo->accompanyRes.strLocalPath) && songInfo->accompanyRes.uiLocalSize)
                {
                    songInfo->accompanyRes.uiLocalSize = 0;
                    songInfo->accompanyRes.strSig = "";
                    songInfo->originalRes.uiLocalSize = 0;
                    songInfo->originalRes.strSig = "";
                    ((CLocalTask*)songInfo)->taskStatus = TaskStatus_Fail;
                }
                if(((CLocalTask*)songInfo)->taskStatus != TaskStatus_Fail)
                {
                    if(songInfo->accompanyRes.uiFileSize == 0 || songInfo->accompanyRes.uiFileSize != songInfo->accompanyRes.uiLocalSize ||
                       songInfo->originalRes.uiFileSize == 0 || songInfo->originalRes.uiFileSize != songInfo->originalRes.uiLocalSize)
                    {
                        ((CLocalTask*)songInfo)->taskStatus = TaskStatus_Pause;
                    }
                    else {
                        ((CLocalTask*)songInfo)->taskStatus = TaskStatus_Finish;
                    }

                }
                m_vecLocalTask.push_back(songInfo);
            }
        }
    }
    c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"LoadAllTask finish,local num:%d",m_vecLocalTask.size());
    return TRUE;
 
}

CSongInfoBase * CLocalMusicRequest::GetLocalMusic(const std::string & strRid)
{
    for (std::vector<CSongInfoBase *>::iterator iter = m_vecLocalTask.begin(); iter!= m_vecLocalTask.end(); iter++) {
        if(strRid == (*iter)->strRid)
            return (*iter);
    }
    return NULL;
}

void CLocalMusicRequest::IHttpNotify_DownStart(CHttpRequest* pRequest,long lTotalSize)
{
    if(m_pCurrentTask && m_pCurrentTask->pRequest && m_pCurrentTask->pRequest == pRequest)
    {
        if(m_pCurrentTask->downStatus == Status_DowningMusic)
            m_pCurrentTask->accompanyRes.uiFileSize = lTotalSize;
        else if(m_pCurrentTask->downStatus == Status_DowningOriginSong)
            m_pCurrentTask->originalRes.uiFileSize = lTotalSize;
        m_bChangeData = true;
        [MobClick beginEvent:[NSString stringWithUTF8String:KS_DOWN_SONG_TIME]];
    }
    
}

void CLocalMusicRequest::IHttpNotify_Process(CHttpRequest* pRequest,long lTotalSize,long lCurrentSize,long lSpeed)
{
    if(CHttpRequest::GetNetWorkStatus() == NETSTATUS_NONE)
        return;
    if(m_pCurrentTask && m_pCurrentTask->pRequest && m_pCurrentTask->pRequest == pRequest)
    {
       if(lCurrentSize == 0)
           return;
        if(lTotalSize<lCurrentSize)
            return;
        float fpercent = 0;
        if(m_pCurrentTask->downStatus == Status_DowningMusic)
        {
            m_pCurrentTask->accompanyRes.uiFileSize = lTotalSize;
            m_pCurrentTask->accompanyRes.uiLocalSize = lCurrentSize;
            fpercent = lCurrentSize*1.0/lTotalSize/2.0;
        }
        else if(m_pCurrentTask->downStatus == Status_DowningOriginSong)
        {
            m_pCurrentTask->originalRes.uiFileSize = lTotalSize;
            m_pCurrentTask->originalRes.uiLocalSize = lCurrentSize;
            fpercent = 0.5+lCurrentSize*1.0/lTotalSize/2.0;
        }
        
        m_bChangeData = true;
        
        SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::TaskProgress,m_pCurrentTask->strRid,fpercent);
    }
}

void CLocalMusicRequest::IHttpNotify_Stop(CHttpRequest* pRequest,BOOL bSuccess)
{
    if(m_pCurrentTask && m_pCurrentTask->pRequest && m_pCurrentTask->pRequest == pRequest)
    {
       if(bSuccess)
       {
           if(m_pCurrentTask->downStatus == Status_DowningMusic)
           {
               m_pCurrentTask->nRetryCount = 0;
           }
           else if(m_pCurrentTask->downStatus == Status_DowningOriginSong)
           {
               m_pCurrentTask->taskStatus = TaskStatus_Finish;
               m_pCurrentTask->originalRes.uiLocalSize = m_pCurrentTask->originalRes.uiFileSize;
               RTLog_DownloadMusic(AR_SUCCESS,CHttpRequest::GetNetWorkProviderName().c_str(),m_pCurrentTask->strSongName.c_str()
                                   ,m_pCurrentTask->strArtist.c_str(),m_pCurrentTask->strRid.c_str(),
                                   GetFormatName(m_pCurrentTask->accompanyRes.eumFormat),GetBitRate(m_pCurrentTask->accompanyRes.eumFormat));
               UMengLog(KS_DOWN_MUSIC, "0");
               SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::DownTaskStop,m_pCurrentTask->strRid);
           }
       }
       else 
       {
           if(m_pCurrentTask->nRetryCount >= DOWN_MUSIC_RETRY_COUNT)
           {
               // 失败的任务从下载队列中删除
               RTLog_DownloadMusic(AR_FAIL,CHttpRequest::GetNetWorkProviderName().c_str(),m_pCurrentTask->strSongName.c_str()
                                   ,m_pCurrentTask->strArtist.c_str(),m_pCurrentTask->strRid.c_str(),
                                   GetFormatName(m_pCurrentTask->accompanyRes.eumFormat),GetBitRate(m_pCurrentTask->accompanyRes.eumFormat));
               UMengLog(KS_DOWN_MUSIC, "1");
               m_pCurrentTask->taskStatus = TaskStatus_Fail;
               m_pCurrentTask->nRetryCount = 0;
               SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::TaskFail,m_pCurrentTask->strRid);
           }
           else {
               // 重试
               m_pCurrentTask->nRetryCount++;
           }
       }
        
        [MobClick endEvent:[NSString stringWithUTF8String:KS_DOWN_SONG_TIME]];
        m_bChangeData = true;
        // 保存一次数据
        SaveAllTask();
        delete m_pCurrentTask->pRequest;
        m_pCurrentTask->pRequest = NULL;
        m_pCurrentTask = NULL;
        UpdateDownTask();
    }
}

BOOL CLocalMusicRequest::DeleteTask(const std::string & strRid)
{
    CLocalTask * localtask = (CLocalTask*)GetLocalMusic(strRid);
    if(localtask)
    {
        if(m_pCurrentTask && m_pCurrentTask->strRid == strRid)
        {
            if(m_pCurrentTask->pRequest)
                m_pCurrentTask->pRequest->StopRequest();
            m_pCurrentTask = NULL;
        }
        for (std::vector<CSongInfoBase *>::iterator iter = m_vecLocalTask.begin(); iter!= m_vecLocalTask.end(); iter++) {
            if(strRid == (*iter)->strRid)
            {
                m_vecLocalTask.erase(iter);
                break;
            }
        }
        for (std::vector<CSongInfoBase *>::iterator iter = m_vecDowningTask.begin(); iter!= m_vecDowningTask.end(); iter++) {
            if(strRid == (*iter)->strRid)
            {
                m_vecDowningTask.erase(iter);
                break;
            }
        }
        m_bChangeData = true;
        KwTools::Dir::DeleteFile(localtask->accompanyRes.strLocalPath);
        KwTools::Dir::DeleteFile(localtask->originalRes.strLocalPath);
        SaveAllTask();
        SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::DeleteTask,localtask->strRid);
        delete localtask;
        UpdateDownTask();
        return TRUE;
    }
    return  FALSE;
}

BOOL CLocalMusicRequest::PauseDownTask(const std::string & strRid)
{
    CLocalTask * localtask = (CLocalTask*)GetLocalMusic(strRid);
    if(localtask)
    {
        if(m_pCurrentTask && m_pCurrentTask->strRid == strRid)
        {
            if(m_pCurrentTask->pRequest)
            {
                m_pCurrentTask->pRequest->StopRequest();
                delete m_pCurrentTask->pRequest;
                m_pCurrentTask->pRequest = NULL;
            }
            m_pCurrentTask = NULL;
        }
        localtask->taskStatus = TaskStatus_Pause;
        for (std::vector<CSongInfoBase *>::iterator iter = m_vecDowningTask.begin(); iter!= m_vecDowningTask.end(); iter++) {
            if(strRid == (*iter)->strRid)
            {
                m_vecDowningTask.erase(iter);
                break;
            }
        }
        UpdateDownTask();
        SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::PauseTask,localtask->strRid);
    }

    return FALSE;
}


//更新当前真正下载对象
void CLocalMusicRequest::UpdateDownTask()
{
    if(m_pCurrentTask != NULL)
        return;
    for (std::vector<CSongInfoBase *>::iterator iter = m_vecDowningTask.begin(); iter!= m_vecDowningTask.end(); iter++) {
        if(((CLocalTask*)(*iter))->taskStatus != TaskStatus_Downing)
        {
            iter = m_vecDowningTask.erase(iter);
            --iter;
        }
        else {
            // 从下载队列中挑选最前面对一个任务开始下载
            CSongInfoBase *ptemp = new CSongInfoBase;
            m_pCurrentTask = (CLocalTask*)(*iter);
            *ptemp = *(*iter);
            c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"UpdateDownTask:Start Downing Task:rid=%s",ptemp->strRid.c_str());
            KS_BLOCK_DECLARE
            {
                DownTaskThread(ptemp);
                delete ptemp;
            }
            KS_BLOCK_RUN_THREAD();
            return;
        }
    }

}

float CLocalMusicRequest::GetTaskRadio(CSongInfoBase * pTask)
{
    if(!pTask)
        return 0.0;
    float fpercent = 0.0;
    if(pTask->accompanyRes.uiFileSize && pTask->accompanyRes.uiFileSize == pTask->accompanyRes.uiLocalSize)
    {
        fpercent = 0.5;
        if(pTask->originalRes.uiFileSize)
            fpercent = 0.5+pTask->originalRes.uiLocalSize*1.0/pTask->originalRes.uiFileSize/2.0;
    }
    else
    {
        if(pTask->accompanyRes.uiFileSize)
            fpercent = pTask->accompanyRes.uiLocalSize*1.0/pTask->accompanyRes.uiFileSize/2.0;
    }
    return fpercent;
}

NSString * CLocalMusicRequest::GetDowningTaskListString()
{
    NSString * value = @"";
    if(m_pCurrentTask)
    {
        int nradio = 0;
        if(m_pCurrentTask->accompanyRes.uiFileSize!=0)
            nradio = m_pCurrentTask->accompanyRes.uiLocalSize*100/m_pCurrentTask->accompanyRes.uiFileSize;
        value = [NSString stringWithFormat: @"%s&&downing&&%d",m_pCurrentTask->strRid.c_str(),nradio];
    }

    return value;

}

NSString * CLocalMusicRequest::GetLocalMusicListString()
{
    NSString * value = [[NSString alloc] initWithString:@""]; //@"";//@"<array>";
    std::string arrstr[3] = {"downing","finish","pause"};
    
    for (std::vector<CSongInfoBase *>::iterator iter = m_vecLocalTask.begin(); iter!= m_vecLocalTask.end(); iter++)  {
        @autoreleasepool {
            CLocalTask * temp = ((CLocalTask*)(*iter));
            if(temp->taskStatus == TaskStatus_Fail)
                continue;
            int nradio = 0;
            if(temp->accompanyRes.uiFileSize != 0)
                nradio = temp->accompanyRes.uiLocalSize*100/temp->accompanyRes.uiFileSize;
            NSString* p = [[value stringByAppendingFormat:@"%s&&%s&&%d||",temp->strRid.c_str(),arrstr[temp->taskStatus-1].c_str(),nradio] retain];
            [value release];
            value=p;
        }
    }
    [value autorelease];
    return value;
}

BOOL CLocalMusicRequest::StartAllTask()
{
    for (std::vector<CSongInfoBase *>::iterator iter = m_vecLocalTask.begin(); iter!= m_vecLocalTask.end(); iter++) {
        TaskStatus status = ((CLocalTask*)(*iter))->taskStatus;
        if(status == TaskStatus_Pause )
            ((CLocalTask*)(*iter))->taskStatus = TaskStatus_Downing;
        m_vecDowningTask.push_back((*iter));
    }
    UpdateDownTask();
    return TRUE;
}

BOOL CLocalMusicRequest::SaveAllTask()
{
    if(!m_bChangeData)
        return FALSE;
    c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"SaveAllTasks start");
    NSMutableArray *arrTask = [NSMutableArray arrayWithCapacity:m_vecLocalTask.size()];
    for (std::vector<CSongInfoBase *>::iterator iter = m_vecLocalTask.begin(); iter!= m_vecLocalTask.end(); iter++) {
        CLocalTask* temp = ((CLocalTask*)(*iter));
        @autoreleasepool {
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc]init]autorelease];
            temp->SaveToDict(dict);
            [arrTask addObject:dict];
        }
    }
    
    NSString *filepath = KwTools::Dir::GetPath(KwTools::Dir::PATH_DUCUMENT);
    NSString *str = [filepath stringByAppendingPathComponent:FILENAME_LOCALMUSIC];
    if(KwTools::Dir::IsExistFile([str UTF8String]) && !KwTools::Dir::DeleteFile(str))
    {
        c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"SaveAllTasks:can't delete old file");
        return false;
    }
    BOOL bret = [arrTask writeToFile:str atomically:YES];
    c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"SaveAllTasks:result:%d",bret);
    return bret;
}

BOOL CLocalMusicRequest::PauseAllTasks()
{
    for (std::vector<CSongInfoBase *>::iterator iter = m_vecDowningTask.begin(); iter!= m_vecDowningTask.end(); iter++) {
        ((CLocalTask*)(*iter))->taskStatus = TaskStatus_Pause;
        SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::PauseTask,(*iter)->strRid);
    }
    m_vecDowningTask.clear();
    if(m_pCurrentTask && m_pCurrentTask->pRequest)
    {
        m_pCurrentTask->pRequest->StopRequest();
        delete m_pCurrentTask->pRequest;
        m_pCurrentTask->pRequest = NULL;
    }
    m_pCurrentTask = NULL;
    
    c_KuwoDebugLog("LOCALMUSIC",DEBUG_LOG,"PauseAllTasks");
    
    //SYN_NOTIFY(OBSERVER_ID_MUSICLIB, IMusicLibObserver::PauseAllTasks);
    return TRUE;
}

void CLocalMusicRequest::IObserverApp_EnterBackground()
{
    SaveAllTask();
}

void CLocalMusicRequest::IObserverApp_EnterForeground()
{
    UpdateDownTask();
}

void CLocalMusicRequest::IObserverApp_NetWorkStatusChanged(KSNetworkStatus enumStatus)
{
    if(enumStatus == NETSTATUS_NONE)
    {
        PauseAllTasks();
    }
}

//void CLocalMusicRequest::GetLocalMusicVec(std::vector<CSongInfoBase*>& vecLocalMusic)
//{
//    vecLocalMusic = m_vecLocalTask;
//}




