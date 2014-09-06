//
//  UserInfo.h
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseModel.h"

@interface UserInfo : BaseModel
{
    NSInteger   _user_id;           //用户 id
    NSString    *_im_user_id;       //IM 用户 id
    BOOL        _can_dm;            //是否可以发私聊
    NSString    *_username;         //昵称
    NSInteger   _gender;            //性别  (0/1/2: 保密/男/女)
    NSString    *_title;            //头衔  (X袋长老)
    NSString    *_avatar;           //头像
    NSString    *_cover;            //头图
    NSString    *_signingMessages;  //签名
    NSString    *_footprint;        //足迹地图
    NSString    *_follow_status;    //关注状态 (关注TA/已关注/相互关注)
    NSInteger   _fans;              //粉丝数量
    NSInteger   _follow;            //关注数量
    NSInteger   _countries;         //去过的国家数量
    NSInteger   _cities;            //去过的城市数量
    NSInteger   _pois;              //去过的景点数量
    NSInteger   _trips;             //行程数量
    NSInteger   _wants;             //想去的数量
}

@property (nonatomic,assign) NSInteger   user_id;           //用户 id
@property (nonatomic,retain) NSString    *im_user_id;       //IM 用户 id
@property (nonatomic,assign) NSInteger   age;               //年龄
@property (nonatomic,assign) BOOL        can_dm;            //是否可以发私聊
@property (nonatomic,retain) NSString    *username;         //昵称
@property (nonatomic,assign) NSInteger   gender;            //性别  (0/1/2: 保密/男/女)
@property (nonatomic,retain) NSString    *title;            //头衔  (X袋长老)
@property (nonatomic,retain) NSString    *avatar;           //头像
@property (nonatomic,retain) NSString    *cover;            //头图
@property (nonatomic,retain) NSString    *footprint;        //足迹地图
@property (nonatomic,retain) NSString    *follow_status;    //关注状态 (关注 TA/已关注/相互关注)
@property (nonatomic,assign) NSInteger   fans;              //粉丝数量
@property (nonatomic,assign) NSInteger   follow;            //关注数量
@property (nonatomic,assign) NSInteger   countries;         //去过的国家数量
@property (nonatomic,assign) NSInteger   cities;            //去过的城市数量
@property (nonatomic,assign) NSInteger   pois;              //去过的景点数量
@property (nonatomic,assign) NSInteger   trips;             //行程数量
@property (nonatomic,assign) NSInteger   wants;             //想去的数量
@property (nonatomic,retain) NSString    *signingMessages;  //签名

@property (nonatomic, copy)  NSString    *attribute1;   //备用属性1
@property (nonatomic, copy)  NSString    *attribute2;   //备用属性2
@property (nonatomic, copy)  NSString    *attribute3;   //备用属性3
@property (nonatomic,assign) NSInteger   attribute4;    //备用属性4
@property (nonatomic,assign) NSInteger   attribute5;    //备用属性5

@end
