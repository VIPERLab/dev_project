//
//  PoiComment.h
//  QYGuide
//
//  Created by 我去 on 14-2-10.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoiComment : NSObject <NSCoding>
{
    NSString    *_str_userImageUrl;     //用户头像👦
    NSString    *_name_user;            //用户名称
    NSString    *_rate_user;            //用户评星
    NSString    *_commentTime_user;     //用户评论时间
    NSString    *_comment_user;         //用户的评论
    NSString    *_commentId_user;       //用户的评论id
    NSString    *_str_commentHeight;    //评论的高度
}

@property(nonatomic,retain) NSString    *str_userImageUrl;
@property(nonatomic,retain) NSString    *name_user;
@property(nonatomic,retain) NSString    *rate_user;
@property(nonatomic,retain) NSString    *commentTime_user;
@property(nonatomic,retain) NSString    *comment_user;
@property(nonatomic,retain) NSString    *commentId_user;
@property(nonatomic,retain) NSString    *str_commentHeight;

@end

