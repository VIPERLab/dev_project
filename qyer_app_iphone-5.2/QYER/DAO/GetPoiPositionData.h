//
//  GetPoiPositionData.h
//  QYER
//
//  Created by 我去 on 14-4-8.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^GetPoiPositionDataSuccessBlock)(NSArray *array_PoiPositionData);
typedef void (^GetPoiPositionDataFailedBlock)(void);
#endif


@interface GetPoiPositionData : NSObject

+(void)getAllPoiPositionByCityId:(NSString *)cityId
                         success:(GetPoiPositionDataSuccessBlock)finishedBlock
                          failed:(GetPoiPositionDataFailedBlock)failedBlock;

+(void)getMapByCountryName:(NSString *)countryName
                   success:(GetPoiPositionDataSuccessBlock)finishedBlock
                    failed:(GetPoiPositionDataFailedBlock)failedBlock;

@end
