//
//  QYCommonUtil.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-3-6.
//
//

#import <Foundation/Foundation.h>

#define Key_Time_Days           @"Time_Days"
#define Key_Time_Hours          @"Time_Hours"
#define Key_Time_Minutes        @"Time_Minutes"
#define Key_Time_Seconds        @"Time_Seconds"

typedef void(^QYLastMinuteAlipaySuccessBlock) (NSArray *data);
typedef void(^QYLastMinuteAlipayFailureBlock) (NSError *error);


@interface QYCommonUtil : NSObject

//清除当前联系人信息
//+ (void)clearCurrPersonInfo;

//验证电话：开头为1，共11位
+ (BOOL)checkPhone:(NSString*)aContent;

//验证邮箱：邮箱正则
+ (BOOL)checkEmail:(NSString*)aContent;

//获得倒计时时间格式： 2天13小时19分54秒
+ (NSString*)getTimeStrngWithSeconds:(NSInteger)aSeconds;

//获得倒计时时间格式Dictionary： 2天13小时19分54秒
+ (NSDictionary*)getTimeInfoWithSeconds:(NSInteger)aSeconds;

//设置本地18:00提醒
//+ (void)setLocalAppReminder;

//移除本地18:00提醒
//+ (void)removeLocalAppReminder;

//移除全部本地提醒
+ (void)removeAllLocalReminders;


/**
 设置本地提醒
 
 aFireDate: 激活时间
 aBody: 提醒文案
 aKey: 提醒对应Key值
 aRepeatInterval:重复时间间隔（0为不重复）
 
 */
+ (void)setLocalAppReminderWithDate:(NSDate*)aFireDate body:(NSString*)aBody key:(NSString*)aKey repeatInterval:(CFCalendarUnit)aRepeatInterval;

/**
 移除本地提醒
 
 aKey: 提醒对应Key值
 
 */
+ (void)removeLocalReminderWithKey:(NSString*)aKey;

//清除图片缓存
+ (BOOL)cleanImageCache;

//清除全部缓存
+ (BOOL)cleanAllCache;

//获得带有http://的Url
+ (NSString*)getCorrectUrlWithString:(NSString*)aUrlStr;

//友盟统计 （计算型）
+ (void)umengEvent:(NSString *)eventId attributes:(NSDictionary *)attributes number:(NSNumber *)number;

//判断是否安装了某软件
+ (BOOL)checkIfAppInstalled:(NSString *)aUrlSchemes;

//获得通用的间隔Cell
+ (UITableViewCell*)getCommentSpaceCellWithTableView:(UITableView*)aTableView;


//显示Alert
+ (void)showAlertWithTitle:(NSString*)aTitle content:(NSString*)aContent;

//显示Alert
+ (void)showAlertWithTitle:(NSString*)aTitle content:(NSString*)aContent delegate:(id)delegate tag:(NSInteger)aTag;

//判断是否是折扣详情
+ (BOOL)isLastMinuteDetailWithUrl:(NSString*)aUrl;

//从Url中获取id
+ (NSInteger)getIdFromLastMinuteDetailUrl:(NSString*)aUrl;

@end
