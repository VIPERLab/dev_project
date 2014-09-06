//
//  FootPrintDelete.m
//  QYER
//
//  Created by 我去 on 14-8-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "FootPrintDelete.h"
#import "QYAPIClient.h"

@implementation FootPrintDelete

+(void)deleteFootPrintWithOper:(NSString *)oper
                       andType:(NSString *)type
                         andId:(NSInteger)obj_id
                       success:(FootPrintDeleteSuccessBlock)successBlock
                        failed:(FootPrintDeleteFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] deleteFootPrintWithOper:oper
                                                   andType:type
                                                  andObjId:obj_id
                                                   success:successBlock
                                                    failed:failedBlock];
}

@end
