//
//  UserItineraryData.m
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-10.
//
//

#import "UserItineraryData.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"
#import "UserItinerary.h"
#import "RegexKitLite.h"
#import "FilePath.h"
#import "CacheData.h"
#import "DeviceInfo.h"
#import "UniqueIdentifier.h"


#define getdatamaxtime  10    //获取用户的行程列表的请求超时时间


@implementation UserItineraryData

//获取用户的行程列表:
+(void)getUserItineraryWithUserId:(NSString *)user_id
                      andPageSize:(NSString *)pageSize
                          success:(UserItineraryDataSuccessBlock)finished
                           failed:(UserItineraryDataFailedBlock)failed
{
    //本地缓存数据:
    NSString *plistPath = [[FilePath getUserItineraryPathWithUserId:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]] retain];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] && [user_id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]])
    {
        NSArray *array = [CacheData getCacheDataFromFilePath:plistPath];
        if(array && array.count > 0)
        {
            finished(array);
        }
    }
        
    
    
    NSString *url_str = [NSString stringWithFormat:@"%@/plan/get_list?uid=%@&page_size=%@&",DomainName,user_id,pageSize];
    url_str = [self initRequestUrl:url_str];
    //从服务器请求数据:
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_str]];
    request.timeOutSeconds = getdatamaxtime;
    MYLog(@"url ==UserItinerary== %@",[request.url absoluteString]);
    [request setCompletionBlock:^{
        
        NSString *result = [request responseString];
        
        if([[[result JSONValue] objectForKey:@"status"] intValue] == 1)
        {
            MYLog(@"获取用户的行程列表 成功");
            NSArray *array = [[result JSONValue] valueForKey:@"data"];
            NSArray *array_ = [[self produceData:array] retain];
            NSMutableArray *array_itinerary = [[NSMutableArray alloc] init];
            if(array_ && [array_ count] > 0)
            {
                //*** 按照更新时间排序:
                NSArray *array_sort = [array_ sortedArrayUsingComparator:^(UserItinerary *obj1, UserItinerary *obj2){
                    
                    NSString *str = [obj1.itineraryUpdateTime stringByReplacingOccurrencesOfRegex:@" " withString:@""];
                    str = [str stringByReplacingOccurrencesOfRegex:@"-" withString:@""];
                    NSString *str2 = [obj2.itineraryUpdateTime stringByReplacingOccurrencesOfRegex:@" " withString:@""];
                    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"-" withString:@""];
                    
                    NSInteger time1 = [str intValue];
                    NSInteger time2 = [str2 intValue];
                    if(time1 >= time2)
                    {
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    else if(time1 < time2)
                    {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                }];
                [array_itinerary removeAllObjects];
                [array_itinerary addObjectsFromArray:array_sort];
                
                
                //将数据缓存到本地:
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] && [user_id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]])
                {
                    [CacheData cacheData:array_itinerary toFilePath:plistPath];
                }
                
                
                finished(array_itinerary);
            }
            else
            {
                MYLog(@"获取用户的行程列表 暂无数据 ~~~ ");
                
                //将数据缓存到本地:
                [CacheData cacheData:array_itinerary toFilePath:plistPath];
                
                finished(array_itinerary);
            }
            
            [array_itinerary removeAllObjects];
            [array_itinerary release];
            [array_ release];
        }
        else
        {
            if([result rangeOfString:@"timed out"].location != NSNotFound)
            {
                MYLog(@"请求获取用户的行程列表 超时 ~~~");
                failed();
            }
            else
            {
                MYLog(@"获取用户的行程列表失败");
                failed();
            }
        }
    }];
    
    [request setFailedBlock:^{
        MYLog(@"获取用户的行程列表失败");
        
        failed();
    }];
    [request startAsynchronous];
    
    [plistPath release];
}
+(NSString *)initRequestUrl:(NSString *)string_url
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
    
    
    NSString *str_url = string_url;
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"client_id=%@",ClientId_QY]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&client_secret=%@",ClientSecret_QY]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&v=%@",API_version]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_user_id=%@",track_user_id]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_deviceid=%@",track_deviceid]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_app_version=%@",track_app_version]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_app_channel=%@",channel]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_device_info=%@",track_device_info]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_os=%@",track_os]];
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&oauth_token=%@",access_token]];
    }
    
    return str_url;
}




+(NSArray *)produceData:(NSArray *)array
{
    NSMutableArray *arr_ = [[NSMutableArray alloc] init];
    
    if(array && array.count > 0)
    {
        for(int i = 0; i < array.count; i++)
        {
            NSDictionary *dic = [array objectAtIndex:i];
            UserItinerary *itinerary = [[UserItinerary alloc] init];
            
            itinerary.itineraryCost = [NSString stringWithFormat:@"%@",[dic objectForKey:@"total_expense"]];
            itinerary.itineraryDays = [NSString stringWithFormat:@"%@",[dic objectForKey:@"total_day"]];
            itinerary.itineraryId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            itinerary.itineraryImageLink = [NSString stringWithFormat:@"%@",[dic objectForKey:@"pic"]];
            itinerary.itineraryLinkString = [NSString stringWithFormat:@"%@",[dic objectForKey:@"mapp_url"]];
            itinerary.itineraryPath_desc = [NSString stringWithFormat:@"%@",[dic objectForKey:@"info_desc"]];
            itinerary.itineraryPlannerName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"planner_name"]];
            itinerary.itineraryUpdateTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"utime"]];
            
            [arr_ addObject:itinerary];
            [itinerary release];
        }
    }
    
    return [arr_ autorelease];
}


@end
