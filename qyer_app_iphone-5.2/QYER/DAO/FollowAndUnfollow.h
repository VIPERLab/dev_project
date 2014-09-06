//
//  FollowAndUnfollow.h
//  QYER
//
//  Created by 我去 on 14-5-21.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>



#if NS_BLOCKS_AVAILABLE
typedef void (^FollowAndUnfollowSuccessBlock)(BOOL flag, NSString *status);
typedef void (^FollowAndUnfollowFailedBlock)(void);
#endif



@interface FollowAndUnfollow : NSObject

+(void)followWithUserid:(NSString *)userid
                success:(FollowAndUnfollowSuccessBlock)successBlock
                 failed:(FollowAndUnfollowFailedBlock)failedBlock;

+(void)unFollowWithUserid:(NSString *)userid
                  success:(FollowAndUnfollowSuccessBlock)successBlock
                   failed:(FollowAndUnfollowFailedBlock)failedBlock;

@end
