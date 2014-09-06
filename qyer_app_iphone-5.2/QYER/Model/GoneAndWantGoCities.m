//
//  GoneAndWantGoCities.m
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GoneAndWantGoCities.h"

@implementation GoneAndWantGoCities
@synthesize city_cn = _city_cn;
@synthesize city_en = _city_en;
@synthesize city_idstring = _city_idstring;
@synthesize array_poiInfo = _array_poiInfo;


-(void)dealloc
{
    QY_SAFE_RELEASE(_city_cn);
    QY_SAFE_RELEASE(_city_cn);
    QY_SAFE_RELEASE(_city_idstring);
    QY_MUTABLERECEPTACLE_RELEASE(_array_poiInfo);
    
    [super dealloc];
}

-(id)init
{
    self = [super init];
    if(self)
    {
        _array_poiInfo = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
