//
//  BookManagement.cpp
//  kwbook
//
//  Created by 单 永杰 on 14-1-6.
//  Copyright (c) 2014年 单 永杰. All rights reserved.
//

#import "BookManagement.h"
#import "LocalTask.h"
#import "BookInfoList.h"
#import "KBDatabaseManagement.h"
#include <algorithm>
#include "KwTools.h"

CBookManagement* CBookManagement::GetInstance(){
    static CBookManagement s_book_management;
    
    return &s_book_management;
}

void CBookManagement::AddBook(CBookInfo* book_info){
    for (std::vector<CBookInfo*>::iterator iter_book = m_BookList.begin(); iter_book != m_BookList.end(); ++iter_book) {
        if (book_info->m_strBookId == (*iter_book)->m_strBookId) {
            return;
        }
    }
    
    CBookInfo* cur_book = new CBookInfo;
    *cur_book = *book_info;
    m_BookList.push_back(cur_book);
}

CBookInfo* CBookManagement::GetBookInfo(std::string str_book_id){
    for (std::vector<CBookInfo*>::iterator iter_book = m_BookList.begin(); iter_book != m_BookList.end(); ++iter_book) {
        if (str_book_id == (*iter_book)->m_strBookId) {
            return *iter_book;
        }
    }
    
    return NULL;
}

std::vector<CBookInfo*>& CBookManagement::GetBookList(){
    return m_BookList;
}

CChapterInfo* CBookManagement::GetChapterInfo(std::string str_book_id, int n_rid){
    std::map<std::string, std::vector<CChapterInfo*>* >::iterator iter = m_BookDetailList.find(str_book_id);
    if (m_BookDetailList.end() != iter) {
        std::vector<CChapterInfo*>* p_vec_chapter = iter->second;
        for (std::vector<CChapterInfo*>::iterator iter = p_vec_chapter->begin(); iter != p_vec_chapter->end(); ++iter) {
            if (n_rid == (*iter)->m_unRid) {
                return *iter;
            }
        }
    }
    
    return NULL;
}

void CBookManagement::AddChapterFromDB(CChapterInfo* chapter_info){
    if (HasBook(chapter_info->m_strBookId)) {
        if (HasChapter(chapter_info->m_unRid)) {
            return;
        }
        CChapterInfo* cur_chapter = new CLocalTask;
        *cur_chapter = *chapter_info;
        ((CLocalTask*)cur_chapter)->taskStatus = ((CLocalTask*)chapter_info)->taskStatus;
        ((CLocalTask*)cur_chapter)->downStatus = ((CLocalTask*)chapter_info)->downStatus;
        
        m_BookDetailList.find(cur_chapter->m_strBookId)->second->push_back(cur_chapter);
    }else {
        std::vector<CChapterInfo*>* vec_book = new std::vector<CChapterInfo*>;
        CChapterInfo* cur_chapter = new CLocalTask;
        *cur_chapter = *chapter_info;
        ((CLocalTask*)cur_chapter)->taskStatus = ((CLocalTask*)chapter_info)->taskStatus;
        ((CLocalTask*)cur_chapter)->downStatus = ((CLocalTask*)chapter_info)->downStatus;
        
        vec_book->push_back(cur_chapter);
        m_BookDetailList.insert(std::map<std::string, std::vector<CChapterInfo*>*>::value_type(cur_chapter->m_strBookId, vec_book));
    }
    
    m_ChapterSet.insert(chapter_info->m_unRid);
}

void CBookManagement::AddChapter(CChapterInfo* chapter_info){
    if (HasBook(chapter_info->m_strBookId)) {
        if (HasChapter(chapter_info->m_unRid)) {
            return;
        }
        CChapterInfo* cur_chapter = new CLocalTask;
        *cur_chapter = *chapter_info;
        ((CLocalTask*)cur_chapter)->taskStatus = ((CLocalTask*)chapter_info)->taskStatus;
        ((CLocalTask*)cur_chapter)->downStatus = ((CLocalTask*)chapter_info)->downStatus;
        
        m_BookDetailList.find(cur_chapter->m_strBookId)->second->push_back(cur_chapter);
    }else {
        std::vector<CChapterInfo*>* vec_book = new std::vector<CChapterInfo*>;
        CChapterInfo* cur_chapter = new CLocalTask;
        *cur_chapter = *chapter_info;
        ((CLocalTask*)cur_chapter)->taskStatus = ((CLocalTask*)chapter_info)->taskStatus;
        ((CLocalTask*)cur_chapter)->downStatus = ((CLocalTask*)chapter_info)->downStatus;
        
        vec_book->push_back(cur_chapter);
        m_BookDetailList.insert(std::map<std::string, std::vector<CChapterInfo*>*>::value_type(cur_chapter->m_strBookId, vec_book));
        CBookInfo* cur_book = new CBookInfo;
        *cur_book = *CBookInfoList::getInstance()->getBookInfo(chapter_info->m_strBookId);
        
        [[KBDatabaseManagement sharedInstance] addBook:cur_book];
        m_BookList.push_back(cur_book);
    }
    
    m_ChapterSet.insert(chapter_info->m_unRid);
    
    //发送添加通知；
}
//void CBookManagement::AddChapters(std::vector<CChapterInfo*>& vec_chapter){
//    for (std::vector<CChapterInfo*>::iterator iter = vec_chapter.begin(); iter != vec_chapter.end(); ++iter) {
//        if (HasBook((*iter)->m_strBookId)) {
//            if (HasChapter(*iter)) {
//                continue;
//            }
//            CChapterInfo* cur_chapter = new CLocalTask;
//            *cur_chapter = **iter;
//            ((CLocalTask*)cur_chapter)->taskStatus = ((CLocalTask*)(*iter))->taskStatus;
//            ((CLocalTask*)cur_chapter)->downStatus = ((CLocalTask*)(*iter))->downStatus;
//            
//            [[KBDatabaseManagement sharedInstance] addChapter:cur_chapter];
//            m_BookDetailList.find(cur_chapter->m_strBookId)->second->push_back(cur_chapter);
//        }else {
//            std::map<std::string, CChapterInfo*>* map_book = new std::map<std::string, CChapterInfo*>;
//            CChapterInfo* cur_chapter = new CLocalTask;
//            *cur_chapter = **iter;
//            ((CLocalTask*)cur_chapter)->taskStatus = ((CLocalTask*)(*iter))->taskStatus;
//            ((CLocalTask*)cur_chapter)->downStatus = ((CLocalTask*)(*iter))->downStatus;
//            
//            [[KBDatabaseManagement sharedInstance] addChapter:cur_chapter];
//            map_book->insert(std::map<std::string, CChapterInfo*>::value_type(cur_chapter->m_strName, cur_chapter));
//            m_BookDetailList.insert(std::map<std::string, std::map<std::string, CChapterInfo*>*>::value_type(cur_chapter->m_strBookId, map_book));
//            
//            CBookInfo* cur_book = new CBookInfo;
//            *cur_book = *CBookInfoList::getInstance()->getBookInfo((*iter)->m_strBookId);
//            
//            [[KBDatabaseManagement sharedInstance] addBook:cur_book];
//            m_BookList.insert(std::map<std::string, CBookInfo*>::value_type(cur_book->m_strBookId, cur_book));
//        }
//    }
//    
//    //发送批量添加通知；
//}

void CBookManagement::DeleteChapter(CChapterInfo* chapter_info){
    std::string str_book_id = chapter_info->m_strBookId;
    int n_rid = chapter_info->m_unRid;
    if (HasBook(str_book_id)) {
        if (HasChapter(n_rid)) {
            std::string str_file_path = [KwTools::Dir::GetPath(KwTools::Dir::PATH_LOCALMUSIC) UTF8String];
            str_file_path += [[NSString stringWithFormat:@"/%d.m4a", n_rid] UTF8String];
            
            KwTools::Dir::DeleteDir(str_file_path);
            
            std::map<std::string, std::vector<CChapterInfo*>* >::iterator iter = m_BookDetailList.find(str_book_id);
            if (m_BookDetailList.end() != iter) {
                std::vector<CChapterInfo*>* p_vec_chapter = iter->second;
                for (std::vector<CChapterInfo*>::iterator iter_chapter = p_vec_chapter->begin(); iter_chapter != p_vec_chapter->end(); ++iter_chapter) {
                    if (n_rid == (*iter_chapter)->m_unRid) {
                        delete *iter_chapter;
                        *iter_chapter = NULL;
                        p_vec_chapter->erase(iter_chapter);
                        break;
                    }
                }
            }
            [[KBDatabaseManagement sharedInstance] deleteChapter:n_rid];
            
            m_ChapterSet.erase(n_rid);
            
            if (0 == m_BookDetailList.find(str_book_id)->second->size()) {
                std::vector<CChapterInfo*>* vec_book = m_BookDetailList.find(str_book_id)->second;
                delete vec_book;
                vec_book = NULL;
                
                for (std::vector<CBookInfo*>::iterator iter_book = m_BookList.begin(); iter_book != m_BookList.end(); ++iter_book) {
                    if (str_book_id == (*iter_book)->m_strBookId) {
                        CBookInfo* book_info = *iter_book;
                        delete book_info;
                        book_info = NULL;
                        m_BookList.erase(iter_book);
                        
                        break;
                    }
                }
                
                m_BookDetailList.erase(str_book_id);
                [[KBDatabaseManagement sharedInstance] deleteBook:str_book_id];
            }
            
            //发送 删除 通知；
        }
    }
}
void CBookManagement::DeleteChapters(std::string str_book_id){
    std::map<std::string, std::vector<CChapterInfo*>* >::iterator iter = m_BookDetailList.find(str_book_id);
    if (m_BookDetailList.end() != iter){
        std::vector<CChapterInfo*>* chapter_list = iter->second;
        for (std::vector<CChapterInfo*>::iterator iter_chapter = chapter_list->begin(); iter_chapter != chapter_list->end(); ++iter_chapter) {
            CChapterInfo* chapter_info = *iter_chapter;
            
            std::string str_file_path = [KwTools::Dir::GetPath(KwTools::Dir::PATH_LOCALMUSIC) UTF8String];
            str_file_path += [[NSString stringWithFormat:@"/%d.m4a", chapter_info->m_unRid] UTF8String];
            KwTools::Dir::DeleteDir(str_file_path);
            
            m_ChapterSet.erase(chapter_info->m_unRid);
            delete chapter_info;
            chapter_info = NULL;
        }
        
        chapter_list->clear();
        
        delete iter->second;
        iter->second = NULL;
        m_BookDetailList.erase(iter);
        
        for (std::vector<CBookInfo*>::iterator iter_book = m_BookList.begin(); iter_book != m_BookList.end(); ++iter_book) {
            if (str_book_id == (*iter_book)->m_strBookId) {
                CBookInfo* book_info = *iter_book;
                delete book_info;
                book_info = NULL;
                m_BookList.erase(iter_book);
                
                break;
            }
        }
        
        [[KBDatabaseManagement sharedInstance] deleteChapters:str_book_id];
        [[KBDatabaseManagement sharedInstance] deleteBook:str_book_id];
    }
}

void CBookManagement::DeleteChapters(std::string str_book_id, bool b_finished){
    [[KBDatabaseManagement sharedInstance] deleteChapters:str_book_id :b_finished];
    std::map<std::string, std::vector<CChapterInfo*>* >::iterator iter = m_BookDetailList.find(str_book_id);
    if (m_BookDetailList.end() != iter){
        std::vector<CChapterInfo*>* chapter_list = iter->second;
        for (std::vector<CChapterInfo*>::iterator iter_chapter = chapter_list->begin(); iter_chapter != chapter_list->end();) {
            CChapterInfo* chapter_info = *iter_chapter;
            
            if (b_finished == chapter_info->m_unDownload) {
                m_ChapterSet.erase(chapter_info->m_unRid);
                
                std::string str_file_path = [KwTools::Dir::GetPath(KwTools::Dir::PATH_LOCALMUSIC) UTF8String];
                str_file_path += [[NSString stringWithFormat:@"/%d.m4a", chapter_info->m_unRid] UTF8String];
                KwTools::Dir::DeleteDir(str_file_path);
                
                delete chapter_info;
                chapter_info = NULL;
                iter_chapter = chapter_list->erase(iter_chapter);
            }else {
                ++iter_chapter;
            }
        }
        
        if (0 == chapter_list->size()) {
            delete iter->second;
            iter->second = NULL;
            m_BookDetailList.erase(iter);
            
            for (std::vector<CBookInfo*>::iterator iter_book = m_BookList.begin(); iter_book != m_BookList.end(); ++iter_book) {
                if (str_book_id == (*iter_book)->m_strBookId) {
                    CBookInfo* book_info = *iter_book;
                    delete book_info;
                    book_info = NULL;
                    m_BookList.erase(iter_book);
                    
                    break;
                }
            }
            
            [[KBDatabaseManagement sharedInstance] deleteBook:str_book_id];
        }
        
        //发送 批量删除 通知；
    }
}

void CBookManagement::ResetChapter(CChapterInfo* chapter_info){
    CChapterInfo* dest_chapter_info = GetChapterInfo(chapter_info->m_strBookId, chapter_info->m_unRid);
    *dest_chapter_info = *chapter_info;
    [[KBDatabaseManagement sharedInstance] updateChapter:chapter_info];
    //发送 更新 通知；
}

bool CBookManagement::HasBook(std::string str_book_id){
    if (m_BookDetailList.end() != m_BookDetailList.find(str_book_id)){
        return true;
    }
    else{
        return false;
    }
}
bool CBookManagement::HasChapter(int n_rid){
    std::set<int>::iterator iter = m_ChapterSet.find(n_rid);
    if (m_ChapterSet.end() != iter) {
        return true;
    }else {
        return false;
    }
}

std::vector<CChapterInfo*>* CBookManagement::GetChapterList(std::string str_book_id){
    if (m_BookDetailList.end() != m_BookDetailList.find(str_book_id)) {
        return (m_BookDetailList.find(str_book_id)->second);
    }else {
        return NULL;
    }
}

void CBookManagement::GetBookDownList(std::string str_book_id, std::vector<CChapterInfo*>& vec_chapter_downed, std::vector<CChapterInfo*>& vec_chapter_downing){
    vec_chapter_downed.clear();
    vec_chapter_downing.clear();
    
    if (!CBookManagement::GetInstance()->HasBook(str_book_id)) {
        return;
    }
    
    std::map<std::string, std::vector<CChapterInfo*>* >::iterator iter = m_BookDetailList.find(str_book_id);
    if (m_BookDetailList.end() != iter){
        std::vector<CChapterInfo*>* chapter_list = iter->second;
        for (std::vector<CChapterInfo*>::iterator iter_chapter = chapter_list->begin(); iter_chapter != chapter_list->end(); ++iter_chapter) {
            CChapterInfo* chapter_info = *iter_chapter;
            if (chapter_info->m_unDownload) {
                vec_chapter_downed.push_back(chapter_info);
            }else {
                vec_chapter_downing.push_back(chapter_info);
            }
        }
    }
}

bool compareChapter(CChapterInfo* first, CChapterInfo* second){
    if (0 >= strcmp(first->m_strName.c_str(), second->m_strName.c_str())) {
        return true;
    }else {
        return false;
    }
}

void CBookManagement::SortChapter(){
    for(std::map<std::string, std::vector<CChapterInfo*>* >::iterator iter = m_BookDetailList.begin(); iter != m_BookDetailList.end(); ++iter){
        std::vector<CChapterInfo*>* vec_chapter = (*iter).second;
        std::sort(vec_chapter->begin(), vec_chapter->end(), compareChapter);
    }
}

void CBookManagement::ClearBuffer(){
    NSMutableArray* arrayFiles = [[NSMutableArray alloc] init];
    KwTools::Dir::FindFiles([NSString stringWithFormat:@"%@/", KwTools::Dir::GetPath(KwTools::Dir::PATH_LOCALMUSIC)], @"m4a", arrayFiles);
    
    int n_count = arrayFiles.count;
    for (int n_itr = 0; n_itr < n_count; ++n_itr) {
        NSString* str_file_path = [arrayFiles objectAtIndex:n_itr];
        NSString* str_file_name = KwTools::Dir::GetFileName(str_file_path);
        NSString* str_rid = KwTools::Dir::GetFileNameWithoutExt(str_file_name);
        if (!HasChapter([str_rid intValue])) {
            KwTools::Dir::DeleteDir(str_file_path);
        }
    }
}