//
//  URLCache.m
//  URLCacheTest
//
//  Created by Jin Luo on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "URLCache.h"
#include <CommonCrypto/CommonDigest.h>


static inline char hexChar(unsigned char c) {
    return c < 10 ? '0' + c : 'a' + c - 10;
}

static inline void hexString(unsigned char *from, char *to, NSUInteger length) {
    for (NSUInteger i = 0; i < length; ++i) {
        unsigned char c = from[i];
        unsigned char cHigh = c >> 4;
        unsigned char cLow = c & 0xf;
        to[2 * i] = hexChar(cHigh);
        to[2 * i + 1] = hexChar(cLow);
    }
    to[2 * length] = '\0';
}

static NSString * sha1(const char *string) {
    static const NSUInteger LENGTH = 20;
    unsigned char result[LENGTH];
    CC_SHA1(string, (CC_LONG)strlen(string), result);
    
    char hexResult[2 * LENGTH + 1];
    hexString(result, hexResult, LENGTH);
    
    return [NSString stringWithUTF8String:hexResult];
}

@implementation URLCache
@synthesize cachedResponses, responsesInfo;
@synthesize cachePaths;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        cachePaths=[NSMutableSet set];
    }
    
    return self;
}

static NSString *cacheDirectory;

+ (void)initialize {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    cacheDirectory = [[paths objectAtIndex:0] retain];
}

- (void)saveInfo {
    if ([responsesInfo count]) {
        //NSString *path = [cacheDirectory stringByAppendingString:@"responsesInfo.plist"];
        NSString *path = [cacheDirectory stringByAppendingPathComponent:@"responsesInfo.plist"];
        [responsesInfo writeToFile:path atomically: YES];
    }	
}



- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path {
    if (self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path]) {
        cachedResponses = [[NSMutableDictionary alloc] init];
        //NSString *path = [cacheDirectory stringByAppendingString:@"responsesInfo.plist"];
        NSString *path = [cacheDirectory stringByAppendingPathComponent:@"responsesInfo.plist"];
        NSLog(@"responsesInfo path:%@",path);
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:path]) {
            responsesInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        } else {
            responsesInfo = [[NSMutableDictionary alloc] init];
        }
        [fileManager release];
    }
    return self;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    
    //我们得先判断是不是GET方法，因为其他方法不应该被缓存。还得判断是不是网络请求，例如http、https和ftp，因为连data协议等本地请求都会跑到这个方法里来…
    
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return [super cachedResponseForRequest:request];
    }
    
    NSURL *url = request.URL;

    
    NSSet *supportSchemes = [NSSet setWithObjects:@"http",@"https",@"ftp", nil];
    if (![supportSchemes containsObject:url.scheme]) {
        return [super cachedResponseForRequest:request];
    }
   
    
//    //过滤掉cachePaths中不包含的文件，只缓存包含的文件
//    BOOL isContain=false;
//
//    NSArray *array=[cachePaths allObjects];
//    for (NSString *path in array) {
//
//        if([url.path rangeOfString:path].location!=NSNotFound){  //只要cachePaths中的某条路径包含在当前请求的url中，就认为是需要缓存的
//            isContain=true;
//        }
//    }
//    if (!isContain) {
//        
//        return [super cachedResponseForRequest:request];
//    }
    
    //接着判断是不是已经在cachedResponses里了，这样的话直接拿出来即可：
    NSString *absoluteString = url.absoluteString;
    NSCachedURLResponse *cachedResponse = [cachedResponses objectForKey:absoluteString];
    if (cachedResponse) {
       // NSLog(@"cached: %@", absoluteString);
        return cachedResponse;
    }
    //再查查responsesInfo里有没有，如果有的话，说明可以从磁盘获取：
    
    //NSLog(@"responseInfo:%@",responsesInfo);
    NSDictionary *responseInfo = [responsesInfo objectForKey:absoluteString];
    if (responseInfo) {
        NSString *path = [cacheDirectory stringByAppendingPathComponent:[responseInfo objectForKey:@"filename"]];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager release];
            
            NSData *data = [NSData dataWithContentsOfFile:path];
            
 
            NSString *encName=@"UTF8";
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:[responseInfo objectForKey:@"MIMEType"] expectedContentLength:data.length textEncodingName:encName];
            cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            [response release];
            
            [cachedResponses setObject:cachedResponse forKey:absoluteString];
            [cachedResponse release];
           // NSLog(@"cached: %@", absoluteString);
            return cachedResponse;
        }
        [fileManager release];
    }
    //这里的难点在于构造NSURLResponse和NSCachedURLResponse，不过对照下文档看看也就清楚了。如前文所说，我们还得把cachedResponse保存到cachedResponses里，避免它被提前释放。
    //接下来就说明缓存不存在了，需要我们自己发起一个请求。可恨的是NSURLResponse不能更改属性，所以还需要手动新建一个NSMutableURLRequest对象：
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:request.timeoutInterval];
    newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
    newRequest.HTTPShouldHandleCookies = request.HTTPShouldHandleCookies;
    //实际上NSMutableURLRequest还有一些其他的属性，不过并不太重要，所以我就只复制了这2个。
    
    //然后就可以用它来发起请求了。由于UIWebView就是在子线程调用cachedResponseForRequest:的，不用担心阻塞的问题，所以无需使用异步请求：
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:newRequest returningResponse:&response error:&error];
    if (error) {
        NSLog(@"%@", error);
       // NSLog(@"not cached: %@", absoluteString);
        return nil;
    }
    //如果下载没出错的话，我们就能拿到data和response了，于是就能将其保存到磁盘了。保存的文件名必须是合法且独一无二的，所以我就用到了sha1算法。
    NSString *filename = sha1([absoluteString UTF8String]);
    NSString *path=[cacheDirectory stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager createFileAtPath:path contents:data attributes:nil];
    [fileManager release];
    
    //接下来还得将文件信息保存到responsesInfo，并构造一个NSCachedURLResponse。
    //然而这里还有个陷阱，因为直接使用response对象会无效。我稍微研究了一下，发现它其实是个NSHTTPURLResponse对象，可能是它的allHeaderFields属性影响了缓存策略，导致不能重用。
    //不过这难不倒我们，直接像前面那样构造一个NSURLResponse对象就行了，这样就没有allHeaderFields属性了：
    
    NSString *encName=@"UTF8";
    NSURLResponse *newResponse = [[NSURLResponse alloc] initWithURL:response.URL MIMEType:response.MIMEType expectedContentLength:data.length textEncodingName:encName];
    responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:filename, @"filename", newResponse.MIMEType, @"MIMEType", nil];
    [responsesInfo setObject:responseInfo forKey:absoluteString];
    
    cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:newResponse data:data];
    [newResponse release];
    [cachedResponses setObject:cachedResponse forKey:absoluteString];
    [cachedResponse release];
    return cachedResponse;
    
}
- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    NSLog(@"removeCachedResponseForRequest:%@", request.URL.absoluteString);
    
    NSFileManager  *fm =[NSFileManager defaultManager];
    NSError *error=nil;
    BOOL success;

    NSDictionary *responseInfo = [responsesInfo objectForKey:request.URL.absoluteString];
    if (responseInfo) {
        NSString *path = [cacheDirectory stringByAppendingPathComponent:[responseInfo objectForKey:@"filename"]];
        success= [fm removeItemAtPath:path error:&error];
        if (!success) {
            NSLog(@"failed to remove file at :%@",path);
        }
    }

    [cachedResponses removeObjectForKey:request.URL.absoluteString];
    [super removeCachedResponseForRequest:request];
}

- (void)removeAllCachedResponses {
   NSLog(@"removeAllObjects");
    NSFileManager  *fm =[NSFileManager defaultManager];
    NSError *error=nil;
    BOOL success;
    NSArray  *keys=[responsesInfo allKeys];
    for (NSString *key in keys) {
        NSDictionary *responseInfo = [responsesInfo objectForKey:key];
        if (responseInfo) {
            NSString *path = [cacheDirectory stringByAppendingPathComponent:[responseInfo objectForKey:@"filename"]];
            success= [fm removeItemAtPath:path error:&error];
            if (!success) {
                NSLog(@"failed to remove file at :%@",path);
            }
        }
        
    }

    [cachedResponses removeAllObjects];
    [super removeAllCachedResponses];
}

- (void)dealloc {
    [cachedResponses release];
    [responsesInfo release];
    [super dealloc];
}
@end
