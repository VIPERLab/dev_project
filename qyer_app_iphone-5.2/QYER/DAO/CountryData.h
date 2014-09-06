//
//  CountryData.h
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import <Foundation/Foundation.h>
#import "Country.h"

#if NS_BLOCKS_AVAILABLE
typedef void (^CountryDataSuccessBlock)(Country *guideData);
typedef void (^CountryDataFailedBlock)(void);
#endif


@interface CountryData : NSObject

+(void)getCountryDataByCountryId:(NSString *)countryId
                         success:(CountryDataSuccessBlock)finishedBlock
                          failed:(CountryDataFailedBlock)failedBlock;

@end

