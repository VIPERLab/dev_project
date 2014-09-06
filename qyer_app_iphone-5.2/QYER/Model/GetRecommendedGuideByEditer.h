//
//  GetRecommendedGuideByEditer.h
//  QyGuide
//
//  Created by 回头蓦见 on 13-6-6.
//
//

#import <Foundation/Foundation.h>



#if NS_BLOCKS_AVAILABLE
typedef void (^getRecommendedGuideByEditerFinishedBlock)(NSArray *array);
typedef void (^getRecommendedGuideByEditerFailedBlock)(void);
#endif




@interface GetRecommendedGuideByEditer : NSObject

+(void)getRecommendedGuidebyPoiByClientid:(NSString *)client_id
                         andClientSecrect:(NSString *)client_secrect
                            andDeviceType:(NSString *)type
                                 finished:(getRecommendedGuideByEditerFinishedBlock)finished
                                   failed:(getRecommendedGuideByEditerFailedBlock)failed;

@end
