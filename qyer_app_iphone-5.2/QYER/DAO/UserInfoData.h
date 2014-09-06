//
//  UserInfoData.h
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"



#if NS_BLOCKS_AVAILABLE
typedef void (^UserInfoDataSuccessBlock)(NSDictionary *dic);
typedef void (^UserInfoDataFailedBlock)(void);
#endif




@interface UserInfoData : NSObject


//获取我的个人信息(缓存):
+(void)getCachedMineInfoWithUserid:(NSString *)userid
                        orImUserId:(NSString *)userid_im
                           success:(UserInfoDataSuccessBlock)finishedBlock
                            failed:(UserInfoDataFailedBlock)failedBlock;
//获取我的个人信息:
+(void)getMineInfoWithUserid:(NSString *)userid
                  orImUserId:(NSString *)userid_im
                     success:(UserInfoDataSuccessBlock)finishedBlock
                      failed:(UserInfoDataFailedBlock)failedBlock;

//获取他人的个人信息:
+(void)getUserInfoWithUserId:(NSString *)user_id
                  orImUserId:(NSString *)userid_im
                     success:(UserInfoDataSuccessBlock)finishedBlock
                      failed:(UserInfoDataFailedBlock)failedBlock;

//清空userInfo的数据:
+(void)cleanInfo:(UserInfo *)userInfo;

@end
