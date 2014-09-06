//
//  Friends.m
//  QYER
//
//  Created by 我去 on 14-5-12.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "Friends.h"

@implementation Friends
@synthesize user_id = _user_id;
@synthesize im_user_id = _im_user_id;
@synthesize username = _username;
@synthesize gender = _gender;
@synthesize avatar = _avatar;
@synthesize both_follow = _both_follow;
@synthesize countries = _countries;
@synthesize cities = _cities;
@synthesize age = _age;

-(void)dealloc
{
    self.im_user_id = nil;
    self.username = nil;
    self.avatar = nil;
    
    [super dealloc];
}

@end
