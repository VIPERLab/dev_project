//
//  GoneAndWantGoCitiesData.m
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GoneAndWantGoCitiesData.h"
#import "QYAPIClient.h"
#import "GoneAndWantGoCities.h"



@implementation GoneAndWantGoCitiesData


+(void)cancleGetGoneAndWantGoCitiesDataWithUserid:(NSString *)userid
                                        andCityId:(NSString *)str_cityId
                                          andType:(NSString *)type
{
    [[QYAPIClient sharedAPIClient] cancleGetGoneAndWantGoCitiesDataWithUserid:userid
                                                                    andCityId:str_cityId
                                                                      andType:type];
}

+(void)getGoneAndWantGoCitiesDataWithUserid:(NSString *)userid
                                  andCityId:(NSString *)str_cityId
                                    andType:(NSString *)type
                                    success:(GoneAndWantGoCitiesDataSuccessBlock)successBlock
                                     failed:(GoneAndWantGoCitiesDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getGoneAndWantGoCitiesDataWithUserid:userid andCityId:str_cityId andType:type success:^(NSDictionary *dic){
        
        if([[dic objectForKey:@"status"] intValue] == 1)
        {
            NSArray *array = [dic objectForKey:@"data"];
            NSMutableArray *array_out = [[NSMutableArray alloc] init];
            GoneAndWantGoCities *goneAndWantGoCities_ = [self processWithData:array];
            successBlock(goneAndWantGoCities_);
            [array_out release];
        }
        else
        {
            failedBlock();
        }
    } failed:^{
        failedBlock();
    }];
}
+(GoneAndWantGoCities *)processWithData:(NSArray *)array
{
    for(NSDictionary *dic in array)
    {
        GoneAndWantGoCities *goneAndWantGoCities_ = [[GoneAndWantGoCities alloc] init];
        
        
        //获取城市信息:
        goneAndWantGoCities_.city_cn = [dic objectForKey:@"city_cn"];
        goneAndWantGoCities_.city_en = [dic objectForKey:@"city_en"];
        goneAndWantGoCities_.city_idstring = [NSString stringWithFormat:@"%@",[dic objectForKey:@"city_id"]];
        
        
        //获取poi信息:
        NSArray *array = [dic objectForKey:@"pois"];
        for(NSDictionary *dic_ in array)
        {
            if(dic_)
            {
                NSMutableDictionary *dic_poiinfo = [[NSMutableDictionary alloc] init];
                NSString *str_poiid = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"poi_id"]];
                NSString *poi_cn = [dic_ objectForKey:@"poi_cn"];
                NSString *poi_en = [dic_ objectForKey:@"poi_en"];
                NSString *photo = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"photo"]];
                NSString *my_review_ranking = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"my_review_ranking"]];
                if([dic_ objectForKey:@"ranking"])
                {
                    my_review_ranking = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"ranking"]];
                }
                NSString *my_reivew = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"my_reivew"]];
                NSString *comment_id = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"comment_id"]];
                
                [dic_poiinfo setObject:str_poiid forKey:@"str_poiid"];
                [dic_poiinfo setObject:poi_cn forKey:@"poi_cn"];
                [dic_poiinfo setObject:poi_en forKey:@"poi_en"];
                [dic_poiinfo setObject:photo forKey:@"photo"];
                [dic_poiinfo setObject:my_review_ranking forKey:@"my_review_ranking"];
                [dic_poiinfo setObject:my_reivew forKey:@"my_reivew"];
                [dic_poiinfo setObject:comment_id forKey:@"comment_id"];
                [goneAndWantGoCities_.array_poiInfo addObject:dic_poiinfo];
                [dic_poiinfo release];
            }
        }
        
        return [goneAndWantGoCities_ autorelease];
    }
    
    return nil;
}

@end
