//
//  ArtistListRequest.h
//  KwSing
//
//  Created by Hu Qian on 12-11-22.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__ArtistListRequest__
#define __KwSing__ArtistListRequest__

#include <iostream>
#include <string>
#include <vector>
#include <map>
#import "RanksListRequest.h"

typedef std::vector<ListInfo> ARTIST_LIST;


class CArtistListRequest
{
public:
    CArtistListRequest(ListInfo info);
    
    // 阻塞调用
    BOOL StartRequest();

    std::map< std::string,ARTIST_LIST >& GetArtistList();
    std::vector<std::string> & GetArtistKey(){return m_vecKey;}
    
protected:
    BOOL ParseArtistList(const char *buffer,int size);
    std::string GetUrl();
    void InitSig();
    std::string GetCacheKey();
    
private:
    std::vector<std::string> m_vecKey;
    std::map< std::string,ARTIST_LIST > m_mapArtistList;
    ListInfo m_RootInfo;
    std::string m_strSig;
};

#endif /* defined(__KwSing__ArtistListRequest__) */
