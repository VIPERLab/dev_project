//
//  Plan.m
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import "Plan.h"


@implementation Plan
@synthesize str_planId = _str_planId;
@synthesize str_planName = _str_planName;
@synthesize str_planAlbumCover = _str_planAlbumCover;
@synthesize str_planRoute = _str_planRoute;
@synthesize str_planDays = _str_planDays;
@synthesize str_planBelongTo = _str_planBelongTo;
@synthesize str_planUpdateTime = _str_planUpdateTime;
@synthesize str_planUrl = _str_planUrl;

@synthesize str_avatar = _str_avatar;

-(void)dealloc
{
    self.str_planId = nil;
    self.str_planName = nil;
    self.str_planAlbumCover = nil;
    self.str_planRoute = nil;
    self.str_planDays = nil;
    self.str_planBelongTo = nil;
    self.str_planUpdateTime = nil;
    self.str_planUrl = nil;
    
    self.str_avatar = nil;
    [super dealloc];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.str_planId = [aDecoder decodeObjectForKey:_str_planId];
        self.str_planName = [aDecoder decodeObjectForKey:_str_planName];
        self.str_planAlbumCover = [aDecoder decodeObjectForKey:_str_planAlbumCover];
        self.str_planRoute = [aDecoder decodeObjectForKey:_str_planRoute];
        self.str_planDays = [aDecoder decodeObjectForKey:_str_planDays];
        self.str_planBelongTo = [aDecoder decodeObjectForKey:_str_planBelongTo];
        self.str_planUpdateTime = [aDecoder decodeObjectForKey:_str_planUpdateTime];
        self.str_planUrl = [aDecoder decodeObjectForKey:_str_planUrl];
        
        self.str_avatar = [aDecoder decodeObjectForKey:_str_avatar];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.str_planId forKey:_str_planId];
    [aCoder encodeObject:self.str_planName forKey:_str_planName];
    [aCoder encodeObject:self.str_planAlbumCover forKey:_str_planAlbumCover];
    [aCoder encodeObject:self.str_planRoute forKey:_str_planRoute];
    [aCoder encodeObject:self.str_planDays forKey:_str_planDays];
    [aCoder encodeObject:self.str_planBelongTo forKey:_str_planBelongTo];
    [aCoder encodeObject:self.str_planUpdateTime forKey:_str_planUpdateTime];
    [aCoder encodeObject:self.str_planUrl forKey:_str_planUrl];
    
    [aCoder encodeObject:self.str_avatar forKey:_str_avatar];

}

@end
