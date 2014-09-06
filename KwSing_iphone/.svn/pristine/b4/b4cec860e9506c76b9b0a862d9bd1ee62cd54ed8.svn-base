//
//  RanksListRequest.h
//  KwSing
//
//  Created by Hu Qian on 12-11-21.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__RanksListRequest__
#define __KwSing__RanksListRequest__

#include <iostream>
#include <string>
#include <vector>
#include <map>
#include "SongInfo.h"

enum ListType
{
    eRankMusic,
    eArtistMusic
};
struct 	ListInfo                    // 榜单数据节点
{
    ListType type;
    
    std::string strID;
    std::string strDigest;
	std::string strName;
	std::string strPicUrl;  		// 榜单图片url
    
    int nCount;
    
    ListInfo():strID(""),nCount(0),type(eRankMusic){}
};

enum RankType
{
    eMusicRank,
    eArtistRank
};

#define CACHEOUTTIME         3*60*60 // 3个小时

//榜单采用的是先取缓存，再更新数据对策略
class CRanksListRequest
{
public:
    CRanksListRequest(RankType type);
    //立即返回
    std::vector<ListInfo> &QuickGetList();
    //阻塞调用
    BOOL UpdateList();
    
    std::vector<ListInfo>& GetRankList(){return m_vecList;}
    
protected:
    std::string GetRankUrl();
    BOOL ParseRanksList(const char *buffer,int size);
    std::string GetCacheKey();
    void InitSig();
    
private:
    std::vector<ListInfo> m_vecList;
    RankType m_type;
    std::string m_strSig;
};


#endif /* defined(__KwSing__RanksListRequest__) */
