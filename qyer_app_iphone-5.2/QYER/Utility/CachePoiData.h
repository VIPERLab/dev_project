//
//  CachePoiData.h
//  QyGuide
//
//  Created by an qing on 13-3-8.
//
//

#import <Foundation/Foundation.h>

@interface CachePoiData : NSObject

+(id)sharedCachePoiData;
-(void)cachePoiData:(NSDictionary*)dic withPoiId:(NSInteger)poiid;
+(BOOL)isFileExistByPoiId:(NSInteger)poiId;
-(NSDictionary *)getCachePoiDataWithPoiId:(NSInteger)poiid;

@end

