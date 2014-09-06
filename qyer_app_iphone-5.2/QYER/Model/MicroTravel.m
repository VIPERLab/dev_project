//
//  MicroTravel.m
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import "MicroTravel.h"

@implementation MicroTravel
@synthesize str_travelId = _str_travelId;
@synthesize str_travelName = _str_travelName;
@synthesize str_travelAlbumCover = _str_travelAlbumCover;
@synthesize str_browserCount = _str_browserCount;
@synthesize str_commentCount = _str_commentCount;
@synthesize str_likeCount = _str_likeCount;
@synthesize str_travelBelongTo = _str_travelBelongTo;
@synthesize str_travelUpdateTime = _str_travelUpdateTime;
@synthesize str_travelUrl_all = _str_travelUrl_all;
@synthesize str_travelUrl_onlyauthor = _str_travelUrl_onlyauthor;
@synthesize str_userId = _str_userId;

@synthesize str_avatarUrl = _str_avatarUrl;
-(void)dealloc
{
    self.str_travelId = nil;
    self.str_travelName = nil;
    self.str_travelAlbumCover = nil;
    self.str_browserCount = nil;
    self.str_commentCount = nil;
    self.str_likeCount = nil;
    self.str_travelBelongTo = nil;
    self.str_travelUpdateTime = nil;
    self.str_travelUrl_all = nil;
    self.str_travelUrl_onlyauthor = nil;
    
    self.str_avatarUrl = nil;
    self.str_userId = nil;
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.str_travelId = [aDecoder decodeObjectForKey:_str_travelId];
        self.str_travelName = [aDecoder decodeObjectForKey:_str_travelName];
        self.str_travelAlbumCover = [aDecoder decodeObjectForKey:_str_travelAlbumCover];
        self.str_browserCount = [aDecoder decodeObjectForKey:_str_browserCount];
        self.str_commentCount = [aDecoder decodeObjectForKey:_str_commentCount];
        self.str_likeCount = [aDecoder decodeObjectForKey:_str_likeCount];
        self.str_travelBelongTo = [aDecoder decodeObjectForKey:_str_travelBelongTo];
        self.str_travelUpdateTime = [aDecoder decodeObjectForKey:_str_travelUpdateTime];
        self.str_travelUrl_all = [aDecoder decodeObjectForKey:_str_travelUrl_all];
        self.str_travelUrl_onlyauthor = [aDecoder decodeObjectForKey:_str_travelUrl_onlyauthor];
        
        self.str_avatarUrl = [aDecoder decodeObjectForKey:_str_avatarUrl];
        self.str_userId = [aDecoder decodeObjectForKey:_str_userId];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.str_travelId forKey:_str_travelId];
    [aCoder encodeObject:self.str_travelName forKey:_str_travelName];
    [aCoder encodeObject:self.str_travelAlbumCover forKey:_str_travelAlbumCover];
    [aCoder encodeObject:self.str_browserCount forKey:_str_browserCount];
    [aCoder encodeObject:self.str_commentCount forKey:_str_commentCount];
    [aCoder encodeObject:self.str_likeCount forKey:_str_likeCount];
    [aCoder encodeObject:self.str_travelBelongTo forKey:_str_travelBelongTo];
    [aCoder encodeObject:self.str_travelUpdateTime forKey:_str_travelUpdateTime];
    [aCoder encodeObject:self.str_travelUrl_all forKey:_str_travelUrl_all];
    [aCoder encodeObject:self.str_travelUrl_onlyauthor forKey:_str_travelUrl_onlyauthor];
    
    [aCoder encodeObject:self.str_avatarUrl forKey:_str_avatarUrl];
    [aCoder encodeObject:self.str_userId forKey:_str_userId];
}


@end
