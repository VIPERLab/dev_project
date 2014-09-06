//
//  CityList.m
//  QYER
//
//  Created by 我去 on 14-3-19.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CityList.h"

@implementation CityList
@synthesize str_id = _str_id;
@synthesize str_catename = _str_catename;
@synthesize str_catename_en = _str_catename_en;
@synthesize str_photo = _str_photo;
@synthesize str_lat = _str_lat;
@synthesize str_lng = _str_lng;
@synthesize str_wantstr = _str_wantstr;
@synthesize str_ishot = _str_ishot;


-(void)dealloc
{
    self.str_id = nil;
    self.str_catename = nil;
    self.str_catename_en = nil;
    self.str_photo = nil;
    self.str_lat = nil;
    self.str_lng = nil;
    self.str_wantstr = nil;
    self.str_ishot = nil;
    
    //********** Insert By ZhangDong 2014.3.31 Start **********
    
    self.beenstr = nil;
    self.recommendstr = nil;
    self.representative = nil;
    //********** Insert By ZhangDong 2014.3.31 End **********
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.str_id = [aDecoder decodeObjectForKey:@"id"];
        self.str_catename = [aDecoder decodeObjectForKey:@"catename"];
        self.str_catename_en = [aDecoder decodeObjectForKey:@"catename_en"];
        self.str_photo = [aDecoder decodeObjectForKey:@"photo"];
        self.str_lat = [aDecoder decodeObjectForKey:@"lat"];
        self.str_lng = [aDecoder decodeObjectForKey:@"lng"];
        self.str_wantstr = [aDecoder decodeObjectForKey:@"wantstr"];
        self.str_ishot = [aDecoder decodeObjectForKey:@"ishot"];
        
        //********** Insert By ZhangDong 2014.4.1 Start **********
        self.beennumber = [aDecoder decodeIntegerForKey:@"beennumber"];
        self.beenstr = [aDecoder decodeObjectForKey:@"beenstr"];
        self.recommendnumber = [aDecoder decodeIntegerForKey:@"recommendnumber"];
        self.recommendscores = [aDecoder decodeIntegerForKey:@"recommendscores"];
        self.recommendstr = [aDecoder decodeObjectForKey:@"recommendstr"];
        self.representative = [aDecoder decodeObjectForKey:@"representative"];
        //********** Insert By ZhangDong 2014.4.1 End **********
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.str_id forKey:@"id"];
    [aCoder encodeObject:self.str_catename forKey:@"catename"];
    [aCoder encodeObject:self.str_catename_en forKey:@"catename_en"];
    [aCoder encodeObject:self.str_photo forKey:@"photo"];
    [aCoder encodeObject:self.str_lat forKey:@"lat"];
    [aCoder encodeObject:self.str_lng forKey:@"lng"];
    [aCoder encodeObject:self.str_wantstr forKey:@"wantstr"];
    [aCoder encodeObject:self.str_ishot forKey:@"ishot"];
    
    //********** Insert By ZhangDong 2014.4.1 Start **********
    [aCoder encodeInteger:self.beennumber forKey:@"beennumber"];
    [aCoder encodeObject:self.beenstr forKey:@"beenstr"];
    [aCoder encodeInteger:self.recommendnumber forKey:@"recommendnumber"];
    [aCoder encodeInteger:self.recommendscores forKey:@"recommendscores"];
    [aCoder encodeObject:self.recommendstr forKey:@"recommendstr"];
    [aCoder encodeObject:self.representative forKey:@"representative"];
    //********** Insert By ZhangDong 2014.4.1 End **********
}


@end
