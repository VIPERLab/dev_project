//
//  JHURLCache.h
//  WebCache
//
//  Created by Jubal Hoo on 27/4/12.
//  Copyright (c) 2012 MarsLight Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHURLCache : NSURLCache
{
    
    NSOperationQueue *queue_;
    
    __block NSMutableDictionary *cachedResponses_;
    __block NSMutableDictionary *responsesInfo_;
    
    NSMutableArray                  *_array_cacheRequest;           //有缓存时发送的请求
    NSMutableArray                  *_array_serverRequest;          //有缓存时完成的请求
}

@property (nonatomic, retain) NSMutableDictionary *cachedResponses;
@property (nonatomic, retain) NSMutableDictionary *responsesInfo;

- (void)saveInfo;

@end
