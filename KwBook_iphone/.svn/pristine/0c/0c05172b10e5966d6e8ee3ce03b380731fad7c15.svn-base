//
//  RecentBookInfo.h
//  kwbook
//
//  Created by 单 永杰 on 13-11-29.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#ifndef kwbook_RecentBookInfo_h
#define kwbook_RecentBookInfo_h

#include "BookInfo.h"

class CRecentBookInfo : public CBookInfo {
public:
    CRecentBookInfo() : m_unRid(0), m_unIndex(0), m_unPosMilSec(0){};
    void LoadFromDict(NSDictionary* dict);
    void SaveToDict(NSMutableDictionary* dict);
    
public:
    unsigned m_unRid;
    unsigned m_unIndex;
    unsigned m_unPosMilSec;//毫秒
};

#endif
