//
//  MicroTravelData.m
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import "MicroTravelData.h"
#import "QYAPIClient.h"
#import "MicroTravel.h"


@implementation MicroTravelData

+(void)getMicroTravelDataOfCountryByCountryId:(NSString *)countryId
                                     pageSize:(NSString *)str_pageSize
                                         page:(NSString *)str_page
                                      success:(MicroTravelDataSuccessBlock)finishedBlock
                                       failed:(MicroTravelDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getMicroTravelDataOfCountryByCountryId:countryId pageSize:str_pageSize page:str_page
                                                                  success:^(NSDictionary *dic){
                                                                      
                                                                      
                                                                      if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
                                                                      {
                                                                          NSLog(@" getMicroTravelDataOfCountryByCountryId 成功 ");
                                                                          NSArray *array = [dic objectForKey:@"data"];
                                                                          NSArray *array_out = [[self prepareData:array] retain];
                                                                          finishedBlock(array_out);
                                                                          [array_out release];
                                                                      }
                                                                      else
                                                                      {
                                                                          failedBlock();
                                                                      }
                                                                      
                                                                  } failed:^{
                                                                      NSLog(@" getMicroTravelDataOfCountryByCountryId 失败! ");
                                                                      failedBlock();
                                                                  }];
}
+(void)getMicroTravelDataOfCityByCityId:(NSString *)cityId
                               pageSize:(NSString *)str_pageSize
                                   page:(NSString *)str_page
                                   success:(MicroTravelDataSuccessBlock)finishedBlock
                                    failed:(MicroTravelDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getMicroTravelDataOfCityByCityId:cityId  pageSize:str_pageSize page:str_page 
                                                            success:^(NSDictionary *dic){
                                                                
                                                                if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"])
                                                                {
                                                                    NSLog(@" getMicroTravelDataOfCityByCityId 成功 ");
                                                                    NSArray *array = [dic objectForKey:@"data"];
                                                                    NSArray *array_out = [[self prepareData:array] retain];
                                                                    finishedBlock(array_out);
                                                                    [array_out release];
                                                                }
                                                                
                                                            } failed:^{
                                                                NSLog(@" getMicroTravelDataOfCityByCityId 失败! ");
                                                                failedBlock();
                                                            }];
}

+(NSArray *)prepareData:(NSArray *)array
{
    NSMutableArray *array_microlTravel = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            MicroTravel *microlTravel_obj = [[MicroTravel alloc] init];
            microlTravel_obj.str_travelId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            microlTravel_obj.str_travelName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"subject"]];
            microlTravel_obj.str_travelAlbumCover = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
            microlTravel_obj.str_travelBelongTo = [NSString stringWithFormat:@"%@",[dic objectForKey:@"username"]];
            microlTravel_obj.str_travelUpdateTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"updatetime"]];
            microlTravel_obj.str_travelUrl_all = [NSString stringWithFormat:@"%@",[dic objectForKey:@"view_url"]];
            microlTravel_obj.str_travelUrl_onlyauthor = [NSString stringWithFormat:@"%@",[dic objectForKey:@"view_author_url"]];
            microlTravel_obj.str_likeCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"like_count"]];
            microlTravel_obj.str_commentCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"comment_count"]];
            microlTravel_obj.str_browserCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"view_count"]];
            
            microlTravel_obj.str_avatarUrl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar"]];
            
            
            [array_microlTravel addObject:microlTravel_obj];
            [microlTravel_obj release];
        }
    }
    return [array_microlTravel autorelease];
}







+(void)getUserTravelDataWithUserId:(NSInteger)userId
                           andType:(NSString *)type
                          andCount:(NSInteger)count
                           andPage:(NSInteger)page
                           success:(MicroTravelDataSuccessBlock)finishedBlock
                            failed:(MicroTravelDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getUserTravelDataWithUserId:userId
                                                       andType:(NSString *)type
                                                      andCount:(NSInteger)count
                                                       andPage:(NSInteger)page
                                                       success:^(NSDictionary *dic){
                                                           
                                                           if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"])
                                                           {
                                                               NSLog(@" getMyTravelDataWithUserId 成功 ");
                                                               NSArray *array = [dic objectForKey:@"data"];
                                                               NSArray *array_out = [[self prepareBbsData:array] retain];
                                                               finishedBlock(array_out);
                                                               [array_out release];
                                                           }
                                                           else
                                                           {
                                                               failedBlock();
                                                           }
                                                       } failed:^(NSError *error){
                                                           NSLog(@" getMyTravelDataWithUserId 失败! ");
                                                           failedBlock();
                                                       }];
}

+(void)getUserCollectTravelDataWithUserId:(NSInteger)userId
                                  andType:(NSString *)type
                                 andCount:(NSInteger)count
                                  andPage:(NSInteger)page
                                  success:(MicroTravelDataSuccessBlock)finishedBlock
                                   failed:(MicroTravelDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getUserCollectTravelDataWithUserId:userId
                                                              andType:(NSString *)type
                                                             andCount:(NSInteger)count
                                                              andPage:(NSInteger)page
                                                              success:^(NSDictionary *dic){
                                                                  
                                                                  if(dic && [dic count] > 0 && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"])
                                                                  {
                                                                      NSLog(@" getMyCollectTravelDataWithUserId 成功 ");
                                                                      NSArray *array = [dic objectForKey:@"data"];
                                                                      NSArray *array_out = [[self prepareBbsData:array] retain];
                                                                      finishedBlock(array_out);
                                                                      [array_out release];
                                                                  }
                                                                  else
                                                                  {
                                                                      failedBlock();
                                                                  }
                                                                  
                                                              } failed:^(NSError *error){
                                                                NSLog(@" getMyCollectTravelDataWithUserId 失败! ");
                                                                failedBlock();
                                                            }];
}

+(NSArray *)prepareBbsData:(NSArray *)array
{
    NSMutableArray *array_microlTravel = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            MicroTravel *microlTravel_obj = [[MicroTravel alloc] init];
            //microlTravel_obj.str_travelId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
            microlTravel_obj.str_travelAlbumCover = [NSString stringWithFormat:@"%@",[dic objectForKey:@"photo"]];
            microlTravel_obj.str_travelName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"title"]];
            microlTravel_obj.str_travelUpdateTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"lastpost"]];
            microlTravel_obj.str_userId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"user_id"]];
            microlTravel_obj.str_travelBelongTo = [NSString stringWithFormat:@"%@",[dic objectForKey:@"username"]];
            microlTravel_obj.str_travelUrl_all = [NSString stringWithFormat:@"%@",[dic objectForKey:@"view_url"]];
            microlTravel_obj.str_avatarUrl = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar"]];
            microlTravel_obj.str_commentCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"replys"]];
            microlTravel_obj.str_likeCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"likes"]];
            //microlTravel_obj.str_travelUrl_onlyauthor = [NSString stringWithFormat:@"%@",[dic objectForKey:@"view_author_url"]];
            //microlTravel_obj.str_browserCount = [NSString stringWithFormat:@"%@",[dic objectForKey:@"view_count"]];
            
            
            
            [array_microlTravel addObject:microlTravel_obj];
            [microlTravel_obj release];
        }
    }
    return [array_microlTravel autorelease];
}


@end
