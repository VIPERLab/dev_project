//
//  WantGoData.m
//  QYER
//
//  Created by 我去 on 14-5-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "WantGoData.h"
#import "QYAPIClient.h"
#import "WantGo.h"


@implementation WantGoData


//取消请求:
+(void)cancleGetWantGoDataWithUserid:(NSString *)userid
{
    [[QYAPIClient sharedAPIClient] cancleGetWantGoDataWithUserid:userid];
}


+(void)getWantGoDataWithUserid:(NSString *)userid
                       success:(WantGoDataSuccessBlock)successBlock
                        failed:(WantGoDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getWantGoDataWithUserid:userid success:^(NSDictionary *dic){
        
        if([[dic objectForKey:@"status"] intValue] == 1)
        {
            //保存数据以供缓存使用:
            [[NSUserDefaults standardUserDefaults] setObject:dic forKey:[NSString stringWithFormat:@"wantgo_%@",userid]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            NSLog(@" data  : %@",[dic objectForKey:@"data"]);
            NSArray *array = [dic objectForKey:@"data"];
            //NSDictionary *dic_out = [[self processData:array] retain];
            NSMutableDictionary *dic_out = [[NSMutableDictionary alloc] init];
            NSMutableArray *array_countryname_cn = [[NSMutableArray alloc] init];
            NSMutableArray *array_countryname_en = [[NSMutableArray alloc] init];
            [self processWithData:array toDic:dic_out andArray_cn:array_countryname_cn andArray_en:array_countryname_en];
            successBlock(dic_out,array_countryname_cn,array_countryname_en);
            [dic_out release];
            [array_countryname_en release];
            [array_countryname_cn release];
        }
        else
        {
            failedBlock();
        }
    }failed:^{
        failedBlock();
    }];
}
+(void)getCachedWantGoDataWithUserid:(NSString *)userid
                             success:(WantGoDataSuccessBlock)successBlock
                              failed:(WantGoDataFailedBlock)failedBlock
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"wantgo_%@",userid]];
    
    if([[dic objectForKey:@"status"] intValue] == 1)
    {
        NSLog(@" data  : %@",[dic objectForKey:@"data"]);
        NSArray *array = [dic objectForKey:@"data"];
        //NSDictionary *dic_out = [[self processData:array] retain];
        NSMutableDictionary *dic_out = [[NSMutableDictionary alloc] init];
        NSMutableArray *array_countryname_cn = [[NSMutableArray alloc] init];
        NSMutableArray *array_countryname_en = [[NSMutableArray alloc] init];
        [self processWithData:array toDic:dic_out andArray_cn:array_countryname_cn andArray_en:array_countryname_en];
        successBlock(dic_out,array_countryname_cn,array_countryname_en);
        [dic_out release];
        [array_countryname_en release];
        [array_countryname_cn release];
    }
    else
    {
        failedBlock();
    }
}
+(void)processWithData:(NSArray *)array toDic:(NSMutableDictionary *)dic_out andArray_cn:(NSMutableArray *)array_countryname_cn andArray_en:(NSMutableArray *)array_countryname_en
{
    for(NSDictionary *dic in array)
    {
        NSLog(@"  dic  : %@",dic);
        WantGo *wantGo_ = [[WantGo alloc] init];
        
        
        //获取国家信息:
        wantGo_.country_cn = [dic objectForKey:@"country_cn"];
        wantGo_.country_en = [dic objectForKey:@"country_en"];
        wantGo_.country_idstring = [NSString stringWithFormat:@"%@",[dic objectForKey:@"country_id"]];
        if([dic objectForKey:@"country_cn"])
        {
            [array_countryname_cn addObject:[dic objectForKey:@"country_cn"]];
        }
        else
        {
            [array_countryname_cn addObject:@" "];
        }
        if([dic objectForKey:@"country_en"])
        {
            [array_countryname_en addObject:[dic objectForKey:@"country_en"]];
        }
        else
        {
            [array_countryname_en addObject:@" "];
        }
        
        
        
        
        //获取城市信息:
        NSArray *array = [dic objectForKey:@"cities"];
        for(NSDictionary *dic_ in array)
        {
            if(dic_)
            {
                NSMutableDictionary *dic_cityinfo = [[NSMutableDictionary alloc] init];
                NSString *chineseName = [dic_ objectForKey:@"city_cn"];
                NSString *englishName = [dic_ objectForKey:@"city_en"];
                NSString *str_cityId = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"city_id"]];
                NSString *str_albumCover = [dic_ objectForKey:@"photo"];
                NSString *str_total_gone_poi = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"total_gone_poi"]];
                [dic_cityinfo setObject:chineseName forKey:@"city_cn"];
                [dic_cityinfo setObject:englishName forKey:@"city_en"];
                [dic_cityinfo setObject:str_cityId forKey:@"city_id"];
                [dic_cityinfo setObject:str_albumCover forKey:@"photo"];
                [dic_cityinfo setObject:str_total_gone_poi forKey:@"total_gone_poi"];
                [wantGo_.array_cityInfo addObject:dic_cityinfo];
                [dic_cityinfo release];
            }
        }
        
        if([dic objectForKey:@"country_cn"])
        {
            [dic_out setObject:wantGo_ forKey:[dic objectForKey:@"country_cn"]];
        }
        else if ([dic objectForKey:@"country_en"])
        {
            [dic_out setObject:wantGo_ forKey:[dic objectForKey:@"country_en"]];
        }
        
        [wantGo_ release];
    }
}

@end
