//
//  WantGoData.h
//  QYER
//
//  Created by 我去 on 14-5-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^WantGoDataSuccessBlock)(NSDictionary *dic,NSArray *array_cn,NSArray *array_en);
typedef void (^WantGoDataFailedBlock)(void);
#endif


@interface WantGoData : NSObject


//取消请求:
+(void)cancleGetWantGoDataWithUserid:(NSString *)userid;


+(void)getWantGoDataWithUserid:(NSString *)userid
                       success:(WantGoDataSuccessBlock)successBlock
                        failed:(WantGoDataFailedBlock)failedBlock;

+(void)getCachedWantGoDataWithUserid:(NSString *)userid
                             success:(WantGoDataSuccessBlock)successBlock
                              failed:(WantGoDataFailedBlock)failedBlock;

@end
