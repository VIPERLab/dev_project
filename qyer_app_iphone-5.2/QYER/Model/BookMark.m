//
//  BookMark.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-12.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "BookMark.h"



@implementation BookMark
@synthesize str_bookMarkTitle = _str_bookMarkTitle;
@synthesize str_guideHtmlInfoPath = _str_guideHtmlInfoPath;
@synthesize str_guideName = _str_guideName;
@synthesize str_bookMarkPageNumber = _str_bookMarkPageNumber;

-(void)dealloc
{
    self.str_guideName = nil;
    self.str_guideHtmlInfoPath = nil;
    self.str_bookMarkTitle = nil;
    self.str_bookMarkPageNumber = nil;
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self != nil)
    {
        self.str_bookMarkTitle = [aDecoder decodeObjectForKey:@"str_bookMarkTitle"];
        self.str_guideHtmlInfoPath = [aDecoder decodeObjectForKey:@"str_guideHtmlInfoPath"];
        self.str_guideName = [aDecoder decodeObjectForKey:@"str_guideName"];
        self.str_bookMarkPageNumber = [aDecoder decodeObjectForKey:@"str_bookMarkPageNumber"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_str_bookMarkTitle forKey:@"str_bookMarkTitle"];
    [aCoder encodeObject:_str_guideHtmlInfoPath forKey:@"str_guideHtmlInfoPath"];
    [aCoder encodeObject:_str_guideName forKey:@"str_guideName"];
    [aCoder encodeObject:_str_bookMarkPageNumber forKey:@"str_bookMarkPageNumber"];
}

@end


