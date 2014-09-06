//
//  KSLoginViewController.h
//  KwSing
//
//  Created by 改 熊 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "KSViewController.h"
#import "IUserStatusObserver.h"
#import "KSLoginDelegate.h"

@interface KSOtherLoginViewController : KSViewController<IUserStatusObserver,OLoginView>
{
}
@property (nonatomic) BOOL isShare;         //分享
@property (nonatomic) BOOL isRegist;        //注册
@property (nonatomic) LOGIN_TYPE type;      //第三方类型
-(id)initWithType:(LOGIN_TYPE)setType;

@end
