//
//  QYMoreApp.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-15.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "QYMoreApp.h"


@implementation QYMoreApp
@synthesize appAppStoreURL = _appAppStoreURL;
@synthesize appName = _appName;
@synthesize appPicUrl = _appPicUrl;
@synthesize apptitle = _apptitle;
@synthesize appVersion = _appVersion;
@synthesize array_app = _array_app;

-(void)dealloc
{
    QY_SAFE_RELEASE(_appAppStoreURL);
    QY_SAFE_RELEASE(_appName);
    QY_SAFE_RELEASE(_appPicUrl);
    QY_SAFE_RELEASE(_apptitle);
    QY_SAFE_RELEASE(_appVersion);
    QY_SAFE_RELEASE(_array_app);
    
    [super dealloc];
}

-(id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}


#pragma mark -
#pragma mark --- NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self != nil)
    {
        self.appAppStoreURL = [aDecoder decodeObjectForKey:@"appAppStoreURL"];
        self.appName = [aDecoder decodeObjectForKey:@"appName"];
        self.appPicUrl = [aDecoder decodeObjectForKey:@"appPicUrl"];
        self.apptitle = [aDecoder decodeObjectForKey:@"apptitle"];
        self.appVersion = [aDecoder decodeObjectForKey:@"appVersion"];
        self.array_app = [aDecoder decodeObjectForKey:@"array_app"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.appAppStoreURL forKey:@"appAppStoreURL"];
    [aCoder encodeObject:self.appName forKey:@"appName"];
    [aCoder encodeObject:self.appPicUrl forKey:@"appPicUrl"];
    [aCoder encodeObject:self.apptitle forKey:@"apptitle"];
    [aCoder encodeObject:self.appVersion forKey:@"appVersion"];
    [aCoder encodeObject:self.array_app forKey:@"array_app"];
}

@end
