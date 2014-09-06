//
//  IMyOpusObserver.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-9-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IMyOpusObserver_h
#define KwSing_IMyOpusObserver_h

#include "IMessageObserver.h"
#include "SongInfo.h"
#include "MyOpusData.h"

@protocol IMyOpusObserver <NSObject>
@optional
- (void)IMyOpusObserver_Refresh;
- (void)IMyOpusObserver_AddSong:(CRecoSongInfo*)pSong;
- (void)IMyOpusObserver_BeforeDeleteItem:(unsigned)idx :(CRecoSongInfo*)pSong;
- (void)IMyOpusObserver_AfterDeleteItem:(unsigned)idx;
- (void)IMyOpusObserver_UploadProgress:(unsigned)idx :(CRecoSongInfo*)pSong :(unsigned)percent;
- (void)IMyOpusObserver_FinishUploadOne:(unsigned)idx :(CRecoSongInfo*)pSong :(CMyOpusData::SEND_RESULT)sendRes;
@end

class IMyOpusObserver:public IMessageObserver
{
public:
    virtual void IMyOpusObserver_Refresh() {}
    
    virtual void IMyOpusObserver_AddSong(const CRecoSongInfo* pSong) {}
    
    virtual void IMyOpusObserver_BeforeDeleteItem(unsigned idx,const CRecoSongInfo* pSong) {}
    
    virtual void IMyOpusObserver_AfterDeleteItem(unsigned idx) {}
    
    virtual void IMyOpusObserver_UploadProgress(unsigned idx,const CRecoSongInfo* pSong,unsigned percent) {}
    
    virtual void IMyOpusObserver_FinishUploadOne(unsigned idx,const CRecoSongInfo* pSong,CMyOpusData::SEND_RESULT sendRes) {}
    
    enum eumMethod
    {
        AddSong
        ,Refresh
        ,BeforeDeleteItem
        ,AfterDeleteItem
        ,UploadProgress
        ,FinishUploadOne
    };
    
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IMyOpusObserver)
        NOTIFY_CASE_ITEM(Refresh,IMyOpusObserver_Refresh,_0PARA);
        NOTIFY_CASE_ITEM(AddSong,IMyOpusObserver_AddSong,_1PARA);
        NOTIFY_CASE_ITEM(BeforeDeleteItem,IMyOpusObserver_BeforeDeleteItem,_2PARA);
        NOTIFY_CASE_ITEM(AfterDeleteItem,IMyOpusObserver_AfterDeleteItem,_1PARA);
        NOTIFY_CASE_ITEM(UploadProgress,IMyOpusObserver_UploadProgress,_3PARA);
        NOTIFY_CASE_ITEM(FinishUploadOne,IMyOpusObserver_FinishUploadOne,_3PARA);
    MESSAGE_OBSERVER_NOTIFY_END();
    
};

#endif
