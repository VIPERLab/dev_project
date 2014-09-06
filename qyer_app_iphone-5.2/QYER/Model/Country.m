//
//  Country.m
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import "Country.h"


@implementation Country
@synthesize chineseName = _chineseName;
@synthesize englishName = _englishName;
@synthesize str_countryId = _str_countryId;
@synthesize str_albumCover = _str_albumCover;
@synthesize str_imagesCount = _str_imagesCount;
@synthesize str_lastMinuteFlag = _str_lastMinuteFlag;
@synthesize str_PracticalGuide_url = _str_PracticalGuide_url;
@synthesize str_isguideFlag = _str_isguideFlag;
@synthesize str_hotFlag = _str_hotFlag;

@synthesize photoArray = _photoArray;

-(void)dealloc
{
    self.chineseName = nil;
    self.englishName = nil;
    self.str_countryId = nil;
    self.str_albumCover = nil;
    self.str_imagesCount = nil;
    self.str_lastMinuteFlag = nil;
    self.str_PracticalGuide_url = nil;
    self.str_isguideFlag = nil;
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
        self.str_countryId = [aDecoder decodeObjectForKey:_str_countryId];
        self.str_albumCover = [aDecoder decodeObjectForKey:_str_albumCover];
        self.str_imagesCount = [aDecoder decodeObjectForKey:_str_imagesCount];
        self.str_lastMinuteFlag = [aDecoder decodeObjectForKey:_str_lastMinuteFlag];
        self.str_PracticalGuide_url = [aDecoder decodeObjectForKey:_str_PracticalGuide_url];
        self.str_isguideFlag = [aDecoder decodeObjectForKey:_str_isguideFlag];
        self.str_hotFlag = [aDecoder decodeObjectForKey:_str_hotFlag];
        
        self.photoArray = [aDecoder decodeObjectForKey:@"photoArray"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.chineseName forKey:_chineseName];
    [aCoder encodeObject:self.englishName forKey:_englishName];
    [aCoder encodeObject:self.str_countryId forKey:_str_countryId];
    [aCoder encodeObject:self.str_albumCover forKey:_str_albumCover];
    [aCoder encodeObject:self.str_imagesCount forKey:_str_imagesCount];
    [aCoder encodeObject:self.str_lastMinuteFlag forKey:_str_lastMinuteFlag];
    [aCoder encodeObject:self.str_PracticalGuide_url forKey:_str_PracticalGuide_url];
    [aCoder encodeObject:self.str_isguideFlag forKey:_str_isguideFlag];
    [aCoder encodeObject:self.str_hotFlag forKey:_str_hotFlag];
    
    [aCoder encodeObject:self.photoArray forKey:@"photoArray"];

}

@end
