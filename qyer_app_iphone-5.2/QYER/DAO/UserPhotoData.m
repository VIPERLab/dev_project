//
//  UserPhotoData.m
//  QYER
//
//  Created by 我去 on 14-5-22.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "UserPhotoData.h"
#import "QYAPIClient.h"


@implementation UserPhotoData

+(void)postPhotoWithImage:(UIImage *)image
                  success:(UserPhotoDataSuccessBlock)successBlock
                   failed:(UserPhotoDataFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] postPhotoWithImage:image
                                              success:^(NSDictionary *dic){
                                                  NSLog(@" Photo dic : %@",dic);
                                                  if(dic && [[dic objectForKey:@"status"] intValue] == 1 && [dic objectForKey:@"data"])
                                                  {
                                                      NSDictionary *dic_ = [dic objectForKey:@"data"];
                                                      if(dic_ && dic_.count > 0 && [[dic objectForKey:@"status"] intValue] == 1)
                                                      {
                                                          successBlock(dic);
                                                      }
                                                      else
                                                      {
                                                          failedBlock();
                                                      }
                                                  }
                                                  else
                                                  {
                                                      failedBlock();
                                                  }
                                              }
                                               failed:^{
                                                   NSLog(@" postPhoto failed");
                                                   failedBlock();
                                               }];
}

@end
