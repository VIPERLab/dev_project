//
//  ChatroomData.m
//  QYER
//
//  Created by 我去 on 14-5-12.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "ChatroomData.h"
#import "QYAPIClient.h"

@implementation ChatroomData

+(void)getChatRoomWithLocation:(CLLocation *)location
                andCountryName:(NSString *)countryName
                   andCityName:(NSString*)cityName
                   andAreaName:(NSString *)areaName
                 andStreetName:(NSString*)streetName
                       success:(ChatroomDataSuccessBlock)successBlock
                        failed:(ChatroomDataFailedBlock)failedBlock
{

    [[QYAPIClient sharedAPIClient] getChatRoomWithLocation:location
                                            andCountryName:countryName
                                                andCityName:cityName
                                               andAreaName:areaName
                                                andStreetName:streetName
                                                   success:^(NSDictionary *dic){
                                                       NSLog(@" getChatRoomWithLocation success ");
                                                       NSLog(@" dic : %@",dic);
                                                       if([[dic objectForKey:@"status"] intValue] ==  1)
                                                       {
                                                           successBlock([dic objectForKey:@"data"]);
                                                       }
                                                       else
                                                       {
                                                           failedBlock();
                                                       }
                                                   }
                                                    failed:^{
                                                        NSLog(@" getChatRoomWithLocation failed ");
                                                        failedBlock();
                                                    }];
    
}
+(void)getChatRoomWithLocation:(CLLocation *)location success:(ChatroomDataSuccessBlock)successBlock failed:(ChatroomDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getChatRoomWithLocation:location success:^(NSDictionary *dic) {
        NSLog(@" getChatRoomWithLocation success ");
        NSLog(@" dic : %@",dic);
        if([[dic objectForKey:@"status"] intValue] ==  1)
        {
            successBlock([dic objectForKey:@"data"]);
        }
        else
        {
            failedBlock();
        }
    } failed:^{
        
        NSLog(@" getChatRoomWithLocation failed ");
        failedBlock();
        
    }];
}
@end
