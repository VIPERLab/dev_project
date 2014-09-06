//
//  TongjiFenxi.m
//  iPhoneJinNang
//
//  Created by 安庆 on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TongjiFenxi.h"
#import "ASINetworkQueue.h"
#import "ASIDownloadCache.h"
#import "ASIFormDataRequest.h"



@implementation TongjiFenxi

-(void)dealloc
{
    //[_queue release];
    [super dealloc];
}

-(id)init
{
    if (self = [super init]) 
    {
        //if (!_queue) 
        //{
        //    _queue = [[ASINetworkQueue alloc] init];
        //    _queue.showAccurateProgress = YES;
        //    _queue.shouldCancelAllRequestsOnFailure = NO;
        //    [_queue go];
        //}
    }
    return self;
}

//获取终端设备信息:
-(NSString *)getDeviceInfoModel
{
    //NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *deviceModel = [[[UIDevice currentDevice] model] retain];
    //NSString *deviceLocalizedModel = [[UIDevice currentDevice] localizedModel];
    //NSString *deviceSystemName = [[UIDevice currentDevice] systemName];
    //NSString *deviceSystemVersion = [[UIDevice currentDevice] systemVersion];
    
    
    
    //NSLog(@"deviceName = %@",deviceName);
    //NSLog(@"deviceModel = %@",deviceModel);
    //NSLog(@"deviceLocalizedModel = %@",deviceLocalizedModel);
    //NSLog(@"deviceSystemName = %@",deviceSystemName);
    //NSLog(@"deviceSystemVersion = %@",deviceSystemVersion);
    return [deviceModel autorelease];
}

//获取终端设备系统版本信息:
-(NSString *)getDeviceInfoSystemVersion
{
    //NSString *deviceName = [[UIDevice currentDevice] name];
    //NSString *deviceModel = [[UIDevice currentDevice] model];
    //NSString *deviceLocalizedModel = [[UIDevice currentDevice] localizedModel];
    //NSString *deviceSystemName = [[UIDevice currentDevice] systemName];
    NSString *deviceSystemVersion = [[[UIDevice currentDevice] systemVersion] retain];
    
    
    //NSLog(@"deviceName = %@",deviceName);
    //NSLog(@"deviceModel = %@",deviceModel);
    //NSLog(@"deviceLocalizedModel = %@",deviceLocalizedModel);
    //NSLog(@"deviceSystemName = %@",deviceSystemName);
    //NSLog(@"deviceSystemVersion = %@",deviceSystemVersion);
    return [deviceSystemVersion autorelease];
}

//获取该应用的版本信息:
-(NSString *)getAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];  
    // app名称  
    //    NSString *name = [infoDictionary objectForKey:@"CFBundleDisplayName"];  
    // app版本  
    //    NSString *versionShort = [infoDictionary objectForKey:@"CFBundleShortVersionString"];  
    // app build版本  
    NSString *version = [[infoDictionary objectForKey:@"CFBundleVersion"] retain];
    return [version autorelease];
}



//获取机器的mac地址:
#include <sys/socket.h> 
#include <sys/sysctl.h> 
#include <net/if.h>
#include <net/if_dl.h>
-(NSString *)macaddress
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


-(void)postDataByUrlStr:(NSString *)urlStr andAppId:(NSString *)AppId andType:(NSString *)type andAboutId:(NSString *)aboutId
{
    NSString *device = [[self getDeviceInfoModel] retain];
    NSString *sysVersion = [[self getDeviceInfoSystemVersion] retain];
    NSString *appVersion = [[self getAppVersion] retain];
    
    
    ASIFormDataRequest *request  = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    request.shouldRedirect = NO; //不让网页自动跳转[例:从'go2eu'跳转到'qyer']!!
    [request addPostValue:AppId forKey:@"appid"];
    [request addPostValue:type forKey:@"type"];
    [request addPostValue:aboutId forKey:@"aboutid"];
    [request addPostValue:device forKey:@"device"];
    [request addPostValue:sysVersion forKey:@"sysVersion"];
    [request addPostValue:appVersion forKey:@"appVersion"];
    
    [request startAsynchronous];
    
    [device release];
    [sysVersion release];
    [appVersion release];
    
    [request setFailedBlock:^{[request release];}];
    [request setCompletionBlock:^(void){MYLog(@"统计分析结果:%@",request.responseString);[request release];}];
}
-(void)postDataByUrlStr:(NSString *)urlStr andAppId:(NSString *)AppId andDeviceId:(NSString *)deviceid andType:(NSString *)type andAboutId:(NSString *)aboutId
{
    
    NSString *device = [[self getDeviceInfoModel] retain];
    NSString *sysVersion = [[self getDeviceInfoSystemVersion] retain];
    NSString *appVersion = [[self getAppVersion] retain];
    
    
    ASIFormDataRequest *request  = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    request.shouldRedirect = NO; //不让网页自动跳转[例:从'go2eu'跳转到'qyer']!!
//    [request addPostValue:kClientId forKey:@"client_id"];  
//    [request addPostValue:macaddress() forKey:@"device_id"];  
//    [request addPostValue:myTextView.text forKey:@"content"];
//    [request addPostValue:[[NSDate date] description] forKey:@"modified"];
    
    [request addPostValue:AppId forKey:@"appid"];
    [request addPostValue:[self macaddress] forKey:@"deviceID"];
    [request addPostValue:type forKey:@"type"];
    [request addPostValue:aboutId forKey:@"aboutid"];
    [request addPostValue:device forKey:@"device"];
    [request addPostValue:sysVersion forKey:@"sysVersion"];
    [request addPostValue:appVersion forKey:@"appVersion"];
    
    [request startAsynchronous];
    
    [device release];
    [sysVersion release];
    [appVersion release];
    
    [request setFailedBlock:^{[request release];}];
    [request setCompletionBlock:^(void){MYLog(@"统计分析结果:%@",request.responseString);[request release];}];
}

@end
