//
//  WantGo.m
//  QYER
//
//  Created by 我去 on 14-5-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "WantGo.h"

@implementation WantGo
@synthesize country_cn = _country_cn;
@synthesize country_en = _country_en;
@synthesize country_idstring = _country_idstring;
@synthesize array_cityInfo = _array_cityInfo;


-(void)dealloc
{
    QY_SAFE_RELEASE(_country_cn);
    QY_SAFE_RELEASE(_country_en);
    QY_SAFE_RELEASE(_country_idstring);
    QY_MUTABLERECEPTACLE_RELEASE(_array_cityInfo);
    
    [super dealloc];
}

-(id)init
{
    self = [super init];
    if(self)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        self.array_cityInfo = array;
        [array release];
    }
    return self;
}


@end
