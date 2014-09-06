//
//  ChapterInfo.c
//  kwbook
//
//  Created by 单 永杰 on 13-11-29.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//
#include "ChapterInfo.h"

inline void __ReadFromDict(NSDictionary* dict,NSString* strKey,std::string& str)
{
    id v=[dict objectForKey:strKey];
    if (v && [[v class] isSubclassOfClass:[NSString class]]) {
        NSString* s=(NSString*)v;
        str=[s UTF8String];
    }
}
inline void __ReadFromDict(NSDictionary* dict,NSString* strKey,unsigned& n)
{
    id v=[dict objectForKey:strKey];
    if (v && [[v class] isSubclassOfClass:[NSNumber class]]) {
        NSNumber* num=(NSNumber*)v;
        n=[num unsignedIntValue];
    }
}
//inline void __ReadFromDict(NSDictionary* dict,NSString* strKey,CChapterInfo& chapter)
//{
//    id v=[dict objectForKey:strKey];
//    if (v && [[v class] isSubclassOfClass:[NSDictionary class]]) {
//        NSDictionary* d=(NSDictionary*)v;
//        __ReadFromDict(d, @"bookid", chapter.m_strBookId);
//        __ReadFromDict(d, @"bookname", chapter.m_strBookName);
//        __ReadFromDict(d, @"artist", chapter.m_strArtist);
//        __ReadFromDict(d, @"rid", chapter.m_unRid);
//        __ReadFromDict(d, @"hotindex", chapter.m_unHotIndex);
//        __ReadFromDict(d, @"downloaded", chapter.m_unDownload);
//        __ReadFromDict(d, @"dur", chapter.m_unDuration);
//        __ReadFromDict(d, @"fsize", chapter.m_unFileSize);
//        __ReadFromDict(d, @"url", chapter.m_strUrl);
//        __ReadFromDict(d, @"sig", chapter.m_strSig);
//        __ReadFromDict(d, @"path", chapter.m_strLocalPath);
//        __ReadFromDict(d, @"lsize", chapter.m_unLocalSize);
//    }
//}

inline void __SaveToDict(const std::string& str,NSString* strKey,NSMutableDictionary* dict)
{
    if(!str.empty()) [dict setObject:[NSString stringWithUTF8String:str.c_str()] forKey:strKey];
}
inline void __SaveToDict(unsigned n,NSString* strKey,NSMutableDictionary* dict)
{
    if(n) [dict setObject:[NSNumber numberWithUnsignedInt:n] forKey:strKey];
}
//void __SaveToDict(const CChapterInfo& chapter,NSString* strKey,NSMutableDictionary* dict)
//{
//    NSMutableDictionary* child=[NSMutableDictionary dictionary];
//    __SaveToDict(chapter.m_strBookId, @"bookid", child);
//    __SaveToDict(chapter.m_strBookName, @"bookname", child);
//    __SaveToDict(chapter.m_strArtist, @"artist", child);
//    __SaveToDict(chapter.m_unRid, @"rid", child);
//    __SaveToDict(chapter.m_unHotIndex, @"hotindex", child);
//    __SaveToDict(chapter.m_unDownload, @"downloaded", child);
//    __SaveToDict(chapter.m_unDuration, @"dur", child);
//    __SaveToDict(chapter.m_strUrl, @"url", child);
//    __SaveToDict(chapter.m_strSig, @"sig", child);
//    __SaveToDict(chapter.m_strLocalPath, @"path", child);
//    __SaveToDict(chapter.m_unLocalSize, @"lsize", child);
//    __SaveToDict(chapter.m_unFileSize, @"fsize", child);
//    if([child count]) [dict setObject:child forKey:strKey];
//}

CChapterInfo::CChapterInfo()
:m_unRid(0)
,m_unHotIndex(0)
,m_unDownload(0)
,m_unDuration(0)
,m_unLocalSize(0)
,m_unFileSize(0)
{
    std::string m_strBookId = "";
    std::string m_strName = "";
    std::string m_strBookName = "";
    std::string m_strArtist = "";
    std::string m_strUrl = "";         //播放url
    std::string m_strSig = "";         //断点续传用
    std::string m_strLocalPath = "";   //本地缓存
}

void CChapterInfo::LoadFromDict(NSDictionary* dict)
{
    __ReadFromDict(dict, @"bookid", m_strBookId);
    __ReadFromDict(dict, @"name", m_strName);
    __ReadFromDict(dict, @"bookname", m_strBookName);
    __ReadFromDict(dict, @"artist", m_strArtist);
    __ReadFromDict(dict, @"rid", m_unRid);
    __ReadFromDict(dict, @"hotindex", m_unHotIndex);
    __ReadFromDict(dict, @"downloaded", m_unDownload);
    __ReadFromDict(dict, @"dur", m_unDuration);
    __ReadFromDict(dict, @"url", m_strUrl);
    __ReadFromDict(dict, @"sig", m_strSig);
    __ReadFromDict(dict, @"path", m_strLocalPath);
    __ReadFromDict(dict, @"lsize", m_unLocalSize);
    __ReadFromDict(dict, @"fsize", m_unFileSize);
}

void CChapterInfo::SaveToDict(NSMutableDictionary* dict)
{
    __SaveToDict(m_strBookId, @"bookid", dict);
    __SaveToDict(m_strName, @"name", dict);
    __SaveToDict(m_strBookName, @"bookname", dict);
    __SaveToDict(m_strArtist, @"artist", dict);
    __SaveToDict(m_unRid, @"rid", dict);
    __SaveToDict(m_unHotIndex, @"hotindex", dict);
    __SaveToDict(m_unDownload, @"downloaded", dict);
    __SaveToDict(m_unDuration, @"dur", dict);
    __SaveToDict(m_strUrl, @"url", dict);
    __SaveToDict(m_strSig, @"sig", dict);
    __SaveToDict(m_strLocalPath, @"path", dict);
    __SaveToDict(m_unLocalSize, @"lsize", dict);
    __SaveToDict(m_unFileSize, @"fsize", dict);
}