//
//  AppDelegate.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "NetworkMonitoring.h"
#import "Reachability.h"
#import "AppReviewsRemind.h"
#import "MobClick.h"
#import "DownloadData.h"
#import "GetInfo.h"
#import "ASIFormDataRequest.h"
#import "GetRemoteNotificationData.h"
#import "QyerSns.h"
#import "DeviceToken.h"
#import "VersionUpdate.h"
#import "QYAPIClient.h"
#import "QYGuideData.h"
#import "SBJsonParser.h"
#import "GoogleAPIKey.h"
#import <GoogleMaps/GoogleMaps.h>
#import "webFrameCacheData.h"
#import "UniqueIdentifier.h"
#import "RPSViewController.h"
#import "ChatroomData.h"
#import "UserInfo.h"
#import "Toast+UIView.h"

#import "QYIMObject.h"
#import "AnPush.h"
#import "MLNavigationController.h"
#import <BugSense-iOS/BugSenseController.h>
#import "GlobalObject.h"
#import "QyYhConst.h"

#import "PrivateChat.h"
#import "LocalData.h"
#import "DetailChatRoomController.h"

@implementation AppDelegate
@synthesize locationManager = _locationManager;

@synthesize _homeNavVC ;

- (void)dealloc
{
    self.locationManager = nil;
    [myOnlyString release];
    [_homeNavVC release];
    
    [rootVC release];
    
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //校准服务器时间
    [QYTime checkServerTime];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
//    [MiPushSDK registerMiPush:self];
    
    
    [AnPush registerForPushNotification:(UIRemoteNotificationTypeAlert |
                                         UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound)];
    
    
    //*** 处理状态栏:
    application.statusBarHidden = NO;
    if(ios7)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    //*** 友盟:
//    [MobClick startWithAppkey:@"533e4f6556240b5a20001399" reportPolicy:(ReportPolicy)REALTIME channelId:appChannel_UMeng];

    [MobClick startWithAppkey:@"533e4f6556240b5a20001399"];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    [MobClick setAppVersion:version];
    [MobClick checkUpdateWithDelegate:self selector:@selector(appUpdate:)];
    [MobClick updateOnlineConfig];  //在线参数配置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
  
    
    
    // 开发环境关闭 UMENG 捕捉异常
    [MobClick setCrashReportEnabled:YES];
    
//    // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
//    [MobClick setLogEnabled:YES];
    // 开发环境开启 BugSense 捕捉异常
    [BugSenseController sharedControllerWithBugSenseAPIKey:@"397ac1ab"
                                            userDictionary:nil
                                           sendImmediately:YES];

    [BugSenseController setUserIdentifier:[[UIDevice currentDevice] name]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];

    
    //*** 远程推送:
    [self initRemoteNotification:launchOptions];
    
    //*** app评论提醒:
    [AppReviewsRemind remindWithDelegate:self];
    
    //*** 监听网络状态:
    [[NetworkMonitoring sharedNetworkMonitoring] NetworkMonitor];
    
    //*** 新浪微博:
    [QyerSns sharedQyerSns];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
    {
        [[QyerSns sharedQyerSns] sinaweibo].accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
        [[QyerSns sharedQyerSns] sinaweibo].expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
        [[QyerSns sharedQyerSns] sinaweibo].userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
    }
    
    //*** 微信:
    [WXApi registerApp:WeixinAppID];
    
    
    //*** 设置rootViewController:
    rootVC = [[[RootViewController alloc] init] autorelease];
    _homeNavVC = [[MLNavigationController alloc] initWithRootViewController:rootVC];
    _homeNavVC.navigationBarHidden = YES;
    self.window.rootViewController = _homeNavVC;
    
    //*** 其他的一些初始化:
    [self initOther];
    
    //*** 初始化googleMap:
    [self initGoogleMap];
    
    //*** 大版本替换:
    NSLog(@"  大版本替换 开始");
    [VersionUpdate updateFileSystem];
    [VersionUpdate fixBugAppearWhenVersion5];
    NSLog(@"  大版本替换 结束");
    
    //*** 获取未登录情况下允许下载的次数:
    [self getGuideDownloadLimit];
    
    //***  获取未读（新）通知个数:
    [self getNotificationUnreadCount];
    
    // 更新用户资料
    [self getUserInfoData];
    
    // 获取私信列表数据
    [self getPrivateChatListDataFromServer];
    
    [self initLocationManager];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
    
    
    return YES;
}

- (void)onlineConfigCallBack:(NSNotification *)note
{
    NSLog(@" 【 UMeng 】 online config note = %@", note.userInfo);
}

-(void)getUserInfoData{
    
    NSString *imUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid_im"];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    
    if (IsEmpty(imUserId) || userId) {
        
        
        [[QYAPIClient sharedAPIClient] getMyInfoWithUserid:userId orImUserId:@"" success:^(NSDictionary *dic) {
            
            NSMutableDictionary *dic_ = (NSMutableDictionary *)dic;
            NSString *im_user_id = [[dic_ objectForKey:@"data"] objectForKey:@"im_user_id"];
            
            if ([im_user_id length] > 0 && ![im_user_id isEqual:[NSNull null]] && ![im_user_id isEqualToString:@"<null>"] ) {
                
                [[NSUserDefaults standardUserDefaults] setObject:im_user_id forKey:@"userid_im"];
                
            }else{
                
                [dic_ setObject:@"" forKey:@"im_user_id"];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:dic_ forKey:[NSString stringWithFormat:@"mineinfo_%@",userId]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[QYIMObject getInstance] connect:im_user_id withBlock:^(QYIMObject *imObject, QYIMConnectStatus status) {
                
            }];
            
        } failed:^{
            
           
            
        }];
        
    }else{
        
        [[QYIMObject getInstance] connect:imUserId withBlock:^(QYIMObject *imObject, QYIMConnectStatus status) {
            
        }];
    }
    
    
}



-(void)initGoogleMap
{
    if ([kAPIKey length] == 0)
    {
        // Blow up if APIKey has not yet been set.
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        NSString *format = @"Configure APIKey inside GoogleAPIKey.h for your "
        @"bundle `%@`, see README.GoogleMapsSDKDemos for more information";
        @throw [NSException exceptionWithName:@"AppDelegate"
                                       reason:[NSString stringWithFormat:format, bundleId]
                                     userInfo:nil];
    }
    [GMSServices provideAPIKey:kAPIKey];
    
    // Log the required open source licenses!  Yes, just NSLog-ing them is not
    // enough but is good for a demo.
    NSLog(@" [GoogleMap SDK] Open source licenses:\n%@", [GMSServices openSourceLicenseInfo]);
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
//    [[QYIMObject getInstance] disConnect];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [GlobalObject share].isInPublicRoom = NO;
    [GlobalObject share].isAuto = YES;

    MYLog(@" --- applicationDidEnterBackground ");
    
    [[QYIMObject getInstance] disConnectWithBlock:nil];
    [QYIMObject getInstance].connectStatus = QYIMConnectStatusOffLine;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    
    
    [rootVC end];
    
    
    //*** (1)地图页停止定位:
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setmapviewdelegatenil" object:nil userInfo:nil];
    
    
    
    //*** (2)记录正在下载的锦囊:
    //[[DownloadData sharedDownloadData] cancleAllRequest];  //暂停所有下载
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloading.plist",[pathURL path]];
    NSArray *array = [QYGuideData getDownloadingGuide];
    if(array)
    {
        for(QYGuide *guide in array)
        {
            if(guide.guide_state == GuideRead_State || guide.guide_state == GuideNoamal_State)
            {
                continue;
            }
            
            //guide.guide_state = GuideDownloadFailed_State;
        }
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        if(data)
        {
            [data writeToFile:plistPath atomically:NO];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [GlobalObject share].isInPublicRoom = NO;
    [GlobalObject share].isAuto = YES;
    //校准服务器时间
    [QYTime checkServerTime];
    [self getNotificationUnreadCount];
    /**
     *  获取私信列表数据
     */
    [self getPrivateChatListDataFromServer];
    [self getUserInfoData];
   
    MYLog(@" --- applicationWillEnterForeground ");
    flag_getLocation = NO;
    [self initLocationManager];
    
    //*** 地图页启动定位:
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setmapviewdelegate" object:nil userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_AppWillEnterForeground" object:nil];
    
    
}

/**
 *  得到离线数据
 */
-(void)getPrivateChatListDataFromServer{
    
    
    NSString *imUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid_im"];
    if (IsEmpty(imUserId)) {
        return;
    }
    
    [self getLoalPirvateData];
    
    
    [[QYAPIClient sharedAPIClient] getPrichatListWithImUserId:imUserId count:@"200" since:@"" success:^(NSDictionary *dic) {
        

        if ([[dic objectForKey:@"status"] intValue] == 1) {
        

            NSArray *tempArr = [dic objectForKey:@"data"];
            if (tempArr.count > 0) {
                
                //异步插入数据到数据库。
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                   
                    
                    for (int i = 0; i<tempArr.count; i++) {
                        
                        NSDictionary *tempDict = [tempArr objectAtIndex:i];
                        PrivateChat *chat = [PrivateChat prasePrivateChatWithDict:tempDict];
                        [[LocalData getInstance] insertReplacePrivateChatWithTableName:PrivateChatTableName withObject:chat];
                        
                    }
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                       
                        [self getLoalPirvateData];

                    });
                    
                });
                
                
            }
            
           
        }
        
    } failed:^{
        
    }];
    
    return;
    
    
//    [[QYAPIClient sharedAPIClient] getPrichatListWithImUserId:imUserId count:@"100" since:@"" success:^(NSDictionary *dic) {
//        
//        if ([[dic objectForKey:@"status"] intValue] == 1) {
//            
//            NSArray *tempArr = [dic objectForKey:@"data"];
//            if (tempArr.count > 0) {
//                
//                //如果数据大于0，清空掉之前的数据。
//                [[GlobalObject share].priChatArray removeAllObjects];
//                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:TotalPrivateChatNumber];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"privateChatUnReadMsgNum" object:nil];
//
//                /**
//                 *  清空私信列表
//                 */
//                [[LocalData getInstance] clearPrivateChat];
//            }
//            
//            for (int i = 0; i<tempArr.count; i++) {
//                
//                NSDictionary *tempDict = [tempArr objectAtIndex:i];
//                PrivateChat *chat = [PrivateChat prasePrivateChatWithDict:tempDict];
//                [[GlobalObject share].priChatArray addObject:chat];
//                
//                
////                [[LocalData getInstance] insertPrivateChatWithTableName:PrivateChatTableName withObject:chat];
//            }
//            
//            [[LocalData getInstance] resetAllPrivateChatUnReadNumberTableName:PrivateChatTableName];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"reflushPriteTable" object:nil];
//        }
//
//        NSLog(@"dic is %@",dic);
//        
//    } failed:^{
//        
//        
//        NSMutableArray *temparr = [[[LocalData getInstance] queryPrivateChatWithTableName:PrivateChatTableName] retain];
//        [[GlobalObject share].priChatArray addObjectsFromArray:temparr];
//        [temparr release];
//
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"reflushPriteTable" object:nil];
//
//    }];
    
}

/**
 *  从数据库中获取私信数据
 */
-(void)getLoalPirvateData{
    
    
    [[GlobalObject share].priChatArray removeAllObjects];
    
    int totalUnReadNumber = 0;
    NSMutableArray * localArray = [[LocalData getInstance] queryPrivateChatWithTableName:PrivateChatTableName];
    for (PrivateChat *localChat in localArray) {
        
        [[GlobalObject share].priChatArray addObject:localChat];
        totalUnReadNumber += localChat.unReadNumber;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:totalUnReadNumber forKey:TotalPrivateChatNumber];
    
    
    //更新消息个数
    [[NSNotificationCenter defaultCenter] postNotificationName:@"privateChatUnReadMsgNum" object:nil];
    //更新私信列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reflushPriteTable" object:nil];
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //连接IM服务器
    //[self getNotificationUnreadCount];
    //flag_getLocation = NO;
    //[self initLocationManager];
    [[[QyerSns sharedQyerSns] sinaweibo] applicationDidBecomeActive];
    
    //发消息(当应用从后台返回来):
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BecomeActive" object:nil userInfo:nil];
    
    //从后台回来时需要刷新用户得行程数据:
    [[NSNotificationCenter defaultCenter] postNotificationName:@"freshdata_MyItineraryVC" object:nil userInfo:nil];
    
    
    
    
    [rootVC begin];
    
    
    
   

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[QYIMObject getInstance] disConnectWithBlock:nil];
}



#pragma mark -
#pragma mark --- 登录成功
-(void)loginIn_Success
{
    flag_getLocation = NO;
    //***  获取未读（新）通知个数:
    [self getNotificationUnreadCount];
    [self initLocationManager];
    
    /**
     *  删除私信数据
     */
    [[GlobalObject share].priChatArray removeAllObjects];
    /**
     *  获取私信列表数据
     */
    [self getPrivateChatListDataFromServer];
}


#pragma mark -
#pragma mark --- initLocationManager
-(void)initLocationManager
{
    if(!self.locationManager)
    {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        self.locationManager = locationManager;
        [locationManager release];
    }
    
    [self.locationManager stopUpdatingLocation];
    
    if ([CLLocationManager authorizationStatus] == 0 || [CLLocationManager authorizationStatus] == 1 || [CLLocationManager authorizationStatus] == 3)
    {
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        [self.locationManager startUpdatingLocation];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getLocationFailed" object:nil userInfo:nil];
        
        [self locationFail];
    }
}

#pragma mark -
#pragma mark --- locationManager - Delegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude] forKey:@"lat_user"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude] forKey:@"lon_user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.locationManager stopUpdatingLocation];
    //self.locationManager.delegate = nil;
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"qyerlogin"];
    
    if (isLogin == NO) {
        return;
    }
    if (!flag_getLocation) {
        flag_getLocation = YES;
        
        if ([GlobalObject share].isAuto) {
            [MobClick event:@"IMAutoJoin"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startActivityIndicatorView" object:nil userInfo:nil];
        
        
//        // 开发使用
//        if ([GlobalObject share].lat == 0 && [GlobalObject share].lon == 0) {
//            NSString *imUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid_im"];
//            if (IsEmpty(imUserId)) {
//                NSLog(@"Im user id still is nil, abort！");
//                return;
//            }
//            
//            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
//            [dict setObject:@"143" forKey:@"chatroom_id"];
//            [dict setObject:@"53ba02e7144452cd76000004" forKey:@"im_topic_id"];
//            [dict setObject:@"艾普洛菲尔" forKey:@"chatroom_name"];
//            [dict setObject:imUserId forKey:@"im_user_id"];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"getchatroomsuccess" object:nil userInfo:dict];
//                
//            });
//            return;
//        }
        
        
        NSString *strLat = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
        NSString *strLon = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
        
        if ([GlobalObject share].lat != 0 && [GlobalObject share].lon != 0) {
            strLat = [NSString stringWithFormat:@"%f",[GlobalObject share].lat];
            strLon = [NSString stringWithFormat:@"%f",[GlobalObject share].lon];
        }
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[strLat floatValue] longitude:[strLon floatValue]];
        
        [ChatroomData getChatRoomWithLocation:location success:^(NSDictionary *dic) {
            NSLog(@"  dic ===  dic : %@",dic);
            if(dic)
            {
                if (IsEmpty([dic objectForKey:@"im_user_id"])) {
                    // 修复接口返回 im user id 为空
                    [self getUserInfoData];
                    [dic setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid_im"] forKey:@"im_user_id"];
                }
                
                if (IsEmpty([dic objectForKey:@"im_topic_id"])) {
                    
                    [[QYIMObject getInstance] disJoinChatRoomWithBlock:^(QYIMObject *imObject, BOOL isSuc){
                        
                    }];
                    
                    UINavigationController *navController = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
                    if ([navController isKindOfClass:[UINavigationController class]]) {
                        
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"当前城市暂未开通身边人功能" delegate:self cancelButtonTitle:nil otherButtonTitles:@"查看城市列表",@"我知道了", nil];
                        alertView.tag = 7777;
                        [alertView show];
                        
                    }
                    
                }else{
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getchatroomsuccess" object:nil userInfo:dic];
                    
                }
                
                //存储userid_im
                [[NSUserDefaults standardUserDefaults] setObject:dic[@"im_user_id"] forKey:@"userid_im"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
            }
        } failed:^{
            NSLog(@"请求聊天室失败 fail");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getLocationFailed" object:nil userInfo:nil];
            
            //定位失败，如果正在聊天室，那么退出聊天室
            [self locationFail];
        }];
    }
}

-(void)setFlag_getLocation:(BOOL)bValue{
    flag_getLocation=bValue;
}

//定位失败:
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getLocationFailed" object:nil userInfo:nil];
    NSLog(@"App locationManager didFailWithError");
    
    //定位失败，如果正在聊天室，那么退出聊天室
    [self locationFail];

}

#pragma mark -
#pragma mark --- 设置APP的远程推送
- (void)initRemoteNotification:(NSDictionary *)launchOptions
{
    //*** 注册远程推送:
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    //UIApplication *myapp = [UIApplication sharedApplication];
    //myapp.idleTimerDisabled = YES;
    
    
    //*** 收到远程通知 [当应用从后台退出后]!!!
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(localNotif != nil)
    {
        NSMutableDictionary *dicaps = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSMutableDictionary *dic = [dicaps objectForKey:@"aps"];
        NSString *pushMseeage = [dic valueForKey:@"alert"];
        NSInteger badgeNumber = [[dic valueForKey:@"badge"] intValue];
        
        
        
        pushFlag = 1;
        
        //推送的数字:
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
        
        
        if (dicaps[@"msg_type"]) {
            return;
        }

        
        //推送的url:
        pushUrl = [[dic valueForKey:@"sub_field"] retain];
        
        //标示推送的内容分类:
        NSInteger extend_id = [[dic valueForKey:@"extend_id"] intValue];
        
        
        NSLog(@"^^^^^^ %@ ^^^^^^^ %d ^^^^^^^",pushUrl,extend_id);
        
        if(pushUrl && pushUrl.length > 1)
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:nil
                                      message:pushMseeage
                                      delegate:self
                                      cancelButtonTitle:@"忽略"
                                      otherButtonTitles:@"了解详情",nil];
            [alertView show];
            [alertView release];
        }
        else if(extend_id > 0)
        {
            [self getPushData:extend_id withFlag:1 andMsg:pushMseeage]; //flag=1表示:应用已从后台退出
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:nil
                                      message:pushMseeage
                                      delegate:self
                                      cancelButtonTitle:@"我知道了"
                                      otherButtonTitles:nil];
            alertView.delegate = self;
            [alertView show];
        }
    }
}
//*** 获取DeviceToken成功 [需要发给qyer的服务器]:
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *str = [NSString stringWithFormat:@"%@",deviceToken];
    str = [str stringByReplacingOccurrencesOfString:@"<" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    
    [DeviceToken postTokenToServer:str];
    
//    // 注册APNS成功, 注册deviceToken
//    [MiPushSDK bindDeviceToken:deviceToken];
    
    
    [AnPush setup:IMAppKey deviceToken:deviceToken delegate:[QYIMObject getInstance] secure:YES];
    [[QYIMObject getInstance] registerChannel];
}

//*** 获取DeviceToken失败:
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@" 获取DeviceToken失败 ");
    [DeviceToken postTokenToServer:@"1"];
}

//*** 收到远程通知 [还未从后台退出时]:
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //********** Mod By ZhangDong 2014.5.21 Start ************
    //1.私聊消息，2.私聊文件，3.聊天室消息，4.聊天室文件
    if (userInfo[@"msg_type"]) {
        return;
    }
    //********** Mod By ZhangDong 2014.5.21 End ************
    
    
    
    for (id key in userInfo)
    {
        NSString *pushMseeage = [[[userInfo objectForKey:key] valueForKey:@"alert"] retain];
        
        pushFlag = 1;
        
        //*** 设置推送的数字:
        NSInteger badgeNumber = [[[userInfo objectForKey:key] valueForKey:@"badge"] intValue];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
        
        //*** 获取推荐应用再appStore里的url地址:
        if(pushUrl && pushUrl.retainCount > 0)
        {
            [pushUrl release];
            pushUrl = nil;
        }
        
        if([[userInfo objectForKey:key] valueForKey:@"sub_field"])
        {
            pushUrl = [[[userInfo objectForKey:key] valueForKey:@"sub_field"] retain];
        }
        
        //*** 是否又扩展信息:
        NSInteger extend_id = [[[userInfo objectForKey:key] valueForKey:@"extend_id"] intValue];
        
        
        NSLog(@"###### %@ ###### %@ ###### %d ######",pushUrl,pushMseeage,extend_id);
        
        
        if(pushUrl && pushUrl.length > 1)
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:nil
                                      message:pushMseeage
                                      delegate:self
                                      cancelButtonTitle:@"忽略"
                                      otherButtonTitles:@"了解详情",nil];
            
            alertView.delegate = self;
            [alertView show];
        }
        
        else if(extend_id > 0)
        {
            [self getPushData:extend_id withFlag:0 andMsg:pushMseeage]; //flag=0表示:应用还未从后台退出
        }
        
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:nil
                                      message:pushMseeage
                                      delegate:self
                                      cancelButtonTitle:@"我知道了"
                                      otherButtonTitles:nil];
            alertView.delegate = self;
            [alertView show];
        }
        [pushMseeage release];
    }
    
}

-(void)getPushData:(NSInteger)extend_id withFlag:(bool)flag andMsg:(NSString*)pushMseeage
{
    GetRemoteNotificationData *remoteNotificationData = [[GetRemoteNotificationData alloc] init];
    [remoteNotificationData getPushDataByClientid:ClientId_QY
                                 andClientSecrect:ClientSecret_QY
                                     andExtend_id:extend_id
                                         finished:nil
                                           failed:nil
                                         withFlag:flag
                                           andMsg:pushMseeage];
    [remoteNotificationData release];
}

-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1000;
        [alert show];
        [alert release];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = @"这是从微信启动的消息";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}


#pragma mark -
#pragma mark --- 新浪微博 / 腾讯微博  ---  SSO
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@" handleOpenURL : %@",url);
    
//    return  [WXApi handleOpenURL:url delegate:self];

    if([[url absoluteString] rangeOfString:@"sina"].location != NSNotFound)
    {
        return [[[QyerSns sharedQyerSns] sinaweibo] handleOpenURL:url];
    }
    
    else{
        return YES;
    }
    
//    else
//    {
//        return [[[QyerSns sharedQyerSns] wbapi] handleOpenURL:url];
//    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([sourceApplication rangeOfString:@"tencent"].location != NSNotFound) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DidWeixinLogIn" object:url];
        
        return YES;
    }
    
    if([sourceApplication rangeOfString:@"sina"].location != NSNotFound)
    {
        return [[[QyerSns sharedQyerSns] sinaweibo] handleOpenURL:url];
    }
    
    else
    {
        return YES;
    }
}


#pragma mark -
#pragma mark --- initOther
-(void)initOther
{
//    [[NSUserDefaults standardUserDefaults] setInteger:0  forKey:NotificationUnreadCount];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hideUpdateButton_updateAllGuide"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark --- 获取未读（新）通知个数
-(void)getNotificationUnreadCount
{
    [[QYAPIClient sharedAPIClient] getNotificationUnreadCount:^(NSDictionary *dictionary){
        
        if(dictionary && [dictionary objectForKey:@"data"])
        {
            NSDictionary *dic = [dictionary objectForKey:@"data"];
            if([dic isKindOfClass:[NSDictionary class]])
            {
                if([dic objectForKey:@"total"])
                {
                    NSInteger count = [(NSString*)[dic objectForKey:@"total"] integerValue];
                    
                    [[NSUserDefaults standardUserDefaults] setInteger:count  forKey:NotificationUnreadCount];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"privateChatUnReadMsgNum" object:nil];
                }
            }
        }
               
        
    } failed:^{
        
    }];
}

#pragma mark -
#pragma mark --- 获取在未登录状态下允许下载的最大次数
-(void)getGuideDownloadLimit
{
    [[QYAPIClient sharedAPIClient] getMobileDownloadLimit:^(NSDictionary *dictionary){
        
        if(dictionary && [dictionary objectForKey:@"data"])
        {
            NSDictionary *dic = [dictionary objectForKey:@"data"];
            if([dic isKindOfClass:[NSDictionary class]])
            {
                if([dic objectForKey:@"mobile_download_limit"])
                {
                    NSString *limit = [NSString stringWithFormat:@"%@",[dic objectForKey:@"mobile_download_limit"]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:limit forKey:@"mobileDownloadLimit"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else
                {
                    [[NSUserDefaults standardUserDefaults] setObject:@"10" forKey:@"mobileDownloadLimit"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"10" forKey:@"mobileDownloadLimit"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"10" forKey:@"mobileDownloadLimit"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    } failed:^{
        [[NSUserDefaults standardUserDefaults] setObject:@"10" forKey:@"mobileDownloadLimit"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}



#pragma mark -
#pragma mark --- 友盟方法(获取更新相关信息)
-(void)appUpdate:(NSDictionary *)appUpdateInfo
{
    //[currentVC.view hideToast];
    
    appNewInfo = [[appUpdateInfo valueForKey:@"update_log"] retain];
    appNewVersion = [[appUpdateInfo valueForKey:@"version"] retain];
    path = [[appUpdateInfo objectForKey:@"path"] retain];
    //NSLog(@"path:%@",path);
    if(![isUpdate isEqualToString:[appUpdateInfo valueForKey:@"update"]])
    {
        [isUpdate release];
        isUpdate = [[appUpdateInfo valueForKey:@"update"] retain];
    }
    updateFlag = 0;
    //NSLog(@"isUpdate:%@",isUpdate);
    if([isUpdate isEqualToString:@"YES"])
    {
        updateFlag = 1;
        [self performSelectorOnMainThread:@selector(showUpdateAlert) withObject:nil waitUntilDone:YES];
    }
    
}

-(void)showUpdateAlert
{
    //[NSString stringWithFormat:@"找到最新版本:%@,是否更新到此版本",appNewVersion]
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"发现最新版本"
                          message:appNewInfo
                          delegate:self
                          cancelButtonTitle:@"忽略本次提醒"
                          otherButtonTitles:@"立即更新",nil];
    alert.delegate = self;
    alert.tag = 10001;
    [alert show];
    [alert release];
}


#pragma mark -
#pragma mark --- UIAlertView - delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 7777) {
        
        if (buttonIndex == 0) {
        
            DetailChatRoomController *detailVc = [[DetailChatRoomController alloc]init];
            [self.window.rootViewController presentViewController:detailVc animated:YES completion:nil];
            [detailVc release];
        }
        
        return;
    }
    
    
    if (alertView.tag == 10002) {
        
    }
    
    
    
    
    
    switch(alertView.tag)
    {
        case 10001: //app评论
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
                    appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
                    NSString *key_2 = [NSString stringWithFormat:@"rejective_comment_app_V%@",appVersion];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]] forKey:key_2];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                    break;
                }
                case 1:
                {
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
                    appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
                    NSString *key = [NSString stringWithFormat:@"comment_app_V%@",appVersion];
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:key];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=563467866"]]];
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d&at=10l6dK",APPSTOREAPPLICATIONID]];
                    if(ios7)
                    {
                        url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d?at=10l6dK",APPSTOREAPPLICATIONID]];
                    }
                    [[UIApplication sharedApplication] openURL:url];
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
          
            
        default:
            break;
    }
}

- (void)locationFail
{
    //定位失败，如果正在聊天室，那么退出聊天室
    UINavigationController *rootViewController = (UINavigationController*)self.window.rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UIView *view = rootViewController.topViewController.view;
        if ([QYIMObject getInstance].publicChatTopicId) {
            [view makeToast:@"当前城市没有聊天室" duration:1.5f position:@"center" isShadow:NO];
            [rootViewController popToRootViewControllerAnimated:YES];
        }
    }
}


@end


