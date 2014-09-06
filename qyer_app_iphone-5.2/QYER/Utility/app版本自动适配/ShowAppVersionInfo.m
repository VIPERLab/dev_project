//
//  ShowAppVersionInfo.m
//  QyGuide
//
//  Created by 你猜你猜 on 13-12-31.
//
//

#import "ShowAppVersionInfo.h"

#define     height_content  16
#define     width_content   320
#define     offset_bottom   2
#define     startYear       2014



@implementation ShowAppVersionInfo

+(void)showInView:(UIView *)view atPositionY:(float)positionY
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *str_deviceDate = [dateFormatter stringFromDate:currentDate];
    [dateFormatter release];
    if(startYear - [str_deviceDate intValue] > 0)
    {
        str_deviceDate = @"2014";
    }
    
    
    UIView *view_backGround = [[UIView alloc] initWithFrame:CGRectMake(0, positionY, width_content, height_content*3+offset_bottom)];
    view_backGround.backgroundColor = [UIColor clearColor];
    UILabel *label_top = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width_content, height_content)];
    label_top.backgroundColor = [UIColor clearColor];
    label_top.textColor = [UIColor colorWithRed:150/255. green:150/255. blue:150/255. alpha:1];
    label_top.textAlignment = NSTextAlignmentCenter;
    label_top.font = [UIFont systemFontOfSize:12];
    label_top.text = [NSString stringWithFormat:@"%@iPhone版",appName];
    [view_backGround addSubview:label_top];
    UILabel *label_middle = [[UILabel alloc] initWithFrame:CGRectMake(0, label_top.frame.origin.y+label_top.frame.size.height, width_content, height_content)];
    label_middle.backgroundColor = [UIColor clearColor];
    label_middle.textColor = [UIColor colorWithRed:150/255. green:150/255. blue:150/255. alpha:1];
    label_middle.textAlignment = NSTextAlignmentCenter;
    label_middle.font = [UIFont systemFontOfSize:12];
    label_middle.text = [NSString stringWithFormat:@"版本 %@",appVersion];
    [view_backGround addSubview:label_middle];
    UILabel *label_bottom = [[UILabel alloc] initWithFrame:CGRectMake(0, label_middle.frame.origin.y+label_middle.frame.size.height, width_content, height_content)];
    label_bottom.backgroundColor = [UIColor clearColor];
    label_bottom.textColor = [UIColor colorWithRed:150/255. green:150/255. blue:150/255. alpha:1];
    label_bottom.textAlignment = NSTextAlignmentCenter;
    label_bottom.font = [UIFont systemFontOfSize:12];
    label_bottom.text = [NSString stringWithFormat:@"Copyright © 2004-%@ QYER.inc",str_deviceDate];
    [view_backGround addSubview:label_bottom];
    [view addSubview:view_backGround];
    [label_top release];
    [label_middle release];
    [label_bottom release];
    [view_backGround release];
    
}

@end

