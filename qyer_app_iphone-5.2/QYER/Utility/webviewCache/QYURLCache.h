//
//  QYURLCache.h
//  QYGuide
//
//  Created by 你猜你猜 on 13-12-2.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol QYURLCacheDelegate;

@interface QYURLCache : NSURLCache
{
    NSOperationQueue                *_queue;
    __block NSMutableDictionary     *_dic_cachedResponses;
    __block NSMutableDictionary     *_dic_responsesInfo;
    __block NSMutableArray          *_array_responsesUrl_begin;     //记录开始进行缓存的url
    __block NSMutableArray          *_array_responsesUrl;           //记录成功被缓存的url
    NSString                        *_str_requestUrl;
    NSMutableArray                  *_array_cacheRequest;           //有缓存时发送的请求
    NSMutableArray                  *_array_serverRequest;          //有缓存时完成的请求
    
    BOOL                            _flag_cache;                    //是否有本地缓存数据
    BOOL                            _flag_deleteCaches;
    
    
    id<QYURLCacheDelegate>          _delegate;
}
@property(nonatomic,assign) id<QYURLCacheDelegate>  delegate;
@property(nonatomic,assign) BOOL flag_cache;
@property(nonatomic,assign) BOOL freshFlag;
@property(nonatomic,assign) BOOL donotgetdatafromserver;
+(QYURLCache *)sharedQYURLCache;
-(void)deleteAllLocalCachesWithFileName:(NSString *)file_name andUrl:(NSString *)url;
-(void)processCacheData;
-(void)removeCachedResponseForRequest:(NSURLRequest *)request;
-(void)removeAllCachedResponses;
@end







#pragma mark -
#pragma mark --- QYURLCache - Delegate
@protocol QYURLCacheDelegate <NSObject>
-(void)reloadWebViewData;
@end


