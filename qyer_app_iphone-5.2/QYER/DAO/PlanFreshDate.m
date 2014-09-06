//
//  PlanFreshDate.m
//  QYGuide
//
//  Created by 你猜你猜 on 13-11-11.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "PlanFreshDate.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"



#define getdatamaxtime  15    //获取数据的请求超时时间



@implementation PlanFreshDate

+(void)isFresh:(NSString *)str_planId
      finished:(PlanFreshDateFinishedBlock)finished
        failed:(PlanFreshDateFailedBlock)failed
{
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/plan/tripapp_time?client_id=%@&client_secret=%@&id=%@",DomainName,ClientId_QY,ClientSecret_QY,str_planId]]];
    request.timeOutSeconds = getdatamaxtime;
    MYLog(@"url == lastminute == %@",[request.url absoluteString]);
    
    
    [request setCompletionBlock:^{
        
        NSString *result = [request responseString];
        
        if([[[result JSONValue] objectForKey:@"status"] intValue] == 1)
        {
            if([NSString stringWithFormat:@"%@",[[result JSONValue] objectForKey:@"data"]] && [NSString stringWithFormat:@"%@",[[result JSONValue] objectForKey:@"data"]].length > 0)
            {
                MYLog(@"获取PlanFreshDate 成功");
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
//                NSString *myDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[[result JSONValue] objectForKey:@"data"] doubleValue]]];
//                NSLog(@" date === %@",myDateStr);
                [dateFormatter release];
            }
            else
            {
                failed();
            }
        }
        else
        {
            failed();
        }
    }];
    
    [request setFailedBlock:^{
        MYLog(@"获取PlanFreshDate 失败");
        
        failed();
    }];
    [request startAsynchronous];
}

@end


