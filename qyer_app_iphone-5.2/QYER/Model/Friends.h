//
//  Friends.h
//  QYER
//
//  Created by 我去 on 14-5-12.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friends : NSObject
{
    NSInteger   _user_id;       //用户 id
    NSString    *_im_user_id;   //IM 用户 id
    NSInteger   _age;
    NSString    *_username;     //昵称
    NSInteger   _gender;        //性别   0/1/2: 保密/男/女
    NSString    *_avatar;       //头像   http 链接
    BOOL        _both_follow;   //是否相互关注	true/false: 是/否
    NSInteger   _countries;     //去过的国家数量
    NSInteger   _cities;        //去过的城市数量
}

@property(nonatomic,assign) NSInteger   user_id;       //用户 id
@property(nonatomic,retain) NSString    *im_user_id;   //IM 用户 id
@property(nonatomic,assign) NSInteger   age;
@property(nonatomic,retain) NSString    *username;     //昵称
@property(nonatomic,assign) NSInteger   gender;        //性别   0/1/2: 保密/男/女
@property(nonatomic,retain) NSString    *avatar;       //头像   http 链接
@property(nonatomic,assign) BOOL        both_follow;   //是否相互关注	true/false: 是/否
@property(nonatomic,assign) NSInteger   countries;     //去过的国家数量
@property(nonatomic,assign) NSInteger   cities;        //去过的城市数量

@end
