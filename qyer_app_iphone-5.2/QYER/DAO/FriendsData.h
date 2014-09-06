//
//  FriendsData.h
//  QYER
//
//  Created by 我去 on 14-5-12.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^FriendsDataSuccessBlock)(NSArray *array);
typedef void (^FriendsDataFailedBlock)(void);
#endif



@interface FriendsData : NSObject

+(void)cancleGetFriendsDataWithType:(NSString *)type
                          andUserid:(NSString *)userid
                           andCount:(NSString *)count
                            andPage:(NSString *)page;

+(void)getFriendsDataWithType:(NSString *)type
                    andUserid:(NSString *)userid
                     andCount:(NSString *)count
                      andPage:(NSString *)page
                      success:(FriendsDataSuccessBlock)successBlock
                       failed:(FriendsDataFailedBlock)failedBlock;

@end
