//
//  LyricRequest.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-3.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__LyricRequest__
#define __KwSing__LyricRequest__

#include "SongInfo.h"
#include "ILyricNotify.h"
#include <string>
#include "IHttpNotify.h"

class CHttpRequest;

class CLyricRequest:public IHttpRequestNotify
{
public:
    CLyricRequest(const CSongInfoBase* pSong);
    
    BOOL SyncRequestLyric(BOOL bWordForWord=TRUE);
    
    BOOL AsyncRequestLyric(ILyricNotify* pNotify
                           ,BOOL bWordForWord=TRUE);
    BOOL AsyncRequestLyric(id<ILyricNotify> idNotify
                           ,BOOL bWordForWord=TRUE);
    void Cancle();
    
    BOOL IsFinished();
    BOOL IsSuccess();
    
    CLyricInfo& GetLyricInfo();

public:
    ~CLyricRequest();
    void IHttpNotify_Stop(CHttpRequest* pRequest,BOOL bSuccess);
private:
    std::string CreateUrl(BOOL bWordForWord);
    BOOL ParseLyric(void* pData,long len);
    BOOL LoadFromCache(const std::string& strUrl);
    BOOL SaveToCache(const std::string& strUrl,void* pData,unsigned len);
private:
    CLyricInfo m_lyricInfo;
    ILyricNotify* m_pNotify;
    id<ILyricNotify> m_idNotify;
    std::string m_strBaseParas;
    CHttpRequest* m_pAsyncHttpRequest;
    BOOL m_bSuccess;
};

#endif 
