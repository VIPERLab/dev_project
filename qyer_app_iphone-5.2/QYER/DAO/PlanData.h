//
//  PlanData.h
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import <Foundation/Foundation.h>



#if NS_BLOCKS_AVAILABLE
typedef void (^PlanDataSuccessBlock)(NSArray *array_planData);
typedef void (^PlanDataFailedBlock)(void);
#endif



@interface PlanData : NSObject


+(void)getPlanDataOfCountryByCountryId:(NSString *)countryId
                              pageSize:(NSString *)str_pageSize
                                  page:(NSString *)str_page
                               success:(PlanDataSuccessBlock)finishedBlock
                                failed:(PlanDataFailedBlock)failedBlock;


+(void)getPlanDataOfCityByCityId:(NSString *)cityId
                        pageSize:(NSString *)str_pageSize
                            page:(NSString *)str_page
                         success:(PlanDataSuccessBlock)finishedBlock
                          failed:(PlanDataFailedBlock)failedBlock;

@end
