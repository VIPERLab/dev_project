//
//  HasGoneData.h
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HasGoneData : NSObject


#if NS_BLOCKS_AVAILABLE
typedef void (^HasGoneDataSuccessBlock)(NSDictionary *dic,NSArray *array_cn,NSArray *array_en);
typedef void (^HasGoneDataFailedBlock)(void);
#endif


+(void)cancleGetHasGoneDataWithUserid:(NSString *)userid;
+(void)getCachedHasGoneDataWithUserid:(NSString *)userid
                              success:(HasGoneDataSuccessBlock)successBlock
                               failed:(HasGoneDataFailedBlock)failedBlock;
+(void)getHasGoneDataWithUserid:(NSString *)userid
                        success:(HasGoneDataSuccessBlock)successBlock
                         failed:(HasGoneDataFailedBlock)failedBlock;


@end
