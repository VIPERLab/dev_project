//
//  GuideDownloadTime.m
//  QYGuide
//
//  Created by 我去 on 14-2-19.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GuideDownloadTime.h"
#import "QYAPIClient.h"


@implementation GuideDownloadTime


+(void)getGuideDownloadTimeSuccessBlock:(GuideDownloadTimeSuccessBlock)finishedBlock
                            failedBlock:(GuideDownloadTimeFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getGuideDownloadTimeFinished:^(NSDictionary *dic){
                                                            
                                                            if(dic && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"status"]] isEqualToString:@"1"] && [dic objectForKey:@"data"])
                                                            {
                                                                NSLog(@" 获取锦囊的最新下载次数 成功");
                                                                
                                                                finishedBlock([dic objectForKey:@"data"]);
                                                            }
                                                            else
                                                            {
                                                                NSLog(@" 获取锦囊的最新下载次数 失败 ~~");
                                                                failedBlock();
                                                            }
                                                        }
                                                         failed:^{
                                                             NSLog(@" 获取锦囊的最新下载次数 失败!");
                                                             failedBlock();
                                                          }];
}


@end

