//
//  BookInfo.mm
//  kwbook
//
//  Created by 单 永杰 on 13-12-2.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#include <stdio.h>
#include "BookInfo.h"

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

inline void __SaveToDict(const std::string& str,NSString* strKey,NSMutableDictionary* dict)
{
    if(!str.empty()) [dict setObject:[NSString stringWithUTF8String:str.c_str()] forKey:strKey];
}
inline void __SaveToDict(unsigned n,NSString* strKey,NSMutableDictionary* dict)
{
    if(n) [dict setObject:[NSNumber numberWithUnsignedInt:n] forKey:strKey];
}

void CBookInfo::LoadFromDict(NSDictionary* dict)
{
    __ReadFromDict(dict, @"bookid", m_strBookId);
    __ReadFromDict(dict, @"bookname", m_strBookTitle);
    __ReadFromDict(dict, @"artist", m_strArtist);
    __ReadFromDict(dict, @"count", m_unCount);
    __ReadFromDict(dict, @"hotindex", m_unHotIndex);
    __ReadFromDict(dict, @"listencnt", m_unListenCnt);
    __ReadFromDict(dict, @"imgurl", m_strImgUrl);
    __ReadFromDict(dict, @"newchapter", m_unNewChapter);
    __ReadFromDict(dict, @"digest", m_strDigest);
    __ReadFromDict(dict, @"type", m_unType);
    __ReadFromDict(dict, @"summary", m_strSummary);
}

void CBookInfo::SaveToDict(NSMutableDictionary* dict)
{
    __SaveToDict(m_strBookId, @"bookid", dict);
    __SaveToDict(m_strBookTitle, @"bookname", dict);
    __SaveToDict(m_strArtist, @"artist", dict);
    __SaveToDict(m_unCount, @"count", dict);
    __SaveToDict(m_unHotIndex, @"hotindex", dict);
    __SaveToDict(m_unListenCnt, @"listencnt", dict);
    __SaveToDict(m_strImgUrl, @"imgurl", dict);
    __SaveToDict(m_unNewChapter, @"newchapter", dict);
    __SaveToDict(m_strDigest, @"digest", dict);
    __SaveToDict(m_unType, @"type", dict);
    __SaveToDict(m_strSummary, @"summary", dict);
}