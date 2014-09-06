//
//  UMengLog.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-10-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "UMengLog.h"
#include "MobClick.h"

void UMengLog(const std::string& event)
{
    [MobClick event:[NSString stringWithUTF8String:event.c_str()]];
}

void UMengLog(const std::string& event,int nDuration)
{
    [MobClick event:[NSString stringWithUTF8String:event.c_str()] durations:nDuration];
}

void UMengLog(const std::string& event,const std::string& attribute)
{
    [MobClick event:[NSString stringWithUTF8String:event.c_str()] label:[NSString stringWithUTF8String:attribute.c_str()]];
}

void UMengLog(const std::string& event,const std::string& attribute,int nDuration)
{
    [MobClick event:[NSString stringWithUTF8String:event.c_str()]
              label:[NSString stringWithUTF8String:attribute.c_str()]
          durations:nDuration];
}

void UMengLog(const std::string& event,const std::map<std::string,std::string>& mapKeyValue)
{
    assert(mapKeyValue.size()<=10);
    NSMutableDictionary* dict=[NSMutableDictionary dictionary];
    for (std::map<std::string,std::string>::const_iterator ite=mapKeyValue.begin(); ite!=mapKeyValue.end(); ++ite) {
        [dict setObject:[NSString stringWithUTF8String:ite->first.c_str()]
                 forKey:[NSString stringWithUTF8String:ite->second.c_str()]];
    }
    [MobClick event:[NSString stringWithUTF8String:event.c_str()] attributes:dict];
}

void UMengLog(const std::string& event,const std::map<std::string,std::string>& mapKeyValue,int nDuration)
{
    assert(mapKeyValue.size()<=10);
    NSMutableDictionary* dict=[NSMutableDictionary dictionary];
    for (std::map<std::string,std::string>::const_iterator ite=mapKeyValue.begin(); ite!=mapKeyValue.end(); ++ite) {
        [dict setObject:[NSString stringWithUTF8String:ite->first.c_str()]
                 forKey:[NSString stringWithUTF8String:ite->second.c_str()]];
    }
    [MobClick event:[NSString stringWithUTF8String:event.c_str()] attributes:dict durations:nDuration];
}


CUMengDurationLog::CUMengDurationLog(const std::string& event)
:m_nRandKey(rand())
,m_strEvent(event)
,m_nType(0)
{
}

void CUMengDurationLog::Start()
{
    [MobClick beginEvent:[NSString stringWithUTF8String:m_strEvent.c_str()]];
}

void CUMengDurationLog::Start(const std::string& attribute)
{
    [MobClick beginEvent:[NSString stringWithUTF8String:m_strEvent.c_str()] label:[NSString stringWithUTF8String:attribute.c_str()]];
    m_nType=1;
}

void CUMengDurationLog::Start(const std::map<std::string,std::string>& mapKeyValue)
{
    assert(mapKeyValue.size()<=10);
    NSMutableDictionary* dict=[NSMutableDictionary dictionary];
    for (std::map<std::string,std::string>::const_iterator ite=mapKeyValue.begin(); ite!=mapKeyValue.end(); ++ite) {
        [dict setObject:[NSString stringWithUTF8String:ite->first.c_str()]
                 forKey:[NSString stringWithUTF8String:ite->second.c_str()]];
    }
    [MobClick beginEvent:[NSString stringWithUTF8String:m_strEvent.c_str()]
              primarykey:[NSString stringWithFormat:@"%d",m_nRandKey]
              attributes:dict];
    m_nType=2;
}

void CUMengDurationLog::End()
{
    if (m_nType==2) {
        [MobClick endEvent:[NSString stringWithUTF8String:m_strEvent.c_str()] primarykey:[NSString stringWithFormat:@"%d",m_nRandKey]];
    } else {
        [MobClick endEvent:[NSString stringWithUTF8String:m_strEvent.c_str()]];
    }
}


CUMengAutoDurationLog::CUMengAutoDurationLog(const std::string& event)
:m_durationLog(event)
{
    m_durationLog.Start();
}

CUMengAutoDurationLog::CUMengAutoDurationLog(const std::string& event,const std::string& attribute)
:m_durationLog(event)
{
    m_durationLog.Start(attribute);
}

CUMengAutoDurationLog::CUMengAutoDurationLog(const std::string& event,const std::map<std::string,std::string>& mapKeyValue)
:m_durationLog(event)
{
    m_durationLog.Start(mapKeyValue);
}

CUMengAutoDurationLog::~CUMengAutoDurationLog()
{
    m_durationLog.End();
}





