//
//  SearchRequest.h
//  KwSing
//
//  Created by Hu Qian on 12-11-20.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__SearchRequest__
#define __KwSing__SearchRequest__

#include <string>
#include <vector>
#include <map>
#include "SongInfo.h"

typedef std::vector<CSongInfoBase> SONG_LIST;
struct SearchParam
{
    std::string strword;    // 检索词
    unsigned pn;            // 第几页
    unsigned rn;            // 每页多少首
    
    SearchParam():pn(0),rn(50){}
};

class CSearchRequest
{
public:
    
    // 阻塞调用
    BOOL StartRequest(SearchParam &param);
    BOOL RequestNextPage();
    
    SONG_LIST & GetSongList(unsigned npage);

    unsigned GetHitNum();
    
    SearchParam GetCurSearchParam(){ return  m_searchParam; }

    CSearchRequest():m_nHitNum(0),m_nCurPage(0){}
    
protected:
    BOOL Search(SearchParam &param);
   
private:   
    std::map< unsigned,SONG_LIST > m_mapSongList;
    unsigned m_nHitNum;
    unsigned m_nCurPage;
    SearchParam m_searchParam;
};


class CSearchTipRequest
{
public:
    CSearchTipRequest(std::string strword):m_strWord(strword){}
    // 阻塞调用
    BOOL RequestTip();

    std::vector<std::string> & GetTips(){return m_vecTips;}

private:
    std::vector<std::string> m_vecTips;
    std::string m_strWord;
    unsigned m_nHitNum;
};


#endif /* defined(__KwSing__MusicLibRequest__) */
