//
//  QYURLCache.m
//  QYGuide
//
//  Created by 你猜你猜 on 13-12-2.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "QYURLCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"
#import "FilePath.h"



static NSString *str_cacheDirectory;
static NSSet    *set_supportSchemes;



@implementation QYURLCache
@synthesize delegate = _delegate;
@synthesize flag_cache = _flag_cache;
@synthesize freshFlag;
@synthesize donotgetdatafromserver;

-(void)dealloc
{
    NSLog(@"  dealloc --- QYURLCache");
    
    [_queue release];
    [_dic_cachedResponses removeAllObjects];
    [_dic_cachedResponses release];
    [_dic_responsesInfo removeAllObjects];
    [_dic_responsesInfo release];
    
    if(_str_requestUrl && _str_requestUrl.retainCount > 0)
    {
        [_str_requestUrl release];
    }
    
    self.delegate = nil;
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- SHA1算法
-(NSString *)sha1:(NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}




#pragma mark -
#pragma mark --- 单例
static QYURLCache *sharedQYURLCache = nil;
+(QYURLCache *)sharedQYURLCache
{
    @synchronized(sharedQYURLCache)
    {
        if(!sharedQYURLCache)
        {
            sharedQYURLCache = [[self alloc] init];
        }
        return sharedQYURLCache;
    }
}




#pragma mark -
#pragma mark --- 初始化QYURLCache对象
- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path
{
    if(self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path])
    {
        str_cacheDirectory = [path retain];
        set_supportSchemes = [[NSSet setWithObjects:@"http", @"https", @"ftp", nil] retain];
        _dic_cachedResponses = [[NSMutableDictionary alloc] init];
        
        
        NSString *path = [NSString stringWithFormat:@"%@/%@",str_cacheDirectory,@"cache_responsesInfo.plist"];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            _dic_responsesInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        }
        else
        {
            _dic_responsesInfo = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}




#pragma mark -
#pragma mark --- [重写cachedResponseForRequest方法]-request请求发送前会被调用,此时我们可以判定是否针对此NSURLRequest返回本地数据
-(NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    
    NSLog(@"   cachedResponseForRequest");
    NSLog(@"   [NSURLCache sharedURLCache] : %@",[NSURLCache sharedURLCache]);
    NSLog(@"   url: %@",request.URL.absoluteString);
    
    
    //*** (1)如果不是get请求则返回:
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame)
    {
        return [super cachedResponseForRequest:request];
    }
    
    
    //*** (2)如果不是'http/https/ftp'类的请求则返回:
    NSURL *url = request.URL;
    if(![set_supportSchemes containsObject:url.scheme])
    {
        return [super cachedResponseForRequest:request];
    }
    
    
    
    
    
    
    //*** (3)本地磁盘有缓存:
    // check if it exist in disk
    NSString *absoluteString = url.absoluteString;
    if(_str_requestUrl && _str_requestUrl.retainCount > 0)
    {
        [_str_requestUrl release];
    }
    _str_requestUrl = [url.absoluteString retain];
    
    NSCachedURLResponse *cachedResponse = [_dic_cachedResponses objectForKey:absoluteString];
   
    NSDictionary *dic_responseInfo_tmp = [_dic_responsesInfo objectForKey:absoluteString];
    
    if(dic_responseInfo_tmp)
    {
        NSLog(@" 本地磁盘缓存: %@",absoluteString);
        NSString *path = [NSString stringWithFormat:@"%@/%@",str_cacheDirectory,[dic_responseInfo_tmp objectForKey:@"filename"]];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSURLResponse *response = [[[NSURLResponse alloc] initWithURL:request.URL MIMEType:[dic_responseInfo_tmp objectForKey:@"MIMEType"] expectedContentLength:data.length textEncodingName:nil] autorelease];
            cachedResponse = [[[NSCachedURLResponse alloc] initWithResponse:response data:data] autorelease];
            [_dic_cachedResponses setObject:cachedResponse forKey:absoluteString];
            
            NSLog(@"  cachedResponse    === %@",cachedResponse);
            NSLog(@"  absoluteString    === %@",absoluteString);
            
            
            _flag_cache = YES;
            
            
            //保存本地已有缓存的请求:
            if(!_array_cacheRequest)
            {
                _array_cacheRequest = [[NSMutableArray alloc] init];
            }
            [_array_cacheRequest addObject:request];
            
            
            return cachedResponse;
        }
    }
    
    
    
    
    //*** (4)没有缓存,并且没有网络:
    else if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        NSLog(@" 没有缓存,并且没有网络!");
        return [super cachedResponseForRequest:request];
    }
    
    
    
    //*** 06.25 新增 (若更新时间没有变,则不获取网络数据)
    if(self.donotgetdatafromserver)
    {
        return nil;
    }
    
    
    //*** (5)没有缓存,网络良好:
    else
    {
        NSLog(@" 没有缓存,网络良好!");
        [self getDataWithRequest:request];
        return [super cachedResponseForRequest:request];
    }
    
    
    return nil;
}




#pragma mark -
#pragma mark --- loadDataFromServer
-(void)loadDataFromServer:(NSURLRequest *)request
{
    [self performSelector:@selector(getDataWithRequest:) withObject:request afterDelay:0.8];
}
-(void)deleteAllLocalCaches
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        return;
    }
    
    @synchronized([NSString stringWithFormat:@"%d",_flag_deleteCaches])
    {
        if(_flag_deleteCaches)
        {
            NSLog(@"   已经删除所有的缓存 !");
            return;
        }
        
        _flag_deleteCaches = YES;
        NSLog(@"   删除所有的缓存");
        [_dic_responsesInfo removeAllObjects];
        [_dic_cachedResponses removeAllObjects];
        
        
        NSString *path_delete = [NSString stringWithFormat:@"%@",str_cacheDirectory];
        NSArray *array_file = [[NSFileManager defaultManager] subpathsAtPath:path_delete];
        for(NSString *str in array_file)
        {
            NSString *file_delete = [NSString stringWithFormat:@"%@/%@",path_delete,str];
            if([[NSFileManager defaultManager] fileExistsAtPath:file_delete])
            {
                if(![[NSFileManager defaultManager] removeItemAtPath:file_delete error:nil])
                {
                    NSLog(@" 删除缓存文件失败 ");
                }
                else
                {
                    NSLog(@" 删除缓存文件成功 ");
                }
            }
        }
    }
}
-(void)deleteAllLocalCachesWithFileName:(NSString *)file_name andUrl:(NSString *)url
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        return;
    }
    
    
    @synchronized([NSString stringWithFormat:@"%d",_flag_deleteCaches])
    {
        if(_flag_deleteCaches)
        {
            NSLog(@"   已经删除%@的缓存 !",file_name);
            return;
        }
        
        _flag_deleteCaches = YES;
        NSLog(@"   删除%@的缓存",file_name);
        [_dic_responsesInfo removeObjectForKey:url];
        [_dic_cachedResponses removeObjectForKey:url];
        
        NSString *pathName = [NSString stringWithFormat:@"webviewCache/plan/%@",file_name];
        NSString *path_delete = [[FilePath sharedFilePath] getFilePath:pathName];
        NSArray *array_file = [[NSFileManager defaultManager] subpathsAtPath:path_delete];
        for(NSString *str in array_file)
        {
            NSString *file_delete = [NSString stringWithFormat:@"%@/%@",path_delete,str];
            if([[NSFileManager defaultManager] fileExistsAtPath:file_delete])
            {
                if(![[NSFileManager defaultManager] removeItemAtPath:file_delete error:nil])
                {
                    NSLog(@" 删除缓存文件失败 ");
                }
                else
                {
                    NSLog(@" 删除缓存文件成功 ");
                }
            }
        }
    }
}




#pragma mark -
#pragma mark --- 从网络请求数据
-(void)getDataWithRequest:(NSURLRequest *)request
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        return;
    }
    
    
    
    NSURL *url = request.URL;
    NSString *absoluteString = url.absoluteString;
    NSLog(@" 从网络获取数据: %@",url.absoluteString);
    
    
    
    
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:request.timeoutInterval];
    newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
    newRequest.HTTPShouldHandleCookies = request.HTTPShouldHandleCookies;
    
    
    
    
    
    if(!_queue)
    {
        _queue = [[NSOperationQueue alloc] init];
    }
    [NSURLConnection sendAsynchronousRequest:newRequest
                                       queue:_queue
                           completionHandler:^(NSURLResponse *respone,NSData *data,NSError *error){
                               
                               
                               NSString *str_error = [error localizedDescription];
                               if(str_error && str_error.length > 0)
                               {
                                   NSLog(@"  error  error : %@",str_error);
                                   [_queue cancelAllOperations];
                                   return ;
                               }
                               
                               if(absoluteString)
                               {
                                   NSLog(@"  %@下载成功",absoluteString);
                               }
                               NSString *filename = [self sha1:absoluteString]; //对链接地址加密
                               
                               
                               BOOL ui;
                               if(![[NSFileManager defaultManager] fileExistsAtPath:str_cacheDirectory isDirectory:&ui])
                               {
                                   [[NSFileManager defaultManager] createDirectoryAtPath:str_cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
                               }
                               NSString *path_cacheData = [NSString stringWithFormat:@"%@/%@",str_cacheDirectory,filename]; //缓存存放的路径
                               [[NSFileManager defaultManager] createFileAtPath:path_cacheData contents:data attributes:nil];
                               
                               
                               NSDictionary *responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:filename, @"filename", respone.MIMEType, @"MIMEType", nil];
                               @synchronized(_dic_responsesInfo)
                               {
                                   if (absoluteString) {
                                       [_dic_responsesInfo setValue:responseInfo forKey:absoluteString]; //存放‘链接地址--请求的属性’
                                   }
                               }
                            
                               
                               if (absoluteString) {
                                   //保存该url的请求数据:
                                   NSCachedURLResponse *cachedResponse_tmp = [[NSCachedURLResponse alloc] initWithResponse:respone data:data];
                                   [_dic_cachedResponses setValue:cachedResponse_tmp forKey:absoluteString];
                                   [cachedResponse_tmp release];
                               }
                               
                               if(!_array_serverRequest)
                               {
                                   _array_serverRequest = [[NSMutableArray alloc] init];
                               }
                               [_array_serverRequest addObject:request];
                               if(_array_serverRequest.count == _array_cacheRequest.count)
                               {
                                   NSLog(@" 有本地缓存时,全部下载完毕!");
                                   
                                   [self saveCacheData];
                                   
                                   [self webViewNeedReloadData];
                                   
                               }
                               
                           }];
    
}




#pragma mark -
#pragma mark --- processCacheData
-(void)processCacheData
{
    if(_flag_cache) //本地磁盘有缓存
    {
        for(NSURLRequest *request in _array_cacheRequest)
        {
            //如果有网络就去请求网络上的数据,并更新到本地:
            if(![[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
            {
                [self loadDataFromServer:request];
            }
        }
    }
    else
    {
        NSLog(@" 没有缓存时,全部下载完毕!");
        [self saveCacheData];
    }
}



#pragma mark -
#pragma mark --- 保存缓存数据
-(void)saveCacheData
{
    @synchronized(_dic_responsesInfo)
    {
        if(_dic_responsesInfo && [_dic_responsesInfo count])
        {
            NSString *path = [NSString stringWithFormat:@"%@/%@",str_cacheDirectory,@"cache_responsesInfo.plist"];
            NSLog(@"  保存_dic_responsesInfo");
            [_dic_responsesInfo writeToFile:path atomically:YES];
            
            
            if(_array_serverRequest)
            {
                [_array_serverRequest removeAllObjects];
            }
            if(_array_cacheRequest)
            {
                [_array_cacheRequest removeAllObjects];
            }
        }
    }
}




#pragma mark -
#pragma mark --- QYURLCache - Delegate
-(void)webViewNeedReloadData
{
    if(self && self.delegate && [self.delegate respondsToSelector:@selector(reloadWebViewData)])
    {
        [self.delegate reloadWebViewData];
    }
}




#pragma mark -
#pragma mark --- 删除缓存数据
-(void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    [_dic_cachedResponses removeObjectForKey:request.URL.absoluteString];
    [_dic_responsesInfo removeObjectForKey:request.URL.absoluteString];
    
    [super removeCachedResponseForRequest:request];
}
-(void)removeAllCachedResponses
{
    [_dic_cachedResponses removeAllObjects];
    [_dic_responsesInfo removeAllObjects];
    
    [super removeAllCachedResponses];
}


@end

