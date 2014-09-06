//
//  CountryListData.m
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CountryListData.h"
#import "QYAPIClient.h"
#import "CountryList.h"

@implementation CountryListData

+(void)getCountryListByContinentId:(NSString *)continentid
                           success:(CountryListDataSuccessBlock)finishedBlock
                            failed:(CountryListDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getCountryListByContinentId:continentid
                                                  success:^(NSDictionary *dic){
                                                      
                                                      if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
                                                      {
                                                          NSLog(@" getCityPoiDataByCityId 成功 ");
                                                          NSArray *array = [dic objectForKey:@"data"];
                                                          NSArray *array_out = [[self prepareData:array] retain];
                                                          finishedBlock(array_out);
                                                          [array_out release];
                                                      }
                                                      else
                                                      {
                                                          failedBlock();
                                                      }
                                                  }
                                                   failed:^{
                                                       NSLog(@" getCityPoiDataByCityId 失败! ");
                                                       failedBlock();
                                                   }];
}
+(NSArray *)prepareData:(NSArray *)array
{
    NSMutableArray *array_countryList = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            CountryList *countryList_obj = [[CountryList alloc] init];
            countryList_obj.str_catename = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename"]];
            countryList_obj.str_catename_en = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename_en"]];
            countryList_obj.str_photo = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
            countryList_obj.str_ishot = [NSString stringWithFormat:@"%@",[dic objectForKey:@"ishot"]];
            
            [array_countryList addObject:countryList_obj];
            [countryList_obj release];
        }
    }
    return [array_countryList autorelease];
}


@end
