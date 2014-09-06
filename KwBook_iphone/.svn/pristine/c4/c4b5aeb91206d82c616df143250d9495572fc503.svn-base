//
//  BookInfoList.h
//  kwbook
//
//  Created by 单 永杰 on 13-12-19.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#ifndef __kwbook__BookInfoList__
#define __kwbook__BookInfoList__

#include <iostream>
#include <vector>
#include <map>
#include "BookInfo.h"

class CBookInfoList {
private:
    CBookInfoList();
    
    std::vector<CBookInfo*> m_vecBookList;
    std::map<std::string, CBookInfo*> m_mapBookInfo;
    BOOL deleteBook(std::string str_book_id);
    BOOL SaveAllBooks();
    BOOL LoadAllBooks();
    
public:
    virtual~ CBookInfoList(){};
    
    static CBookInfoList* getInstance();
    
    BOOL addBook(CBookInfo* book_info);
    CBookInfo* getBookInfo(std::string str_book_id)const;
};

#endif /* defined(__kwbook__BookInfoList__) */
