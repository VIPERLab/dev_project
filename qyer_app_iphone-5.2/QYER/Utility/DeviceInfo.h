//
//  DeviceInfo.h
//  QyGuide
//
//  Created by 你猜你猜 on 13-10-12.
//
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject

//获取终端设备信息:
+(NSString *)getDeviceInfoModel;
+(NSString *)getDeviceName;
+(NSString *)getDeviceName_detail;
+(NSString *)getDeviceSystemVersion;

//获取该应用的版本信息:
+(NSString *)getAppName;
+(NSString *)getAppVersion;

@end
