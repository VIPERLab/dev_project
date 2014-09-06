//
//  AppDelegate.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <Cordova/CDVViewController.h>
#import "WXApi.h"
#import "Reachability.h"

#import "QYTime.h"

//#import "MiPushSDK.h"


#import "MLNavigationController.h"

@class RootViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,WXApiDelegate,UIAlertViewDelegate>
{
    //CLLocationManager       *_locationManager;      //后台下载时使用的位置管理器
    
    RootViewController      *rootVC;
    MLNavigationController  *_homeNavVC;
    BOOL                    pushFlag;               //是否点击远程推送alertview的标志
    NSString                *pushUrl;               //远程推送消息中的链接地址
    NSString                *myOnlyString;
    
    NSString    *isUpdate;
    NSString    *appNewVersion;
    NSString    *appNewInfo;
    BOOL        updateFlag;
    NSString    *path;
    
    BOOL        flag_getLocation;
}

@property (strong, nonatomic) UIWindow          *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong)Reachability *hostReach;
@property (retain,nonatomic)MLNavigationController  *_homeNavVC;

-(void)initLocationManager;

/**
 *  当前正在私聊的IM_USER_ID
 */
//@property (copy, nonatomic) NSString *privateUserId;

-(void)setFlag_getLocation:(BOOL)bValue;
-(void)getNotificationUnreadCount;
@end
