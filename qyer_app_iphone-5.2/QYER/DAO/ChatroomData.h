//
//  ChatroomData.h
//  QYER
//
//  Created by 我去 on 14-5-12.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^ChatroomDataSuccessBlock)(NSDictionary *dic);
typedef void (^ChatroomDataFailedBlock)(void);
#endif



@interface ChatroomData : NSObject

+(void)getChatRoomWithLocation:(CLLocation *)location
                andCountryName:(NSString *)countryName
                   andCityName:(NSString*)cityName
                   andAreaName:(NSString *)areaName
                 andStreetName:(NSString*)streetName
                       success:(ChatroomDataSuccessBlock)successBlock
                        failed:(ChatroomDataFailedBlock)failedBlock;

+(void)getChatRoomWithLocation:(CLLocation *)location
                               success:(ChatroomDataSuccessBlock)successBlock
                                failed:(ChatroomDataFailedBlock)failedBlock;
@end
