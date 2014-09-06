//
//  RecentBookInfo.mm
//  kwbook
//
//  Created by 单 永杰 on 13-12-2.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#include <stdio.h>
#include "RecentBookInfo.h"

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

void CRecentBookInfo::LoadFromDict(NSDictionary* dict){
    CBookInfo::LoadFromDict(dict);
    
    __ReadFromDict(dict, @"rid", m_unRid);
    __ReadFromDict(dict, @"index", m_unIndex);
    __ReadFromDict(dict, @"position", m_unPosMilSec);
}
void CRecentBookInfo::SaveToDict(NSMutableDictionary* dict){
    CBookInfo::SaveToDict(dict);
    
    __SaveToDict(m_unRid, @"rid", dict);
    __SaveToDict(m_unIndex, @"index", dict);
    __SaveToDict(m_unPosMilSec, @"position", dict);
}