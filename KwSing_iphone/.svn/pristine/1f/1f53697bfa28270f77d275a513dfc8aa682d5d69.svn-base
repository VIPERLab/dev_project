//
//  RanksListRequest.cpp
//  KwSing
//
//  Created by Hu Qian on 12-11-21.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "RanksListRequest.h"
#include "KwTools.h"
#include "MessageManager.h"
#include "HttpRequest.h"
#include "CacheMgr.h"
#include "KwConfig.h"
#include <libxml/parser.h>
#include "AutoPtr.h"
#include "KuwoLog.h"
#include "KwUMengElement.h"
#include "UMengLog.h"

CRanksListRequest::CRanksListRequest(RankType type):m_type(type)
{
    InitSig();
}

void CRanksListRequest::InitSig()
{
    std::string strkey = GetCacheKey();
    m_strSig = "";
    void* pData(NULL);
    unsigned uiLen(0);
    BOOL bouttime;
    if(CCacheMgr::GetInstance()->Read(strkey, pData, uiLen,bouttime) && uiLen>0)
    {
        ((char*)pData)[uiLen] = '\0';
        std::string strdata = (char*)pData;
        delete[] (char*)pData;
        std::string strtemp = strdata.substr(0,strdata.find("\r\n"));
        if(strtemp.find("sig=") == 0)
        {
            m_strSig = strtemp.substr(4,-1);
        }
       
    }

}

std::string CRanksListRequest::GetRankUrl()
{
    std::string strid;
    if(m_type == eMusicRank)
        strid = "2";
    else if(m_type == eArtistRank)
        strid = "3";
    std::string strparam = KwTools::StringUtility::Format("type=catalog&id=%s&sig=%s",strid.c_str(),m_strSig.c_str());
    std::string strUrl=KwTools::Encrypt::CreateDesUrl(strparam.c_str());
    return strUrl;
}

std::string CRanksListRequest::GetCacheKey()
{
    std::string strid;
    if(m_type == eMusicRank)
        strid = "2";
    else if(m_type == eArtistRank)
        strid = "3";
    std::string strparam = KwTools::StringUtility::Format("type=catalog&id=%s",strid.c_str());
    std::string strUrl=KwTools::Encrypt::CreateDesUrl(strparam.c_str());
    return strUrl;
}

std::vector<ListInfo> & CRanksListRequest::QuickGetList()
{
    std::string strCacheKey = GetCacheKey();
    void* pData(NULL);
    unsigned uiLen(0);
    BOOL bouttime;
    if(CCacheMgr::GetInstance()->Read(strCacheKey, pData, uiLen,bouttime) && uiLen>0)
    {
        ((char*)pData)[uiLen] = '\0';
        ParseRanksList((char*)pData, uiLen);
        delete[] (char*)pData;
//        if(bouttime)
//            CCacheMgr::GetInstance()->UpdateTimeToNow(strCacheKey);
    }
    
    return m_vecList;
}

BOOL CRanksListRequest::UpdateList()
{
    std::string strCacheKey = GetCacheKey();
    NSDate *date = CCacheMgr::GetInstance()->GetSaveTime(strCacheKey);
    double dtemp = [date timeIntervalSinceNow];
    dtemp = -dtemp;
    if(date && dtemp < CACHEOUTTIME)
        return true;
    
    std::string strUrl=GetRankUrl();
    CHttpRequest req(strUrl);
    void* pData(NULL);
    unsigned uiLen(0);
    if(req.SyncSendRequest() && req.ReadAll(pData, uiLen))
    {
        ((char*)pData)[uiLen] = '\0';
        RTLog_DownloadSongList(AR_SUCCESS,CHttpRequest::GetNetWorkProviderName().c_str(),"K歌曲库");
        UMengLog(KS_DOWN_SONGLIST, "0");
        CCacheMgr::GetInstance()->Cache(T_YEAR, 1, strCacheKey, ((char*)pData), uiLen);
        KS_BLOCK_DECLARE
        {
            ParseRanksList(((char*)pData), uiLen);
        }
        KS_BLOCK_SYNRUN();
        delete[] (char*)pData;
    }
    else
    {
        unsigned retcode = req.GetRetCode();
        if(retcode == 304)
        {
            CCacheMgr::GetInstance()->UpdateTimeToNow(strCacheKey);
        }
        else
        {
            RTLog_DownloadSongList(AR_FAIL,CHttpRequest::GetNetWorkProviderName().c_str(),"K歌曲库");
            UMengLog(KS_DOWN_SONGLIST, "1");
            return false;
        }
    }

    return true;
}

BOOL CRanksListRequest::ParseRanksList(const char *buffer,int size)
{
    std::string strdata = buffer;
    strdata = strdata.substr(strdata.find("\r\n") + 2,-1);
    xmlDocPtr doc = xmlParseMemory(strdata.c_str(), strdata.size());
	if (!doc)
		return FALSE;
	
    BOOL bret = false;
	if (xmlNodePtr root = xmlDocGetRootElement(doc))
	{
       	if (0 != strcmp((const char*)root->name, "root"))
        {
            return FALSE;
        }
        
        for (xmlNodePtr node = root->children;
             NULL != node; node = node->next)
        {
            if (node->type != XML_ELEMENT_NODE)
                continue;
            if (strcmp((const char*)node->name, "section") == 0)
            {
                CAutoXmlCharPtr value;
                if ((value = xmlGetProp(node, BAD_CAST "type")) && strcmp((const char*)value, "list") == 0)
                {
                    bret = true;
                    m_vecList.clear();
                    for (xmlNodePtr curNode = node->children;
                         NULL != curNode; curNode = curNode->next)
                    {
                        if (curNode->type != XML_ELEMENT_NODE)
                            continue;
                        
                        ListInfo info;
                        const char* name = (const char*)curNode->name;
                        if (strcmp(name, "list") == 0)
                        {
                            if ((value = xmlGetProp(curNode, BAD_CAST "id")))
                            {
                                info.strID = (const char*)value;
                            }
                            if ((value = xmlGetProp(curNode, BAD_CAST "digest")))
                            {
                                info.strDigest = (const char*)value;
                            }
                            if ((value = xmlGetProp(curNode, BAD_CAST "name")))
                            {
                                info.strName = (const char*)value;
                            }
                            if ((value = xmlGetProp(curNode, BAD_CAST "img")))
                            {
                                info.strPicUrl = (const char*)value;
                            }
                            if(info.strID!="")
                                m_vecList.push_back(info);
                        }
                        
                    }
                }
                
            }
        }
	}
	
	xmlFreeDoc(doc);
    return bret;
}

