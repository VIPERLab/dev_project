//
//  UserInfo.m
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
@synthesize user_id = _user_id;
@synthesize im_user_id = _im_user_id;
@synthesize can_dm = _can_dm;
@synthesize username = _username;
@synthesize gender = _gender;
@synthesize title = _title;
@synthesize avatar = _avatar;
@synthesize cover = _cover;
@synthesize footprint = _footprint;
@synthesize follow_status = _follow_status;
@synthesize fans = _fans;
@synthesize follow = _follow;
@synthesize countries = _countries;
@synthesize cities = _cities;
@synthesize pois = _pois;
@synthesize trips = _trips;
@synthesize wants = _wants;
@synthesize age;
@synthesize signingMessages = _signingMessages;

-(void)dealloc
{
    self.username = nil;
    self.title = nil;
    self.avatar = nil;
    self.cover = nil;
    self.footprint = nil;
    self.follow_status = nil;
    self.attribute1 = nil;
    self.attribute2 = nil;
    self.attribute3 = nil;
    self.signingMessages = nil;
    
    [super dealloc];
}

@end

