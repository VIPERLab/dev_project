//
//  Account.h
//  QYER
//
//  Created by 我去 on 14-5-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject
{
    NSString    *_access_token;     //密钥令牌
    NSInteger   _expires_in;        //令牌过期时间
    NSString    *_scope;            //授权范围
    NSInteger   _user_id;
    NSString    *_im_user_id;       //IM 用户 id
    NSString    *_username;
    NSInteger   _gender;
    NSString    *_title;            //头衔	1袋长老
    NSString    *_avatar;           //头像	http 链接
    NSString    *_cover;            //头图	http 链接
}

@property(nonatomic,retain) NSString    *access_token;     //密钥令牌
@property(nonatomic,assign) NSInteger   expires_in;        //令牌过期时间
@property(nonatomic,retain) NSString    *scope;            //授权范围
@property(nonatomic,assign) NSInteger   user_id;
@property(nonatomic,retain) NSString    *im_user_id;       //IM 用户 id
@property(nonatomic,retain) NSString    *username;
@property(nonatomic,assign) NSInteger   gender;
@property(nonatomic,retain) NSString    *title;            //头衔	1袋长老
@property(nonatomic,retain) NSString    *avatar;           //头像	http 链接
@property(nonatomic,retain) NSString    *cover;            //头图	http 链接

+(id)sharedAccount;
-(void)initAccountWithDic:(NSDictionary *)dic;
-(void)initAccountWhenThirdLoginWithDic:(NSDictionary *)dic;

@end
