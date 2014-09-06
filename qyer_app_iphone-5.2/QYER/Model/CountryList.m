//
//  CountryList.m
//  QYER
//
//  Created by 我去 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CountryList.h"

@implementation CountryList
@synthesize str_catename;     //中文名称
@synthesize str_catename_en;  //英文名
@synthesize str_photo;        //封面图
@synthesize str_ishot;        //是否热门国家,为true时为热门

-(void)dealloc
{
    self.str_catename = nil;     //中文名称
    self.str_catename_en = nil;  //英文名
    self.str_photo = nil;        //封面图
    self.str_ishot = nil;        //是否热门国家,为true时为热门
    
    //********** Insert By ZhangDong 2014.3.27 Start **********
    self.str_id = nil;
    
    self.label = nil;
    //********** Insert By ZhangDong 2014.3.27 End **********
    
    [super dealloc];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.str_catename = [aDecoder decodeObjectForKey:@"catename"];
        self.str_catename_en = [aDecoder decodeObjectForKey:@"catename_en"];
        self.str_photo = [aDecoder decodeObjectForKey:@"photo"];
        self.str_ishot = [aDecoder decodeObjectForKey:@"ishot"];
        
        //********** Insert By ZhangDong 2014.3.27 Start **********
        self.str_id = [aDecoder decodeObjectForKey:@"pid"];
        
        self.count = [aDecoder decodeIntegerForKey:@"count"];
        self.flag = [aDecoder decodeIntegerForKey:@"flag"];
        self.label = [aDecoder decodeObjectForKey:@"label"];
        //********** Insert By ZhangDong 2014.3.27 End **********
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //********** Mod By ZhangDong 2014.3.31 Start **********
    [aCoder encodeObject:self.str_catename forKey:@"catename"];
    [aCoder encodeObject:self.str_catename_en forKey:@"catename_en"];
    [aCoder encodeObject:self.str_photo forKey:@"photo"];
    [aCoder encodeObject:self.str_ishot forKey:@"ishot"];
    //********** Mod By ZhangDong 2014.3.31 End **********
    
    //********** Insert By ZhangDong 2014.3.27 Start **********
    [aCoder encodeObject:self.str_id forKey:@"pid"];
    
    [aCoder encodeInteger:self.count forKey:@"count"];
    [aCoder encodeInteger:self.flag forKey:@"flag"];
    [aCoder encodeObject:self.label forKey:@"label"];

    //********** Insert By ZhangDong 2014.3.27 End **********
}

//********** Insert By ZhangDong 2014.3.27 Start **********
- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        self.str_id = dict[@"pid"];
        self.str_catename = dict[@"catename"];
        self.str_catename_en = dict[@"catename_en"];
        self.str_photo = dict[@"photo"];
        
        self.flag = [dict[@"flag"] integerValue];
        self.count = [dict[@"count"] integerValue];
        self.label = dict[@"label"];
    }
    return self;
}
//********** Insert By ZhangDong 2014.3.27 End **********
@end
