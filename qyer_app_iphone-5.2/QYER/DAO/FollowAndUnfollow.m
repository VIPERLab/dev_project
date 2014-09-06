//
//  FollowAndUnfollow.m
//  QYER
//
//  Created by 我去 on 14-5-21.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "FollowAndUnfollow.h"
#import "QYAPIClient.h"


@implementation FollowAndUnfollow

+(void)followWithUserid:(NSString *)userid
                success:(FollowAndUnfollowSuccessBlock)successBlock
                 failed:(FollowAndUnfollowFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] followWithUserid:userid
                                            success:^(NSDictionary *dic){
                                                NSLog(@" follow dic : %@",dic);
                                                if(dic && [[dic objectForKey:@"status"] intValue] == 1 && [dic objectForKey:@"data"])
                                                {
                                                    NSDictionary *dic_ = [dic objectForKey:@"data"];
                                                    if(dic_ && dic_.count > 0 && [[dic_ objectForKey:@"result"] intValue] == 1)
                                                    {
                                                        successBlock(YES,[dic_ objectForKey:@"follow_status"]);
                                                    }
                                                }
                                                else
                                                {
                                                    successBlock(NO,@"");
                                                }
                                            }
                                             failed:^{
                                                 NSLog(@" follow failed");
                                             }];
}

+(void)unFollowWithUserid:(NSString *)userid
                  success:(FollowAndUnfollowSuccessBlock)successBlock
                   failed:(FollowAndUnfollowFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] unFollowWithUserid:userid
                                              success:^(NSDictionary *dic){
                                                  NSLog(@" unFollow dic : %@",dic);
                                                  if(dic && [[dic objectForKey:@"status"] intValue] == 1 && [dic objectForKey:@"data"])
                                                  {
                                                      NSDictionary *dic_ = [dic objectForKey:@"data"];
                                                      if(dic_ && dic_.count > 0 && [[dic_ objectForKey:@"result"] intValue] == 1)
                                                      {
                                                          successBlock(YES,@"");
                                                      }
                                                  }
                                                  else
                                                  {
                                                      successBlock(NO,@"");
                                                  }
                                              }
                                               failed:^{
                                                   NSLog(@" unFollow failed");
                                               }];
}

@end
