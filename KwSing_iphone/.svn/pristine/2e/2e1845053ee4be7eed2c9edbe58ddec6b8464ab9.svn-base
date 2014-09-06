//
//  KSHttpRequest.m
//  KwSing
//
//  Created by 单 永杰 on 13-11-15.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import "KSHttpRequest.h"

@implementation KSHttpRequest

+ (NSData*)SyncRequest:(NSString*)str_url{
    NSURL* url_http = [NSURL URLWithString:str_url];
    NSURLRequest* request = [NSURLRequest requestWithURL:url_http cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5.0];
    NSHTTPURLResponse* response = nil;
    NSError* error = nil;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (nil != error) {
        return nil;
    }
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse* response_http = (NSHTTPURLResponse*)response;
        if (200 != response_http.statusCode) {
            return nil;
        }
    }
    
    return data;
}

@end
