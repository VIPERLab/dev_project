//
//  BookManagement.h
//  kwbook
//
//  Created by 单 永杰 on 14-1-6.
//  Copyright (c) 2014年 单 永杰. All rights reserved.
//

#ifndef __kwbook__BookManagement__
#define __kwbook__BookManagement__

#include <iostream>
#include <map>
#include <vector>
#include <set>

#ifndef kwbook_BookInfo_h
#include "BookInfo.h"
#endif

#ifndef kwbook_ChapterInfo_h
#include "ChapterInfo.h"
#endif

class CBookManagement {
private:
    CBookManagement(){}
public:
    virtual~ CBookManagement(){}
    
    static CBookManagement* GetInstance();
    
    void AddBook(CBookInfo* book_info);
    CBookInfo* GetBookInfo(std::string str_book_id);
    std::vector<CBookInfo*>& GetBookList();
    
    void AddChapter(CChapterInfo* chapter_info);
    void AddChapterFromDB(CChapterInfo* chapter_info);
//    void AddChapters(std::vector<CChapterInfo*>& vec_chapter);
    
    void DeleteChapter(CChapterInfo* chapter_info);
    void DeleteChapters(std::string str_book_id);
    void DeleteChapters(std::string str_book_id, bool b_finished);
    
    void ResetChapter(CChapterInfo* chapter_info);
    CChapterInfo* GetChapterInfo(std::string str_book_id, int n_rid);
    
    bool HasBook(std::string str_book_id);
    bool HasChapter(int n_rid);
    
    std::vector<CChapterInfo*>* GetChapterList(std::string str_book_id);
    
    void GetBookDownList(std::string str_book_id, std::vector<CChapterInfo*>&, std::vector<CChapterInfo*>&);
    
    void SortChapter();
    
    void ClearBuffer();
    
private:
    std::map<std::string, std::vector<CChapterInfo*>* >  m_BookDetailList;
    std::vector<CBookInfo*> m_BookList;
    std::set<int> m_ChapterSet;
};

#endif /* defined(__kwbook__BookManagement__) */
