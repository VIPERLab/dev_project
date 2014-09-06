//
//  PlaceSearchModel.m
//  QYER
//
//  Created by Frank on 14-4-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PlaceSearchModel.h"

@implementation PlaceSearchModel

- (id)initWithDictionary:(NSDictionary *)item
{
    self = [super initWithDictionary:item];
    if (self) {
        self.modelId = item[@"id"];
    }
    return self;
}
@end
