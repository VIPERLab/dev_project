//
//  UniqueIdentifier.m
//  NewPackingList
//
//  Created by 安庆 安庆 on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UniqueIdentifier.h"
#import "OpenUDID.h"
#import <CommonCrypto/CommonDigest.h>   //md5
#import <AdSupport/AdSupport.h>


@implementation UniqueIdentifier

-(id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
}


+(NSString *)getIdfa
{
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //NSLog(@" adId : %@",adId);
    
//    UIAlertView *alert = [[UIAlertView alloc]
//                          initWithTitle:@"IDFA"
//                          message:adId
//                          delegate:nil
//                          cancelButtonTitle:@"ok"
//                          otherButtonTitles:nil];
//    alert.delegate = self;
//    [alert show];
//    [alert release];

    return adId;
}

+(NSString *)getUniqueIdentifier
{
    NSString *str_uniqueIdentifier = @" ";
    if(ios7)
    {
        //str_uniqueIdentifier = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] retain];
        str_uniqueIdentifier = [[OpenUDID value] retain];
        
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"标识符:"
//                              message:str_uniqueIdentifier
//                              delegate:nil
//                              cancelButtonTitle:@"ok"
//                              otherButtonTitles:nil];
//        alert.delegate = self;
//        [alert show];
//        [alert release];
        
    }
    else
    {
        str_uniqueIdentifier = [[self macaddress] retain];
    }
    
    return [str_uniqueIdentifier autorelease];
}

+(NSString *)getUniqueIdentifierMd5String
{
    NSString *srcStr = [[self getUniqueIdentifier] retain];
    NSString *str1 = [self md5:srcStr];
    NSString *string1 = [str1 substringToIndex:30];
    NSString *string2 = [str1 substringFromIndex:30];
    NSString *str = [NSString stringWithFormat:@"%@%@",string2,string1];
    NSString *outStr = [[self md5:str] retain];
    [srcStr release];
    return [outStr autorelease];
}



#include <sys/socket.h>
#include <sys/sysctl.h> 
#include <net/if.h>
#include <net/if_dl.h>
+(NSString *)macaddress
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
+(NSString *)md5:(NSString *)str 
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr,strlen(cStr), result );
    
    NSString *outStr = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                        result[0], result[1], result[2], result[3], 
                        result[4], result[5], result[6], result[7],
                        result[8], result[9], result[10], result[11],
                        result[12], result[13], result[14], result[15]
                        ];
    return outStr;
}

@end
