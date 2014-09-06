//
//  SearchRequest.mm
//  KwSing
//
//  Created by Hu Qian on 12-11-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "SearchRequest.h"
#include "KwTools.h"
#include "MessageManager.h"
#include "HttpRequest.h"
#include "CacheMgr.h"
#import "RanksListRequest.h"
#include "KuwoLog.h"
#include "KwUMengElement.h"
#include "UMengLog.h"

static KwTools::CLock s_RequestLock;

BOOL CSearchRequest::StartRequest(SearchParam &param)
{
    m_mapSongList.clear();
    return  Search(param);
}

BOOL CSearchRequest::Search(SearchParam &param)
{
    s_RequestLock.Lock();
    m_searchParam = param;
    std::string strword = KwTools::Encoding::UrlEncode(param.strword);
    std::string strparam = KwTools::StringUtility::Format("filt=0&type=music&all=%s&pn=%d&rn=%d",strword.c_str(),param.pn,param.rn);
    std::string strUrl=KwTools::Encrypt::CreateDesUrl(strparam.c_str());
    std::string strData;
    void* pData(NULL);
    unsigned uiLen(0);
    BOOL bouttime;
    if(CCacheMgr::GetInstance()->Read(strUrl, pData, uiLen,bouttime) && uiLen>0 && !bouttime)
    {
        ((char*)pData)[uiLen] = '\0';
        strData = (char*)pData;
        delete[] (char*)pData;
    }
    else if(!CHttpRequest::QuickSyncGet(strUrl, strData) || strData.empty())
    {
        RTLog_SearchMusic(AR_FAIL,CHttpRequest::GetNetWorkProviderName().c_str(),param.strword.c_str());
        UMengLog(KS_SEARCH_MUSIC, "Search_Fail");
        s_RequestLock.UnLock();
        return  false;
    }
    else
    {
        RTLog_SearchMusic(AR_SUCCESS,CHttpRequest::GetNetWorkProviderName().c_str(),param.strword.c_str());
        UMengLog(KS_SEARCH_MUSIC, "TP=none" == strData ? "Search_Success_No_Result" : "Search_Success_Has_Result");
    }
    
    if(strData == "TP=none")
    {
        KS_BLOCK_DECLARE
        {
            m_nHitNum = 0;
        }
        KS_BLOCK_SYNRUN();
        s_RequestLock.UnLock();
        return true;
    }
    std::vector<std::string> vecData;
    KwTools::StringUtility::TokenizeEx(strData, "\r\n\r\n", vecData);
    if(vecData.empty())
    {
        s_RequestLock.UnLock();
       // NSLog(@"parse error,url:%s data:%s",strUrl.c_str(),strData.c_str());
        return false;
    }
    //NSLog(@"%@",[NSString stringWithUTF8String:strData.c_str()]);

    CCacheMgr::GetInstance()->Cache(T_DAY, 1, [NSString stringWithUTF8String:strUrl.c_str()], [NSString stringWithUTF8String:strData.c_str()]);

    s_RequestLock.UnLock();
    KS_BLOCK_DECLARE
    {
        m_mapSongList[param.pn] = std::vector<CSongInfoBase>();
        std::vector<CSongInfoBase> &vecTempSong = m_mapSongList[param.pn];
        for (size_t i = 0; i < vecData.size(); i++) {
            std::map<std::string,std::string> mapDatas;
            KwTools::StringUtility::TokenizeKeyValueEx(vecData[i],mapDatas,"\r\n");
            if (mapDatas.empty() && i != 0) {
                continue;
            }
            if(i==0)
            {
                if( mapDatas["TP"] == "list")
                {
                    std::string strtemp = mapDatas["HIT"];
                    m_nHitNum = atoi(mapDatas["HIT"].c_str());
                    if(m_nHitNum == 0)
                        break;
                }
                else
                    break;
            }
            else
            {
                vecTempSong.push_back(CSongInfoBase());
                CSongInfoBase &songinfo =  vecTempSong[vecTempSong.size()-1];
                std::string strid = mapDatas["MUSICRID"];
                if(strid.size() > 6)
                    songinfo.strRid = strid.substr(6,-1);
                else
                {
                    //NSLog(@"search return error data!");
                    continue;
                }
                songinfo.strSongName = mapDatas["SONGNAME"];
                songinfo.strAlbum = mapDatas["ALBUM"];
                songinfo.strArtist = mapDatas["ARTIST"];
            }
        }
    }
    KS_BLOCK_SYNRUN();

    return true;
}

BOOL CSearchRequest::RequestNextPage()
{
    SearchParam param = m_searchParam;
    param.pn++;
    return Search(param);
}

unsigned CSearchRequest::GetHitNum()
{
    return m_nHitNum;
}

SONG_LIST & CSearchRequest::CSearchRequest::GetSongList(unsigned npage)
{
    std::map<unsigned,SONG_LIST >::iterator ite = m_mapSongList.find(npage);
    if (ite!=m_mapSongList.end()) {
        return ite->second;
    }
    static SONG_LIST sPageSongs;
    return sPageSongs;
}

//////////////////////////////////////////
BOOL CSearchTipRequest::RequestTip()
{
    std::string strword = KwTools::Encoding::UrlEncode(m_strWord);
    std::string strparam = KwTools::StringUtility::Format("type=tips&word=%s&encoding=utf8",strword.c_str());
    std::string strUrl=KwTools::Encrypt::CreateDesUrl(strparam.c_str());
    std::string strData;
    void* pData(NULL);
    unsigned uiLen(0);
    BOOL bouttime;
    if(CCacheMgr::GetInstance()->Read(strUrl, pData, uiLen,bouttime) && uiLen>1 && !bouttime)
    {
        ((char*)pData)[uiLen] = '\0';
        //NSLog(@"read cache tip!%s",strword.c_str());
        strData = (char*)pData;
    }
    else
    {
        NSError *error = nil;
        NSString * strResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithUTF8String:strUrl.c_str()]] encoding:NSUTF8StringEncoding error:&error];
        if(error != nil || strResult == nil)
            return false;

        strData = [strResult UTF8String];
        CCacheMgr::GetInstance()->Cache(T_MONTH, 1, strUrl , strData.c_str()  ,strData.length());
        //NSLog(@"http request tip!%s",strword.c_str());
        
//        CHttpRequest req(strUrl);
//        req.SetTimeOut(5000);
//        if(!req.SyncSendRequest() || !req.ReadAll(pData, uiLen))
//            return  false;
//        else
//            CCacheMgr::GetInstance()->Cache(T_MONTH, 1, strUrl , pData,uiLen);
//        NSLog(@"http request tip!%s",strword.c_str());
//        ((char*)pData)[uiLen] = '\0';
//        strData = (char*)pData;
    }
    
    //strData = (char*)pData;
    if(strData == "HITNUM=0\r\n\r\n")
        return true;
    
    std::vector<std::string> vecData;
    KwTools::StringUtility::TokenizeEx(strData, "\r\n\r\n", vecData);
    if(vecData.empty())
    {
        //NSLog(@"parse error,url:%s data:%s",strUrl.c_str(),strData.c_str());
        return false;
    }
    //NSLog(@"%@",[NSString stringWithUTF8String:strData.c_str()]);
    if(pData)
        delete[] (char*)pData;
    
    KS_BLOCK_DECLARE
    {
        for (size_t i = 0; i < vecData.size(); i++) {
            std::map<std::string,std::string> mapDatas;
            KwTools::StringUtility::TokenizeKeyValueEx(vecData[i],mapDatas,"\r\n");
            if (mapDatas.empty()  && i != 0)
            {
                continue;
            }
            if(i==0)
            {
                m_nHitNum = atoi(mapDatas["HITNUM"].c_str());
            }
            else
            {
                std::string strret = mapDatas["RELWORD"];
                m_vecTips.push_back(strret);
            }
        }
    }
    KS_BLOCK_SYNRUN();
    
    return true;
}
