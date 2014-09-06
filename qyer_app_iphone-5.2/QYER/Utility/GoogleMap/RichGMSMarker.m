//
//  RichGMSMarker.m
//  QYGuide
//
//  Created by 你猜你猜 on 13-11-11.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "RichGMSMarker.h"

@implementation RichGMSMarker
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize imageUrlString = _imageUrlString;
@synthesize poiId = _poiId;
@synthesize cateId = _cateId;


-(void)dealloc
{
    self.title = nil;
    self.subtitle = nil;
    self.imageUrlString = nil;
    self.poiId = nil;
    self.cateId = nil;
    
    [super dealloc];
}


-(id)init
{
    self = [super init];
    if(self)
    {
        
    }
    
    return self;
}


#pragma mark -
#pragma mark --- NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{    
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_subtitle forKey:@"subtitle"];
    [aCoder encodeObject:_imageUrlString forKey:@"imageUrlString"];
    [aCoder encodeObject:_poiId forKey:@"poiId"];
    [aCoder encodeObject:_cateId forKey:@"cateId"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self != nil)
    {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.subtitle = [aDecoder decodeObjectForKey:@"subtitle"];
        self.imageUrlString = [aDecoder decodeObjectForKey:@"imageUrlString"];
        self.poiId = [aDecoder decodeObjectForKey:@"poiId"];
        self.cateId = [aDecoder decodeObjectForKey:@"cateId"];
    }
    return self;
}

@end
