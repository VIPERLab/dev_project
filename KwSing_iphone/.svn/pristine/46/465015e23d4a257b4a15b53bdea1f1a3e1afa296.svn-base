//
//  KuwoConstants.mm
//  KwSing
//
//  Created by YeeLion on 11-1-8.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//  从音乐盒搬过来

#import "KuwoConstants.h"
#import "KwConfig.h"

//const char* GetNetworkName()
//{
//    if (!g_config)
//        return "";
//    return g_config->GetCurrentNetworkName();
//}

const char* GetDeviceType()
{
    return [KwConfig::GetConfigureInstance()->GetDeviceType() UTF8String];
}

const char* GetDeviceId()
{
    return [KwConfig::GetConfigureInstance()->GetUserUUID() UTF8String];
}

const char* GetDeviceMacAddress()
{
    return [KwConfig::GetConfigureInstance()->GetDeviceMacAddress() UTF8String];
}

const char* GetUserUUID()
{
    return [KwConfig::GetConfigureInstance()->GetUserUUID() UTF8String];
}

const char* GetDeviceOSVersion()
{
    return [KwConfig::GetConfigureInstance()->GetDeviceOSVersion() UTF8String];
}

const char* GetClientVersionString()
{
    return [KwConfig::GetConfigureInstance()->GetClientVersionString() UTF8String];
}

const char* GetClientInstallSource()
{
    return [KwConfig::GetConfigureInstance()->GetClientInstallSource() UTF8String];
}
