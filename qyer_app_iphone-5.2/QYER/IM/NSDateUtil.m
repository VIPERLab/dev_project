//
//  NSDateUtil.m
//  QYER
//
//  Created by Frank on 14-5-9.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "NSDateUtil.h"

@implementation NSDateUtil


/**
 *  日期转换成字符串
 *
 *  @param date 日期
 *
 *  @param format 格式化字符串
 *
 *  @return 字符串
 */
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString*)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return destDateString;
}

/**
 *  字符串转换成日期
 *
 *  @param dateString 字符串
 *
 *  @return 日期
 */
+ (NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: DateFormatYMDHMS];
    NSDate *destDate = [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    return destDate;
}

/**
 *  字符串转换成日期
 *
 *  @param dateString 字符串
 *  @param format     日期格式
 *
 *  @return 日期
 */
+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: format];
    NSDate *destDate = [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    return destDate;
}

/**
 *  日期转换成字符串
 *
 *  @param date 日期
 *
 *  @return 字符串
 */
+ (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DateFormatYMDHMS];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return destDateString;
}

/**
 *  根据时间戳获取时间样式
 *
 *  @param timestamp 时间戳
 *
 *  @return 几分钟前，几小时前
 */
+ (NSString *)getTimeDiffString:(NSTimeInterval) timestamp
{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *todate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDate *today = [NSDate date];//当前时间
    unsigned int unitFlag = NSDayCalendarUnit | NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *gap = [cal components:unitFlag fromDate:today toDate:todate options:0];//计算时间差
    
    if (ABS([gap day]) > 0)
    {
        if (ABS([gap day]) >= 7) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:DateFormatYMD];
            NSString *destDateString = [dateFormatter stringFromDate:todate];
            [dateFormatter release];
            return destDateString;
        }
        
        return [NSString stringWithFormat:@"%d天前", ABS([gap day])];
        
    }else if(ABS([gap hour]) > 0)
    {
        return [NSString stringWithFormat:@"%d小时前", ABS([gap hour])];
    }else
    {
        return [NSString stringWithFormat:@"%d分钟前",  ABS([gap minute])];
    }
}

/**
 *  计算date距离当前日期的值
 *
 *  @param date 某个日期
 *
 *  1.如果是当前消息，只显示hh:mm
 *  2.相差一天，显示昨天 hh:mm
 *  3.如果是本周消息，显示星期几 hh:mm
 *  4.其他 yyyy-mm-dd hh:mm
 *
 *  @return
 */
+ (NSString*)formatDate:(NSDate*)date
{
    if (!date) {
        return @"";
    }
    NSString *text = @"";
    NSString *format = @"HH:mm";
    NSDate *today = nil;
    NSDate *yesterday = nil;
    NSDate *thisWeek = nil;
    
    [self diffDate:date withToday:&today withYesterday:&yesterday withThisWeek:&thisWeek];
    
    if ([date compare:today] == NSOrderedDescending) {
        //今天
    }else if ([date compare:today] == NSOrderedAscending && [date compare:yesterday] == NSOrderedDescending){
        //昨天
        text = @"昨天 ";
    }else if ([date compare:yesterday] == NSOrderedAscending && [date compare:thisWeek] == NSOrderedDescending){
        //本周
        NSInteger weekDay = [self weekDay:date];
        text = [NSString stringWithFormat:@"%@ ", [self weekDayName:weekDay]];
    }else{
        format = DateFormatYMDHM;
    }
    return [NSString stringWithFormat:@"%@%@", text, [self stringFromDate:date withFormat:format]];
}

/**
 *  获取某个日期距离现在
 *
 *  @param date
 *
 *  @return
 */
+ (void)diffDate:(NSDate*)date withToday:(NSDate**)today withYesterday:(NSDate**)yesterday withThisWeek:(NSDate**)thisWeek
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[NSDate date]];
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];    //设置成 yyyy-MM-dd 00:00:00 格式
    
    *today = [cal dateByAddingComponents:components toDate:[NSDate date] options:0];
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    
    *yesterday = [cal dateByAddingComponents:components toDate:*today options:0];
    
    components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    [components setDay:([components day] - ([components weekday]))];
    
    *thisWeek  = [cal dateFromComponents:components];
}

/**
 *  获取当前星期几
 *
 *  @param date
 *
 *  @return
 */
+ (NSInteger)weekDay:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSWeekdayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    return [comps weekday];
}


/**
 *  通过星期数字，转换成汉字
 *
 *  @param week
 *
 *  @return
 */
+ (NSString*)weekDayName:(NSInteger)week
{
    NSString *weekStr = @"";
    switch (week) {
        case 1:
            weekStr = @"星期天";
            break;
        case 2:
            weekStr = @"星期一";
            break;
        case 3:
            weekStr = @"星期二";
            break;
        case 4:
            weekStr = @"星期三";
            break;
        case 5:
            weekStr = @"星期四";
            break;
        case 6:
            weekStr = @"星期五";
            break;
        case 7:
            weekStr = @"星期六";
            break;
    }
    return weekStr;
}

- (void)dealloc
{
    [super dealloc];
}

@end
