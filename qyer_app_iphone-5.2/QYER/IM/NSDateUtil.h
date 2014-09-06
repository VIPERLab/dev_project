//
//  NSDateUtil.h
//  QYER
//
//  Created by Frank on 14-5-9.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *DateFormatYMDHMSMS = @"yyyy-MM-dd HH:mm:ss.SSS";

static NSString *DateFormatYMDHMS = @"yyyy-MM-dd HH:mm:ss";

static NSString *DateFormatYMDHM = @"yyyy-MM-dd HH:mm";

static NSString *DateFormatYMD = @"yyyy-MM-dd";

/**
 *  日期工具类
 */
@interface NSDateUtil : NSObject

/**
 *  字符串转换成日期
 *
 *  @param dateString 字符串
 *
 *  @return 日期
 */
+ (NSDate *)dateFromString:(NSString *)dateString;


/**
 *  日期转换成字符串
 *
 *  @param date 日期
 *
 *  @return 字符串
 */
+ (NSString *)stringFromDate:(NSDate *)date;

/**
 *  字符串转换成日期
 *
 *  @param dateString 字符串
 *  @param format     日期格式
 *
 *  @return 日期
 */
+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString*)format;

/**
 *  日期转换成字符串
 *
 *  @param date 日期
 *
 *  @param format 格式化字符串
 *
 *  @return 字符串
 */
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString*)format;

/**
 *  根据时间戳获取时间样式
 *
 *  @param timestamp 时间戳
 *
 *  @return 几分钟前，几小时前
 */
+ (NSString *)getTimeDiffString:(NSTimeInterval) timestamp;

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
+ (NSString*)formatDate:(NSDate*)date;


@end
