//
//  JHURLCache.m
//  WebCache
//
//  Created by Jubal Hoo on 27/4/12.
//  Copyright (c) 2012 MarsLight Studio. All rights reserved.
//

#import "JHURLCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"



static NSString *cacheDirectory;
static NSSet *supportSchemes;

@implementation JHURLCache

@synthesize cachedResponses = cachedResponses_;
@synthesize responsesInfo = responsesInfo_;

-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
//    NSLog(@"removeCachedResponseForRequest:%@", request.URL.absoluteString);
    [cachedResponses_ removeObjectForKey:request.URL.absoluteString];
    [super removeCachedResponseForRequest:request];
}

- (void)removeAllCachedResponses {
//    NSLog(@"removeAllObjects");
    [cachedResponses_ removeAllObjects];
    [super removeAllCachedResponses];
}

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path
{
    if (self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path])
    {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cacheDirectory = [[paths objectAtIndex:0] retain];
       
        supportSchemes = [[NSSet setWithObjects:@"http", @"https", @"ftp", nil] retain];
        
        
        
        
        cachedResponses_ = [[NSMutableDictionary alloc] init];
        NSString *path = [cacheDirectory stringByAppendingString:@"responsesInfo.plist"];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:path]) {
            NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            self.responsesInfo = item;
            [item release];
        } else {
            NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
            self.responsesInfo = item;
            [item release];
        }
        [fileManager release];
    }
    return self;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return [super cachedResponseForRequest:request];
    }
    
    NSURL *url = request.URL;
    if (![supportSchemes containsObject:url.scheme]) {
        return [super cachedResponseForRequest:request];
    }
    //
    // supported url
    // check if url already cached
    NSString *absoluteString = url.absoluteString;
    NSLog(@"url :%@", absoluteString);
    NSCachedURLResponse *cachedResponse = [cachedResponses_ objectForKey:absoluteString];
    if (cachedResponse && isNotReachable) {
        NSLog(@"cached: %@", absoluteString);
        return cachedResponse;
    }
    
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"updatecache_webview"] isEqualToString:@"1"])
    {
        [responsesInfo_ removeObjectForKey:absoluteString];
    }
    
    
    //
    // check if it exist in disk
    NSDictionary *responseInfo = [responsesInfo_ objectForKey:absoluteString];
    if (responseInfo && isNotReachable) {
        NSString *path = [cacheDirectory stringByAppendingString:[responseInfo objectForKey:@"filename"]];
        NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
        if ([fileManager fileExistsAtPath:path]) {
            
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:[responseInfo objectForKey:@"MIMEType"] expectedContentLength:data.length textEncodingName:nil];
            cachedResponse = [[[NSCachedURLResponse alloc] initWithResponse:response data:data] autorelease];
            [response release];
            [cachedResponses_ setObject:cachedResponse forKey:absoluteString];
//            NSLog(@"cached: %@", absoluteString);
            return cachedResponse;
            
        }
    }
    
    
//    NSLog(@"                        ");
//    NSLog(@"                        ");
//    NSLog(@"                        ");
//    NSLog(@" 没有缓存  没有缓存   没有缓存  ");
//    NSLog(@"                        ");
    
    
    
    
    //
    // not cached, then we make a request and return it.
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:request.timeoutInterval];
    
    newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
    newRequest.HTTPShouldHandleCookies = request.HTTPShouldHandleCookies;
    // if error happen
    NSError *error = nil;
    NSURLResponse *response = nil;
    if([[[UIDevice currentDevice] systemVersion] floatValue] - 6. < 0)
    {
//        NSLog(@"     6.0 以下版本:");
//        NSLog(@"                        ");
        
        NSData *data = [NSURLConnection sendSynchronousRequest:newRequest returningResponse:&response error:&error];
        if (error) {
//            NSLog(@"error : %@", error);
//            NSLog(@"not cached: %@", absoluteString);
            return nil;
        }
        // no error save it
        NSString *filename = [self sha1:absoluteString];
        NSString *path = [cacheDirectory stringByAppendingString:filename];
        [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
        // reocord response
        NSURLResponse *newResponse = [[NSURLResponse alloc] initWithURL:response.URL MIMEType:response.MIMEType expectedContentLength:data.length textEncodingName:nil];
        responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:filename, @"filename", newResponse.MIMEType, @"MIMEType", nil];
        [responsesInfo_ removeObjectForKey:absoluteString];
        [responsesInfo_ setObject:responseInfo forKey:absoluteString];
//        NSLog(@"saved: %@", absoluteString);
        
        cachedResponse = [[[NSCachedURLResponse alloc] initWithResponse:newResponse data:data]autorelease];
        [newResponse release];
        [cachedResponses_ setObject:cachedResponse forKey:absoluteString];
        return cachedResponse;
        
    }
    else
    {
//        NSLog(@"     6.0 及以上版本:");
//        NSLog(@"                        ");
//        
        
        if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        {
//            NSLog(@" 无网络 则返回 ");
            return nil;
        }
        
        //保存本地已有缓存的请求:
        if(!_array_cacheRequest)
        {
            _array_cacheRequest = [[NSMutableArray alloc] init];
        }
        [_array_cacheRequest addObject:request];
        
        
        if(!queue_)
        {
            queue_ = [[NSOperationQueue alloc] init];
        }
        [NSURLConnection sendAsynchronousRequest:newRequest queue:queue_ completionHandler:^(NSURLResponse *respone,NSData *data,NSError *error){
           
            NSString *filename = [self sha1:absoluteString];
            NSString *path = [cacheDirectory stringByAppendingString:filename];
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
            NSDictionary *responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:filename, @"filename", respone.MIMEType, @"MIMEType", nil];
            [responsesInfo_ setObject:responseInfo forKey:absoluteString];
            if (data && respone) {
                NSCachedURLResponse *cachedResponse_ios6 = [[NSCachedURLResponse alloc] initWithResponse:respone data:data];
                [cachedResponses_ setObject:cachedResponse_ios6 forKey:absoluteString];
                [cachedResponse_ios6 release];
            }
            if(!_array_serverRequest)
            {
                _array_serverRequest = [[NSMutableArray alloc] init];
            }
            [_array_serverRequest addObject:request];
            
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"RecommendWebCache_Need"]) {
                if (_array_serverRequest.count>5 && _array_serverRequest.count == _array_cacheRequest.count) {
                    [self saveInfo];
                }
                
            }
            
            
            //return cachedResponse_ios6;
        }];
        return nil;
        
    }
    
}// cachedResponseForRequest:



+ (void)initialize {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    cacheDirectory = [[paths objectAtIndex:0] retain];
//    NSLog(@" cacheDirectory cacheDirectory : %@",cacheDirectory);
//    
//    supportSchemes = [[NSSet setWithObjects:@"http", @"https", @"ftp", nil] retain];
}

- (void)saveInfo {
    return;
    if ([responsesInfo_ count])
    {
        NSString *path = [cacheDirectory stringByAppendingString:@"responsesInfo.plist"];
        [responsesInfo_ writeToFile:path atomically:YES];
       
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RecommendWebCache_Need"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Cache saved");
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

-(void)dealloc{
    self.responsesInfo=nil;
    self.cachedResponses=nil;
    [_array_serverRequest release];
    [_array_cacheRequest release];
    [super dealloc];
}

@end
