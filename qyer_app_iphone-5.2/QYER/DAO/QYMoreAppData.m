//
//  QYMoreAppData.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-15.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "QYMoreAppData.h"
#import "QYAPIClient.h"
#import "QYMoreApp.h"
#import "FilePath.h"
#import "CacheData.h"


@implementation QYMoreAppData

+(void)getMoreApplicationSuccess:(QYMoreAppDataSuccessBlock)successBlock
                         failure:(QYMoreAppDataFaiedBlock)failedBlock
{
    //本地缓存数据:
    NSString *plistPath = [[FilePath getQYMoreAppPath] retain];
    NSArray *array_cache = [CacheData getCacheDataFromFilePath:plistPath];
    
    
    //从服务器请求数据:
    [[QYAPIClient sharedAPIClient] getMoreApplicationSuccess:^(NSDictionary *dic){
        NSArray *array = [dic objectForKey:@"data"];
        NSArray *array_ = [[self processData:array] retain];
        
        //将数据缓存到本地:
        [CacheData cacheData:array_ toFilePath:plistPath];
        
        successBlock(array_);
        
        [array_ release];
    } failed:^{
        if(array_cache && [array_cache isKindOfClass:[NSArray class]] && array_cache.count > 0)
        {
            NSLog(@" getMoreApplicationSuccess (本地缓存)");
            successBlock(array_cache);
        }
        else
        {
            NSLog(@" getMoreApplicationSuccess 失败!");
            failedBlock();
        }
    }];
    
    [plistPath release];
}

+(NSArray *)processData:(NSArray *)array
{
    NSMutableArray *array_ = [[NSMutableArray alloc] init];
    for(NSDictionary *dic in array)
    {
        QYMoreApp *more_app = [[QYMoreApp alloc] init];
        
        more_app.appAppStoreURL = [dic objectForKey:@"appstore_url"];
        more_app.appVersion = [NSString stringWithFormat:@"%@",[dic objectForKey:@"app_version"]];
        more_app.appName = [dic objectForKey:@"sub_name"];
        more_app.apptitle = [dic objectForKey:@"title"];
        more_app.appPicUrl = [dic objectForKey:@"thumb"];
        more_app.array_app = [[dic objectForKey:@"relation"] componentsSeparatedByString:@"|"];
        
        [array_ addObject:more_app];
        [more_app release];
    }
    return [array_ autorelease];
}


@end
