//
//  QyerAppNotificationData.h
//  QYER
//
//  Created by Qyer on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

#if NS_BLOCKS_AVAILABLE
typedef void (^QyerAppNotificationDataSuccessBlock)(NSArray *array);
typedef void (^QyerAppNotificationDataFailedBlock)(void);
#endif

@interface QyerAppNotificationData : NSObject{

}

//获取通知列表
+(void)getNotificationListWithCount:(NSString *)count
                            andPage:(NSString *)page
                            success:(QyerAppNotificationDataSuccessBlock)successBlock
                             failed:(QyerAppNotificationDataFailedBlock)failedBlock;
@end
