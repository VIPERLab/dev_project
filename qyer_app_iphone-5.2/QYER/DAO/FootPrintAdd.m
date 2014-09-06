//
//  FootPrintAdd.m
//  QYER
//
//  Created by 我去 on 14-8-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "FootPrintAdd.h"
#import "QYAPIClient.h"

@implementation FootPrintAdd

+(void)addFootPrintWithOper:(NSString *)oper
                    andType:(NSString *)type
                      andId:(NSInteger)obj_id
                    success:(FootPrintAddSuccessBlock)successBlock
                     failed:(FootPrintAddFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] addFootPrintWithOper:oper
                                                andType:type
                                               andObjId:obj_id
                                                success:successBlock
                                                 failed:failedBlock];
}

@end
