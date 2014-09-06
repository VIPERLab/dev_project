//
//  LyricRequest.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-3.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "LyricRequest.h"
#include "HttpRequest.h"
#include "KwTools.h"
#include "CacheMgr.h"
#include "MessageManager.h"
#include "LyricParseTools.h"

#define LYRIC_CACHE_KEY_PREF    "Lyric"
#define LYRIC_CACHE_TIME_GRANU  T_DAY
#define LYRIC_CACHE_TIME_VALUE  1

CLyricRequest::CLyricRequest(const CSongInfoBase* pSong)
:m_pNotify(NULL)
,m_idNotify(nil)
,m_pAsyncHttpRequest(NULL)
,m_bSuccess(FALSE)
{
    assert(pSong);

    m_strBaseParas="type=lyric&songname=";
//    NSString* pSongName=[NSString stringWithUTF8String:pSong->strSongName.c_str()];
    NSString* pSongName=KwTools::Encoding::Utf82Gbk(pSong->strSongName.c_str());
    NSString* pEscapeSongName=KwTools::Encoding::UrlEncode(pSongName);
//    NSString* pArtist=[NSString stringWithUTF8String:pSong->strArtist.c_str()];
    NSString* pArtist=KwTools::Encoding::Utf82Gbk(pSong->strArtist.c_str());
    NSString* pEscapeArtist=KwTools::Encoding::UrlEncode(pArtist);
    m_strBaseParas+=[pEscapeSongName UTF8String];
    m_strBaseParas+="&artist=";
    m_strBaseParas+=[pEscapeArtist UTF8String];
    m_strBaseParas+="&rid="+pSong->strRid;
}

CLyricRequest::~CLyricRequest()
{
    if (m_pAsyncHttpRequest) {
        delete m_pAsyncHttpRequest;
    }
}

BOOL CLyricRequest::SyncRequestLyric(BOOL bWordForWord/*=TRUE*/)
{
    std::string strUrl=CreateUrl(bWordForWord);
    void* pData(NULL);
    unsigned len(0);

    if (!LoadFromCache(strUrl)) {
        
        if(!CHttpRequest::QuickSyncGet(strUrl, pData, len) || !len)
        {
            return FALSE;
        }
        m_bSuccess=ParseLyric(pData,len);
        if (m_bSuccess) {
            SaveToCache(strUrl, pData, len);
        }
        delete[] (char*)pData;
    }
    
    return m_bSuccess;
}

BOOL CLyricRequest::AsyncRequestLyric(ILyricNotify* pNotify
                                      ,BOOL bWordForWord/*=TRUE*/)
{
    m_pNotify=pNotify;
    std::string strUrl=CreateUrl(bWordForWord);
    if (LoadFromCache(strUrl)) {
        if (pNotify) {
            pNotify->ILyricNotify_Finished(this,TRUE);
        }
        return TRUE;
    }
    m_pAsyncHttpRequest=new CHttpRequest(strUrl);
    return m_pAsyncHttpRequest->AsyncSendRequest(this);
}

BOOL CLyricRequest::AsyncRequestLyric(id<ILyricNotify> idNotify
                                      ,BOOL bWordForWord/*=TRUE*/)
{
    m_idNotify=idNotify;
    std::string strUrl=CreateUrl(bWordForWord);
    if (LoadFromCache(strUrl)) {
        if (idNotify) {
            [idNotify ILyricNotify_Finished:this success:TRUE];
        }
        return TRUE;
    }
    m_pAsyncHttpRequest=new CHttpRequest(strUrl);
    return m_pAsyncHttpRequest->AsyncSendRequest(this);
}

std::string CLyricRequest::CreateUrl(BOOL bWordForWord)
{
    return KwTools::Encrypt::CreateDesUrl(m_strBaseParas+(bWordForWord?"&req=2":"&req=0"));

}

BOOL CLyricRequest::ParseLyric(void* pData,long len)
{
    if (!pData || len<60) {
        return FALSE;
    }
    std::vector<std::string> vecHead;
    std::string strHead;
    void* pRealData(NULL);
    for (char* p=(char*)pData;p!=((char*)pData)+len-4;++p) {
        if (*p=='\r' && *(p+1)=='\n' && *(p+2)=='\r' && *(p+3)=='\n') {//恶心了点，但因为\r\n\r\n距离开头很近，所以不用担心效率。
            std::string strHead((char*)pData,p-(char*)pData);
            KwTools::StringUtility::TokenizeEx(strHead, "\r\n", vecHead);
            pRealData=p+4;
            break;
        }
    }
    if (vecHead.size()!=2) {
        return FALSE;
    }
    size_t pos=vecHead[1].find('=');
    if (pos==std::string::npos) {
        return FALSE;
    }
    unsigned uiLrcx=KwTools::Convert::ConvertToDouble(vecHead[1].substr(pos+1));
    
    unsigned uiRawSize=*(unsigned*)LyricParseTools::Avoid_EX_ARM_DA_ALIGN(pRealData, sizeof(unsigned));
    unsigned uiDesSize=*(unsigned*)LyricParseTools::Avoid_EX_ARM_DA_ALIGN(sizeof(unsigned)+(char*)pRealData, sizeof(unsigned));

    if (uiLrcx>2 || uiRawSize>1024*1024 || uiDesSize>1024*1024) {
        return FALSE;
    }
    if ((char*)pRealData-(char*)pData+uiRawSize+2*sizeof(unsigned)!=len) {
        return FALSE;
    }
    
    LyricParseTools::Avoid_EX_ARM_DA_ALIGN(pRealData, &uiLrcx, sizeof(unsigned));
    if(!m_lyricInfo.ReadFromBuffer(pRealData, uiRawSize+2*sizeof(unsigned))){
        LyricParseTools::Avoid_EX_ARM_DA_ALIGN(pRealData, &uiRawSize, sizeof(unsigned));
        return FALSE;
    }
    LyricParseTools::Avoid_EX_ARM_DA_ALIGN(pRealData, &uiRawSize, sizeof(unsigned));

    m_bSuccess=TRUE;
    return TRUE;
}

BOOL CLyricRequest::LoadFromCache(const std::string& strUrl)
{
    std::string strCacheKey=LYRIC_CACHE_KEY_PREF+strUrl;
    if (CCacheMgr::GetInstance()->IsExist(strCacheKey)) {
        void* pData(NULL);
        unsigned len(0);
        BOOL bOutOfTime(FALSE);
        if(CCacheMgr::GetInstance()->Read(strCacheKey, pData, len, bOutOfTime) && len && !bOutOfTime)
        {
            m_bSuccess=ParseLyric(pData,len);
            delete[] (char*)pData;
        }
        if (!m_bSuccess) {
            CCacheMgr::GetInstance()->Delete(strCacheKey);
        }
    }
    return m_bSuccess;
}

BOOL CLyricRequest::SaveToCache(const std::string& strUrl,void* pData,unsigned len)
{
    if (len==0) {
        return FALSE;
    }
    std::string strCacheKey=LYRIC_CACHE_KEY_PREF+strUrl;
    return CCacheMgr::GetInstance()->Cache(LYRIC_CACHE_TIME_GRANU, LYRIC_CACHE_TIME_VALUE, strCacheKey, pData, len);
}

void CLyricRequest::Cancle()
{
    if (m_pAsyncHttpRequest) {
        m_pAsyncHttpRequest->StopRequest();
    }
    
    if (m_pNotify) {
        m_pNotify->ILyricNotify_Finished(this,FALSE);
    }
    if (m_idNotify) {
        [m_idNotify ILyricNotify_Finished:this success:FALSE];
    }
}

BOOL CLyricRequest::IsFinished()
{
    if (!m_pAsyncHttpRequest) {
        return FALSE;
    }
    return m_pAsyncHttpRequest->IsFinished();
}

BOOL CLyricRequest::IsSuccess()
{
    if (!m_pAsyncHttpRequest) {
        return FALSE;
    }
    return m_bSuccess;
}

CLyricInfo& CLyricRequest::GetLyricInfo()
{
    return m_lyricInfo;
}

void CLyricRequest::IHttpNotify_Stop(CHttpRequest* pRequest,BOOL bSuccess)
{
    if (bSuccess) {
        void* pData(NULL);
        unsigned len(0);
        if(pRequest->ReadAll(pData,len) && len)
        {
            if ( (m_bSuccess=ParseLyric(pData,len)) ) {
                if (m_pNotify) {
                    m_pNotify->ILyricNotify_Finished(this, TRUE);
                }
                if (m_idNotify) {
                    [m_idNotify ILyricNotify_Finished:this success:TRUE];
                }
                return;
            }
        }
    }
    if (m_pNotify) {
        m_pNotify->ILyricNotify_Finished(this, FALSE);
    }
    if (m_idNotify) {
        [m_idNotify ILyricNotify_Finished:this success:FALSE];
    }
}


