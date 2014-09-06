//
//  CacheMgr.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-7-27.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CacheMgr_h
#define KwSing_CacheMgr_h

#import <string>
#import <map>
#import "Lock.h"

#ifndef IN
#define IN
#endif
#ifndef OUT
#define OUT
#endif

typedef enum {
    T_SECOND
    ,T_MINUTE
    ,T_HOUR
    ,T_DAY
    ,T_WEEK
    ,T_MONTH
    ,T_YEAR
}TIME_GRANU;

class CCacheMgr
{
public:
    static CCacheMgr* GetInstance();
    
    //NSString一定用下方的重载接口，否则facebook
    BOOL Cache(IN TIME_GRANU eumGranu,IN unsigned uiTimeValue,IN const std::string& strKey,IN const void* pData,IN unsigned uiLen);
    BOOL Cache(IN TIME_GRANU eumGranu,IN unsigned uiTimeValue,IN NSString* strKey,IN NSString* str);
    //存入一个文件
    BOOL Cache(IN TIME_GRANU eumGranu,IN unsigned uiTimeValue,IN const std::string& strKey,IN const std::string& strFile);
    
    //又一个违反规则的地方，记得pData要传NULL，uiLen用来返回数据大小，并且负责pData的销毁
    BOOL Read(IN const std::string& strKey,OUT void*& pData,OUT unsigned& uiLen,OUT BOOL& bOutOfTime);
    //直接取得缓存文件完整路径，只许对文件内容操作，不许删除改名文件本身～
    BOOL GetCacheFile(IN const std::string& strKey,OUT std::string& strFile,OUT BOOL& bOutOfTime);
    
    //存入时间，不存在返回NULL，返回的NSDate是autorelease的
    NSDate* GetSaveTime(IN const std::string& strKey);
    //不存在返回FALSE
    BOOL UpdateTimeToNow(IN const std::string& strKey);
    
    //是否超期，不存在或者过期返回TRUE
    BOOL IsOutOfTime(IN const std::string& strKey);
    
    BOOL IsExist(IN const std::string& strKey);
    
    BOOL Delete(IN const std::string& strKey);
    
    void CleanOutOfDate();
    
    void CleanAll();
    
private:
    CCacheMgr();
    ~CCacheMgr();
    struct CacheItem
    {
        std::string strPath;
        TIME_GRANU eumGranu;
        unsigned uiTimeValue;
        unsigned uiCreateTime;
    };
    BOOL m_bInit;
    std::map<std::string,CacheItem*> m_mapCacheItems;
    std::string m_strCachePath;
    NSRecursiveLock* m_lock;
    void Init();
    CacheItem* GetItemByKey(const std::string& strKey);
    CacheItem* GetItemByHashKey(const std::string& strKey);
    BOOL DeleteItemByHashKey(IN const std::string& strHashKey);
    std::string NameHash(std::string strName);
    unsigned GranToSecond(unsigned ulGran) const;
    BOOL IsItemOutOfTime(const CacheItem* item) const;
};

#endif
