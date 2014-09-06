//
//  DeviceToken.m
//  QyGuide
//
//  Created by 你猜你猜 on 13-10-12.
//
//

#import "DeviceToken.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "UniqueIdentifier.h"
#import "GetInfo.h"
#import "NSString+SBJSON.h"
#import "DeviceInfo.h"
#import "RegexKitLite.h"


#define     postdatamaxtime          30


@implementation DeviceToken


-(void)dealloc
{
    [sharedDeviceToken release];
    [super dealloc];
}


#pragma mark -
#pragma mark --- 单例
static DeviceToken *sharedDeviceToken = nil;
+(id)sharedDeviceToken
{
    if (!sharedDeviceToken)
    {
        sharedDeviceToken = [[self alloc] init];
    }
    return sharedDeviceToken;
}


#pragma mark -
#pragma mark --- post DeviceToken
+(void)postTokenToServer:(NSString *)token_device
{
    NSLog(@"####### %@ ########",[UniqueIdentifier getIdfa]);
    
    NSString *urlStr = @"http://open.qyer.com/app/device/submitdevice";
    ASIFormDataRequest *request  = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    request.delegate = [DeviceToken sharedDeviceToken];
    request.shouldRedirect = NO;
    request.timeOutSeconds = postdatamaxtime;
    [request addPostValue:[UniqueIdentifier getIdfa] forKey:@"idfa"];
    [request addPostValue:[UniqueIdentifier getUniqueIdentifier] forKey:@"deviceid"];
    [request addPostValue:[UniqueIdentifier getUniqueIdentifierMd5String] forKey:@"authkey"];
    [request addPostValue:APPID forKey:@"appid"];
    [request addPostValue:[GetInfo getAppVersion]  forKey:@"version"];
    [request addPostValue:[GetInfo getDeviceSystemVersion] forKey:@"osversion"];
    [request addPostValue:token_device forKey:@"deviceToken"];
    [self processRequest:request];
    [request startAsynchronous];
}


+(void)processRequest:(ASIFormDataRequest *)my_request{
    
    NSString *track_user_id = @"";
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
    {
        track_user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    }
    NSString *track_deviceid = [UniqueIdentifier getIdfa];
    NSString *track_app_version = [DeviceInfo getAppVersion];
    NSString *track_device_info = [DeviceInfo getDeviceName_detail];
    track_device_info = [track_device_info stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    NSString *track_os = [DeviceInfo getDeviceSystemVersion];
    track_os = [NSString stringWithFormat:@"ios %@",track_os];
    track_os = [track_os stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    NSString *channel = [appChannel_UMeng stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    NSString *lat_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lat_user"]];
    NSString *lon_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lon_user"]];
    
    [my_request addPostValue:API_version forKey:@"v"];
    [my_request addPostValue:track_user_id forKey:@"track_user_id"];
    [my_request addPostValue:track_deviceid forKey:@"track_deviceid"];
    [my_request addPostValue:track_app_version forKey:@"track_app_version"];
    [my_request addPostValue:channel forKey:@"track_app_channel"];
    [my_request addPostValue:track_device_info forKey:@"track_device_info"];
    [my_request addPostValue:track_os forKey:@"track_os"];
    [my_request addPostValue:lat_user forKey:@"lat"];
    [my_request addPostValue:lon_user forKey:@"lon"];
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        [my_request addPostValue:access_token forKey:@"oauth_token"];
    }
    
    NSString *appInstalltime = [[NSUserDefaults standardUserDefaults] objectForKey:@"appInstalltime_sec"];
    if(appInstalltime)
    {
        [my_request addPostValue:appInstalltime forKey:@"app_installtime"];
    }
}



#pragma mark -
#pragma mark --- ASIHTTPRequest - delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    //***(1)Use when fetching text data
    NSString *responseString2 = [request responseString];
    NSMutableString *responseString = [[NSMutableString alloc]initWithString:responseString2];
    NSLog(@"responseString ==(requestFinished)== %@",responseString);
    
    
    NSMutableDictionary *dic = [responseString JSONValue];
    NSString *flag = [NSString stringWithFormat:@"%@",[dic valueForKey:@"status"]];
    if([flag isEqualToString:@"1"])
    {
        NSLog(@" token post成功 ");
    }
    else
    {
        NSLog(@" token post失败 ");
    }
    [responseString release];
    
    
    //***(2)Use when fetching binary data
    //NSData *responseData = [request responseData];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSString *responseString2 = [request responseString];
    if (responseString2)
    {
        NSMutableString *responseString = [[NSMutableString alloc] initWithString:responseString2];
        NSLog(@"responseString (Failed)==== %@",responseString);
        [responseString release];
    }
}


@end
