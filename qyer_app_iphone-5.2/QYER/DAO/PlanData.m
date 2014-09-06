//
//  PlanData.m
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import "PlanData.h"
#import "QYAPIClient.h"
#import "Plan.h"


@implementation PlanData


//+(void)getPlanDataOfCountryByCountryId:(NSString *)countryId
//                              pageSize:(NSString *)str_pageSize
//                                  page:(NSString *)str_page
//                               success:(PlanDataSuccessBlock)finishedBlock
//                                failed:(PlanDataFailedBlock)failedBlock
//{
//    [[QYAPIClient sharedAPIClient] getPlanDataOfCountryByCountryId:countryId pageSize:str_pageSize page:str_page 
//                                                           success:^(NSDictionary *dic){
//                                                               
//                                                               if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
//                                                               {
//                                                                   
//                                                                   NSArray *array = [dic objectForKey:@"data"];
//                                                                   NSArray *array_out = [[self prepareData:array] retain];
//                                                                   finishedBlock(array_out);
//                                                                   [array_out release];
//                                                               }
//                                                               else
//                                                               {
//                                                                   failedBlock();
//                                                               }
//                                                           }
//                                                            failed:^{
//                                                                NSLog(@" getPlanDataOfCountryByCountryId 失败! ");
//                                                                failedBlock();
//                                                            }];
//}
//+(void)getPlanDataOfCityByCityId:(NSString *)cityId
//                        pageSize:(NSString *)str_pageSize
//                            page:(NSString *)str_page
//                         success:(PlanDataSuccessBlock)finishedBlock
//                          failed:(PlanDataFailedBlock)failedBlock
//{
//    [[QYAPIClient sharedAPIClient] getPlanDataOfCityByCityId:cityId pageSize:str_pageSize page:str_page
//                                                     success:^(NSDictionary *dic){
//                                                         
//                                                         if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"])
//                                                         {
//                                                             NSLog(@" getPlanDataOfCityByCityId 成功 %@",dic);
//                                                             NSArray *array = [dic objectForKey:@"data"];
//                                                             NSArray *array_out = [[self prepareData:array] retain];
//                                                             finishedBlock(array_out);
//                                                             [array_out release];
//                                                         }
//                                                         
//                                                     }
//                                                      failed:^{
//                                                          NSLog(@" getPlanDataOfCityByCityId 失败! ");
//                                                          failedBlock();
//                                                      }];
//}


+(NSArray *)prepareData:(NSArray *)array
{
    NSMutableArray *array_planData = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            Plan *plan_obj = [[Plan alloc] init];
            plan_obj.str_planName= [NSString stringWithFormat:@"%@",[dic objectForKey:@"subject"]];
            plan_obj.str_planId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            plan_obj.str_planAlbumCover = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
            plan_obj.str_planDays = [NSString stringWithFormat:@"%@",[dic objectForKey:@"day_count"]];
            plan_obj.str_planBelongTo = [NSString stringWithFormat:@"%@",[dic objectForKey:@"username"]];
            plan_obj.str_planRoute = [NSString stringWithFormat:@"%@",[dic objectForKey:@"route"]];
            plan_obj.str_planUpdateTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"updatetime"]];
            plan_obj.str_planUrl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"view_url"]];
            
            plan_obj.str_avatar = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar"]];
            [array_planData addObject:plan_obj];
            [plan_obj release];
        }
    }
    
    return [array_planData autorelease];
}


@end
