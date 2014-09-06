//
//  CityData.h
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import <Foundation/Foundation.h>

#import "City.h"

#if NS_BLOCKS_AVAILABLE
typedef void (^CityDataSuccessBlock)(City *guideData);
typedef void (^CityDataFailedBlock)(void);
#endif



@interface CityData : NSObject

+(void)getCityDataByCityId:(NSString *)cityId
                   success:(CityDataSuccessBlock)finishedBlock
                    failed:(CityDataFailedBlock)failedBlock;

@end
