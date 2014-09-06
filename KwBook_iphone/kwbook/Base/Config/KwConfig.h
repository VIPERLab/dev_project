//
//  KwConfig.h
//  KwSing
//
//  Created by Qian Hu on 12-7-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_KwConfig_h
#define KwSing_KwConfig_h

#include <string>
#include "iniReader.h"

#define DEBUG_LOG_NAME @"debug.txt"
#define CLIENT_LOG_NAME @"log.txt"

#define TEMP_LOG_FILE   @"log.tmp"

#define USER_CONFIG_FILE         "config.ini"
#define SVR_CONFIG_FILE          "svrconfig.ini"

class KwConfig 
{
private:
    KwConfig(){}
    ~KwConfig(){}
    
public:
    static KwConfig* GetConfigureInstance();
 //   static void ReleaseConfigureInstance();
    
    BOOL InitConfig();
    void ReLoadSvrConfig();
    
public:
    const char* GetCurrentNetworkName() const;
    NSString* GetDeviceType() const;
    NSString* GetDeviceId() const;
    NSString* GetDeviceMacAddress() const;
    NSString* GetUserUUID() const;
    NSString* GetDeviceOSVersion() const;
    NSString* GetClientVersionString();
    NSString* GetClientInstallSource();
    
    bool GetConfigStringValue(const char* pSection, const char* pKey,std::string & strValue);
    bool GetConfigStringValue(const char* pSection, const char* pKey,std::string & strValue,const std::string & strDefault);
    bool SetConfigStringValue(const char* pSection, const char* pKey,const std::string & strValue);
    
    bool GetConfigIntValue(const char* pSection, const char* pKey,int & nValue);
    bool GetConfigIntValue(const char* pSection, const char* pKey,int & nValue,const int nDefault);
    bool SetConfigIntValue(const char* pSection, const char* pKey,int  nValue);
    
    bool GetConfigBoolValue(const char* pSection, const char* pKey,bool & bValue);
    bool GetConfigBoolValue(const char* pSection, const char* pKey,bool & bValue,const bool bDefault);
    bool SetConfigBoolValue(const char* pSection, const char* pKey,bool  bValue);
    
    bool SaveConfig();
    
private:
    BOOL LoadInstallInfo();
    BOOL LoadConfigInfo();
    BOOL LoadDeviceInfo();
    
private:
    NSString* mClientVersionString;
	NSString* mClientInstallSource;
    NSString* mDeviceType;
    NSString* mDeviceOSVersion;
    NSString* mDeviceId;    // UDID
    NSString* mDeviceMacAddr;
    NSString* mUserUUID;    //***
    
    UInt32 mClientVersion;
    
    iniReader mUserReader;
    iniReader mSvrReader;
    
    bool mbChangeConf;
   

};

#endif
