//
//  CityData.m
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import "CityData.h"
#import "QYAPIClient.h"





@implementation CityData

+(void)getCityDataByCityId:(NSString *)cityId
                   success:(CityDataSuccessBlock)finishedBlock
                    failed:(CityDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getCityDataByCityId:cityId
                                               success:^(NSDictionary *dic){
                                                   
                                                   if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
                                                   {
                                                       NSLog(@" getCityPoiDataByCityId 成功 %@ ",dic);
                                                       
                                                       
                                                       NSDictionary *dictData = [dic objectForKey:@"data"]
                                                       ;
                                                       if (![dictData isKindOfClass:[NSDictionary class]]) {
                                                           
                                                           dictData = nil;

                                                       }
                                                       
                                                       
                                                       City *model = [[self prepareData:dictData] retain];
                                                       finishedBlock(model);
                                                       [model release];
//                                                       NSArray *array = [dic objectForKey:@"data"];
//                                                       NSArray *array_out = [[self prepareData:array] retain];
//                                                       finishedBlock(array_out);
//                                                       [array_out release];
                                                   }
                                                   else
                                                   {
                                                       failedBlock();
                                                   }
                                               }
                                                failed:^{
                                                    NSLog(@" getCityDataByCityId 失败! ");
                                                    failedBlock();
                                                }];
}

+(City *)prepareData:(NSDictionary *)dic{
    
    City *city_obj = [[City alloc] init];
    
    if (dic) {
        
        city_obj.str_cityId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        city_obj.str_countryId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"countryid"]];
        city_obj.chineseName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename"]];
        city_obj.englishName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename_en"]];
        city_obj.str_albumCover = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
        city_obj.str_imagesCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photocount"]];
        city_obj.str_PracticalGuideUrl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"overview_url"]];
        city_obj.str_hotelUrl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"selecthotel_url"]];
        city_obj.str_guideFlag = [NSString stringWithFormat:@"%@",[dic objectForKey:@"isguide"]];
        
        NSMutableArray *muArr = [[NSMutableArray alloc]init];
        NSArray *arr = [dic objectForKey:@"photo"];
        [muArr addObjectsFromArray:arr];
        
        city_obj.photoArray = muArr;
        [muArr release];
    }
  
    
    return [city_obj autorelease];
}
/*

+(NSArray *)prepareData:(NSArray *)array
{
    NSMutableArray *array_cityData = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            City *city_obj = [[City alloc] init];
            city_obj.str_cityId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            city_obj.str_countryId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"countryid"]];
            city_obj.chineseName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename"]];
            city_obj.englishName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"catename_en"]];
            city_obj.str_albumCover = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
            city_obj.str_imagesCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photocount"]];
            city_obj.str_PracticalGuideUrl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"overview_url"]];
            city_obj.str_hotelUrl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"selecthotel_url"]];
            city_obj.str_guideFlag = [NSString stringWithFormat:@"%@",[dic objectForKey:@"isguide"]];
            
            
            [array_cityData addObject:city_obj];
            [city_obj release];
        }
    }
    return [array_cityData autorelease];
}
*/

@end

