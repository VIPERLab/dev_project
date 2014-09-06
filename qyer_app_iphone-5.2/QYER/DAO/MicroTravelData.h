//
//  MicroTravelData.h
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import <Foundation/Foundation.h>



#if NS_BLOCKS_AVAILABLE
typedef void (^MicroTravelDataSuccessBlock)(NSArray *array_microTravelData);
typedef void (^MicroTravelDataFailedBlock)(void);
#endif



@interface MicroTravelData : NSObject

+(void)getMicroTravelDataOfCountryByCountryId:(NSString *)countryId
                                     pageSize:(NSString *)str_pageSize
                                         page:(NSString *)str_page
                                      success:(MicroTravelDataSuccessBlock)finishedBlock
                                       failed:(MicroTravelDataFailedBlock)failedBlock;


+(void)getMicroTravelDataOfCityByCityId:(NSString *)cityId
                               pageSize:(NSString *)str_pageSize
                                   page:(NSString *)str_page
                                success:(MicroTravelDataSuccessBlock)finishedBlock
                                 failed:(MicroTravelDataFailedBlock)failedBlock;

//获取用户的帖子(游记):
+(void)getUserTravelDataWithUserId:(NSInteger)userId
                           andType:(NSString *)type
                          andCount:(NSInteger)count
                           andPage:(NSInteger)page
                           success:(MicroTravelDataSuccessBlock)finishedBlock
                            failed:(MicroTravelDataFailedBlock)failedBlock;


//获取用户收藏的帖子(游记):
+(void)getUserCollectTravelDataWithUserId:(NSInteger)userId
                                  andType:(NSString *)type
                                 andCount:(NSInteger)count
                                  andPage:(NSInteger)page
                                  success:(MicroTravelDataSuccessBlock)finishedBlock
                                   failed:(MicroTravelDataFailedBlock)failedBlock;


@end
