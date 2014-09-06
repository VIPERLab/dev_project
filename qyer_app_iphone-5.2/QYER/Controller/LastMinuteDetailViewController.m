//
//  LastMinuteDetailViewController.m
//  QYER
//
//  Created by Leno（蔡小雨） on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "LastMinuteDetailViewController.h"

#import "WebViewViewController.h"
#import "CityLoginViewController.h"
#import "Toast+UIView.h"
#import "NSString+SBJSON.h"
#import "QYAPIClient.h"
#import "QyYhConst.h"
#import "QyerSns.h"

#import "Reachability.h"

#import "QYTime.h"

#define Key_Time_Days           @"Time_Days"
#define Key_Time_Hours          @"Time_Hours"
#define Key_Time_Minutes        @"Time_Minutes"
#define Key_Time_Seconds        @"Time_Seconds"

//timeTable
#define  xPadding                 10.0f
#define  yPadding                 35.0f-2
#define  widthTip                 23.0f//56
#define  widthUnit                11.0f//天


typedef enum {
    BottomStyleNormal,
    BottomStyleNormalNotStart,
    BottomStyleNormalEnd
} BottomStyle;

typedef enum {
    OnsaleTypeOff = 0,//下架
    OnsaleTypeOn = 1//在售
} OnsaleType;

@interface LastMinuteDetailViewController ()

@property (nonatomic, retain) UIButton *collectButton;
@property (nonatomic, retain) UIButton *cancelCollectButton;

@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, retain) UIImageView              *styleEmptyContentView;//空白
@property (nonatomic, retain) UIImageView              *styleNormalContentView;//不能进行购买
@property (nonatomic, retain) UIImageView              *styleNormalNotStartContentView;//不能进行购买 已开始
@property (nonatomic, retain) UIImageView              *styleNormalEndContentView;//不能进行购买 已结束

@property (nonatomic, retain) UIView                   *timeTableContentView;

//已开始 Tip
@property (nonatomic, retain) UILabel                  *styleStartingTipDaysLabel;//天
@property (nonatomic, retain) UILabel                  *styleStartingTipHoursLabel;//小时
@property (nonatomic, retain) UILabel                  *styleStartingTipMinutesLabel;//分
@property (nonatomic, retain) UILabel                  *styleStartingTipSecondsLabel;//秒

//已开始
@property (nonatomic, retain) UILabel                  *styleStartingDaysLabel;//天
@property (nonatomic, retain) UILabel                  *styleStartingHoursLabel;//小时
@property (nonatomic, retain) UILabel                  *styleStartingMinutesLabel;//分
@property (nonatomic, retain) UILabel                  *styleStartingSecondsLabel;//秒

@property (nonatomic, retain) UIButton                 *lmBookButton;
@property (nonatomic, retain) UILabel                  *lmTimeLabel;

@property (nonatomic, assign) __block int               timeout;
@property (nonatomic, assign) dispatch_queue_t          queue;
@property (nonatomic, assign) dispatch_source_t         timer;

@end

#define     height_headerview           (ios7 ? (44+20) : 44)

@implementation LastMinuteDetailViewController

@synthesize dealURL = _dealURL;
@synthesize originalURL = _originalURL;
@synthesize dealTitle = _dealTitle;

@synthesize dealInfoDictionary = _dealInfoDictionary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _dealURL = [NSString string];
        _originalURL = [NSString string];
        _dealTitle = [NSString string];
        
        _dealInfoDictionary = [[NSDictionary alloc]init];
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setMultipleTouchEnabled:NO];
    
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [_reloadLastMinuteView setHidden:NO];
        [_screenTapReloadTappp setEnabled:YES];
        
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
        
    }
    //有网络则
    else{
        [self queryData];
    }

    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initRootView];
    
    
    //App 从后台进入前端
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryData) name:@"Notification_AppWillEnterForeground" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"折扣详情"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"折扣详情"];
}

//*********** Insert By ZhangDong 2014.4.8 Start **********
/**
 *  查询URL数据
 */
- (void)queryData
{
    NSString * token = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_access_token"];
    
    [self.view makeToastActivity];
    
    [[QYAPIClient sharedAPIClient]getLastMinuteDetailWithID:self.dealID OAuthToken:token success:^(NSDictionary *dic) {
        
        [self.view hideToastActivity];
        
        [_reloadLastMinuteView setHidden:YES];
        [_screenTapReloadTappp setEnabled:NO];
        
        self.dealURL = [[dic objectForKey:@"data"] objectForKey:@"app_url"];
        
        NSLog(@"\n\n%@\n\n",[dic objectForKey:@"data"]);
        
        NSLog(@"----%@-----",self.dealURL);
        
        
        if ([[[dic objectForKey:@"data"] objectForKey:@"m_qyer_url"] isKindOfClass:[NSString class]] && ![[[dic objectForKey:@"data"] objectForKey:@"m_qyer_url"] isEqualToString:@""]) {
            self.originalURL = [[dic objectForKey:@"data"] objectForKey:@"m_qyer_url"];
        }
        else{
            self.originalURL = [[dic objectForKey:@"data"] objectForKey:@"qyer_url"];
        }
        
        //获取折扣详情
        self.dealInfoDictionary = [dic objectForKey:@"data"];
        
        //存在折扣代码
        if ([self.dealInfoDictionary objectForKey:@"discount_code"] && ![[self.dealInfoDictionary objectForKey:@"discount_code"] isEqualToString:@""])
        {
            _lastMinuteBookView = [[BookView alloc] initWithOrderArray:[self.dealInfoDictionary objectForKey:@"order_info"]
                                                           titleArray:[self.dealInfoDictionary objectForKey:@"order_info_txt"]
                                                          dicountCode:[self.dealInfoDictionary objectForKey:@"discount_code"]
                                                            orderType:[[self.dealInfoDictionary objectForKey:@"order_type"] intValue]];
            _lastMinuteBookView.delegate = self;
        }
        
        else{
            _lastMinuteBookView = [[BookView alloc] initWithOrderArray:[self.dealInfoDictionary objectForKey:@"order_info"]
                                                            titleArray:[self.dealInfoDictionary objectForKey:@"order_info_txt"]
                                                             orderType:[[self.dealInfoDictionary objectForKey:@"order_type"] intValue]];
            _lastMinuteBookView.delegate = self;
        }
        
        
        NSString * titleee = [[dic objectForKey:@"data"] objectForKey:@"title"];
        NSMutableString *priceee = [NSMutableString stringWithString:[[dic objectForKey:@"data"] objectForKey:@"price"]];
        NSRange frontRange = [priceee rangeOfString:@"<em>"];
        if(frontRange.length != 0)
        {
            [priceee deleteCharactersInRange:frontRange];
        }
        NSRange backRange = [priceee rangeOfString:@"</em>"];
        if(backRange.length != 0)
        {
            [priceee deleteCharactersInRange:backRange];
        }
        self.dealTitle = [NSString stringWithFormat:@"%@ %@",titleee,priceee];
        
        
        //倒计时
        //获得当前时间戳
        NSTimeInterval nowInterval = [QYTime nowAdjustTimeInterval];//[[NSDate date] timeIntervalSince1970];

        NSNumber *app_endDate = [NSNumber numberWithInt:[[[dic objectForKey:@"data"] objectForKey:@"app_end_date_new"] intValue]];
        
        if (nowInterval < [app_endDate intValue]) {
            
            //UI
            [self showBottomViewWithBottomStyle:BottomStyleNormalNotStart];
            //UI TIPS
            NSTimeInterval seconds = [app_endDate intValue] - nowInterval;
            [self setTimeScheduleWithTimeInterval:seconds];
            
        }else{
            
            [self showBottomViewWithBottomStyle:BottomStyleNormalEnd];
            
        }
        
        _lmTimeLabel.text = [[dic objectForKey:@"data"] objectForKey:@"end_date"];//_detail.lastMinuteFinishDate;
        
        
        NSInteger favoredFlag = [[[dic objectForKey:@"data"] objectForKey:@"favored"] intValue];
        
        if(favoredFlag)
        {
            _collectButton.hidden = YES;
            _cancelCollectButton.hidden = NO;
        }
        else
        {
            _collectButton.hidden = NO;
            _cancelCollectButton.hidden = YES;
        }
        
        //加载链接
       [_lastMinuteWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.dealURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:16]];
        
        
    } failure:^{
        
        [self.view hideToastActivity];
        
        [_reloadLastMinuteView setHidden:NO];
        [_screenTapReloadTappp setEnabled:YES];
        
    }];
}

//*********** Insert By ZhangDong 2014.4.8 End **********

-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
    

    float height_naviViewHeight = (ios7 ? 20+44 : 44);
    UIView * naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height_naviViewHeight)];
    naviView.backgroundColor = RGB(43, 171, 121);
    [self.view addSubview:naviView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 240, 20)];
    if(ios7)
    {
        titleLabel.frame = CGRectMake(50, 12+20, 220, 20);
    }
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"折扣详情";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:20];
    [naviView addSubview:titleLabel];
    [titleLabel release];

    
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor = [UIColor clearColor];
    backButton.frame = CGRectMake(0, 2, 40, 40);
    if(ios7)
    {
        backButton.frame = CGRectMake(0, 2+20, 40, 40);
    }
    [backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:backButton];
    
    //分享按钮
    UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setTag:789789];
    shareButton.backgroundColor = [UIColor clearColor];
    shareButton.frame = CGRectMake(self.view.frame.size.width-40-40-10-6, naviView.frame.size.height-40-2, 40, 40);
    [shareButton setEnabled:NO];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"share_Icon"] forState:UIControlStateNormal];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"share_Icon_Pressed"] forState:UIControlStateHighlighted];
    [shareButton addTarget:self action:@selector(shareLastMinute) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:shareButton];
    
    //收藏按钮
    _collectButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_collectButton setTag:789790];
    _collectButton.backgroundColor = [UIColor clearColor];
    _collectButton.frame = CGRectMake(self.view.frame.size.width-40-6, naviView.frame.size.height-40-2, 40, 40);
    [_collectButton setEnabled:NO];
    [_collectButton setBackgroundImage:[UIImage imageNamed:@"lastMinute_nav_btn_like.png"] forState:UIControlStateNormal];
    [_collectButton setBackgroundImage:[UIImage imageNamed:@"lastMinute_nav_btn_like_highlighted.png"] forState:UIControlStateHighlighted];
    [_collectButton addTarget:self action:@selector(clickCollectButton:) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:_collectButton];
    
    //取消收藏按钮
    _cancelCollectButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_cancelCollectButton setTag:789791];
    _cancelCollectButton.backgroundColor = [UIColor clearColor];
    _cancelCollectButton.frame = CGRectMake(self.view.frame.size.width-40-6, naviView.frame.size.height-40-2, 40, 40);
    [_cancelCollectButton setEnabled:NO];
    [_cancelCollectButton setBackgroundImage:[UIImage imageNamed:@"lastMinute_nav_btn_liked.png"] forState:UIControlStateNormal];
    [_cancelCollectButton setBackgroundImage:[UIImage imageNamed:@"lastMinute_nav_btn_liked_highlighted.png"] forState:UIControlStateHighlighted];
    [_cancelCollectButton addTarget:self action:@selector(clickCancelCollectButton:) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:_cancelCollectButton];
    _cancelCollectButton.hidden = YES;
    [naviView release];
    
    //初始化WebView
    if(ios7)
    {
        _lastMinuteWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, height_headerview, 320, [[UIScreen mainScreen] bounds].size.height -height_headerview -60+6)];
    }
    else
    {
        _lastMinuteWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, height_headerview, 320, ([[UIScreen mainScreen] bounds].size.height-20) -height_headerview -60+6)];
    }
    
    _lastMinuteWebView.delegate = self;
    _lastMinuteWebView.scalesPageToFit = YES;
    _lastMinuteWebView.backgroundColor = [UIColor clearColor];
    _lastMinuteWebView.scrollView.decelerationRate = 5.0;
    [self.view addSubview:_lastMinuteWebView];

    _didFinishLoading = NO;
    //发起获取详情的请求

    
    //没有缓存提示点击加载的图层
    _reloadLastMinuteView = [[UIView alloc]initWithFrame:_lastMinuteWebView.frame];
    [_reloadLastMinuteView setHidden:YES];
    [_reloadLastMinuteView setBackgroundColor:[UIColor clearColor]];
    [_reloadLastMinuteView setUserInteractionEnabled:YES];
    [self.view addSubview:_reloadLastMinuteView];
    
    UIImageView * noResultImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, (_reloadLastMinuteView.frame.size.height-180)/2, 320, 180)];
    [noResultImgView setBackgroundColor:[UIColor clearColor]];
    [noResultImgView setImage:[UIImage imageNamed:@"notReachable.png"]];
    [_reloadLastMinuteView addSubview:noResultImgView];
    [noResultImgView release];
    
    _screenTapReloadTappp = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reloadWebContent)];
    [self.view addGestureRecognizer:_screenTapReloadTappp];
    [_screenTapReloadTappp setEnabled:NO];
    
    //config bottom view
    [self drawBottomView];
//    [self showBottomViewWithBottomStyle:BottomStyleNormal];
    
    
    
}

//config bottom view
- (void)drawBottomView
{
    //背景图
    _styleEmptyContentView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _lastMinuteWebView.frame.origin.y + _lastMinuteWebView.frame.size.height - 6, 320, 60)];
    [_styleEmptyContentView setBackgroundColor:[UIColor clearColor]];
    [_styleEmptyContentView setImage:[UIImage imageNamed:@"lastMinute_detail_dock"]];
    [_styleEmptyContentView setUserInteractionEnabled:YES];
    [self.view addSubview:_styleEmptyContentView];
    
    CGRect frame = _styleEmptyContentView.frame;
    frame.size.width = 186.0f;
    
    //不能进行购买  ------------------------------------------------------------------------------------------
    _styleNormalContentView = [[UIImageView alloc] initWithFrame:frame];
    _styleNormalContentView.backgroundColor = [UIColor clearColor];
    _styleNormalContentView.userInteractionEnabled = YES;
    [self.view addSubview:_styleNormalContentView];
    _styleNormalContentView.hidden = YES;
    
    
    //    //2014.03.31结束
    //    UILabel *limitTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 165, 60)];
    //    limitTimeLabel.text = @"2014.03.31结束";
    //    limitTimeLabel.backgroundColor = [UIColor clearColor];
    //    limitTimeLabel.textColor = [UIColor blackColor];
    //    limitTimeLabel.font = [UIFont systemFontOfSize:12.0f];
    //    [_styleNormalContentView addSubview:limitTimeLabel];
    //    [limitTimeLabel release];
    
    //不能进行购买  2014.03.31结束
    _lmTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 165, 60)];
    _lmTimeLabel.text = @"2014.03.31结束";
    _lmTimeLabel.backgroundColor = [UIColor clearColor];
    _lmTimeLabel.textColor = [UIColor blackColor];
    _lmTimeLabel.font = [UIFont systemFontOfSize:12.0f];
    [_styleNormalContentView addSubview:_lmTimeLabel];
    
    
    //不能进行购买 Not Start ------------------------------------------------------------------------------------------
    _styleNormalNotStartContentView = [[UIImageView alloc] initWithFrame:frame];
    _styleNormalNotStartContentView.backgroundColor = [UIColor clearColor];
    _styleNormalNotStartContentView.userInteractionEnabled = YES;
    [self.view addSubview:_styleNormalNotStartContentView];
    _styleNormalNotStartContentView.hidden = YES;
    
    
    //已开始  离折扣结束还有
    UILabel *normalNotStartTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 16+1, 159, 14)];
    normalNotStartTipLabel.text = @"离折扣结束还有";
    normalNotStartTipLabel.font = [UIFont systemFontOfSize:12];
    normalNotStartTipLabel.textColor = [UIColor blackColor];
    normalNotStartTipLabel.backgroundColor = [UIColor clearColor];
    [_styleNormalNotStartContentView addSubview:normalNotStartTipLabel];
    [normalNotStartTipLabel release];

    
    //查看预订
    _lmBookButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_lmBookButton setFrame:CGRectMake(176, 17, 134, 33)];
    [_lmBookButton setBackgroundColor:[UIColor clearColor]];
    [_lmBookButton setBackgroundImage:[UIImage imageNamed:@"lastMinute_Reserve_gray"] forState:UIControlStateNormal];
    [_lmBookButton setBackgroundImage:[UIImage imageNamed:@"lastMinute_Reserve_gray_press"] forState:UIControlStateHighlighted];
    [_styleEmptyContentView addSubview:_lmBookButton];
    
    //不能进行购买 End ------------------------------------------------------------------------------------------
    _styleNormalEndContentView = [[UIImageView alloc] initWithFrame:frame];
    _styleNormalEndContentView.backgroundColor = [UIColor clearColor];
    _styleNormalEndContentView.userInteractionEnabled = YES;
    [self.view addSubview:_styleNormalEndContentView];
    _styleNormalEndContentView.hidden = YES;
    
    //已结束logo
    UIImageView *finishImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _styleNormalEndContentView.frame.size.height-54, 124, 54)];
    finishImageView.image = [UIImage imageNamed:@"lastminute_detail_finish.png"];
    [_styleNormalEndContentView addSubview:finishImageView];
    [finishImageView release];
    
    
    //drawTimeTable
    [self drawTimeTable];


}

//设置底部展示样式
- (void)showBottomViewWithBottomStyle:(BottomStyle)aBottomStyle
{
    if (aBottomStyle ==  BottomStyleNormal) {//不能进行购买
        
        _styleNormalContentView.hidden = NO;
        _styleNormalNotStartContentView.hidden = YES;
        _styleNormalEndContentView.hidden = YES;
        
        //隐藏 倒计时
        _timeTableContentView.hidden = YES;
        
    }else if (aBottomStyle ==  BottomStyleNormalNotStart) {//不能进行购买
        
        _styleNormalContentView.hidden = YES;
        _styleNormalNotStartContentView.hidden = NO;
        _styleNormalEndContentView.hidden = YES;
        
        //显示 倒计时
        _timeTableContentView.hidden = NO;
        
    }else if (aBottomStyle == BottomStyleNormalEnd){
        _styleNormalContentView.hidden = YES;
        _styleNormalNotStartContentView.hidden = YES;
        _styleNormalEndContentView.hidden = NO;
        
        //隐藏 倒计时
        _timeTableContentView.hidden = YES;
    
    }

}

//设置底部展示样式
- (void)drawTimeTable
{
    CGRect frame = _styleEmptyContentView.frame;
    frame.size.width = 186.0f;
    _timeTableContentView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:_timeTableContentView];
    [self.view bringSubviewToFront:_timeTableContentView];
    _timeTableContentView.hidden = YES;
    
    //---------------------------------------------------------------------------
    UIFont *Font_Tip = [UIFont boldSystemFontOfSize:16];
    UIFont *Font_Unit = [UIFont systemFontOfSize:11];
    
    // 天 tip
    _styleStartingTipDaysLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPadding, yPadding, widthTip, 19)];
    _styleStartingTipDaysLabel.text = @"1";
    _styleStartingTipDaysLabel.textAlignment = NSTextAlignmentCenter;
    _styleStartingTipDaysLabel.font = Font_Tip;
    _styleStartingTipDaysLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
    _styleStartingTipDaysLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingTipDaysLabel];
    _styleStartingTipDaysLabel.hidden = YES;
    
    // 小时 tip
    _styleStartingTipHoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(33, yPadding, widthTip, 19)];
    _styleStartingTipHoursLabel.text = @"23";
    _styleStartingTipHoursLabel.textAlignment = NSTextAlignmentCenter;
    _styleStartingTipHoursLabel.font = Font_Tip;
    _styleStartingTipHoursLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
    _styleStartingTipHoursLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingTipHoursLabel];
    _styleStartingTipHoursLabel.hidden = YES;
    
    // 分 tip
    _styleStartingTipMinutesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yPadding, widthTip, 19)];
    _styleStartingTipMinutesLabel.text = @"1";
    _styleStartingTipMinutesLabel.textAlignment = NSTextAlignmentCenter;
    _styleStartingTipMinutesLabel.font = Font_Tip;
    _styleStartingTipMinutesLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
    _styleStartingTipMinutesLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingTipMinutesLabel];
    _styleStartingTipMinutesLabel.hidden = YES;
    
    // 秒 tip
    _styleStartingTipSecondsLabel = [[UILabel alloc] initWithFrame:CGRectMake(82, yPadding, widthTip, 19)];
    _styleStartingTipSecondsLabel.text = @"59";
    _styleStartingTipSecondsLabel.textAlignment = NSTextAlignmentCenter;
    _styleStartingTipSecondsLabel.font = Font_Tip;
    _styleStartingTipSecondsLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
    _styleStartingTipSecondsLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingTipSecondsLabel];
    _styleStartingTipSecondsLabel.hidden = YES;
    
    CGFloat yPaddingUnit = 39.0-2;
    
    // 天
    _styleStartingDaysLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, yPaddingUnit, widthUnit, 14)];
    _styleStartingDaysLabel.text = @"天";
    _styleStartingDaysLabel.font = Font_Unit;
    _styleStartingDaysLabel.textColor = [UIColor blackColor];
    _styleStartingDaysLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingDaysLabel];
    _styleStartingDaysLabel.hidden = YES;
    
    // 小时
    _styleStartingHoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(58, yPaddingUnit, widthUnit*2, 14)];
    _styleStartingHoursLabel.text = @"小时";
    _styleStartingHoursLabel.font = Font_Unit;
    _styleStartingHoursLabel.textColor = [UIColor blackColor];
    _styleStartingHoursLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingHoursLabel];
    _styleStartingHoursLabel.hidden = YES;
    
    // 分
    _styleStartingMinutesLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, yPaddingUnit, widthUnit, 14)];
    _styleStartingMinutesLabel.text = @"分";
    _styleStartingMinutesLabel.font = Font_Unit;
    _styleStartingMinutesLabel.textColor = [UIColor blackColor];
    _styleStartingMinutesLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingMinutesLabel];
    _styleStartingMinutesLabel.hidden = YES;
    
    // 秒
    _styleStartingSecondsLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, yPaddingUnit, widthUnit, 14)];
    _styleStartingSecondsLabel.text = @"秒";
    _styleStartingSecondsLabel.font = Font_Unit;
    _styleStartingSecondsLabel.textColor = [UIColor blackColor];
    _styleStartingSecondsLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingSecondsLabel];
    _styleStartingSecondsLabel.hidden = YES;
    
}

//设置定时器
- (void)setTimeScheduleWithTimeInterval:(NSInteger)aTimeInterval
{
    if (_queue) {
        dispatch_release(_queue);
    }
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
    
    _timeout= aTimeInterval;//aTimeInterval; //倒计时时间
    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(_timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_release(_timer);
            _timer = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                
                //刷新我的订单界面
                //                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_MyOrder_Refresh object:nil];
                
                //刷新界面数据
                [self queryData];
                
            });
        }else{
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                
                
                //            NSString *timeStr = [QYCommonUtil getTimeStrngWithSeconds:timeout];//获得倒计时时间格式： 2天13小时19分54秒
                NSDictionary *timeInfo = [self getTimeInfoWithSeconds:_timeout];//获得倒计时时间格式： 2天13小时19分54秒
                [self setTimeTableWithTimeInfo:timeInfo];
                
                //                if (aBottomStyle == BottomStyleNotStart) {//未开始（设置提醒） 倒计时
                //
                //                    NSString *strTime = [NSString stringWithFormat:@"%@", timeStr];
                ////                    _styleNotStartTipLabel.text = strTime;//@"在2天13小时19分54秒内完成支付！"
                //
                //                }else if (aBottomStyle == BottomStyleStarting){//已开始（立即预订）倒计时
                //                    NSString *strTime = [NSString stringWithFormat:@"%@", timeStr];
                ////                    _styleStartingTipLabel.text = strTime;//@"在2天13小时19分54秒内完成支付！"
                //
                //                }
                
            });
            _timeout--;
            
        }
    });
    dispatch_resume(_timer);
    
    
}


- (void)setTimeTableWithTimeInfo:(NSDictionary*)aTimeInfo
{
    
    int days = [[aTimeInfo objectForKey:Key_Time_Days] intValue];
    int hours = [[aTimeInfo objectForKey:Key_Time_Hours] intValue];
    int minutes = [[aTimeInfo objectForKey:Key_Time_Minutes] intValue];
    int seconds = [[aTimeInfo objectForKey: Key_Time_Seconds] intValue];
    
    
    CGFloat x = xPadding;
    CGFloat tPadding = 2;//调整天、小时、分、秒之间的间隔
    
    if (days>0) {//显示 天
        _styleStartingTipDaysLabel.hidden = NO;
        _styleStartingDaysLabel.hidden = NO;
        _styleStartingTipDaysLabel.text = [NSString stringWithFormat:@"%d", days];
        
        CGSize size = [_styleStartingTipDaysLabel.text sizeWithFont:_styleStartingTipDaysLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _styleStartingTipDaysLabel.frame.size.height) lineBreakMode:_styleStartingTipDaysLabel.lineBreakMode];
        CGFloat width = size.width + tPadding;
        
        CGRect frame = _styleStartingTipDaysLabel.frame;
        frame.origin.x = x;
        frame.size.width = width;
        _styleStartingTipDaysLabel.frame = frame;
        
        x += width;
        
        frame = _styleStartingDaysLabel.frame;
        frame.origin.x = x;
        _styleStartingDaysLabel.frame = frame;
        
        x += widthUnit;
        
    }else{
        _styleStartingTipDaysLabel.hidden = YES;
        _styleStartingDaysLabel.hidden = YES;
    }
    
    if (hours>0) {//显示 小时
        _styleStartingTipHoursLabel.hidden = NO;
        _styleStartingHoursLabel.hidden = NO;
        _styleStartingTipHoursLabel.text = [NSString stringWithFormat:@"%d", hours];
        
        CGSize size = [_styleStartingTipHoursLabel.text sizeWithFont:_styleStartingTipHoursLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _styleStartingTipHoursLabel.frame.size.height) lineBreakMode:_styleStartingTipHoursLabel.lineBreakMode];
        CGFloat width = size.width + tPadding;
        
        CGRect frame = _styleStartingTipHoursLabel.frame;
        frame.origin.x = x;
        frame.size.width = width;
        _styleStartingTipHoursLabel.frame = frame;
        
        x += width;
        
        frame = _styleStartingHoursLabel.frame;
        frame.origin.x = x;
        _styleStartingHoursLabel.frame = frame;
        
        x += widthUnit*2;
        
    }else{
        _styleStartingTipHoursLabel.hidden = YES;
        _styleStartingHoursLabel.hidden = YES;
    }
    
    if (minutes>0) {//显示 分
        _styleStartingTipMinutesLabel.hidden = NO;
        _styleStartingMinutesLabel.hidden = NO;
        _styleStartingTipMinutesLabel.text = [NSString stringWithFormat:@"%d", minutes];
        
        CGSize size = [_styleStartingTipMinutesLabel.text sizeWithFont:_styleStartingTipMinutesLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _styleStartingTipMinutesLabel.frame.size.height) lineBreakMode:_styleStartingTipMinutesLabel.lineBreakMode];
        CGFloat width = size.width + tPadding;
        
        CGRect frame = _styleStartingTipMinutesLabel.frame;
        frame.origin.x = x;
        frame.size.width = width;
        _styleStartingTipMinutesLabel.frame = frame;
        
        x += width;
        
        frame = _styleStartingMinutesLabel.frame;
        frame.origin.x = x;
        _styleStartingMinutesLabel.frame = frame;
        
        x += widthUnit;
        
    }else{
        _styleStartingTipMinutesLabel.hidden = YES;
        _styleStartingMinutesLabel.hidden = YES;
    }
    
    if (seconds>0) {//显示 秒
        _styleStartingTipSecondsLabel.hidden = NO;
        _styleStartingSecondsLabel.hidden = NO;
        _styleStartingTipSecondsLabel.text = [NSString stringWithFormat:@"%d", seconds];
        
        CGSize size = [_styleStartingTipSecondsLabel.text sizeWithFont:_styleStartingTipSecondsLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _styleStartingTipSecondsLabel.frame.size.height) lineBreakMode:_styleStartingTipSecondsLabel.lineBreakMode];
        CGFloat width = size.width + tPadding;
        
        CGRect frame = _styleStartingTipSecondsLabel.frame;
        frame.origin.x = x;
        frame.size.width = width;
        _styleStartingTipSecondsLabel.frame = frame;
        
        x += width;
        
        frame = _styleStartingSecondsLabel.frame;
        frame.origin.x = x;
        _styleStartingSecondsLabel.frame = frame;
        
        x += widthUnit;
        
    }else{
        _styleStartingTipSecondsLabel.hidden = YES;
        _styleStartingSecondsLabel.hidden = YES;
    }
    
}

-(void)reloadWebContent
{
    [_reloadLastMinuteView setHidden:YES];
    [_screenTapReloadTappp setEnabled:NO];
    
    [self.view hideToast];
    [self.view hideToastActivity];
    
    [self queryData];
}


-(void)reserve:(id)sender
{
    int qyerOnly = [[self.dealInfoDictionary objectForKey:@"self_use"] integerValue];
    BOOL isLogIn = [[[NSUserDefaults standardUserDefaults]objectForKey:@"qyerlogin"] boolValue];
    
    if (qyerOnly == 1 && isLogIn == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"预定该折扣需要先登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 12537;
        [alertView show];
        [alertView release];
    }
    else{
        [_lastMinuteBookView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 12537 && buttonIndex == 1) {
        CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
        navigationController.navigationBarHidden = YES;
        [self presentViewController:navigationController animated:YES completion:nil];
        [cityLoginVC release];
    }
}

- (void)bookViewButtonDidClicked:(id)sender
{
    if([[self.dealInfoDictionary objectForKey:@"order_type"] intValue] == 0)
    {
        NSString * stttt = [[self.dealInfoDictionary objectForKey:@"order_info"] objectAtIndex:[sender tag]];
        
        if ([stttt hasPrefix:@"http://z.qyer.com/deal/"]) {
            
            NSString * str = [[stttt componentsSeparatedByString:@"deal/"]objectAtIndex:1];
            NSString * stttt = [[str componentsSeparatedByString:@"/"]objectAtIndex:0];

            self.dealID = [stttt integerValue];
            
            [self queryData];
        }

        else{
            
            [_lastMinuteWebView stopLoading];
            
            WebViewViewController *  webVC = [[WebViewViewController alloc] init] ;
            [webVC setStartURL:stttt];
            [webVC.label_title setText:@"在线预订"];
            [self presentViewController:[QYToolObject getControllerWithBaseController:webVC] animated:YES completion:nil];
            [webVC release];
        }
    }
    
    else
    {
        if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"])
        {
            NSMutableString *phone = [NSMutableString stringWithString:[[self.dealInfoDictionary objectForKey:@"order_info"] objectAtIndex:[sender tag]]];
            
            NSMutableString *callNumber = [NSMutableString stringWithCapacity:0];
            for(NSUInteger i = 0; i < [phone length]; i++)
            {
                NSString *string = [phone substringWithRange:NSMakeRange(i, 1)];
                if([string integerValue] != 0 || [string isEqualToString:@"0"] || [string isEqualToString:@"+"])
                {
                    if([string isEqualToString:@"+"])
                    {
                        if([callNumber rangeOfString:@"+"].length != 0)
                        {
                            [callNumber insertString:string atIndex:[callNumber length]];
                        }
                    }
                    else
                    {
                        [callNumber insertString:string atIndex:[callNumber length]];
                    }
                }
            }
            
            if([callNumber length] == 0)
            {
                [callNumber insertString:@"0" atIndex:0];
            }

//            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", callNumber]];
//            [[UIApplication sharedApplication] openURL:url];
            
            //拨打电话返回应用
            UIWebView*callWebview =[[[UIWebView alloc] init]autorelease];
            [callWebview setFrame:CGRectZero];
            NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", callNumber]];// 貌似tel:// 或者 tel: 都行
            [self.view addSubview:callWebview];
            [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
            
            
        }
        else
        {
            [self.view makeToast:@"您的设备不支持拨叫" duration:1.2f position:@"center" isShadow:NO];
        }
    }
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view makeToastActivity];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_reloadLastMinuteView setHidden:YES];
    [_screenTapReloadTappp setEnabled:NO];
    
    if (_didFinishLoading == NO) {
        
        [_lmBookButton setBackgroundImage:[UIImage imageNamed:@"lastMinute_Reserve"] forState:UIControlStateNormal];
        [_lmBookButton setBackgroundImage:[UIImage imageNamed:@"lastMinute_Reserve_pressed"] forState:UIControlStateHighlighted];
        [_lmBookButton addTarget:self action:@selector(reserve:) forControlEvents:UIControlEventTouchUpInside];
    
        //分享按钮
        UIButton * shareButton = (UIButton *)[self.view viewWithTag:789789];
        [shareButton setEnabled:YES];
        
        //收藏按钮
        UIButton * collectButton = (UIButton *)[self.view viewWithTag:789790];
        [collectButton setEnabled:YES];
        
        //取消收藏按钮
        UIButton * cancelCollectButton = (UIButton *)[self.view viewWithTag:789791];
        [cancelCollectButton setEnabled:YES];
    }
    
    _didFinishLoading = YES;
    
    [self.view hideToastActivity];
}



-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.view hideToast];
    [self.view hideToastActivity];
    [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];

    [_reloadLastMinuteView setHidden:NO];
    [_screenTapReloadTappp setEnabled:YES];
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString * str = [NSString stringWithFormat:@"%@",request.URL];
    
    NSLog(@"---%@---",str);
    
    if ([str hasPrefix:@"http://m.qyer.com/z/deal"] || [str hasPrefix:@"http://z.qyer.com/deal"] || [str hasPrefix:@"http://appview.qyer.com/z/deal/"] || [str hasPrefix:@"tel:"]) {
        
//        self.dealID = [stttt integerValue];
//        [self queryData];
        
        if (_didFinishLoading == YES) {
            
            _didFinishLoading = NO;
            
            NSString * strrrr = [[str componentsSeparatedByString:@"deal/"]objectAtIndex:1];
            
            self.dealID = [strrrr integerValue];
            [self queryData];
            
            return NO;
        }
        
        
        /*
        http://z.qyer.com/deal/
        http://m.qyer.com/z/deal/
        http://appview.qyer.com/z/deal/
        */
        
        return YES;
    
    }
    else{
        
        if (_didFinishLoading == YES) {
            if ([str hasPrefix:@"http://www.booking.com"]) {
                WebViewViewController *  webVC = [[WebViewViewController alloc] init] ;
                [webVC setStartURL:str];
                [self presentViewController:[QYToolObject getControllerWithBaseController:webVC] animated:YES completion:nil];
                [webVC release];
            }
        }
        
        return NO;
    }
}


-(void)shareLastMinute
{
    BOOL flag = [[QyerSns sharedQyerSns] getIsWeixinInstalled];
    NSString *versonStr = [[QyerSns sharedQyerSns] getWeixinVerson];
    BOOL SMSFlag = [[QyerSns sharedQyerSns] isCanSendSMS];
    
    if (SMSFlag)
    {
        if(flag == 1 && iPhone5)
        {
            MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",@"短信", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo", @"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
            actionSheet.delegate = self;
            
            [actionSheet show];
            [actionSheet release];
        }
        else
        {
            if(flag == 0 || [versonStr floatValue] - 1.1 < 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"腾讯微博",@"邮件", @"短信", nil] imageArray:[NSArray arrayWithObjects: @"btn_actionsheet_weibo",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
            else if(flag == 1 && [versonStr floatValue] - 1.1 >= 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",@"短信",  nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo",@"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
        }
    }
    else
    {
        if(flag == 1 && iPhone5)
        {
            MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo", @"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
            actionSheet.delegate = self;
            
            [actionSheet show];
            [actionSheet release];
        }
        else
        {
            if(flag == 0 || [versonStr floatValue] - 1.1 < 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"腾讯微博",@"邮件", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
            else if(flag == 1 && [versonStr floatValue]  - 1.1 >= 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",  nil] imageArray:[NSArray arrayWithObjects: @"btn_actionsheet_weibo", @"btn_actionsheet_weixin",@"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
                actionSheet.delegate = self;
                
                [actionSheet show];
                [actionSheet release];
            }
        }
    }
}

//判断是否显示登陆框
- (void)showLoginAlertWithMessage:(NSString*)aMessage
{
    
    [MobClick event:@"detailLoginDialogPopUp"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:aMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 12537;
    [alertView show];
    [alertView release];
    
}

//点击收藏按钮
- (void)clickCollectButton:(id)sender
{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue])
    {
        
        //判断是否显示登陆框
        [self showLoginAlertWithMessage:@"收藏该折扣需要先登录？"];
        
        return;
    }
    
    if(_isLoading)
    {
        return;
    }
    _isLoading = YES;
    
    [self.view makeToastActivity];
    [[QYAPIClient sharedAPIClient] lastMinuteAddFavorWithId:self.dealID
                                                    success:^(NSDictionary *dic) {
                                                        
                                                        [self.view hideToastActivity];
                                                        [self.view hideToast];
                                                        [self.view makeToast:@"添加收藏成功" duration:1.2f position:@"center" isShadow:NO];
                                                        
                                                        _collectButton.hidden = YES;
                                                        _cancelCollectButton.hidden = NO;
                                                        
                                                        _isLoading = NO;
                                                        
                                                    } failure:^ {
                                                        
                                                        [self.view hideToastActivity];
                                                        [self.view hideToast];
                                                        [self.view makeToast:@"添加收藏失败" duration:1.2f position:@"center" isShadow:NO];
                                                        
                                                        
                                                        _isLoading = NO;
                                                        
                                                    }];


}

//点击取消收藏按钮
- (void)clickCancelCollectButton:(id)sender
{
    
    if(_isLoading)
    {
        return;
    }
    _isLoading = YES;
    
    [self.view makeToastActivity];
    [[QYAPIClient sharedAPIClient] lastMinuteDeleteFavorWithId:self.dealID
                                                       success:^(NSDictionary *dic) {
                                                           
                                                           [self.view hideToastActivity];
                                                           [self.view hideToast];
                                                           [self.view makeToast:@"取消收藏成功" duration:1.2f position:@"center" isShadow:NO];
                                                           
                                                           _collectButton.hidden = NO;
                                                           _cancelCollectButton.hidden = YES;
                                                           
                                                           _isLoading = NO;
                                                           
                                                       } failure:^ {
                                                           
                                                           [self.view hideToastActivity];
                                                           [self.view hideToast];
                                                           [self.view makeToast:@"取消收藏失败" duration:1.2f position:@"center" isShadow:NO];

                                                           _isLoading = NO;
                                                           
                                                       }];



}

-(void)actionSheetButtonDidClickWithType:(NSString*)type
{
    if([type isEqualToString:@"邮件"])
    {
        //[MobClick event:@"setting" label:@"邮件分享"];
        [self youjianfenxiang];
    }
    if([type isEqualToString:@"短信"])
    {
        //[MobClick event:@"setting" label:@"短信"];
        [self sendmessage];
    }
    else if([type isEqualToString:@"新浪微博"])
    {
        //[MobClick event:@"setting" label:@"新浪微博分享"];
        [self shareToSinaWeibo];
    }
    else if([type isEqualToString:@"微信"])
    {
        //[MobClick event:@"setting" label:@"微信分享"];
        [self shareToWeixinFriend];
    }
    else if([type isEqualToString:@"微信朋友圈"])
    {
        //[MobClick event:@"setting" label:@"微信朋友圈"];
        [self shareToWeixinFriendCircle];
    }
    else if([type isEqualToString:@"腾讯微博"])
    {
        [self shareToTencentWeibo];
    }
}



#pragma mark --- 分享
-(void)youjianfenxiang
{
    NSString * shareURL = [self.dealInfoDictionary objectForKey:@"qyer_url"];
    
    [[QyerSns sharedQyerSns] shareToMailWithMailTitle:[NSString stringWithFormat:@"Hi~我在#穷游APP#里发现一条给力折扣【%@】",self.dealTitle] andMailInfo:[NSString stringWithFormat:@"Hi~\n\t我在#穷游APP#里发现一条给力折扣【%@】，已经hold不住准备拿下啦！\n\t你要不要？也来抢一发呗！折扣详情→_→ %@ \n\n\t关于出境游，这一切，尽在穷游。\n\t只需免费下载穷游APP，你就进入了穷游的世界，这里不仅有准确的指南和给力的折扣，这里还有由经验丰富的穷游网友所组成的社区，通过问答和发帖，大家可以彼此互助。\n\t从此，你将永远不会独行，伴随你旅行始终的，将是穷游和穷游的几千万新老朋友。\n\t有了穷游APP，你就放心出行吧。 穷游，陪你体验整个世界的精彩。\n\t穷游App有iPhone、Android和iPad版本，扫描二维码即可轻松下载！",self.dealTitle,shareURL] andImage: [UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)sendmessage
{
    NSString * shareURL = [self.dealInfoDictionary objectForKey:@"qyer_url"];
    [[QyerSns sharedQyerSns] shareWithShortMessage:[NSString stringWithFormat:@"在#穷游APP#里发现一条给力折扣【%@】，我已经hold不住准备拿下啦！你要不要？也来抢一发呗！折扣详情→_→ %@",self.dealTitle,shareURL] inViewController:self];
}

-(void)shareToWeixinFriend
{
    NSString * shareURL = [self.dealInfoDictionary objectForKey:@"qyer_url"];
    
    [[QyerSns sharedQyerSns] shareToWeixinWithAPPTitle:@"穷游APP" andDescription:[NSString stringWithFormat:@"在#穷游APP#里发现一条给力折扣【%@】，已经hold不住，准备拿下啦！你要不要？也来抢一发呗！",self.dealTitle] andImage:[UIImage imageNamed:@"120icon"] andUrl:shareURL];
}

-(void)shareToWeixinFriendCircle
{
    NSString * shareURL = [self.dealInfoDictionary objectForKey:@"qyer_url"];
    
     [[QyerSns sharedQyerSns] shareToWeixinFriendCircleWithAPPTitle:[NSString stringWithFormat:@"在#穷游APP#里发现一条给力折扣【%@】，超级给力、无法淡定。我准备拿下了，大家快抢！折扣详情→_→",self.dealTitle] andDescription:@"" andImage:[UIImage imageNamed:@"120icon"] andUrl:shareURL];
}

-(void)shareToSinaWeibo
{
    NSString * shareURL = [self.dealInfoDictionary objectForKey:@"qyer_url"];
    
    [[QyerSns sharedQyerSns] shareToSinaWeiboWithTitle:@"分享到新浪微博" andText:[NSString stringWithFormat:@"在#穷游APP#里发现一条给力折扣【%@】，超级给力、无法淡定。我准备拿下了，大家快抢！折扣详情→_→ %@",self.dealTitle,shareURL] andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)shareToTencentWeibo
{
    NSString * shareURL = [self.dealInfoDictionary objectForKey:@"qyer_url"];
    [[QyerSns sharedQyerSns] shareToTencentWeiboWithText:[NSString stringWithFormat:@"在#穷游APP#里发现一条给力折扣【%@】，超级给力、无法淡定。我准备拿下了，大家快抢！折扣详情→_→ %@",self.dealTitle,shareURL] andImage:[UIImage imageNamed:@"iphone_sina_sns"] andDelegate:self];
}


- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //倒计时功能
    if (_queue) {
        dispatch_release(_queue);
        _queue = nil;
    }
    if (_timer) {
        dispatch_source_cancel(_timer);
        dispatch_release(_timer);
        _timer = nil;
    }
    
    self.dealInfoDictionary = nil;
    
    QY_VIEW_RELEASE(_lastMinuteWebView);
    QY_SAFE_RELEASE(_dealURL);
    QY_SAFE_RELEASE(_originalURL);
    
    QY_VIEW_RELEASE(_reloadLastMinuteView);
    QY_SAFE_RELEASE(_screenTapReloadTappp);
    
    QY_VIEW_RELEASE(_collectButton);
    QY_VIEW_RELEASE(_cancelCollectButton);
    
    QY_VIEW_RELEASE(_styleEmptyContentView);
    QY_VIEW_RELEASE(_styleNormalContentView);
    QY_VIEW_RELEASE(_styleNormalNotStartContentView);
    QY_VIEW_RELEASE(_styleNormalEndContentView);
    
    QY_VIEW_RELEASE(_timeTableContentView);
    QY_VIEW_RELEASE(_styleStartingTipDaysLabel);
    QY_VIEW_RELEASE(_styleStartingTipHoursLabel);
    QY_VIEW_RELEASE(_styleStartingTipMinutesLabel);
    QY_VIEW_RELEASE(_styleStartingTipSecondsLabel);
    
    QY_VIEW_RELEASE(_styleStartingDaysLabel);
    QY_VIEW_RELEASE(_styleStartingHoursLabel);
    QY_VIEW_RELEASE(_styleStartingMinutesLabel);
    QY_VIEW_RELEASE(_styleStartingSecondsLabel);
    
    QY_VIEW_RELEASE(_lmBookButton);
    QY_VIEW_RELEASE(_lmTimeLabel);
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Util
//获得倒计时时间格式Dictionary： 2天13小时19分54秒
- (NSDictionary*)getTimeInfoWithSeconds:(NSInteger)aSeconds
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

@end
