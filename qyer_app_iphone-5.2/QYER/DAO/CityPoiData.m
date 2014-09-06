//
//  CityPoiData.m
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import "CityPoiData.h"
#import "QYAPIClient.h"
#import "CityPoi.h"


@implementation CityPoiData

+(void)getCityPoiDataByCityId:(NSString *)countryId
                andCategoryId:(NSString *)str_categoryId
                     pageSize:(NSString *)str_pageSize
                         page:(NSString *)str_page
                      success:(CityPoiDataSuccessBlock)finishedBlock
                       failed:(CityPoiDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getCityPoiDataByCityId:countryId
                                            andCategoryId:str_categoryId pageSize:str_pageSize page:str_page
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
    NSMutableArray *array_cityPoiData = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            CityPoi *cityPoi_obj = [[CityPoi alloc] init];
            cityPoi_obj.str_poiId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            cityPoi_obj.str_poiChineseName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"firstname"]];
            cityPoi_obj.str_poiEnglishName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"secnodname"]];
            cityPoi_obj.str_poiLocalName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"localname"]];
            cityPoi_obj.str_albumCover = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
            cityPoi_obj.str_lat = [NSString stringWithFormat:@"%@",[dic objectForKey:@"lat"]];
            cityPoi_obj.str_lng = [NSString stringWithFormat:@"%@",[dic objectForKey:@"lng"]];
            cityPoi_obj.str_wantGo = [NSString stringWithFormat:@"%@",[dic objectForKey:@"beenstr"]];
            cityPoi_obj.str_comprehensiveEvaluation = [NSString stringWithFormat:@"%@",[dic objectForKey:@"gradescores"]];
            cityPoi_obj.str_comprehensiveRating = [NSString stringWithFormat:@"%@",[dic objectForKey:@"grade"]];
            cityPoi_obj.str_recommendscores = [NSString stringWithFormat:@"%@",[dic objectForKey:@"recommendscores"]];
            cityPoi_obj.str_recommendstr = [NSString stringWithFormat:@"%@",[dic objectForKey:@"recommendstr"]];
            
            int isHot = [[NSString stringWithFormat:@"%@",[dic objectForKey:@"recommendnumber"]] intValue];
            if (isHot == 1 || isHot == 2) //如果是热门
            {
                cityPoi_obj.str_hotFlag = @"1";
            }
            else
            {
                cityPoi_obj.str_hotFlag = @"0";
            }
            
            [array_cityPoiData addObject:cityPoi_obj];
            [cityPoi_obj release];
        }
    }
    return [array_cityPoiData autorelease];
}




+(void)getPoiNearByWithLat:(float)lat
                    andLon:(float)lon
             andCategoryId:(NSInteger)categoryId
               andPageSize:(NSString *)str_pageSize
                   andPage:(NSString *)str_page
                  andPoiId:(NSInteger)poi_id
                   success:(CityPoiDataSuccessBlock)finishedBlock
                    failed:(CityPoiDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getPoiNearByWithLat:lat
                                                andLon:lon
                                         andCategoryId:categoryId
                                              andPoiId:poi_id
                                              andPageSize:str_pageSize
                                               andPage:str_page
                                                  success:^(NSDictionary *dic){
                                                      
                                                      if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
                                                      {
                                                          NSLog(@" getCityPoiDataByCityId 成功 ");
                                                          NSArray *array = [dic objectForKey:@"data"];
                                                          NSArray *array_out = [[self prepareNearByData:array andLat:lat andLng:lon] retain];
                                                          finishedBlock(array_out);
                                                          [array_out release];
                                                      }
                                                      else
                                                      {
                                                          failedBlock();
                                                      }
                                                  }
                                                   failed:^(NSError *error){
                                                       NSLog(@" getCityPoiDataByCityId 失败! ");
                                                       failedBlock();
                                                   }];
}
+(NSArray *)prepareNearByData:(NSArray *)array andLat:(float)lat andLng:(float)lng
{
    NSMutableArray *array_cityPoiData = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            CityPoi *cityPoi_obj = [[CityPoi alloc] init];
            cityPoi_obj.str_poiId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            cityPoi_obj.str_poiChineseName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"firstname"]];
            cityPoi_obj.str_poiEnglishName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"secnodname"]];
            cityPoi_obj.str_poiLocalName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"localname"]];
            cityPoi_obj.str_albumCover = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
            cityPoi_obj.str_lat = [NSString stringWithFormat:@"%@",[dic objectForKey:@"lat"]];
            cityPoi_obj.str_lng = [NSString stringWithFormat:@"%@",[dic objectForKey:@"lng"]];
            cityPoi_obj.str_wantGo = [NSString stringWithFormat:@"%@",[dic objectForKey:@"beenstr"]];
            cityPoi_obj.str_comprehensiveEvaluation = [NSString stringWithFormat:@"%@",[dic objectForKey:@"gradescores"]];
            cityPoi_obj.str_comprehensiveRating = [NSString stringWithFormat:@"%@",[dic objectForKey:@"grade"]];
            cityPoi_obj.str_recommendscores = [NSString stringWithFormat:@"%@",[dic objectForKey:@"recommendscores"]];
            cityPoi_obj.str_recommendstr = [NSString stringWithFormat:@"%@",[dic objectForKey:@"recommendstr"]];
            
            float distance = [self LantitudeLongitudeDist:lng other_Lat:lat self_Lon:[[dic objectForKey:@"lng"] floatValue] self_Lat:[[dic objectForKey:@"lat"] floatValue]];
            cityPoi_obj.str_distance = [NSString stringWithFormat:@"%.2fkm",distance/1000];
            
            
            int isHot = [[NSString stringWithFormat:@"%@",[dic objectForKey:@"recommendnumber"]] intValue];
            if (isHot == 1 || isHot == 2) //如果是热门
            {
                cityPoi_obj.str_hotFlag = @"1";
            }
            else
            {
                cityPoi_obj.str_hotFlag = @"0";
            }
            
            [array_cityPoiData addObject:cityPoi_obj];
            [cityPoi_obj release];
        }
    }
    return [array_cityPoiData autorelease];
}


#pragma mark
#pragma mark --- calculate distance  根据2个经纬度计算距离
#define PI 3.1415926
+(double)LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2
{
    NSLog(@" lon1 : %f",lon1);
    NSLog(@" lat1 : %f",lat1);
    NSLog(@" lon2 : %f",lon2);
    NSLog(@" lat2 : %f",lat2);
    
    
    double er = 6378137; // 6378700.0f;
	//ave. radius = 6371.315 (someone said more accurate is 6366.707)
	//equatorial radius = 6378.388
	//nautical mile = 1.15078
	double radlat1 = PI*lat1/180.0f;
	double radlat2 = PI*lat2/180.0f;
	//now long.
	double radlong1 = PI*lon1/180.0f;
	double radlong2 = PI*lon2/180.0f;
	if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
	if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
	if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
	if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
	if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
	if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
	//spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
	//zero ag is up so reverse lat
	double x1 = er * cos(radlong1) * sin(radlat1);
	double y1 = er * sin(radlong1) * sin(radlat1);
	double z1 = er * cos(radlat1);
	double x2 = er * cos(radlong2) * sin(radlat2);
	double y2 = er * sin(radlong2) * sin(radlat2);
	double z2 = er * cos(radlat2);
	double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
	//side, side, side, law of cosines and arccos
	double theta = acos((er*er+er*er-d*d)/(2*er*er));
	double dist  = theta*er;
    NSLog(@" dist : %f",dist);
	return dist;
}

@end
