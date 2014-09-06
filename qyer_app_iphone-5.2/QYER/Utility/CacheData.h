//
//  CacheData.h
//  QyGuide
//
//  Created by an qing on 13-3-8.
//
//

#import <Foundation/Foundation.h>

@interface CacheData : NSObject

+(id)sharedCacheData;


//*** 锦囊相关:
+(BOOL)isFileExist;
-(void)cacheData:(NSArray *)array;
-(NSArray *)getCacheData;


//*** 其他:
+(NSArray *)getCacheDataFromFilePath:(NSString *)filePath;
+(void)cacheData:(NSArray *)array toFilePath:(NSString *)filePath;


//*** 获取已下载的锦囊:
+(NSArray *)getDownloadedGuideCache;
+(void)cacheDownloadedGuideData:(NSArray *)array;



//*** 书签:
+(NSDictionary *)getCachedBookmarkFromFilePath:(NSString *)filePath;


//*** 缓存锦囊详情页的信息:
+(void)cacheGuideDetailInfoData:(NSDictionary *)dic;

//*** 获取已缓存的锦囊详情页的信息:
+(NSDictionary *)getCachedGuideDetailInfoData;

@end

