//
//  QYCommonUtil.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-3-6.
//
//

#import "QYCommonUtil.h"
//#import "LastMinuteUserOrder.h"

#define Setting_Remind_Date                   @"Setting_Remind_Date"

@implementation QYCommonUtil

////清除当前联系人信息
//+ (void)clearCurrPersonInfo
//{
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//    [settings removeObjectForKey:Settings_Buyer_Curr_Name];
//    [settings removeObjectForKey:Settings_Buyer_Curr_Phone];
//    [settings removeObjectForKey:Settings_Buyer_Curr_Email];
//    [settings synchronize];
//}

//验证电话：开头为1，共11位
+ (BOOL)checkPhone:(NSString*)aContent
{
    if ([aContent length]==11) {//11位
        NSString *firstChar = [aContent substringToIndex:1];
        return [firstChar isEqualToString:@"1"]?YES:NO;
    }
    return NO;

}

//验证邮箱：邮箱正则
+ (BOOL)checkEmail:(NSString*)aContent
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPredicate evaluateWithObject:aContent];
    
}

+ (UITableViewCell*)getCommentSpaceCellWithTableView:(UITableView*)aTableView
{

    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellIdentifier"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;

}


//获得倒计时时间格式： 2天13小时19分54秒
+ (NSString*)getTimeStrngWithSeconds:(NSInteger)aSeconds
{
    int days = aSeconds / (60*60*24);
    int hours = aSeconds % (60*60*24) / 3600;
    
    //剩余时间
    int lastSecond = aSeconds - days*(60*60*24) - hours*(60*60);
    int minutes = lastSecond / 60;
    int seconds = lastSecond % 60;
    
    //    NSLog(@"-------------- days:%d, hours:%d, minutes:%d, seconds:%d", days, hours, minutes, seconds);
    
    NSString *dayStr = days==0?@"":[NSString stringWithFormat:@"%d天", days];
    NSString *hoursStr = hours==0?@"":[NSString stringWithFormat:@"%d小时", hours];//   @"小时";
    NSString *minutesStr = minutes==0?@"":[NSString stringWithFormat:@"%d分", minutes];//@"分";
    NSString *secondsStr = seconds==0?@"":[NSString stringWithFormat:@"%d秒", seconds];//@"秒";
    
    NSString *timeStr = [NSString stringWithFormat:@"%@%@%@%@", dayStr, hoursStr, minutesStr, secondsStr];
    
    return timeStr;
    
}


//获得倒计时时间格式Dictionary： 2天13小时19分54秒
+ (NSDictionary*)getTimeInfoWithSeconds:(NSInteger)aSeconds
{
    int days = aSeconds / (60*60*24);
    int hours = aSeconds % (60*60*24) / 3600;
    
    //剩余时间
    int lastSecond = aSeconds - days*(60*60*24) - hours*(60*60);
    int minutes = lastSecond / 60;
    int seconds = lastSecond % 60;
    
    //    NSLog(@"-------------- days:%d, hours:%d, minutes:%d, seconds:%d", days, hours, minutes, seconds);
    
//    NSString *dayStr = days==0?@"":[NSString stringWithFormat:@"%d天", days];
//    NSString *hoursStr = hours==0?@"":[NSString stringWithFormat:@"%d小时", hours];//   @"小时";
//    NSString *minutesStr = minutes==0?@"":[NSString stringWithFormat:@"%d分", minutes];//@"分";
//    NSString *secondsStr = seconds==0?@"":[NSString stringWithFormat:@"%d秒", seconds];//@"秒";
    
//    NSString *timeStr = [NSString stringWithFormat:@"%@%@%@%@", dayStr, hoursStr, minutesStr, secondsStr];
    
    NSDictionary *timeInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                  [NSNumber numberWithInt:days],
                                                                  [NSNumber numberWithInt:hours],
                                                                  [NSNumber numberWithInt:minutes],
                                                                  [NSNumber numberWithInt:seconds],nil]
                                                         forKeys:[NSArray arrayWithObjects:
                                                                  Key_Time_Days,
                                                                  Key_Time_Hours,
                                                                  Key_Time_Minutes,
                                                                  Key_Time_Seconds, nil]];
    
    return timeInfo;

}

/**
 设置本地提醒
 
 aFireDate: 激活时间
 aBody: 提醒文案
 aKey: 提醒对应Key值
 aRepeatInterval:重复时间间隔（0为不重复）
 */
+ (void)setLocalAppReminderWithDate:(NSDate*)aFireDate body:(NSString*)aBody key:(NSString*)aKey repeatInterval:(CFCalendarUnit)aRepeatInterval
{
    //先移除该本地提醒
    [self removeLocalReminderWithKey:aKey];
    
    // 创建一个本地推送
    UILocalNotification *notification = [[[UILocalNotification alloc] init] autorelease];
    
    if (notification) {
        
//        NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:10];
        
        // 设置推送时间
        notification.fireDate = aFireDate; //pushDate;// test
        // 设置时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        // 设置重复间隔
        notification.repeatInterval = aRepeatInterval;//kCFCalendarUnitDay;
        // 推送声音
        notification.soundName = UILocalNotificationDefaultSoundName;
        // 推送内容
        notification.alertBody = aBody;
        notification.alertAction = @"打开";
        notification.hasAction = YES;
        //显示在icon上的红色圈中的数子
        notification.applicationIconBadgeNumber = 1;
        //设置userinfo 方便在之后需要撤销的时候使用
        NSDictionary *info = [NSDictionary dictionaryWithObject:aKey forKey:@"key"];
        notification.userInfo = info;
        //添加推送到UIApplication
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:notification];
        
    }



}

/**
 移除本地提醒
 
 aKey: 提醒对应Key值
 
 */
+ (void)removeLocalReminderWithKey:(NSString*)aKey
{
    // 获得 UIApplication
    UIApplication *app = [UIApplication sharedApplication];
    //获取本地推送数组
    NSArray *localArray = [app scheduledLocalNotifications];
    //声明本地通知对象
    UILocalNotification *localNotification = nil;
    if (localArray) {
        for (UILocalNotification *noti in localArray) {
            NSDictionary *dict = noti.userInfo;
            if (dict) {
                NSString *inKey = [dict objectForKey:@"key"];
                if ([inKey isEqualToString:aKey]) {
                    if (localNotification){
                        [localNotification release];
                        localNotification = nil;
                    }
                    localNotification = [noti retain];
                    break;
                }
            }
        }
        
        //判断是否找到已经存在的相同key的推送
        if (localNotification) {
            //不推送 取消推送
            [app cancelLocalNotification:localNotification];
            [localNotification release];
            return;
        }
    }



}

////设置本地18:00提醒
//+ (void)setLocalAppReminder
//{
//    NSDate *pushDate = [[NSUserDefaults standardUserDefaults] objectForKey:Setting_Remind_Date];//[NSDate dateWithTimeIntervalSinceNow:10];
//    
//    //点击查看N月N日最新折扣汇总
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setLocale:[NSLocale currentLocale]];
//    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
//    [dateFormat setDateFormat:@"M月d日"];
//    NSString *body = [NSString stringWithFormat:LocalNotification_Body_App_Format, [dateFormat stringFromDate:[NSDate date]]];
//    [self setLocalAppReminderWithDate:pushDate body:body key:LocalNotification_Key_App_Reminder repeatInterval:kCFCalendarUnitDay];
//
//}

////移除本地18:00提醒
//+ (void)removeLocalAppReminder
//{
//    
//    [self removeLocalReminderWithKey:LocalNotification_Key_App_Reminder];
//    
//}

//移除全部本地提醒
+ (void)removeAllLocalReminders
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

//清除图片缓存
+ (BOOL)cleanImageCache
{
    // Init the disk cache
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path])
    {
        NSError *error = nil;
        BOOL isRemoved = [fileManager removeItemAtPath:path error:&error];
        
        if (isRemoved) {
            //并重新创建该文件夹
            [[NSFileManager defaultManager] createDirectoryAtPath:path
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
            
        }
        
        return isRemoved;
    
    }
    
    return YES;

}

//清除全部缓存
+ (BOOL)cleanAllCache
{
    return [self cleanImageCache];

}

//获得带有http://的Url
+ (NSString*)getCorrectUrlWithString:(NSString*)aUrlStr
{
    NSString *urlHead = @"http://";
    if (![aUrlStr hasPrefix:@"http"]) {
        aUrlStr = [NSString stringWithFormat:@"%@%@", urlHead, aUrlStr];
    }
    
    return aUrlStr;

}

//友盟统计 （计算型）
+ (void)umengEvent:(NSString *)eventId attributes:(NSDictionary *)attributes number:(NSNumber *)number
{
    NSString *numberKey = @"__ct__";
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [mutableDictionary setObject:[number stringValue] forKey:numberKey];
    [MobClick event:eventId attributes:mutableDictionary];

}

//判断是否安装了某软件
+ (BOOL)checkIfAppInstalled:(NSString *)aUrlSchemes
{
//    return YES;
    return NO;
//    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", aUrlSchemes]]];

}

//显示Alert
+ (void)showAlertWithTitle:(NSString*)aTitle content:(NSString*)aContent
{
    [self showAlertWithTitle:aTitle content:aContent delegate:nil tag:0];
}

//显示Alert
+ (void)showAlertWithTitle:(NSString*)aTitle content:(NSString*)aContent delegate:(id)delegate tag:(NSInteger)aTag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:aTitle message:aContent delegate:delegate cancelButtonTitle:@"确定" otherButtonTitles:nil];
    alert.tag = aTag;
    [alert show];
    [alert release];
    
}

//判断是否是折扣详情
+ (BOOL)isLastMinuteDetailWithUrl:(NSString*)aUrl
{
    if ([aUrl rangeOfString:@"qyer.com/lastminute/deal"].location!=NSNotFound) {
        return YES;
    }else if([aUrl rangeOfString:@"z.qyer.com/deal"].location!=NSNotFound) {
        return YES;
    }else if([aUrl rangeOfString:@"m.qyer.com/lastminute/deal"].location!=NSNotFound) {
        return YES;
    }else if([aUrl rangeOfString:@"m.qyer.com/z/deal"].location!=NSNotFound) {
        return YES;
    }

    return NO;
}

//从Url中获取id
+ (NSInteger)getIdFromLastMinuteDetailUrl:(NSString*)aUrl
{
    NSArray *urlComp = [aUrl componentsSeparatedByString:@"/"];
    NSLog(@"----------urlComp:%@", urlComp);
    
    NSString *lastField = [urlComp lastObject];
    NSString *lastSecField = [urlComp objectAtIndex:[urlComp count]-2];
    NSInteger lastMinuteId = [lastField length]>0?[lastField intValue]:[lastSecField intValue];
    NSLog(@"-------------------lastMinuteId:%d", lastMinuteId);
    return lastMinuteId;
}

@end
