//
//  PoiComment.m
//  QYGuide
//
//  Created by 我去 on 14-2-10.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PoiComment.h"

@implementation PoiComment
@synthesize str_userImageUrl = _str_userImageUrl;
@synthesize name_user = _name_user;
@synthesize rate_user = _rate_user;
@synthesize commentTime_user = _commentTime_user;
@synthesize comment_user = _comment_user;
@synthesize str_commentHeight = _str_commentHeight;
@synthesize commentId_user = _commentId_user;

-(void)dealloc
{
    self.str_userImageUrl = nil;
    self.name_user = nil;
    self.rate_user = nil;
    self.commentTime_user = nil;
    self.comment_user = nil;
    self.str_commentHeight = nil;
    self.commentId_user = nil;
    
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
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.str_userImageUrl = [aDecoder decodeObjectForKey:@"str_userImageUrl"];
        self.name_user = [aDecoder decodeObjectForKey:@"name_user"];
        self.rate_user = [aDecoder decodeObjectForKey:@"rate_user"];
        self.commentTime_user = [aDecoder decodeObjectForKey:@"commentTime_user"];
        self.comment_user = [aDecoder decodeObjectForKey:@"comment_user"];
        self.commentId_user = [aDecoder decodeObjectForKey:@"commentId_user"];
        self.str_commentHeight = [aDecoder decodeObjectForKey:@"str_commentHeight"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.str_userImageUrl forKey:@"str_userImageUrl"];
    [aCoder encodeObject:self.name_user forKey:@"name_user"];
    [aCoder encodeObject:self.rate_user forKey:@"rate_user"];
    [aCoder encodeObject:self.commentTime_user forKey:@"commentTime_user"];
    [aCoder encodeObject:self.comment_user forKey:@"comment_user"];
    [aCoder encodeObject:self.commentId_user forKey:@"commentId_user"];
    [aCoder encodeObject:self.str_commentHeight forKey:@"str_commentHeight"];
}


@end

