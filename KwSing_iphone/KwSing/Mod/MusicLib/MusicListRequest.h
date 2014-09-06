//
//  MusicListRequest.h
//  KwSing
//
//  Created by Hu Qian on 12-11-21.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__MusicListRequest__
#define __KwSing__MusicListRequest__

#include <string>
#include <vector>
#include <map>
#include "SongInfo.h"
#include "RanksListRequest.h"

typedef std::vector<CSongInfoBase> SONG_LIST;
#define NUM_ONE_PAGE    50

//榜单采用的是先取缓存，再更新数据对策略
class CMusicListRequest
{
public:
    CMusicListRequest(ListInfo info);
    
    // 阻塞调用
    BOOL RequestPage(unsigned npage);
    BOOL RequestNextPage();
    std::vector<CSongInfoBase>& GetSongList();
    int GetCurPage(){return m_curpage;}
    int GetTotalSongNum(){return m_ListInfo.nCount; }
    
protected:
    BOOL ParseMusicList(const char *buffer,int size);
    std::string GetUrl(unsigned npage);
    void InitSig();
    std::string GetCacheKey(unsigned npage);
private:
    //std::map< unsigned,SONG_LIST > m_mapSongList;
    std::vector<CSongInfoBase> m_vecCurPageSong;
    ListInfo m_ListInfo;
    int m_curpage;
    std::string m_strSig;
};




#endif /* defined(__KwSing__MusicListRequest__) */
