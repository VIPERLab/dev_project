//
//  QyYhConst.h
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//


#import "LoadMoreView.h"
#define APPDELEGATE (AppDelegate *)[[UIApplication sharedApplication]delegate]

#define UIHeight [[UIScreen mainScreen] bounds].size.height
#define UIWidth [[UIScreen mainScreen] bounds].size.width

#define IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568 ? YES:NO)
#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? YES :NO)
#define RGB(x,y,z) [UIColor colorWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:1.0]
#define screenSize [NSString stringWithFormat:@"%.f",[[[UIScreen mainScreen] currentMode] size].width]
#define reqNumber @"20"

#define PrivateChatTableName @"PrivateChat"

/**
 *  私信未读总个数
 */
#define TotalPrivateChatNumber [NSString stringWithFormat:@"TotalPrivateChatNumber_%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]]
/**
 *  通知未读个数
 */
#define NotificationUnreadCount [NSString stringWithFormat:@"NotificationUnreadCount_%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]]


#define Default_Font @"HiraKakuProN-W3"
#define Default_Font_Bold @"HiraKakuProN-W6"
