//
//  PhotoList.h
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoList : NSObject <NSCoding>
{
    NSString *_str_photoid;     //图片id
    NSString *_str_uid;         //用户id
    NSString *_str_username;    //用户名
    NSString *_str_photourl;    //图片地址
    NSString *_str_avatar;      //用户头像
    NSString *_str_datetime;    //上传时间
}

@property(nonatomic,retain) NSString *str_photoid;     //图片id
@property(nonatomic,retain) NSString *str_uid;         //用户id
@property(nonatomic,retain) NSString *str_username;    //用户名
@property(nonatomic,retain) NSString *str_photourl;    //图片地址
@property(nonatomic,retain) NSString *str_avatar;      //用户头像
@property(nonatomic,retain) NSString *str_datetime;    //上传时间

@end
