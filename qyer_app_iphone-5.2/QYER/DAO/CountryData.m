//
//  CountryData.m
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import "CountryData.h"
#import "QYAPIClient.h"



@implementation CountryData

+(void)getCountryDataByCountryId:(NSString *)countryId
                         success:(CountryDataSuccessBlock)finishedBlock
                          failed:(CountryDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getCountryDataByCountryId:countryId
                                                     success:^(NSDictionary *dic){
                                                         if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
                                                         {
                                                             NSLog(@" getCountryDataByCountryId 成功");
                                                             
                                                             NSDictionary *dictData = [dic objectForKey:@"data"];
                                                             if ([dictData isKindOfClass:[NSArray class]]) {
                                                                 dictData = nil;
                                                             }
                                                             NSLog(@"dict is %@",dictData);
                                                             Country *mode = [[self prepareData:dictData] retain];
                                                             finishedBlock(mode);
                                                             [mode release];
                                                             
//                                                             NSArray *array = [dic objectForKey:@"data"];
//                                                             NSArray *array_out = [[self prepareData:array] retain];
//                                                             finishedBlock(array_out);
//                                                             [array_out release];
                                                         }
                                                         else
                                                         {
                                                             failedBlock();
                                                         }
                                                     }
                                                      failed:^{
                                                          NSLog(@" getCountryDataByCountryId 失败!");
                                                          failedBlock();
                                                      }];
}
+(Country *)prepareData:(NSDictionary *)dic{
    
    Country *country_obj = [[Country alloc] init];
    
    if (dic) {
        
        country_obj.str_countryId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        country_obj.chineseName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename"]];
        country_obj.englishName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename_en"]];
        country_obj.str_albumCover = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
        country_obj.str_imagesCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photocount"]];
        country_obj.str_lastMinuteFlag = [NSString stringWithFormat:@"%@",[dic objectForKey:@"islastminute"]];
        country_obj.str_PracticalGuide_url = [NSString stringWithFormat:@"%@",[dic objectForKey:@"overview_url"]];
        country_obj.str_isguideFlag = [NSString stringWithFormat:@"%@",[dic objectForKey:@"isguide"]];
        
        NSMutableArray *muArr = [[NSMutableArray alloc]init];
        NSArray *arr = [dic objectForKey:@"photo"];
        [muArr addObjectsFromArray:arr];
        country_obj.photoArray = muArr;
        [muArr release];
    }
   
    
    return [country_obj autorelease];
}
/*
+(NSArray *)prepareData:(NSArray *)array
{
    NSMutableArray *array_countryData = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            Country *country_obj = [[Country alloc] init];
            country_obj.str_countryId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            country_obj.chineseName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename"]];
            country_obj.englishName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename_en"]];
            country_obj.str_albumCover = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
            country_obj.str_imagesCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photocount"]];
            country_obj.str_lastMinuteFlag = [NSString stringWithFormat:@"%@",[dic objectForKey:@"islastminute"]];
            country_obj.str_PracticalGuide_url = [NSString stringWithFormat:@"%@",[dic objectForKey:@"overview_url"]];
            country_obj.str_isguideFlag = [NSString stringWithFormat:@"%@",[dic objectForKey:@"isguide"]];
            
            [array_countryData addObject:country_obj];
            [country_obj release];
        }
    }
    return [array_countryData autorelease];
}
*/

@end
