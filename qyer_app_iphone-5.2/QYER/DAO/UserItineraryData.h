//
//  UserItineraryData.h
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-10.
//
//

#import <Foundation/Foundation.h>




#if NS_BLOCKS_AVAILABLE
typedef void (^UserItineraryDataSuccessBlock)(NSArray *array);
typedef void (^UserItineraryDataFailedBlock)(void);
#endif



@interface UserItineraryData : NSObject


//获取用户的行程列表:
+(void)getUserItineraryWithUserId:(NSString *)user_id
                      andPageSize:(NSString *)pageSize
                          success:(UserItineraryDataSuccessBlock)finished
                           failed:(UserItineraryDataFailedBlock)failed;


@end
