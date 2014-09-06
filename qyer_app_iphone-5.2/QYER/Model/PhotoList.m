//
//  PhotoList.m
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PhotoList.h"

@implementation PhotoList
@synthesize str_photoid;     //图片id
@synthesize str_uid;         //用户id
@synthesize str_username;    //用户名
@synthesize str_photourl;    //图片地址
@synthesize str_avatar;      //用户头像
@synthesize str_datetime;    //上传时间


-(void)dealloc
{
    self.str_photoid = nil;     //图片id
    self.str_uid = nil;         //用户id
    self.str_username = nil;    //用户名
    self.str_photourl = nil;    //图片地址
    self.str_avatar = nil;      //用户头像
    self.str_datetime = nil;
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.str_photoid = [aDecoder decodeObjectForKey:_str_photoid];
        self.str_uid = [aDecoder decodeObjectForKey:_str_uid];
        self.str_username = [aDecoder decodeObjectForKey:_str_username];
        self.str_photourl = [aDecoder decodeObjectForKey:_str_photourl];
        self.str_avatar = [aDecoder decodeObjectForKey:_str_avatar];
        self.str_datetime = [aDecoder decodeObjectForKey:_str_datetime];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.str_photoid forKey:_str_photoid];
    [aCoder encodeObject:self.str_uid forKey:_str_uid];
    [aCoder encodeObject:self.str_username forKey:_str_username];
    [aCoder encodeObject:self.str_photourl forKey:_str_photourl];
    [aCoder encodeObject:self.str_avatar forKey:_str_avatar];
    [aCoder encodeObject:self.str_datetime forKey:_str_datetime];
}

@end
