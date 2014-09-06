//
//  CacheMgr.cpp
//  KwSing
//
//  Created by Zhai HaiPIng on 12-7-27.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "CacheMgr.h"
#include "KwTools.h"
#include <algorithm>
#include "KwConfig.h"
#include <stdlib.h>


CCacheMgr* CCacheMgr::GetInstance()
{
    static CCacheMgr sCacheMgr;
    return &sCacheMgr;
}

CCacheMgr::CCacheMgr()
:m_bInit(FALSE)
{
    m_lock=[[NSRecursiveLock alloc] init];
}

CCacheMgr::~CCacheMgr()
{
    
}

BOOL CCacheMgr::Cache(IN TIME_GRANU eumGranu,IN unsigned uiTimeValue,IN const std::string& strKey,IN const void* pData,IN unsigned uiLen)
{
    if (strKey.empty()) {
        return FALSE;
    }
    
    KwTools::CAutoRecursiveLock lock(m_lock);
    if(!m_bInit)Init();
    
    std::string strHashKey=NameHash(strKey);
    CacheItem* pItem=GetItemByHashKey(strHashKey);
    if (pItem) {
        DeleteItemByHashKey(strHashKey);
    }
    CacheItem* item=new CacheItem;
    item->eumGranu=eumGranu;
    item->uiTimeValue=uiTimeValue;
    
    item->uiCreateTime=(unsigned)[NSDate timeIntervalSinceReferenceDate];
    item->strPath=m_strCachePath+KwTools::StringUtility::Format("%d_%d_%d_",eumGranu,uiTimeValue,item->uiCreateTime)+strHashKey+".cah";
    
    FILE* f=fopen(item->strPath.c_str(),"wb");
    if (f) {
        fwrite(pData,sizeof(char),uiLen,f);
        fflush(f);
        fclose(f);
        m_mapCacheItems[strHashKey]=item;
        return TRUE;
    }
    return FALSE;
}

BOOL CCacheMgr::Cache(IN TIME_GRANU eumGranu,IN unsigned uiTimeValue,IN NSString* strKey,IN NSString* str)
{
    if ([strKey length]==0) {
        return FALSE;
    }
    return Cache(eumGranu, uiTimeValue, [strKey UTF8String], [str UTF8String], [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding]+1);
}

BOOL CCacheMgr::Cache(IN TIME_GRANU eumGranu,IN unsigned uiTimeValue,IN const std::string& strKey,IN const std::string& strFile)
{
    NSData* data=[NSData dataWithContentsOfFile:[NSString stringWithUTF8String:strFile.c_str()]];
    if([data length]==0) {
        return FALSE;
    }
    return Cache(eumGranu, uiTimeValue, strKey, [data bytes], [data length]);
}

BOOL CCacheMgr::Read(IN const std::string& strKey,OUT void*& pData,OUT unsigned& uiLen,OUT BOOL& bOutOfTime)
{
    bOutOfTime=TRUE;
    if (strKey.empty()) {
        return FALSE;
    }
    KwTools::CAutoRecursiveLock lock(m_lock);
    if(!m_bInit)Init();
    
    CacheItem* pItem=GetItemByKey(strKey);
    if (!pItem) {
        return FALSE;
    }
    FILE* f=fopen(pItem->strPath.c_str(),"rb");
    if (f) {
        fseek(f, 0, SEEK_END);
        if (( uiLen=ftell(f) )) {
            fseek(f, 0, SEEK_SET);
            pData=new char[uiLen];
            fread(pData, sizeof(char), uiLen, f);
            fclose(f);
            
            bOutOfTime=IsItemOutOfTime(pItem);
            //NSLog(@"ReadFromCacheSuccess,key=%s,outlen=%d,outoftime=%d",strKey.c_str(),uiLen,bOutOfTime);
            return TRUE;
        }
        fclose(f);
    }
    return FALSE;
}

BOOL CCacheMgr::GetCacheFile(IN const std::string& strKey,OUT std::string& strFile,OUT BOOL& bOutOfTime)
{
    bOutOfTime=TRUE;
    if (strKey.empty()) {
        return FALSE;
    }
    KwTools::CAutoRecursiveLock lock(m_lock);
    if(!m_bInit)Init();
    
    CacheItem* pItem=GetItemByKey(strKey);
    if (!pItem) {
        return FALSE;
    }
    strFile=pItem->strPath;
    bOutOfTime=IsItemOutOfTime(pItem);
    //NSLog(@"GetFileFromCacheSuccess,key=%s,outoftime:%d",strKey.c_str(),bOutOfTime);
    return TRUE;
}

NSDate* CCacheMgr::GetSaveTime(IN const std::string& strKey)
{
    if (strKey.empty()) {
        return NULL;
    }
    KwTools::CAutoRecursiveLock lock(m_lock);
    if(!m_bInit)Init();
    
    CacheItem* pItem=GetItemByKey(strKey);
    if (!pItem) {
        return NULL;
    }
    return [NSDate dateWithTimeIntervalSinceReferenceDate:pItem->uiCreateTime];
}

BOOL CCacheMgr::IsExist(IN const std::string& strKey)
{
    KwTools::CAutoRecursiveLock lock(m_lock);
    if(!m_bInit)Init();
    return GetItemByKey(strKey)!=NULL;
}

BOOL CCacheMgr::Delete(IN const std::string& strKey)
{
    KwTools::CAutoRecursiveLock lock(m_lock);
    if(!m_bInit)Init();
    
    return DeleteItemByHashKey(NameHash(strKey));
}

BOOL CCacheMgr::DeleteItemByHashKey(IN const std::string& strHashKey)
{
    std::map<std::string,CacheItem*>::iterator ite=m_mapCacheItems.find(strHashKey);
    if (ite!=m_mapCacheItems.end()) {
        CacheItem* pItem=ite->second;
        m_mapCacheItems.erase(ite);
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithUTF8String:pItem->strPath.c_str()] error:nil];
        return TRUE;
    }
    return FALSE;
}

void CCacheMgr::Init()
{
    KwTools::Dir::GetPath(KwTools::Dir::PATH_CASHE,m_strCachePath);
    m_strCachePath+="/KSCache/";

    NSFileManager* pMgr=[NSFileManager defaultManager];
    NSString* pNSStringCachePath=[NSString stringWithUTF8String:m_strCachePath.c_str()];
    if(![pMgr fileExistsAtPath:pNSStringCachePath]){
        [pMgr createDirectoryAtPath:pNSStringCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSArray* array=[pMgr contentsOfDirectoryAtPath:pNSStringCachePath error:nil];
    std::string strFullPath;
    NSString* pExt=@"cah";
    
    int nCount(0);
    @autoreleasepool {
        for (NSString* file in array) {
            if ([[file pathExtension] isEqualToString:pExt]) {
                strFullPath=m_strCachePath;
                strFullPath+=[file UTF8String];
                
                size_t posStart=strFullPath.rfind('/');
                size_t posEnd=strFullPath.rfind('.');
                std::string strName=strFullPath.substr(posStart+1,posEnd-posStart-1);
                std::vector<std::string> vecParts;
                KwTools::StringUtility::Tokenize(strName,"_",vecParts);
                if (vecParts.size()==4) {
                    CacheItem* item=new CacheItem;
                    item->strPath=strFullPath;
                    item->eumGranu=(TIME_GRANU)(TIME_GRANU)KwTools::Convert::ConvertToDouble(vecParts[0]);
                    item->uiTimeValue=(unsigned)KwTools::Convert::ConvertToDouble(vecParts[1]);
                    item->uiCreateTime=strtoul(vecParts[2].c_str(),NULL,10);
                    m_mapCacheItems[vecParts[3]]=(item);
                }
            }
            ++nCount;
        }

    }
    
    m_bInit=TRUE;
}

CCacheMgr::CacheItem* CCacheMgr::GetItemByKey(const std::string& strKey)
{ 
    return GetItemByHashKey(NameHash(strKey));
}

CCacheMgr::CacheItem* CCacheMgr::GetItemByHashKey(const std::string& strHashKey)
{
    std::map<std::string,CacheItem*>::iterator ite=m_mapCacheItems.find(strHashKey);
    if (ite!=m_mapCacheItems.end()) {
        return ite->second;
    }
    return NULL;
}

std::string CCacheMgr::NameHash(std::string strName)
{
	unsigned long a = 63689;
	unsigned long b = 378551;
	unsigned long hash = 0;
    
	const char *p = strName.c_str();
	while(*p)
	{
		hash = hash * a + ( *p++ );
		a *= b;
	}
	hash = hash & 0x7FFFFFFF;			// RS STRING HASH FUNCTION
    
	char buff[32];
	memset(buff, 0, sizeof(buff));
	sprintf(buff,"%08lX", hash);
    
	return buff;
}

void CCacheMgr::CleanOutOfDate()
{
    if(!m_bInit)return;
    
    unsigned now=(unsigned)[NSDate timeIntervalSinceReferenceDate];
    int nLastClean(0);
    KwConfig::GetConfigureInstance()->GetConfigIntValue("App","LastCleanCache",nLastClean,0);
    if(now-(unsigned)nLastClean<GranToSecond(T_DAY))
    {
        return;
    }
    KwConfig::GetConfigureInstance()->SetConfigIntValue("App", "LastCleanCache", (int)now);
    
    KwTools::CAutoRecursiveLock lock(m_lock);
    for (std::map<std::string,CacheItem*>::iterator ite=m_mapCacheItems.begin(); ite!=m_mapCacheItems.end();) {
        CacheItem* p=ite->second;
        unsigned uiGranu=GranToSecond(p->eumGranu);
        unsigned uiNow=(unsigned)(now/uiGranu);
        unsigned uiFile=(unsigned)(p->uiCreateTime/uiGranu);
        if (uiNow-uiFile>p->uiTimeValue + 3*GranToSecond(T_DAY)) {//超出三天的才会真删
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithUTF8String:p->strPath.c_str()] error:nil];
            m_mapCacheItems.erase(ite++);
        }
        else ++ite;
    }
}

unsigned CCacheMgr::GranToSecond(unsigned uiGran) const
{
	unsigned uiSecond = 0;
	switch(uiGran)
	{
        case T_SECOND:
            uiSecond = 1;
            break;
        case T_MINUTE:
            uiSecond = 60;
            break;
        case T_HOUR:
            uiSecond = 60 * 60;
            break;
        case T_DAY:
            uiSecond = 24 * 60 * 60;
            break;
        case T_MONTH:
            uiSecond = 30 * 24 * 60 * 60;
            break;
        case T_YEAR:
            uiSecond = 365 * 30 * 24 * 60 * 60;
            break;
        default:
            uiSecond = 1;
            break;
	}
	return uiSecond;
}

void CCacheMgr::CleanAll()
{
    KwTools::CAutoRecursiveLock lock(m_lock);
    if (m_mapCacheItems.empty()) {
        return;
    }
    for (std::map<std::string,CacheItem*>::iterator ite=m_mapCacheItems.begin(); ite!=m_mapCacheItems.end();++ite) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithUTF8String:ite->second->strPath.c_str()] error:nil];
    }
    m_mapCacheItems.clear();
}

BOOL CCacheMgr::UpdateTimeToNow(IN const std::string& strKey)
{
    if (strKey.empty()) {
        return FALSE;
    }
    KwTools::CAutoRecursiveLock lock(m_lock);
    if(!m_bInit)Init();
    
    CacheItem* pItem=GetItemByKey(strKey);
    if (!pItem) {
        return FALSE;
    }
    std::string strHashKey=NameHash(strKey);
    pItem->uiCreateTime=(unsigned)[NSDate timeIntervalSinceReferenceDate];
    std::string strNewPath=m_strCachePath+KwTools::StringUtility::Format("%d_%d_%d_",pItem->eumGranu,pItem->uiTimeValue,pItem->uiCreateTime)+strHashKey+".cah";
    if(KwTools::Dir::MoveFile(pItem->strPath, strNewPath)){
        pItem->strPath=strNewPath;
        return TRUE;
    }
    return FALSE;
}

BOOL CCacheMgr::IsOutOfTime(IN const std::string& strKey)
{
    if (strKey.empty()) {
        return TRUE;
    }
    KwTools::CAutoRecursiveLock lock(m_lock);
    if(!m_bInit)Init();
    
    CacheItem* pItem=GetItemByKey(strKey);
    if (!pItem) {
        return TRUE;
    }
    return IsItemOutOfTime(pItem);
}

BOOL CCacheMgr::IsItemOutOfTime(const CacheItem* item) const
{
    unsigned now=(unsigned)[NSDate timeIntervalSinceReferenceDate];
    
    unsigned uiGranu=GranToSecond(item->eumGranu);
    unsigned uiNow=(unsigned)(now/uiGranu);
    unsigned uiFile=(unsigned)(item->uiCreateTime/uiGranu);
    return uiNow-uiFile>item->uiTimeValue;
}
