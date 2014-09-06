//
//  SongInfo.cpp
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-6.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "SongInfo.h"

const char* GetFormatName(MUSIC_FORMAT t)
{
    if (t<0 || t>=FMT_MAX) {
        return "";
    }
    static const char* szFmgName[] = {
        "NULL","AAC","AAC","AAC","MP3","MP4"
    };
    return szFmgName[t];
}

int GetBitRate(MUSIC_FORMAT t)
{
    if (t<0 || t>=FMT_MAX) {
        return 0;
    }
    static int nBitRates[] = {
        0,24000,32000,48000,128000,300000
    };
    return nBitRates[t];
}

#pragma mark Read & Save
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
inline void __ReadFromDict(NSDictionary* dict,NSString* strKey,MUSIC_RESOURCE& res)
{
    id v=[dict objectForKey:strKey];
    if (v && [[v class] isSubclassOfClass:[NSDictionary class]]) {
        NSDictionary* d=(NSDictionary*)v;
        __ReadFromDict(d, @"fmt", (unsigned&)res.eumFormat);
        __ReadFromDict(d, @"dur", res.uiDuration);
        __ReadFromDict(d, @"fsize", res.uiFileSize);
        __ReadFromDict(d, @"url", res.strUrl);
        __ReadFromDict(d, @"sig", res.strSig);
        __ReadFromDict(d, @"path", res.strLocalPath);
        __ReadFromDict(d, @"lsize", res.uiLocalSize);
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
void __SaveToDict(const MUSIC_RESOURCE& res,NSString* strKey,NSMutableDictionary* dict)
{
    NSMutableDictionary* child=[NSMutableDictionary dictionary];
    __SaveToDict(res.eumFormat, @"fmt", child);
    __SaveToDict(res.uiDuration, @"dur", child);
    __SaveToDict(res.uiFileSize, @"fsize", child);
    __SaveToDict(res.strUrl, @"url", child);
    __SaveToDict(res.strSig, @"sig", child);
    __SaveToDict(res.strLocalPath, @"path", child);
    __SaveToDict(res.uiLocalSize, @"lsize", child);
    if([child count]) [dict setObject:child forKey:strKey];
}

#pragma mark CSongInfoBase
CSongInfoBase::CSongInfoBase()
:uiPopularity(0)
,uiFlower(0)
,uiComment(0)
,uiCare(0)
{
    accompanyRes.eumFormat=originalRes.eumFormat=FMT_UNKNOWN;
    accompanyRes.uiDuration=originalRes.uiDuration=0;
    accompanyRes.uiFileSize=originalRes.uiFileSize=0;
    accompanyRes.uiLocalSize=originalRes.uiLocalSize=0;
}

void CSongInfoBase::LoadFromDict(NSDictionary* dict)
{
    @autoreleasepool {
        __ReadFromDict(dict, @"rid", strRid);
        __ReadFromDict(dict, @"kid", strKid);
        __ReadFromDict(dict, @"name", strSongName);
        __ReadFromDict(dict, @"art", strArtist);
        __ReadFromDict(dict, @"album", strAlbum);
        __ReadFromDict(dict, @"pop", uiPopularity);
        __ReadFromDict(dict, @"accres", accompanyRes);
        __ReadFromDict(dict, @"orires", originalRes);
        __ReadFromDict(dict, @"flower", uiFlower);
        __ReadFromDict(dict, @"comment", uiComment);
        __ReadFromDict(dict, @"care", uiCare);
    }
}

void CSongInfoBase::SaveToDict(NSMutableDictionary* dict)
{
    @autoreleasepool {
        __SaveToDict(strRid, @"rid", dict);
        __SaveToDict(strKid, @"kid", dict);
        __SaveToDict(strSongName, @"name", dict);
        __SaveToDict(strArtist, @"art", dict);
        __SaveToDict(strAlbum, @"album", dict);
        __SaveToDict(uiPopularity, @"pop", dict);
        __SaveToDict(accompanyRes, @"accres", dict);
        __SaveToDict(originalRes, @"orires", dict);
        __SaveToDict(uiFlower, @"flower", dict);
        __SaveToDict(uiComment, @"comment", dict);
        __SaveToDict(uiCare, @"care", dict);
    }
}

#pragma mark CRecoSongInfo
CRecoSongInfo::CRecoSongInfo()
:uiPoints(0)
,uiUploadPercent(0)
,uiDefeat(0)
,eumLocalState(CRecoSongInfo::STATE_NOSAVE)
{
    recoRes.eumFormat=FMT_UNKNOWN;
    recoRes.uiDuration=0;
    recoRes.uiFileSize=0;
    recoRes.uiLocalSize=0;
}

void CRecoSongInfo::LoadFromDict(NSDictionary* dict)
{
    CSongInfoBase::LoadFromDict(dict);
    
    @autoreleasepool {
        __ReadFromDict(dict, @"points", uiPoints);
        __ReadFromDict(dict, @"defeat", uiDefeat);
        __ReadFromDict(dict, @"recores", recoRes);
        __ReadFromDict(dict, @"lpicpack", strLocalPicPack);
        __ReadFromDict(dict, @"lstate", (unsigned&)eumLocalState);
        __ReadFromDict(dict, @"savetime", strSaveTime);
    }
}

void CRecoSongInfo::SaveToDict(NSMutableDictionary* dict)
{
    CSongInfoBase::SaveToDict(dict);
    
    @autoreleasepool {
        __SaveToDict(uiPoints, @"points", dict);
        __SaveToDict(uiDefeat, @"defeat", dict);
        __SaveToDict(recoRes, @"recores", dict);
        __SaveToDict(strLocalPicPack, @"lpicpack", dict);
        __SaveToDict(eumLocalState==STATE_UPLOADING?STATE_NOUPLOAD:eumLocalState, @"lstate", dict);
        __SaveToDict(strSaveTime, @"savetime", dict);
    }
}

#pragma mark CPlaySongInfo
CPlaySongInfo::CPlaySongInfo()
:uiPoints(0)
{
    recoRes.eumFormat=FMT_UNKNOWN;
    recoRes.uiDuration=0;
    recoRes.uiFileSize=0;
    recoRes.uiLocalSize=0;
}

void CPlaySongInfo::LoadFromDict(NSDictionary* dict)
{
    CSongInfoBase::LoadFromDict(dict);
    
    @autoreleasepool {
        __ReadFromDict(dict, @"subjectID", strSid);
        __ReadFromDict(dict, @"recores", recoRes);
        __ReadFromDict(dict, @"picpack", strPicPackUrl);
        __ReadFromDict(dict, @"username", strUserName);
        __ReadFromDict(dict, @"userid", strUserId);
        __ReadFromDict(dict, @"points", uiPoints);
        __ReadFromDict(dict, @"userpic", strUserPic);
    }
}

void CPlaySongInfo::SaveToDict(NSMutableDictionary* dict)
{
    CSongInfoBase::SaveToDict(dict);
    
    @autoreleasepool {
        __SaveToDict(strSid, @"subjectID", dict);
        __SaveToDict(recoRes, @"recores", dict);
        __SaveToDict(strPicPackUrl, @"picpack", dict);
        __SaveToDict(strUserName, @"username", dict);
        __SaveToDict(strUserId, @"userid", dict);
        __SaveToDict(uiPoints, @"points", dict);
        __SaveToDict(strUserPic, @"userpic", dict);
    }
}

