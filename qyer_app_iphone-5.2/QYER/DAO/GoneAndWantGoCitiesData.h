//
//  GoneAndWantGoCitiesData.h
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GoneAndWantGoCities;



#if NS_BLOCKS_AVAILABLE
typedef void (^GoneAndWantGoCitiesDataSuccessBlock)(GoneAndWantGoCities *obj);
typedef void (^GoneAndWantGoCitiesDataFailedBlock)(void);
#endif




@interface GoneAndWantGoCitiesData : NSObject

+(void)cancleGetGoneAndWantGoCitiesDataWithUserid:(NSString *)userid
                                        andCityId:(NSString *)str_cityId
                                          andType:(NSString *)type;
+(void)getGoneAndWantGoCitiesDataWithUserid:(NSString *)userid
                                  andCityId:(NSString *)str_cityId
                                    andType:(NSString *)type
                                    success:(GoneAndWantGoCitiesDataSuccessBlock)successBlock
                                     failed:(GoneAndWantGoCitiesDataFailedBlock)failedBlock;
@end
