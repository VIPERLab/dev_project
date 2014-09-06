//
//  QyerAppNotificationData.m
//  QYER
//
//  Created by Qyer on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QyerAppNotificationData.h"
#import "QyerAppNotification.h"
#import "QYAPIClient.h"
@implementation QyerAppNotificationData

+(void)getNotificationListWithCount:(NSString *)count
                            andPage:(NSString *)page
                            success:(QyerAppNotificationDataSuccessBlock)successBlock
                             failed:(QyerAppNotificationDataFailedBlock)failedBlock{
    [[QYAPIClient sharedAPIClient] getNotificationListWithCount:count
                                                andPage:page
                                               success:^(NSDictionary *dic){
                                                   
                                                   if(dic && [dic count] > 0 && [dic objectForKey:@"data"] && ![[dic objectForKey:@"data"] isKindOfClass:[NSNull class]])
                                                   {
                                                       
                                                       NSArray *dictData = [dic objectForKey:@"data"];
                                                       
                                                       NSArray *array_out=[[self prepareData:dictData] retain];
                                                       successBlock(array_out);
                                                       [array_out release];
                                                   }
                                                   else
                                                   {
                                                       failedBlock();
                                                   }
                                               }
                                                failed:^{
                                                    NSLog(@" getNotificationListWithCount 失败! ");
                                                    failedBlock();
                                                }];
}

+(NSArray *)prepareData:(NSArray *)array
{
    NSMutableArray *array_notificationData = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dic in array)
    {
        if(dic)
        {
            QyerAppNotification *notification_obj = [[QyerAppNotification alloc] init];
            notification_obj.notification_id= [NSString stringWithFormat:@"%@",[dic objectForKey:@"notification_id"]];
            notification_obj.object_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"object_id"]];
            notification_obj.message = [NSString stringWithFormat:@"%@",[dic objectForKey:@"message"]];
            notification_obj.type = [NSString stringWithFormat:@"%@",[dic objectForKey:@"type"]];
            notification_obj.publish_time = [NSString stringWithFormat:@"%@",[dic objectForKey:@"publish_time"]];
           notification_obj.object_photo= [NSString stringWithFormat:@"%@",[dic objectForKey:@"object_photo"]];
            
            notification_obj.numbers= [NSString stringWithFormat:@"%@",[dic objectForKey:@"numbers"]];

            [array_notificationData addObject:notification_obj];
            [notification_obj release];
        }
    }
    
    return [array_notificationData autorelease];
}
@end
