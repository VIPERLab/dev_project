//
//  RootViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "RootViewController.h"
#import "DownloadViewController.h"
#import "SearchViewController.h"
#import "BookMarkViewController.h"
#import "MoreViewController.h"
#import "MobClick.h"
#import "QYGuideData.h"
#import "RecommendViewController.h"
#import "PlaceViewController.h"
#import "LastMinuteViewController.h"
#import "ActivityViewController.h"
#import "MineViewController.h"
#import "CityLoginViewController.h"

#define     RecommendButtonTag      1
#define     PlaceButtonTag          2
#define     ReservationButtonTag    3
#define     MineButtonTag           4


#define     height_headerView               (ios7 ? (44+20) : 44)
#define     positionY_QYlogo                (ios7 ? (10+20) : 10)
#define     positionY_QYWordlogo            (ios7 ? (10+20) : 10)
#define     positionY_button_bookmark       (ios7 ? 20 : 0)
#define     positionY_button_search         (ios7 ? 20 : 0)
#define     positionY_button_more           (ios7 ? 20 : 0)




@interface RootViewController ()

@end


@implementation RootViewController
@synthesize currentViewController = _currentViewController;
@synthesize headView = _headView;
@synthesize titleImageLogo = _titleImageLogo;
@synthesize footView = _footView;
@synthesize updateCountButton = _updateCountButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}
-(id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNeedUpdatedGuide) name:@"someGuideNeedToBeUpdated" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNeedUpdatedGuide) name:@"updateNumOfGuideNeedToBeUpdated" object:nil];
        
        
        //************ Insert By ZhangDong 2014.4.3 Start ***********
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(footViewHidden:) name:@"footViewHidden" object:nil];
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActivityView) name:@"showActivityView" object:nil];
        //************ Insert By ZhangDong 2014.4.3 End ***********
        
        
        _mineVC = [[MineViewController alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isShowNoteMsg:) name:@"isShowNoteMsg" object:nil];
        
        
        
    }
    return self;
}
-(void)isShowNoteMsg:(NSNotification *)aNote{
    NSDictionary *item = aNote.userInfo;
    noteImageView.hidden = [item[@"count"] boolValue];
}
/**
 *  控制底部视图是否隐藏
 *
 *  @param notification
 */
- (void)footViewHidden:(NSNotification*)notification
{
    _footView.hidden = [notification.userInfo[@"hidden"] boolValue];
}

/**
 *  显示活动视图
 */
//- (void)showActivityView
//{
//    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
//    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    
//    NSDate *startDate = [dateformat dateFromString:kStartDateStr];
//    NSDate *endDate = [dateformat dateFromString:kEndDateStr];
//    NSDate *nowDate = [[NSDate alloc] init];
//    
//    //当前日期 在 开始活动日期 和 结果活动日期 之内，弹出活动视图
//    if ([startDate compare:nowDate] == NSOrderedAscending &&
//        [nowDate compare:endDate] == NSOrderedAscending) {
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"footViewHidden" object:nil userInfo:@{@"hidden":@YES}];
//        
//        ActivityViewController *viewController = [[ActivityViewController alloc] init];
//        [self presentViewController:viewController animated:YES completion:nil];
//        [viewController release];
//    }
//    [nowDate release];
//    [dateformat release];
//}

-(void)dealloc
{
    self.currentViewController = nil;
    
    QY_VIEW_RELEASE(_titleImageLogo);
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_footView);
    
    QY_SAFE_RELEASE(_recommendVC);
    QY_SAFE_RELEASE(_placeVC);
    QY_SAFE_RELEASE(_lastMinuteVC);
    QY_SAFE_RELEASE(_mineVC);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- DidAppear & DidDisappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(_flag_pushVC)
    {
        switch (_selectedVC_state)
        {
            case recommendVC_state:
            {
                NSLog(@"  popTo 推荐页");
            }
                break;
                
            case placeVC_state:
            {
                NSLog(@"  popTo 目的地页");
            }
                break;
                
            case reservationVC_state:
            {
                NSLog(@"  popTo 折扣页");
            }
                break;
                
            case mine_state:
            {
                NSLog(@"  popTo 个人中心页");
                [_mineVC resetView]; //当退出登录后需要重新调整view
            }
                break;
                
            default:
                break;
        }
    }
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _flag_pushVC = YES;
}


-(void)end
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}
-(void)begin
{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didChangeStatusBarFrame:)
//                                                 name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
//    
//    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
//    if (rect.size.height == 40) //状态条放大状态
//    {
//        CGRect rt = self.view.frame;
//        rt.size.height -= 20;
//        self.view.frame = rt;
//        [self higherSubviews];
//    }
//    else
//    {
//        CGRect rt = self.view.frame;
//        rt.size.height += 20;
//        self.view.frame = rt;
//        [self lowerSubviews];
//    }
}


#pragma mark -
#pragma mark --- 构建View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _flag_pushVC = NO;
    [self initRootView];
    [self setNavigationBar];
    [self initFootView];
}
-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerView)];
    _headView.backgroundColor = [UIColor colorWithRed:43/255. green:171/255. blue:121/255. alpha:1];
    //_headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    _headView.hidden = YES;
    
    
    //logo:
    _titleImageLogo = [[UIImageView alloc] initWithFrame:CGRectMake(8, positionY_QYlogo, 24, 24)];
    _titleImageLogo.image = [UIImage imageNamed:@"home_qyer_logo"];
    [_headView addSubview:_titleImageLogo];
    UIImageView *_titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(36, positionY_QYWordlogo, 95, 24)];
    _titleImageView.image = [UIImage imageNamed:@"home_qyer_guide"];
    [_headView addSubview:_titleImageView];
    [_titleImageView release];
    [self.view addSubview:_headView];
    
    
    //书签:
    UIButton *button_bookmark = [UIButton buttonWithType:UIButtonTypeCustom];
    button_bookmark.frame = CGRectMake(206, positionY_button_bookmark, 76/2, 62/2);
    [button_bookmark setBackgroundImage:[UIImage imageNamed:@"btn_bookmark"] forState:UIControlStateNormal];
    [button_bookmark addTarget:self action:@selector(clickBookmarkButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:button_bookmark];
    
    
    //搜索🔍:
    UIButton *button_search = [UIButton buttonWithType:UIButtonTypeCustom];
    button_search.frame = CGRectMake(280, positionY_button_search, 80/2, 80/2);
    button_search.backgroundColor = [UIColor clearColor];
    [button_search setBackgroundImage:[UIImage imageNamed:@"btn_search"] forState:UIControlStateNormal];
    [button_search addTarget:self action:@selector(clickSearchButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:button_search];
    
    
    //更多:
    UIButton *button_more = [UIButton buttonWithType:UIButtonTypeCustom];
    button_more.frame = CGRectMake(282, positionY_button_more, 76/2, 62/2);
    [button_more setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [button_more addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:button_more];
}
-(void)initFootView
{
    if(ios7)
    {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - RootViewControllerFootViewHeight, 320, RootViewControllerFootViewHeight)];
    }
    else
    {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height-20) - RootViewControllerFootViewHeight, 320, RootViewControllerFootViewHeight)];
    }
    _footView.tag = 6666;
    _footView.backgroundColor = [UIColor whiteColor];
    //_footView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"qyer_background"]];
    [self.view addSubview:_footView];
    
    [self initButtonInFootView];
}
-(void)initButtonInFootView
{
    _button_recommend = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_recommend.frame = CGRectMake(0, 0, 80, 98/2);
    [_button_recommend setBackgroundImage:[UIImage imageNamed:@"featured"] forState:UIControlStateNormal];
    [_button_recommend setBackgroundImage:[UIImage imageNamed:@"highlight_featured"] forState:UIControlStateSelected];
    [_button_recommend addTarget:self action:@selector(clickRecommendButton) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:_button_recommend];
    _button_recommend.tag = RecommendButtonTag;
    
    
    _button_place = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_place.frame = CGRectMake(80, 0, 80, 98/2);
    [_button_place setBackgroundImage:[UIImage imageNamed:@"destination"] forState:UIControlStateNormal];
    [_button_place setBackgroundImage:[UIImage imageNamed:@"highlight_destination"] forState:UIControlStateSelected];
    [_button_place addTarget:self action:@selector(clickPlaceButton) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:_button_place];
    _button_place.tag = PlaceButtonTag;
    
    
    _button_reservation = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_reservation.frame = CGRectMake(80*2, 0, 80, 98/2);
    [_button_reservation setBackgroundImage:[UIImage imageNamed:@"sale"] forState:UIControlStateNormal];
    [_button_reservation setBackgroundImage:[UIImage imageNamed:@"highlight_sale"] forState:UIControlStateSelected];
    [_button_reservation addTarget:self action:@selector(clickReservationButton) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:_button_reservation];
    _button_reservation.tag = ReservationButtonTag;
    
    
    
    _button_mine = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_mine.frame = CGRectMake(80*3, 0, 80, 98/2);
    [_button_mine setBackgroundImage:[UIImage imageNamed:@"userCenter"] forState:UIControlStateNormal];
    [_button_mine setBackgroundImage:[UIImage imageNamed:@"highlight_userCenter"] forState:UIControlStateSelected];
    [_button_mine addTarget:self action:@selector(clickMineButton) forControlEvents:UIControlEventTouchUpInside];
    [_footView addSubview:_button_mine];
    _button_mine.tag = MineButtonTag;
    
    /**
     *  加入消息提醒红点
     */
    noteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(285, 8, 8, 8)];
    noteImageView.backgroundColor = [UIColor redColor];
    noteImageView.layer.cornerRadius = 4.0;
    noteImageView.layer.masksToBounds = YES;
    noteImageView.hidden = YES;
    [_footView addSubview:noteImageView];
    [noteImageView release];
    
    
    [self clickRecommendButton];
    //*** 初始选中的button:
    //[self performSelector:@selector(clickRecommendButton) withObject:nil afterDelay:0];
}




#pragma mark -
#pragma mark --- 更多页面
-(void)clickMoreButton:(id)sender
{
    MoreViewController *moreVC = [[MoreViewController alloc] init];
    [self.navigationController pushViewController:moreVC animated:YES];
    [moreVC release];
}



#pragma mark -
#pragma mark --- 点击tabbar事件
-(void)clickRecommendButton
{
    if([_button_recommend isSelected])
    {
        return;
    }
    if ([_button_place isSelected] || [_button_reservation isSelected] || [_button_mine isSelected]) {
        
        [MobClick event:@"clickRec"];
    }
    [_button_recommend setSelected:YES];
    _selectedVC_state = recommendVC_state;  //标识当前选择的是推荐页
    
    [self initButtonInFootViewState:_button_recommend.tag];
    [self resetCurrentView:_button_recommend.tag];
}
-(void)clickPlaceButton
{
    if([_button_place isSelected])
    {
        return;
    }
    
    [MobClick event:@"clickDest"];
    
    _selectedVC_state = placeVC_state;  //标识当前选择的是目的地页
    
    [_button_place setSelected:YES];
    [self initButtonInFootViewState:_button_place.tag];
    [self resetCurrentView:_button_place.tag];
}
-(void)clickReservationButton
{
    if([_button_reservation isSelected])
    {
        return;
    }
    _selectedVC_state = reservationVC_state;  //标识当前选择的是预定页
    
    [MobClick event:@"clickDisc"];
    
    [_button_reservation setSelected:YES];
    [self initButtonInFootViewState:_button_reservation.tag];
    [self resetCurrentView:_button_reservation.tag];
}
-(void)clickMineButton
{
    if([_button_mine isSelected])
    {
        return;
    }
    
    [MobClick event:@"clickMine"];
    
    _selectedVC_state = mine_state;  //标识当前选择的是个人中心页
    [_button_mine setSelected:YES];
    [self initButtonInFootViewState:_button_mine.tag];
    [self resetCurrentView:_button_mine.tag];
}
-(void)initButtonInFootViewState:(NSInteger)buttonTag
{
    switch (buttonTag)
    {
        case RecommendButtonTag: //推荐
        {
            [_button_place setSelected:NO];
            [_button_reservation setSelected:NO];
            [_button_myPlan setSelected:NO];

            [_button_mine setSelected:NO];

        }
            break;
            
        case PlaceButtonTag: //目的地
        {
            [_button_recommend setSelected:NO];
            [_button_myPlan setSelected:NO];
            [_button_reservation setSelected:NO];
            [_button_mine setSelected:NO];
            
        }
            break;
            
        case ReservationButtonTag: //预定
        {
            [_button_recommend setSelected:NO];
            [_button_place setSelected:NO];
            [_button_myPlan setSelected:NO];

            [_button_mine setSelected:NO];
            
        }

            break;
            
        case MineButtonTag: //个人中心
        {
            [_button_recommend setSelected:NO];
            [_button_place setSelected:NO];
            [_button_reservation setSelected:NO];
            [_button_myPlan setSelected:NO];
            
        }
            break;
            
        default:
            break;
    }
}
-(void)resetCurrentView:(NSInteger)buttonTag
{
    switch (buttonTag)
    {
        case RecommendButtonTag: //推荐
        {
            if(self.currentViewController)
            {
                [self.currentViewController.view removeFromSuperview];
            }
            if(_mineVC && _mineVC.loginVC)
            {
                _mineVC.loginVC.view.hidden = YES;
            }
            if(!_recommendVC)
            {
                _recommendVC = [[RecommendViewController alloc] init];
            }
            _recommendVC.currentVC = self;
            self.currentViewController = _recommendVC;
            [self.view insertSubview:self.currentViewController.view atIndex:0];
            [self.view bringSubviewToFront:_headView];
            [self.view bringSubviewToFront:_footView];
            
        }
            break;
            
        case PlaceButtonTag: //目的地
        {
            if(self.currentViewController)
            {
                [self.currentViewController.view removeFromSuperview];
            }
            if(!_placeVC)
            {
                _placeVC = [[PlaceViewController alloc] init];
            }
            _placeVC.currentVC = self;
            self.currentViewController = _placeVC;
            [self.view insertSubview:self.currentViewController.view atIndex:0];
            [self.view bringSubviewToFront:_headView];
            [self.view bringSubviewToFront:_footView];
            
        }
            break;
            
        case ReservationButtonTag: //折扣
        {
            if(self.currentViewController)
            {
                [self.currentViewController.view removeFromSuperview];
            }
            if(!_lastMinuteVC)
            {
                _lastMinuteVC = [[LastMinuteViewController alloc] init];
            }
            if(_mineVC && _mineVC.loginVC)
            {
                _mineVC.loginVC.view.hidden = YES;
            }
            _lastMinuteVC.homeViewController = self;
            self.currentViewController = _lastMinuteVC;
            [self.view insertSubview:self.currentViewController.view atIndex:0];
            [self.view bringSubviewToFront:_headView];
            [self.view bringSubviewToFront:_footView];
            
        }
            break;
            
        case MineButtonTag: //个人中心
        {
            if(self.currentViewController)
            {
                [self.currentViewController.view removeFromSuperview];
            }
            if(!_mineVC)
            {
                _mineVC = [[MineViewController alloc] init];
            }
            if(_mineVC.loginVC)
            {
                _mineVC.loginVC.view.hidden = YES;
            }
            _mineVC.currentVC = self;
            _mineVC.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue];
            self.currentViewController = _mineVC;
            [self.view insertSubview:self.currentViewController.view atIndex:0];
            [self.view bringSubviewToFront:_headView];
            [self.view bringSubviewToFront:_footView];
        }
            break;
            
        default:
            break;
    }
}



#pragma mark -
#pragma mark --- 设置我的锦囊页面的需要更新的锦囊的数目
-(void)processNeedUpdatedGuide
{
//    if(![[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] || [[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated].count == 0)
//    {
//        [_updateCountButton setTitle:@"" forState:UIControlStateNormal];
//        _updateCountButton.hidden = YES;
//    }
//    else
//    {
//        NSInteger number = [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] count];
//        [_updateCountButton setTitle:[NSString stringWithFormat:@"%d",number] forState:UIControlStateNormal];
//        _updateCountButton.hidden = NO;
//    }
}


#pragma mark -
#pragma mark --- notif status bar
-(void)didChangeStatusBarFrame:(NSNotification *)notification
{
    NSLog(@" 状态栏发生了变化  状态栏发生了变化");
    NSValue *statusBarFrameValue = [notification.userInfo valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    
    // TODO: react on changes of status bar height (e.g. incoming call, tethering, ...)
    
    CGRect rect = [statusBarFrameValue CGRectValue];
    if (rect.size.height == 40) //状态条放大状态
    {
        CGRect rt = self.view.frame;
        rt.size.height -= 20;
        self.view.frame = rt;
        [self higherSubviews];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"hotdot"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        CGRect rt = self.view.frame;
        rt.size.height += 20;
        self.view.frame = rt;
        [self lowerSubviews];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hotdot"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void)lowerSubviews
{
    NSLog(@"  lower - Subviews  lower - Subviews");
    
    for (UIView *aview in [self.view subviews] )
    {
        if (aview.tag == 6666)
        {
            CGRect rect = aview.frame;
            if(ios7)
            {
                rect.origin.y = [[UIScreen mainScreen] bounds].size.height - RootViewControllerFootViewHeight;
            }
            else
            {
                rect.origin.y = ([[UIScreen mainScreen] bounds].size.height-20) - RootViewControllerFootViewHeight;
            }
            aview.frame = rect;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hotdot_phone" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"type", nil]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hotdot_phone"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)higherSubviews
{
    NSLog(@"  higher - Subviews  higher - Subviews");
    
    for (UIView *aview in [self.view subviews])
    {
        if (aview.tag == 6666)
        {
            CGRect rect = aview.frame;
            if(ios7)
            {
                rect.origin.y = [[UIScreen mainScreen] bounds].size.height - RootViewControllerFootViewHeight-20;
            }
            else
            {
                rect.origin.y = ([[UIScreen mainScreen] bounds].size.height-20) - RootViewControllerFootViewHeight-20;
            }
            aview.frame = rect;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hotdot_phone" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"type", nil]];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hotdot_phone"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}





#pragma mark -
#pragma mark --- 搜索 & 书签
-(void)clickBookmarkButton:(id)sender
{
    BookMarkViewController *bookMarkVC = [[BookMarkViewController alloc] init];
    [self.navigationController pushViewController:bookMarkVC animated:YES];
    [bookMarkVC release];
}
-(void)clickSearchButton:(id)sender
{
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [searchVC release];
    navVC.navigationBarHidden = YES;
    //[self presentModalViewController:navVC animated:YES];
    [self presentViewController:navVC animated:YES completion:nil];
    [navVC release];
}


#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
