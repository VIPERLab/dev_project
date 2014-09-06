//
//  DeviceInfo.m
//  QyGuide
//
//  Created by 你猜你猜 on 13-10-12.
//
//

#import "DeviceInfo.h"
#import "sys/utsname.h"

@implementation DeviceInfo


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
+(NSString *)getDeviceName_detail
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString *devicename_detail = [self process:deviceString];
    
    return devicename_detail;
}
+(NSString *)process:(NSString *)str_in
{
    NSString *str_out = @"ios device";
    if([str_in isEqualToString:@"i386"])
    {
        str_out = @"ios simulator";
    }
    else if([str_in isEqualToString:@"iPod1,1"])
    {
        str_out = @"iPod touch";
    }
    else if([str_in isEqualToString:@"iPod2,1"])
    {
        str_out = @"iPod touch 2";
    }
    else if([str_in isEqualToString:@"iPod3,1"])
    {
        str_out = @"iPod touch 3";
    }
    else if([str_in isEqualToString:@"iPod4,1"])
    {
        str_out = @"iPod touch 4";
    }
    else if([str_in isEqualToString:@"iPod5,1"])
    {
        str_out = @"iPod touch 5";
    }
    else if([str_in isEqualToString:@"iPad1,1"])
    {
        str_out = @"iPad 1";
    }
    else if([str_in isEqualToString:@"iPad2,1"])
    {
        str_out = @"iPad 2(Wifi)";
    }
    else if([str_in isEqualToString:@"iPad2,2"])
    {
        str_out = @"iPad 2(GSM)";
    }
    else if([str_in isEqualToString:@"iPad2,3"])
    {
        str_out = @"iPad 2(CDMA)";
    }
    else if([str_in isEqualToString:@"iPad2,4"])
    {
        str_out = @"iPad 2(32nm)";
    }
    else if([str_in isEqualToString:@"iPad2,5"])
    {
        str_out = @"iPad mini(Wifi)";
    }
    else if([str_in isEqualToString:@"iPad2,6"])
    {
        str_out = @"iPad mini(GSM)";
    }
    else if([str_in isEqualToString:@"iPad2,7"])
    {
        str_out = @"iPad mini(CDMA)";
    }
    else if([str_in isEqualToString:@"iPad3,1"])
    {
        str_out = @"iPad 3(Wifi)";
    }
    else if([str_in isEqualToString:@"iPad3,2"])
    {
        str_out = @"iPad 3(CDMA)";
    }
    else if([str_in isEqualToString:@"iPad3,3"])
    {
        str_out = @"iPad 3(4G)";
    }
    else if([str_in isEqualToString:@"iPad3,4"])
    {
        str_out = @"iPad 4(Wifi)";
    }
    else if([str_in isEqualToString:@"iPad3,5"])
    {
        str_out = @"iPad 4(4G)";
    }
    else if([str_in isEqualToString:@"iPad3,6"])
    {
        str_out = @"iPad 4(CDMA)";
    }
    else if([str_in isEqualToString:@"iPad4,1"])
    {
        str_out = @"iPad Air (Wifi)";
    }
    else if([str_in isEqualToString:@"iPad4,2"])
    {
        str_out = @"iPad Air (Cellular)";
    }
    else if([str_in isEqualToString:@"iPad4,4"])
    {
        str_out = @"iPad mini (Wifi)";
    }
    else if([str_in isEqualToString:@"iPad4,5"])
    {
        str_out = @"iPad mini (Cellular)";
    }
    else if([str_in isEqualToString:@"iPhone1,1"])
    {
        str_out = @"iPhone";
    }
    else if([str_in isEqualToString:@"iPhone1,2"])
    {
        str_out = @"iPhone 3G";
    }
    else if([str_in isEqualToString:@"iPhone2,1"])
    {
        str_out = @"iPhone 3GS";
    }
    else if([str_in isEqualToString:@"iPhone3,1"])
    {
        str_out = @"iPhone 4(ChinaMobile,ChinaUnicom)";
    }
    else if([str_in isEqualToString:@"iPhone3,2"])
    {
        str_out = @"iPhone 4(ChinaUnicom)";
    }
    else if([str_in isEqualToString:@"iPhone3,3"])
    {
        str_out = @"iPhone 4(ChinaTelecom)";
    }
    else if([str_in isEqualToString:@"iPhone4,1"])
    {
        str_out = @"iPhone 4S";
    }
    else if([str_in isEqualToString:@"iPhone5,1"])
    {
        str_out = @"iPhone 5(ChinaMobile,ChinaUnicom)";
    }
    else if([str_in isEqualToString:@"iPhone5,2"])
    {
        str_out = @"iPhone 5(ChinaMobile,ChinaTelecom,ChinaUnicom)";
    }
    else if([str_in isEqualToString:@"iPhone6,1"])
    {
        str_out = @"iPhone 5s";
    }
    else if([str_in isEqualToString:@"iPhone6,2"])
    {
        str_out = @"iPhone 5s";
    }
    else if([str_in isEqualToString:@"iPhone6,3"])
    {
        str_out = @"iPhone 5c";
    }
    else if([str_in isEqualToString:@"iPhone6,4"])
    {
        str_out = @"iPhone 5c";
    }
    
    return str_out;
}
+(NSString *)getDeviceSystemVersion
{
    NSString *deviceSystemVersion = [[UIDevice currentDevice] systemVersion];
    return deviceSystemVersion;
}


+(NSString *)getAppName
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    return appName;
}
+(NSString *)getAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersionShort = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return appVersionShort;
}


@end
