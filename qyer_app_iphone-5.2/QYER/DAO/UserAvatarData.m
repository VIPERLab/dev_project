//
//  UserAvatarData.m
//  QYER
//
//  Created by 我去 on 14-5-21.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "UserAvatarData.h"
#import "QYAPIClient.h"
#import "LocalData.h"
#import "QYIMObject.h"
@implementation UserAvatarData

+(void)postAvatarWithImage:(UIImage *)image
                   success:(UserAvatarDataSuccessBlock)successBlock
                    failed:(UserAvatarDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] postAvatarWithImage:image
                                               success:^(NSDictionary *dic){
                                                   NSLog(@" Avatar dic : %@",dic);
                                                   if(dic && [[dic objectForKey:@"status"] intValue] == 1 && [dic objectForKey:@"data"])
                                                   {
                                                       NSDictionary *dic_ = [dic objectForKey:@"data"];
                                                       if(dic_ && dic_.count > 0 && [[dic objectForKey:@"status"] intValue] == 1)
                                                       {
                                                           //修改本地用户头像
                                                           [[NSUserDefaults standardUserDefaults] setObject:dic_[@"avatar"] forKey:@"usericon"];
                                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                                           
                                                           if (!IsEmpty([QYIMObject getInstance].privateChatImUserId) || !IsEmpty([QYIMObject getInstance].publicChatTopicId)) {
                                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableView" object:nil];
                                                           }
                                                           
                                                           successBlock(dic);
                                                       }
                                                   }
                                                   else
                                                   {
                                                       failedBlock();
                                                   }
                                               }
                                                failed:^{
                                                    NSLog(@" follow failed");
                                                    failedBlock();
                                                }];
}


@end
