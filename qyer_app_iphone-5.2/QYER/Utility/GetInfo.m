//
//  GetInfo.m
//  PackingList
//
//  Created by 安庆 安庆 on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GetInfo.h"

@implementation GetInfo

-(id)init
{
    if (self = [super init]) 
    {
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

//***(1) 获取终端设备信息:
+(NSString *)getDeviceInfoModel
{
    //NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *deviceModel = [[[UIDevice currentDevice] model] retain];
    //NSString *deviceLocalizedModel = [[UIDevice currentDevice] localizedModel];
    //NSString *deviceSystemName = [[UIDevice currentDevice] systemName];
    //NSString *deviceSystemVersion = [[UIDevice currentDevice] systemVersion];
    
    
    
    ////NSLog(@"deviceName = %@",deviceName);
    ////NSLog(@"deviceModel = %@",deviceModel);
    ////NSLog(@"deviceLocalizedModel = %@",deviceLocalizedModel);
    ////NSLog(@"deviceSystemName = %@",deviceSystemName);
    ////NSLog(@"deviceSystemVersion = %@",deviceSystemVersion);
    return [deviceModel autorelease];
}
+(NSString *)getDeviceName
{
    NSString *deviceLocalizedModel = [[UIDevice currentDevice] localizedModel];
    return deviceLocalizedModel;
}
+(NSString *)getDeviceSystemVersion
{
    NSString *deviceSystemVersion = [[UIDevice currentDevice] systemVersion];
    return deviceSystemVersion;
}

//***(2) 获取终端设备系统版本信息:
+(NSString *)getDeviceInfoSystemVersion
{
    //NSString *deviceName = [[UIDevice currentDevice] name];
    //NSString *deviceModel = [[UIDevice currentDevice] model];
    //NSString *deviceLocalizedModel = [[UIDevice currentDevice] localizedModel];
    //NSString *deviceSystemName = [[UIDevice currentDevice] systemName];
    NSString *deviceSystemVersion = [[[UIDevice currentDevice] systemVersion] retain];
    
    
    ////NSLog(@"deviceName = %@",deviceName);
    ////NSLog(@"deviceModel = %@",deviceModel);
    ////NSLog(@"deviceLocalizedModel = %@",deviceLocalizedModel);
    ////NSLog(@"deviceSystemName = %@",deviceSystemName);
    ////NSLog(@"deviceSystemVersion = %@",deviceSystemVersion);
    return [deviceSystemVersion autorelease];
}


//***(3) 获取该应用名称:
+(NSString *)getAppName
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    return appName;
}

//***(4) 获取该应用的版本信息:
+(NSString *)getAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersionShort = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return appVersionShort;
}



//***(5) 获取设备的macaddress:
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
+(NSString *)getMacaddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        //BFLog("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        //BFLog("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        //BFLog("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        //BFLog("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%X:%X:%X:%X:%X:%X",*ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}


@end

