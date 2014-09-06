//
//  HotPlace.m
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "HotPlace.h"

@implementation HotPlace
@synthesize str_placeId = _str_placeId;
@synthesize str_placeCatename = _str_placeCatename;
@synthesize str_placePhoto = _str_placePhoto;


-(void)dealloc
{
    self.str_placePhoto = nil;
    self.str_placeId = nil;
    self.str_placeCatename = nil;
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.str_placePhoto = [aDecoder decodeObjectForKey:_str_placePhoto];
        self.str_placeId = [aDecoder decodeObjectForKey:_str_placeId];
        self.str_placeCatename = [aDecoder decodeObjectForKey:_str_placeCatename];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.str_placePhoto forKey:_str_placePhoto];
    [aCoder encodeObject:self.str_placeId forKey:_str_placeId];
    [aCoder encodeObject:self.str_placeCatename forKey:_str_placeCatename];
}

@end
