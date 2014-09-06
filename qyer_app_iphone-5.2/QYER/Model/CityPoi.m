//
//  CityPoi.m
//  QyGuide
//
//  Created by 我去 on 14-3-10.
//
//

#import "CityPoi.h"

@implementation CityPoi
@synthesize str_poiChineseName = _str_poiChineseName;
@synthesize str_poiEnglishName = _str_poiEnglishName;
@synthesize str_poiLocalName = _str_poiLocalName;
@synthesize str_poiId = _str_poiId;
@synthesize str_albumCover = _str_albumCover;
@synthesize str_lat = _str_lat;
@synthesize str_lng = _str_lng;
@synthesize str_wantGo = _str_wantGo;
@synthesize str_comprehensiveRating = _str_comprehensiveRating;
@synthesize str_comprehensiveEvaluation = _str_comprehensiveEvaluation;
@synthesize str_recommendscores = _str_recommendscores;
@synthesize str_recommendstr = _str_recommendstr;
@synthesize str_distance = _str_distance;
@synthesize str_hotFlag = _str_hotFlag;

-(void)dealloc
{
    self.str_poiChineseName = nil;
    self.str_poiEnglishName = nil;
    self.str_poiLocalName = nil;
    self.str_poiId = nil;
    self.str_albumCover = nil;
    self.str_lat = nil;
    self.str_lng = nil;
    self.str_wantGo = nil;
    self.str_comprehensiveRating = nil;
    self.str_comprehensiveEvaluation = nil;
    self.str_recommendstr = nil;
    self.str_recommendscores = nil;
    self.str_distance = nil;
    self.str_hotFlag = nil;
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.str_poiChineseName = [aDecoder decodeObjectForKey:_str_poiChineseName];
        self.str_poiEnglishName = [aDecoder decodeObjectForKey:_str_poiEnglishName];
        self.str_poiLocalName = [aDecoder decodeObjectForKey:_str_poiLocalName];
        self.str_poiId = [aDecoder decodeObjectForKey:_str_poiId];
        self.str_albumCover = [aDecoder decodeObjectForKey:_str_albumCover];
        self.str_lat = [aDecoder decodeObjectForKey:_str_lat];
        self.str_lng = [aDecoder decodeObjectForKey:_str_lng];
        self.str_wantGo = [aDecoder decodeObjectForKey:_str_wantGo];
        self.str_comprehensiveRating = [aDecoder decodeObjectForKey:_str_comprehensiveRating];
        self.str_comprehensiveEvaluation = [aDecoder decodeObjectForKey:_str_comprehensiveEvaluation];
        self.str_recommendstr = [aDecoder decodeObjectForKey:_str_recommendstr];
        self.str_recommendscores = [aDecoder decodeObjectForKey:_str_recommendscores];
        
        self.str_hotFlag = [aDecoder decodeObjectForKey:_str_hotFlag];
        self.str_distance = [aDecoder decodeObjectForKey:_str_distance];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.str_poiChineseName forKey:_str_poiChineseName];
    [aCoder encodeObject:self.str_poiEnglishName forKey:_str_poiEnglishName];
    [aCoder encodeObject:self.str_poiLocalName forKey:_str_poiLocalName];
    [aCoder encodeObject:self.str_albumCover forKey:_str_albumCover];
    [aCoder encodeObject:self.str_poiId forKey:_str_poiId];
    [aCoder encodeObject:self.str_albumCover forKey:_str_albumCover];
    [aCoder encodeObject:self.str_lat forKey:_str_lat];
    [aCoder encodeObject:self.str_lng forKey:_str_lng];
    [aCoder encodeObject:self.str_wantGo forKey:_str_wantGo];
    [aCoder encodeObject:self.str_comprehensiveRating forKey:_str_comprehensiveRating];
    [aCoder encodeObject:self.str_comprehensiveEvaluation forKey:_str_comprehensiveEvaluation];
    [aCoder encodeObject:self.str_recommendstr forKey:_str_recommendstr];
    [aCoder encodeObject:self.str_recommendscores forKey:_str_recommendscores];
    
    [aCoder encodeObject:self.str_hotFlag forKey:_str_hotFlag];
    [aCoder encodeObject:self.str_distance forKey:_str_distance];
}

@end

