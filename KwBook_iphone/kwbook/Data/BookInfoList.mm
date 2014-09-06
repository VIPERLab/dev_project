
//
//  BookInfoList.cpp
//  kwbook
//
//  Created by 单 永杰 on 13-12-19.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#define FILENAME_BOOK_LIST @"bookInfoList.plist"

#include "BookInfoList.h"
#include "KwTools.h"

CBookInfoList * CBookInfoList::getInstance(){
    static CBookInfoList sInstance;
    
    return &sInstance;
}

CBookInfoList::CBookInfoList(){
    LoadAllBooks();
}

BOOL CBookInfoList::addBook(CBookInfo* recent_book){
    if (m_mapBookInfo.end() == m_mapBookInfo.find(recent_book->m_strBookId)) {
        CBookInfo* cur_book = new CBookInfo;
        *((CBookInfo*)cur_book) = *recent_book;
        m_vecBookList.push_back(cur_book);
        m_mapBookInfo.insert(std::pair<std::string, CBookInfo*>(cur_book->m_strBookId, cur_book));
    }else {
        CBookInfo* book_info = m_mapBookInfo.find(recent_book->m_strBookId)->second;
        *book_info = *recent_book;
    }
    
    SaveAllBooks();
    
    return YES;
}

BOOL CBookInfoList::deleteBook(std::string str_book_id){
    
    if (m_mapBookInfo.end() != m_mapBookInfo.find(str_book_id)){
        for (std::vector<CBookInfo *>::iterator iter = m_vecBookList.begin(); iter!= m_vecBookList.end(); iter++) {
            if(str_book_id == (*iter)->m_strBookId)
            {
                m_vecBookList.erase(iter);
                break;
            }
        }
        
        delete m_mapBookInfo.find(str_book_id)->second;
        m_mapBookInfo.find(str_book_id)->second = NULL;
        
        m_mapBookInfo.erase(str_book_id);
    }
    
    return YES;
}

BOOL CBookInfoList::SaveAllBooks(){
    NSMutableArray *arrTask = [NSMutableArray arrayWithCapacity:m_vecBookList.size()];
    for (std::vector<CBookInfo *>::iterator iter = m_vecBookList.begin(); iter!= m_vecBookList.end(); iter++) {
        CBookInfo* temp = ((CBookInfo*)(*iter));
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        temp->SaveToDict(dict);
        [arrTask addObject:dict];
    }
    
    NSString *filepath = KwTools::Dir::GetPath(KwTools::Dir::PATH_DUCUMENT);
    NSString *str = [filepath stringByAppendingPathComponent:FILENAME_BOOK_LIST];
    if(KwTools::Dir::IsExistFile([str UTF8String]) && !KwTools::Dir::DeleteFile(str))
    {
        return false;
    }
    BOOL bret = [arrTask writeToFile:str atomically:YES];
    
    return bret;
}

BOOL CBookInfoList::LoadAllBooks(){
    m_vecBookList.clear();
    NSString *filepath = KwTools::Dir::GetPath(KwTools::Dir::PATH_DUCUMENT);
    filepath = [filepath stringByAppendingPathComponent:FILENAME_BOOK_LIST];
    NSMutableArray *arrLocalTask;
    if(KwTools::Dir::IsExistFile(filepath))
    {
        arrLocalTask = [NSMutableArray arrayWithContentsOfFile:filepath];
        for (NSDictionary *dict in arrLocalTask)
        {
            CBookInfo * bookInfo = new CBookInfo;
            ((CBookInfo*)bookInfo)->LoadFromDict(dict);
            
            m_vecBookList.push_back(bookInfo);
            m_mapBookInfo.insert(std::pair<std::string, CBookInfo*>(bookInfo->m_strBookId, bookInfo));
            
            
        }
    }
    
    return TRUE;
}

CBookInfo* CBookInfoList::getBookInfo(std::string str_book_id)const{
    if (m_mapBookInfo.end() == m_mapBookInfo.find(str_book_id)) {
        return NULL;
    }else {
        return m_mapBookInfo.find(str_book_id)->second;
    }
}