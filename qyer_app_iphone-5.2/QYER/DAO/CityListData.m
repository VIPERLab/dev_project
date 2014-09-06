//
//  CityListData.m
//  QYER
//
//  Created by 我去 on 14-3-19.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CityListData.h"
#import "QYAPIClient.h"
#import "CityList.h"
#import "FilePath.h"
#import "CacheData.h"

#define CACHEPATH_CITYLIST @"cityList"

@implementation CityListData

+(void)getCityListDataByCountryId:(NSString *)countryId
                         pageSize:(NSString *)pageSize
                             page:(NSString *)page
                          success:(CityListDataSuccessBlock)finishedBlock
                           failed:(CityListDataFailedBlock)failedBlock
{
    //************ Mod By ZhangDong 2014.4.1 Start ***********

    //缓存路径:
    NSString *plistPath = [[FilePath fileFullPathWithPath:CACHEPATH_CITYLIST] retain];
    
    [[QYAPIClient sharedAPIClient] getCityListDataByCountryId:countryId pageSize:pageSize page:page
                                                      success:^(NSDictionary *dic){
                                                          
                                                          if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
                                                          {
                                                              NSLog(@" getCityPoiDataByCityId 成功 ");
                                                              NSArray *array = [dic objectForKey:@"data"];
                                                              NSArray *array_out = [[self prepareData:array] retain];
                                                              
                                                              //缓存数据
                                                              [CacheData cacheData:array_out toFilePath:plistPath];
                                                              [plistPath release];
                                                              
                                                              finishedBlock(array_out);
                                                              [array_out release];

                                                          }
                                                          else
                                                          {
                                                              failedBlock();
                                                              [plistPath release];
                                                          }
                                                      }
                                                       failed:^{
                                                           NSLog(@" getCityDataByCityId 失败! ");
                                                           failedBlock();
                                                           [plistPath release];
                                                       }];
    //************ Mod By ZhangDong 2014.4.1 End ***********

}
+(NSArray *)prepareData:(NSArray *)array
{
    NSMutableArray *array_cityListData = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            CityList *cityList_obj = [[CityList alloc] init];
            cityList_obj.str_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            cityList_obj.str_catename = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename"]];
            cityList_obj.str_catename_en = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename_en"]];
            cityList_obj.str_photo = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
            cityList_obj.str_lat = [NSString stringWithFormat:@"%@",[dic objectForKey:@"lat"]];
            cityList_obj.str_lng = [NSString stringWithFormat:@"%@",[dic objectForKey:@"lng"]];
            cityList_obj.str_wantstr = [NSString stringWithFormat:@"%@",[dic objectForKey:@"wantstr"]];
            cityList_obj.str_ishot = [NSString stringWithFormat:@"%@",[dic objectForKey:@"ishot"]];
            
            
            //************ Insert By ZhangDong 2014.4.1 Start ***********
            
            if ([dic objectForKey:@"beennumber"] != [NSNull null]) {
                cityList_obj.beennumber = [[dic objectForKey:@"beennumber"] integerValue];
            }
            if ([dic objectForKey:@"recommendnumber"] != [NSNull null]) {
                cityList_obj.recommendnumber = [[dic objectForKey:@"recommendnumber"] integerValue];
            }
            if ([dic objectForKey:@"recommendscores"] != [NSNull null]) {
                cityList_obj.recommendscores = [[dic objectForKey:@"recommendscores"] integerValue];
            }
            
            cityList_obj.beenstr = [dic objectForKey:@"beenstr"];
            cityList_obj.recommendstr = [dic objectForKey:@"recommendstr"];
            cityList_obj.representative = [dic objectForKey:@"representative"];
            
            //************ Insert By ZhangDong 2014.4.1 End ***********
            [array_cityListData addObject:cityList_obj];
            [cityList_obj release];
        }
    }
    return [array_cityListData autorelease];
}

@end

