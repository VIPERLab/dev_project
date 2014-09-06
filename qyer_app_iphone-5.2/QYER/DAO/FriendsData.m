//
//  FriendsData.m
//  QYER
//
//  Created by 我去 on 14-5-12.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "FriendsData.h"
#import "QYAPIClient.h"
#import "Friends.h"

@implementation FriendsData


+(void)cancleGetFriendsDataWithType:(NSString *)type
                          andUserid:(NSString *)userid
                           andCount:(NSString *)count
                            andPage:(NSString *)page
{
    if(type && [type isEqualToString:@"fans"])
    {
        [[QYAPIClient sharedAPIClient] cancleGetFansDataWithUserid:userid
                                                          andCount:count
                                                           andPage:page
         ];
    }
    else if(type && [type isEqualToString:@"follows"])
    {
        [[QYAPIClient sharedAPIClient] cancleGetFansDataWithUserid:userid
                                                          andCount:count
                                                           andPage:page
         ];
    }
}

+(void)getFriendsDataWithType:(NSString *)type
                    andUserid:(NSString *)userid
                     andCount:(NSString *)count
                      andPage:(NSString *)page
                      success:(FriendsDataSuccessBlock)successBlock
                       failed:(FriendsDataFailedBlock)failedBlock
{
    if(type && [type isEqualToString:@"fans"])
    {
        [[QYAPIClient sharedAPIClient] getFansDataWithUserid:userid
                                                    andCount:count
                                                     andPage:page
                                                     success:^(NSDictionary *dic){
                                                         
                                                         NSArray *array = [self processData:dic];
                                                         successBlock(array);
                                                     }
                                                      failed:^{
                                                          failedBlock();
                                                      }];
    }
    else if(type && [type isEqualToString:@"follows"])
    {
        [[QYAPIClient sharedAPIClient] getFollowDataWithUserid:userid
                                                      andCount:count
                                                       andPage:page
                                                       success:^(NSDictionary *dic){
                                                           
                                                           NSArray *array = [self processData:dic];
                                                           successBlock(array);
                                                       }
                                                        failed:^{
                                                            failedBlock();
                                                        }];
    }
}

+(NSArray *)processData:(NSDictionary *)dic
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if(dic && [dic objectForKey:@"data"] && [[dic objectForKey:@"data"] isKindOfClass:[NSArray class]])
    {
        NSArray *array_ = [dic objectForKey:@"data"];
        if(![dic objectForKey:@"data"] || ![array_ isKindOfClass:[NSArray class]])
        {
            return [NSArray array];
        }
        
        for(NSDictionary *dic_ in array_)
        {
            if(!dic_ || ![dic_ isKindOfClass:[NSDictionary class]])
            {
                continue;
            }
            
            
            Friends *friend = [[Friends alloc] init];
            
            if(![dic_ objectForKey:@"im_user_id"] || [[dic_ objectForKey:@"im_user_id"] isKindOfClass:[NSNull class]])
            {
                friend.im_user_id = @"";
            }
            else
            {
                friend.im_user_id = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"im_user_id"]];
            }
            
            if(![dic_ objectForKey:@"gender"] || [[dic_ objectForKey:@"gender"] isKindOfClass:[NSNull class]])
            {
                friend.gender = 0;
            }
            else
            {
                friend.gender = [[dic_ objectForKey:@"gender"] intValue];
            }
            
            if(![dic_ objectForKey:@"username"] || [[dic_ objectForKey:@"username"] isKindOfClass:[NSNull class]])
            {
                friend.username = @"";
            }
            else
            {
                friend.username = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"username"]];
            }
            
            if(![dic_ objectForKey:@"avatar"] || [[dic_ objectForKey:@"avatar"] isKindOfClass:[NSNull class]])
            {
                friend.avatar = @"";
            }
            else
            {
                friend.avatar = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"avatar"]];
            }
            
            
            friend.user_id = [[dic_ objectForKey:@"user_id"] intValue];
            friend.both_follow = [[dic_ objectForKey:@"both_follow"] boolValue];
            friend.countries = [[dic_ objectForKey:@"countries"] intValue];
            friend.cities = [[dic_ objectForKey:@"cities"] intValue];
            [array addObject:friend];
            [friend release];
        }
    }
    
    return [array autorelease];
}



@end
