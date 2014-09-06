//
//  UserPhotoData.h
//  QYER
//
//  Created by 我去 on 14-5-22.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^UserPhotoDataSuccessBlock)(NSDictionary *dic);
typedef void (^UserPhotoDataFailedBlock)(void);
#endif


@interface UserPhotoData : NSObject

+(void)postPhotoWithImage:(UIImage *)image
                  success:(UserPhotoDataSuccessBlock)successBlock
                   failed:(UserPhotoDataFailedBlock)failedBlock;

@end
