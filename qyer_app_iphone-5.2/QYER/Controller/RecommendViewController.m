//
//  RecommendViewController.m
//  QYER
//
//  Created by 我去 on 14-3-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "RecommendViewController.h"
#import "MoreViewController.h"
#import "GroupChatRoomViewController.h"
#import "CDVWebMainViewController.h"
#import "webFrameCacheData.h"
#import "NoteAndChatViewController.h"
#import "UserInfo.h"
#import "QYIMObject.h"
#import "Account.h"
#import <CoreLocation/CLLocationManager.h>
#import "CityLoginViewController.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "DestinationCell.h"
#import "TripNewViewCell.h"
#import "QYOperation.h"
#import "CountryViewController.h"
#import "GuideDetailViewController.h"
//#import "LastMinuteDetailViewController.h"
#import "LastMinuteDetailViewControllerNew.h"
#import "QYGuideData.h"
#import "CDVWebRedicteViewController.h"
#import "PoiDetailViewController.h"
#import "BBSDetailViewController.h"
#import "loadCDWebViewShellViewController.h"
#import "SubjectViewController.h"
#import "WebViewViewController.h"
#import "MyPlanViewController.h"
#import "GuideViewController.h"
#import "CountryViewController.h"
#import "GuideDetailViewController.h"
//#import "LastMinuteDetailViewController.h"
#import "QYGuideData.h"
#import "CDVWebRedicteViewController.h"
#import "PoiDetailViewController.h"
#import "BBSDetailViewController.h"
#import "loadCDWebViewShellViewController.h"
#import "SubjectViewController.h"
#import "WebViewViewController.h"
#import "MyPlanViewController.h"
#import "GuideViewController.h"
#import "DetailChatRoomController.h"
#import "MobClick.h"
#import "GroupMember.h"
#import "LocalData.h"
#import "GlobalObject.h"
#import "YouMayLikeViewController.h"


static BOOL                 isActivityIndicatorView;

#define     positionY_QYlogo                (ios7 ? (0+20) : 0)
#define     positionY_QYWordlogo            (ios7 ? (10+20) : 10)
#define     positionY_button_more           (ios7 ? (6+20) : 6)


#define URL_REDIRECT_PLACE      @"http://appview.qyer.com/index.php?action=placeDetail"
#define URL_REDIRECT_STRING     @"http://appview.qyer.com"
#define URL_REDIRECT_COUNTRY    @"country"
#define URL_REDIRECT_CITY       @"city"
#define URL_REDIRECT_GUIDE      @"guide"
#define URL_REDIRECT_POI        @"poi"
#define URL_REDIRECT_BBS        @"bbs"
#define URL_REDIRECT_TRIP       @"trip"
#define URL_REDIRECT_QUESTION   @"question"
#define URL_REDIRECT_LASTMINUTE @"deal"


//你可能喜欢的按钮位置
#define btnLikeX     10
#define btnLikeY     (170 + 74)
#define btnLikeW     300
#define btnLikeH     49




@interface RecommendViewController ()

@property (nonatomic, retain) NSDictionary *YouMayLikeDict;

@property (nonatomic, copy) NSString *likeTitle;
@property (nonatomic, retain) UIButton *YouMayLikeButton;
@property (nonatomic, retain) UILabel *YouMayLikeLable;

@end







@implementation RecommendViewController
@synthesize currentVC;
@synthesize dic = _dic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        imagesArray = [[NSMutableArray alloc] init];
        placesArray = [[NSMutableArray alloc] init];
        discountArray = [[NSMutableArray alloc] init];
        tripsArray = [[NSMutableArray alloc] init];
        
        [self setDisplayCahtroomAccessStatus];
    }
    return self;
}
-(NSString *)likeTitle
{
    _likeTitle = [[self.YouMayLikeDict objectForKey:@"data"] objectForKey:@"title"];
    
    return _likeTitle;
}
-(NSDictionary *)YouMayLikeDict
{
    if (_YouMayLikeDict == nil) {
        _YouMayLikeDict = [[NSDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"recommendYouMayLike"]];
    }
    return _YouMayLikeDict;
}

-(void)goChatroomButton:(id)sender{
    
    [QYIMObject getInstance].connectStatus = QYIMConnectStatusOffLine;
    [MobClick event:@"IMClickJoin"];
    [GlobalObject share].isAuto = NO;
    
    if (isNotReachable) {
        [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.0f position:@"center" isShadow:NO];
        return;
    }
    
    if([CLLocationManager authorizationStatus] == 2)
    {
        [self.view hideToast];
        [self.view makeToast:@"需要您在系统设置界面\n授权打开定位服务" duration:1.5 position:@"center" isShadow:NO];
        
    }else{
        
        BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue];
        if (!isLogin) {
            //未登录状态用户提示登录
            CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
            UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
            navigationController.navigationBarHidden = YES;
            [currentVC presentViewController:navigationController animated:YES completion:nil];
            [cityLoginVC release];
            
        }else{
            
            limitMultiple = NO;
            [_chatchatroomAdvertiseView removeFromSuperview];
            
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setFlag_getLocation:NO];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] performSelector:@selector(initLocationManager) withObject:nil afterDelay:0];
        }
    }

}

-(void)clickBackButton:(id)sender{
    limitMultiple = NO;
    [_chatchatroomAdvertiseView removeFromSuperview];
}

-(void)loginIn_Success{
    limitMultiple = NO;

    [_chatchatroomAdvertiseView removeFromSuperview];
    NSLog(@"loginIn_Success--loginIn_Success");
    
    if([CLLocationManager authorizationStatus] != 2)
    {
        [_activityView startAnimating];
        _chatButton.enabled=NO;
        [_chatButton setBackgroundImage:[UIImage imageNamed:@"bg_身边人2.png"] forState:UIControlStateNormal];

    }
//    NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
//    NSInteger totalPriChatNum = [myUserDefault integerForKey:TotalPrivateChatNumber];
//    
//    NSInteger notificationUnreadCount=[myUserDefault integerForKey:NotificationUnreadCount];
//    NSString* count=[NSString stringWithFormat:@"%d",notificationUnreadCount+totalPriChatNum];
//    [button_meassage setBackgroundImage:[self getMessageButtonImage:[UIImage imageNamed:@"press_remind"] count:count] forState:UIControlStateNormal];
    
    [_chatButton setBackgroundImage:[UIImage imageNamed:@"bg_身边人2.png"] forState:UIControlStateNormal];
    
//    [self connectIMServer];
    
}
-(UIImage*)getChatButtonImage:(UIImage*)btn_image count:(NSString*)_count location:(NSString*)_location{
    
    CGSize newImageSize = CGSizeMake(160, 160);
    
    UIGraphicsBeginImageContext(newImageSize);
    
    [btn_image drawInRect:CGRectMake(0, 0, newImageSize.width, newImageSize.height)];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, RGB(243, 33, 81).CGColor);
    [_count drawInRect:CGRectMake(25,22,54*2,30) withFont:[UIFont systemFontOfSize:40] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    CGContextSetFillColorWithColor(context, RGB(44, 170, 122).CGColor);
    [_location drawInRect:CGRectMake(25,67,54*2,30) withFont:[UIFont systemFontOfSize:20] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
    UIImage *imagePNG = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return imagePNG;
    
}

-(UIImage*)getMessageButtonImage:(UIImage*)btn_image count:(NSString*)_count{
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue];
    if (_count && isLogin) {
        if([_count intValue]>99){
           _count=@"99+";
        }
        UIImage* numberImg=[UIImage imageNamed:@"number_bg.png"];
        CGSize count_size=[_count sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(80, 80) lineBreakMode:NSLineBreakByWordWrapping];
        if (count_size.width<24) {
            count_size=CGSizeMake(24, 24);
        }else if(count_size.width>35){
            count_size=CGSizeMake(35, 24);
        }
        CGSize newImageSize = CGSizeMake(80, 80);
        
        UIGraphicsBeginImageContext(newImageSize);
        
        [btn_image drawInRect:CGRectMake(0, 0, newImageSize.width, newImageSize.height)];
        [numberImg drawInRect:CGRectMake(45, 20, count_size.width+2, count_size.height+2)];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        [_count drawInRect:CGRectMake(46,18,count_size.width,count_size.height) withFont:[UIFont systemFontOfSize:20] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
        
        UIImage *imagePNG = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return imagePNG;
    }
    
    return btn_image;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reConnectSocket" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getchatroomsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getLocationFailed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"logininsuccess" object:nil];
    [_headView release];
    [_titleImageLogo release];
    [_userInfo release];
    
    [_topScrollView release];
    _topScrollView = nil;
    
    QY_SAFE_RELEASE(_dic);
    QY_VIEW_RELEASE(tableHeadView);
    
    [imagesArray release];
    [placesArray release];
    [discountArray release];
    [tripsArray release];
    
    [super dealloc];
}

-(void)getLocationFailed{
    
    isActivityIndicatorView=NO;
    [_activityView stopAnimating];
    _chatButton.enabled=YES;
    displayChatroomStaus=0;
   [_chatButton setBackgroundImage:[UIImage imageNamed:@"bg_身边人2.png"] forState:UIControlStateNormal];
    
    
    if ([GlobalObject share].isInPublicRoom == NO) {
        
        
        if ([QYIMObject getInstance].privateChatImUserId && ![[QYIMObject getInstance].privateChatImUserId isEqualToString:@""]) {
        
            return;
        }
        
        if ([GlobalObject share].isAuto == NO) {
            
            UINavigationController *navController = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
            if ([navController isKindOfClass:[UINavigationController class]]) {

                if (_isArrowExcption) {
                    _isArrowExcption = NO;
                    
                    UIView *view = navController.topViewController.view;
                    [view makeToast:@"网络异常，请稍后再试" duration:1.5f position:@"center" isShadow:NO];
                }else{
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"当前城市暂未开通身边人功能" delegate:self cancelButtonTitle:nil otherButtonTitles:@"查看城市列表",@"我知道了", nil];
                    alertView.tag = 7777;
                    [alertView show];
                }
                
                [GlobalObject share].isAuto = YES;

                /*
                UIView *view = navController.topViewController.view;
                [view makeToast:@"当前城市没有聊天室" duration:1.5f position:@"center" isShadow:NO];
                
                */
            }
        }
    }
    
   
    
}
#pragma mark
#pragma mark alertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 7777) {
        
        NSLog(@"buttonIndex is %d",buttonIndex);
        if (buttonIndex == 0) {
            
            [self moreDetailAboutChatRoom];
        }
        
    }
}

-(void)getchatroomsuccess:(NSNotification *)notifation
{
    self.dic = notifation.userInfo;
    
//    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:self.dic];
//    [item setObject:@"53aa489a144452bc8f000001" forKey:@"im_topic_id"];
//    self.dic = item;
//    [item release];

    NSLog(@"\n############\n%@\n##############\n",self.dic);
    
    NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
    
    _userInfo = [[UserInfo alloc] init];
    _userInfo.user_id = [myDefault integerForKey:@"userid"];
    _userInfo.username = [myDefault objectForKey:@"username"];
    _userInfo.avatar = [myDefault objectForKey:@"usericon"];
    _userInfo.im_user_id = self.dic[@"im_user_id"];
    [[NSUserDefaults standardUserDefaults] setObject:self.dic[@"im_topic_id"] forKey:@"IM_TOPIC_ID"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
   
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"IM_Chatroom_ID"]) {
        NSString* chatroom_id=[[NSUserDefaults standardUserDefaults] objectForKey:@"IM_Chatroom_ID"];
        if (self.dic[@"chatroom_id"]) {
            NSString* str=self.dic[@"chatroom_id"];
            displayChatroomStaus=1;
            if (![str isEqualToString:chatroom_id]) {
                [[QYIMObject getInstance] disJoinChatRoomWithBlock:^(QYIMObject *imObject, BOOL isSuc){
                    
                }];
                //连接IM服务器
                [self connectIMServer];
            }else{
                [self connectIMServer];
            }
        }else{
            isActivityIndicatorView=NO;
            [_activityView stopAnimating];
            _chatButton.enabled=YES;
            displayChatroomStaus=0;
            [_chatButton setBackgroundImage:[UIImage imageNamed:@"bg_身边人2.png"] forState:UIControlStateNormal];
            [[QYIMObject getInstance] disJoinChatRoomWithBlock:^(QYIMObject *imObject, BOOL isSuc){
                
            }];
            //连接IM服务器
            [self connectIMServer];
        }
    }else{
        //连接IM服务器
        if (self.dic[@"chatroom_id"]) {
            //连接IM服务器
            [self connectIMServer];
            displayChatroomStaus=1;
        }else{
            _chatButton.enabled=YES;
            isActivityIndicatorView=NO;
            [_activityView stopAnimating];
            displayChatroomStaus=0;
            [_chatButton setBackgroundImage:[UIImage imageNamed:@"bg_身边人2.png"] forState:UIControlStateNormal];
        }
       
    }
    
    //********* Insert By ZhangDong Start 2014.5.13 End ***********
}

/**
 *  连接IM服务器
 */
- (void)connectIMServer
{
    if ([QYIMObject getInstance].connectStatus == QYIMConnectStatusOffLine) {
        NSString *userImId = self.dic[@"im_user_id"];
        [[QYIMObject getInstance] connect:userImId withBlock:^(QYIMObject *imObject, QYIMConnectStatus status) {
            if (status != QYIMConnectStatusOffLine) {
                [self checkJoined];
            }
        }];
    }else if ([QYIMObject getInstance].connectStatus != QYIMConnectStatusOffLine) {
        [self checkJoined];
    }
}

/**
 *  校验是否已经加入当前聊天室
 */
- (void)checkJoined
{
    NSString *topicId = self.dic[@"im_topic_id"];
    NSString *userImId = self.dic[@"im_user_id"];
    [[QYIMObject getInstance] getTopicInfo:topicId withBlock:^(QYIMObject *imObject, NSArray *userIds, BOOL isSuc) {
        if (isSuc) {
            BOOL isJoined = NO;
            for (NSString* userId in userIds) {
                if ([userId isEqualToString:userImId]) {
                    isJoined = YES; //如果当前聊天室成员的USERID和当前USERID相同，那么说明当前用户已经加入了这个聊天室
                    break;
                }
            }
            //聊天室人数
            _roomMemberCount = userIds.count;
            if (!isJoined) {
                [self joinTopic:_roomMemberCount];
            }else{
                [self showRoomCount:_roomMemberCount location:self.dic[@"chatroom_name"]];
            }
            
            [GlobalObject share].isInPublicRoom =  isJoined;
        }else{
            _isArrowExcption = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getLocationFailed" object:nil];
        }
    }];
}

/**
 *  加入聊天室
 */
- (void)joinTopic:(NSInteger)count
{
    NSString *topicId = self.dic[@"im_topic_id"];
    [[QYIMObject getInstance] joinChatRoomWithTopicId:topicId withBlock:^(QYIMObject *imObject, BOOL isSuc) {
        [imObject sendNewUserJoinMessageWithUsername:_userInfo.username];

        [[NSUserDefaults standardUserDefaults] setObject:self.dic[@"chatroom_id"] forKey:@"IM_Chatroom_ID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"========== joinChatRoom ========= ");
        NSLog(@"========== %d ========= ", isSuc);
        [self showRoomCount:count location:self.dic[@"chatroom_name"]];
        
        
        
    }];
}

/**
 *  显示身边人聊天室人员数量
 *
 *  @param count
 */
- (void)showRoomCount:(NSInteger)count location:(NSString*)_location
{
    displayChatroomStaus=1;
    _chatButton.enabled=YES;
    isActivityIndicatorView=NO;
    [_activityView stopAnimating];
    [_chatButton setBackgroundImage:[self getChatButtonImage:[UIImage imageNamed:@"bg_身边人.png"] count:[NSString stringWithFormat:@"%d", count] location:_location] forState:UIControlStateNormal];

    if ([GlobalObject share].isAuto) {
        [MobClick event:@"IMAutoJoinSuccess"];
    }else{
        
        [MobClick event:@"IMClickJoinSuccess"];
    }

}


#pragma mark -
#pragma mark --- 点击进入聊天室
-(void)clickChatButton
{
    
    if (limitMultiple == YES) {
        return;
    }
    limitMultiple = YES;
    [MobClick event:@"recClickIM"];

    
    if (displayChatroomStaus!=0) {
        GroupChatRoomViewController * groupChatVC = [[GroupChatRoomViewController alloc]init];
        
        if(self.dic)
        {
            groupChatVC.roomMemberCount = _roomMemberCount;
            groupChatVC.topicId = [self.dic objectForKey:@"im_topic_id"];
            groupChatVC.roomInfoDictionary = self.dic;
        }
        
        [self.currentVC.navigationController pushViewController:groupChatVC animated:YES];
        [groupChatVC release];
        
        
    }else{
        
        UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        [window.rootViewController.view addSubview:_chatchatroomAdvertiseView];
        [_chatchatroomAdvertiseView getChatroomStats];
        
    }
    
}

-(void)clickMeassageButton
{
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue];
    if (!isLogin) {
        //未登录状态用户提示登录
        CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
        navigationController.navigationBarHidden = YES;
        [currentVC presentViewController:navigationController animated:YES completion:nil];
        [cityLoginVC release];
        
    }else{
//        NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
//        NSInteger notificationUnreadCount=[myUserDefault integerForKey:NotificationUnreadCount];
//        if (notificationUnreadCount!=0) {
//            [[NSUserDefaults standardUserDefaults] setInteger:0  forKey:NotificationUnreadCount];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
        
        NoteAndChatViewController *noteVc = [[NoteAndChatViewController alloc]init];
        [self.currentVC.navigationController pushViewController:noteVc animated:YES];
        [noteVc release];
    }
   
}
-(void)moreDetailAboutChatRoom{
    
    DetailChatRoomController *detailVc = [[DetailChatRoomController alloc]init];
    [self.currentVC presentViewController:detailVc animated:YES completion:nil];
    [detailVc release];
}

-(void)setDisplayCahtroomAccessStatus{
   
    NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue];
    if (isLogin && userToken && userToken.length > 0 && [CLLocationManager authorizationStatus] != 2 ) {
        
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"IM_Chatroom_ID"]) {
                displayChatroomStaus=1;
            }
        
    }else{
        displayChatroomStaus=0;
    }
}
#pragma mark -
#pragma mark --- 构建view
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = RGB(231, 242, 248);

    page = 1;
    
    isActivityIndicatorView=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getchatroomsuccess:) name:@"getchatroomsuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLocationFailed) name:@"getLocationFailed" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startActivityIndicatorView) name:@"startActivityIndicatorView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reConnectSocket) name:@"reConnectSocket" object:nil];

//    
//    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
//    {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
    
    [self initHeadView];
    [self initRootView];

    //[self initChatroomAdvertiseView];
    /*
    CGRect viewBounds = [[UIScreen mainScreen] applicationFrame];
    
    self.viewController = [[[CDVWebMainViewController alloc] init] autorelease];
    
//    self.viewController.wwwFolderName = @"www";
//    self.viewController.startPage = @"index.html";
    if (ios7) {
        viewBounds.origin.y += 44;
    }else{
        viewBounds.origin.y += 24;
    }
    
    viewBounds.size.height -=ios7 ? 94 : 74;
    self.viewController.view.frame = viewBounds;
    ((CDVWebMainViewController*)self.viewController).currentVC=self.currentVC;
    [self.view addSubview:self.viewController.view];
    [self.view bringSubviewToFront:_headView];
    */

    _chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _chatButton.backgroundColor = [UIColor clearColor];
    _chatButton.frame = CGRectMake(230, 0, 82, 82);
    if(ios7)
    {
        _chatButton.frame = CGRectMake(230, 20, 80, 80);
    }
    [_chatButton setBackgroundImage:[UIImage imageNamed:@"bg_身边人2.png"] forState:UIControlStateNormal];
    if (displayChatroomStaus!=0) {
        _chatButton.enabled=NO;
    }
    
    
    [_chatButton addTarget:self action:@selector(clickChatButton) forControlEvents:UIControlEventTouchUpInside];
   
    [self.view addSubview:_chatButton];
    
    
    if(!_activityView)
    {
        _activityView = [[CDActivityIndicatorView alloc] initWithImage:[UIImage imageNamed:@"身边人loading.png"]];
    }
    _activityView.frame=CGRectMake(0, 0, 80, 80);
    [_activityView setFitFrame:YES];
    _activityView.backgroundColor = [UIColor clearColor];
    _activityView.center = _chatButton.center;
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue];
    if([CLLocationManager authorizationStatus] != 2 && isLogin)
    {
        [_activityView startAnimating];
        [_chatButton setBackgroundImage:[UIImage imageNamed:@"bg_身边人2.png"] forState:UIControlStateNormal];

    }
    
    [self.view addSubview:_activityView];
    
    _chatchatroomAdvertiseView=[[chatroomAdvertiseView alloc] initWithFrame:iPhone5? CGRectMake(0, 0, 320, 568): CGRectMake(0, 0, 320, 480)];
    _chatchatroomAdvertiseView.delegate=self;
    
    [self requestBaseDataFromServerIsFlush:NO];
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"recommendData"];
    if (dict == nil) {
        [self.view makeToastActivity];
    }
    
    
//    [self loadMayLikeData];
}

//-(void)updateYouMayLikeButton{
//    if ([[self.YouMayLikeDict objectForKey:@"status"] intValue] == 1) {
//        
//        _YouMayLikeLable.text = [[self.YouMayLikeDict objectForKey:@"data"] objectForKey:@"title"];
//        
//        MYLog(@"_YouMayLikeLable.text   =====  %@",_YouMayLikeLable.text);
//    }
//}


-(void)updateUIWithDict:(NSDictionary *)dic{
    
    if ([[dic objectForKey:@"status"] intValue] == 1) {
        
        myTableView.hidden = NO;
        [_topScrollView destroyTimer];
        
        [imagesArray removeAllObjects];
        
        [placesArray removeAllObjects];
        [discountArray removeAllObjects];
        [tripsArray removeAllObjects];
        
        [imagesArray addObjectsFromArray:[[dic objectForKey:@"data"] objectForKey:@"slide"]];
        [placesArray addObjectsFromArray:[[dic objectForKey:@"data"] objectForKey:@"place"]];
        
        /**
         *  折扣数据
         */
        NSArray *tempArr = [[dic objectForKey:@"data"] objectForKey:@"discount"];
        
        for (int i = 0; i<tempArr.count; i++) {
            NSDictionary *tempDict = [tempArr objectAtIndex:i];
            QYOperation *operation = [[[QYOperation alloc] initWithAttribute:tempDict]autorelease];
            [discountArray addObject:operation];
        }
        
        [tripsArray addObjectsFromArray:[[dic objectForKey:@"data"] objectForKey:@"trip"]];
        
        
        [_topScrollView reloadData];
        [myTableView reloadData];
        
        footView.isHaveData = YES;
        footView.hidden = NO;
        isLoading = NO;
        [footView changeLoadingStatus:isLoading];
        
        refeshControl.hidden = NO;
        [refeshControl endRefreshing];
        page = 2;
        
    }
}
#pragma mark
#pragma mark --requestBaseData
- (void)loadMayLikeData{
    
    [[QYAPIClient sharedAPIClient] getYouMayLikeSuccess:^(NSDictionary *dict) {
        
        self.YouMayLikeDict = dict;
        
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"recommendYouMayLike"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self tableView:myTableView heightForHeaderInSection:0];
            [self tableView:myTableView viewForHeaderInSection:0];
            [myTableView reloadData];
        });

    } failed:^{
        self.YouMayLikeDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"recommendYouMayLike"];
    }];
}

/**
 *  请求网络数据
 */
-(void)requestBaseDataFromServerIsFlush:(BOOL)flag{
    
    
    if (flag == NO) {
        
        
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"recommendData"];
        
        if (dict) {
            [self updateUIWithDict:dict];
        }
    }
#pragma mark- chenguanglin
    [self loadMayLikeData];
    
    [[QYAPIClient sharedAPIClient] getRecommandsSuccess:^(NSDictionary *dic) {
        
        NSArray * discount = [[dic objectForKey:@"data"]objectForKey:@"discount"];
        
        for (int i = 0; i < discount.count; i ++) {
            NSDictionary * dict = [discount objectAtIndex:i];
            if (![[dict objectForKey:@"url"] isKindOfClass:[NSString class]] || [[dict objectForKey:@"url"] isEqual:[NSNull null]]) {
                [dict setValue:@"" forKey:@"url"];
            }
        }
        
        [self updateUIWithDict:dic];

        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"recommendData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.view hideToastActivity];
        
    } failed:^{

        refeshControl.hidden = NO;
        [refeshControl endRefreshing];

        
        //本地没有缓存
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"recommendData"];
        if (dict == nil) {
            [super setNotReachableView:YES];

        }
        [self.view hideToastActivity];

    }];
    
}

-(void)touchesView{
    
    [super setNotReachableView:NO];
    [self.view makeToastActivity];
    [self requestBaseDataFromServerIsFlush:NO];
}

-(void)reConnectSocket{
    
    [self connectIMServer];
}
/*
-(void)privateChatUnReadMsgNum{
    NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
    NSInteger totalPriChatNum = [myUserDefault integerForKey:TotalPrivateChatNumber];
    
    NSInteger notificationUnreadCount=[myUserDefault integerForKey:NotificationUnreadCount];
    NSString* count=[NSString stringWithFormat:@"%d",notificationUnreadCount+totalPriChatNum];
    [button_meassage setBackgroundImage:[self getMessageButtonImage:[UIImage imageNamed:@"press_remind"] count:count] forState:UIControlStateNormal];
}*/

-(void)startActivityIndicatorView{
    isActivityIndicatorView=YES;
    if (isActivityIndicatorView) {
        [_activityView startAnimating];
        [_chatButton setBackgroundImage:[UIImage imageNamed:@"bg_身边人2.png"] forState:UIControlStateNormal];

    }
}

-(void)viewWillAppear:(BOOL)animated{
    
    [_topScrollView reloadData];
    
    
    
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"首屏推荐"];

    if (isActivityIndicatorView) {
        isActivityIndicatorView=NO;
        [_activityView startAnimating];
        [_chatButton setBackgroundImage:[UIImage imageNamed:@"bg_身边人2.png"] forState:UIControlStateNormal];

    }
    limitMultiple = NO;
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
    if (_topScrollView) {
        [_topScrollView destroyTimer];
    }
    
    [MobClick endLogPageView:@"首屏推荐"];
    
    limitMultiple = NO;

}
-(void)initRootView
{
    _backButton.hidden = YES;
    
    /**
     *  加入tableView
     */
    CGRect viewBounds = [[UIScreen mainScreen] applicationFrame];
    if (ios7) {
        viewBounds.origin.y += 44;
    }else{
        viewBounds.origin.y += 24;
    }
    viewBounds.size.height -=ios7 ? 94 : 94;

    myTableView = [[UITableView alloc]initWithFrame:viewBounds];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.separatorColor = [UIColor clearColor];
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:myTableView];
    [myTableView release];
    
    myTableView.hidden = YES;
    
//    [self.view sendSubviewToBack:myTableView];
//    [ChangeTableviewContentInset changeTableView:myTableView withOffSet:0];
    
    [self.view bringSubviewToFront:_headView];

    //[self createTableHeadViewUI];
    
    refeshControl = [[ODRefreshControl alloc]initInScrollView:myTableView];
    [refeshControl addTarget:self action:@selector(dropViewDidBeginRefreshing) forControlEvents:UIControlEventValueChanged];
    refeshControl.hidden = YES;
    [refeshControl release];
    
    footView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
    footView.hidden = YES;
    [myTableView setTableFooterView:footView];
    [footView release];
}

-(void)dropViewDidBeginRefreshing{
    
    footView.isHaveData = YES;
    footView.hidden = NO;
    isLoading = NO;
    [footView changeLoadingStatus:isLoading];
    
    
    if (refeshControl.hidden == YES) {
        return;
    }
    [self requestBaseDataFromServerIsFlush:YES];
}
/**
 *  创建表头
 */
-(void)createTableHeadViewUI{
    
   
}
/**
 *  选择分类，目前是锦囊和我的行程
 *
 *  @param btn
 */
-(void)buttonAction:(UIButton *)btn{
    
    if (limitMultiple == YES) {
        return;
    }
    limitMultiple = YES;
    
    if (btn.tag == 10) {//锦囊
        
        [MobClick event:@"recClickGuide"];
        
        GuideViewController *guideVc = [[GuideViewController alloc]init];
        guideVc.currentVC = self.currentVC;
        [self.currentVC.navigationController pushViewController:guideVc animated:YES];
        [guideVc release];
        
        
    }else if (btn.tag == 11){//我的行程
    
        [MobClick event:@"recClickPlan"];
        
        
        MyPlanViewController *planVc = [[MyPlanViewController alloc]init];
        [self.currentVC.navigationController pushViewController:planVc animated:YES];
        [planVc release];
    }
    else if (btn.tag == 12){//你可能喜欢的
        
        [MobClick event:@"recClickYouLike"];
        
        YouMayLikeViewController *likeVc = [[YouMayLikeViewController alloc]init];
        likeVc.YouMayLikeDict = [self.YouMayLikeDict objectForKey:@"data"];
        [self.currentVC.navigationController pushViewController:likeVc animated:YES];
        [likeVc release];
    }
    
}

-(void)initHeadView
{
//    float height_headView = (ios7 ? 20+44 : 44);
//    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headView)];
//    _headView.backgroundColor = [UIColor clearColor];
//    _headView.image = [UIImage imageNamed:@"home_head"];
//    _headView.userInteractionEnabled = YES;
//    [self.view addSubview:_headView];
//    
    
    
    //logo:
    _titleImageLogo = [[UIImageView alloc] initWithFrame:CGRectMake((320-70)/2, positionY_QYlogo, 70, 44)];
    _titleImageLogo.backgroundColor = [UIColor clearColor];
    _titleImageLogo.image = [UIImage imageNamed:@"logo"];
    [_headView addSubview:_titleImageLogo];
    
 
    /*
    //消息:
    button_meassage = [UIButton buttonWithType:UIButtonTypeCustom];
    button_meassage.frame = CGRectMake(5, positionY_button_more, 40, 40);
    NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
    NSInteger totalPriChatNum = [myUserDefault integerForKey:TotalPrivateChatNumber];
    
    NSInteger notificationUnreadCount=[myUserDefault integerForKey:NotificationUnreadCount];
    NSString* count=[NSString stringWithFormat:@"%d",notificationUnreadCount+totalPriChatNum];
    [button_meassage setBackgroundImage:[self getMessageButtonImage:[UIImage imageNamed:@"press_remind"] count:count] forState:UIControlStateNormal];
    [button_meassage addTarget:self action:@selector(clickMeassageButton) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:button_meassage];
    
    */
    
}
#pragma mark -
#pragma mark --- tableDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 1) {
        
        return placesArray.count;
        
    }else if (section == 2){
    
        
        return (discountArray.count + 1)/2;
        
    }else if (section == 3){
        
        return tripsArray.count;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        
        if (indexPath.row < placesArray.count - 1) {
            return 110;

        }else{
            
            return 120;
        }
    }
    if (indexPath.section == 2) {
        
        int count = (discountArray.count + 1)/2;
        
        if (indexPath.row < count - 1) {
            return 100;
        }else {
            return 110;
        }
    }
    if (indexPath.section == 3) {
        return 89;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        if (self.likeTitle.length > 0) {
            return btnLikeY + btnLikeH + 10;
        }else{
            return btnLikeY;
        }
    }
    if (section == 3) {
        return 40;
    }
    return 30;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        tableHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 170 + 84)];
        tableHeadView.backgroundColor = [UIColor clearColor];
        if (!_topScrollView) {
            _topScrollView = [[XLCycleScrollView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 170)];
            _topScrollView.tapEnabled = YES;
            _topScrollView.delegate = self;
            _topScrollView.datasource = self;
        }
        [tableHeadView addSubview:_topScrollView];
        
        for (int i = 0; i<2; i++) {
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10+155*i, 180, 145, 54)];
            button.tag = 10+i;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [tableHeadView addSubview:button];
            [button release];
            
//            UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 100, 20)];
//            lblTitle.font = [UIFont boldSystemFontOfSize:18.0];
//            lblTitle.textAlignment = NSTextAlignmentLeft;
//            lblTitle.backgroundColor = [UIColor clearColor];
//            lblTitle.textColor = [UIColor whiteColor];
//            [button addSubview:lblTitle];
//            [lblTitle release];
            
//            UILabel *lblSubTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 100, 15)];
//            lblSubTitle.font = [UIFont systemFontOfSize:12.0];
//            lblSubTitle.textAlignment = NSTextAlignmentLeft;
//            lblSubTitle.backgroundColor = [UIColor clearColor];
//            lblSubTitle.textColor = [UIColor whiteColor];
//            [button addSubview:lblSubTitle];
//            [lblSubTitle release];
            
            switch (i) {
                    
                case 0:
                    [button setImage:[UIImage imageNamed:@"bg_book"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"press_bg_book"] forState:UIControlStateHighlighted];
                    
//                    lblTitle.text = @"锦囊";
//                    lblSubTitle.text = @"热门锦囊推荐";
                    break;
                case 1:
                    [button setImage:[UIImage imageNamed:@"bg_plan"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"press_bg_plan"] forState:UIControlStateHighlighted];
                    
//                    lblTitle.text = @"我的行程";
//                    lblSubTitle.text = @"我的行程规划";
                    
                    break;
                default:
                    break;
            }
            
            
        }
#pragma mark-
#pragma mark --- chenguanglin
        
        if (self.likeTitle.length > 0) {
            _YouMayLikeButton = [[UIButton alloc]initWithFrame:CGRectMake(btnLikeX, btnLikeY, btnLikeW, btnLikeH)];
        }else{
            _YouMayLikeButton = [[UIButton alloc]initWithFrame:CGRectMake(btnLikeX, btnLikeY, btnLikeW, 0)];
        }
        _YouMayLikeButton.tag = 12;
        [_YouMayLikeButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_YouMayLikeButton setBackgroundImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        [_YouMayLikeButton setBackgroundImage:[UIImage imageNamed:@"press_like"] forState:UIControlStateHighlighted];
        [tableHeadView addSubview:_YouMayLikeButton];
        
        _YouMayLikeLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, btnLikeW - 60, btnLikeH)];
        _YouMayLikeLable.backgroundColor = [UIColor clearColor];
        _YouMayLikeLable.font = [UIFont systemFontOfSize:15];
        _YouMayLikeLable.textColor = [UIColor whiteColor];
        _YouMayLikeLable.text = self.likeTitle;
        
        [_YouMayLikeButton addSubview:_YouMayLikeLable];
        
        return tableHeadView;
    }else{
        
        UIView *view = [[[UIView alloc]init] autorelease];
        view.backgroundColor = self.view.backgroundColor;
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 200, 20)];
        if(!ios7)
        {
            lbl.frame = CGRectMake(10, 13, 200, 26);
        }
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.textColor = RGB(68, 68, 68);
        lbl.backgroundColor = [UIColor clearColor];
        lbl.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        [view addSubview:lbl];
        
        switch (section) {
            case 1:
                lbl.text = @"目的地推荐";
                
                break;
            case 2:
                lbl.text = @"精选折扣";
                break;
            case 3:
                lbl.text = @"精华游记";
                
                break;
                
            default:
                break;
        }
        [lbl release];
        return  view;
    }
    
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        
        static NSString *str = @"cell_poi";
        DestinationCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if (cell == nil) {
            cell = [[[DestinationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
        }
        [cell updateUIWithDict:[placesArray objectAtIndex:indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.section == 2) {
        
        
        static NSString *str = @"cell_discount";
        DiscountCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if (cell == nil) {
            cell = [[[DiscountCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
        }
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell updateCellWithLastMinuteDeal:discountArray index:indexPath.row];
        return cell;
        
        
    }else if (indexPath.section == 3) {
        
        static NSString *strInd = @"cell_travel";
        TripNewViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strInd];
        if (cell == nil) {
            cell = [[[TripNewViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strInd] autorelease];
        }
        [cell updateUIWithDict:[tripsArray objectAtIndex:indexPath.row]];
        if (indexPath.row == 0) {
            UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, 1)];
            line.image = [UIImage imageNamed:@"line1"];
            [cell addSubview:line];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        
        NSDictionary *dict = [placesArray objectAtIndex:indexPath.row];
        NSString *url = [dict objectForKey:@"url"];
        [self pushWebViewWithUrl:url withTitle:@"目的地推荐" isAddUMEvent:YES];
        
    }else if (indexPath.section == 2){
    
        
    }else if (indexPath.section == 3){
    
        NSDictionary *dict = [tripsArray objectAtIndex:indexPath.row];
        NSString *url = [dict objectForKey:@"view_url"];
        [self pushWebViewWithUrl:url withTitle:@"精华游记" isAddUMEvent:YES] ;
    }
}

#pragma mark
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    
    //YOUR_HEIGHT 为最高的那个headerView的高度
    CGFloat sectionHeaderHeight = btnLikeY;
    if (scrollView.contentOffset.y <= sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        
    }else{
        
//        scrollView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    }
    
    //如果正在刷新的，不能加载更多。
    if (refeshControl.refreshing == YES) {
        return;
    }
   
    if (footView.isHaveData == NO) {
        return;
    }
    
    if(myTableView.contentOffset.y + myTableView.frame.size.height - myTableView.contentSize.height >= 10 && isLoading == NO)
    {
        //NSLog(@"再去网上加载数据 ^ ^ ");
        isLoading = YES;
        
        [footView changeLoadingStatus:isLoading];
        
        [[QYAPIClient sharedAPIClient] getRecommandsTripByObjectId:nil type:@"index" pageSize:@"10" page:[NSString stringWithFormat:@"%d",page] success:^(NSDictionary *dic) {
            

            if ([[dic objectForKey:@"status"] intValue] == 1) {
    
                isLoading = NO;
                [footView changeLoadingStatus:isLoading];
                
                NSArray *array = [dic objectForKey:@"data"];
                
                if (array.count < 10) {
                    
                    footView.isHaveData = NO;
                    
                }else{
                    
                    footView.isHaveData = YES;
                }
                
                footView.hidden = NO;

                if (refeshControl.refreshing == NO) {
              
                    page ++;
                    [tripsArray addObjectsFromArray:array];
                    [myTableView reloadData];
                }
               
            }
            
        } failed:^{
            
            isLoading = NO;
            [footView changeLoadingStatus:isLoading];
            
        }];
    }
    
}

#pragma mark
#pragma mark  XLCycleScrollViewDelegate
- (NSInteger)numberOfPages
{
    
    return [imagesArray count];
    /*
    
   
        
    if (_countryModel == nil) {
            return 0;
    }
    //保证有一张封面图
    if (_countryModel.photoArray.count == 0) {
        [_countryModel.photoArray addObject:@""];
    }
        
    return _countryModel.photoArray.count;
    
    */
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    UIImageView*_topImageView = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 170)] autorelease];
    _topImageView.backgroundColor = [UIColor clearColor];
    _topImageView.userInteractionEnabled = YES;
    _topImageView.contentMode = UIViewContentModeScaleAspectFill;
    _topImageView.clipsToBounds = YES;
    
    if (imagesArray.count > index) {
        NSDictionary *tempDict = [imagesArray objectAtIndex:index];
        [_topImageView setImageWithURL:[NSURL URLWithString:[tempDict objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"default_co_back"]];
    }
    return _topImageView;
}
/**
 *  点击运营位置图片事件
 *
 *  @param tapGesture
 */
//-(void)tapTopImageAction:(UITapGestureRecognizer *)tapGesture{
//    
//    int index = [tapGesture view].tag - 100;
//    NSDictionary *tempDict = [imagesArray objectAtIndex:index];
//    NSString *url = [tempDict objectForKey:@"url"];
//    NSArray *tempArr = [self spliteRedictUrl:url withSeparated:URL_REDIRECT_STRING];
//    
//}
- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index
{
    
    if (limitMultiple == YES) {
        return;
    }
    limitMultiple = YES;
    
    [MobClick event:@"recClickAD"];
    
    NSDictionary *tempDict = [imagesArray objectAtIndex:index];
    NSString *url = [tempDict objectForKey:@"url"];
    NSLog(@"url is %@",url);
    

    NSArray* _array = [self spliteRedictUrl:url withSeparated:URL_REDIRECT_STRING];
    if (_array.count>1) {
        
        if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_COUNTRY]) {

            CountryViewController *countryVc = [[CountryViewController alloc]init];
            countryVc.type =1;
            countryVc.key = [_array objectAtIndex:2];
            [self.currentVC.navigationController pushViewController:countryVc animated:YES];
            [countryVc release];
            
            return;

        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_CITY]){

            CountryViewController *countryVc = [[CountryViewController alloc]init];
            countryVc.type = 2;
            countryVc.key = [_array objectAtIndex:2];
            [self.currentVC.navigationController pushViewController:countryVc animated:YES];
            [countryVc release];
            
            return;


        }else if ([[_array objectAtIndex:0] isEqualToString:URL_REDIRECT_GUIDE]){

            GuideDetailViewController *guideDetailVC = [[GuideDetailViewController alloc] init];
            
            guideDetailVC.guideId = [_array objectAtIndex:1];
            guideDetailVC.flag_new = YES;
            [guideDetailVC setGuide:[QYGuideData getGuideById:[_array objectAtIndex:1]]];
            [self.currentVC.navigationController pushViewController:guideDetailVC animated:YES];
            [guideDetailVC release];
            
            return;
            

        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_POI]){

            PoiDetailViewController *poiDetailVC = [[PoiDetailViewController alloc] init];
            poiDetailVC.poiId = [[_array objectAtIndex:2] integerValue];
            [self.currentVC.navigationController pushViewController:poiDetailVC animated:YES];
            [poiDetailVC release];
            
            return;
            
        }else if ([[_array objectAtIndex:0] isEqualToString:URL_REDIRECT_BBS]){
            
            [self pushWebViewWithUrl:url withTitle:[self getTitleStringWithUrl:url]  isAddUMEvent:NO];
            return;


        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_TRIP]){
            
            [self pushWebViewWithUrl:url withTitle:[self getTitleStringWithUrl:url]  isAddUMEvent:NO];
            return;

        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_QUESTION]){
            
            [self pushWebViewWithUrl:url withTitle:[self getTitleStringWithUrl:url] isAddUMEvent:NO];
            return;


        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_LASTMINUTE]){
            
            [MobClick event:@"recClickDisc"];

            
//            LastMinuteDetailViewController * lastDetailVC = [[LastMinuteDetailViewController alloc]init];
//            lastDetailVC.dealID = [[_array objectAtIndex:2] integerValue];

//            LastMinuteDetailViewController * lastDetailVC = [[LastMinuteDetailViewController alloc]init];
//            lastDetailVC.dealID = [[_array objectAtIndex:2] integerValue];
//            [self.currentVC.navigationController pushViewController:lastDetailVC animated:YES];
//            [lastDetailVC release];
            
            //by jessica
            LastMinuteDetailViewControllerNew * lastDetailVC = [[LastMinuteDetailViewControllerNew alloc]init];
            lastDetailVC.lastMinuteId = [[_array objectAtIndex:2] integerValue];
            lastDetailVC.source = NSStringFromClass([self class]);
            [self.currentVC.navigationController pushViewController:lastDetailVC animated:YES];
            [lastDetailVC release];
            
            return;

        }
    }
    
    NSRange foundObj=[url rangeOfString:URL_REDIRECT_PLACE options:NSCaseInsensitiveSearch];
    if (foundObj.length>0) {
        [self pushWebViewWithUrl:url withTitle:@"目的地推荐" isAddUMEvent:NO];
        return ;

    }
    foundObj=[url rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
    if (foundObj.length > 0){

        WebViewViewController *webVC_inApp = [[WebViewViewController alloc] init];
        [webVC_inApp setStartURL:url];
        [self.currentVC presentViewController:[QYToolObject getControllerWithBaseController:webVC_inApp] animated:YES completion:nil];
        [webVC_inApp release];
        
        return ;

    }
}

-(void)pushWebViewWithUrl:(NSString*)_url withTitle:(NSString*)_strTitle isAddUMEvent:(BOOL)flag
{
    _url = [_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([_strTitle isEqualToString:@"精华游记"]) {
        
        if (flag == YES) {
            [MobClick event:@"recClickJournal"];
        }
        BBSDetailViewController * bbsDetailVC = [[BBSDetailViewController alloc]init];
        bbsDetailVC.bbsAllUserLink = _url;
        //bbsDetailVC.bbsAuthorLink = travalll.str_travelUrl_onlyauthor;
        [self.currentVC.navigationController pushViewController:bbsDetailVC animated:YES];
        [bbsDetailVC release];
    }
    
    else{
        
        if (flag == YES) {
            [MobClick event:@"recClickDest"];
        }
        
        loadCDWebViewShellViewController* cdMianWeb=[[loadCDWebViewShellViewController alloc] initWithTitle:_strTitle];
        cdMianWeb._redicteUrl=[NSURL URLWithString:_url];
        cdMianWeb._titleLabel.text=_strTitle;
        [self.currentVC.navigationController pushViewController:cdMianWeb animated:YES];
        [cdMianWeb release];
    }
}

#pragma mark
#pragma mark -- 折扣代理

//显示折扣详情界面
- (void)showLastMinuteDetailViewControllerWithId:(NSInteger)aId
{
//    LastMinuteDetailViewController *lastMinuteDetailVC = [[[LastMinuteDetailViewController alloc] init] autorelease];
//    [lastMinuteDetailVC setDealID:aId];

//    LastMinuteDetailViewController *lastMinuteDetailVC = [[[LastMinuteDetailViewController alloc] init] autorelease];
//    [lastMinuteDetailVC setDealID:aId];
//    [self.currentVC.navigationController pushViewController:lastMinuteDetailVC animated:YES];
    
    //by jessica
    LastMinuteDetailViewControllerNew *lastMinuteDetailVC = [[[LastMinuteDetailViewControllerNew alloc] init] autorelease];
    [lastMinuteDetailVC setLastMinuteId:aId];
    lastMinuteDetailVC.source = NSStringFromClass([self class]);
    [self.currentVC.navigationController pushViewController:lastMinuteDetailVC animated:YES];
}


-(void)clickDiscount:(int)index{
    
    if (limitMultiple == YES) {
        return;
    }
    limitMultiple = YES;

    
    QYOperation *operation = [discountArray objectAtIndex:index];
    switch ([operation.openType intValue]) {
        case 1:
        {
          
            [MobClick event:@"recClickDisc"];
            //显示折扣详情界面
            [self showLastMinuteDetailViewControllerWithId:[[[operation operationIds] objectAtIndex:0] intValue]];
            
        }
            break;
        case 2:
        {
            [MobClick event:@"recClickDisc"];

            //显示专题页面
            SubjectViewController *subjectVC = [[[SubjectViewController alloc] init] autorelease];
            subjectVC.operation = operation;
            subjectVC.operationIds = [operation operationIds];
         // subjectVC.lastMinuteArray = [NSMutableArray arrayWithArray:data];
            [self.currentVC.navigationController pushViewController:subjectVC animated:YES];

            
        }
            break;
        case 3:
        {
            [MobClick event:@"recClickDisc"];

            WebViewViewController *webVC = [[[WebViewViewController alloc] init] autorelease];
            [webVC setStartURL:operation.operationUrl];
            [webVC.label_title setText:@"穷游折扣"];
            [self.currentVC presentViewController:[QYToolObject getControllerWithBaseController:webVC] animated:YES completion:^{
                
            }];
            
        }
            break;
        case 4:
        {
            [MobClick event:@"recClickDisc"];

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[operation operationUrl]]];
            limitMultiple = NO;
        }
            break;
        default:
            break;
    }
}
#pragma mark -
#pragma mark --- 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark
#pragma mark -- 解析URL地址
-(NSArray*)spliteRedictUrl:(NSString*)_url withSeparated:(NSString*)_separated{
    NSString *strUrl = [_url stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableArray* _array=[NSMutableArray arrayWithArray:[strUrl componentsSeparatedByString:_separated]];
    
    if (_array.count>1) {
        NSString* strTemp=[_array objectAtIndex:1];
        _array=[NSMutableArray arrayWithArray:[strTemp componentsSeparatedByString:@"/"]];
        if ([[_array objectAtIndex:0] isEqualToString:@""]) {
            [_array removeObjectAtIndex:0];
        }
        if ([[_array lastObject] isEqualToString:@""]) {
            [_array removeLastObject];
        }
    }
    return _array;
}

-(NSString*)getTitleStringWithUrl:(NSString*)_url{
    
    NSString* strValue=nil;
    NSArray* _array=[self spliteRedictUrl:_url withSeparated:URL_REDIRECT_STRING];
    if (_array.count>1) {
        if ([[_array objectAtIndex:0] isEqualToString:URL_REDIRECT_TRIP]) {
            strValue=@"行程" ;
        }
        if ([[_array objectAtIndex:0] isEqualToString:URL_REDIRECT_BBS]) {
            strValue=@"精华游记" ;
        }
        if ([[_array objectAtIndex:0] isEqualToString:URL_REDIRECT_QUESTION]) {
            strValue=@"问答" ;
        }else{
            //strValue=@"目的地" ;
        }
    }
    
    return strValue;
}

/**
 *  把数组格式的userIds转换成用“,”分隔的字符串格式
 *
 *  @param userIds 数组
 *
 *  @return 字符串
 */
- (NSString*)getUserIdsWithUserArray:(NSArray*)userIds
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:userIds];
    return [array componentsJoinedByString:@","];;
}

@end
