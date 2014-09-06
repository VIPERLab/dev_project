//
//  QYAPIClient.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-4.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "QYAPIClient.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJsonParser.h"
#import "NSString+SBJSON.h"
#import "QyYhConst.h"
#import "DataManager.h"
#import "UniqueIdentifier.h"
#import "DeviceInfo.h"
#import "RegexKitLite.h"
#import <CommonCrypto/CommonDigest.h>   //md5
#import <CoreLocation/CLLocation.h>

#define is_show_pay                                   1//0=不显示（适应旧版），1=显示（for新版）

/**
 折扣总分类缓存策略
 */
#define FileName_LastMinute_Category          @"LastMinute_Category"
#define FileName_LastMinute_Category_Total    @"LastMinute_Category_Total"

//Settings category refresh
#define Setting_Category_IsRefreshed          @"Setting_Category_IsRefreshed"
#define Setting_Category_Total_IsRefreshed    @"Setting_Category_Total_IsRefreshed"


#define getdatamaxtime  20    //请求超时时间

#define Error_Common_Text                     @"加载数据出错"
#define Error_Common_Status                   99999



@implementation QYAPIClient

-(void)dealloc
{
    QY_SAFE_RELEASE(sharedAPIClient);
    
//    QY_MUTABLERECEPTACLE_RELEASE(sharedAPIClient.dic_request);
//    
//    sharedAPIClient = nil;
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- sharedAPIClient
static QYAPIClient *sharedAPIClient = nil;
+(id)sharedAPIClient
{
    @synchronized(sharedAPIClient)
    {
        if(sharedAPIClient == nil)
        {
            sharedAPIClient = [[self alloc] init];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            sharedAPIClient.dic_request = dic;
            [dic release];
        }
    }
    return sharedAPIClient;  //外界初始化得到单例类对象的唯一借口,这个类方法返回的就是sharedAPIClient,即类的一个对象。如果sharedQYGuideData为空,则实例化一个对象;如果不为空,则直接返回。这样保证了实例的唯一。
}
+(id)allocWithZone:(NSZone *)zone
{
    @synchronized (self)
    {
        if(!sharedAPIClient)
        {
            sharedAPIClient = [super allocWithZone:zone];
            return sharedAPIClient;
        }
        
        return sharedAPIClient;
    }
}
-(id)init
{
    self = [super init];
    @synchronized(self)
    {
        if(sharedAPIClient)
        {
            return sharedAPIClient;
        }
        else
        {
            [super init];
            return self;
        }
    }
}
-(id)copy
{
    return self; //copy和copyWithZone这两个方法是为了防止外界拷贝造成多个实例,保证实例的唯一性。
}
-(id)copyWithZone:(NSZone *)zone
{
    return self;
}
-(id)retain
{
    return self; //因为只有一个实例对象,所以retain不能增加引用计数。
}
-(unsigned)retainCount
{
    return UINT_MAX; //因为只有一个实例对象,设置默认引用计数。这里是取的NSUinteger的最大值,当然也可以设置成1或其他值。
}
-(oneway void)release  //'oneway void'用于多线程编程中,表示单向执行,不能“回滚”,即原子操作。
{
    // Do nothing
}




#pragma mark -
#pragma mark --- 取消request请求:
-(void)cancleRequestPath:(NSString *)path
              parameters:(NSDictionary *)params
                  method:(NSString *)method
{
    NSString *urlStr = [DomainName stringByAppendingFormat:@"/%@", path];
    urlStr = [self getRequestUrl:urlStr withParameters:params];
    NSLog(@"  取消的请求 - Url : %@",urlStr);
    
    ASIHTTPRequest *request_ing = [sharedAPIClient.dic_request objectForKey:urlStr];
    if(request_ing)
    {
        //取消请求:
        NSLog(@" --- clearDelegatesAndCancel !");
        [request_ing clearDelegatesAndCancel];
        
        
        //从dic_request中删除:
        NSLog(@" --- removeObject !");
        [sharedAPIClient.dic_request removeObjectForKey:urlStr];
    }
}



#pragma mark -
#pragma mark --- 添加一些必传的参数
-(NSString *)getRequestUrl:(NSString *)string_url withParameters:(NSDictionary *)dic
{
    NSString *track_user_id = @"";
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
    {
        track_user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    }
    NSString *track_deviceid = [UniqueIdentifier getIdfa];
    
    NSLog(@"######## %@ ##########",track_deviceid);
    
    
    
    NSString *track_app_version = [DeviceInfo getAppVersion];
    NSString *track_device_info = [DeviceInfo getDeviceName_detail];
    track_device_info = [track_device_info stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    NSString *track_os = [DeviceInfo getDeviceSystemVersion];
    track_os = [NSString stringWithFormat:@"ios %@",track_os];
    track_os = [track_os stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    NSString *channel = [appChannel_UMeng stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    NSString *lat_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lat_user"]];
    NSString *lon_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lon_user"]];

    
    
    NSString *str_url = [NSString stringWithString:[string_url stringByAppendingFormat:@"?"]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"client_id=%@",ClientId_QY]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&client_secret=%@",ClientSecret_QY]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&v=%@",API_version]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_user_id=%@",track_user_id]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_deviceid=%@",track_deviceid]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_app_version=%@",track_app_version]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_app_channel=%@",channel]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_device_info=%@",track_device_info]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_os=%@",track_os]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&lat=%@",lat_user]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&lon=%@",lon_user]];
    
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&oauth_token=%@",access_token]];
    }
    
    
    NSString *appInstalltime = [[NSUserDefaults standardUserDefaults] objectForKey:@"appInstalltime_sec"];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&app_installtime=%@",appInstalltime]];
    
    
    for(id key in [dic allKeys])
    {
        str_url = [str_url stringByAppendingFormat:@"&%@=%@", key, [dic objectForKey:key]];
    }
    
    return str_url;
}



//绑定追踪信息
-(NSString *)addTrackInfoWithUrlString:(NSString *)string_url
{
    NSString *track_user_id = @"";
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
    {
        track_user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
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

    
    
    NSString *str_url = [NSString stringWithString:[string_url stringByAppendingFormat:@"?"]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&v=%@",API_version]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_user_id=%@",track_user_id]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_deviceid=%@",track_deviceid]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_app_version=%@",track_app_version]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_app_channel=%@",channel]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_device_info=%@",track_device_info]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_os=%@",track_os]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&lat=%@",lat_user]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&lon=%@",lon_user]];
    
    
    NSString *appInstalltime = [[NSUserDefaults standardUserDefaults] objectForKey:@"appInstalltime_sec"];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&app_installtime=%@",appInstalltime]];

    return str_url;
}




-(void)processRequest:(ASIFormDataRequest *)my_request
{
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
#pragma mark --- sendRequest
- (void)sendRequestPath:(NSString *)path
             parameters:(NSDictionary *)params
                 method:(NSString *)method
                success:(QYApiClientSuccessBlock)successBlock
                 failed:(QYApiClientFailedBlock)failed_Block
{
    //by jessica
    [self sendNewRequestPath:path
                  parameters:params
                      method:method
                     success:successBlock
                      failed:^(NSError *error) {
                          if (failed_Block)
                          {
                              failed_Block();
                          }
                      }];
    
    
//    [ASIHTTPRequest hideNetworkActivityIndicator];
//    
//    if([method isEqualToString:@"get"])  //从服务器端获取数据
//    {
//        NSString *urlStr = [DomainName stringByAppendingFormat:@"/%@", path];
//        urlStr = [self getRequestUrl:urlStr withParameters:params];
//        NSLog(@"  sendRequest - Url : %@",urlStr);
//        
//        
//        [ASIHTTPRequest hideNetworkActivityIndicator];
//        __block ASIHTTPRequest *my_request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
//        my_request.timeOutSeconds = getdatamaxtime;
//        
//        
//        if([sharedAPIClient.dic_request objectForKey:urlStr])
//        {
//            NSLog(@" 该请求还没有结束～～～");
//            return;
//        }
//        else
//        {
//            NSLog(@" 保存该请求");
//            [sharedAPIClient.dic_request setObject:my_request forKey:urlStr]; //保存请求
//        }
//        
//        
//        [my_request setCompletionBlock:^{
//            
//            //从dic_request中删除:
//            [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
//            
//            NSString *result = [my_request responseString];
//            if(result && result.length > 0)
//            {
//                SBJsonParser *json = [[SBJsonParser alloc] init];
//                NSDictionary *dic = [[json objectWithString:result] retain];
//                [json release];
//                
//                
//                if ([path isEqualToString:@"qyer/wall/detail"]) {
//                    successBlock(dic);
//                }
//                
//                else{
//                    if(dic && [[dic objectForKey:@"status"] isEqualToNumber:[NSNumber numberWithInt:1]])
//                    {
//                        successBlock(dic);
//                    }else{
//                        failed_Block();
//                    }
//                }
//                
//                [dic release];
//            }
//        }];
//        
//        
//        [my_request setFailedBlock:^{
//            
//            //从dic_request中删除:
//            if(my_request && my_request.url && my_request.url.absoluteString)
//            {
//                [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
//            }
//            
//            NSLog(@" Request Failed! error : %@",[[my_request error] description]);
//            failed_Block();
//        }];
//        
//        
//        [my_request startAsynchronous];
//    }
//    
//    
//    else if([method isEqualToString:@"post"]) //往服务器端提交数据
//    {
//        NSString *urlStr = [DomainName stringByAppendingFormat:@"/%@?", path];
//        urlStr = [NSString stringWithString:[urlStr stringByAppendingFormat:@"client_id=%@",ClientId_QY]];
//        urlStr = [NSString stringWithString:[urlStr stringByAppendingFormat:@"&client_secret=%@",ClientSecret_QY]];
//        
//        NSArray *allKeys_tmp = [params allKeys];
//        NSMutableArray *allKeys = [[NSMutableArray alloc] init];
//        for(int i = 0; i < params.count; i++)
//        {
//            NSString *key = [allKeys_tmp objectAtIndex:i];
//            
//            NSString *value_post = [params objectForKey:key];
//            
//            if([value_post isKindOfClass:[NSString class]] && ![value_post isEqualToString:@""])
//            {
//                [allKeys addObject:key];
//            }
//        }
//        
//        ASIFormDataRequest *my_request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] autorelease];
//        
//        if([sharedAPIClient.dic_request objectForKey:urlStr])
//        {
//            NSLog(@" 该请求还没有结束～～～");
//            [allKeys removeAllObjects];
//            [allKeys release];
//            return;
//        }
//        else
//        {
//            [sharedAPIClient.dic_request setObject:my_request forKey:urlStr]; //保存请求
//        }
//        
//        my_request.delegate = self;
//        my_request.shouldRedirect = NO;
//        my_request.timeOutSeconds = getdatamaxtime;
//        for(int i = 0; i < allKeys.count; i++)
//        {
//            NSString *key = [allKeys objectAtIndex:i];
//            NSString *value_post = [params objectForKey:key];
//            
//            if(value_post && value_post.length > 0)
//            {
//                [my_request addPostValue:value_post forKey:key];
//            }
//        }
//        [self processRequest:my_request];
//        
//        [allKeys removeAllObjects];
//        [allKeys release];
//        
//        
//        [my_request setCompletionBlock:^{
//            
//            //从dic_request中删除:
//            [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
//            
//            NSString *result = [my_request responseString];
//            NSLog(@" result : %@",result);
//            
//            if(result && result.length > 0)
//            {
//                SBJsonParser *json = [[SBJsonParser alloc] init];
//                NSDictionary *dic = [json objectWithString:result];
//                [json release];
//                
//                if ([path isEqualToString:@"qyer/user/oauth"]) {
//                                        
//                    successBlock(dic);
//                }
//                
//                else
//                {
//                    if(dic && [[dic objectForKey:@"status"] isEqualToNumber:[NSNumber numberWithInt:1]])
//                    {
//                        NSLog(@"post  ==  Request Finished == ");
//                        successBlock(dic);
//                    }
//                    else
//                    {
//                        NSLog(@"post  ==  Request Failed =0= ");
//                        NSLog(@" info : %@",[dic objectForKey:@"info"]);
//                        failed_Block();
//                    }
//                }
//                
//            }
//            else
//            {
//                NSLog(@"post  ==  Request Failed =1= ");
//                failed_Block();
//            }
//            
//        }];
//        
//        [my_request setFailedBlock:^{
//            
//            //从dic_request中删除:
//            [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
//            
//            NSLog(@"post  ==  Request Failed =2= ");
//            failed_Block();
//        }];
//        
//        [my_request startAsynchronous];
//    }
}

//by jessica
- (void)sendNewRequestPath:(NSString *)path
             parameters:(NSDictionary *)params
                 method:(NSString *)method
                success:(QYApiClientSuccessBlock)successBlock
                 failed:(QYApiClientFailedBlock_Error)failed_Block
{
    [ASIHTTPRequest hideNetworkActivityIndicator];
    
    if([method isEqualToString:@"get"])  //从服务器端获取数据
    {
        NSString *urlStr = [DomainName stringByAppendingFormat:@"/%@", path];
        urlStr = [self getRequestUrl:urlStr withParameters:params];
        
        
        NSLog(@"  sendRequest - Url : %@",urlStr);
        if([path isEqualToString:@"qyer/bbs/thread_list"])
        {
            NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
            if(access_token)
            {
                NSString *fuck_api = [NSString stringWithFormat:@"&oauth_token=%@",access_token];
                urlStr = [urlStr stringByReplacingOccurrencesOfRegex:fuck_api withString:@""];
                NSLog(@"  sendRequest - Url (整理后) : %@",urlStr);
            }
        }
        
        
        [ASIHTTPRequest hideNetworkActivityIndicator];
        __block ASIHTTPRequest *my_request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
        my_request.timeOutSeconds = getdatamaxtime;
        
        
        if([sharedAPIClient.dic_request objectForKey:urlStr])
        {
            NSLog(@" 该请求还没有结束～～～");
            return;
        }
        else
        {
            NSLog(@" 保存该请求");
            [sharedAPIClient.dic_request setObject:my_request forKey:urlStr]; //保存请求
        }
        
        
        [my_request setCompletionBlock:^{
            
            //从dic_request中删除:
            [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
            
            NSString *result = [my_request responseString];
            if(result && result.length > 0)
            {
                SBJsonParser *json = [[SBJsonParser alloc] init];
                NSDictionary *dic = [[json objectWithString:result] retain];
                [json release];
                
                
                if ([path isEqualToString:@"qyer/wall/detail"]) {
                    successBlock(dic);
                }
                
                else{
                    
                    if (dic) {
                        
                        NSLog(@" dic ： %@",dic);
                        NSLog(@" info: %@",[dic objectForKey:@"info"]);
                        
                        if ([dic objectForKey:@"status"]) {
                            
                            NSInteger status = [[dic objectForKey:@"status"] intValue];
                            
                            if (status==1) {
                                successBlock(dic);
                            }
                            else if(status==2)
                            {
                                if ([path isEqualToString:@"qyer/bbs/thread_list"] || [path isEqualToString:@"qyer/footprint/create"]) {
                                    successBlock(dic);
                                }
                            }
                            else{
                                NSString *info = [dic objectForKey:@"info"];
                                NSError *error = [NSError errorWithDomain:@"qyer_Guide" code:status userInfo:[NSDictionary dictionaryWithObject:info forKey:NSLocalizedDescriptionKey]];
                                failed_Block(error);
                            
                            }
                            
                        }else{
                            NSError *error = [NSError errorWithDomain:@"qyer_Guide" code:Error_Common_Status userInfo:[NSDictionary dictionaryWithObject:Error_Common_Text forKey:NSLocalizedDescriptionKey]];
                            failed_Block(error);
                        }
                        
                    }else{
                        NSError *error = [NSError errorWithDomain:@"qyer_Guide" code:Error_Common_Status userInfo:[NSDictionary dictionaryWithObject:Error_Common_Text forKey:NSLocalizedDescriptionKey]];
                        failed_Block(error);
                    }
                }
                
                [dic release];
            }
        }];
        
        
        [my_request setFailedBlock:^{
            
            //从dic_request中删除:
            [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
            
            
            NSLog(@" Request Failed! error : %@",[[my_request error] description]);
            failed_Block([my_request error]);
        }];
        
        
        [my_request startAsynchronous];
    }
    
    
    else if([method isEqualToString:@"post"]) //往服务器端提交数据
    {
        NSString *urlStr = [DomainName stringByAppendingFormat:@"/%@?", path];
        urlStr = [NSString stringWithString:[urlStr stringByAppendingFormat:@"client_id=%@",ClientId_QY]];
        urlStr = [NSString stringWithString:[urlStr stringByAppendingFormat:@"&client_secret=%@",ClientSecret_QY]];
        
        NSArray *allKeys_tmp = [params allKeys];
        NSMutableArray *allKeys = [[NSMutableArray alloc] init];
        for(int i = 0; i < params.count; i++)
        {
            NSString *key = [allKeys_tmp objectAtIndex:i];
            
            NSString *value_post = [params objectForKey:key];
            
            if([value_post isKindOfClass:[NSString class]] && ![value_post isEqualToString:@""])
            {
                [allKeys addObject:key];
            }
        }
        
        ASIFormDataRequest *my_request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] autorelease];
        
        if([sharedAPIClient.dic_request objectForKey:urlStr])
        {
            NSLog(@" 该请求还没有结束～～～");
            [allKeys removeAllObjects];
            [allKeys release];
            return;
        }
        else
        {
            [sharedAPIClient.dic_request setObject:my_request forKey:urlStr]; //保存请求
        }
        
        my_request.delegate = self;
        my_request.shouldRedirect = NO;
        my_request.timeOutSeconds = getdatamaxtime;
        for(int i = 0; i < allKeys.count; i++)
        {
            NSString *key = [allKeys objectAtIndex:i];
            NSString *value_post = [params objectForKey:key];
            
            if(value_post && value_post.length > 0)
            {
                [my_request addPostValue:value_post forKey:key];
            }
        }
        [self processRequest:my_request];
        
        [allKeys removeAllObjects];
        [allKeys release];
        
        
        [my_request setCompletionBlock:^{
            
            //从dic_request中删除:
            [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
            
            NSString *result = [my_request responseString];
            NSLog(@" result (post) : %@",result);
            
            if(result && result.length > 0)
            {
                SBJsonParser *json = [[SBJsonParser alloc] init];
                NSDictionary *dic = [json objectWithString:result];
                [json release];
                
                if ([path isEqualToString:@"qyer/user/oauth"]) {
                    
                    successBlock(dic);
                }
                
                else
                {
                    if (dic) {
                        if ([dic objectForKey:@"status"]) {
                            
                            NSInteger status = [[dic objectForKey:@"status"] intValue];
                            if (status==1) {
                                NSLog(@"post  ==  Request Finished == ");
                                NSLog(@"info:%@",[dic objectForKey:@"info"]);
                                successBlock(dic);
                            }
                            else if([path isEqualToString:@"qyer/footprint/create"] && [[dic objectForKey:@"info"] rangeOfString:@"已经标记过"].location != NSNotFound) //特殊情况
                            {
                                NSLog(@"path:%@",path);
                                NSLog(@"info:%@",[dic objectForKey:@"info"]);
                                successBlock(dic);
                            }
                            else{
                                NSString *info = [dic objectForKey:@"info"];
                                NSError *error = [NSError errorWithDomain:@"qyer_Guide" code:status userInfo:[NSDictionary dictionaryWithObject:info forKey:NSLocalizedDescriptionKey]];
                                failed_Block(error);
                                
                            }
                            
                        }else{
                            NSError *error = [NSError errorWithDomain:@"qyer_Guide" code:Error_Common_Status userInfo:[NSDictionary dictionaryWithObject:Error_Common_Text forKey:NSLocalizedDescriptionKey]];
                            failed_Block(error);
                        
                        }
                        
                    }else{
                        NSError *error = [NSError errorWithDomain:@"qyer_Guide" code:Error_Common_Status userInfo:[NSDictionary dictionaryWithObject:Error_Common_Text forKey:NSLocalizedDescriptionKey]];
                        failed_Block(error);
                    
                    }
                }
                
            }
            else
            {
                NSLog(@"post  ==  Request Failed =1= ");
                NSError *error = [NSError errorWithDomain:@"qyer_Guide" code:Error_Common_Status userInfo:[NSDictionary dictionaryWithObject:Error_Common_Text forKey:NSLocalizedDescriptionKey]];
                failed_Block(error);
            }
            
        }];
        
        [my_request setFailedBlock:^{
            
            //从dic_request中删除:
            [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
            
            NSLog(@"post  ==  Request Failed =2= ");
            failed_Block([my_request error]);
        }];
        
        [my_request startAsynchronous];
    }
}



#pragma mark -

//第三方账号登录验证
-(void)sendSNSToServerWithType:(NSString *)type
                  Access_Token:(NSString *)token
                           UID:(NSString *)userID
                  SNS_Username:(NSString *)userName
                       success:(QYApiClientSuccessBlock)successBlock
                        failed:(QYApiClientFailedBlock)failedBlock
{
    NSString * uNamePre = [NSString string];
    NSString * uNamePro = [NSString string];
    
    if (userName.length >=2) {
        uNamePre = [userName substringToIndex:2];
        uNamePro = [userName substringFromIndex:userName.length -2];
    }
    
    NSString * uIDPre = [NSString string];
    NSString * uIDPro = [NSString string];
    
    if (userID.length >=2) {
        uIDPre = [userID substringToIndex:2];
        uIDPro = [userID substringFromIndex:userID.length -2];
    }
    
    NSString * authSecret = [NSString stringWithFormat:@"%@%@%@%@",uNamePre,uIDPre,uNamePro,uIDPro];
    NSString * MD5String = [self md5:[self md5:authSecret]];
        
    NSMutableDictionary *parameters = [[[NSMutableDictionary alloc] init]autorelease];
    
    [parameters setObject:MD5String forKey:@"account_s"];
    [parameters setObject:[NSString stringWithFormat:@"%@",type] forKey:@"type"];
    [parameters setObject:[NSString stringWithFormat:@"%@",token] forKey:@"access_token"];
    [parameters setObject:[NSString stringWithFormat:@"%@",userID] forKey:@"sns_user_id"];
    [parameters setObject:[NSString stringWithFormat:@"%@",userName] forKey:@"sns_username"];
    
    [self sendRequestPath:@"qyer/user/oauth"
               parameters:parameters
                   method:@"post"
                  success:successBlock
                   failed:failedBlock];
}


-(NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr,strlen(cStr), result );
    
    NSString *outStr = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        result[0], result[1], result[2], result[3],
                        result[4], result[5], result[6], result[7],
                        result[8], result[9], result[10], result[11],
                        result[12], result[13], result[14], result[15]
                        ];
    return outStr;
}



//#pragma mark -
//#pragma mark --- 取消某个请求:
//-(void)cancleRequestByUrlString:(NSString *)urlString
//{
//    if(sharedAPIClient && sharedAPIClient.dic_request)
//    {
//        //取消请求:
//        ASIHTTPRequest *my_request = [sharedAPIClient.dic_request objectForKey:urlString];
//        [my_request clearDelegatesAndCancel];
//
//
//        //从dic_request中删除:
//        [sharedAPIClient.dic_request removeObjectForKey:urlString];
//    }
//}



#pragma mark -
#pragma mark --- 获取未登录状态下允许下载锦囊的个数:
-(void)getMobileDownloadLimit:(QYApiClientSuccessBlock)successBlock
                       failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [self sendRequestPath:@"guide/get_mobile_download_limit"
               parameters:params
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [params removeAllObjects];
    [params release];
}




#pragma mark -
#pragma mark --- 获取全部锦囊列表
-(void)getAllMobileGuideListWithModifiedTime:(NSInteger)modifiedTime
                                     success:(QYApiClientSuccessBlock)successBlock
                                      failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d",modifiedTime] forKey:@"modified"];
    [parameters setObject:@"1" forKey:@"mobile_guide"]; //是否返回移动端锦囊
    [parameters setObject:@"2" forKey:@"order_type"];   //排序规则，1:按添加时间正序排列、2:按添加时间倒序、3:按更新时间倒序;默认为1

    
    [self sendRequestPath:@"guide/get_all"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


#pragma mark -
#pragma mark --- 获取已下线的锦囊列表:
-(void)getAllInvalidGuideListSuccess:(QYApiClientSuccessBlock)successBlock
                              failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [self sendRequestPath:@"guide/get_all_invalid"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


#pragma mark -
#pragma mark --- 获取某本锦囊的评论列表:
-(void)getGuideCommentByGuideId:(NSInteger)guideId
                       andCount:(NSInteger)count
                       andMaxId:(NSInteger)maxId
                        success:(QYApiClientSuccessBlock)successBlock
                         failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d",guideId] forKey:@"guide_id"];
    [parameters setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [parameters setObject:[NSString stringWithFormat:@"%d",maxId] forKey:@"max_id"];
    
    
    [self sendRequestPath:@"guide_com/get_list"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


#pragma mark -
#pragma mark --- 获取锦囊分类:
-(void)getGuideCategoryListMobile:(BOOL)bMobile
                     successBlock:(QYApiClientSuccessBlock)successBlock
                      failedBlock:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d",bMobile] forKey:@"mobile_guide"];
    
    
    [self sendRequestPath:@"guide_clazz/get_list"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


#pragma mark -
#pragma mark --- 添加我对锦囊的评论:
-(void)sendMyCommentByAccessToken:(NSString *)accessToken
                       andGuideId:(NSString *)guideid
                   andCommentText:(NSString *)comment
                         finished:(QYApiClientSuccessBlock)successBlock
                           failed:(QYApiClientFailedBlock_detail)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"guide_clazz/get_list" forKey:@"url"];
    [parameters setObject:accessToken forKey:@"oauth_token"];
    [parameters setObject:guideid forKey:@"guide_id"];
    [parameters setObject:comment forKey:@"content"];
    
    
//    [self sendRequestPath:@"guide_com/add"
//               parameters:parameters
//                   method:@"post"
//                  success:successBlock
//                   failed:failedBlock];
    [self sendMyGuideCommentWithApi:@"guide_com/add"
                         parameters:parameters
                            success:successBlock
                             failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}
-(void)sendMyGuideCommentWithApi:(NSString *)path
                      parameters:(NSDictionary *)params
                         success:(QYApiClientSuccessBlock)successBlock
                          failed:(QYApiClientFailedBlock_detail)failed_Block
{
    NSString *urlStr = [DomainName stringByAppendingFormat:@"/%@?", path];
    urlStr = [NSString stringWithString:[urlStr stringByAppendingFormat:@"client_id=%@",ClientId_QY]];
    urlStr = [NSString stringWithString:[urlStr stringByAppendingFormat:@"&client_secret=%@",ClientSecret_QY]];
    
    NSArray *allKeys_tmp = [params allKeys];
    NSMutableArray *allKeys = [[NSMutableArray alloc] init];
    for(int i = 0; i < params.count; i++)
    {
        NSString *key = [allKeys_tmp objectAtIndex:i];
        
        NSString *value_post = [params objectForKey:key];
        
        if([value_post isKindOfClass:[NSString class]] && ![value_post isEqualToString:@""])
        {
            [allKeys addObject:key];
        }
    }
    
    ASIFormDataRequest *my_request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] autorelease];
    
    if([sharedAPIClient.dic_request objectForKey:urlStr])
    {
        NSLog(@" 该请求还没有结束～～～");
        [allKeys removeAllObjects];
        [allKeys release];
        return;
    }
    else
    {
        [sharedAPIClient.dic_request setObject:my_request forKey:urlStr]; //保存请求
    }
    
    my_request.delegate = self;
    my_request.shouldRedirect = NO;
    my_request.timeOutSeconds = getdatamaxtime;
    for(int i = 0; i < allKeys.count; i++)
    {
        NSString *key = [allKeys objectAtIndex:i];
        NSString *value_post = [params objectForKey:key];
        
        if(value_post && value_post.length > 0)
        {
            [my_request addPostValue:value_post forKey:key];
        }
    }
    [self processRequest:my_request];
    
    [allKeys removeAllObjects];
    [allKeys release];
    
    
    [my_request setCompletionBlock:^{
        
        //从dic_request中删除:
        [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
        
        NSString *result = [my_request responseString];
        NSLog(@" result : %@",result);
        
        if(result && result.length > 0)
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSDictionary *dic = [json objectWithString:result];
            [json release];
            
            if(dic && [[dic objectForKey:@"status"] isEqualToNumber:[NSNumber numberWithInt:1]])
            {
                NSLog(@"post  ==  Request Finished == ");
                successBlock(dic);
            }
            else
            {
                NSLog(@"post  ==  Request Failed =0= ");
                NSLog(@" info : %@",[dic objectForKey:@"info"]);
                NSString *info = [dic objectForKey:@"info"];
                failed_Block(info);
            }
            
        }
        else
        {
            NSLog(@"post  ==  Request Failed =1= ");
            failed_Block(nil);
        }
        
    }];
    
    [my_request setFailedBlock:^{
        
        //从dic_request中删除:
        [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
        
        NSLog(@"post  ==  Request Failed =2= ");
        failed_Block(nil);
    }];
    
    [my_request startAsynchronous];
}







#pragma mark -
#pragma mark --- 获取更多穷游应用:
-(void)getMoreApplicationSuccess:(QYApiClientSuccessBlock)successBlock
                          failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
    
    [self sendRequestPath:@"app/relations"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


#pragma mark -
#pragma mark --- 获取推送的相关信息:
-(void)getPushDataByClientid:(NSString *)client_id
            andClientSecrect:(NSString *)client_secrect
                andExtend_id:(NSInteger)extend_id
                    finished:(QYApiClientSuccessBlock)successBlock
                      failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d",extend_id] forKey:@"id"];
    
    [self sendRequestPath:@"app/get_push_extend"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


#pragma mark -
#pragma mark --- 用户行为统计:
-(void)postUserHabitWithAppId:(NSString *)appId
                andOauthToken:(NSString *)oauthToken
                  andDeviceId:(NSString *)deviceId
                      andData:(NSDictionary *)dic_userHabit
                     finished:(QYApiClientSuccessBlock)finishedBlock
                       failed:(QYApiClientFailedBlock)failedBlock
{
    //NSLog(@" dic_userHabit : %@ ",dic_userHabit);
    if(!dic_userHabit || !oauthToken)
    {
        failedBlock();
        return;
    }
    
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:appId forKey:@"appid"];
    [parameters setObject:oauthToken forKey:@"oauth_token"];
    [parameters setObject:deviceId forKey:@"device_id"];
    [parameters setObject:[dic_userHabit objectForKey:@"app_opentime"] forKey:@"app_opentime"];
    [parameters setObject:[dic_userHabit objectForKey:@"guide_detail"] forKey:@"guide_detail"];
    [parameters setObject:[dic_userHabit objectForKey:@"bookmark_detail"] forKey:@"bookmark_detail"];
    
    [self sendRequestPath:@"app/census/user"
               parameters:parameters
                   method:@"post"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


#pragma mark -
#pragma mark --- 用户反馈:
-(void)postUserFeedBackWithContent:(NSString *)content
                          finished:(QYApiClientSuccessBlock)finishedBlock
                            failed:(QYApiClientFailedBlock)failedBlock
{
    
    
}



#pragma mark -
#pragma mark --- 获取锦囊的最新下载次数:
-(void)getGuideDownloadTimeFinished:(QYApiClientSuccessBlock)finishedBlock
                             failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [self sendRequestPath:@"guide/get_downcount"
               parameters:parameters
                   method:@"post"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}






// ====================================== V4.0 =====================

//用户添加想去/去过的城市或国家
-(void)addCountryCityPlanOrBeenToWithType:(NSString *)type
                               ID:(NSString *)countryCityID
                           status:(NSString *)status
                          success:(QYApiClientSuccessBlock)finishedBlock
                           failed:(QYApiClientFailedBlock)failedBlock
{
    if (!type || !countryCityID || !status) {
        failedBlock();
        return;
    }
    
    NSString * token = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_access_token"];

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:type forKey:@"type"];
    [parameters setObject:countryCityID forKey:@"id"];
    [parameters setObject:status forKey:@"oper"];
    [parameters setObject:token forKey:@"oauth_token"];
    
    [self sendRequestPath:@"qyer/footprint/create"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}

//用户取消想去/去过的城市或国家
-(void)removeCountryCityPlanOrBeenToWithType:(NSString *)type
                                          ID:(NSString *)countryCityID
                                      status:(NSString *)status
                                     success:(QYApiClientSuccessBlock)finishedBlock
                                      failed:(QYApiClientFailedBlock)failedBlock
{
    if (!type || !countryCityID || !status) {
        failedBlock();
        return;
    }
    
    NSString * token = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_access_token"];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:type forKey:@"type"];
    [parameters setObject:countryCityID forKey:@"id"];
    [parameters setObject:status forKey:@"oper"];
    [parameters setObject:token forKey:@"oauth_token"];
    
    [self sendRequestPath:@"qyer/footprint/remove"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}



//获取国家数据:
-(void)getCountryDataByCountryId:(NSString *)str_countryId
                         success:(QYApiClientSuccessBlock)finishedBlock
                          failed:(QYApiClientFailedBlock)failedBlock
{
    if(!str_countryId)
    {
        failedBlock();
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:str_countryId forKey:@"country_id"];
    
    [self sendRequestPath:@"qyer/footprint/country_detail"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}

//获取城市数据:
-(void)getCityDataByCityId:(NSString *)str_cityId
                   success:(QYApiClientSuccessBlock)finishedBlock
                    failed:(QYApiClientFailedBlock)failedBlock
{
    if(!str_cityId)
    {
        failedBlock();
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:str_cityId forKey:@"city_id"];
    
    [self sendRequestPath:@"qyer/footprint/city_detail"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}

//获取某城市下的poi:
-(void)getCityPoiDataByCityId:(NSString *)str_cityId
                andCategoryId:(NSString *)str_categoryId
                     pageSize:(NSString *)str_pageSize
                         page:(NSString *)str_page
                      success:(QYApiClientSuccessBlock)finishedBlock
                       failed:(QYApiClientFailedBlock)failedBlock
{
    if(!str_cityId || !str_categoryId)
    {
        failedBlock();
        return;
    }
    
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:str_cityId forKey:@"cityid"];
    [parameters setObject:str_categoryId forKey:@"categoryid"];
    [parameters setObject:str_pageSize forKey:@"pagesize"];
    [parameters setObject:str_page forKey:@"page"];
    
    
    [self sendRequestPath:@"place/poi/get_poi_list"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


//获取某国家／城市下的行程
-(void)getRecommandPlanListByType:(int )type
                               ID:(NSString *)countryCityID
                           source:(NSString *)fromSource
                             page:(NSString *)pageIndex
                          success:(QYApiClientSuccessBlock)finishedBlock
                           failed:(QYApiClientFailedBlock)failedBlock
{
    NSString * countryCityType;
    
    if (type == 1) {
        countryCityType = @"country";
    }
    else{
        countryCityType = @"city";
    }

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:countryCityType forKey:@"type"];
    
    if (type == 1) {
        [parameters setObject:countryCityID forKey:@"countryid"];
    }
    else{
        [parameters setObject:countryCityID forKey:@"cityid"];
    }
    
    if ([fromSource isEqualToString:@"user"]) {
        [parameters setObject:@"user" forKey:@"recommand"];
    }
    else{
        [parameters setObject:@"editor" forKey:@"recommand"];
    }
    
    [parameters setObject:pageIndex forKey:@"page"];
    [parameters setObject:@"10" forKey:@"pagesize"];
    [parameters setObject:screenSize forKey:@"screensize"];
    
    [self sendRequestPath:@"place/common/get_recommend_plan_list"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];

    
}


//-(void)getPlanDataOfCityByCityId:(NSString *)str_Id
//                        pageSize:(NSString *)str_pageSize
//                            page:(NSString *)str_page
//                         success:(QYApiClientSuccessBlock)finishedBlock
//                          failed:(QYApiClientFailedBlock)failedBlock
//{
//    if(!str_Id)
//    {
//        failedBlock();
//        return;
//    }
//    
//    
//    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//    
//    [parameters setObject:@"city" forKey:@"type"];
//    [parameters setObject:str_Id forKey:@"cityid"];
//    [parameters setObject:str_page forKey:@"page"];
//    [parameters setObject:str_pageSize forKey:@"pagesize"];
//    [parameters setObject:screenSize forKey:@"screensize"];
//    
//    [self sendRequestPath:@"place/common/get_recommend_plan_list"
//               parameters:parameters
//                   method:@"get"
//                  success:finishedBlock
//                   failed:failedBlock];
//    
//    [parameters removeAllObjects];
//    [parameters release];
//}



//获取某国家／城市下的微游记:
-(void)getMicroTravelDataOfCountryByCountryId:(NSString *)str_Id
                                     pageSize:(NSString *)str_pageSize
                                         page:(NSString *)str_page
                                      success:(QYApiClientSuccessBlock)finishedBlock
                                       failed:(QYApiClientFailedBlock)failedBlock
{
    if(!str_Id)
    {
        failedBlock();
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:@"country" forKey:@"type"];
    [parameters setObject:str_Id forKey:@"countryid"];
    [parameters setObject:str_pageSize forKey:@"pagesize"];
    [parameters setObject:str_page forKey:@"page"];
    [parameters setObject:screenSize forKey:@"screensize"];
    
    [self sendRequestPath:@"place/common/get_essence_bbs_list"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}
-(void)getMicroTravelDataOfCityByCityId:(NSString *)str_Id
                               pageSize:(NSString *)str_pageSize
                                   page:(NSString *)str_page
                                success:(QYApiClientSuccessBlock)finishedBlock
                                 failed:(QYApiClientFailedBlock)failedBlock
{
    if(!str_Id)
    {
        failedBlock();
        return;
    }
    
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:@"city" forKey:@"type"];
    [parameters setObject:str_Id forKey:@"cityid"];
    [parameters setObject:str_pageSize forKey:@"pagesize"];
    [parameters setObject:str_page forKey:@"page"];
    [parameters setObject:screenSize forKey:@"screensize"];
    
    [self sendRequestPath:@"place/common/get_essence_bbs_list"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


//获取某大洲／当季热门／专题下的锦囊列表:
-(void)getCountryListByContinentId:(NSString *)str_continentId
                           success:(QYApiClientSuccessBlock)finishedBlock
                            failed:(QYApiClientFailedBlock)failedBlock
{
    if(!str_continentId)
    {
        failedBlock();
        return;
    }
    
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:str_continentId forKey:@"continentid"];
    
    [self sendRequestPath:@"place/country/get_country_list"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}

//根据国家或城市维度获取照片列表:
-(void)getPhotoListByType:(NSString *)type
              andObjectId:(NSString *)str_id
                  success:(QYApiClientSuccessBlock)finishedBlock
                   failed:(QYApiClientFailedBlock)failedBlock
{
    if(!type || !str_id)
    {
        failedBlock();
        return;
    }
    
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:type forKey:@"type"];
    [parameters setObject:str_id forKey:@"objectid"];
    
    [self sendRequestPath:@"common/get_photo_list"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}

//获取当即热门目的地列表:
-(void)getHotPlaceListSuccess:(QYApiClientSuccessBlock)finishedBlock
                       failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [self sendRequestPath:@"place/common/get_hot_area_data"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    [parameters removeAllObjects];
    [parameters release];
}

-(void)getAllPlaceListSuccess:(QYApiClientSuccessBlock)finishedBlock
                       failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [self sendRequestPath:@"place/common/get_all_country"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    [parameters removeAllObjects];
    [parameters release];
}

- (void)searchDataByText:(NSString *)text page:(NSInteger)page success:(QYApiClientSuccessBlock)finishedBlock failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:text forKey:@"keyword"];
    [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [self sendRequestPath:@"place/poi/get_srearch_list"
               parameters:parameters
                   method:@"post"           //必须使用ASIHttpRequest，否则请求参数带中文，会返回错误
                  success:finishedBlock
                   failed:failedBlock];
    [parameters removeAllObjects];
    [parameters release];
}

//获取某国家下的城市列表:
-(void)getCityListDataByCountryId:(NSString *)str_continentId
                         pageSize:(NSString *)pageSize
                             page:(NSString *)page
                          success:(QYApiClientSuccessBlock)finishedBlock
                           failed:(QYApiClientFailedBlock)failedBlock
{
    if(!str_continentId)
    {
        failedBlock();
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:str_continentId forKey:@"countryid"];
    [parameters setObject:pageSize forKey:@"pageSize"];
    [parameters setObject:page forKey:@"page"];
    
    
    [self sendRequestPath:@"place/city/get_city_list"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    [parameters removeAllObjects];
    [parameters release];
}


//获取锦囊详情:
-(void)getGuideDeatilInfoWithGuideId:(NSString *)guide_id
                             success:(QYApiClientSuccessBlock)finishedBlock
                              failed:(QYApiClientFailedBlock)failedBlock
{
    if(!guide_id)
    {
        failedBlock();
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:guide_id forKey:@"guideid"];
    
    [self sendRequestPath:@"guide/guide/get_guide_info"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}
-(void)cancleGuideDetailInfoWithGuideId:(NSString *)guide_id
{
    if(!guide_id)
    {
        return;
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:guide_id forKey:@"guideid"];
    
    [self cancleRequestPath:@"guide/guide/get_guide_info"
                 parameters:parameters
                     method:@"get"];
    
    [parameters removeAllObjects];
    [parameters release];
    
}

//获取全部锦囊列表:
-(void)fromV4_getAllMobileGuideListWithModifiedTime:(NSInteger)modifiedTime
                                            success:(QYApiClientSuccessBlock)successBlock
                                             failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d",modifiedTime] forKey:@"modified"];
    [parameters setObject:@"1" forKey:@"mobile_guide"]; //是否返回移动端锦囊
    [parameters setObject:@"2" forKey:@"order_type"];   //排序规则，1:按添加时间正序排列、2:按添加时间倒序、3:按更新时间倒序;默认为1
    
    
    [self sendRequestPath:@"guide/guide/get_guide_all"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}
//取消获取全部锦囊列表:
-(void)cancleGetAllMobileGuideListWithModifiedTime:(NSInteger)modifiedTime
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d",modifiedTime] forKey:@"modified"];
    [parameters setObject:@"1" forKey:@"mobile_guide"]; //是否返回移动端锦囊
    [parameters setObject:@"2" forKey:@"order_type"];   //排序规则，1:按添加时间正序排列、2:按添加时间倒序、3:按更新时间倒序;默认为1
    
    
    [self cancleRequestPath:@"guide/guide/get_guide_all"
                 parameters:parameters
                     method:@"get"];
    
    [parameters removeAllObjects];
    [parameters release];
}




//根据国家或城市ID获取锦囊列表:
-(void)getGuideListWithType:(NSString *)type
                      andId:(NSString *)str_id
                    success:(QYApiClientSuccessBlock)successBlock
                     failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:type forKey:@"type"];
    [parameters setObject:str_id forKey:@"objectid"];
    
    [self sendRequestPath:@"guide/guide/get_guide_list"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


//根据搜索字符串获取锦囊列表:
-(void)getGuideListWithSearchString:(NSString *)str
                            success:(QYApiClientSuccessBlock)successBlock
                             failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    [parameters setObject:str forKey:@"keyword"];
    
    [self sendRequestPath:@"guide/guide/get_search_guide_list"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}



/**
 获取折扣运营图片
 */
- (void)getOperationWithCount:(NSUInteger)count
                      success:(QYApiClientSuccessBlock)successBlock
                      failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if(count > 0)
    {
        [parameters setObject:[NSString stringWithFormat:@"%i", count] forKey:@"count"];
    }
    
    [self sendRequestPath:@"operation/get_top" parameters:parameters method:@"get" success:^(NSDictionary *dic) {
        
        successBlock(dic);
        
    } failed:^{
        
    }];
}


/**
 获取折扣运营图片
 */
- (void)getLastMinuteTopSuccess:(QYApiClientSuccessBlock)successBlock
                        failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [self sendRequestPath:@"lastminute/get_recommend" parameters:parameters method:@"get" success:^(NSDictionary *dic) {
        
        successBlock(dic);
        
    } failed:^{
        
    }];
    
}

/**
 获取服务器时间
 */
- (void)getServerTimeSuccess:(QYApiClientSuccessBlock)successBlock
                     failure:(QYApiClientFailedBlock)failureBlock;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [self sendRequestPath:@"app/time" parameters:params method:@"get" success:successBlock failed:failureBlock];
    
}

/*
 通过id字符串获取折扣列表
 */
- (void)getLastMinuteWithIds:(NSArray *)ids
                     success:(QYApiClientSuccessBlock)successBlock
                     failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init]autorelease];
    
    NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
    
    for (int i=0; i<ids.count;i++) {
        
        if (i < ids.count -1) {
            [string appendFormat:@"%@,",[ids objectAtIndex:i]];
        }else{
            [string appendString:[ids objectAtIndex:i]];
        }
    }
    [params setObject:string forKey:@"id"];
    
    [self sendRequestPath:@"lastminute/get_list_byid" parameters:params method:@"get" success:successBlock failed:failureBlock];
    [string release];
}


/**
 获取折扣总分类
 */
- (void)getCategoryAllWithType:(NSUInteger)type
                         times:(NSString *)times
                   continentId:(NSUInteger)continentId
                     countryId:(NSUInteger)countryId
                     departure:(NSString *)departure
                       success:(QYApiClientSuccessBlock)successBlock
                       failure:(QYApiClientFailedBlock)failureBlock{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL isCategoryRefreshed = [settings boolForKey:Setting_Category_IsRefreshed];
    
    
    //如果折扣筛选条件已经刷新，则取本地数据
    if (isCategoryRefreshed) {
        
        NSDictionary *dict = [[DataManager sharedManager] unarchiveWebDictFromCache:FileName_LastMinute_Category];
        successBlock(dict);
        
        return;
        
    }else{
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        
        
        [params setObject:[NSString stringWithFormat:@"%i", type] forKey:@"type"];
        
        if(times && ![times isEqualToString:@""])
        {
            [params setObject:times forKey:@"times"];
        }
        else
        {
            [params setObject:@"" forKey:@"times"];
        }
        
        [params setObject:[NSString stringWithFormat:@"%i", continentId] forKey:@"continent_id"];
        [params setObject:[NSString stringWithFormat:@"%i", countryId] forKey:@"country_id"];
        
        if(departure && ![departure isEqualToString:@""])
        {
            [params setObject:departure forKey:@"departure"];
        }
        
        [self sendRequestPath:@"lastminute/get_category_all" parameters:params method:@"get" success:^(NSDictionary *dic) {
            
            //第一次加载成功则缓存数据
            [[DataManager sharedManager] archiveDict:dic IntoCache:FileName_LastMinute_Category];
            [settings setBool:YES forKey:Setting_Category_IsRefreshed];
            [settings synchronize];
            
            if (successBlock) {
                successBlock(dic);
            }
            
        } failed:^{
            
            //如果缓存数据存在，则读缓存
            NSDictionary *dict = [[DataManager sharedManager] unarchiveWebDictFromCache:FileName_LastMinute_Category];
            
            if (dict) {
                successBlock(dict);
                
            }else{
                
                failureBlock();
            }
            
        }];
        
    }
    
    
}

/**
 获取折扣总分类 (提醒) by jessica
 */
- (void)getCategoryTotalWithType:(NSUInteger)type
                           times:(NSString *)times
                     continentId:(NSUInteger)continentId
                       countryId:(NSUInteger)countryId
                       departure:(NSString *)departure
                         success:(QYApiClientSuccessBlock)successBlock
                         failure:(QYApiClientFailedBlock)failureBlock
{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL isCategoryRefreshed = [settings boolForKey:Setting_Category_Total_IsRefreshed];
    
    //如果折扣筛选条件已经刷新，则取本地数据
    if (isCategoryRefreshed) {
        NSDictionary *dict = [[DataManager sharedManager] unarchiveWebDictFromCache:FileName_LastMinute_Category_Total];
        successBlock(dict);
        
        return;
        
    }else{
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        
        [params setObject:[NSString stringWithFormat:@"%i", type] forKey:@"type"];

        if(times && ![times isEqualToString:@""])
        {
            [params setObject:times forKey:@"times"];
        }
        else
        {
            [params setObject:@"" forKey:@"times"];
        }

        [params setObject:[NSString stringWithFormat:@"%i", continentId] forKey:@"continent_id"];
        [params setObject:[NSString stringWithFormat:@"%i", countryId] forKey:@"country_id"];

        if(departure && ![departure isEqualToString:@""])
        {
            [params setObject:departure forKey:@"departure"];
        }
        
        [self sendRequestPath:@"lastminute/get_category_total" parameters:params method:@"get" success:^(NSDictionary *dic) {
            
            //第一次加载成功则缓存数据
            [[DataManager sharedManager] archiveDict:dic IntoCache:FileName_LastMinute_Category_Total];
            [settings setBool:YES forKey:Setting_Category_Total_IsRefreshed];
            [settings synchronize];
            
            if (successBlock) {
                successBlock(dic);
            }
            
        } failed:^{
            
            //如果缓存数据存在，则读缓存
            NSDictionary *dict = [[DataManager sharedManager] unarchiveWebDictFromCache:FileName_LastMinute_Category_Total];
            
            if (dict) {
                successBlock(dict);
                
            }else{
                
                failureBlock();
            }
            
        }];
        
    }



}

/**
 获取折扣热门国家
 */
- (void)getHotCountrySuccess:(QYApiClientSuccessBlock)successBlock
                     failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [self sendRequestPath:@"lastminute/hot_country" parameters:params method:@"get" success:successBlock failed:failureBlock];

}

/**
 获取折扣列表（改）
 */
- (void)getLastMinuteListWithType:(NSUInteger)type
                            maxId:(NSUInteger)maxId
                         pageSize:(NSUInteger)pageSize
                            times:(NSString *)times
                      continentId:(NSUInteger)continentId
                        countryId:(NSUInteger)countryId
                        departure:(NSString *)departure
                          success:(QYApiClientSuccessBlock)successBlock
                          failure:(QYApiClientFailedBlock)failureBlock{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:[NSString stringWithFormat:@"%i", type] forKey:@"product_type"];
    [params setObject:[NSString stringWithFormat:@"%i", maxId] forKey:@"max_id"];
    [params setObject:[NSString stringWithFormat:@"%i", pageSize] forKey:@"page_size"];
    if(times && ![times isEqualToString:@""])
    {
        [params setObject:times forKey:@"times"];
    }
    else
    {
        [params setObject:@"" forKey:@"times"];
    }
    [params setObject:[NSString stringWithFormat:@"%i", continentId] forKey:@"continent_id"];
    [params setObject:[NSString stringWithFormat:@"%i", countryId] forKey:@"country_id"];
    if(departure && ![departure isEqualToString:@""])
    {
        [params setObject:departure forKey:@"departure"];
    }
    
    [params setObject:[NSString stringWithFormat:@"%i", is_show_pay] forKey:@"is_show_pay"];//显示支付类折扣

    [self sendRequestPath:@"lastminute/get_lastminute_list" parameters:params method:@"get" success:successBlock failed:failureBlock];
}


///**
// 获取折扣详情信息
// */
//- (void)getLastMinuteDetailWithID:(NSUInteger)ID
//                       OAuthToken:(NSString *)token
//                          success:(QYApiClientSuccessBlock)successBlock
//                          failure:(QYApiClientFailedBlock)failureBlock
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
//    
//    [params setObject:[NSString stringWithFormat:@"%d", ID] forKey:@"id"];
//    
//    if(token && ![token isEqualToString:@""])
//    {
//        [params setObject:token forKey:@"oauth_token"];
//    }
//    [self sendRequestPath:@"lastminute/get_detail" parameters:params method:@"get" success:successBlock failed:failureBlock];
//}

/**
 获取折扣详情 by 折扣
 */
- (void)getLastMinuteDetailWithId:(NSUInteger)lastMinuteId
                           source:(NSString*)aSource//进入折扣详情页的类名
                          success:(QYApiClientSuccessBlock)successBlock
                          failure:(QYApiClientFailedBlock)failureBlock
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:[NSString stringWithFormat:@"%i", lastMinuteId] forKey:@"id"];
    [params setObject:[NSString stringWithFormat:@"%@", aSource] forKey:@"source"];
    
    [self sendRequestPath:@"lastminute/get_detail" parameters:params method:@"get" success:successBlock failed:failureBlock];
    
}

/**
 获取默认购买人信息 by 折扣
 */
- (void)getBuyerInfoSuccess:(QYApiClientSuccessBlock)successBlock
                    failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [self sendRequestPath:@"lastminute/app_get_contact" parameters:params method:@"get" success:successBlock failed:failureBlock];
    
//    [self sendRequestPath:@"lastminute/app_get_contact"
//                   params:params
//                   method:@"GET"
//                  success:successBlock
//                  failure:failureBlock];

}

/**
 lastminute 修改默认联系人信息 by 折扣
 */

- (void)changeBuyerInfoWithParams:(NSDictionary*)aParams
                          success:(QYApiClientSuccessBlock)successBlock
                          failure:(QYApiClientFailedBlock)failureBlock
{
    
    [self sendRequestPath:@"lastminute/app_post_contact" parameters:aParams method:@"post" success:successBlock failed:failureBlock];
    
//    [self sendRequestPath:@"lastminute/app_post_contact"
//                   params:aParams
//                   method:@"POST"
//                  success:successBlock
//                  failure:failureBlock];


}

/**
 获取折扣预订信息 by 折扣
 */
- (void)getLastMinuteOrderInfoWithId:(NSUInteger)lastMinuteId
                             success:(QYApiClientSuccessBlock)successBlock
                             failure:(QYApiClientFailedBlock_Error)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:[NSString stringWithFormat:@"%i", lastMinuteId] forKey:@"id"];
    
    [self sendNewRequestPath:@"lastminute/app_get_productsinfo" parameters:params method:@"get" success:successBlock failed:failureBlock];

    
//    [self sendRequestPath:@"lastminute/app_get_productsinfo"
//                   params:params
//                   method:@"GET"
//                  success:successBlock
//                  failure:failureBlock];

}

/**
 获取折扣套餐的品类信息 by 折扣
 */
- (void)getSectionCategorysWithId:(NSUInteger)productId
                          success:(QYApiClientSuccessBlock)successBlock
                          failure:(QYApiClientFailedBlock_Error)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:[NSString stringWithFormat:@"%i", productId] forKey:@"pid"];
    
    [self sendNewRequestPath:@"lastminute/get_lastminute_category_by_pid" parameters:params method:@"get" success:successBlock failed:failureBlock];
    
//    [self sendRequestPath:@"lastminute/get_lastminute_category_by_pid"
//                   params:params
//                   method:@"GET"
//                  success:successBlock
//                  failure:failureBlock];

}

/**
 lastminute 提交订单 by 折扣
 */

- (void)lastMinutePostOrderWithParams:(NSDictionary*)aParams
                              success:(QYApiClientSuccessBlock)successBlock
                              failure:(QYApiClientFailedBlock_Error)failureBlock
{
    
    
    [self sendNewRequestPath:@"lastminute/app_post_orderform" parameters:aParams method:@"post" success:successBlock failed:failureBlock];
    
//    [self sendRequestPath:@"lastminute/app_post_orderform"
//                   params:aParams
//                   method:@"POST"
//                  success:successBlock
//                  failure:failureBlock];

}

/**
 APP获取订单信息 by 折扣
 */
- (void)getLastMinuteOrderInfoDetailWithId:(NSUInteger)orderId
                                   success:(QYApiClientSuccessBlock)successBlock
                                   failure:(QYApiClientFailedBlock_Error)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:[NSString stringWithFormat:@"%i", orderId] forKey:@"id"];
    
    [self sendNewRequestPath:@"lastminute/app_get_orderforminfo" parameters:params method:@"get" success:successBlock failed:failureBlock];
    
//    [self sendRequestPath:@"lastminute/app_get_orderforminfo"
//                   params:params
//                   method:@"GET"
//                  success:successBlock
//                  failure:failureBlock];

}

/**
 APP获取订单列表 by 折扣
 */
- (void)getLastMinuteUserOrderListWithCount:(NSUInteger)aCount
                                       page:(NSUInteger)aPage
                                    success:(QYApiClientSuccessBlock)successBlock
                                    failure:(QYApiClientFailedBlock_Error)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:[NSString stringWithFormat:@"%i", aCount] forKey:@"count"];
    [params setObject:[NSString stringWithFormat:@"%i", aPage] forKey:@"page"];
    
    [params setObject:[NSString stringWithFormat:@"%i", is_show_pay] forKey:@"is_show_pay"];//显示支付类折扣
    
    [self sendNewRequestPath:@"lastminute/app_get_userorderformlist" parameters:params method:@"get" success:successBlock failed:failureBlock];
    
//    [self sendRequestPath:@"lastminute/app_get_userorderformlist"
//                   params:params
//                   method:@"GET"
//                  success:successBlock
//                  failure:failureBlock];

}

/**
 lastminute 删除订单 by 折扣
 */

- (void)deleteLastMinuteUserOrderWithParams:(NSDictionary*)aParams
                                    success:(QYApiClientSuccessBlock)successBlock
                                    failure:(QYApiClientFailedBlock_Error)failureBlock
{
    
    [self sendNewRequestPath:@"lastminute/app_post_del_orderform" parameters:aParams method:@"post" success:successBlock failed:failureBlock];
    
//    [self sendRequestPath:@"lastminute/app_post_del_orderform"
//                   params:aParams
//                   method:@"POST"
//                  success:successBlock
//                  failure:failureBlock];

}

/**
 lastminute 生成尾款订单 by 折扣
 */

- (void)createLastMinuteBalanceOrderWithParams:(NSDictionary*)aParams
                                       success:(QYApiClientSuccessBlock)successBlock
                                       failure:(QYApiClientFailedBlock_Error)failureBlock
{
    
    [self sendNewRequestPath:@"lastminute/app_post_second_orderform" parameters:aParams method:@"post" success:successBlock failed:failureBlock];
    
//    [self sendRequestPath:@"lastminute/app_post_second_orderform"
//                   params:aParams
//                   method:@"POST"
//                  success:successBlock
//                  failure:failureBlock];

}

/**
 lastminute提醒条件列表
 */
- (void)getRemindListWithMaxId:(NSUInteger)maxId
                      pageSize:(NSUInteger)pageSize
                       success:(QYApiClientSuccessBlock)successBlock
                       failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if(maxId > 0)
    {
        [params setObject:[NSString stringWithFormat:@"%i", maxId] forKey:@"max_id"];
    }
    if(pageSize > 0)
    {
        [params setObject:[NSString stringWithFormat:@"%i", pageSize] forKey:@"page_size"];
    }
    
    [self sendRequestPath:@"lastminute/subscribe_list" parameters:params method:@"get" success:successBlock failed:failureBlock];
    
}

/**
 lastminute添加提醒条件
 */
- (void)addLastMinuteRemindWithType:(NSUInteger)type
                              times:(NSString *)times
                      startPosition:(NSString *)startPosition
                          countryId:(NSUInteger)countryId
                            success:(QYApiClientSuccessBlock)successBlock
                            failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:[NSString stringWithFormat:@"%i", type] forKey:@"type"];
    [params setObject:times forKey:@"times"];
    [params setObject:[NSString stringWithFormat:@"%@", startPosition] forKey:@"dpt"];
    [params setObject:[NSString stringWithFormat:@"%i", countryId] forKey:@"country_id"];
    
    [self sendRequestPath:@"lastminute/add_subscribe" parameters:params method:@"post" success:successBlock failed:failureBlock];

}

/**
 lastminute取消提醒条件 by Jessica
 */
- (void)deleteLastMinuteRemindWithId:(NSUInteger)remindId
                             success:(QYApiClientSuccessBlock)successBlock
                             failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:[NSString stringWithFormat:@"%i", remindId] forKey:@"id"];
    
    [self sendRequestPath:@"lastminute/del_subscribe" parameters:params method:@"post" success:successBlock failed:failureBlock];

}

/**
 lastminute收藏列表
 */
- (void)getLastMinuteFavorListWithMaxId:(NSUInteger)maxId
                               pageSize:(NSUInteger)pageSize
                                success:(QYApiClientSuccessBlock)successBlock
                                failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if(maxId > 0)
    {
        [params setObject:[NSString stringWithFormat:@"%i", maxId] forKey:@"max_id"];
    }
    if(pageSize > 0)
    {
        [params setObject:[NSString stringWithFormat:@"%i", pageSize] forKey:@"page_size"];
    }
    
    [params setObject:[NSString stringWithFormat:@"%i", is_show_pay] forKey:@"is_show_pay"];//显示支付类折扣
    [self sendRequestPath:@"lastminute/favor_list" parameters:params method:@"get" success:successBlock failed:failureBlock];

}

/**
 lastminute取消收藏
 */
- (void)lastMinuteDeleteFavorWithId:(NSUInteger)lastMinuteId
                            success:(QYApiClientSuccessBlock)successBlock
                            failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:[NSString stringWithFormat:@"%i", lastMinuteId] forKey:@"id"];
    
    [self sendRequestPath:@"lastminute/del_favor" parameters:params method:@"post" success:successBlock failed:failureBlock];
    
}

/**
 lastminute添加收藏
 */
- (void)lastMinuteAddFavorWithId:(NSUInteger)lastMinuteId
                         success:(QYApiClientSuccessBlock)successBlock
                         failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:[NSString stringWithFormat:@"%i", lastMinuteId] forKey:@"id"];
    
    [self sendRequestPath:@"lastminute/add_favor" parameters:params method:@"post" success:successBlock failed:failureBlock];

}

/**
 回复论坛游记帖子
 */
- (void)sendThreadWithThreadID:(NSString *)threadID
                       Message:(NSString *)message
                       floorID:(NSString *)PID
                        userID:(NSString *)UID
                    floorIndex:(NSString *)floorIndexxx
                    OAuthToken:(NSString *)token
                       success:(QYApiClientSuccessBlock)successBlock
                       failure:(QYApiClientFailedBlock)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:threadID forKey:@"tid"];
    [params setObject:message forKey:@"message"];
    [params setObject:PID forKey:@"pid"];
    [params setObject:UID forKey:@"uid"];
    [params setObject:floorIndexxx forKey:@"floor"];
    [params setObject:token forKey:@"oauth_token"];
    
    [self sendRequestPath:@"post/add_post" parameters:params method:@"post" success:successBlock failed:failureBlock];
}



/**
 获取所有poi的位置坐标
 */
-(void)getRecommendWebHtmlWithAppVer:(NSString *)app_version
                           andWebVer:(NSString *)web_version
                             success:(QYApiClientSuccessBlock)successBlock
                              failed:(QYApiClientFailedBlock)failedBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params setObject:app_version forKey:@"app_version"];
    [params setObject:web_version forKey:@"web_version"];
    [self sendRequestPath:@"place/common/get_is_down_appview_index" parameters:params method:@"get" success:successBlock failed:failedBlock];
}

/**
 获取所有poi的位置坐标
 */
- (void)getAllPoiPositionByCityId:(NSString *)city_id
                          success:(QYApiClientSuccessBlock)successBlock
                           failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:city_id forKey:@"cityid"];
    
    [self sendRequestPath:@"place/poi/get_city_poi_list"
               parameters:params
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
}

/**
 获取国家的位置坐标
 */
- (void)getMapByCountryName:(NSString *)countryName
                    success:(QYApiClientSuccessBlock)successBlock
                     failed:(QYApiClientFailedBlock)failedBlock
{
    countryName = [countryName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlStr = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",countryName];
    
    [ASIHTTPRequest hideNetworkActivityIndicator];
    ASIHTTPRequest *my_request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
    my_request.timeOutSeconds = getdatamaxtime;
    my_request.delegate = self;
    
    [my_request setCompletionBlock:^{
        NSString *result = [my_request responseString];
        if(result && result.length > 0)
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSDictionary *dic = [json objectWithString:result];
            [json release];
            
            if(dic && [dic objectForKey:@"results"] )
            {
                NSLog(@" Request Finished : %@",my_request.url.absoluteString);
                successBlock(dic);
            }
            else
            {
                failedBlock();
            }
        }
    }];
    
    [my_request setFailedBlock:^{
        NSLog(@" Request Failed! ");
        NSLog(@" url : %@", my_request.url.absoluteString);
        NSLog(@" error : %@", [my_request responseString]);
        failedBlock();
    }];
    
    [my_request startAsynchronous];
    
}


//获取我的信息:
-(void)getMyInfoWithUserid:(NSString *)userid
                orImUserId:(NSString *)userid_im
                   success:(QYApiClientSuccessBlock)successBlock
                    failed:(QYApiClientFailedBlock)failedBlock
{
    
    if(!userid && !userid_im)
    {
        failedBlock();
    }
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(userid)
    {
        [params setObject:userid forKey:@"user_id"];
    }
    else if(userid_im)
    {
        [params setObject:userid_im forKey:@"im_user_id"];
    }
    
    [self sendRequestPath:@"/qyer/user/profile"
               parameters:params
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [params removeAllObjects];
    [params release];
}


//获取他人的个人信息:
-(void)getUserInfoWithUserId:(NSString *)user_id
                  orImUserId:(NSString *)userid_im
                     success:(QYApiClientSuccessBlock)successBlock
                      failed:(QYApiClientFailedBlock)failedBlock
{
    if(!user_id && !userid_im)
    {
        failedBlock();
    }
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init] ;
    if(user_id)
    {
        [params setObject:user_id forKey:@"user_id"];
    }
    else if(userid_im)
    {
        [params setObject:userid_im forKey:@"im_user_id"];
    }
    else
    {
        failedBlock();
        [params removeAllObjects];
        [params release];
        return;
    }
    
    [self sendRequestPath:@"/qyer/user/profile"
               parameters:params
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [params removeAllObjects];
    [params release];
}


//获取聊天室的小黑板列表
-(void)getChatRoomWallListWithRoomID:(NSString *)roomID
                                page:(NSInteger)pageIndex
                             success:(QYApiClientSuccessBlock)successBlock
                              failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[NSString stringWithFormat:@"%@",roomID] forKey:@"chatroom_id"];
    
    [params setObject:[NSString stringWithFormat:@"%d",pageIndex] forKey:@"page"];
    [params setObject:@"10" forKey:@"count"];
    
    [self sendRequestPath:@"qyer/wall/list"
               parameters:params
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
}

//用户在聊天室发布小黑板
- (void)postBoardToServerWithTitle:(NSString *)titleee
                           content:(NSString *)contenttt
                         imageData:(NSData *)imageData
                        chatRoomID:(NSString *)roomID
                             token:(NSString *)userToken
                           success:(QYApiClientSuccessBlock)successBlock
                           failure:(QYApiClientFailedBlock)failureBlock
{
    NSString *client_id = ClientId_QY;
    NSString *client_secret = ClientSecret_QY;
    NSString *access_tokennn = userToken;
    
    NSString * urlll = [NSString stringWithFormat:@"%@/qyer/wall/publish",DomainName];

    urlll = [[QYAPIClient sharedAPIClient]addTrackInfoWithUrlString:urlll];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL: [NSURL URLWithString:urlll]];
    [request setDelegate:self];
    [request setTimeOutSeconds:18];
    
    NSString *lat_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lat_user"]];
    NSString *lon_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lon_user"]];
    
    [request setPostValue:roomID forKey:@"chatroom_id"];
    [request setPostValue:client_id forKey:@"client_id"];
    [request setPostValue:client_secret forKey:@"client_secret"];
    [request setPostValue:access_tokennn forKey:@"oauth_token"];
    [request setPostValue:titleee forKey:@"title"];
    [request setPostValue:contenttt forKey:@"content"];
    [request setPostValue:lat_user forKey:@"lat"];
    [request setPostValue:lon_user forKey:@"lon"];
    
    
    if ([imageData isKindOfClass:[NSData class]] && imageData.length >0) {        
        [request setData:imageData withFileName:@"picture" andContentType:@"image/jpeg" forKey:@"photo"];
    }
    
    [request buildRequestHeaders];
    
    [request setCompletionBlock:^{
        
        NSData *data = [request responseData];
        
       NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
//        if([dictionary objectForKey:@"status"])
//        {
//            NSInteger status = [[dictionary objectForKey:@"status"] intValue];
        
//            if(status == 1)
//            {
//                NSString * newUserAvatar = [[dictionary objectForKey:@"data"] objectForKey:@"bigsrc"];
//                [[NSUserDefaults standardUserDefaults]setObject:newUserAvatar forKey:@"TripUserCover"];
        
                successBlock(dictionary);
//            }
//            else
//            {
//                NSString *info = [dictionary objectForKey:@"info"];
//                NSError *error = [NSError errorWithDomain:@"qyer_travel" code:status userInfo:[NSDictionary dictionaryWithObject:info forKey:NSLocalizedDescriptionKey]];
//            }
//        }
//        else {
//            
//        }
    }];
    
    
    [request setFailedBlock:^{
        
        [request clearDelegatesAndCancel];
//        NSError *error = [NSError errorWithDomain:@"qyer_guide net Not avilable" code:100000000 userInfo:nil];
        failureBlock();
    }];
    
    [request startAsynchronous];

}

//删除小黑板
-(void)deleteBoardDetailByWallID:(NSString *)wallID
                         success:(QYApiClientSuccessBlock)successBlock
                          failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[NSString stringWithFormat:@"%@",wallID] forKey:@"wall_id"];
    
    NSString * token = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_access_token"];
    [params setObject:[NSString stringWithFormat:@"%@",token] forKey:@"oauth_token"];
    
    
    [self sendRequestPath:@"qyer/wall/delete"
               parameters:params
                   method:@"post"
                  success:successBlock
                   failed:failedBlock];
}


//获取小黑板详情
-(void)getBoardDetailByWallID:(NSString *)wallID
                      success:(QYApiClientSuccessBlock)successBlock
                       failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[NSString stringWithFormat:@"%@",wallID] forKey:@"wall_id"];
    [self sendRequestPath:@"qyer/wall/detail"
               parameters:params
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
}


//获取小黑板评论列表
-(void)getBoardCommentsListByWallID:(NSString *)wallID
                              Count:(NSString *)count
                               Page:(NSString *)page
                            success:(QYApiClientSuccessBlock)successBlock
                             failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[NSString stringWithFormat:@"%@",wallID] forKey:@"wall_id"];
    [params setObject:[NSString stringWithFormat:@"%@",count] forKey:@"count"];
    [params setObject:[NSString stringWithFormat:@"%@",page] forKey:@"page"];

    [self sendRequestPath:@"qyer/wall/list_comments"
               parameters:params
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
}

//评论回复小黑板的内容
-(void)replyToBoardByWallID:(NSString *)wallID
                    Message:(NSString *)content
                    success:(QYApiClientSuccessBlock)successBlock
                     failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[NSString stringWithFormat:@"%@",wallID] forKey:@"wall_id"];
    [params setObject:[NSString stringWithFormat:@"%@",content] forKey:@"message"];
    
    NSString * token = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_access_token"];
    [params setObject:[NSString stringWithFormat:@"%@",token] forKey:@"oauth_token"];
    
    [self sendRequestPath:@"qyer/wall/publish_comment"
               parameters:params
                   method:@"post"
                  success:successBlock
                   failed:failedBlock];
}



//http://maps.google.com/maps/api/geocode/json?latlng=30.905361,116.463103&sensor=true&language=en
//根据经纬度，反地里编码
-(void)getLocationDataWithLat:(NSString *)lat
                          lng:(NSString *)lng
                       sensor:(NSString *)sensor
                     language:(NSString *)language
                      success:(QYApiClientSuccessBlock)successBlock
                       failed:(QYApiClientFailedBlock)failedBlock{
    
    NSString *strURL = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?latlng=%@,%@&sensor=%@&language=%@",lat,lng,@"true",@"en"];
 
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strURL]];
    
    [request setTimeOutSeconds:20];
    [request setCompletionBlock:^{
        
        NSString *result = [request responseString];
        
        if(result && result.length > 0)
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSDictionary *dic = [json objectWithString:result];
            [json release];
            
            if(dic && [[dic objectForKey:@"status"] isEqualToString:@"OK"])
            {
                NSLog(@"post  ==  Request Finished == ");
                successBlock(dic);
            }
            else
            {
                NSLog(@"post  ==  Request Failed =0= ");
                NSLog(@" info : %@",[dic objectForKey:@"info"]);
                failedBlock();
            }
        }
        else
        {
            NSLog(@"post  ==  Request Failed =1= ");
            failedBlock();
        }
    }];
    [request setFailedBlock:^{
        
        failedBlock();
    }];
    [request startAsynchronous];
    
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
//    [params setObject:[NSString stringWithFormat:@"%@",wallID] forKey:@"wall_id"];
//    [params setObject:[NSString stringWithFormat:@"%@",content] forKey:@"message"];
//    
//    NSString * token = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_access_token"];
//    [params setObject:[NSString stringWithFormat:@"%@",token] forKey:@"oauth_token"];
//    
//    [self sendRequestPath:@"qyer/wall/publish_comment"
//               parameters:params
//                   method:@"post"
//                  success:successBlock
//                   failed:failedBlock];
    
}

//获取用户所在地的聊天室:
-(void)getChatRoomWithLocation:(CLLocation *)location
                andCountryName:(NSString *)countryName
                   andCityName:(NSString *)cityName
                   andAreaName:(NSString *)areaName
                 andStreetName:(NSString *)streetName
                       success:(QYApiClientSuccessBlock)successBlock
                        failed:(QYApiClientFailedBlock)failedBlock
{
    countryName = [countryName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    areaName = [areaName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    cityName= [cityName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    streetName=[streetName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token && countryName && areaName)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:countryName forKey:@"country"];
        [params setObject:cityName forKey:@"p1_area"];
        [params setObject:areaName forKey:@"p2_area"];
        [params setObject:streetName forKey:@"p3_area"];
        [params setObject:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"lat"];
        [params setObject:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"lon"];
        [params setObject:access_token forKey:@"oauth_token"];
        [params setObject:@"ios" forKey:@"device_type"];
        [params setObject:[UniqueIdentifier getIdfa] forKey:@"device_id"];
        
        [self sendRequestPath:@"qyer/chatroom/get_by_location"
                   parameters:params
                       method:@"get"
                      success:successBlock
                       failed:failedBlock];
    }
    else
    {
        failedBlock();
    }
}
//获取用户所在地的聊天室2:
-(void)getChatRoomWithLocation:(CLLocation *)location success:(QYApiClientSuccessBlock)successBlock failed:(QYApiClientFailedBlock)failedBlock
{
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"lat"];
        [params setObject:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"lon"];
        [params setObject:access_token forKey:@"oauth_token"];
        [params setObject:@"ios" forKey:@"device_type"];
        [params setObject:[UniqueIdentifier getIdfa] forKey:@"device_id"];
        
        
        [self sendRequestPath:@"qyer/chatroom/get_by_location"
                   parameters:params
                       method:@"get"
                      success:successBlock
                       failed:failedBlock];
    }
    else
    {
        failedBlock();
    }
    
}

//获取用户Fans:
-(void)getFansDataWithUserid:(NSString *)user_id
                    andCount:(NSString *)count
                     andPage:(NSString *)page
                     success:(QYApiClientSuccessBlock)successBlock
                      failed:(QYApiClientFailedBlock)failedBlock
{
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:user_id forKey:@"user_id"];
        [params setObject:count forKey:@"count"];
        [params setObject:page forKey:@"page"];
        
        
        [self sendRequestPath:@"qyer/user/fans"
                   parameters:params
                       method:@"get"
                      success:successBlock
                       failed:failedBlock];
    }
    else
    {
        failedBlock();
    }
}
-(void)cancleGetFansDataWithUserid:(NSString *)user_id
                          andCount:(NSString *)count
                           andPage:(NSString *)page
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:user_id forKey:@"user_id"];
    [parameters setObject:count forKey:@"count"];
    [parameters setObject:page forKey:@"page"];
    
    [self cancleRequestPath:@"qyer/user/fans"
                 parameters:parameters
                     method:@"get"];
    
    [parameters removeAllObjects];
    [parameters release];
}



//获取用户Follow:
-(void)getFollowDataWithUserid:(NSString *)user_id
                      andCount:(NSString *)count
                       andPage:(NSString *)page
                       success:(QYApiClientSuccessBlock)successBlock
                        failed:(QYApiClientFailedBlock)failedBlock
{
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:user_id forKey:@"user_id"];
        [params setObject:count forKey:@"count"];
        [params setObject:page forKey:@"page"];
        
        
        [self sendRequestPath:@"qyer/user/follow"
                   parameters:params
                       method:@"get"
                      success:successBlock
                       failed:failedBlock];
    }
    else
    {
        failedBlock();
    }
}
-(void)cancleGetFollowDataWithUserid:(NSString *)user_id
                            andCount:(NSString *)count
                             andPage:(NSString *)page
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:user_id forKey:@"user_id"];
    [parameters setObject:count forKey:@"count"];
    [parameters setObject:page forKey:@"page"];
    
    [self cancleRequestPath:@"qyer/user/follow"
                 parameters:parameters
                     method:@"get"];
    
    [parameters removeAllObjects];
    [parameters release];
}


//统计聊天室人数
-(void)getChatroomStatsHotNum:(NSString *)HotNum
                       newNum:(NSString *)newNum
                      success:(QYApiClientSuccessBlock)successBlock
                       failed:(QYApiClientFailedBlock)failedBlock{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:@"3" forKey:@"hot"];
    [params setObject:@"3" forKey:@"new"];
    
    [self sendRequestPath:@"qyer/chatroom/stats"
               parameters:params
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
}
//获取聊天室成员列表
-(void)getChatRoomMembersWithRoomID:(NSString *)roomID
                           andCount:(NSString *)count
                            andPage:(NSString *)page
                            success:(QYApiClientSuccessBlock)successBlock
                             failed:(QYApiClientFailedBlock)failedBlock{
    
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:roomID forKey:@"roomID"];
        [params setObject:count forKey:@"count"];
        [params setObject:page forKey:@"page"];
        
        
        [self sendRequestPath:@"qyer/chatroom/members"
                   parameters:params
                       method:@"get"
                      success:successBlock
                       failed:failedBlock];
    }
    else
    {
        failedBlock();
    }
}

//新接口，获取聊天室成员
-(void)getChatRoomMembersWithIDs:(NSString *)userIDs
                         success:(QYApiClientSuccessBlock)successBlock
                          failed:(QYApiClientFailedBlock)failedBlock{
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:userIDs forKey:@"ids"];        
        
        [self sendRequestPath:@"qyer/user/im_users"
                   parameters:params
                       method:@"get"
                      success:successBlock
                       failed:failedBlock];
    }
    else
    {
        failedBlock();
    }
    
}

//获取用户想去的国家:
-(void)getWantGoDataWithUserid:(NSString *)userid
                       success:(QYApiClientSuccessBlock)successBlock
                        failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:userid forKey:@"user_id"];
    
    [self sendRequestPath:@"qyer/footprint/want_country"
               parameters:params
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
}
-(void)cancleGetWantGoDataWithUserid:(NSString *)userid
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:userid forKey:@"user_id"];
    
    [self cancleRequestPath:@"qyer/footprint/want_country"
                 parameters:parameters
                     method:@"get"];
    
    [parameters removeAllObjects];
    [parameters release];
}



//获取用户去过的国家:
-(void)getHasGoneDataWithUserid:(NSString *)userid
                        success:(QYApiClientSuccessBlock)successBlock
                         failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:userid forKey:@"user_id"];
    
    [self sendRequestPath:@"qyer/footprint/gone_country"
               parameters:params
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
}
-(void)cancleGetHasGoneDataWithUserid:(NSString *)userid
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:userid forKey:@"user_id"];
    
    [self cancleRequestPath:@"qyer/footprint/gone_country"
                 parameters:parameters
                     method:@"get"];
    
    [parameters removeAllObjects];
    [parameters release];
}



//获取用户去过/想去的城市的poi:
-(void)getGoneAndWantGoCitiesDataWithUserid:(NSString *)userid
                                  andCityId:(NSString *)str_cityId
                                    andType:(NSString *)type
                                    success:(QYApiClientSuccessBlock)successBlock
                                     failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:userid forKey:@"user_id"];
    [params setObject:str_cityId forKey:@"city_id"];
    
    if(type && [type isEqualToString:@"hasgone"])
    {
        [self sendRequestPath:@"qyer/footprint/gone_city"
                   parameters:params
                       method:@"get"
                      success:successBlock
                       failed:failedBlock];
    }
    else if(type && [type isEqualToString:@"wantgo"])
    {
        [self sendRequestPath:@"qyer/footprint/want_city"
                   parameters:params
                       method:@"get"
                      success:successBlock
                       failed:failedBlock];
    }
}
-(void)cancleGetGoneAndWantGoCitiesDataWithUserid:(NSString *)userid
                                        andCityId:(NSString *)str_cityId
                                          andType:(NSString *)type
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:userid forKey:@"user_id"];
    [parameters setObject:str_cityId forKey:@"city_id"];
    
    if(type && [type isEqualToString:@"hasgone"])
    {
        [self cancleRequestPath:@"qyer/footprint/gone_city"
                     parameters:parameters
                         method:@"get"];
    }
    else if(type && [type isEqualToString:@"wantgo"])
    {
        
    }
    
    [parameters removeAllObjects];
    [parameters release];
}



//关注:
-(void)followWithUserid:(NSString *)userid
                success:(QYApiClientSuccessBlock)successBlock
                 failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:userid forKey:@"user_id"];
    
    [self sendRequestPath:@"qyer/user/following"
               parameters:params
                   method:@"post"
                  success:successBlock
                   failed:failedBlock];
}

//取消关注:
-(void)unFollowWithUserid:(NSString *)userid
                  success:(QYApiClientSuccessBlock)successBlock
                   failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:userid forKey:@"user_id"];
    
    [self sendRequestPath:@"qyer/user/unfollowing"
               parameters:params
                   method:@"post"
                  success:successBlock
                   failed:failedBlock];
}


//上传用户的头像:
-(void)postAvatarWithImage:(UIImage *)image
                   success:(QYApiClientSuccessBlock)successBlock
                    failed:(QYApiClientFailedBlock)failedBlock
{
    NSString *urlStr = [DomainName stringByAppendingFormat:@"/%@", @"qyer/user/upload_avatar"];
    __block ASIFormDataRequest *my_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    my_request.delegate = self;
    my_request.shouldRedirect = NO;
    my_request.timeOutSeconds = getdatamaxtime;
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        [my_request setPostValue:access_token forKey:@"oauth_token"];
    }
    [my_request setPostValue:ClientId_QY forKey:@"client_id"];
    [my_request setPostValue:ClientSecret_QY forKey:@"client_secret"];
    NSData *data = UIImagePNGRepresentation(image);
    if(data == nil)
    {
        data = UIImageJPEGRepresentation(image, 1);
        [my_request setData:data withFileName:@"picture" andContentType:@"image/png" forKey:@"avatar"];
    }
    else
    {
        [my_request setData:data withFileName:@"picture" andContentType:@"image/jpeg" forKey:@"avatar"];
    }
    
    
    [self processRequest:my_request];
    
    [my_request setCompletionBlock:^{
        
        NSString *result = [my_request responseString];
        NSLog(@" result : %@",result);
        
        if(result && result.length > 0)
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSDictionary *dic = [json objectWithString:result];
            [json release];
            
            if(dic && [[dic objectForKey:@"status"] isEqualToNumber:[NSNumber numberWithInt:1]])
            {
                NSLog(@"post  ==  Request Finished == ");
                successBlock(dic);
            }
            else
            {
                NSLog(@"post  ==  Request Failed =0= ");
                NSLog(@" info : %@",[dic objectForKey:@"info"]);
                failedBlock();
            }
        }
        else
        {
            NSLog(@"post  ==  Request Failed =1= ");
            failedBlock();
        }
        
    }];
    
    [my_request setFailedBlock:^{
        
        NSLog(@"post  ==  Request Failed =2= ");
        failedBlock();
    }];
    
    [my_request startAsynchronous];
}


//上传用户的头图:
-(void)postPhotoWithImage:(UIImage *)image
                  success:(QYApiClientSuccessBlock)successBlock
                   failed:(QYApiClientFailedBlock)failedBlock
{
    NSString *urlStr = [DomainName stringByAppendingFormat:@"/%@", @"qyer/user/upload_cover"];
    __block ASIFormDataRequest *my_request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    my_request.delegate = self;
    my_request.shouldRedirect = NO;
    my_request.timeOutSeconds = getdatamaxtime;
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        [my_request setPostValue:access_token forKey:@"oauth_token"];
    }
    [my_request setPostValue:ClientId_QY forKey:@"client_id"];
    [my_request setPostValue:ClientSecret_QY forKey:@"client_secret"];
    NSData *data = UIImagePNGRepresentation(image);
    if(data == nil)
    {
        data = UIImageJPEGRepresentation(image, 1);
        [my_request setData:data withFileName:@"picture" andContentType:@"image/png" forKey:@"cover"];
    }
    else
    {
        [my_request setData:data withFileName:@"picture" andContentType:@"image/jpeg" forKey:@"cover"];
    }
    
    
    [self processRequest:my_request];
    
    [my_request setCompletionBlock:^{
        
        NSString *result = [my_request responseString];
        NSLog(@" result : %@",result);
        
        if(result && result.length > 0)
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSDictionary *dic = [json objectWithString:result];
            [json release];
            
            if(dic && [[dic objectForKey:@"status"] isEqualToNumber:[NSNumber numberWithInt:1]])
            {
                NSLog(@"post  ==  Request Finished == ");
                successBlock(dic);
            }
            else
            {
                NSLog(@"post  ==  Request Failed =0= ");
                NSLog(@" info : %@",[dic objectForKey:@"info"]);
                failedBlock();
            }
        }
        else
        {
            NSLog(@"post  ==  Request Failed =1= ");
            failedBlock();
        }
        
    }];
    
    [my_request setFailedBlock:^{
        
        NSLog(@"post  ==  Request Failed =2= ");
        failedBlock();
    }];
    
    [my_request startAsynchronous];
    
}



//获取通知列表
-(void)getNotificationListWithCount:(NSString *)count
                            andPage:(NSString *)page
                            success:(QYApiClientSuccessBlock)successBlock
                             failed:(QYApiClientFailedBlock)failedBlock{
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        [params setObject:count forKey:@"count"];
        [params setObject:page forKey:@"page"];
        
        
        [self sendRequestPath:@"qyer/notification/list"
                   parameters:params
                       method:@"get"
                      success:successBlock
                       failed:failedBlock];
    }
    else
    {
        failedBlock();
    }
}
// 获取私信列表
-(void)getPrichatListWithImUserId:(NSString *)imUserId
                            count:(NSString *)count
                            since:(NSString *)since
                          success:(QYApiClientSuccessBlock)successBlock
                           failed:(QYApiClientFailedBlock)failedBlock{
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        
        [params setObject:imUserId forKey:@"im_user_id"];
        [params setObject:count forKey:@"count"];
        [params setObject:since forKey:@"since"];

        [self sendRequestPath:@"qyer/dm/user_list"
                   parameters:params
                       method:@"get"
                      success:successBlock
                       failed:failedBlock];
    }
    else
    {
        failedBlock();
    }
    
}

//获取未读通知个数
-(void)getNotificationUnreadCount:(QYApiClientSuccessBlock)successBlock
                           failed:(QYApiClientFailedBlock)failedBlock{
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
        
        
        [self sendRequestPath:@"qyer/notification/unread"
                   parameters:params
                       method:@"get"
                      success:successBlock
                       failed:failedBlock];
    }
    else
    {
        failedBlock();
    }
}


//得到新首页推荐
-(void)getRecommandsSuccess:(QYApiClientSuccessBlock)successBlock
                     failed:(QYApiClientFailedBlock)failedBlock{
    
    [self sendRequestPath:@"qyer/recommands/index"
               parameters:nil
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];    
}


//
/**
 type		游记类型	index/country/city
 object_id	type = country 为 county_id type = city 为 city_id
 */
//新 精华游记推荐
-(void)getRecommandsTripByObjectId:(NSString *)str_Id
                              type:(NSString *)str_type
                                     pageSize:(NSString *)str_pageSize
                                         page:(NSString *)str_page
                                      success:(QYApiClientSuccessBlock)finishedBlock
                                       failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:str_type forKey:@"type"];
    if (str_Id) {
        [parameters setObject:str_Id forKey:@"object_id"];
    }
    [parameters setObject:str_pageSize forKey:@"count"];
    [parameters setObject:str_page forKey:@"page"];
    [parameters setObject:screenSize forKey:@"screensize"];
    
    [self sendRequestPath:@"qyer/recommands/trip"
               parameters:parameters
                   method:@"get"
                  success:finishedBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}



//获取poi详情:
-(void)getPoiDetailInfoByClientid:(NSString *)client_id
                 andClientSecrect:(NSString *)client_secrect
                            poiId:(NSInteger)poiId
                         finished:(QYApiClientSuccessBlock)finished
                           failed:(QYApiClientFailedBlock)failed
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[NSString stringWithFormat:@"%d",poiId] forKey:@"poi_id"];
    [params setObject:screenSize forKey:@"screensize"];
    
    
    [self sendRequestPath:@"qyer/footprint/poi_detail"
               parameters:params
                   method:@"get"
                  success:finished
                   failed:failed];
}


//评论poi --- 修改poi评论:
-(void)postMyCommentWithContent:(NSString *)comment
                        andRate:(NSString *)rate
                       andPoiid:(NSString *)poiid
                   andCommentid:(NSString *)commentId_user
                       finished:(QYApiClientSuccessBlock)finished
                         failed:(QYApiClientFailedBlock_detail)failed
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:poiid forKey:@"poi_id"];
    [params setObject:comment forKey:@"comment"];
    [params setObject:rate forKey:@"star"];
    if(commentId_user) //传 poi_id 和 comment_id 是更新原由的点评
    {
        [params setObject:commentId_user forKey:@"comment_id"];
    }
    
    
    [self sendMyPoiCommentWithApi:@"qyer/footprint/poi_publish_comment"
                       parameters:params
                          success:finished
                           failed:failed];
    
}
-(void)sendMyPoiCommentWithApi:(NSString *)path
                      parameters:(NSDictionary *)params
                         success:(QYApiClientSuccessBlock)successBlock
                          failed:(QYApiClientFailedBlock_detail)failed_Block
{
    NSString *urlStr = [DomainName stringByAppendingFormat:@"/%@?", path];
    urlStr = [NSString stringWithString:[urlStr stringByAppendingFormat:@"client_id=%@",ClientId_QY]];
    urlStr = [NSString stringWithString:[urlStr stringByAppendingFormat:@"&client_secret=%@",ClientSecret_QY]];
    
    NSArray *allKeys_tmp = [params allKeys];
    NSMutableArray *allKeys = [[NSMutableArray alloc] init];
    for(int i = 0; i < params.count; i++)
    {
        NSString *key = [allKeys_tmp objectAtIndex:i];
        
        NSString *value_post = [params objectForKey:key];
        
        if([value_post isKindOfClass:[NSString class]] && ![value_post isEqualToString:@""])
        {
            [allKeys addObject:key];
        }
    }
    
    ASIFormDataRequest *my_request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] autorelease];
    
    if([sharedAPIClient.dic_request objectForKey:urlStr])
    {
        NSLog(@" 该请求还没有结束～～～");
        [allKeys removeAllObjects];
        [allKeys release];
        return;
    }
    else
    {
        [sharedAPIClient.dic_request setObject:my_request forKey:urlStr]; //保存请求
    }
    
    my_request.delegate = self;
    my_request.shouldRedirect = NO;
    my_request.timeOutSeconds = getdatamaxtime;
    for(int i = 0; i < allKeys.count; i++)
    {
        NSString *key = [allKeys objectAtIndex:i];
        NSString *value_post = [params objectForKey:key];
        
        if(value_post && value_post.length > 0)
        {
            [my_request addPostValue:value_post forKey:key];
        }
    }
    [self processRequest:my_request];
    
    [allKeys removeAllObjects];
    [allKeys release];
    
    
    [my_request setCompletionBlock:^{
        
        //从dic_request中删除:
        [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
        
        NSString *result = [my_request responseString];
        NSLog(@" result : %@",result);
        
        if(result && result.length > 0)
        {
            SBJsonParser *json = [[SBJsonParser alloc] init];
            NSDictionary *dic = [json objectWithString:result];
            [json release];
            
            if(dic && [[dic objectForKey:@"status"] isEqualToNumber:[NSNumber numberWithInt:1]])
            {
                NSLog(@"post  ==  Request Finished == ");
                successBlock(dic);
            }
            else
            {
                NSLog(@"post  ==  Request Failed =0= ");
                NSLog(@" info : %@",[dic objectForKey:@"info"]);
                NSString *info = [dic objectForKey:@"info"];
                failed_Block(info);
            }
        }
        else
        {
            NSLog(@"post  ==  Request Failed =1= ");
            failed_Block(nil);
        }
        
    }];
    
    [my_request setFailedBlock:^{
        
        //从dic_request中删除:
        [sharedAPIClient.dic_request removeObjectForKey:my_request.url.absoluteString];
        
        NSLog(@"post  ==  Request Failed =2= ");
        failed_Block(nil);
    }];
    
    [my_request startAsynchronous];
}



//获取用户的帖子(游记):
-(void)getUserTravelDataWithUserId:(NSInteger)userId
                           andType:(NSString *)type
                          andCount:(NSInteger)count
                           andPage:(NSInteger)page
                           success:(QYApiClientSuccessBlock)successBlock
                            failed:(QYApiClientFailedBlock_Error)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d",userId] forKey:@"user_id"];
    [parameters setObject:type forKey:@"type"];
    [parameters setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [parameters setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
//    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
//    if(access_token && userId == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
//    {
//        //[parameters setObject:access_token forKey:@"oauth_token"];
//    }
//    else
//    {
//        [parameters setObject:[NSString stringWithFormat:@"%d",userId] forKey:@"user_id"];
//    }
    
    [self sendNewRequestPath:@"qyer/bbs/thread_list"
                  parameters:parameters
                      method:@"get"
                     success:successBlock
                      failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


//获取用户收藏的帖子(游记):
-(void)getUserCollectTravelDataWithUserId:(NSInteger)userId
                                  andType:(NSString *)type
                                 andCount:(NSInteger)count
                                  andPage:(NSInteger)page
                                  success:(QYApiClientSuccessBlock)successBlock
                                   failed:(QYApiClientFailedBlock_Error)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d",userId] forKey:@"user_id"];
    [parameters setObject:type forKey:@"type"];
    [parameters setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [parameters setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
//    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
//    if(access_token && userId == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
//    {
//        //[parameters setObject:access_token forKey:@"oauth_token"];
//    }
//    else
//    {
//        [parameters setObject:[NSString stringWithFormat:@"%d",userId] forKey:@"user_id"];
//    }
    
    [self sendNewRequestPath:@"qyer/bbs/thread_list"
                  parameters:parameters
                      method:@"get"
                     success:successBlock
                      failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


//将锦囊下载成功的消息反馈给服务器:
-(void)feedBackToServerWithGuideId:(NSInteger)guideId
                           success:(QYApiClientSuccessBlock)successBlock
                            failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d",guideId] forKey:@"guide_id"];
    [parameters setObject:@"1" forKey:@"guide_type"];  //1:HTML锦囊、2:PDF锦囊
    
    [self sendRequestPath:@"guide/down_record"
               parameters:parameters
                   method:@"post"
                  success:successBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
    
    
//    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:@"http://open.qyer.com/guide/down"]];
//    request.shouldRedirect = YES;
//    [request addPostValue:ClientId_QY forKey:@"client_id"];
//    [request addPostValue:ClientSecret_QY forKey:@"client_secret"];
//    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
//    if (access_token)
//    {
//        [request addPostValue:access_token forKey:@"oauth_token"];
//    }
//    
//    [request addPostValue:[NSString stringWithFormat:@"%d",guideId] forKey:@"guide_id"];
//    [request addPostValue:@"1" forKey:@"guide_type"];
//    [request startAsynchronous];
    
}


//添加足迹:
-(void)addFootPrintWithOper:(NSString *)oper
                    andType:(NSString *)type
                   andObjId:(NSInteger)obj_id
                    success:(QYApiClientSuccessBlock)successBlock
                     failed:(QYApiClientFailedBlock_Error)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:oper forKey:@"oper"];
    [parameters setObject:type forKey:@"type"];
    [parameters setObject:[NSString stringWithFormat:@"%d",obj_id] forKey:@"id"];
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        [parameters setObject:access_token forKey:@"oauth_token"];
    }
    
    [self sendNewRequestPath:@"qyer/footprint/create"
                  parameters:parameters
                      method:@"post"
                     success:successBlock
                      failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}

//删除足迹:
-(void)deleteFootPrintWithOper:(NSString *)oper
                       andType:(NSString *)type
                      andObjId:(NSInteger)obj_id
                       success:(QYApiClientSuccessBlock)successBlock
                        failed:(QYApiClientFailedBlock_Error)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:oper forKey:@"oper"];
    [parameters setObject:type forKey:@"type"];
    [parameters setObject:[NSString stringWithFormat:@"%d",obj_id] forKey:@"id"];
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        [parameters setObject:access_token forKey:@"oauth_token"];
    }
    
    [self sendNewRequestPath:@"qyer/footprint/remove"
                  parameters:parameters
                      method:@"post"
                     success:successBlock
                      failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}

//POI周边列表:
-(void)getPoiNearByWithLat:(float)lat
                    andLon:(float)lon
             andCategoryId:(NSInteger)categoryId
                  andPoiId:(NSInteger)poi_id
               andPageSize:(NSString *)str_pageSize
                   andPage:(NSString *)str_page
                   success:(QYApiClientSuccessBlock)finishedBlock
                    failed:(QYApiClientFailedBlock_Error)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d",poi_id] forKey:@"poi_id"];
    [parameters setObject:[NSString stringWithFormat:@"%f",lat] forKey:@"lat"];
    [parameters setObject:[NSString stringWithFormat:@"%f",lon] forKey:@"lon"];
    [parameters setObject:[NSString stringWithFormat:@"%d",categoryId] forKey:@"category_id"];
    [parameters setObject:str_pageSize forKey:@"count"];
    [parameters setObject:str_page forKey:@"page"];
    
    [self sendNewRequestPath:@"qyer/footprint/poi_list"
                  parameters:parameters
                      method:@"get"
                     success:finishedBlock
                      failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


//poi周边酒店:
-(void)getNearByHotelWithPoiId:(NSInteger)poi_id
                  andPageCount:(NSString *)pageCount
                       andPage:(NSString *)page
                       success:(QYApiClientSuccessBlock)finishedBlock
                        failed:(QYApiClientFailedBlock_Error)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%d",poi_id] forKey:@"poi_id"];
    [parameters setObject:pageCount forKey:@"count"];
    [parameters setObject:page forKey:@"page"];

    
    [self sendNewRequestPath:@"qyer/footprint/hotel_list"
                  parameters:parameters
                      method:@"get"
                     success:finishedBlock
                      failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}


#pragma mark-
#pragma mark----chenguanglin
- (void)getYouMayLikeSuccess:(QYApiClientSuccessBlock)successBlock failed:(QYApiClientFailedBlock)failedBlock{
    [self sendRequestPath:@"qyer/recommands/intelligent"
               parameters:nil
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
}

- (void)getTravelSubjectListWithType:(NSString *)type
                                  ID:(NSString *)ID
                               count:(NSInteger)count
                                page:(NSInteger)page
                             success:(QYApiClientSuccessBlock)successBlock
                              failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:type forKey:@"type"];
    [parameters setObject:ID forKey:@"id"];
    [parameters setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [self sendRequestPath:@"qyer/footprint/mguide_list"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    [parameters removeAllObjects];
    [parameters release];
}

- (void)getTravelSubjectDetailWithID:(NSString *)ID
                                page:(NSInteger)page
                              source:(NSString *)source
                             success:(QYApiClientSuccessBlock)successBlock
                              failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:ID forKey:@"id"];
    [parameters setObject:source forKey:@"source"];
    [parameters setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [self sendRequestPath:@"qyer/footprint/mguide_detail"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    
    [parameters removeAllObjects];
    [parameters release];
}
- (void)postBBSCollectStateWithOauthToken:(NSString *)oauthToken
                                      tid:(NSString *)tid
                                      fid:(NSString *)fid
                                     oper:(NSString *)oper
                                  success:(QYApiClientSuccessBlock)successBlock
                                   failed:(QYApiClientFailedBlock)failedBlock
{
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:oauthToken forKey:@"oauth_token"];
    [parameters setObject:tid forKey:@"tid"];
    [parameters setObject:fid forKey:@"fid"];
    [parameters setObject:oper forKey:@"oper"];
    [self sendRequestPath:@"qyer/bbs/thread_update"
               parameters:parameters
                   method:@"post"
                  success:successBlock
                   failed:failedBlock];
    [parameters removeAllObjects];
    [parameters release];
    
}
- (void)getBBSCollectStateWithOauthToken:(NSString *)oauthToken
                                     tid:(NSString *)tid
                                  source:(NSString *)source
                                 success:(QYApiClientSuccessBlock)successBlock
                                  failed:(QYApiClientFailedBlock)failedBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:oauthToken forKey:@"oauth_token"];
    [parameters setObject:tid forKey:@"tid"];
    [parameters setObject:source forKey:@"source"];
    [self sendRequestPath:@"qyer/bbs/thread_fav_status"
               parameters:parameters
                   method:@"get"
                  success:successBlock
                   failed:failedBlock];
    [parameters removeAllObjects];
    [parameters release];
}




//
////更新头像
//- (void)changeUserAvatarWithImage:(UIImage *)image
//                          success:(QYAPISuccessBlock)successBlock
//                          failure:(QYAPIFailureBlock)failureBlock
//{
//    NSString *client_id = kClientId;
//    NSString *client_secret = kClientSecret;
//    NSString *access_tokennn = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
//    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL: [NSURL URLWithString:@"http://open.qyer.com/user/edit_avatar"]];
//    [request setDelegate:self];
//    [request setPostValue:client_id forKey:@"client_id"];
//    [request setPostValue:client_secret forKey:@"client_secret"];
//    [request setPostValue:access_tokennn forKey:@"oauth_token"];
//
//    NSData *imageData = UIImageJPEGRepresentation(image, 1);
//    [request setData:imageData withFileName:@"picture" andContentType:@"image/jpeg" forKey:@"avatar"];
//    [request buildRequestHeaders];
//    
//    [request setCompletionBlock:^{
//        
//        NSData *data = [request responseData];
//        NSDictionary *dictionary = (NSDictionary *)[self responseJSON:data];
//        if([dictionary objectForKey:@"status"])
//        {
//            NSInteger status = [[dictionary objectForKey:@"status"] intValue];
//            if(status == 1)
//            {
//                NSString * newUserAvatar = [[dictionary objectForKey:@"data"] objectForKey:@"middle"];
//                [[NSUserDefaults standardUserDefaults]setObject:newUserAvatar forKey:@"TripUserAvatar"];
//                
//                successBlock(data);
//            }
//            else
//            {
//                NSString *info = [dictionary objectForKey:@"info"];
//                NSError *error = [NSError errorWithDomain:@"qyer_travel" code:status userInfo:[NSDictionary dictionaryWithObject:info forKey:NSLocalizedDescriptionKey]];
//                failureBlock(error);
//            }
//        }
//        else {
//            
//        }
//    }];
//    
//    
//    [request setFailedBlock:^{
//        
//        [request clearDelegatesAndCancel];
//        NSError *error = [NSError errorWithDomain:@"qyer_guide net Not avilable" code:Net_NotAvilable userInfo:nil];
//        failureBlock(error);
//    }];
//    
//    [request startAsynchronous];
//}


@end

