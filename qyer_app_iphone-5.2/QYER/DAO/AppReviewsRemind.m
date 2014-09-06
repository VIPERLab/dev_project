//
//  AppReviewsRemind.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-23.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "AppReviewsRemind.h"


//#define commentAPP_space_of_time    86400*7   //*** 7天的时间间隔(提示评论app的时间间隔)
#define commentAPP_space_of_time    5           //*** 每隔5次提醒一回
#define AlertTag                    10001
#define AlertMessage                @"打滚求点评！做爱分享的穷游er！"
#define ButtunCancleTitle           @"卖萌可耻,无视"
#define ButtunDoneTitle             @"现在点评"



@implementation AppReviewsRemind

+(void)remindWithDelegate:(id)object
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [NSString stringWithFormat:@"%@",[infoDictionary objectForKey:@"CFBundleVersion"]];
    appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    NSString *key = [NSString stringWithFormat:@"comment_app_V%@",appVersion];
    NSString *key_2 = [NSString stringWithFormat:@"rejective_comment_app_V%@",appVersion];
   
    if(![[NSUserDefaults standardUserDefaults] objectForKey:key_2]) //*** 首次打开
    {
        //初始化本版本启动次数:
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"0"] forKey:@"app_open_count"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        //记录首次打开的时间(视为app的安装时间):
        NSDate *date = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd_HH:mm:ss"];
        NSString *str_date = [[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[date timeIntervalSince1970]]] retain];
        NSString *str_sce = [NSString stringWithFormat:@"%d",(NSInteger)[date timeIntervalSince1970]];
        [[NSUserDefaults standardUserDefaults] setObject:str_sce forKey:@"appInstalltime_sec"];
        [[NSUserDefaults standardUserDefaults] setObject:str_date forKey:@"appInstalltime"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"lat_user"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"lon_user"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        NSString *appVersion = [NSString stringWithFormat:@"%@",[infoDictionary objectForKey:@"CFBundleVersion"]];
        if([appVersion floatValue] - 2.7 < 0 && [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"]) //2.7以下版本首次打开强制退出
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_access_token"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userid"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"qyerlogin"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userName"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WIFISwitch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]] forKey:key_2];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [date release];
        [dateFormatter release];
        [str_date release];
    }
    else
    {
        //记录打开的次数:
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"app_open_count"] intValue];
        count++;
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",count] forKey:@"app_open_count"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        if(![[NSUserDefaults standardUserDefaults] objectForKey:key]) //*** 未评论
        {
            if(count == 2 || (count % 5 == 0 && count != 0))
            {
                [self performSelector:@selector(showCommentAppAlertView:) withObject:object afterDelay:1];
            }
        }
    }
}
+(void)showCommentAppAlertView:(id)object
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:AlertMessage
                                                       delegate:object
                                              cancelButtonTitle:ButtunCancleTitle
                                              otherButtonTitles:ButtunDoneTitle, nil];
    alertView.tag = AlertTag;
    [alertView show];
    [alertView release];
}


@end

