//
//  GetPoiPositionData.m
//  QYER
//
//  Created by 我去 on 14-4-8.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GetPoiPositionData.h"
#import "QYAPIClient.h"

@implementation GetPoiPositionData

+(void)getAllPoiPositionByCityId:(NSString *)cityId
                         success:(GetPoiPositionDataSuccessBlock)finishedBlock
                          failed:(GetPoiPositionDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getAllPoiPositionByCityId:cityId
                                                     success:^(NSDictionary *dic){
                                                         if (dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@", [dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
                                                         {
                                                             NSLog(@"getPlanDataOfCountryByCountryOrCityId 成功 ");
                                                             
                                                             NSArray *arrayData = [dic objectForKey:@"data"];
                                                             finishedBlock(arrayData);
                                                         }
                                                         else
                                                         {
                                                             failedBlock();
                                                         }
                                                         
                                                     } failed:^{
                                                         failedBlock();
                                                     }];
}
+(void)getMapByCountryName:(NSString *)countryName
                   success:(GetPoiPositionDataSuccessBlock)finishedBlock
                    failed:(GetPoiPositionDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getMapByCountryName:countryName
                                                     success:^(NSDictionary *dic){
                                                         NSLog(@"  dic  : %@",dic);
                                                         
                                                         if (dic && [dic count] > 0 && [dic objectForKey:@"results"] && [[dic objectForKey:@"results"] count] > 0)
                                                         {
                                                             NSLog(@" getMapByCountryName 成功 ");
                                                             
                                                             NSArray *arrayData = [dic objectForKey:@"results"];
                                                             finishedBlock(arrayData);
                                                         }
                                                         else
                                                         {
                                                             failedBlock();
                                                         }
                                                         
                                                     } failed:^{
                                                         failedBlock();
                                                     }];
}


@end
