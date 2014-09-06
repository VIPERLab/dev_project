//
//  TongjiFenxi.h
//  iPhoneJinNang
//
//  Created by 安庆 on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TongjiFenxi : NSObject

//获取机器的mac地址:
-(NSString *)macaddress;

//获取该应用的版本信息:
-(NSString *)getAppVersion;

//获取终端设备系统版本信息:
-(NSString *)getDeviceInfoSystemVersion;

//获取终端设备信息:
-(NSString *)getDeviceInfoModel;

//用户反馈或纠错:
-(void)postDataByUrlStr:(NSString *)urlStr andAppId:(NSString *)AppId andType:(NSString *)type andAboutId:(NSString *)aboutId;
-(void)postDataByUrlStr:(NSString *)urlStr andAppId:(NSString *)AppId andDeviceId:(NSString *)deviceid andType:(NSString *)type andAboutId:(NSString *)aboutId;

@end

