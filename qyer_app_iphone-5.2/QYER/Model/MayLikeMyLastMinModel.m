//
//  MayLikeMyLastMinModel.m
//  QYER
//
//  Created by chenguanglin on 14-7-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "MayLikeMyLastMinModel.h"

@implementation MayLikeMyLastMinModel
+ (instancetype)ModeWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.title = dict[@"title"];
        self.photo = dict[@"photo"];
        self.price = dict[@"price"];
        self.expire_date = dict[@"expire_date"];
        self.ID = [dict[@"id"] intValue];
    }
    return self;
}

//"id": "4406",
//"title": "测试折扣详情",
//"price": "2000 元起",
//"expire_date": "2014.04.16 结束",
//"photo": "http://static.qyer.com/upload/mobile/operation/db/18/db1895f1be9df943d2e1c128eff35aa6.jpg",
//"big_pic": "http://static.qyer.com/upload/mobile/op
@end
