//
//  GetDeviceDetailInfo.m
//  PackingList
//
//  Created by 安庆 安庆 on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GetDeviceDetailInfo.h"
#include "sys/types.h"
#include "sys/sysctl.h"

@implementation GetDeviceDetailInfo

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

+(NSString *)getDetailInfo
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *name = (char *)malloc(size);
	sysctlbyname("hw.machine", name, &size, NULL, 0);
//	NSString *machine = [NSString stringWithCString:name];
    NSString *machine = [NSString stringWithCString:name encoding:[NSString defaultCStringEncoding]];
	free(name);
	return machine;
}

@end

