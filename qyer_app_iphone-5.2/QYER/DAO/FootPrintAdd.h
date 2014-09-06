//
//  FootPrintAdd.h
//  QYER
//
//  Created by 我去 on 14-8-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>



#if NS_BLOCKS_AVAILABLE
typedef void (^FootPrintAddSuccessBlock)(NSDictionary *dic);
typedef void (^FootPrintAddFailedBlock)(NSError *error);
#endif


@interface FootPrintAdd : NSObject

+(void)addFootPrintWithOper:(NSString *)oper
                    andType:(NSString *)type
                      andId:(NSInteger)obj_id
                    success:(FootPrintAddSuccessBlock)successBlock
                     failed:(FootPrintAddFailedBlock)failedBlock;

@end
