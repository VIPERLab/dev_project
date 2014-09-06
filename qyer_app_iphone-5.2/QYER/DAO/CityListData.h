//
//  CityListData.h
//  QYER
//
//  Created by 我去 on 14-3-19.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>



#if NS_BLOCKS_AVAILABLE
typedef void (^CityListDataSuccessBlock)(NSArray *array_cityList);
typedef void (^CityListDataFailedBlock)(void);
#endif



@interface CityListData : NSObject

+(void)getCityListDataByCountryId:(NSString *)countryId
                             pageSize:(NSString *)pageSize
                             page:(NSString *)page
                          success:(CityListDataSuccessBlock)finishedBlock
                           failed:(CityListDataFailedBlock)failedBlock;

@end
