//
//  CityPoiData.h
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import <Foundation/Foundation.h>



#if NS_BLOCKS_AVAILABLE
typedef void (^CityPoiDataSuccessBlock)(NSArray *array_guideData);
typedef void (^CityPoiDataFailedBlock)(void);
#endif



@interface CityPoiData : NSObject

+(void)getCityPoiDataByCityId:(NSString *)countryId
                andCategoryId:(NSString *)str_categoryId
                     pageSize:(NSString *)str_pageSize
                         page:(NSString *)str_page
                      success:(CityPoiDataSuccessBlock)finishedBlock
                       failed:(CityPoiDataFailedBlock)failedBlock;


+(void)getPoiNearByWithLat:(float)lat
                    andLon:(float)lon
             andCategoryId:(NSInteger)categoryId
               andPageSize:(NSString *)str_pageSize
                   andPage:(NSString *)str_page
                  andPoiId:(NSInteger)poi_id
                   success:(CityPoiDataSuccessBlock)finishedBlock
                    failed:(CityPoiDataFailedBlock)failedBlock;

@end
