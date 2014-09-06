//
//  UserInfoData.m
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "UserInfoData.h"
#import "UserInfo.h"
#import "QYAPIClient.h"

@implementation UserInfoData


//获取我的个人信息(缓存):
+(void)getCachedMineInfoWithUserid:(NSString *)userid
                        orImUserId:(NSString *)userid_im
                           success:(UserInfoDataSuccessBlock)finishedBlock
                            failed:(UserInfoDataFailedBlock)failedBlock
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"mineinfo_%@",userid]];
    if(dic)
    {
        finishedBlock(dic);
    }
}

//获取我的个人信息:
+(void)getMineInfoWithUserid:(NSString *)userid
                  orImUserId:(NSString *)userid_im
                     success:(UserInfoDataSuccessBlock)finishedBlock
                      failed:(UserInfoDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getMyInfoWithUserid:userid
                                            orImUserId:userid_im
                                               success:^(NSDictionary *dic){
                                                   NSLog(@" MineInfo : %@",dic);
                                                   
                                                   NSMutableDictionary *dic_ = (NSMutableDictionary *)dic;
                                                   if(![[dic_ objectForKey:@"data"] objectForKey:@"im_user_id"])
                                                   {
                                                       [[dic_ objectForKey:@"data"] setObject:@"" forKey:@"im_user_id"];
                                                   }
                                                   [[NSUserDefaults standardUserDefaults] setObject:dic_ forKey:[NSString stringWithFormat:@"mineinfo_%@",userid]];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                   
                                                   finishedBlock(dic_);
                                               }
                                                failed:^{
                                                    NSLog(@" MineInfo failed ");
                                                    failedBlock();
                                                }];
}

//获取他人的个人信息:
+(void)getUserInfoWithUserId:(NSString *)user_id
                  orImUserId:(NSString *)userid_im
                     success:(UserInfoDataSuccessBlock)finishedBlock
                      failed:(UserInfoDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getUserInfoWithUserId:user_id
                                              orImUserId:userid_im
                                                 success:^(NSDictionary *dic){
                                                     NSLog(@" UserInfo : %@",dic);
                                                     finishedBlock(dic);
                                                 }
                                                  failed:^{
                                                      NSLog(@" UserInfo failed ");
                                                      failedBlock();
                                                  }];
}

//清空userInfo的数据:
+(void)cleanInfo:(UserInfo *)userInfo
{
    userInfo.user_id = 0;
    userInfo.username = nil;
    userInfo.im_user_id = nil;
    userInfo.can_dm = 0;
    userInfo.gender = 0;
    userInfo.title = nil;
    userInfo.avatar = nil;
    userInfo.cover = nil;
    userInfo.footprint = nil;
    userInfo.follow_status = nil;
    userInfo.fans = 0;
    userInfo.follow = 0;
    userInfo.countries = 0;
    userInfo.cities = 0;
    userInfo.pois = 0;
    userInfo.trips = 0;
    userInfo.wants = 0;
}

@end
