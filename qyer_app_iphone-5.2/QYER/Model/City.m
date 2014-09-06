//
//  City.m
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import "City.h"

@implementation City
@synthesize str_cityId = _str_cityId;
@synthesize str_countryId = _str_countryId;
@synthesize chineseName = _chineseName;
@synthesize englishName = _englishName;
@synthesize str_albumCover = _str_albumCover;
@synthesize str_imagesCount = _str_imagesCount;
@synthesize str_hotelUrl = _str_hotelUrl;
@synthesize str_PracticalGuideUrl = _str_PracticalGuideUrl;
@synthesize str_guideFlag = _str_guideFlag;
@synthesize str_hotFlag = _str_hotFlag;

@synthesize photoArray = _photoArray;
-(void)dealloc
{
    self.chineseName = nil;
    self.englishName = nil;
    self.str_cityId = nil;
    self.str_countryId = nil;
    self.str_albumCover = nil;
    self.str_imagesCount = nil;
    self.str_hotelUrl = nil;
    self.str_PracticalGuideUrl = nil;
    self.str_guideFlag = nil;
    self.str_hotFlag = nil;
    
    self.photoArray = nil;
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.chineseName = [aDecoder decodeObjectForKey:_chineseName];
        self.englishName = [aDecoder decodeObjectForKey:_englishName];
        self.str_cityId = [aDecoder decodeObjectForKey:_str_cityId];
        self.str_countryId = [aDecoder decodeObjectForKey:_str_countryId];
        self.str_albumCover = [aDecoder decodeObjectForKey:_str_albumCover];
        self.str_imagesCount = [aDecoder decodeObjectForKey:_str_imagesCount];
        self.str_hotelUrl = [aDecoder decodeObjectForKey:_str_hotelUrl];
        self.str_PracticalGuideUrl = [aDecoder decodeObjectForKey:_str_PracticalGuideUrl];
        self.str_guideFlag = [aDecoder decodeObjectForKey:_str_guideFlag];
        self.str_hotFlag = [aDecoder decodeObjectForKey:_str_hotFlag];
        
        self.photoArray = [aDecoder decodeObjectForKey:@"photoArray"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.chineseName forKey:_chineseName];
    [aCoder encodeObject:self.englishName forKey:_englishName];
    [aCoder encodeObject:self.str_cityId forKey:_str_cityId];
    [aCoder encodeObject:self.str_countryId forKey:_str_countryId];
    [aCoder encodeObject:self.str_albumCover forKey:_str_albumCover];
    [aCoder encodeObject:self.str_imagesCount forKey:_str_imagesCount];
    [aCoder encodeObject:self.str_hotelUrl forKey:_str_hotelUrl];
    [aCoder encodeObject:self.str_PracticalGuideUrl forKey:_str_PracticalGuideUrl];
    [aCoder encodeObject:self.str_guideFlag forKey:_str_guideFlag];
    [aCoder encodeObject:self.str_hotFlag forKey:_str_hotFlag];
    
    [aCoder encodeObject:self.photoArray forKey:@"photoArray"];
}

@end
