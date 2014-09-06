//
//  QYGuideComment.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-21.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "QYGuideComment.h"
#import "QYAPIClient.h"

@implementation QYGuideComment
@synthesize str_commentId = _str_commentId;
@synthesize str_commentTime = _str_commentTime;
@synthesize str_content = _str_content;
@synthesize str_userAvatar = _str_userAvatar;
@synthesize str_userId = _str_userId;
@synthesize str_userName = _str_userName;


-(void)dealloc
{
    self.str_commentId = nil;
    self.str_commentTime = nil;
    self.str_content = nil;
    self.str_userAvatar = nil;
    self.str_userId = nil;
    self.str_userName = nil;
    
    [super dealloc];
}


static QYGuideComment *sharedQYGuideComment = nil;
+(id)sharedQYGuideComment
{
    if(!sharedQYGuideComment)
    {
        sharedQYGuideComment = [[self alloc] init];
    }
    return sharedQYGuideComment;
}


-(void)getCommentListByGuideId:(NSInteger)guideId
                         count:(NSInteger)count
                         maxId:(NSInteger)maxId
                       success:(getGuideCommentSuccessBlock)successBlock
                       failure:(getGuideCommentFailedBlock)failedBlock
{
    [[QYAPIClient sharedAPIClient] getGuideCommentByGuideId:guideId
                                                   andCount:count
                                                   andMaxId:maxId
                                                    success:^(NSDictionary *dic){
                                                        if (successBlock)
                                                        {
                                                            if(![dic objectForKey:@"data"] || ![[dic objectForKey:@"data"] isKindOfClass:[NSDictionary class]] || ![[dic objectForKey:@"data"] objectForKey:@"comments"])
                                                            {
                                                                if([[dic objectForKey:@"data"] isKindOfClass:[NSArray class]] && [[dic objectForKey:@"data"] count] == 0)
                                                                {
                                                                    MYLog(@"锦囊的评论数为0");
                                                                    successBlock([dic objectForKey:@"data"]);
                                                                }
                                                                else if (failedBlock)
                                                                {
                                                                    failedBlock();
                                                                }
                                                            }
                                                            else
                                                            {
                                                                NSArray *array = [[dic objectForKey:@"data"] objectForKey:@"comments"];
                                                                if(array && array.count == 0)
                                                                {
                                                                    MYLog(@"锦囊的评论数为0");
                                                                }
                                                                NSArray *array_ = [[[QYGuideComment sharedQYGuideComment] produceData:array] retain];
                                                                successBlock(array_);
                                                                [array_ release];
                                                            }
                                                        }
                                                    }
                                                     failed:^{
                                                         if (failedBlock)
                                                         {
                                                             failedBlock();
                                                         }
                                                     }];
}
-(NSArray *)produceData:(NSArray *)array
{
    NSMutableArray *array_guideComment = [[NSMutableArray alloc] init];
    if(array && array.count == 0)
    {
        return [array_guideComment autorelease];
    }
    
    for(int i = 0; i < array.count; i++)
    {
        NSDictionary *dic = [array objectAtIndex:i];
        QYGuideComment *guideComment = [[QYGuideComment alloc] init];
        guideComment.str_commentId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]];
        guideComment.str_userId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"uid"]];
        guideComment.str_userName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"username"]];
        guideComment.str_content = [NSString stringWithFormat:@"%@",[dic objectForKey:@"content"]];
        guideComment.str_userAvatar = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar"]];
        guideComment.str_commentTime = [NSString stringWithFormat:@"%@",[dic objectForKey:@"addtime"]];
        [array_guideComment addObject:guideComment];
        [guideComment release];
    }
    return [array_guideComment autorelease];
}

@end
