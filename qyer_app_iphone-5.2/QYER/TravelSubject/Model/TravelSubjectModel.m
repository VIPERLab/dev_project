//
//  TravelSubjectModel.m
//  QYER
//
//  Created by chenguanglin on 14-7-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "TravelSubjectModel.h"

@implementation TravelSubjectModel


+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.ID = dict[@"id"];
        self.title = dict[@"title"];
        self.photo = dict[@"photo"];
        self.userName = dict[@"username"];
        self.avatar = dict[@"avatar"];
        self.description = dict[@"description"];
        self.count = dict[@"count"];
    }
    return self;
}
@end
