//
//  webFrameCacheData.m
//  QYER
//
//  Created by Qyer on 14-4-9.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "webFrameCacheData.h"
#import <sys/xattr.h>
#import "QYAPIClient.h"
#import "ASIFormDataRequest.h"
#import "FilePath.h"

static id sharedWebFrameCacheData = nil;

@implementation webFrameCacheData
#pragma mark -
#pragma mark --- 单例
+(id)sharedCacheWebData 
{
    if (!sharedWebFrameCacheData)
    {
        sharedWebFrameCacheData = [[self alloc] init];
    }
    
    return sharedWebFrameCacheData;
}

#pragma mark -
#pragma mark --- 缓存数据 ^ ^ ^ ^ ^ ^
-(void)cachePoiData:(NSDictionary*)dic
{
    NSString *Path =[[self getCachePath] retain];
    NSString *destplist = [NSString stringWithFormat:@"%@/%@.html",Path,@"index1"];
    
    
    //这样直接写不行:
    //[dic writeToFile:destplist atomically:YES];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [data writeToFile:destplist atomically:NO];
    
    [Path release];
}
-(NSString*)getTmpCachePath{
    NSFileManager *fileManager = [NSFileManager defaultManager ];
    
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    [self addSkipBackupAttributeToItemAtURL:pathURL];
    
    
    NSString *plistPath = [NSString stringWithFormat:@"%@/webFrameData_Cache_Tmp",[pathURL path]];
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&ui])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return plistPath;
}
//返回缓存路径
-(NSString*)getCachePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager ];
    
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    [self addSkipBackupAttributeToItemAtURL:pathURL];
    
    
    NSString *plistPath = [NSString stringWithFormat:@"%@/webFrameData_Cache",[pathURL path]];
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&ui])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return plistPath;
}

#pragma mark -
#pragma mark --- 对沙盒里的某给定路径添加不进行'iTunes/iCloud备份'属性。
-(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.1)
    {
        NSError *error = nil;
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success)
        {
            //NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    }
    else
    {
        const char* filePath = [[URL path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
}

#pragma mark -
#pragma mark --- 获取wrb框架
-(void)getRecommendWebHtml:(NSString *)app_version
                 andWebVer:(NSString *)web_version
                    
{
    [[QYAPIClient sharedAPIClient] getRecommendWebHtmlWithAppVer:app_version
                                                       andWebVer:web_version
                                                         success:^(NSDictionary *dictionary){
                                                             
                                                             if(dictionary && [dictionary objectForKey:@"data"])
                                                             {
                                                                 NSDictionary *dic = [dictionary objectForKey:@"data"];
                                                                 if([dic isKindOfClass:[NSDictionary class]])
                                                                 {
                                                                     if([[dic objectForKey:@"isdown"] integerValue]!=0)
                                                                     {
                                                                         [self downWebHtmlFrameWork:[dic objectForKey:@"downurl"] version:[dic objectForKey:@"app_version"]];
                                                                         _version=[[dic objectForKey:@"app_version"] retain];
                                                                         
                                                                     }else{
                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"refleshWebView" object:nil userInfo:nil];
                                                                     }
                                                                     
                                                                 }
                                                                 
                                                             }
                                                             
                                                             
                                                         } failed:^{
                                                             
                                                             [[NSUserDefaults standardUserDefaults] setObject:@"1.0" forKey:@"RecommendWebHtml_FrameWork_Version"];
                                                             [[NSUserDefaults standardUserDefaults] synchronize];
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"refleshWebView" object:nil userInfo:nil];
                                                         }];
}


-(void)downWebHtmlFrameWork:(NSString*)value version:(NSString*)_version{
    if (value) {
        //NSLog(@"=======url:%@",value);
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:value]];

//        NSString *plistPath = [self getCachePath];
//        plistPath = [NSString stringWithFormat:@"%@/%@.html",plistPath,@"index1"];
        [request addRequestHeader:@"Content-Type" value:@"text/html"];
        
        [request setShouldAttemptPersistentConnection:NO];
        request.shouldContinueWhenAppEntersBackground = YES;  //后台允许下载
        request.shouldAttemptPersistentConnection = NO;
        request.timeOutSeconds = 15;
 //       NSFileManager *fileManager = [[NSFileManager alloc] init] ;
        request.delegate=self;
//        [request setCompletionBlock:^{
//           
//            NSString *result = [request responseString];
//            if(result && result.length > 0)
//            {
//                if ([fileManager fileExistsAtPath:plistPath]) {
//                    [fileManager removeItemAtPath:plistPath error:nil];
//                }
//                [result writeToFile:plistPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//                if ([fileManager fileExistsAtPath:plistPath]) {
//                    NSString *htmlString = [[NSString alloc] initWithContentsOfFile:plistPath encoding: NSUTF8StringEncoding error:nil];
//                    if (htmlString.length>5000) {
//                        [[NSUserDefaults standardUserDefaults] setObject:_version forKey:@"RecommendWebHtml_FrameWork_Version"];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
//                        
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refleshWebView" object:nil userInfo:nil];
//                    }
//                    [htmlString release];
//                }
//            }
//            
//            
//            
//            [fileManager release];
//        }];
//        
//        [request setFailedBlock:^{
//            [fileManager release];
//            NSLog(@"post  ==  Request Failed =2= ");
//            
//        }];
        [request startAsynchronous];
    }
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    

    NSString *plistPath = [self getCachePath];
    plistPath = [NSString stringWithFormat:@"%@/%@.html",plistPath,@"index1"];
     NSFileManager *fileManager = [[[NSFileManager alloc] init]autorelease] ;
    NSString *result = [request responseString];
    if(result && result.length > 0)
    {
        if ([fileManager fileExistsAtPath:plistPath]) {
            [fileManager removeItemAtPath:plistPath error:nil];
        }
        [result writeToFile:plistPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        if ([fileManager fileExistsAtPath:plistPath]) {
            NSString *htmlString = [[NSString alloc] initWithContentsOfFile:plistPath encoding: NSUTF8StringEncoding error:nil];
            if (htmlString.length>5000) {
                [[NSUserDefaults standardUserDefaults] setObject:_version forKey:@"RecommendWebHtml_FrameWork_Version"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString * cacheDirectory = [paths objectAtIndex:0];
                
                NSString *path = [cacheDirectory stringByAppendingString:@"responsesInfo.plist"];
                NSFileManager *fileManager = [[[NSFileManager alloc] init]autorelease];
                if ([fileManager fileExistsAtPath:path]) {
                    [fileManager removeItemAtPath:path error:nil];
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"RecommendWebCache_Need"];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refleshWebView" object:nil userInfo:nil];
                [cacheDirectory release];
                [fileManager release];
            }else{
                [self downWebHtmlFrameWork:[request.url absoluteString] version:_version];
            }
            [htmlString release];
        }
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request

{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pop_no_data" object:nil userInfo:nil];
//    NSError *error = [request error];
//    NSLog(@"error:%@",error.description);
    
}
@end
