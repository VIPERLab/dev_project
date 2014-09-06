//
//  PlayBookList.h
//  kwbook
//
//  Created by 单 永杰 on 13-12-2.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#ifndef __kwbook__PlayBookList__
#define __kwbook__PlayBookList__

#include <iostream>
#include "ChapterInfo.h"
#include <vector>

class CPlayBookList {
public:
    virtual ~CPlayBookList(){}
    
    static CPlayBookList* getInstance();
    
    BOOL addChapters(const std::vector<CChapterInfo*> vec_chapters);
    BOOL addChapter(CChapterInfo* chapter_info);
    
    CChapterInfo* getCurChapter()const;
    CChapterInfo* getPreChapter()const;
    CChapterInfo* getNextChapter()const;
    bool iSLocalChapter(const CChapterInfo* chapter_info)const;
    
    unsigned getCurPlayIndex()const;
    bool setCurPlayIndex(const unsigned un_index);
    
    unsigned getCurPos()const;
    bool setCurPos(const unsigned un_pos_mil_sec);
    
    unsigned getChapterCount()const;
    
    void resetPlayList();
    
    BOOL SavePlaylist();
    BOOL LoadPlaylist();
    
private:
    unsigned m_unCurIndex;
    unsigned m_unCurPos;
    std::vector<CChapterInfo *> m_vecChapterList;
private:
    CPlayBookList() : m_unCurIndex(0), m_unCurPos(0){
        LoadPlaylist();
    }
};

#endif /* defined(__kwbook__PlayBookList__) */