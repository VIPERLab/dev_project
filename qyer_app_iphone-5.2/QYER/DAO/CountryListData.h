//
//  CountryListData.h
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>



#if NS_BLOCKS_AVAILABLE
typedef void (^CountryListDataSuccessBlock)(NSArray *array_countryList);
typedef void (^CountryListDataFailedBlock)(void);
#endif



@interface CountryListData : NSObject

+(void)getCountryListByContinentId:(NSString *)continentid
                           success:(CountryListDataSuccessBlock)finishedBlock
                            failed:(CountryListDataFailedBlock)failedBlock;

@end
