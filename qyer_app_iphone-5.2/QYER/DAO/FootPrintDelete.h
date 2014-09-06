//
//  FootPrintDelete.h
//  QYER
//
//  Created by 我去 on 14-8-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


#if NS_BLOCKS_AVAILABLE
typedef void (^FootPrintDeleteSuccessBlock)(NSDictionary *dic);
typedef void (^FootPrintDeleteFailedBlock)(NSError *error);
#endif


@interface FootPrintDelete : NSObject

+(void)deleteFootPrintWithOper:(NSString *)oper
                       andType:(NSString *)type
                         andId:(NSInteger)obj_id
                       success:(FootPrintDeleteSuccessBlock)successBlock
                        failed:(FootPrintDeleteFailedBlock)failedBlock;

@end
