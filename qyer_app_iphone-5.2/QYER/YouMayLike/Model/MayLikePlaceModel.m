//
//  MayLikePlaceModel.m
//  QYER
//
//  Created by chenguanglin on 14-7-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "MayLikePlaceModel.h"

@implementation MayLikePlaceModel

+ (instancetype)placeModeWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.title = dict[@"title"];
        self.photo = dict[@"photo"];
        self.ID = [dict[@"id"] intValue];
    }
    return self;
}
//"id": "1456",
//"photo": "http://site.qyer.com/uploadfile/2014/0527/20140527015516721.jpg",
//"title": "四日游乐只为边走边吃",
//"user_id": "182328",
//"username": "牛牛安",
//"avatar": "http://static.qyer.com/images/user2/avatar/big4.png",
//"description": "打着“最后一个二字头生日”的大旗帜，去新加坡庆生，来去匆匆，四天时间。好吃好喝不耽误~",
//"count": 4,
@end
