//
//  Account.m
//  QYER
//
//  Created by 我去 on 14-5-14.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "Account.h"

@implementation Account
@synthesize access_token;
@synthesize expires_in;
@synthesize scope;
@synthesize user_id;
@synthesize im_user_id;
@synthesize username;
@synthesize gender;
@synthesize title;
@synthesize avatar;
@synthesize cover;

-(void)dealloc
{
    self.access_token = nil;
    self.scope = nil;
    self.im_user_id = nil;
    self.username = nil;
    self.title = nil;
    self.avatar = nil;
    self.cover = nil;
    
    [super dealloc];
}



static Account *sharedAccount = nil;
+(id)sharedAccount
{
    @synchronized (self)
    {
        if(!sharedAccount)
        {
            sharedAccount = [[self alloc] init];
        }
    }
    
    return sharedAccount;  //外界初始化得到单例类对象的唯一接口,这个类方法返回的就是sharedAccount,即类的一个对象。如果sharedAccount为空,则实例化一个对象;如果不为空,则直接返回。这样保证了实例的唯一。
}
+(id)allocWithZone:(NSZone *)zone
{
    @synchronized (self)
    {
        if(!sharedAccount)
        {
            sharedAccount = [super allocWithZone:zone];
            return sharedAccount;
        }
        
        return sharedAccount;
    }
}
-(id)init
{
    self = [super init];
    @synchronized(self)
    {
        if(sharedAccount)
        {
            return sharedAccount;
        }
        else
        {
            [super init];
            return self;
        }
    }
}
-(id)copy
{
    return self; //copy和copyWithZone这两个方法是为了防止外界拷贝造成多个实例,保证实例的唯一性。
}
-(id)copyWithZone:(NSZone *)zone
{
    return self;
}
-(id)retain
{
    return self; //因为只有一个实例对象,所以retain不能增加引用计数。
}
-(unsigned)retainCount
{
    return UINT_MAX; //因为只有一个实例对象,设置默认引用计数。这里是取的NSUinteger的最大值,当然也可以设置成1或其他值。
}
-(oneway void)release  //'oneway void'用于多线程编程中,表示单向执行,不能“回滚”,即原子操作。
{
    // Do nothing
}



-(void)initAccountWithDic:(NSDictionary *)dic
{
    sharedAccount.access_token = [NSString stringWithFormat:@"%@",[dic objectForKey:@"access_token"]];
    sharedAccount.expires_in = [[dic objectForKey:@"expires_in"] intValue];
    sharedAccount.scope = [NSString stringWithFormat:@"%@",[dic objectForKey:@"scope"]];
    sharedAccount.im_user_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"im_user_id"]];
    sharedAccount.user_id = [[dic objectForKey:@"user_id"] intValue];
    sharedAccount.username = [NSString stringWithFormat:@"%@",[dic objectForKey:@"username"]];
    sharedAccount.gender = [[dic objectForKey:@"gender"] intValue];
    sharedAccount.title = [NSString stringWithFormat:@"%@",[dic objectForKey:@"title"]];
    sharedAccount.avatar = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar"]];
    sharedAccount.cover = [NSString stringWithFormat:@"%@",[dic objectForKey:@"cover"]];
}
-(void)initAccountWhenThirdLoginWithDic:(NSDictionary *)dic
{
    sharedAccount.access_token = [NSString stringWithFormat:@"%@",[dic objectForKey:@"access_token"]];
    sharedAccount.expires_in = [[dic objectForKey:@"expires_in"] intValue];
    sharedAccount.scope = [NSString stringWithFormat:@"%@",[dic objectForKey:@"scope"]];
    sharedAccount.im_user_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"im_user_id"]];
    
    
    NSDictionary *dic_ = [dic objectForKey:@"userinfo"];
    sharedAccount.user_id = [[dic_ objectForKey:@"user_id"] intValue];
    sharedAccount.username = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"username"]];
    sharedAccount.gender = [[dic_ objectForKey:@"gender"] intValue];
    sharedAccount.title = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"title"]];
    sharedAccount.avatar = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"avatar"]];
    sharedAccount.cover = [NSString stringWithFormat:@"%@",[dic_ objectForKey:@"cover"]];
}


@end
