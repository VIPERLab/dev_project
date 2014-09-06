//  Header.h
//  KwSing
//
//  Created by Qian Hu on 12-8-2.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_NetSongObserver_h
#define KwSing_NetSongObserver_h

#include "IMessageObserver.h"
#include "SongInfo.h"

#define PageRankSong            "pageranksong"
#define PageArtistCat           "pageartistcat"
#define PageArtistSong          "pageartistsong"
#define PageSearch              "pagesearch"

@protocol IMusicLibObserver <NSObject>
@optional
-(void)IObMusicLib_JumpToWebPage:(NSString*)strType :(NSString*)strTitle :(NSString*)strUrl;
-(void)IObMusicLib_AddTask:(NSString*)strRid;
-(void)IObMusicLib_DownTaskFinish:(NSString*)strRid;
-(void)IObMusicLib_DeleteTask:(NSString*)strRid;
-(void)IObMusicLib_PauseTask:(NSString*)strRid;
-(void)IObMusicLib_PauseAllTasks;
-(void)IObMusicLib_StartTask:(NSString*)strRid;
-(void)IObMusicLib_RecordMusic:(NSString*)strRid;
-(void)IObMusicLib_TaskFail:(NSString*)strRid;
-(void)IObMusicLib_TaskProgress:(NSString*)strRid:(float)fPercent;
@end

class IMusicLibObserver:public IMessageObserver
{
public:
    virtual void IObMusicLib_JumpToWebPage(const std::string& strType, const std::string& strTitle,const std::string& strUrl){}
    
    virtual void IObMusicLib_AddTask(const std::string& strRid){}
    
    virtual void IObMusicLib_DownTaskFinish(const std::string& strRid){}
    
    virtual void IObMusicLib_DeleteTask(const std::string& strRid){}
    
    virtual void IObMusicLib_PauseTask(const std::string& strRid){}
    
    virtual void IObMusicLib_PauseAllTasks(){}
    
    virtual void IObMusicLib_StartTask(const std::string& strRid){}

    virtual void IObMusicLib_RecordMusic(const std::string& strRid){}
    
    virtual void IObMusicLib_TaskFail(const std::string& strRid){}
    
    virtual void IObMusicLib_TaskProgress(const std::string& strRid,float fPercent){}

        
    enum eumMethod
    {
        JumpToWebPage,
        AddTask,
        DownTaskStop,
        DeleteTask,
        PauseTask,
        PauseAllTasks,
        StartTask,
        RecordMusic,
        TaskFail,
        TaskProgress
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IMusicLibObserver)
        NOTIFY_CASE_ITEM(JumpToWebPage,IObMusicLib_JumpToWebPage,_3PARA);
        NOTIFY_CASE_ITEM(AddTask,IObMusicLib_AddTask,_1PARA);
        NOTIFY_CASE_ITEM(DownTaskStop,IObMusicLib_DownTaskFinish,_1PARA);
        NOTIFY_CASE_ITEM(DeleteTask,IObMusicLib_DeleteTask,_1PARA);
        NOTIFY_CASE_ITEM(PauseTask,IObMusicLib_PauseTask,_1PARA);
        NOTIFY_CASE_ITEM(PauseAllTasks,IObMusicLib_PauseAllTasks,_0PARA);
        NOTIFY_CASE_ITEM(StartTask,IObMusicLib_StartTask,_1PARA);
        NOTIFY_CASE_ITEM(RecordMusic,IObMusicLib_RecordMusic,_1PARA);
        NOTIFY_CASE_ITEM(TaskFail,IObMusicLib_TaskFail,_1PARA);
        NOTIFY_CASE_ITEM(TaskProgress,IObMusicLib_TaskProgress,_2PARA);
    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif
