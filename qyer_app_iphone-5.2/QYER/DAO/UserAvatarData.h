//
//  UserAvatarData.h
//  QYER
//
//  Created by 我去 on 14-5-21.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>



#if NS_BLOCKS_AVAILABLE
typedef void (^UserAvatarDataSuccessBlock)(NSDictionary *dic);
typedef void (^UserAvatarDataFailedBlock)(void);
#endif


@interface UserAvatarData : NSObject

+(void)postAvatarWithImage:(UIImage *)image
                   success:(UserAvatarDataSuccessBlock)successBlock
                    failed:(UserAvatarDataFailedBlock)failedBlock;

@end
