//
//  UserItinerary.m
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-10.
//
//

#import "UserItinerary.h"

@implementation UserItinerary
@synthesize itineraryCost = _itineraryCost;
@synthesize itineraryDays = _itineraryDays;
@synthesize itineraryId = _itineraryId;
@synthesize itineraryImageLink = _itineraryImageLink;
@synthesize itineraryLinkString = _itineraryLinkString;
@synthesize itineraryPath_desc = _itineraryPath_desc;
@synthesize itineraryPlannerName = _itineraryPlannerName;
@synthesize itineraryUpdateTime = _itineraryUpdateTime;
@synthesize userName = _userName;
@synthesize userIcon = _userIcon;


-(void)dealloc
{
    self.itineraryCost = nil;
    self.itineraryDays = nil;
    self.itineraryId = nil;
    self.itineraryImageLink = nil;
    self.itineraryLinkString = nil;
    self.itineraryPath_desc = nil;
    self.itineraryPlannerName = nil;
    self.itineraryUpdateTime = nil;
    self.userName = nil;
    self.userIcon = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark --- NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self != nil)
    {
        self.itineraryCost = [aDecoder decodeObjectForKey:@"itineraryCost"];
        self.itineraryDays = [aDecoder decodeObjectForKey:@"itineraryDays"];
        self.itineraryId = [aDecoder decodeObjectForKey:@"itineraryId"];
        self.itineraryImageLink = [aDecoder decodeObjectForKey:@"itineraryImageLink"];
        self.itineraryLinkString = [aDecoder decodeObjectForKey:@"itineraryLinkString"];
        self.itineraryPath_desc = [aDecoder decodeObjectForKey:@"itineraryPath_desc"];
        self.itineraryPlannerName = [aDecoder decodeObjectForKey:@"itineraryPlannerName"];
        self.itineraryUpdateTime = [aDecoder decodeObjectForKey:@"itineraryUpdateTime"];
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.userIcon = [aDecoder decodeObjectForKey:@"userIcon"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.itineraryCost forKey:@"itineraryCost"];
    [aCoder encodeObject:self.itineraryDays forKey:@"itineraryDays"];
    [aCoder encodeObject:self.itineraryId forKey:@"itineraryId"];
    [aCoder encodeObject:self.itineraryImageLink forKey:@"itineraryImageLink"];
    [aCoder encodeObject:self.itineraryLinkString forKey:@"itineraryLinkString"];
    [aCoder encodeObject:self.itineraryPath_desc forKey:@"itineraryPath_desc"];
    [aCoder encodeObject:self.itineraryPlannerName forKey:@"itineraryPlannerName"];
    [aCoder encodeObject:self.itineraryUpdateTime forKey:@"itineraryUpdateTime"];
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.userIcon forKey:@"userIcon"];
}


@end
