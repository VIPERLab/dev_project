//
//  TSDetailCellModel.m
//  TravelSubject
//
//  Created by chenguanglin on 14-7-21.
//  Copyright (c) 2014年 chenguanglin. All rights reserved.
//

#import "TSDetailCellModel.h"

@interface TSDetailCellModel()



@end

@implementation TSDetailCellModel
+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.ID = dict[@"id"];
        if (![dict[@"localname"] isEqualToString:@""]) {
            self.title = dict[@"localname"];
        }
        if (![dict[@"secondname"] isEqualToString:@""]) {
            self.title = dict[@"secondname"];
        }
        if (![dict[@"firstname"] isEqualToString:@""]) {
            self.title = dict[@"firstname"];
        };
        self.photo = dict[@"photo"];
        self.countryName = dict[@"countryname"];
        self.cityName = dict[@"cityname"];
        self.description = dict[@"description"];
        self.recommandstar = [dict[@"recommandstar"] floatValue] / 2;
    }
    return self;
}
@end
