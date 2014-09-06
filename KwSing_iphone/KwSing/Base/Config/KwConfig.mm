//
//  KwConfig.cpp
//  KwSing
//
//  Created by Qian Hu on 12-7-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include "KwConfig.h"
#include "UIDevice+Hardware.h"
#include "debug.h"
#include <CommonCrypto/CommonDigest.h>
#include "KuwoConstants.h"
#include "KwTools.h"
#include "log.h"
#include "device.h"
#include "utility.h"
#include "KwConfigElements.h"


KwConfig* KwConfig::GetConfigureInstance()
{
    static KwConfig g_KwConfig;
    return &g_KwConfig;
}

BOOL KwConfig::ReleaseDeviceInfo()
{
    [mDeviceType release];
    [mDeviceOSVersion release];
    [mDeviceId release];
    [mDeviceMacAddr release];
    [mUserUUID release];
    return TRUE;
}

NSString* KwConfig::GetClientVersionString()
{
	return mClientVersionString;
}

NSString* KwConfig::GetClientInstallSource()
{
	return mClientInstallSource;
}

NSString* KwConfig::GetDeviceType() const
{
    return mDeviceType;
}

NSString* KwConfig::GetDeviceOSVersion() const
{
    return mDeviceOSVersion;
}

NSString* KwConfig::GetDeviceId() const
{
    return mDeviceId;
}

NSString* KwConfig::GetDeviceMacAddress() const
{
    return mDeviceMacAddr;
}

NSString* KwConfig::GetUserUUID() const
{
    return mUserUUID;
}

BOOL KwConfig::InitConfig()
{
    @autoreleasepool {
        LoadDeviceInfo();
        LoadInstallInfo();
        
        NSString *logDir = KwTools::Dir::GetPath(KwTools::Dir::PATH_LOG);
        
        NSString* file;
        file = [logDir stringByAppendingPathComponent:DEBUG_LOG_NAME];
        setDebugLogFile([file UTF8String]);
        c_KuwoDebugLog_start();//start_up debug log
        file = [logDir stringByAppendingPathComponent:CLIENT_LOG_NAME];
        setClientLogFile([file UTF8String]);
        
        LoadConfigInfo();
        
        mbChangeConf = false;
        
        std::string str_uuid = "";
        
        GetConfigStringValue(DEVICE_INFO, DEVICE_UUID, str_uuid);
        mUserUUID = [[NSString alloc] initWithUTF8String:str_uuid.c_str()];
    }

    return TRUE; 
}

void KwConfig::ReLoadSvrConfig()
{
    NSString *path = KwTools::Dir::GetPath(KwTools::Dir::PATH_DUCUMENT);
    NSString *svrconf = [path stringByAppendingPathComponent:@ SVR_CONFIG_FILE];
    mSvrReader.loadIniInfo([svrconf UTF8String]);
}

BOOL KwConfig::LoadConfigInfo()
{
    @autoreleasepool {
        NSString *path = KwTools::Dir::GetPath(KwTools::Dir::PATH_DUCUMENT);
        NSString *userconf = [path stringByAppendingPathComponent:@ USER_CONFIG_FILE];
        NSString *svrconf = [path stringByAppendingPathComponent:@ SVR_CONFIG_FILE];
        
        mUserReader.loadIniInfo([userconf UTF8String]);
        mSvrReader.loadIniInfo([svrconf UTF8String]);
    }
    
    return TRUE;
}

BOOL KwConfig::LoadDeviceInfo()
{
    UIDevice* device = [UIDevice currentDevice];
    
    // device type
    mDeviceType = [[device platform] copy];//[[device platformString] copy];
    
    // device version
    mDeviceOSVersion = [[device systemVersion] copy];
    
    // UDID/DeviceId, UDID is not available in iOS 7 and later.
    NSComparisonResult order = [mDeviceOSVersion compare:@"7.0" options:NSNumericSearch];
    BOOL udidAvailable = (order == NSOrderedAscending);
    if (udidAvailable)
    {
        // for review reason, here we shouldnot use the uniqueIdentifier directly.
        NSString* selName = [NSString stringWithFormat:@"unique%s", "Identifier"];
        SEL sel = NSSelectorFromString(selName);
        NSString* devId = @"";
        if ([device respondsToSelector:sel])
            devId = [device performSelector:sel];
        
        // a UDID should must be a 40 charactors string, or at lest 32 for a GUID in simulator.
        if ([devId length] >= 32) {
            char temp[32];
            GetMd5HashString16(temp, [devId UTF8String], [devId length]);
            mDeviceId = [[NSString alloc] initWithUTF8String:temp];
        } else {
            mDeviceId = @"";
        }
    }
    
    // UUID, should be loaded only after loacl directories have been initialized.
    
    // MAC address
    char macAddr[32];
    GetMacAddressHexString(macAddr);
    mDeviceMacAddr = [[NSString alloc] initWithUTF8String:macAddr];
    
    //UserID for log
	setUserId(macAddr);
    
    return TRUE;
}

BOOL KwConfig::LoadInstallInfo()
{
	NSString *path=[[NSBundle mainBundle] pathForResource:@"Install" ofType:@"plist"];
	NSDictionary* installDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSString* product = [installDictionary valueForKey:@"Product"];
	if (!product)
		product = @ KWSING_PRODUCT;
	
	NSString* platform = [installDictionary valueForKey:@"Platform"];
	if (!platform)
		platform = @ KWSING_PLATFORM;
    
	NSNumber* version = [installDictionary valueForKey:@"Version"];
	if (version)
		mClientVersion = [version unsignedIntValue];
	else
		mClientVersion = KWSING_VERSION;
	
	NSString* verstr = [installDictionary valueForKey:@"VersionString"];
	if (!verstr)
		verstr = @ KWSING_VERSION_STRING;
	
	NSString* pkgType = [installDictionary valueForKey:@"PkgType"];
	if (!pkgType)
		pkgType = @ KWSING_PACKEG_TYPE;
	
	
	mClientVersionString = [[NSString stringWithFormat:@"%@_%@_%@", product, platform, verstr] retain];
	
    mClientInstallSource = [[NSString stringWithFormat:@"%@.%@", mClientVersionString, pkgType] retain];
	
	return TRUE;
}

bool KwConfig::GetConfigStringValue(const char* pSection, const char* pKey,std::string & strValue)
{
    if(!mSvrReader.findStringValueInSectionByKey(strValue, pKey, pSection))
    {
        if(!mUserReader.findStringValueInSectionByKey(strValue, pKey, pSection))
            return false;
    }
    return true;
}

bool KwConfig::GetConfigStringValue(const char* pSection, const char* pKey,std::string & strValue,const std::string & strDefault)
{
    bool bret = GetConfigStringValue(pSection, pKey, strValue);
    if(!bret)
    {
        strValue = strDefault;
    }
    return  bret;
}

bool KwConfig::SetConfigStringValue(const char* pSection, const char* pKey,const std::string & strValue)
{
    mbChangeConf = true;
    bool bret = (mUserReader.writeStrValueInSectionByKey(strValue, pKey, pSection));
    SaveConfig();
    return bret;
}

bool KwConfig::GetConfigIntValue(const char* pSection, const char* pKey,int & nValue)
{
    if(!mSvrReader.findIntValueInSectionByKey(nValue, pKey, pSection))
    {
        if(!mUserReader.findIntValueInSectionByKey(nValue, pKey, pSection))
            return false;
    }
    return true;
}

bool KwConfig::GetConfigIntValue(const char* pSection, const char* pKey,int & nValue,const int nDefault)
{
    bool bret = GetConfigIntValue(pSection, pKey, nValue);
    if(!bret)
    {
        nValue = nDefault;
    }
    return  bret;
}

bool KwConfig::SetConfigIntValue(const char* pSection, const char* pKey,int  nValue)
{
    char sz[MAX_PATH];
    sprintf(sz,"%d",nValue);
    string strtemp = sz;
    mbChangeConf = true;
    bool bret =  (mUserReader.writeStrValueInSectionByKey(strtemp, pKey, pSection));
    SaveConfig();
    return bret;

}

bool KwConfig::GetConfigBoolValue(const char* pSection, const char* pKey,bool & bValue)
{
    if(!mSvrReader.findBoolValueInSectionByKey(bValue, pKey, pSection))
    {
        if(!mUserReader.findBoolValueInSectionByKey(bValue, pKey, pSection))
            return false;
    }
    return true;
}

bool KwConfig::GetConfigBoolValue(const char* pSection, const char* pKey,bool & bValue,const bool bDefault)
{
    bool bret = GetConfigBoolValue(pSection, pKey, bValue);
    if(!bret)
    {
        bValue = bDefault;
    }
    return  bret;
}

bool KwConfig::SetConfigBoolValue(const char* pSection, const char* pKey,bool  bValue)
{
    mbChangeConf = true;
    bool bret = (mUserReader.writeStrValueInSectionByKey((bValue?"1":"0"), pKey, pSection));
    SaveConfig();
    return bret;
}

bool KwConfig::SaveConfig()
{
    if(mbChangeConf)
    {
        NSString * strpath = KwTools::Dir::GetPath(KwTools::Dir::PATH_DUCUMENT);
        NSString * strconf = [strpath stringByAppendingPathComponent:@ USER_CONFIG_FILE];
        mbChangeConf = false;
        return mUserReader.writeIni([strconf UTF8String]);
    }
    return false;
}






