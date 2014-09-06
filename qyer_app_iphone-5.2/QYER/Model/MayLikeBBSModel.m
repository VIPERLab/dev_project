//
//  MayLikeBBSModel.m
//  QYER
//
//  Created by chenguanglin on 14-7-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "MayLikeBBSModel.h"
//"photo": "http://test1362383214.qiniudn.com/album/user/576/77/RE5TRR0PZQ/index/w800",
//"title": "♣♣♣ 伊比利亚半岛的标杆----西班牙、葡萄牙、安道尔35日自驾之旅 ♣♣♣",
//"user_id": "1217829",
//"username": "梅尔凯奇",
//"avatar": "http://static.qyer.com/images/user2/avatar/big4.png",
//"view_url": "http://appview.qyer.com/bbs/thread-885954-1.html",
@implementation MayLikeBBSModel

+ (instancetype)BBSModeWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.title = dict[@"title"];
        self.photo = dict[@"photo"];
        self.avatar = dict[@"avatar"];
        self.view_url = dict[@"view_url"];
    }
    return self;
}
@end
