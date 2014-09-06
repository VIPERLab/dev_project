//
//  QYGuideData.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-6.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "QYGuide.h"
#import "QYAPIClient.h"
#import "CacheData.h"
#import "FilePath.h"
#import "ObserverObject.h"



#if NS_BLOCKS_AVAILABLE
typedef void (^QYGuideDataSuccessBlock)(NSArray *array_guideData);
typedef void (^QYGuideDataFailedBlock)(void);
typedef void (^QYGuideSuccessBlock)(QYGuide *guide);
typedef void (^QYGuideFailedBlock)(void);
typedef void (^QYGuideListSuccessBlock)(NSArray *array);
typedef void (^QYGuideListFailedBlock)(void);
typedef void (^fromV4_QYGuideListSuccessBlock)(NSArray *array,BOOL isCache);
typedef void (^fromV4_QYGuideListFailedBlock)(void);
#endif



@interface QYGuideData : NSObject <ASIProgressDelegate>
{
    NSMutableArray      *_array_allGuide;
    NSMutableArray      *_array_guideIsDownloading;
    NSMutableArray      *_array_guideNeedToBeUpdated;
//    ObserverObject      *_obj_observer;
    BOOL                _flag_getAllNew;
}
@property(nonatomic,retain) NSMutableArray  *array_allGuide;
@property(nonatomic,retain) NSMutableArray  *array_guideIsDownloading;
@property(nonatomic,retain) NSMutableArray  *array_guideNeedToBeUpdated;
@property(nonatomic,retain) NSString        *guideName_downloading;
//@property(nonatomic,retain) ObserverObject  *obj_observer;
@property(nonatomic,assign) BOOL flag_getAllNew;

+(id)sharedQYGuideData;


+(void)getAllMobileGuideListWithModifiedTime:(NSInteger)modifiedTime
                                     success:(QYGuideDataSuccessBlock)successBlock
                                      failed:(QYGuideDataFailedBlock)failedBlock;

+(void)getRecommendGuideSuccess:(QYGuideDataSuccessBlock)successBlock
                         failed:(QYGuideDataFailedBlock)failedBlock;

+(NSArray *)getAllGuide;
+(NSArray *)getAllDownloadGuide;
+(QYGuide *)getGuideById:(NSString *)idString;
+(QYGuide *)getGuideByName:(NSString *)guide_name;
+(NSString *)getGuideNameByGuideId:(NSString *)idString;
+(void)replaceGuideStateWithDownloadedGuide:(NSArray *)array;
-(void)processGuideWhenDownloadFailed:(NSDictionary *)userinfo;

//搜索锦囊:
+(void)searchGuideWithString:(NSString *)searchStr
                    finished:(QYGuideDataSuccessBlock)successBlock
                      failed:(QYGuideDataFailedBlock)failedBlock;

//保存正在下载的锦囊:
+(void)cacheDownloadingGuide:(QYGuide *)guide;

//获取正在下载的锦囊:
+(NSArray *)getDownloadingGuide;


//*** 下载锦囊相关:
+(void)startDownloadWithGuide:(QYGuide *)guide;
+(void)suspend:(QYGuide *)guide;
+(void)saveGuideIsDownloading:(QYGuide *)guide;


+(void)deleteGuideNeedToBeUpdatedWithGuideName:(NSString *)guide_name;
+(void)deleteGuideIsDownloadingWithGuideName:(NSString *)guide_name;










#pragma mark -
#pragma mark --- V4.0
+(void)fromV4_getAllGuideIncludeCache:(BOOL)flag
                              success:(fromV4_QYGuideListSuccessBlock)successBlock
                          failed:(fromV4_QYGuideListFailedBlock)failedBlock;
+(void)cancleGetGuideData;


//*** [由锦囊的id获取锦囊的详情 --- 服务器 ]
+(void)getGuideDetailInfoWithGuideId:(NSString *)guide_id
                             success:(QYGuideSuccessBlock)successBlock
                              failed:(QYGuideFailedBlock)failedBlock;
+(void)cancleGuideDetailInfoWithGuideId:(NSString *)guide_id;

//获取上次退出时还正在下载的锦囊:
+(NSArray *)getDownloadingGuideWhenQuit;

//*** [由锦囊的id获取锦囊的详情 --- 本地缓存 ]
+(void)getGuideDetailInfoFromCacheWithGuideId:(NSString *)guide_id
                                      success:(QYGuideSuccessBlock)successBlock
                                       failed:(QYGuideFailedBlock)failedBlock;

//根据国家或城市ID获取锦囊列表:
+(void)getGuideListWithType:(NSString *)type
                      andId:(NSString *)str_id
                    success:(QYGuideListSuccessBlock)successBlock
                     failed:(QYGuideListFailedBlock)failedBlock;


//根据搜索字符串获取锦囊列表:(无效,并没有使用)
+(void)getGuideListWithSearchString:(NSString *)str
                            success:(QYGuideListSuccessBlock)successBlock
                             failed:(QYGuideListFailedBlock)failedBlock;

@end

