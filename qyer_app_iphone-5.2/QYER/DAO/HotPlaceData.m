//
//  HotPlaceData.m
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "HotPlaceData.h"
#import "QYAPIClient.h"
#import "HotPlace.h"


@implementation HotPlaceData

+(void)getHotPlaceListSuccess:(HotPlaceDataSuccessBlock)finishedBlock
                       failed:(HotPlaceDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getHotPlaceListSuccess:^(NSDictionary *dic){
        
        if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
        {
            NSLog(@" getHotPlaceList 成功 ");
            
            NSDictionary *dic_data = [dic objectForKey:@"data"];
            NSArray *array_country = [dic_data objectForKey:@"country"];
            NSArray *array_country_out = [[self prepareData:array_country] retain];
            NSArray *array_city = [dic_data objectForKey:@"city"];
            NSArray *array_city_out = [[self prepareData:array_city] retain];
            
            finishedBlock(array_country_out,array_city_out);
            [array_country_out release];
            [array_city_out release];
        }
        else
        {
            failedBlock();
        }
        
    } failed:^{
        NSLog(@" getHotPlaceList 失败! ");
        failedBlock();
    }];
}
+(NSArray *)prepareData:(NSArray *)array
{
    NSMutableArray *array_hotPlaceData = [[NSMutableArray alloc] init];
    if(!array)
    {
        return [array_hotPlaceData autorelease];
    }
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            HotPlace *hotPlace_obj = [[HotPlace alloc] init];
            hotPlace_obj.str_placeId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"pid"]];
            hotPlace_obj.str_placePhoto = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
            hotPlace_obj.str_placeCatename = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename"]];
            
            [array_hotPlaceData addObject:hotPlace_obj];
            [hotPlace_obj release];
        }
    }
    
    return [array_hotPlaceData autorelease];
}


@end
