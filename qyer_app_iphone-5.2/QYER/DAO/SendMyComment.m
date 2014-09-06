//
//  SendMyComment.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "SendMyComment.h"
#import "QYAPIClient.h"

@implementation SendMyComment

+(void)sendMyCommentByAccessToken:(NSString *)accessToken
                       andGuideId:(NSString *)guideid
                   andCommentText:(NSString *)comment
                         finished:(sendMyCommentFinishedBlock)finished
                           failed:(sendMyCommentFailedBlock)failed
{
    [[QYAPIClient sharedAPIClient] sendMyCommentByAccessToken:accessToken
                                                   andGuideId:guideid
                                               andCommentText:comment
                                                     finished:^(NSDictionary *dic){
                                                         NSLog(@" sendMyComment : %@",dic);
                                                         NSLog(@" content : %@",[[dic objectForKey:@"data"] objectForKey:@"content"]);
                                                         finished();
                                                     }
                                                       failed:^(NSString *info){
                                                           NSLog(@" sendMyComment failed ");
                                                           failed(info);
                                                       }];
}

@end
