//
//  ArtistListRequest.cpp
//  KwSing
//
//  Created by Hu Qian on 12-11-22.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "ArtistListRequest.h"
#include "KwTools.h"
#include "MessageManager.h"
#include "HttpRequest.h"
#include "CacheMgr.h"
#include <libxml/parser.h>
#include "AutoPtr.h"


CArtistListRequest::CArtistListRequest(ListInfo info)
{
    m_RootInfo = info;
    InitSig();
}

BOOL CArtistListRequest::StartRequest()
{
    std::string strUrl=GetUrl();
    std::string strData;
    
    bool breadcache = false;
    std::string strCacheKey = GetCacheKey();
    NSDate *date = CCacheMgr::GetInstance()->GetSaveTime(strCacheKey);
    double dtemp = [date timeIntervalSinceNow];
    dtemp = -dtemp;
    if(date && dtemp < CACHEOUTTIME)
    {
        breadcache = true;
    }
    else
    {
        CHttpRequest req(strUrl);
        void* pData(NULL);
        unsigned uiLen(0);
        if(req.SyncSendRequest() && req.ReadAll(pData, uiLen))
        {
            ((char*)pData)[uiLen] = '\0';
            strData = (char*)pData;
            delete[] (char*)pData;
            CCacheMgr::GetInstance()->Cache(T_YEAR, 1, strCacheKey,strData.c_str(),strData.length());
        }
        else
        {
            unsigned retcode = req.GetRetCode();
            if(retcode == 304)
            {
                CCacheMgr::GetInstance()->UpdateTimeToNow(strCacheKey);
            }
            breadcache = true;
        }
    }
    
    if(breadcache)
    {
        void* pData(NULL);
        unsigned uiLen(0);
        BOOL bouttime;
        if(CCacheMgr::GetInstance()->Read(strCacheKey, pData, uiLen,bouttime) && uiLen>0)
        {
            ((char*)pData)[uiLen] = '\0';
            strData = (char*)pData;
            delete[] (char*)pData;
        }
        else
            return false;
        
    }
    //NSLog(@"%@",[NSString stringWithUTF8String:strData.c_str()]);
    KS_BLOCK_DECLARE
    {
        ParseArtistList(strData.c_str(), strData.length());
    }
    KS_BLOCK_SYNRUN();
    
    return true;
}

std::map< std::string,ARTIST_LIST >& CArtistListRequest::GetArtistList()
{
    return m_mapArtistList;
}


BOOL CArtistListRequest::ParseArtistList(const char *buffer,int size)
{
    if(size < 2)
        return false;
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
        m_mapArtistList.clear();
        m_vecKey.clear();
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
                    std::string strSection;
                    if ((value = xmlGetProp(node, BAD_CAST "name")))
                    {
                        bret = true;
                        strSection = (const char*)value;
                        m_mapArtistList[strSection] = ARTIST_LIST();
                        
                        ARTIST_LIST & vecArtistList = m_mapArtistList[strSection];
                        for (xmlNodePtr curNode = node->children;
                             NULL != curNode; curNode = curNode->next)
                        {
                            if (curNode->type != XML_ELEMENT_NODE)
                                continue;
                            
                            ListInfo info;
                            const char* name = (const char*)curNode->name;
                            if (strcmp(name, "artist") == 0)
                            {
                                info.type = eArtistMusic;
                                if ((value = xmlGetProp(curNode, BAD_CAST "id")))
                                {
                                    info.strID = (const char*)value;
                                }
                                if ((value = xmlGetProp(curNode, BAD_CAST "name")))
                                {
                                    info.strName = (const char*)value;
                                }
                                if ((value = xmlGetProp(curNode, BAD_CAST "img")))
                                {
                                    info.strPicUrl = (const char*)value;
                                }
                                if ((value = xmlGetProp(curNode, BAD_CAST "num")))
                                {
                                    info.nCount = atoi((const char*)value);
                                }
                                
                                if(info.strID!="")
                                    vecArtistList.push_back(info);
                            }
                            
                        }
                        if(vecArtistList.size() != 0)
                            m_vecKey.push_back(strSection);
                    }
                    
                }
                
            }
        }
	}
	
	xmlFreeDoc(doc);
    return bret;

}

std::string CArtistListRequest::GetUrl()
{
    std::string strid;
    std::string strparam = KwTools::StringUtility::Format("type=subcatalog&id=%s&digest=%s&sig=%s",
                                                          m_RootInfo.strID.c_str(),m_RootInfo.strDigest.c_str(),m_strSig.c_str());
    std::string strUrl=KwTools::Encrypt::CreateDesUrl(strparam.c_str());
    return strUrl;
}

void CArtistListRequest::InitSig()
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
        std::string strtemp = strdata.substr(0,strdata.find("\r\n"));
        if(strtemp.find("sig=") == 0)
        {
            m_strSig = strtemp.substr(4,-1);
        }
        delete[] (char*)pData;
    }
}

std::string CArtistListRequest::GetCacheKey()
{
    std::string strid;
    std::string strparam = KwTools::StringUtility::Format("type=subcatalog&id=%s&digest=%s",
                                                          m_RootInfo.strID.c_str(),m_RootInfo.strDigest.c_str());
    std::string strUrl=KwTools::Encrypt::CreateDesUrl(strparam.c_str());
    return strUrl;
}
