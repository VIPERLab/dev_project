//
//  UMengLog.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-10-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__UMengLog__
#define __KwSing__UMengLog__

#include <string>
#include <map>

//event、key、value不允许空格和特殊字符，长度限制255
//带duration的方便自己记录时间段
void UMengLog(const std::string& event);
void UMengLog(const std::string& event,int nDuration);

void UMengLog(const std::string& event,const std::string& attribute);
void UMengLog(const std::string& event,const std::string& attribute,int nDuration);

//key value对不能超过10个
void UMengLog(const std::string& event,const std::map<std::string,std::string>& mapKeyValue);
void UMengLog(const std::string& event,const std::map<std::string,std::string>& mapKeyValue,int nDuration);


//记录时间段
class CUMengDurationLog
{
public:
    CUMengDurationLog(const std::string& event);
    
    void Start();
    void Start(const std::string& attribute);
    //带一堆参数，比如播歌时候带上歌名歌手rid
    void Start(const std::map<std::string,std::string>& mapKeyValue);
    void End();
    
private:
    std::string m_strEvent;
    int m_nRandKey;
    int m_nType;
};

//析构自动end，类似AutoLock
class CUMengAutoDurationLog
{
public:
    CUMengAutoDurationLog(const std::string& event);
    CUMengAutoDurationLog(const std::string& event,const std::string& attribute);
    CUMengAutoDurationLog(const std::string& event,const std::map<std::string,std::string>& mapKeyValue);
    ~CUMengAutoDurationLog();
    
private:
    CUMengDurationLog m_durationLog;
};

#endif



