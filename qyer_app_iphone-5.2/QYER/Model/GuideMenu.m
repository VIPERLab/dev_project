//
//  GuideMenu.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-10.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GuideMenu.h"


@implementation GuideMenu
@synthesize str_pageNumber = _str_pageNumber;
@synthesize title_menu = _title_menu;
@synthesize str_titleHeight = _str_titleHeight;


-(void)dealloc
{
    self.str_pageNumber = nil;
    self.title_menu = nil;
    self.str_titleHeight = nil;
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self != nil)
    {
        self.str_pageNumber = [aDecoder decodeObjectForKey:@"str_pageNumber"];
        self.title_menu = [aDecoder decodeObjectForKey:@"title_menu"];
        self.str_titleHeight = [aDecoder decodeObjectForKey:@"str_titleHeight"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_str_pageNumber forKey:@"str_pageNumber"];
    [aCoder encodeObject:_title_menu forKey:@"title_menu"];
    [aCoder encodeObject:_str_titleHeight forKey:@"str_titleHeight"];
}


@end
