//
//  RecentBookList.h
//  kwbook
//
//  Created by 单 永杰 on 13-12-2.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#ifndef __kwbook__RecentBookList__
#define __kwbook__RecentBookList__

#include <iostream>
#include <vector.h>
#include "RecentBookInfo.h"

class CRecentBookList {
public:
    virtual ~CRecentBookList(){}
    static CRecentBookList * GetInstance();
    void AddBookInfo(CRecentBookInfo* recent_book);
    void DeleteBookInfo(const unsigned& un_book_id);
    CRecentBookInfo* GetCurBook(const unsigned& un_book_id);
    
    std::vector<CRecentBookInfo*>& GetLocalBookVec()
    {
        return m_vecRecentList;
    }
    
    BOOL SaveAllBooks();
private:
    std::vector<CRecentBookInfo *> m_vecRecentList;
private:
    CRecentBookList();
    
    BOOL LoadAllBooks();
};

#endif /* defined(__kwbook__RecentBookList__) */