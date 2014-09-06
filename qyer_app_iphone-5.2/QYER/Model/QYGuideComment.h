//
//  QYGuideComment.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-21.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^getGuideCommentSuccessBlock)(NSArray *array);
typedef void (^getGuideCommentFailedBlock)(void);

@interface QYGuideComment : NSObject
{
    NSString    *_str_userId;      //用户的id
    NSString    *_str_userName;    //用户名
    NSString    *_str_userAvatar;  //用户的头像
    NSString    *_str_content;     //用户的评论
    NSString    *_str_commentTime; //用户评论时间
    NSString    *_str_commentId;   //用户的评论id
}

@property(nonatomic, retain) NSString *str_commentId;
@property(nonatomic, retain) NSString *str_userId;
@property(nonatomic, retain) NSString *str_userName;
@property(nonatomic, retain) NSString *str_userAvatar;
@property(nonatomic, retain) NSString *str_content;
@property(nonatomic, retain) NSString *str_commentTime;

+(id)sharedQYGuideComment;
-(void)getCommentListByGuideId:(NSInteger)guideId
                         count:(NSInteger)count
                         maxId:(NSInteger)maxId
                       success:(getGuideCommentSuccessBlock)successBlock
                       failure:(getGuideCommentFailedBlock)failedBlock;

@end

