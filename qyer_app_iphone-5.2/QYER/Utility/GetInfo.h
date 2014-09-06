//
//  GetInfo.h
//  PackingList
//
//  Created by 安庆 安庆 on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetInfo : NSObject

//获取终端设备信息:
+(NSString *)getDeviceInfoModel;
+(NSString *)getDeviceName;
+(NSString *)getDeviceSystemVersion;

//获取终端设备系统版本信息:
+(NSString *)getDeviceInfoSystemVersion;

//获取该应用的版本信息:
+(NSString *)getAppName;
+(NSString *)getAppVersion;

//获取设备的macaddress:
+(NSString *)getMacaddress;

@end
