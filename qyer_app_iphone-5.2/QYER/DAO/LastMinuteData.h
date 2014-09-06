//
//  LastMinuteData.h
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-15.
//
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^LastMinuteDataSuccessBlock)(NSArray *array);
typedef void (^LastMinuteDataFailedBlock)(void);
#endif


@interface LastMinuteData : NSObject


//由锦囊id获取折扣信息:
+(void)getLastMinuteInfoWithGuideId:(NSString *)guide_id
                            success:(LastMinuteDataSuccessBlock)finished
                             failed:(LastMinuteDataFailedBlock)failed;


//获取折扣列表
+ (void)getLastMinuteListWithType:(NSUInteger)type
                            maxId:(NSUInteger)maxId
                         pageSize:(NSUInteger)pageSize
                            times:(NSString *)times
                      continentId:(NSUInteger)continentId
                        countryId:(NSUInteger)countryId
                        departure:(NSString *)departure
                          success:(LastMinuteDataSuccessBlock)successBlock
                          failure:(LastMinuteDataFailedBlock)failureBlock;
@end
