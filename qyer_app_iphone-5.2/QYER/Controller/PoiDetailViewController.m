//
//  PoiDetailViewController.m
//  QyGuide
//
//  Created by an qing on 13-2-21.
//
//

#import "PoiDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GetPoiDetailInfo.h"
#import "UIImageView+WebCache.h"
#import "PoiDetailInfoImageCell.h"
#import "PoiDetailInfoPlayTimeCell.h"
#import "Toast+UIView.h"
#import "QYMapViewController.h"
#import "PoiDetailInfoControl.h"
#import "PoiAllCommentViewController.h"
#import "PoiInstructionViewController.h"
#import "PoiPhotoBrowserViewController.h"
#import "CachePoiData.h"
#import "WebViewViewController.h"
#import "GetInfo.h"
#import "MobClick.h"
#import "GetHotelNearbyPoi.h"
#import "GetDeviceDetailInfo.h"
#import "RegexKitLite.h"
#import "GoogleMapViewController.h"
#import "GetMinePoiComment.h"
#import "KTThumbsViewController.h"
#import "FootPrintAdd.h"
#import "FootPrintDelete.h"
#import "CityLoginViewController.h"
#import "PoiNearByViewController.h"




#define chineseTitleLabelX                  40
#define chineseTitleLabelY                  (ios7 ? 20 : 4)
#define chineseTitleLabelWidth              240
#define chineseTitleLabelHeight             24

#define englishTitleLabelX                  40
#define englishTitleLabelY                  (ios7 ? (20+19) : 23)
#define englishTitleLabelWidth              240
#define englishTitleLabelHeight             18

#define poiImageHeight                      180
#define poiCommentHeight                    50

#define chineseTitleTypeSize                16
#define englishTitleTypeSize                14

#define commentRateStarPositionX            9
#define mapPositionX                        40


#define height_headerview                   (ios7 ? (44+20) : 44)
#define positionY_backbutton                (ios7 ? (3+20) : 3)
#define positionY_mapbutton                 (ios7 ? (3+20) : 3)
#define positionY_scrollView                (ios7 ? (44+20) : 44)


#define positionY_picNumberLabel                    (ios7 ? 10 : 13)
#define positionY_poiTypeLabel                      (ios7 ? 25 : 30)
#define positionY_poiCommentNumberLabel             (ios7 ? 11 : 15)
#define positionY_poiIntroductionLabel              (ios7 ? 10 : 12)
#define positionY_poiIntroductionContentLabel       (ios7 ? 5 : 9)
#define positionY_poiCommentView                    (ios7 ? 10 : 12)
#define positionY_PoiDetailInfoView                 (ios7 ? 10 : 12)
#define positionY_HotelNearbyPoi                    (ios7 ? 10 : 12)
#define height_toolBar                              44



@interface PoiDetailViewController ()

@end





@implementation PoiDetailViewController
@synthesize navigationTitle = _navigationTitle;
@synthesize poiId;
@synthesize userCommentRateView1 = _userCommentRateView1;
@synthesize userCommentRateView2 = _userCommentRateView2;
@synthesize userCommentRateView3 = _userCommentRateView3;
@synthesize userCommentRateView4 = _userCommentRateView4;
@synthesize userCommentRateView5 = _userCommentRateView5;
@synthesize overMerit = _overMerit;
@synthesize typeImage = _typeImage;
@synthesize dataDic = _dataDic;
@synthesize userComment = _userComment;
@synthesize userCommentRate = _userCommentRate;
@synthesize commentId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hotdot_phone:) name:@"hotdot_phone" object:nil];
        
    }
    return self;
}



-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    QY_SAFE_RELEASE(_navigationTitle);
    if(_chineseTitle && _chineseTitle.retainCount > 0)
    {
        QY_SAFE_RELEASE(_chineseTitle);
    }
    if(_englishTitle && _englishTitle.retainCount > 0)
    {
        QY_SAFE_RELEASE(_englishTitle);
    }
    QY_SAFE_RELEASE(_typeImage);
    
    QY_MUTABLERECEPTACLE_RELEASE(_commentDataArray);
    QY_MUTABLERECEPTACLE_RELEASE(_detailinfokeyArray);
    QY_MUTABLERECEPTACLE_RELEASE(_heightDic);
    
    QY_SAFE_RELEASE(allCommentNumber);
    QY_SAFE_RELEASE(_getPoiDetailInfo_fromServer);
    QY_SAFE_RELEASE(_getHotelNearbyPoi_fromServer);
    QY_SAFE_RELEASE(_bookingUrlStr);
    
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_chineseTitleLabel);
    QY_VIEW_RELEASE(_englishTitleLabel);
    QY_VIEW_RELEASE(_contentTipsWebView);
    QY_VIEW_RELEASE(_userCommentRateView1);
    QY_VIEW_RELEASE(_userCommentRateView2);
    QY_VIEW_RELEASE(_userCommentRateView3);
    QY_VIEW_RELEASE(_userCommentRateView4);
    QY_VIEW_RELEASE(_userCommentRateView5);
    QY_VIEW_RELEASE(_userCommentRateView11);
    QY_VIEW_RELEASE(_userCommentRateView22);
    QY_VIEW_RELEASE(_userCommentRateView33);
    QY_VIEW_RELEASE(_userCommentRateView44);
    QY_VIEW_RELEASE(_userCommentRateView55);
    QY_VIEW_RELEASE(_commentNumLabel);
    QY_VIEW_RELEASE(_myScrollView);
    
    
    
    QY_VIEW_RELEASE(_label_infoComment);
    QY_VIEW_RELEASE(_control_comment);
    QY_VIEW_RELEASE(_typeLabel_nearby);
    QY_VIEW_RELEASE(_nearbyBackBgView);
    QY_VIEW_RELEASE(_imageView_background_nearby);
    QY_VIEW_RELEASE(_imageView_commentBackGround);
    QY_VIEW_RELEASE(_typeLabel_comment);
    QY_VIEW_RELEASE(_imageView_background_comment);
    QY_VIEW_RELEASE(_imageView_logo);
    QY_VIEW_RELEASE(_tipsLabel);
    QY_VIEW_RELEASE(_imageView_tipsBG_tips);
    QY_VIEW_RELEASE(_imageView_background_tips);
    QY_VIEW_RELEASE(_imageView_PoiDetail);
    QY_VIEW_RELEASE(_label_poiDetailInfo);
    QY_VIEW_RELEASE(_imageView_background_poiDetailInfo);
    QY_VIEW_RELEASE(_arrowImageView);
    QY_VIEW_RELEASE(_control_poiIntroduction);
    QY_VIEW_RELEASE(_contentLabel_poiIntroduction);
    QY_VIEW_RELEASE(_contentLabelBG_poiIntroduction);
    QY_VIEW_RELEASE(_imageView_background_introduction);
    QY_VIEW_RELEASE(_label_introduction);
    QY_VIEW_RELEASE(_commentBackBgView);
    QY_VIEW_RELEASE(_mapButBackBgView);
    QY_VIEW_RELEASE(_bgView_imageCount);
    QY_VIEW_RELEASE(_control_poiImageView);
    QY_VIEW_RELEASE(_poiImageView);
    
    
    
    self.overMerit = nil;
    self.userComment = nil;
    self.userCommentRate = nil;
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- 热点 或 打电话
-(void)hotdot_phone:(NSNotification *)noatification
{
    NSDictionary *info = noatification.userInfo;
    if([[info objectForKey:@"type"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:1];
    }
    else if([[info objectForKey:@"type"] isEqualToString:@"0"])
    {
        [self resetRootViewWIthType:0];
    }
}

-(void)resetRootViewWIthType:(BOOL)flag
{
    if(!flag)
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height;
        self.view.frame = newFrame;
        
        
        _myScrollView.frame = CGRectMake(0, positionY_scrollView, 320, [self.view bounds].size.height-positionY_scrollView-height_toolBar);
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        _myScrollView.frame = CGRectMake(0, positionY_scrollView, 320, [self.view bounds].size.height-positionY_scrollView-height_toolBar);
        
    }
}



#pragma mark
#pragma mark --- NotReachableViewDelegate
- (void)touchesView
{
    
    [self getPoiDetailInfoDataFromServer];
    //subclass override
}

/**
 *  是否显示没有网络视图
 */
- (void)setNotReachableView:(BOOL)isVisible
{
    NotReachableView *notReachableView = (NotReachableView*)[self.view viewWithTag:444];
    if (isVisible) {
        if (!notReachableView) {
            CGFloat height = self.view.bounds.size.height - RootViewControllerFootViewHeight - height_headerview;
            notReachableView = [[NotReachableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, height_headerview, UIWidth, height)];
            notReachableView.backgroundColor = [UIColor clearColor];
            notReachableView.delegate = self;
            notReachableView.tag = 444;
            [self.view addSubview:notReachableView];
            [notReachableView release];
        }
    }else{
        [notReachableView removeFromSuperview];
        notReachableView = nil;
    }
}


#pragma mark
#pragma mark --- view - Appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"Poi详情页"];
    
    
    isUserClick = NO;
    
    if (ios7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
//    //刷新数据(主要是评论数和前3条点评,目前接口传回来的数据不是实时更新的)
//    [self freshPartOfData];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"frommapvc"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
    {
        [self getMinePoiCommentFromServer];
    }
    
    if(_flag_init)
    {
        return;
    }
    
    else
    {
        _flag_init = YES;
        [self initData];
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"hotdot_phone"] isEqualToString:@"1"])
        {
            [self resetRootViewWIthType:YES];
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"Poi详情页"];
    
    
    isUserClick = NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(comment_success) name:@"comment_success" object:nil];
    
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    [self setRootView];
    [self setNavigationBar];
}
-(void)setRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image =[UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
}
-(void)addMapButton
{
    _mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _mapButton.frame = CGRectMake(320-40-5, positionY_mapbutton, 40, 40);
    _mapButton.backgroundColor = [UIColor clearColor];
    //NSString *str =[NSString stringWithFormat:@"%@@2x",@"地图button_icon"];
    UIImage *image = [UIImage imageNamed:@"地图button_icon"];
    [_mapButton setBackgroundImage:image forState:UIControlStateNormal];
    [_mapButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [_headView addSubview:_mapButton];
    [_mapButton addTarget:self action:@selector(doTurntoMap) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setTitleView
{
    if(_chineseTitle && ![_chineseTitle isEqualToString:@" "] && _chineseTitle.length > 0 && _englishTitle && ![_englishTitle isEqualToString:@" "] && _englishTitle.length > 0)
    {
        [self setTitleViewWithAll];
    }
    else if(!_englishTitle || _englishTitle.length < 1 ||[_englishTitle isEqualToString:@" "])
    {
        [self setTitleViewWithImageAndChinese];
    }
    else
    {
        [self setTitleViewWithImageAndEnglish];
    }
}
-(void)setTitleViewWithImageAndChinese
{
    _chineseTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(chineseTitleLabelX, chineseTitleLabelY+6, chineseTitleLabelWidth, chineseTitleLabelHeight+2)];
    _chineseTitleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _chineseTitleLabel.backgroundColor = [UIColor clearColor];
    _chineseTitleLabel.text = _chineseTitle;
    _chineseTitleLabel.textAlignment = NSTextAlignmentCenter;
    _chineseTitleLabel.textColor = [UIColor whiteColor];
    _chineseTitleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:chineseTitleTypeSize];
//    _chineseTitleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
//    _chineseTitleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_chineseTitleLabel];
    //[_chineseTitleLabel sizeToFit];
    
    
    if(showImageViewOnNavigationbar)
    {
        UIImageView *imageV;
        if(_chineseTitleLabel.frame.origin.x - chineseTitleLabelX <= 0)
        {
            imageV = [[UIImageView alloc] initWithFrame:CGRectMake(chineseTitleLabelX +5, _chineseTitleLabel.frame.origin.y+_chineseTitleLabel.frame.size.height/2.-11, 18, 18)];
            
            CGRect frame = _chineseTitleLabel.frame;
            frame.origin.x = imageV.frame.origin.x +11+18;
            frame.size.width = chineseTitleLabelWidth-5-18-11;
            _chineseTitleLabel.frame = frame;
        }
        else
        {
            CGRect frame = _chineseTitleLabel.frame;
            frame.origin.x = frame.origin.x +11;
            _chineseTitleLabel.frame = frame;
            
            
            imageV = [[UIImageView alloc] initWithFrame:CGRectMake(_chineseTitleLabel.frame.origin.x-25, _chineseTitleLabel.frame.origin.y+_chineseTitleLabel.frame.size.height/2.-11, 18, 18)];
        }
        imageV.backgroundColor = [UIColor clearColor];
        imageV.image = self.typeImage;
        [_headView addSubview:imageV];
    }
}
-(void)setTitleViewWithImageAndEnglish
{
    _chineseTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(chineseTitleLabelX, chineseTitleLabelY+6, chineseTitleLabelWidth, chineseTitleLabelHeight+2)];
    _chineseTitleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _chineseTitleLabel.backgroundColor = [UIColor clearColor];
    _chineseTitleLabel.text = _englishTitle;
    _chineseTitleLabel.textAlignment = NSTextAlignmentCenter;
    _chineseTitleLabel.textColor = [UIColor whiteColor];
    _chineseTitleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:chineseTitleTypeSize];
//    _chineseTitleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
//    _chineseTitleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_chineseTitleLabel];
    //[_chineseTitleLabel sizeToFit];
    
    
    if(showImageViewOnNavigationbar)
    {
        UIImageView *imageV;
        if(_chineseTitleLabel.frame.origin.x - chineseTitleLabelX <= 0)
        {
            imageV = [[UIImageView alloc] initWithFrame:CGRectMake(chineseTitleLabelX +5, _chineseTitleLabel.frame.origin.y+_chineseTitleLabel.frame.size.height/2.-11, 18, 18)];
            
            CGRect frame = _chineseTitleLabel.frame;
            frame.origin.x = imageV.frame.origin.x +11+18;
            frame.size.width = chineseTitleLabelWidth-5-18-11;
            _chineseTitleLabel.frame = frame;
        }
        else
        {
            CGRect frame = _chineseTitleLabel.frame;
            frame.origin.x = frame.origin.x +11;
            _chineseTitleLabel.frame = frame;
            
            
            imageV = [[UIImageView alloc] initWithFrame:CGRectMake(_chineseTitleLabel.frame.origin.x-25, _chineseTitleLabel.frame.origin.y+_chineseTitleLabel.frame.size.height/2.-11, 18, 18)];
        }
        imageV.backgroundColor = [UIColor clearColor];
        imageV.image = self.typeImage;
        [_headView addSubview:imageV];
    }
}
-(void)setTitleViewWithAll
{
    _chineseTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(chineseTitleLabelX, chineseTitleLabelY, chineseTitleLabelWidth, chineseTitleLabelHeight)];
    _chineseTitleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _chineseTitleLabel.backgroundColor = [UIColor clearColor];
    _chineseTitleLabel.text = _chineseTitle;
    _chineseTitleLabel.textAlignment = NSTextAlignmentCenter;
    _chineseTitleLabel.textColor = [UIColor whiteColor];
    _chineseTitleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:chineseTitleTypeSize];
//    _chineseTitleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
//    _chineseTitleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_chineseTitleLabel];
    //[_chineseTitleLabel sizeToFit];
    
    
    
    CGRect frame = _chineseTitleLabel.frame;
    frame.origin.x = (int)frame.origin.x;
    frame.origin.y = (int)frame.origin.y;
    _chineseTitleLabel.frame = frame;
    
    
    
    _englishTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(englishTitleLabelX, englishTitleLabelY, englishTitleLabelWidth, englishTitleLabelHeight)];
    _englishTitleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _englishTitleLabel.backgroundColor = [UIColor clearColor];
    _englishTitleLabel.text = _englishTitle;
    _englishTitleLabel.textAlignment = NSTextAlignmentCenter;
    _englishTitleLabel.textColor = [UIColor whiteColor];
    _englishTitleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:englishTitleTypeSize];
//    _englishTitleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
//    _englishTitleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_englishTitleLabel];
    
    
    if(showImageViewOnNavigationbar)
    {
        UIImageView *imageV;
        if(_chineseTitleLabel.frame.origin.x - chineseTitleLabelX <= 0)
        {
            imageV = [[UIImageView alloc] initWithFrame:CGRectMake(chineseTitleLabelX +5, _chineseTitleLabel.frame.origin.y+_chineseTitleLabel.frame.size.height/2.-11, 18, 18)];
            
            CGRect frame = _chineseTitleLabel.frame;
            frame.origin.x = imageV.frame.origin.x +11+18;
            frame.size.width = chineseTitleLabelWidth-5-18-11;
            _chineseTitleLabel.frame = frame;
        }
        else
        {
            CGRect frame = _chineseTitleLabel.frame;
            frame.origin.x = frame.origin.x +11;
            _chineseTitleLabel.frame = frame;
            
            
            imageV = [[UIImageView alloc] initWithFrame:CGRectMake(_chineseTitleLabel.frame.origin.x-25, _chineseTitleLabel.frame.origin.y+_chineseTitleLabel.frame.size.height/2.-11, 18, 18)];
        }
        imageV.backgroundColor = [UIColor clearColor];
        imageV.image = self.typeImage;
        [_headView addSubview:imageV];
    }
}



-(void)initData
{
    if(!_myScrollView)
    {
        [self setHomeView];
    }
}

-(void)setHomeView
{
    if(self.dataDic && self.dataDic.count > 0)
    {
        [self setMyData];
        [self performSelector:@selector(initViewAfterGetData) withObject:nil afterDelay:0];
    }
    else
    {
        [self getPoiDetailInfoDataFromServer];
    }
}

#pragma mark -
#pragma mark --- getPoiDetailInfoDataFromCache / FromServer
-(void)getPoiDetailInfoDataFromCacheCompletion:(void (^)(void))completion
{
//    if(_dataDic)
//    {
//        [_dataDic removeAllObjects];
//        [_dataDic release];
//    }
//    
//    NSDictionary *dic = [[CachePoiData sharedCachePoiData] getCachePoiDataWithPoiId:poiId];
//    _dataDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
//    
//    [self setMyData];
//    
//    [self producePoiSrcDatafinished:^{[self initScrollView];completion();} failed:^{completion();}];
}
-(void)setMyData
{
    self.overMerit = [_dataDic objectForKey:@"grade"];
    
    if([_dataDic objectForKey:@"commentcounts"] && ![[_dataDic objectForKey:@"commentcounts"] isKindOfClass:[NSNull class]] && [[NSString stringWithFormat:@"%@",[_dataDic objectForKey:@"commentcounts"]] length] > 0)
    {
        allCommentNumber = [[NSString stringWithFormat:@"%@",[_dataDic objectForKey:@"commentcounts"]] retain];
        
        if([_dataDic objectForKey:@"comment_list"] && ![[_dataDic objectForKey:@"commentcounts"] isKindOfClass:[NSNull class]] && [[_dataDic objectForKey:@"comment_list"] isKindOfClass:[NSArray class]] && [[_dataDic objectForKey:@"comment_list"] count] == 0)
        {
            allCommentNumber = [@"0" retain];
        }
    }
    else
    {
        allCommentNumber = [@"0" retain];
    }
    
    _chineseTitle = [@" " retain];
    if([_dataDic objectForKey:@"chinesename"] && ![[_dataDic objectForKey:@"chinesename"] isKindOfClass:[NSNull class]] && [[_dataDic objectForKey:@"chinesename"] length] > 0)
    {
        [_chineseTitle release];
        _chineseTitle = [[NSString stringWithFormat:@"%@",[_dataDic objectForKey:@"chinesename"]] retain];
    }
    
    _englishTitle = [@" " retain];
    if([_dataDic objectForKey:@"englishname"] && ![[_dataDic objectForKey:@"englishname"] isKindOfClass:[NSNull class]] && [[_dataDic objectForKey:@"englishname"] length] > 0)
    {
        [_englishTitle release];
        _englishTitle = [[NSString stringWithFormat:@"%@",[_dataDic objectForKey:@"englishname"]] retain];
    }
    [self setTitleView];
    
    
    if([_dataDic objectForKey:@"cateid"] && ![[_dataDic objectForKey:@"cateid"] isKindOfClass:[NSNull class]] && [[NSString stringWithFormat:@"%@",[_dataDic objectForKey:@"cateid"]] length] > 0)
    {
        [self setcateid:[_dataDic objectForKey:@"cateid"]];
        _cate_id = [[_dataDic objectForKey:@"cateid"] intValue];
        
    }
    else
    {
        _typeImage = nil;
    }
    
    
    NSLog(@"lat:%@",[_dataDic objectForKey:@"lat"]);
    if(![_dataDic objectForKey:@"lat"] || [[_dataDic objectForKey:@"lat"] isKindOfClass:[NSNull class]] || [[_dataDic objectForKey:@"lat"] length] == 0 || ([_dataDic objectForKey:@"lat"] && [_dataDic objectForKey:@"lat"] && [[_dataDic objectForKey:@"lat"] isEqualToString:@"<null>"]))
    {
        [_dataDic setObject:@"37.441898" forKey:@"lat"];
    }
    if(![_dataDic objectForKey:@"lng"] || [[_dataDic objectForKey:@"lng"] isKindOfClass:[NSNull class]] || [[_dataDic objectForKey:@"lng"] length] == 0 || ([_dataDic objectForKey:@"lng"] && [_dataDic objectForKey:@"lng"] && [[_dataDic objectForKey:@"lng"] isEqualToString:@"<null>"]))
    {
        [_dataDic setObject:@"-122.141899" forKey:@"lng"];
    }
    if([_dataDic objectForKey:@"lat"] && [_dataDic objectForKey:@"lng"] && (![[NSString stringWithFormat:@"%@",[_dataDic objectForKey:@"lat"]] isEqualToString:@"37.441898"]) && (![[NSString stringWithFormat:@"%@",[_dataDic objectForKey:@"lng"]] isEqualToString:@"-122.141899"]))
    {
        [self addMapButton];
        
        lat = [[_dataDic objectForKey:@"lat"] floatValue];
        lng = [[_dataDic objectForKey:@"lng"] floatValue];
    }
}
-(void)setcateid:(NSString*)str
{
    if([str isEqualToString:@"32"]) //景点
    {
        //NSString *str =[NSString stringWithFormat:@"%@@2x",@"目的地icon"];
        //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:@"目的地icon"];
        
        _typeImage = [image retain];
    }
    else if([str isEqualToString:@"77"]) //交通
    {
        //NSString *str =[NSString stringWithFormat:@"%@@2x",@"交通icon"];
        //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:@"交通icon"];
        
        _typeImage = [image retain];
    }
    else if([str isEqualToString:@"78"]) //餐饮
    {
        //NSString *str =[NSString stringWithFormat:@"%@@2x",@"餐饮icon"];
        //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:@"餐饮icon"];
        
        _typeImage = [image retain];
    }
    else if([str isEqualToString:@"147"]) //购物
    {
        //NSString *str =[NSString stringWithFormat:@"%@@2x",@"购物icon"];
        //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:@"购物icon"];
        
        _typeImage = [image retain];
    }
    else if([str isEqualToString:@"148"]) //体验
    {
        //NSString *str =[NSString stringWithFormat:@"%@@2x",@"体验icon"];
        //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:@"体验icon"];
        
        _typeImage = [image retain];
    }
    else if([str isEqualToString:@"149"]) //住宿
    {
        //NSString *str =[NSString stringWithFormat:@"%@@2x",@"酒店icon"];
        //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:@"酒店icon"];
        
        _typeImage = [image retain];
    }
    else if([str isEqualToString:@"150"]) //实用信息
    {
        
    }
    else if([str isEqualToString:@"151"]) //路线
    {
        
    }
    else
    {
        //NSString *str =[NSString stringWithFormat:@"%@@2x",@"目的地icon"];
        //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
        UIImage *image = [UIImage imageNamed:@"目的地icon"];
        
        _typeImage = [image retain];
    }
}


/**
 *  
 */
-(void)getPoiDetailInfoDataFromServer
{
    if (isNotReachable) {
        
        [self setNotReachableView:YES];
        return;
        
    }else{
        
        [self setNotReachableView:NO];
        [self.view hideToast];
        [self.view makeToastActivity];
    }
    
    
    if(!_getPoiDetailInfo_fromServer)
    {
        _getPoiDetailInfo_fromServer = [[GetPoiDetailInfo alloc] init];
    }
    [_getPoiDetailInfo_fromServer getPoiDetailInfoByClientid:ClientId_QY andClientSecrect:ClientSecret_QY poiId:poiId finished:^(NSDictionary *dic){
        
        NSLog(@" PoiDetailInfo : %@",dic);
        [self.view hideToastActivity];
        
        NSMutableDictionary *muDict = (NSMutableDictionary *)dic;
        NSArray *arrKeys = [muDict allKeys];
        NSArray *arrValues = [muDict allValues];

        for (int i = 0;i<arrKeys.count;i++) {
            
            id obj = [arrValues objectAtIndex:i];
            
            if ([obj isEqual:[NSNull null]]) {
                [muDict setObject:@"" forKey:[arrKeys objectAtIndex:i]];
            }
        }
        if (![muDict objectForKey:@"comment_list"]) {
            
            NSArray *array = [[NSArray alloc]init];
            [muDict setObject:array forKey:@"comment_list"];
            [array release];
        }
        
        MYLog(@"获取PoiDetailInfo数据成功 ~~~ ");
        [self getPoiDetailInfoByClientidSuccess:muDict];
        
    } failed:^{
        MYLog(@"获取PoiDetailInfo数据失败 !!! ");
        
        [self setNotReachableView:YES];
        [self.view hideToastActivity];
        
        //[self getPoiDetailInfoByClientidFailed];
    }];
}

-(void)getPoiDetailInfoByClientidSuccess:(NSDictionary *)dic
{
    [self.view hideToastActivity];
    
    if(_dataDic)
    {
        [_dataDic release];
        _dataDic = nil;
    }
    _dataDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    
    [self setMyData];
    [self performSelector:@selector(initViewAfterGetData) withObject:nil afterDelay:0.1];
}

-(void)getPoiDetailInfoByClientidFailed
{
    [self.view hideToastActivity];
    
    [self.view hideToast];
    [self.view makeToast:@"获取详情失败" duration:0.9 position:@"center" isShadow:NO];
    
    [self performSelector:@selector(clickBackButton:) withObject:nil afterDelay:1];
}

-(void)initViewAfterGetData
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"add_new_comment"] isEqualToString:@"1"])
    {
        [self producePoiSrcDatafinished:^{
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"add_new_comment"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            _flag_reDrow_comment = YES;
            [self initScrollView];
            
        } failed:^{
                MYLog(@"producePoiSrcData 失败~~~");
            }
         ];
    }
    else
    {
        [self producePoiSrcDatafinished:^{
            MYLog(@"producePoiSrcData 成功!!! ");
            
            _flag_reDrow_comment = NO;
            [self.view hideToastActivity];
            [self initScrollView];
        } failed:^{
            MYLog(@"producePoiSrcData 失败~~~");
        }];
    }
}
-(void)producePoiSrcDatafinished:(finishedBlock)finished failed:(failedBlock)failed
{
    if(!_dataDic || [_dataDic count] == 0)
    {
        failed();
    }
    else
    {
        if(!_heightDic)
        {
            _heightDic = [[NSMutableDictionary alloc] init];
        }
        [_heightDic removeAllObjects];
        
        
        [_heightDic setObject:[NSString stringWithFormat:@"%d",poiImageHeight] forKey:@"photo"];        //图片高度
        [_heightDic setObject:[NSString stringWithFormat:@"%d",poiCommentHeight] forKey:@"duration"]; //游玩时间高度
        
        
        if(!_detailinfokeyArray)
        {
            _detailinfokeyArray = [[NSMutableArray alloc] init];
        }
        [_detailinfokeyArray removeAllObjects];
        
        
        float height = 0.;
        NSString *str = @" ";
        if([_dataDic objectForKey:@"address"])
        {
            str = [_dataDic objectForKey:@"address"];
            [self produceStr:str withKey1:@"address" andKey2:@"address/地址" withLength:209-16-9+13];
        }
        
        if([_dataDic objectForKey:@"wayto"])
        {
            str = [_dataDic objectForKey:@"wayto"];     //***对 地铁／公交／公交船单独处理
            [self produceStr:str withKey1:@"wayto" andKey2:@"wayto/路线" withLength:209];
        }
        
        if([_dataDic objectForKey:@"opentime"])
        {
            str = [_dataDic objectForKey:@"opentime"];
            [self produceStr:str withKey1:@"opentime" andKey2:@"opentime/时间" withLength:209];
        }
        
        if([_dataDic objectForKey:@"price"])
        {
            str = [_dataDic objectForKey:@"price"];
            [self produceStr:str withKey1:@"price" andKey2:@"price/门票" withLength:209];
        }
        
        if([_dataDic objectForKey:@"phone"])
        {
            str = [_dataDic objectForKey:@"phone"];
            [self produceStr:str withKey1:@"phone" andKey2:@"phone/电话" withLength:209-16-9+13];
        }
        
        if([_dataDic objectForKey:@"site"])
        {
            str = [_dataDic objectForKey:@"site"];
            [self produceStr:str withKey1:@"site" andKey2:@"site/网址" withLength:209-16-9+13];
        }
        
        if([_dataDic objectForKey:@"tips"])
        {
            str = [_dataDic objectForKey:@"tips"];
            [self produceInstructionAndTipsStr:str withKey1:@"tips" withLength:320-8*2];
        }
        
        if([_dataDic objectForKey:@"introduction"])
        {
            str = [_dataDic objectForKey:@"introduction"];
            [self produceInstructionAndTipsStr:str withKey1:@"introduction" withLength:320-8*2];
        }
        
        
        //***详情页的用户评论
        _commentHeight = 0;
        NSArray *commentArray = [_dataDic objectForKey:@"comment_list"];
        int count = [commentArray count];
        if(count>3)
            count=3;
        for(int i = 0; i < count; i++)
        {
            NSDictionary *d = [commentArray objectAtIndex:i];
            str = [d objectForKey:@"comment"];
            if(str && ![str isKindOfClass:[NSNull class]] && str.length > 0 && ![str isEqualToString:@"NULL"])
            {
                height = [self countContentLabelHeightByString:str andLength:230];
                //[_heightDic setObject:[NSString stringWithFormat:@"%f",height] forKey:[[d objectForKey:@"user"] objectForKey:@"username"]];
                [_heightDic setObject:[NSString stringWithFormat:@"%f",height] forKey:[d objectForKey:@"username"]];
                _commentHeight = _commentHeight + height;
            }
        }
        
        finished();
    }
}


-(void)produceInstructionAndTipsStr:(NSString *)str withKey1:(NSString *)key1 withLength:(float)length
{
    //去除内容开头部分的"\r\n\t":
    if([str rangeOfString:@"\r\n\t"].location == 0)
    {
        str = [str substringFromIndex:@"\r\n\t".length];
    }
    
    
    
    str = [str stringByReplacingOccurrencesOfRegex:@"<br />\r\n" withString:@"\n"];
    str = [str stringByReplacingOccurrencesOfRegex:@"<br>" withString:@"\n"];
    str = [str stringByReplacingOccurrencesOfRegex:@"<br/>" withString:@"\n"];
    str = [str stringByReplacingOccurrencesOfRegex:@"<br />" withString:@"\n"];
    
    
    NSString *str2 = (NSMutableString *)[str stringByReplacingOccurrencesOfRegex:@"<(S*?)[^>]*>.*?|<.*? />" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"&ldquo;" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"&rdquo;" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"&nbsp;" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<div>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"</div>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"\r\n" withString:@"\n"];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"\t" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"   " withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"&mdash;" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"&harr;" withString:@"↔"];
    
    
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"\n\n\n\n" withString:@"\n\n"];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"\n\n\n" withString:@"\n\n"];
    
    
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<p>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"</p>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<strong>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"</strong>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<head>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"</head>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<body>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"</body>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<span>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"&ndash;" withString:@""];
    
    NSMutableString *myStr = [[NSMutableString alloc] initWithString:str2];
    
    
    
    if(myStr && myStr.length > 0 && ![myStr isEqualToString:@"NULL"])
    {
        float height = [self countContentLabelHeightByString:myStr andLength:length];
        [_heightDic setObject:[NSString stringWithFormat:@"%f",height] forKey:key1];
        
        
        [_dataDic setObject:myStr forKey:key1];
    }
    else
    {
        [_dataDic removeObjectForKey:key1];
    }
    
    [myStr release];
}


-(void)produceStr:(NSString *)str withKey1:(NSString *)key1 andKey2:(NSString *)key2 withLength:(float)length
{
    
    //针对"盘浦汉江公园"poi进行得处理:
    str = [str stringByReplacingOccurrencesOfRegex:@"\r\n\r\n\t" withString:@""];
    str = [str stringByReplacingOccurrencesOfRegex:@"\r\n\t" withString:@""];
    
    
    
    NSString *str2 = (NSMutableString *)[str stringByReplacingOccurrencesOfRegex:@"&ldquo;" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"&rdquo;" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"&nbsp;" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<div>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"</div>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"\t" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"   " withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<br />\r\n" withString:@"\n"];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<br>" withString:@"\n"];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<br/>" withString:@"\n"];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<br />" withString:@"\n"];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"\r\n" withString:@"\n"];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"\n\n\n" withString:@"\n\n"];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"\n\n\n\n" withString:@"\n\n"];
    
    
    
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<p>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"</p>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<strong>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"</strong>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<head>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"</head>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<body>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"</body>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"<span>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"</span>" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"&mdash;" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfRegex:@"&harr;" withString:@"↔"];
    
    
    
    if([key1 isEqualToString:@"phone"])
    {
        str2 = [str2 stringByReplacingOccurrencesOfRegex:@" " withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfRegex:@"," withString:@""];
        str2 = [str2 stringByReplacingOccurrencesOfRegex:@"/" withString:@""];
    }
    
    
    NSMutableString *myStr = [[NSMutableString alloc] initWithString:str2];
    
    
    if(myStr && myStr.length > 0 && ![myStr isEqualToString:@"NULL"])
    {
        float height = [self countContentLabelHeightByString:myStr andLength:length];
        if([key1 isEqualToString:@"site"])
        {
            height = [self countContentLabelHeightByString:@"我们爱你" andLength:length];
        }
        [_heightDic setObject:[NSString stringWithFormat:@"%f",height] forKey:key1];
        [_detailinfokeyArray addObject:key2];
        [_dataDic setObject:myStr forKey:key1];

    }
    [myStr release];
}

#pragma mark -
#pragma mark --- 初始化视图
-(void)initScrollView
{
    if(!_myScrollView)
    {
        _myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, positionY_scrollView, 320, [self.view bounds].size.height-positionY_scrollView-height_toolBar)];
        _myScrollView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
        _myScrollView.delegate = self;
        _myScrollView.alwaysBounceVertical = YES;
        [self.view addSubview:_myScrollView];
    }
    else
    {
        _myScrollView.frame = CGRectMake(0, positionY_scrollView, 320, [self.view bounds].size.height-positionY_scrollView-height_toolBar);
    }
    [self.view bringSubviewToFront:_headView];
    [self initContentViewByPoiDetailInfoData];
}
-(void)initContentViewByPoiDetailInfoData
{
    [self initBottomToolBar];
    [self initPoiImageView];
    [self initPoiTypeAndCommentNumView];
    [self initIntroductionViewWithFlag:0];
    [self initPoiDetailInfoView];
    [self initTipsView];
    [self initCommentView];
    
    if(_flag_commitPoi)
    {
        [self commentPoi];
    }
}
-(void)initPoiImageView
{
    if([_dataDic objectForKey:@"photo"] && ![[_dataDic objectForKey:@"photo"] isKindOfClass:[NSNull class]])
    {
        float height = [[_heightDic objectForKey:@"photo"] floatValue];
        
        
        if(!_poiImageView)
        {
            _poiImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
        }
        _poiImageView.contentMode = UIViewContentModeScaleAspectFill;
        _poiImageView.clipsToBounds = YES;
        _poiImageView.backgroundColor = [UIColor clearColor];
        UIImage *image = [UIImage imageNamed:@"default_co_back"];
        
        if(!_activityView)
        {
            _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        }
        _activityView.frame = CGRectMake(0, 0, 20, 20);
        _activityView.center = _poiImageView.center;
        [_poiImageView addSubview:_activityView];
        [_activityView startAnimating];
        [_poiImageView setImageWithURL:[NSURL URLWithString:[_dataDic objectForKey:@"photo"]] placeholderImage:image success:^(UIImage *image){
            
            [_activityView stopAnimating];
            
            float positionX = 0;
            float positionY = 0;
            float newImageWidth = 0;
            float newImageHeight = 0;
            if(image.size.width/image.size.height - 16/9. >= 0) //太宽了
            {
                newImageHeight = image.size.height;
                newImageWidth = image.size.height * 16/9.;
                positionX = (image.size.width-newImageWidth)/2.;
            }
            else if(image.size.width/image.size.height - 16/9. < 0) //太高了
            {
                newImageWidth = image.size.width;
                newImageHeight = image.size.width * 9/16.;
                positionY = (image.size.height-newImageHeight)/2.;
            }
            else
            {
                newImageWidth = image.size.width;
                newImageHeight = image.size.width;
                positionY = image.size.height;
            }
            
            CGImageRef newImageRect = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(positionX, positionY, newImageWidth, newImageHeight));
            UIImage *newImage = [UIImage imageWithCGImage:newImageRect];
            [_poiImageView setImage:newImage];
            CGImageRelease(newImageRect);

        } failure:^(NSError *error){
            [_activityView stopAnimating];
            _poiImageView.image = [UIImage imageNamed:@"default_co_back"];

        }];
        [_myScrollView addSubview:_poiImageView];
        
        orginY = _poiImageView.frame.size.height;
        
        
        
        if(_dataDic && [_dataDic objectForKey:@"img_count"] && [[_dataDic objectForKey:@"img_count"] intValue] > 0)
        {
            if(!_control_poiImageView)
            {
                _control_poiImageView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
            }
            [_control_poiImageView addTarget:self action:@selector(doBrowserPhoto) forControlEvents:UIControlEventTouchUpInside];
            _poiImageView.userInteractionEnabled = YES;
            [_poiImageView addSubview:_control_poiImageView];
        }
        
        
        if(!_bgView_imageCount)
        {
            _bgView_imageCount = [[UIImageView alloc] initWithFrame:CGRectMake(320-50-20, 10, 60, 20)];
            _bgView_imageCount.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, _bgView_imageCount.frame.size.width, 20)];
            if(ios7)
            {
                label.frame = CGRectMake(0, 0, _bgView_imageCount.frame.size.width, 20);
            }
            label.backgroundColor = [UIColor clearColor];
            label.adjustsFontSizeToFitWidth = YES;
            label.text = [NSString stringWithFormat:@"%@张",[_dataDic objectForKey:@"img_count"]];
            label.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13];
            label.textAlignment = NSTextAlignmentCenter;
            //label.shadowOffset = CGSizeMake(0, 1);
            //label.shadowColor = [UIColor blackColor];
            label.adjustsFontSizeToFitWidth = YES;
            label.textColor = [UIColor whiteColor];
            [_bgView_imageCount addSubview:label];
            [_bgView_imageCount.layer setCornerRadius:3];
            [label release];
            [_poiImageView addSubview:_bgView_imageCount];
        }
        
    }
    else
    {
        MYLog(@"该POI没有图片");
        
        if(!_poiImageView)
        {
            _poiImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, poiImageHeight)];
        }
        _poiImageView.backgroundColor = [UIColor clearColor];
        _poiImageView.image = [UIImage imageNamed:@"default_co_back"];
        [_myScrollView addSubview:_poiImageView];
        orginY = _poiImageView.frame.size.height;
        
    }
}
-(void)setPoiNameInView:(UIView *)poiImageV
{
    if([_dataDic objectForKey:@"chinesename"])
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 32)];
        label.backgroundColor = [UIColor clearColor];
        [poiImageV addSubview:label];
        label.font = [UIFont systemFontOfSize:28];
        label.textColor = [UIColor whiteColor];
        label.text = [_dataDic objectForKey:@"chinesename"];
        [label release];
    }
    if([_dataDic objectForKey:@"englishname"])
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 32)];
        label.backgroundColor = [UIColor clearColor];
        [poiImageV addSubview:label];
        label.font = [UIFont systemFontOfSize:28];
        label.textColor = [UIColor whiteColor];
        label.text = [_dataDic objectForKey:@"englishname"];
        [label release];
    }
}

-(void)initPoiTypeAndCommentNumView
{
    if(!_mapButBackBgView)
    {
        _mapButBackBgView = [[UIView alloc] initWithFrame:CGRectMake(0, orginY, 160, poiCommentHeight)];
        _mapButBackBgView.backgroundColor = RGB(50, 50, 50);
    }
    [_myScrollView addSubview:_mapButBackBgView];
    
    
    if(!_rateView)
    {
        _rateView = [[DYRateView alloc] initWithFrame:CGRectMake(16, 9, 110, 12)
                                             fullStar:[UIImage imageNamed:@"poi_hot_1"]
                                            emptyStar:[UIImage imageNamed:@"poi_hot_0"]];
        _rateView.backgroundColor = [UIColor clearColor];
        _rateView.alignment = RateViewAlignmentLeft;
    }
    [_mapButBackBgView addSubview:_rateView];
    
    
    if(!_hotLevelLbl)
    {
        _hotLevelLbl = [[UILabel alloc]initWithFrame:CGRectMake(16, 22, 220, 20)];
        _hotLevelLbl.backgroundColor = [UIColor clearColor];
        _hotLevelLbl.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        _hotLevelLbl.textAlignment = NSTextAlignmentLeft;
        _hotLevelLbl.textColor = RGB(150, 150, 150);
    }
    [_mapButBackBgView addSubview:_hotLevelLbl];
    
    
    if (!IS_IOS7) {
        
        _hotLevelLbl.frame = CGRectMake(16, 22, 220, 30);

    }
    
    if([_dataDic objectForKey:@"recommendstr"] && ![[_dataDic objectForKey:@"recommendstr"] isKindOfClass:[NSNull class]] && ![[_dataDic objectForKey:@"recommendstr"] isEqualToString:@"null"] && [[_dataDic objectForKey:@"recommendstr"] length] > 0)
    {
        _hotLevelLbl.text = [NSString stringWithFormat:@"热度：%@",[_dataDic objectForKey:@"recommendstr"]];//@"热度：必去";
    }
    
    NSString *strScore = [NSString stringWithFormat:@"%@",[_dataDic objectForKey:@"recommendscores"]];
    _rateView.rate = [strScore floatValue]/100.0;
    
    
    
    
    
    UILabel *line = (UILabel *)[_mapButBackBgView viewWithTag:11111];
    if(!line)
    {
        line = [[UILabel alloc] initWithFrame:CGRectMake(159, 9, 1, 33)];
        line.backgroundColor = [UIColor colorWithRed:86/255. green:86/255. blue:86/255. alpha:1];
        line.tag = 11111;
        [_mapButBackBgView addSubview:line];
        [line release];
    }
    
    
    
    if(!_commentBackBgView)
    {
        _commentBackBgView = [[UIView alloc] initWithFrame:CGRectMake(160, orginY, 160, poiCommentHeight)];
        PoiDetailInfoControl *control = [[PoiDetailInfoControl alloc] initWithFrame:CGRectMake(0, 0, 160, poiCommentHeight)];
        control.bgColorType = 1;  //对点击的背景做下区别
        [control addTarget:self action:@selector(doShowAllComment) forControlEvents:UIControlEventTouchUpInside];
        control.backgroundColor = [UIColor clearColor];
        [_commentBackBgView addSubview:control];
        [control release];
        _commentBackBgView.backgroundColor = RGB(50, 50, 50);
    }
    [_myScrollView addSubview:_commentBackBgView];
    
    
    if(!_commentNumLabel)
    {
        _commentNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, positionY_poiCommentNumberLabel-20, 149, poiCommentHeight)];
        _commentNumLabel.textColor = RGB(150, 150, 150);
        _commentNumLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15.0f];
        _commentNumLabel.backgroundColor = [UIColor clearColor];
    }
    [_commentBackBgView addSubview:_commentNumLabel];
    if([_dataDic objectForKey:@"commentNum"] && ![[_dataDic objectForKey:@"commentNum"] isKindOfClass:[NSNull class]] && ![[_dataDic objectForKey:@"commentNum"] isEqualToString:@"null"] && [[_dataDic objectForKey:@"commentNum"] length] > 0)
    {
        _commentNumLabel.text = [NSString stringWithFormat:@"%@条点评",[_dataDic objectForKey:@"commentNum"]];
    }
    else
    {
        _commentNumLabel.text = @"0条点评";
    }
    
    
    
    UIImageView *arrowImageView = (UIImageView *)[_commentBackBgView viewWithTag:11112];
    if(!arrowImageView)
    {
        arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_commentBackBgView.frame.size.width-9-13, poiCommentHeight/2.-16/2.-4, 24, 24)];
        arrowImageView.backgroundColor = [UIColor clearColor];
        arrowImageView.tag = 11112;
        UIImage *image = [UIImage imageNamed:@"右箭头icon"];
        [arrowImageView setImage:image];
        [_commentBackBgView addSubview:arrowImageView];
        [arrowImageView release];
    }
    
    
    
    //初始化POI的综合评价:
    [self initIntegrativeRateView:_commentBackBgView];
    
    
    orginY = orginY + poiCommentHeight;
}

-(void)initIntroductionViewWithFlag:(BOOL)flag
{
    if([_dataDic objectForKey:@"introduction"] && [[_dataDic objectForKey:@"introduction"] length] > 0 && ![[_dataDic objectForKey:@"introduction"] isEqualToString:@"NULL"])
    {
        orginY = orginY+10;
        
        
        if(!_imageView_background_introduction)
        {
            _imageView_background_introduction = [[UIImageView alloc] initWithFrame:CGRectMake(0, orginY, 320, 40)];
            _imageView_background_introduction.backgroundColor = [UIColor whiteColor];
            [_myScrollView addSubview:_imageView_background_introduction];
            UILabel *line_top = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
            line_top.backgroundColor = [UIColor colorWithRed:197/255. green:200/255. blue:205/255. alpha:1];
            [_imageView_background_introduction addSubview:line_top];
            [line_top release];
            UILabel *line_bottom = [[UILabel alloc] initWithFrame:CGRectMake(8, _imageView_background_introduction.frame.size.height-0.5, 320-8, 0.5)];
            line_bottom.backgroundColor = [UIColor colorWithRed:197/255. green:200/255. blue:205/255. alpha:1];
            [_imageView_background_introduction addSubview:line_bottom];
            [line_bottom release];
        }
        else
        {
            _imageView_background_introduction.frame = CGRectMake(0, orginY, 320, 40);
            [_myScrollView addSubview:_imageView_background_introduction];
        }
        
        
        
        if(!_label_introduction)
        {
            _label_introduction = [[UILabel alloc] initWithFrame:CGRectMake(8, positionY_poiIntroductionLabel, 160, 20)];
            if(!ios7)
            {
                _label_introduction.frame = CGRectMake(8, positionY_poiIntroductionLabel+3, 160, 26);
            }
            _label_introduction.backgroundColor = [UIColor clearColor];
            _label_introduction.text = @"简介";
            _label_introduction.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:17];
            _label_introduction.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        }
        [_imageView_background_introduction addSubview:_label_introduction];
        
        
        
        orginY = orginY+_imageView_background_introduction.frame.size.height;
        
        
        float height_arrow_bottom = 20;
        float introductionLabelHeight = 85;
        if([[_heightDic objectForKey:@"introduction"] floatValue] - 85. < 0)
        {
            introductionLabelHeight = [[_heightDic objectForKey:@"introduction"] floatValue];
        }
        else if(flag == YES)
        {
            introductionLabelHeight = [[_heightDic objectForKey:@"introduction"] floatValue];
        }
        
        if(!_contentLabelBG_poiIntroduction)
        {
            _contentLabelBG_poiIntroduction = [[UIImageView alloc] initWithFrame:CGRectMake(0, orginY, 320, introductionLabelHeight+height_arrow_bottom+10)];
            _contentLabelBG_poiIntroduction.userInteractionEnabled = YES;
            _contentLabelBG_poiIntroduction.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            _contentLabelBG_poiIntroduction.frame = CGRectMake(0, orginY, 320, introductionLabelHeight+height_arrow_bottom+10);
        }
        [_myScrollView addSubview:_contentLabelBG_poiIntroduction];
        
        
        
        if(!_contentLabel_poiIntroduction)
        {
            if(ios7)
            {
                _contentLabel_poiIntroduction = [[UILabel alloc] initWithFrame:CGRectMake(8, positionY_poiIntroductionContentLabel, 320-8*2, introductionLabelHeight)];
            }
            else
            {
                _contentLabel_poiIntroduction = [[UILabel alloc] initWithFrame:CGRectMake(8, positionY_poiIntroductionContentLabel, 320-8*2, introductionLabelHeight+2)];
            }
            _contentLabel_poiIntroduction.numberOfLines = 0;
            _contentLabel_poiIntroduction.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
            _contentLabel_poiIntroduction.backgroundColor = [UIColor clearColor];
            NSMutableString *introductionStr = [[NSMutableString alloc] initWithString:[_dataDic objectForKey:@"introduction"]];
            _contentLabel_poiIntroduction.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
            _contentLabel_poiIntroduction.text = introductionStr;
            [introductionStr release];
        }
        else
        {
            if(ios7)
            {
                _contentLabel_poiIntroduction.frame = CGRectMake(8, positionY_poiIntroductionContentLabel, 320-8*2, introductionLabelHeight);
            }
            else
            {
                _contentLabel_poiIntroduction.frame = CGRectMake(8, positionY_poiIntroductionContentLabel, 320-8*2, introductionLabelHeight+2);
            }
        }
        [_contentLabelBG_poiIntroduction addSubview:_contentLabel_poiIntroduction];
        
        
        
        if(!_arrowImageView)
        {
            _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake((320-48/2)/2, _contentLabel_poiIntroduction.frame.origin.y+_contentLabel_poiIntroduction.frame.size.height, 48/2, 48/2)];
            _arrowImageView.backgroundColor = [UIColor clearColor];
            UIImage *image = [UIImage imageNamed:@"arrowDown"];
            [_arrowImageView setImage:image];
        }
        else
        {
            _arrowImageView.frame = CGRectMake((320-48/2)/2, _contentLabel_poiIntroduction.frame.origin.y+_contentLabel_poiIntroduction.frame.size.height, 48/2, 48/2);
        }
        [_contentLabelBG_poiIntroduction addSubview:_arrowImageView];
        
        
        
        
        if(!_control_poiIntroduction)
        {
            _control_poiIntroduction = [[PoiDetailInfoControl alloc] initWithFrame:CGRectMake(0, orginY, 320, _contentLabelBG_poiIntroduction.frame.size.height)];
            _control_poiIntroduction.type = @"简介";
            _control_poiIntroduction.alpha = 0.5;
            [_control_poiIntroduction addTarget:self action:@selector(doSelectPoiDetailInfo:) forControlEvents:UIControlEventTouchUpInside];
            _control_poiIntroduction.backgroundColor = [UIColor clearColor];
        }
        else
        {
            _control_poiIntroduction.frame = CGRectMake(0, orginY, 320, _contentLabelBG_poiIntroduction.frame.size.height);
        }
        [_myScrollView addSubview:_control_poiIntroduction];
        
        
        
        if(![_contentLabelBG_poiIntroduction viewWithTag:800])
        {
            UILabel *line_bottom2 = [[UILabel alloc] initWithFrame:CGRectMake(0, _contentLabelBG_poiIntroduction.frame.size.height-0.5, 320, 0.5)];
            line_bottom2.tag = 800;
            line_bottom2.backgroundColor = [UIColor colorWithRed:197/255. green:200/255. blue:205/255. alpha:1];
            [_contentLabelBG_poiIntroduction addSubview:line_bottom2];
            [line_bottom2 release];
        }
        else
        {
            UILabel *line_bottom2 = (UILabel *)[_contentLabelBG_poiIntroduction viewWithTag:800];
            line_bottom2.frame = CGRectMake(0, _contentLabelBG_poiIntroduction.frame.size.height-0.5, 320, 0.5);
            [_contentLabelBG_poiIntroduction addSubview:line_bottom2];
        }
        
        
        
        orginY = orginY+_contentLabelBG_poiIntroduction.frame.size.height;
        [_myScrollView setContentSize:CGSizeMake(320, orginY)];
        
    }
    else
    {
        orginY = orginY+10;
    }
}

-(void)initPoiDetailInfoView
{
    if([_detailinfokeyArray count] > 0)
    {
        orginY = orginY+10;
        
        
        //基本信息title:
        //UIImageView *label_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, orginY, 320, 40)];
        if(!_imageView_background_poiDetailInfo)
        {
            _imageView_background_poiDetailInfo = [[UIImageView alloc] initWithFrame:CGRectMake(0, orginY, 320, 40)];
            UILabel *line_top = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
            line_top.backgroundColor = [UIColor colorWithRed:197/255. green:200/255. blue:205/255. alpha:1];
            [_imageView_background_poiDetailInfo addSubview:line_top];
            [line_top release];
            UILabel *line_bottom = [[UILabel alloc] initWithFrame:CGRectMake(8, _imageView_background_poiDetailInfo.frame.size.height-0.5, 320-8, 0.5)];
            line_bottom.backgroundColor = [UIColor colorWithRed:197/255. green:200/255. blue:205/255. alpha:1];
            [_imageView_background_poiDetailInfo addSubview:line_bottom];
            [line_bottom release];
        }
        else
        {
            _imageView_background_poiDetailInfo.frame = CGRectMake(0, orginY, 320, 40);
        }
        _imageView_background_poiDetailInfo.backgroundColor = [UIColor whiteColor];
        [_myScrollView addSubview:_imageView_background_poiDetailInfo];
        
        
        
        if(!_label_poiDetailInfo)
        {
            _label_poiDetailInfo = [[UILabel alloc] initWithFrame:CGRectMake(8, positionY_PoiDetailInfoView, 160, 20)];
            if(!ios7)
            {
                _label_poiDetailInfo.frame = CGRectMake(8, positionY_PoiDetailInfoView+2, 160, 26);
            }
        }
        else
        {
            if(!ios7)
            {
                _label_poiDetailInfo.frame = CGRectMake(8, positionY_PoiDetailInfoView+2, 160, 26);
            }
            else
            {
                _label_poiDetailInfo.frame = CGRectMake(8, positionY_PoiDetailInfoView, 160, 20);
            }
        }
        _label_poiDetailInfo.backgroundColor = [UIColor clearColor];
        _label_poiDetailInfo.text = @"基本信息";
        _label_poiDetailInfo.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:17];
        _label_poiDetailInfo.textColor  = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        [_imageView_background_poiDetailInfo addSubview:_label_poiDetailInfo];
        
        
        orginY = orginY+_imageView_background_poiDetailInfo.frame.size.height;
        orginYCopy = orginY;
        
        
        //初始化基本信息:
        for(int i = 0; i < [_detailinfokeyArray count]; i++)
        {
            orginY = orginY+10;
            if(i == [_detailinfokeyArray count]-1)
            {
                [self initDetailInfoView:[_detailinfokeyArray objectAtIndex:i] isLast:1 atPosition:i];
            }
            else
            {
                [self initDetailInfoView:[_detailinfokeyArray objectAtIndex:i] isLast:0 atPosition:i];
            }
        }
        
        
        //基本信息背景:
        if(!_imageView_PoiDetail)
        {
            _imageView_PoiDetail = [[UIImageView alloc] initWithFrame:CGRectMake(0,orginYCopy,320,(orginY-orginYCopy))];
        }
        else
        {
            _imageView_PoiDetail.frame = CGRectMake(0,orginYCopy,320,(orginY-orginYCopy));
        }
        _imageView_PoiDetail.userInteractionEnabled = YES;
        _imageView_PoiDetail.backgroundColor = [UIColor whiteColor];
        [_myScrollView insertSubview:_imageView_PoiDetail belowSubview:_imageView_background_poiDetailInfo];
        
        
        
        UILabel *line_bottom_2 = (UILabel *)[_myScrollView viewWithTag:900];
        if(line_bottom_2)
        {
            line_bottom_2.frame = CGRectMake(0, _imageView_PoiDetail.frame.origin.y+_imageView_PoiDetail.frame.size.height-0.5, 320, 0.5);
            [_myScrollView addSubview:line_bottom_2];
        }
        else
        {
            line_bottom_2 = [[UILabel alloc] initWithFrame:CGRectMake(0, _imageView_PoiDetail.frame.origin.y+_imageView_PoiDetail.frame.size.height-0.5, 320, 0.5)];
            line_bottom_2.tag = 900;
            line_bottom_2.backgroundColor = [UIColor colorWithRed:197/255. green:200/255. blue:205/255. alpha:1];
            [_myScrollView addSubview:line_bottom_2];
            [line_bottom_2 release];
        }
        
        
        orginY = orginY+10;
        [_myScrollView setContentSize:CGSizeMake(320, orginY)];
        
    }
    else
    {
        orginY = orginY+10;
    }
}
-(void)initDetailInfoView:(NSString *)type isLast:(BOOL)flag atPosition:(NSInteger)position
{
    NSRange range = [type rangeOfString:@"/"];
    NSString *key = [type substringToIndex:range.location];
    NSString *chineseType = [type substringFromIndex:range.location+1];
    
    
    float height = [[_heightDic objectForKey:key] floatValue];
    if([chineseType isEqualToString:@"地址"] || [chineseType isEqualToString:@"电话"] || [chineseType isEqualToString:@"网址"])
    {
        float height_tmp = height+10*2;
        if(height - 24 < 0)
        {
            height_tmp = 44;
        }
        
        PoiDetailInfoControl *_control_PoiDetail = (PoiDetailInfoControl *)[_myScrollView viewWithTag:1230+position];
        if(!_control_PoiDetail)
        {
            _control_PoiDetail = [[PoiDetailInfoControl alloc] initWithFrame:CGRectMake(0, orginY-10, 320, height_tmp)];
            _control_PoiDetail.type = chineseType;
            _control_PoiDetail.tag = 1230+position;
            [_control_PoiDetail addTarget:self action:@selector(doSelectPoiDetailInfo:) forControlEvents:UIControlEventTouchUpInside];
            _control_PoiDetail.backgroundColor = [UIColor clearColor];
            [_myScrollView addSubview:_control_PoiDetail];
            [_control_PoiDetail release];
        }
        else
        {
            _control_PoiDetail.frame = CGRectMake(0, orginY-10, 320, height_tmp);
            [_myScrollView addSubview:_control_PoiDetail];
        }
        
        
        
        BOOL flag_1 = NO;
        UIImageView *logoImageView = (UIImageView *)[_myScrollView viewWithTag:100+position];
        if(logoImageView)
        {
            logoImageView.frame = CGRectMake(8, orginY, 48/2, 48/2);
            [_myScrollView addSubview:logoImageView];
        }
        else
        {
            flag_1 = YES;
            logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, orginY, 48/2, 48/2)];
            logoImageView.backgroundColor = [UIColor clearColor];
            logoImageView.tag = 100+position;
            [self setLogoImageView:logoImageView byType:chineseType];
            [_myScrollView addSubview:logoImageView];
        }
        
        
        
        
        BOOL flag_2 = NO;
        UILabel *typeLabel_info = (UILabel *)[_myScrollView viewWithTag:200+position];;
        if(typeLabel_info)
        {
            if(ios7)
            {
                typeLabel_info.frame = CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+14/2, orginY, 30, 48/2);
            }
            else
            {
                typeLabel_info.frame = CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+14/2, orginY+3, 30, 48/2);
            }
            [_myScrollView addSubview:typeLabel_info];
        }
        else
        {
            flag_2 = YES;
            float yy = orginY;
            if(!ios7)
            {
                yy = yy+3;
            }
            typeLabel_info = [[UILabel alloc] initWithFrame:CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+14/2, yy, 30, 48/2)];
            typeLabel_info.tag = 200+position;
            typeLabel_info.backgroundColor = [UIColor clearColor];
            typeLabel_info.text = chineseType;
            typeLabel_info.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
            [_myScrollView addSubview:typeLabel_info];
            typeLabel_info.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        }
        
        
        float positionY_contentLabel;
        if(height - 24 >= 0)
        {
            positionY_contentLabel = orginY;
        }
        else
        {
            positionY_contentLabel = orginY-10 + (44-height)/2;
        }
        BOOL flag_3 = NO;
        
        if(!ios7)
        {
            positionY_contentLabel = positionY_contentLabel+3;
        }
        UILabel *contentLabel = (UILabel *)[_myScrollView viewWithTag:300+position];
        if(contentLabel)
        {
            contentLabel.frame = CGRectMake(typeLabel_info.frame.size.width+typeLabel_info.frame.origin.x+46/2, positionY_contentLabel, 200, height);
            [_myScrollView addSubview:contentLabel];
        }
        else
        {
            flag_3 = YES;
            contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(typeLabel_info.frame.size.width+typeLabel_info.frame.origin.x+46/2, positionY_contentLabel, 200, height)];
            contentLabel.tag = 300+position;
            contentLabel.numberOfLines = 0;
            contentLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
            contentLabel.backgroundColor = [UIColor clearColor];
            [_myScrollView addSubview:contentLabel];
            contentLabel.text = [_dataDic objectForKey:key];
            contentLabel.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        }
        
        
        
        
        
        
        UIImageView *arrowImageView = (UIImageView *)[_myScrollView viewWithTag:400+position];
        if(arrowImageView)
        {
            arrowImageView.frame = CGRectMake(320-48/2-8/2, logoImageView.frame.origin.y+2, 20, 20);
            [_myScrollView addSubview:arrowImageView];
        }
        else
        {
            arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(320-48/2-8/2, logoImageView.frame.origin.y, 24, 24)];
            arrowImageView.tag = 400+position;
            arrowImageView.backgroundColor = [UIColor clearColor];
            UIImage *image = [UIImage imageNamed:@"右箭头icon"];
            [arrowImageView setImage:image];
            [_myScrollView addSubview:arrowImageView];
            //[arrowImageView release];
        }
        
        
        
        if([chineseType isEqualToString:@"网址"])
        {
            contentLabel.textColor = [UIColor colorWithRed:0 green:114/255. blue:194/255. alpha:1];
        }
        
        if(flag_1)
        {
            [logoImageView release];
        }
        if(flag_2)
        {
            [typeLabel_info release];
        }
        if(flag_3)
        {
            [contentLabel release];
        }
    }
    else
    {
        BOOL flag_1 = NO;
        UIImageView *logoImageView = (UIImageView *)[_myScrollView viewWithTag:1000+position];;
        if(logoImageView)
        {
            logoImageView.frame = CGRectMake(8, orginY, 48/2, 48/2);
            [_myScrollView addSubview:logoImageView];
        }
        else
        {
            flag_1 = YES;
            logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, orginY, 48/2, 48/2)];
            logoImageView.backgroundColor = [UIColor clearColor];
            logoImageView.tag = 1000+position;
            [self setLogoImageView:logoImageView byType:chineseType];
            [_myScrollView addSubview:logoImageView];
        }
        
        
        
        BOOL flag_2 = NO;
        UILabel *typeLabel = (UILabel *)[_myScrollView viewWithTag:2000+position];;
        if(typeLabel)
        {
            if(ios7)
            {
                typeLabel.frame = CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+7, orginY, 30, 48/2);
            }
            else
            {
                typeLabel.frame = CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+7, orginY+3, 30, 48/2);
            }
            [_myScrollView addSubview:typeLabel];
        }
        else
        {
            flag_2 = YES;
            float yy = orginY;
            if(!ios7)
            {
                yy = yy+3;
            }
            typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+7, yy, 30, 48/2)];
            typeLabel.tag = 2000+position;
            typeLabel.backgroundColor = [UIColor clearColor];
            typeLabel.text = chineseType;
            typeLabel.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
            typeLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
            [_myScrollView addSubview:typeLabel];
        }
        
        
        
        float positionY_contentLabel = 0;
        if(height - 24 >= 0)
        {
            positionY_contentLabel = orginY;
        }
        else
        {
            positionY_contentLabel = orginY-10 + (44-height)/2;
        }
        BOOL flag_3 = NO;
        if(!ios7)
        {
            positionY_contentLabel = positionY_contentLabel+3;
        }
        UILabel *contentLabel = (UILabel *)[_myScrollView viewWithTag:3000+position];;
        if(contentLabel)
        {
            contentLabel.frame = CGRectMake(typeLabel.frame.size.width+typeLabel.frame.origin.x+46/2, positionY_contentLabel, 220, height);
            [_myScrollView addSubview:contentLabel];
        }
        else
        {
            flag_3 = YES;
            contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(typeLabel.frame.size.width+typeLabel.frame.origin.x+46/2, positionY_contentLabel, 220, height)];
            contentLabel.tag = 3000+position;
            contentLabel.numberOfLines = 0;
            contentLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
            contentLabel.backgroundColor = [UIColor clearColor];
            [_myScrollView addSubview:contentLabel];
            contentLabel.text = [_dataDic objectForKey:key];
            contentLabel.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        }
        
        
        if(flag_1)
        {
            [logoImageView release];
        }
        if(flag_2)
        {
            [typeLabel release];
        }
        if(flag_3)
        {
            [contentLabel release];
        }
    }
    
    
    
    if(height - 24 >= 0)
    {
        orginY = orginY + height + 10;
    }
    else
    {
        orginY = orginY + 44-10;
    }
    [_myScrollView setContentSize:CGSizeMake(320, orginY)];
    
    
    
    if(flag == 0)
    {
        if([_myScrollView viewWithTag:500+position])
        {
            UIImageView *brokenLineImageView = (UIImageView *)[_myScrollView viewWithTag:500+position];
            brokenLineImageView.frame = CGRectMake(9, orginY, 302, 0.5);
            [_myScrollView addSubview:brokenLineImageView];
        }
        else
        {
            UIImageView *brokenLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, orginY, 302, 0.5)];
            brokenLineImageView.tag = 500+position;
            brokenLineImageView.backgroundColor = [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:0.1];
            [_myScrollView addSubview:brokenLineImageView];
            [brokenLineImageView release];
        }
    }
    else
    {
        if([_myScrollView viewWithTag:600+position])
        {
            UIImageView *brokenLineImageView = (UIImageView *)[_myScrollView viewWithTag:600+position];
            brokenLineImageView.frame = CGRectMake(0, orginY, 320, 0.5);
            [_myScrollView addSubview:brokenLineImageView];
        }
        else
        {
            UIImageView *brokenLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, orginY, 320, 0.5)];
            brokenLineImageView.tag = 600+position;
            brokenLineImageView.backgroundColor = [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:0.1];
            [_myScrollView addSubview:brokenLineImageView];
            [brokenLineImageView release];
        }
    }
}
-(void)setLogoImageView:(UIImageView *)logoImageView byType:(NSString *)type
{
    NSString *str =[NSString stringWithFormat:@"%@@2x",[NSString stringWithFormat:@"%@icon",type]];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
    [logoImageView setImage:image];
}
-(void)initTipsView
{
    if([_dataDic objectForKey:@"tips"] && [[_dataDic objectForKey:@"tips"] length] > 0 && ![[_dataDic objectForKey:@"tips"] isEqualToString:@"NULL"])
    {
        if(_imageView_background_tips)
        {
            _imageView_background_tips.frame = CGRectMake((320-180/2)/2, orginY, 180/2, 60/2);
        }
        else
        {
            _imageView_background_tips = [[UIImageView alloc] initWithFrame:CGRectMake((320-180/2)/2, orginY, 180/2, 60/2)];
            _imageView_background_tips.backgroundColor = [UIColor clearColor];
            _imageView_background_tips.image = [UIImage imageNamed:@"tips"];
        }
        [_myScrollView addSubview:_imageView_background_tips];
        
        
        orginY = orginY+_imageView_background_tips.frame.size.height;
        
        
        float height = [[_heightDic objectForKey:@"tips"] floatValue];
        if(!_imageView_tipsBG_tips)
        {
            if(!ios7)
            {
                _imageView_tipsBG_tips = [[UIImageView alloc] initWithFrame:CGRectMake(8, orginY, 304, height)];
            }
            else
            {
                _imageView_tipsBG_tips = [[UIImageView alloc] initWithFrame:CGRectMake(8, orginY, 304, height+9)];
            }
            _imageView_tipsBG_tips.backgroundColor = [UIColor clearColor];
            _imageView_tipsBG_tips.userInteractionEnabled = YES;
        }
        if(ios7)
        {
            _imageView_tipsBG_tips.frame = CGRectMake(8, orginY, 304, height+9*2);
        }
        else
        {
            _imageView_tipsBG_tips.frame = CGRectMake(8, orginY, 304, height+9);
        }
        [_myScrollView addSubview:_imageView_tipsBG_tips];
        
        
        
        if(!_tipsLabel)
        {
            _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 8, 302-18, height)];
            _tipsLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
            _tipsLabel.numberOfLines = 0;
            _tipsLabel.backgroundColor = [UIColor clearColor];
            _tipsLabel.text = [_dataDic objectForKey:@"tips"];
            _tipsLabel.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        }
        [_imageView_tipsBG_tips addSubview:_tipsLabel];
        
        
        
        
        float height_background = height+9*2+_imageView_background_tips.frame.size.height/2.;
        if(!_imageView_logo)
        {
            _imageView_logo = [[UIImageView alloc] initWithFrame:CGRectMake(10, _imageView_background_tips.frame.origin.y+_imageView_background_tips.frame.size.height/2., 300, height_background)];
            _imageView_logo.backgroundColor = [UIColor whiteColor];
            [_imageView_logo.layer setCornerRadius:3];
        }
        else
        {
            _imageView_logo.frame = CGRectMake(10, _imageView_background_tips.frame.origin.y+_imageView_background_tips.frame.size.height/2., 300, height_background);
        }
        [_myScrollView insertSubview:_imageView_logo atIndex:0];
        
        
        if(ios7)
        {
            orginY = orginY+_imageView_tipsBG_tips.frame.size.height+9;
        }
        else
        {
            orginY = orginY+_imageView_tipsBG_tips.frame.size.height+19;
        }
        [_myScrollView setContentSize:CGSizeMake(320, orginY)];
        
    }
}

-(void)initCommentView
{
    NSLog(@"orginY --- 1 : %f",orginY);
    if([allCommentNumber floatValue] - 0. > 0)
    {
        _commentNumLabel.text = [NSString stringWithFormat:@"%@条点评",allCommentNumber];
        
        
        BOOL flag_reDraw = NO;
        
        //用户评价title:
        if(!_imageView_background_comment)
        {
            if(_flag_reDrow_comment)
            {
                _imageView_background_comment.frame = CGRectMake(0, orginY, 320, 40);
            }
            else
            {
                _imageView_background_comment = [[UIImageView alloc] initWithFrame:CGRectMake(0, orginY, 320, 40)];
                _imageView_background_comment.backgroundColor = [UIColor whiteColor];
                UILabel *line_top = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
                line_top.backgroundColor = [UIColor colorWithRed:197/255. green:200/255. blue:205/255. alpha:1];
                [_imageView_background_comment addSubview:line_top];
                [line_top release];
                UILabel *line_bottom = [[UILabel alloc] initWithFrame:CGRectMake(8, _imageView_background_comment.frame.size.height-0.5, 320-8, 0.5)];
                line_bottom.backgroundColor = [UIColor colorWithRed:197/255. green:200/255. blue:205/255. alpha:1];
                [_imageView_background_comment addSubview:line_bottom];
                [line_bottom release];
            }
        }
        else
        {
            flag_reDraw = YES;
            _imageView_background_comment.frame = CGRectMake(0, orginY, 320, 40);
        }
        [_myScrollView addSubview:_imageView_background_comment];
        
        
        
        if(!_typeLabel_comment)
        {
            _typeLabel_comment = [[UILabel alloc] initWithFrame:CGRectMake(8, positionY_poiCommentView, 260, 20)];
            _typeLabel_comment.backgroundColor = [UIColor clearColor];
            _typeLabel_comment.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:17];
        }
        else
        {
            _typeLabel_comment.frame = CGRectMake(8, positionY_poiCommentView, 260, 20);
        }
        if(!ios7)
        {
            _typeLabel_comment.frame = CGRectMake(8, positionY_PoiDetailInfoView+2, 160, 26);
        }
        [_imageView_background_comment addSubview:_typeLabel_comment];
        _typeLabel_comment.text = [NSString stringWithFormat:@"点评（%@条）",allCommentNumber];
        _typeLabel_comment.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        
        
        
        
        orginY = orginY+_imageView_background_comment.frame.size.height;
        NSLog(@"orginY --- 2 : %f",orginY);
        
        
        //用户评价:
        if(!_commentDataArray)
        {
            _commentDataArray = [[NSMutableArray alloc] init];
        }
        [_commentDataArray removeAllObjects];
        [_commentDataArray addObjectsFromArray:[_dataDic objectForKey:@"comment_list"]];
        
        
        
        if(!_imageView_commentBackGround)
        {
            _imageView_commentBackGround = [[UIImageView alloc] initWithFrame:CGRectMake(0, orginY, 320, _commentHeight+9+44)];
        }
        else
        {
            _imageView_commentBackGround.frame = CGRectMake(0, orginY, 320, _commentHeight+9+44);
        }
        _imageView_commentBackGround.userInteractionEnabled = YES;
        CGRect frame = _imageView_commentBackGround.frame;
        _commentStartHeight = 0;
        _imageView_commentBackGround.backgroundColor = [UIColor whiteColor];
        [_myScrollView addSubview:_imageView_commentBackGround];
        
        
        
        
        if([allCommentNumber intValue] <= 3)
        {
            frame.size.height = frame.size.height+(9+44)*([_commentDataArray count]-1);
            _imageView_commentBackGround.frame = frame;
            
            if(!flag_reDraw)
            {
                bool hasBrokenFlag = 1;
                for(int i = 0; i < [_commentDataArray count]; i++)
                {
                    if(i == [_commentDataArray count]-1) hasBrokenFlag = 0;
                    NSDictionary *dic = [_commentDataArray objectAtIndex:i];
                    [self initUserCommentView:dic withBgView:_imageView_commentBackGround andHasBrokenline:hasBrokenFlag position:i];
                    hasBrokenFlag = 1;
                }
            }
            else if(_flag_reDrow_comment)
            {
                bool hasBrokenFlag = 1;
                for(int i = 0; i < [_commentDataArray count]; i++)
                {
                    if(i == [_commentDataArray count]-1) hasBrokenFlag = 0;
                    NSDictionary *dic = [_commentDataArray objectAtIndex:i];
                    [self initUserCommentView:dic withBgView:_imageView_commentBackGround andHasBrokenline:hasBrokenFlag position:i];
                    hasBrokenFlag = 1;
                }
            }
            else if(_flag_changeComment)
            {
                bool hasBrokenFlag = 1;
                for(int i = 0; i < [_commentDataArray count]; i++)
                {
                    if(i == [_commentDataArray count]-1) hasBrokenFlag = 0;
                    NSDictionary *dic = [_commentDataArray objectAtIndex:i];
                    [self initUserCommentView:dic withBgView:_imageView_commentBackGround andHasBrokenline:hasBrokenFlag position:i];
                    hasBrokenFlag = 1;
                }
            }
        }
        else
        {
            if(ios7)
            {
                frame.size.height = frame.size.height+(9+44)*2 +30 +5;
            }
            else
            {
                frame.size.height = frame.size.height+(9+44)*2 +30;
            }
            _imageView_commentBackGround.frame = frame;
            
            if(!flag_reDraw)
            {
                for(int i = 0; i < 3; i++)
                {
                    NSDictionary *dic = [_commentDataArray objectAtIndex:i];
                    [self initUserCommentView:dic withBgView:_imageView_commentBackGround andHasBrokenline:1 position:i];
                }
                [self initReadOtherCommentView:_imageView_commentBackGround];
            }
            else if(_flag_reDrow_comment)
            {
                for(int i = 0; i < 3; i++)
                {
                    NSDictionary *dic = [_commentDataArray objectAtIndex:i];
                    [self initUserCommentView:dic withBgView:_imageView_commentBackGround andHasBrokenline:1 position:i];
                }
                [self initReadOtherCommentView:_imageView_commentBackGround];
            }
            else if(_flag_changeComment)
            {
                for(int i = 0; i < 3; i++)
                {
                    NSDictionary *dic = [_commentDataArray objectAtIndex:i];
                    NSLog(@"comment : %@",[dic objectForKey:@"comment"]);
                    [self initUserCommentView:dic withBgView:_imageView_commentBackGround andHasBrokenline:1 position:i];
                }
                [self initReadOtherCommentView:_imageView_commentBackGround];
            }
        }
        orginY = orginY+_imageView_commentBackGround.frame.size.height+9;
        
        
        
        //底部阴影:
        if(![_imageView_commentBackGround viewWithTag:700])
        {
            UIImageView *imageView_lastCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, _imageView_commentBackGround.frame.size.height, _imageView_commentBackGround.frame.size.width, 1)];
            imageView_lastCell.tag = 700;
            imageView_lastCell.backgroundColor = [UIColor colorWithRed:197/255. green:200/255. blue:205/255. alpha:1];
            [_imageView_commentBackGround addSubview:imageView_lastCell];
            [imageView_lastCell release];
        }
        else
        {
            UIImageView *imageView_lastCell = (UIImageView *)[_imageView_commentBackGround viewWithTag:700];
            imageView_lastCell.frame = CGRectMake(0, _imageView_commentBackGround.frame.size.height, _imageView_commentBackGround.frame.size.width, 1);
            [_imageView_commentBackGround addSubview:imageView_lastCell];
        }
        
        
        
        [_myScrollView setContentSize:CGSizeMake(320, orginY)];
        
    }
    
    _hasGetHotelNearbyPoiDone = 1;
    
    
    //*** update at 14.07.29
    //[self getHotelBearbyPoiDataFromServer];
    if([_dataDic objectForKey:@"lat"] && [_dataDic objectForKey:@"lng"] && (![[NSString stringWithFormat:@"%@",[_dataDic objectForKey:@"lat"]] isEqualToString:@"37.441898"]) && (![[NSString stringWithFormat:@"%@",[_dataDic objectForKey:@"lng"]] isEqualToString:@"-122.141899"]))
    {
        [self initNearBy];
    }
    
}

-(void)initUserCommentView:(NSDictionary *)dic withBgView:(UIView*)bgView andHasBrokenline:(NSInteger)flag position:(NSInteger)i
{
    NSDictionary *userDic = dic;
    
    
    //用户头像:
    UIImageView *_userImageView_comment = (UIImageView *)[bgView viewWithTag:10+i];
    if(_userImageView_comment)
    {
        _userImageView_comment.frame = CGRectMake(9, _commentStartHeight+9, 43, 43);
    }
    else
    {
        _userImageView_comment = [[UIImageView alloc] initWithFrame:CGRectMake(9, _commentStartHeight+9, 43, 43)];
        _userImageView_comment.tag = 10+i;
        _userImageView_comment.backgroundColor = [UIColor clearColor];
        _userImageView_comment.layer.masksToBounds = YES;
        [_userImageView_comment.layer setCornerRadius:21.];
        [_userImageView_comment setImageWithURL:[NSURL URLWithString:[userDic objectForKey:@"avatar"]]];
        [bgView addSubview:_userImageView_comment];
    }
    
    
    
    //用户名称:
    UILabel *_userNameLabel_comment = (UILabel *)[bgView viewWithTag:20+i];
    if(_userNameLabel_comment)
    {
        _userNameLabel_comment.frame = CGRectMake(9+_userImageView_comment.frame.size.width+9, _commentStartHeight+9, 155, 22);
    }
    else
    {
        _userNameLabel_comment = [[UILabel alloc] initWithFrame:CGRectMake(9+_userImageView_comment.frame.size.width+9, _commentStartHeight+9, 155, 22)];
        _userNameLabel_comment.tag = 20+i;
        _userNameLabel_comment.backgroundColor = [UIColor clearColor];
        _userNameLabel_comment.textAlignment = NSTextAlignmentLeft;
        _userNameLabel_comment.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        _userNameLabel_comment.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
    }
    if(ios7)
    {
        _userNameLabel_comment.frame = CGRectMake(_userNameLabel_comment.frame.origin.x, _userNameLabel_comment.frame.origin.y-4, _userNameLabel_comment.frame.size.width, _userNameLabel_comment.frame.size.height);
    }
    _userNameLabel_comment.text = [userDic objectForKey:@"username"];
    [bgView addSubview:_userNameLabel_comment];
    
    
    
    
    //用户评价时间:
    UILabel *_userCommentTimeLabel = (UILabel *)[bgView viewWithTag:30+i];
    if(_userCommentTimeLabel)
    {
        _userCommentTimeLabel.frame = CGRectMake(9+_userImageView_comment.frame.size.width+9+_userNameLabel_comment.frame.size.width+10, _commentStartHeight+9, 80, 20);
    }
    else
    {
        _userCommentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(9+_userImageView_comment.frame.size.width+9+_userNameLabel_comment.frame.size.width+10, _commentStartHeight+9, 80, 20)];
        _userCommentTimeLabel.tag = 30+i;
        _userCommentTimeLabel.backgroundColor = [UIColor clearColor];
        _userCommentTimeLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:10];
        _userCommentTimeLabel.textAlignment = NSTextAlignmentRight;
        _userCommentTimeLabel.textColor = [UIColor colorWithRed:165/255. green:165/255. blue:165/255. alpha:1];
    }
    if(ios7)
    {
        _userCommentTimeLabel.frame = CGRectMake(_userCommentTimeLabel.frame.origin.x, _userCommentTimeLabel.frame.origin.y-4, _userCommentTimeLabel.frame.size.width, _userCommentTimeLabel.frame.size.height);
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *myDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"datetime"] doubleValue]]];
    [dateFormatter release];
    _userCommentTimeLabel.text = myDateStr;
    [bgView addSubview:_userCommentTimeLabel];
    
    
    
    
    //用户评价:
    UILabel *_userCommentLabel = (UILabel *)[bgView viewWithTag:40+i];
    if(_userCommentLabel)
    {
        _userCommentLabel.frame = CGRectMake(9+_userImageView_comment.frame.size.width+9, _userImageView_comment.frame.size.height+_userImageView_comment.frame.origin.y-2, 250, [[_heightDic objectForKey:[userDic objectForKey:@"username"]] floatValue]);
    }
    else
    {
        _userCommentLabel = [[UILabel alloc] initWithFrame:CGRectMake(9+_userImageView_comment.frame.size.width+9, _userImageView_comment.frame.size.height+_userImageView_comment.frame.origin.y-2, 250, [[_heightDic objectForKey:[userDic objectForKey:@"username"]] floatValue])];
        _userCommentLabel.tag = 40+i;
        _userCommentLabel.numberOfLines = 0;
        _userCommentLabel.adjustsFontSizeToFitWidth = YES;
        _userCommentLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
        _userCommentLabel.backgroundColor = [UIColor clearColor];
        _userCommentLabel.textColor = [UIColor colorWithRed:102/255. green:102/255. blue:102/255. alpha:1];
    }
    if(ios7)
    {
        _userCommentLabel.frame = CGRectMake(_userCommentLabel.frame.origin.x, _userCommentLabel.frame.origin.y-4, _userCommentLabel.frame.size.width, _userCommentLabel.frame.size.height);
    }
    _userCommentLabel.text = [dic objectForKey:@"comment"];
    [bgView addSubview:_userCommentLabel];
    
    
    
    
    //初始化用户评星:
    NSString *str = [NSString stringWithFormat:@"%@@2x",@""];
    UIImage *hollowImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
    
    UIImageView *i_view = (UIImageView *)[_imageView_commentBackGround viewWithTag:1100+i];
    if(i_view)
    {
        [i_view removeFromSuperview];
    }
    _userCommentRateView1 = [[[UIImageView alloc] initWithFrame:CGRectMake(9+_userImageView_comment.frame.size.width+9, _commentStartHeight+9+_userNameLabel_comment.frame.size.height, 10, 10)] autorelease];
    _userCommentRateView1.tag = 1100+i;
    if(ios7)
    {
        _userCommentRateView1.frame = CGRectMake(_userCommentRateView1.frame.origin.x, _userCommentRateView1.frame.origin.y-2, _userCommentRateView1.frame.size.width, _userCommentRateView1.frame.size.height);
    }
    _userCommentRateView1.backgroundColor = [UIColor clearColor];
    _userCommentRateView1.image = hollowImage;
    [bgView addSubview:_userCommentRateView1];
    
    
    
    UIImageView *ii_view = (UIImageView *)[_imageView_commentBackGround viewWithTag:1200+i];
    if(ii_view)
    {
        [ii_view removeFromSuperview];
    }
    _userCommentRateView2 = [[[UIImageView alloc] initWithFrame:CGRectMake(_userCommentRateView1.frame.origin.x+_userCommentRateView1.frame.size.width+3, _commentStartHeight+9+_userNameLabel_comment.frame.size.height, 10, 10)] autorelease];
    _userCommentRateView2.tag = 1200+i;
    if(ios7)
    {
        _userCommentRateView2.frame = CGRectMake(_userCommentRateView2.frame.origin.x, _userCommentRateView2.frame.origin.y-2, _userCommentRateView2.frame.size.width, _userCommentRateView2.frame.size.height);
    }
    _userCommentRateView2.backgroundColor = [UIColor clearColor];
    _userCommentRateView2.image = hollowImage;
    [bgView addSubview:_userCommentRateView2];
    
    
    
    UIImageView *iii_view = (UIImageView *)[_imageView_commentBackGround viewWithTag:1300+i];
    if(iii_view)
    {
        [iii_view removeFromSuperview];
    }
    _userCommentRateView3 = [[[UIImageView alloc] initWithFrame:CGRectMake(_userCommentRateView2.frame.origin.x+_userCommentRateView2.frame.size.width+3, _commentStartHeight+9+_userNameLabel_comment.frame.size.height, 10, 10)] autorelease];
    _userCommentRateView3.tag = 1300+i;
    if(ios7)
    {
        _userCommentRateView3.frame = CGRectMake(_userCommentRateView3.frame.origin.x, _userCommentRateView3.frame.origin.y-2, _userCommentRateView3.frame.size.width, _userCommentRateView3.frame.size.height);
    }
    _userCommentRateView3.backgroundColor = [UIColor clearColor];
    _userCommentRateView3.image = hollowImage;
    [bgView addSubview:_userCommentRateView3];
    
    
    
    UIImageView *iiii_view = (UIImageView *)[_imageView_commentBackGround viewWithTag:1400+i];
    if(iiii_view)
    {
        [iiii_view removeFromSuperview];
    }
    _userCommentRateView4 = [[[UIImageView alloc] initWithFrame:CGRectMake(_userCommentRateView3.frame.origin.x+_userCommentRateView3.frame.size.width+3, _commentStartHeight+9+_userNameLabel_comment.frame.size.height, 10, 10)] autorelease];
    _userCommentRateView4.tag = 1400+i;
    if(ios7)
    {
        _userCommentRateView4.frame = CGRectMake(_userCommentRateView4.frame.origin.x, _userCommentRateView4.frame.origin.y-2, _userCommentRateView4.frame.size.width, _userCommentRateView4.frame.size.height);
    }
    _userCommentRateView4.backgroundColor = [UIColor clearColor];
    _userCommentRateView4.image = hollowImage;
    [bgView addSubview:_userCommentRateView4];
    
    
    
    UIImageView *iiiii_view = (UIImageView *)[_imageView_commentBackGround viewWithTag:1500+i];
    if(iiiii_view)
    {
        [iiiii_view removeFromSuperview];
    }
    _userCommentRateView5 = [[[UIImageView alloc] initWithFrame:CGRectMake(_userCommentRateView4.frame.origin.x+_userCommentRateView4.frame.size.width+3, _commentStartHeight+9+_userNameLabel_comment.frame.size.height, 10, 10)] autorelease];
    _userCommentRateView5.tag = 1500+i;
    if(ios7)
    {
        _userCommentRateView5.frame = CGRectMake(_userCommentRateView5.frame.origin.x, _userCommentRateView5.frame.origin.y-2, _userCommentRateView5.frame.size.width, _userCommentRateView5.frame.size.height);
    }
    _userCommentRateView5.backgroundColor = [UIColor clearColor];
    _userCommentRateView5.image = hollowImage;
    [bgView addSubview:_userCommentRateView5];
    [self initRateView:[dic objectForKey:@"star"]];
    
    
    
    //用户评价之间的分割线:
    if(flag == 1)
    {
        UIImageView *brokenLineImageView = (UIImageView *)[bgView viewWithTag:50+i];
        if(brokenLineImageView)
        {
            [brokenLineImageView removeFromSuperview];
        }
        
        
        brokenLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, _userCommentLabel.frame.size.height+_userCommentLabel.frame.origin.y, 310, 0.5)];
        brokenLineImageView.tag = 50+i;
        if(ios7)
        {
            brokenLineImageView.frame = CGRectMake(brokenLineImageView.frame.origin.x, brokenLineImageView.frame.origin.y+6, brokenLineImageView.frame.size.width, brokenLineImageView.frame.size.height);
        }
        brokenLineImageView.backgroundColor = [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:0.1];
        [bgView addSubview:brokenLineImageView];
        [brokenLineImageView release];
        
        _commentStartHeight = brokenLineImageView.frame.origin.y+0.5;
    }
}
-(void)initRateView:(NSString*)rate
{
    rate = [NSString stringWithFormat:@"%d",[rate integerValue]/2];
    
    UIImage *image = [UIImage imageNamed:@"star"];
    UIImage *halfImage = [UIImage imageNamed:@"halfstar"];
    UIImage *hollowImage = [UIImage imageNamed:@"hollowstar"];
    
    if([rate isEqualToString:@"0"])  //全设为灰色
    {
        self.userCommentRateView1.image = hollowImage;
        self.userCommentRateView2.image = hollowImage;
        self.userCommentRateView3.image = hollowImage;
        self.userCommentRateView4.image = hollowImage;
        self.userCommentRateView5.image = hollowImage;
        return;
    }
    if([rate isEqualToString:@"1"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = hollowImage;
        self.userCommentRateView3.image = hollowImage;
        self.userCommentRateView4.image = hollowImage;
        self.userCommentRateView5.image = hollowImage;
    }
    else if([rate isEqualToString:@"1.5"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = halfImage;
        self.userCommentRateView3.image = hollowImage;
        self.userCommentRateView4.image = hollowImage;
        self.userCommentRateView5.image = hollowImage;
    }
    else if([rate isEqualToString:@"2"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = image;
        self.userCommentRateView3.image = hollowImage;
        self.userCommentRateView4.image = hollowImage;
        self.userCommentRateView5.image = hollowImage;
    }
    else if([rate isEqualToString:@"2.5"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = image;
        self.userCommentRateView3.image = halfImage;
        self.userCommentRateView4.image = hollowImage;
        self.userCommentRateView5.image = hollowImage;
    }
    else if([rate isEqualToString:@"3"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = image;
        self.userCommentRateView3.image = image;
        self.userCommentRateView4.image = hollowImage;
        self.userCommentRateView5.image = hollowImage;
    }
    else if([rate isEqualToString:@"3.5"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = image;
        self.userCommentRateView3.image = image;
        self.userCommentRateView4.image = halfImage;
        self.userCommentRateView5.image = hollowImage;
    }
    else if([rate isEqualToString:@"4"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = image;
        self.userCommentRateView3.image = image;
        self.userCommentRateView4.image = image;
        self.userCommentRateView5.image = hollowImage;
    }
    else if([rate isEqualToString:@"4.5"])
    {
        self.userCommentRateView1.image = image;
        self.userCommentRateView2.image = image;
        self.userCommentRateView3.image = image;
        self.userCommentRateView4.image = image;
        self.userCommentRateView5.image = halfImage;
    }
    else if([rate isEqualToString:@"5"])  //全设为彩色
    {
        [self setAllRateViewColorful];
    }
}
-(void)initAllRateView
{
    UIImage *hollowImage = [UIImage imageNamed:@"hollowstar"];
    
    self.userCommentRateView1.image = hollowImage;
    self.userCommentRateView2.image = hollowImage;
    self.userCommentRateView3.image = hollowImage;
    self.userCommentRateView4.image = hollowImage;
    self.userCommentRateView5.image = hollowImage;
}
-(void)setAllRateViewColorful
{
    UIImage *image = [UIImage imageNamed:@"star"];
    
    self.userCommentRateView1.image = image;
    self.userCommentRateView2.image = image;
    self.userCommentRateView3.image = image;
    self.userCommentRateView4.image = image;
    self.userCommentRateView5.image = image;
}
-(void)initReadOtherCommentView:(UIView *)bgView
{
    if(!_control_comment)
    {
        _control_comment = [[PoiDetailInfoControl alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height-36, 320, 36)];
        [_control_comment addTarget:self action:@selector(doShowAllComment) forControlEvents:UIControlEventTouchUpInside];
        _control_comment.backgroundColor = [UIColor clearColor];
    }
    else
    {
        _control_comment.frame = CGRectMake(0, bgView.frame.size.height-36, 320, 36);
    }
    [bgView addSubview:_control_comment];
    
    
    
    CGRect frame = _control_comment.frame;
    if(!ios7)
    {
        frame.origin.y += 3;
    }
    if(!_label_infoComment)
    {
        _label_infoComment = [[UILabel alloc] initWithFrame:frame];
        _label_infoComment.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        _label_infoComment.backgroundColor = [UIColor clearColor];
        _label_infoComment.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        _label_infoComment.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        _label_infoComment.frame = frame;
    }
    _label_infoComment.text = [NSString stringWithFormat:@"查看全部%@条点评",allCommentNumber];
    [bgView addSubview:_label_infoComment];
    
}


#pragma mark -
#pragma mark --- 计算String所占的高度
-(float)countContentLabelHeightByString:(NSString *)content andLength:(float)length
{
    CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:@"HiraKakuProN-W3" size:14] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    //CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    
    return sizeToFit.height;
}
-(float)countContentLabelHeightByString:(NSString *)content andLength:(float)length andTypeSize:(float)size
{
    CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:@"HiraKakuProN-W3" size:size] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    //CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:size] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    
    return sizeToFit.height;
}

#pragma mark -
#pragma mark --- doShowAllComment
-(void)doShowAllComment
{
    if (isUserClick) {
        return;
    }
    isUserClick = YES;
    
    [MobClick event:@"poiDetailClickReview"];
    
    
    
    PoiAllCommentViewController *poiAllCommentVC = [[PoiAllCommentViewController alloc] init];
    poiAllCommentVC.poiId = poiId;
    if(_chineseTitle)
    {
        poiAllCommentVC.navigationTitle = _chineseTitle;
    }
    else
    {
        poiAllCommentVC.navigationTitle = _englishTitle;
    }
    poiAllCommentVC.allCommentNumberStr = allCommentNumber;
    [self.navigationController pushViewController:poiAllCommentVC animated:YES];
    [poiAllCommentVC release];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isUserClick = NO;
    });
}

#pragma mark -
#pragma mark --- doSelectPoiDetailInfo
-(void)doSelectPoiDetailInfo:(PoiDetailInfoControl *)control
{
    
    if (isUserClick) {
        return;
    }
    isUserClick = YES;
    
    if([control.type isEqualToString:@"简介"])
    {
        [self showPoiInstructionView];
        
//        PoiInstructionViewController *poiInstructionVC = [[PoiInstructionViewController alloc] init];
//        poiInstructionVC.instruction = [_dataDic objectForKey:@"introduction"];
//        poiInstructionVC.typeImage = self.typeImage;
//        poiInstructionVC.chineseTitle = _chineseTitle;
//        poiInstructionVC.englishTitle = _englishTitle;
//        [self.navigationController pushViewController:poiInstructionVC animated:YES];
//        [poiInstructionVC release];
        
    }
    else if([control.type isEqualToString:@"电话"])
    {
        
        BOOL flag = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[_dataDic objectForKey:@"phone"]]]];
        
        if(flag == 0)
        {
            [self.view hideToast];
            [self.view makeToast:@"该设备不支持电话" duration:1. position:@"center" isShadow:NO];
        }
        else
        {
            //拨打电话返回应用
            UIWebView*callWebview =[[[UIWebView alloc] init]autorelease];
            [callWebview setFrame:CGRectZero];
            NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [_dataDic objectForKey:@"phone"]]];
            [self.view addSubview:callWebview];
            [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        }
    }
    else if([control.type isEqualToString:@"地址"])
    {
        [self doTurntoMap];
        
    }
    else if([control.type isEqualToString:@"网址"])
    {
        NSString *webStr = [_dataDic objectForKey:@"site"];
        if([webStr rangeOfString:@"http://"].location == NSNotFound && [webStr rangeOfString:@"https://"].location == NSNotFound)
        {
            webStr = [NSString stringWithFormat:@"http://%@",webStr];
        }
        
        WebViewViewController *webVC = [[WebViewViewController alloc] init];
        webVC.flag_plan = 0;
        [webVC setStartURL:webStr];
        [self presentViewController:[QYToolObject getControllerWithBaseController:webVC] animated:YES completion:nil];
        [webVC release];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isUserClick = NO;
    });
}
-(void)turnToSystemMap
{
    NSString *version = [[GetInfo getDeviceInfoSystemVersion] retain];
    if([version floatValue] - 6. < 0)
    {
        //***(1).通过坐标跳转到google地图
        float latitudeTurnTo = lat;
        float longitudeTurnTo = lng;
        NSString *url = [NSString stringWithFormat:@"http://maps.google.com/?q=%f,%f",latitudeTurnTo,longitudeTurnTo];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    else
    {
        CLLocationCoordinate2D location;
        location.latitude = lat;
        location.longitude = lng;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil];
        MKMapItem *item = [[[MKMapItem alloc] initWithPlacemark:placemark] autorelease];
        [placemark release];
        //[item setName:@"i am here"];
        if(_chineseTitle && _chineseTitle.length > 0)
        {
            [item setName:_chineseTitle];
        }
        else
        {
            [item setName:_englishTitle];
        }
        
        //[item setPhoneNumber:@"+86 15501197655"];
        //[item setUrl:[NSURL URLWithString:@"http://www.qyer.com"]];
        NSDictionary *mapLaunchOptions = [NSDictionary dictionaryWithObjectsAndKeys:@"title",@"title", nil];
        [item openInMapsWithLaunchOptions:mapLaunchOptions];
    }
    [version release];
}



#pragma mark -
#pragma mark --- 此处为图片下面的那些小星星星星星星星星星星星星星星⋯⋯
-(void)initIntegrativeRateView:(UIView *)commentBackBgView
{
    if(!_userCommentRateView11)
    {
        _userCommentRateView11 = [[UIImageView alloc] initWithFrame:CGRectMake(commentRateStarPositionX, 29, 15, 15)];
        _userCommentRateView11.backgroundColor = [UIColor clearColor];
        [commentBackBgView addSubview:_userCommentRateView11];
    }
    
    
    if(!_userCommentRateView22)
    {
        _userCommentRateView22 = [[UIImageView alloc] initWithFrame:CGRectMake(commentRateStarPositionX+(15+4), 29, 15, 15)];
        _userCommentRateView22.backgroundColor = [UIColor clearColor];
        [commentBackBgView addSubview:_userCommentRateView22];
    }
    
    if(!_userCommentRateView33)
    {
        _userCommentRateView33 = [[UIImageView alloc] initWithFrame:CGRectMake(commentRateStarPositionX+(15+4)+(15+4), 29, 15, 15)];
        _userCommentRateView33.backgroundColor = [UIColor clearColor];
        [commentBackBgView addSubview:_userCommentRateView33];
    }
    
    if(!_userCommentRateView44)
    {
        _userCommentRateView44 = [[UIImageView alloc] initWithFrame:CGRectMake(commentRateStarPositionX+(15+4)+(15+4)+(15+4), 29, 15, 15)];
        _userCommentRateView44.backgroundColor = [UIColor clearColor];
        [commentBackBgView addSubview:_userCommentRateView44];
    }
    
    if(!_userCommentRateView55)
    {
        _userCommentRateView55 = [[UIImageView alloc] initWithFrame:CGRectMake(commentRateStarPositionX+(15+4)+(15+4)+(15+4)+(15+4), 29, 15, 15)];
        _userCommentRateView55.backgroundColor = [UIColor clearColor];
        [commentBackBgView addSubview:_userCommentRateView55];
    }
    
    
    [self setIntegrativeRateView:[_dataDic objectForKey:@"grade"]];
}
-(void)setAllGrayStar
{
    //NSString *str =[NSString stringWithFormat:@"%@@2x",@"hollowstar"];
    //UIImage *hollowImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
    UIImage *hollowImage = [UIImage imageNamed:@"hollowstar"];
    
    _userCommentRateView11.image = hollowImage;
    _userCommentRateView22.image = hollowImage;
    _userCommentRateView33.image = hollowImage;
    _userCommentRateView44.image = hollowImage;
    _userCommentRateView55.image = hollowImage;
}
-(void)setIntegrativeRateView:(NSString *)rate
{
    if([rate isKindOfClass:[NSNumber class]])
    {
        rate = [NSString stringWithFormat:@"%@",rate];
    }
    else if(!rate || [rate isEqualToString:@"null"] || rate.length == 0)
    {
        rate = @"0";
    }
    rate = [NSString stringWithFormat:@"%f",[rate integerValue]/2.];
    //NSLog(@" 综合评价: %@",rate);
    
    UIImage *image = [UIImage imageNamed:@"star"];
    UIImage *halfImage = [UIImage imageNamed:@"halfstar"];
    UIImage *hollowImage = [UIImage imageNamed:@"hollowstar"];
    
    if([rate floatValue] - 0. == 0)  //全设为灰色
    {
        [self setAllGrayStar];
        return;
    }
    if([rate floatValue] - 1. == 0)
    {
        _userCommentRateView11.image = image;
        _userCommentRateView22.image = hollowImage;
        _userCommentRateView33.image = hollowImage;
        _userCommentRateView44.image = hollowImage;
        _userCommentRateView55.image = hollowImage;
    }
    else if([rate floatValue] - 1.5 == 0)
    {
        _userCommentRateView11.image = image;       
        _userCommentRateView22.image = halfImage;
        _userCommentRateView33.image = hollowImage;
        _userCommentRateView44.image = hollowImage;
        _userCommentRateView55.image = hollowImage;
    }
    else if([rate floatValue] - 2. == 0)
    {
        _userCommentRateView11.image = image;
        _userCommentRateView22.image = image;
        _userCommentRateView33.image = hollowImage;
        _userCommentRateView44.image = hollowImage;
        _userCommentRateView55.image = hollowImage;
    }
    else if([rate floatValue] - 2.5 == 0)
    {
        _userCommentRateView11.image = image;
        _userCommentRateView22.image = image;
        _userCommentRateView33.image = halfImage;
        _userCommentRateView44.image = hollowImage;
        _userCommentRateView55.image = hollowImage;
    }
    else if([rate floatValue] - 3. == 0)
    {
        _userCommentRateView11.image = image;
        _userCommentRateView22.image = image;
        _userCommentRateView33.image = image;
        _userCommentRateView44.image = hollowImage;
        _userCommentRateView55.image = hollowImage;
    }
    else if([rate floatValue] - 3.5 == 0)
    {
        _userCommentRateView11.image = image;
        _userCommentRateView22.image = image;
        _userCommentRateView33.image = image;
        _userCommentRateView44.image = halfImage;
        _userCommentRateView55.image = hollowImage;
    }
    else if([rate floatValue] - 4. == 0)
    {
        _userCommentRateView11.image = image;
        _userCommentRateView22.image = image;
        _userCommentRateView33.image = image;
        _userCommentRateView44.image = image;
        _userCommentRateView55.image = hollowImage;
    }
    else if([rate floatValue] - 4.5 == 0)
    {
        _userCommentRateView11.image = image;
        _userCommentRateView22.image = image;
        _userCommentRateView33.image = image;
        _userCommentRateView44.image = image;
        _userCommentRateView55.image = halfImage;
    }
    else if([rate floatValue] - 5. == 0)  //全设为彩色
    {
        [self setAllRateViewColorful2];
    }
}
-(void)setAllRateViewColorful2
{
    //NSString *str =[NSString stringWithFormat:@"%@@2x",@"点评星icon"];
    //UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
    UIImage *image = [UIImage imageNamed:@"star"];
    
    _userCommentRateView11.image = image;
    _userCommentRateView22.image = image;
    _userCommentRateView33.image = image;
    _userCommentRateView44.image = image;
    _userCommentRateView55.image = image;
}


#pragma mark -
#pragma mark --- doBrowserPhoto
-(void)doBrowserPhoto
{
    if (isUserClick) {
        return;
    }
    isUserClick = YES;
    
    
    PoiPhotoBrowserViewController *poiPhotoVC = [[PoiPhotoBrowserViewController alloc] init];
    poiPhotoVC.poiId = self.poiId;
    poiPhotoVC.strType = @"poi";
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_chineseTitle forKey:@"_chineseTitle"];
    [dic setObject:_englishTitle forKey:@"_englishTitle"];
    poiPhotoVC.dic_navation = dic;
    [dic release];
    [self.navigationController pushViewController:poiPhotoVC animated:YES];
    [poiPhotoVC release];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isUserClick = NO;
    });
}


#pragma mark -
#pragma mark --- 跳转到地图
-(void)doTurntoMap
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_chineseTitle forKey:@"_chineseTitle"];
    [dic setObject:_englishTitle forKey:@"_englishTitle"];
    [dic setObject:[NSString stringWithFormat:@"%f",lat] forKey:@"lat"];
    [dic setObject:[NSString stringWithFormat:@"%f",lng] forKey:@"lng"];
    [dic setObject:[NSString stringWithFormat:@"%d",_cate_id] forKey:@"cateid"];
    [dic setObject:[NSString stringWithFormat:@"%d",self.poiId] forKey:@"poiId"];
    GoogleMapViewController *googleMapVC = [[GoogleMapViewController alloc] init];
    googleMapVC.array_in = nil;
    googleMapVC.dic_in = dic;
    googleMapVC.tap_notEnabled = YES;
    [dic release];
    if([dic objectForKey:@"_chineseTitle"])
    {
        googleMapVC.title_navigation = [dic objectForKey:@"_chineseTitle"];
    }
    else
    {
        googleMapVC.title_navigation = [dic objectForKey:@"_englishTitle"];
    }
    [self.navigationController pushViewController:googleMapVC animated:YES];
    [googleMapVC release];
    
    
    
    
    
//    QYMapViewController *qyMapVC = [[QYMapViewController alloc] init];
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setObject:_chineseTitle forKey:@"_chineseTitle"];
//    [dic setObject:_englishTitle forKey:@"_englishTitle"];
//    [dic setObject:[NSString stringWithFormat:@"%f",lat] forKey:@"lat"];
//    [dic setObject:[NSString stringWithFormat:@"%f",lng] forKey:@"lng"];
//    [dic setObject:[NSString stringWithFormat:@"%d",_cate_id] forKey:@"cateid"];
//    [dic setObject:[NSString stringWithFormat:@"%d",self.poiId] forKey:@"poiId"];
//    [qyMapVC initPinarrayWithDic:dic];
//    [dic release];
//    
//    qyMapVC.fromPoidetailVC = 1;
//    qyMapVC.showPopViewFlag = 1;
//    [self.navigationController pushViewController:qyMapVC animated:YES];
//    if(_chineseTitle && _chineseTitle.length > 0)
//    {
//        [qyMapVC setNavigationTitle:_chineseTitle];
//    }
//    else
//    {
//        [qyMapVC setNavigationTitle:_englishTitle];
//    }
//    [qyMapVC release];
}


#pragma mark -
#pragma mark --- freshPartOfData
-(void)freshPartOfData
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"add_new_comment"] isEqualToString:@"1"])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getPoiDetailInfoDataFromServer];
            dispatch_async(dispatch_get_main_queue(), ^{
                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"add_new_comment"] isEqualToString:@"0"])
                {
                    [self freshCommentAndCommentNum];
                }
            });
        });
    }
}
-(void)freshCommentAndCommentNum
{
    _commentNumLabel.text = [NSString stringWithFormat:@"%@条点评",[_dataDic objectForKey:@"commentNum"]];
    [self initCommentView];
}



#pragma mark -
#pragma mark --- 查看周边
-(void)initNearBy
{
    if(!_imageView_background_nearby)
    {
        _imageView_background_nearby = [[UIImageView alloc] initWithFrame:CGRectMake(0, orginY, 320, 40)];
        _imageView_background_nearby.backgroundColor = [UIColor whiteColor];
        UILabel *line_top = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
        line_top.backgroundColor = [UIColor colorWithRed:197/255. green:200/255. blue:205/255. alpha:1];
        [_imageView_background_nearby addSubview:line_top];
        [line_top release];
        UILabel *line_bottom = [[UILabel alloc] initWithFrame:CGRectMake(8, _imageView_background_nearby.frame.size.height-0.5, 320-8, 0.5)];
        line_bottom.backgroundColor = [UIColor colorWithRed:197/255. green:200/255. blue:205/255. alpha:1];
        [_imageView_background_nearby addSubview:line_bottom];
        [line_bottom release];
    }
    else
    {
        _imageView_background_nearby.frame = CGRectMake(0, orginY, 320, 40);
    }
    [_myScrollView addSubview:_imageView_background_nearby];
    
    
    
    if(!_typeLabel_nearby)
    {
        _typeLabel_nearby = [[UILabel alloc] initWithFrame:CGRectMake(8, positionY_HotelNearbyPoi, 80, 22)];
        if(!ios7)
        {
            _typeLabel_nearby.frame = CGRectMake(8, positionY_PoiDetailInfoView, 80, 28);
        }
        _typeLabel_nearby.backgroundColor = [UIColor clearColor];
        _typeLabel_nearby.text = @"查看周边";
        _typeLabel_nearby.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        _typeLabel_nearby.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:17];
    }
    else
    {
        
        if(!ios7)
        {
            _typeLabel_nearby.frame = CGRectMake(8, positionY_PoiDetailInfoView, 80, 28);
        }
        else
        {
            _typeLabel_nearby.frame = CGRectMake(8, positionY_HotelNearbyPoi, 80, 22);
        }
    }
    [_imageView_background_nearby addSubview:_typeLabel_nearby];
    
    
    orginY = orginY+_imageView_background_nearby.frame.size.height;
    
    
    
    if(!_nearbyBackBgView)
    {
        _nearbyBackBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, orginY, 320, 80)];
        _nearbyBackBgView.userInteractionEnabled = YES;
        _nearbyBackBgView.backgroundColor = [UIColor whiteColor];
        _nearbyBackBgView.alpha = 1;
        UIImageView *imageView_lastCell = [[UIImageView alloc] initWithFrame:CGRectMake(0, _nearbyBackBgView.frame.size.height, _nearbyBackBgView.frame.size.width, 2)];
        imageView_lastCell.backgroundColor = [UIColor clearColor];
        imageView_lastCell.image = [UIImage imageNamed:@"首页_底部阴影"];
        [_nearbyBackBgView addSubview:imageView_lastCell];
        [imageView_lastCell release];
    }
    else
    {
        _nearbyBackBgView.frame = CGRectMake(0, orginY, 320, 80);
    }
    [_myScrollView addSubview:_nearbyBackBgView];
    
    
    
    for(int i = 0; i < 5; i++)
    {
        [self initNearByImageViewAtPosition:i inView:_nearbyBackBgView];
    }
    
    orginY = orginY+80+10;
    [_myScrollView setContentSize:CGSizeMake(320, orginY)];
}
-(void)initNearByImageViewAtPosition:(NSInteger)position inView:(UIView *)superView
{
    NSInteger positionX = (320-5*68/2)/6 + position*(68/2+(320-5*68/2)/6);
    NSInteger positionY = 10;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = position+1;
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(positionX, positionY, 68/2, 108/2);
    [superView addSubview:button];
    UIImage *image_default = nil;
    UIImage *image_selected = nil;
    switch (position)
    {
        case 0:
        {
            image_default = [UIImage imageNamed:@"poi"];
            image_selected = [UIImage imageNamed:@"press_poi"];
        }
            break;
            
        case 1:
        {
            image_default = [UIImage imageNamed:@"food"];
            image_selected = [UIImage imageNamed:@"press_food"];
        }
            break;
            
        case 2:
        {
            image_default = [UIImage imageNamed:@"shopping"];
            image_selected = [UIImage imageNamed:@"press_shopping"];
        }
            break;
            
        case 3:
        {
            image_default = [UIImage imageNamed:@"entertainment"];
            image_selected = [UIImage imageNamed:@"press_entertainment"];
        }
            break;
            
        case 4:
        {
            image_default = [UIImage imageNamed:@"hotel"];
            image_selected = [UIImage imageNamed:@"press_hotel"];
        }
            break;
            
        default:
            break;
    }
    [button addTarget:self action:@selector(selectNearBy:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:image_default forState:UIControlStateNormal];
    [button setBackgroundImage:image_selected forState:UIControlStateSelected];
}
-(void)selectNearBy:(id)sender   //32：景点、77：交通、78：餐饮、147：购物、148：活动、149：住宿、 150：实用信息、151：路线
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    
    PoiNearByViewController *poiNearByVC = [[PoiNearByViewController alloc] init];
    poiNearByVC.lat = [[_dataDic objectForKey:@"lat"] floatValue];
    poiNearByVC.lon = [[_dataDic objectForKey:@"lng"] floatValue];
    poiNearByVC.poiId = self.poiId;
    poiNearByVC.hotel_nearBy = NO;
    
    switch (tag)
    {
        case 1:
        {
            NSLog(@" 选择景点");
            poiNearByVC.categoryId = 32;
            poiNearByVC.navigationTitle = @"周边景点";
            
            [MobClick event:@"poiClickAround" label:@"景点"];
            
        }
            break;
            
        case 2:
        {
            NSLog(@" 选择美食");
            poiNearByVC.categoryId = 78;
            poiNearByVC.navigationTitle = @"周边美食";
            
            [MobClick event:@"poiClickAround" label:@"美食"];
            
        }
            break;
            
        case 3:
        {
            NSLog(@" 选择购物");
            poiNearByVC.categoryId = 147;
            poiNearByVC.navigationTitle = @"周边购物";
            
            [MobClick event:@"poiClickAround" label:@"购物"];
            
        }
            break;
            
        case 4:
        {
            NSLog(@" 选择娱乐");
            poiNearByVC.categoryId = 148;
            poiNearByVC.navigationTitle = @"周边娱乐";
            
            [MobClick event:@"poiClickAround" label:@"娱乐"];
            
        }
            break;
            
        case 5:
        {
            NSLog(@" 选择酒店");
            poiNearByVC.hotel_nearBy = YES;
            poiNearByVC.navigationTitle = @"周边酒店";
            
            [MobClick event:@"poiClickAround" label:@"酒店"];
            
        }
            break;
            
        default:
            break;
    }
    
    [self.navigationController pushViewController:poiNearByVC animated:YES];
    [poiNearByVC release];
}



#pragma mark -
#pragma mark --- init - BottomToolBar
-(void)initBottomToolBar
{
    if(!_bottomToolBar)
    {
        _bottomToolBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-height_toolBar, 320, height_toolBar)];
        _bottomToolBar.userInteractionEnabled = YES;
        _bottomToolBar.backgroundColor = [UIColor colorWithRed:69/255. green:79/255. blue:97/255. alpha:1];
        
        
        
        for(int i = 0; i < 3; i++)
        {
            NSInteger positionX = 320/3*i;
            NSInteger positionY = 0;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(positionX, positionY, 320/3, 44)];
            imageView.userInteractionEnabled = YES;
            imageView.backgroundColor = [UIColor clearColor];
            [_bottomToolBar addSubview:imageView];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i+1;
            button.frame = CGRectMake((320-214/2*3)/2., 0, 214/2, 88/2);
            UIImage *image_default = nil;
            UIImage *image_select = nil;
            if(i == 0)
            {
                image_default = [UIImage imageNamed:@"去过"];
                image_select = [UIImage imageNamed:@"highlight_去过"];
                
                if(_dataDic && [[_dataDic objectForKey:@"beento"] boolValue] == YES)
                {
                    [button setSelected:YES];
                }
                else
                {
                    [button setSelected:NO];
                }
            }
            else if(i == 1)
            {
                image_default = [UIImage imageNamed:@"想去"];
                image_select = [UIImage imageNamed:@"highlight_想去"];
                
                if(_dataDic && [[_dataDic objectForKey:@"planto"] boolValue] == YES)
                {
                    [button setSelected:YES];
                }
                else
                {
                    [button setSelected:NO];
                }
            }
            else if(i == 2)
            {
                image_default = [UIImage imageNamed:@"review"];
                image_select = [UIImage imageNamed:@"highlight_review"];
                
                if(self.userComment && self.userComment.length > 0)
                {
                    [button setSelected:YES];
                }
                else
                {
                    [button setSelected:NO];
                }
            }
            [button addTarget:self action:@selector(selectToolBar:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:image_default forState:UIControlStateNormal];
            [button setBackgroundImage:image_select forState:UIControlStateSelected];
            [imageView addSubview:button];
            [imageView release];
        }
    }
    else
    {
        _bottomToolBar.frame = CGRectMake(0, self.view.frame.size.height-height_toolBar, 320, height_toolBar);
        for(int i = 0; i < 3; i++)
        {
            NSInteger tag = i+1;
            UIButton *button = (UIButton *)[_bottomToolBar viewWithTag:tag];
            
            UIImage *image_default = nil;
            UIImage *image_select = nil;
            if(i == 0)
            {
                image_default = [UIImage imageNamed:@"去过"];
                image_select = [UIImage imageNamed:@"highlight_去过"];
                
                if(_dataDic && [[_dataDic objectForKey:@"beento"] boolValue] == YES)
                {
                    [button setSelected:YES];
                }
                else
                {
                    [button setSelected:NO];
                }
            }
            else if(i == 1)
            {
                image_default = [UIImage imageNamed:@"想去"];
                image_select = [UIImage imageNamed:@"highlight_想去"];
                
                if(_dataDic && [[_dataDic objectForKey:@"planto"] boolValue] == YES)
                {
                    [button setSelected:YES];
                }
                else
                {
                    [button setSelected:NO];
                }
            }
            else if(i == 2)
            {
                image_default = [UIImage imageNamed:@"review"];
                image_select = [UIImage imageNamed:@"highlight_review"];
                
                if(self.userComment && self.userComment.length > 0)
                {
                    [button setSelected:YES];
                }
                else
                {
                    [button setSelected:NO];
                }
            }
        }
    }
    
    [self.view addSubview:_bottomToolBar];
}
-(void)selectToolBar:(id)sender
{
    //*** 网络不好:
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view makeToast:@"网络错误" duration:1 position:@"center" isShadow:NO];
        return;
    }
    
    
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    
    switch (tag)
    {
        case 1:
        {
            NSLog(@" 点击去过");
            
            
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
            {
                NSLog(@"未登录");
                _type_beforeLogin = @"去过";
                [self showLoginView];
            }
            else
            {
                if(_flag_postBeento)
                {
                    break;
                }
                _flag_postBeento = YES;
                [self produceBeenToWithTag:tag];
            }
        }
            break;
            
        case 2:
        {
            NSLog(@" 点击想去");
            
            
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
            {
                NSLog(@"未登录");
                _type_beforeLogin = @"想去";
                [self showLoginView];
            }
            else
            {
                if(_flag_postWantgo)
                {
                    break;
                }
                _flag_postWantgo = YES;
                [self producePlanToWithTag:tag];
            }
        }
            break;
            
        case 3:
        {
            NSLog(@" 点击点评");
            
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
            {
                [self commentPoi];
            }
            else
            {
                NSLog(@" 提示先登录 ");
                _type_beforeLogin = @"点评";
                [self showLoginView];
            }
        }
            break;
            
        default:
            break;
    }
}
-(void)produceBeenToWithTag:(NSInteger)tag
{
    UIButton *button = (UIButton *)[_bottomToolBar viewWithTag:tag];
    if(button.selected)
    {
        [FootPrintDelete deleteFootPrintWithOper:@"beento"
                                         andType:@"poi"
                                           andId:self.poiId
                                         success:^(NSDictionary *dic){
                                             _flag_postBeento = NO;
                                             [button setSelected:NO];
                                         }
                                          failed:^(NSError *error){
                                              _flag_postBeento = NO;
                                          }];
    }
    else
    {
        [MobClick event:@"poiClickBeenTo"];
        
        [FootPrintAdd addFootPrintWithOper:@"beento"
                                   andType:@"poi"
                                     andId:self.poiId
                                   success:^(NSDictionary *dic){
                                       _flag_postBeento = NO;
                                       [button setSelected:YES];
                                   }
                                    failed:^(NSError *error){
                                        _flag_postBeento = NO;
                                    }];
    }
}
-(void)producePlanToWithTag:(NSInteger)tag
{
    UIButton *button = (UIButton *)[_bottomToolBar viewWithTag:tag];
    if(button.selected)
    {
        [FootPrintDelete deleteFootPrintWithOper:@"planto"
                                         andType:@"poi"
                                           andId:self.poiId
                                         success:^(NSDictionary *dic){
                                             _flag_postWantgo = NO;
                                             [button setSelected:NO];
                                         }
                                          failed:^(NSError *error){
                                              _flag_postWantgo = NO;
                                          }];
    }
    else
    {
        [MobClick event:@"poiClickWishTo"];
        
        [FootPrintAdd addFootPrintWithOper:@"planto"
                                   andType:@"poi"
                                     andId:self.poiId
                                   success:^(NSDictionary *dic){
                                       _flag_postWantgo = NO;
                                       [button setSelected:YES];
                                   }
                                    failed:^(NSError *error){
                                        _flag_postWantgo = NO;
                                    }];
    }
}


#pragma mark -
#pragma mark --- 点评poi
-(void)commentPoi
{
    
    [MobClick event:@"poiClickWrtReview"];
    
    
    if(self.userComment)
    {
        NSInteger positionY = 44;
        if(ios7)
        {
            positionY = positionY + 20;
        }
        PoiRateView *_poiRateView = [[PoiRateView alloc] initWithFrame:CGRectMake((320-580/2)/2., positionY, 580/2, 1136/2) andLeftButTitle:@"取消" andRightButTitle:@"发送" andRate:[NSString stringWithFormat:@"%d",[self.userCommentRate intValue]/2] andVC:self];
        [_poiRateView setTextViewText:self.userComment];
        _poiRateView.poiTitle = self.navigationTitle;
        _poiRateView.poiId = poiId;
        _poiRateView.commentId_user = [NSString stringWithFormat:@"%d",self.commentId];
        [_poiRateView release];
    }
    else
    {
        NSInteger positionY = 44;
        if(ios7)
        {
            positionY = positionY + 20;
        }
        PoiRateView *_poiRateView = [[PoiRateView alloc] initWithFrame:CGRectMake((320-580/2)/2., positionY, 580/2, 1136/2) andLeftButTitle:@"取消" andRightButTitle:@"发送" andRate:@"0" andVC:self];
        [_poiRateView setTextViewText:@""];
        _poiRateView.poiTitle = self.navigationTitle;
        _poiRateView.poiId = poiId;
        [_poiRateView release];
    }
}


#pragma mark -
#pragma mark --- 推出登录页面
-(void)showLoginView
{
    CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
    navigationController.navigationBarHidden = YES;
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:navigationController animated:YES completion:nil];
    [cityLoginVC release];
}


#pragma mark -
#pragma mark --- 登录成功
-(void)loginIn_Success
{
    _flag_login = YES;
    _flag_commitPoi = NO;
    if(_type_beforeLogin && [_type_beforeLogin isEqualToString:@"点评"])
    {
        _flag_commitPoi = YES;
    }
    
    if(_type_beforeLogin && [_type_beforeLogin isEqualToString:@"想去"])
    {
        _type_beforeLogin = nil;
        
        [MobClick event:@"poiClickWishTo"];
        
        [FootPrintAdd addFootPrintWithOper:@"planto"
                                   andType:@"poi"
                                     andId:self.poiId
                                   success:^(NSDictionary *dic){
                                       _flag_postWantgo = NO;
                                       
                                       [self getMinePoiCommentFromServer];
                                       [self getPoiDetailInfoDataFromServer];
                                       
                                   }
                                    failed:^(NSError *error){
                                        _flag_postWantgo = NO;
                                    }];
    }
    else if(_type_beforeLogin && [_type_beforeLogin isEqualToString:@"去过"])
    {
        _type_beforeLogin = nil;
        
        [MobClick event:@"poiClickBeenTo"];
        
        [FootPrintAdd addFootPrintWithOper:@"beento"
                                   andType:@"poi"
                                     andId:self.poiId
                                   success:^(NSDictionary *dic){
                                       _flag_postBeento = NO;
                                       
                                       [self getMinePoiCommentFromServer];
                                       [self getPoiDetailInfoDataFromServer];
                                       
                                   }
                                    failed:^(NSError *error){
                                        _flag_postBeento = NO;
                                    }];
    }
    else
    {
        [self getMinePoiCommentFromServer];
        [self getPoiDetailInfoDataFromServer];
    }
}



#pragma mark -
#pragma mark --- 获取用户自己的点评
-(void)getMinePoiCommentFromServer
{
    [self getMinePoiCommentDataCompletion:^{
        
        NSLog(@" self.userComment : %@",self.userComment);
        NSLog(@" self.userCommentRate : %@",self.userCommentRate);
        
        
        [self.view hideToastActivity];
        
        if(_bottomToolBar && self.userComment && self.userComment.length > 0)
        {
            UIButton *button = (UIButton *)[_bottomToolBar viewWithTag:3];
            if(button)
            {
                [button setSelected:YES];
            }
        }
        
    } failed:^{
        
    }];
}
-(void)getMinePoiCommentDataCompletion:(void (^)(void))completion failed:(void (^)(void))failed
{
    GetMinePoiComment *_getMineComment = [[GetMinePoiComment alloc] init];
    [_getMineComment getMineCommentByClientid:ClientId_QY andPoiId:self.poiId finished:^{
        
        self.userComment = _getMineComment.userComment;
        self.userCommentRate = _getMineComment.userCommentRate;
        self.commentId = _getMineComment.userCommentId;
        
        completion();
        
    } failed:^{
        
        if(self.userCommentRate && self.userComment)
        {
            
        }
        else
        {
            self.userCommentRate = @"0";
            self.userComment = @"";
        }
        
        failed();
        
    }];
    [_getMineComment release];
}

//
//-(float)countHotelLabelWidthByString:(NSString*)content andTypeSize:(float)size
//{
//    CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:@"HiraKakuProN-W6" size:size] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 999)];
//    
//    return sizeToFit.width;
//}
//-(void)initHotelViewBrokenLine:(NSInteger)positionY andWidth:(float)width inView:(UIView*)hotelNearbyBackBgView
//{
//    UIImageView *brokenLine = [[UIImageView alloc] initWithFrame:CGRectMake(61, positionY-1, width-3-60, 0.5)];
//    //brokenLine.image = [UIImage imageNamed:@"line.png"];
//    brokenLine.backgroundColor = [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:0.1];
//    [hotelNearbyBackBgView addSubview:brokenLine];
//    [brokenLine release];
//}
//-(void)initHotelViewLayer:(UIView*)hotelNearbyBackBgView
//{
//    UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, hotelNearbyBackBgView.frame.size.width, 1)];
//    topLine.backgroundColor = [UIColor colorWithRed:204/255. green:204/255. blue:204/255. alpha:0.8];
//    [hotelNearbyBackBgView addSubview:topLine];
//    
//    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, hotelNearbyBackBgView.frame.size.height, hotelNearbyBackBgView.frame.size.width, 1)];
//    bottomLine.backgroundColor = [UIColor colorWithRed:204/255. green:204/255. blue:204/255. alpha:0.8];
//    [hotelNearbyBackBgView addSubview:bottomLine];
//    
//    UILabel *leftLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, hotelNearbyBackBgView.frame.size.height)];
//    leftLine.backgroundColor = [UIColor colorWithRed:204/255. green:204/255. blue:204/255. alpha:0.8];
//    [hotelNearbyBackBgView addSubview:leftLine];
//    
//    UILabel *rightLine = [[UILabel alloc] initWithFrame:CGRectMake(hotelNearbyBackBgView.frame.size.width-1, 0, 1, hotelNearbyBackBgView.frame.size.height)];
//    rightLine.backgroundColor = [UIColor colorWithRed:204/255. green:204/255. blue:204/255. alpha:0.8];
//    [hotelNearbyBackBgView addSubview:rightLine];
//    
//    [topLine release];
//    [bottomLine release];
//    [leftLine release];
//    [rightLine release];
//}


#pragma mark -
#pragma mark --- turnToBooking
-(void)turnToBooking:(id)sender
{
    if (isUserClick) {
        return;
    }
    isUserClick = YES;
    
    PoiDetailInfoControl *control = (PoiDetailInfoControl*)sender;
    if(_bookingUrlStr && _bookingUrlStr.retainCount > 0 && ![_bookingUrlStr isEqualToString:control.bookingUrlStr])
    {
        [_bookingUrlStr release];
    }
    _bookingUrlStr = [control.bookingUrlStr retain];
    
    
    NSString *machine = [GetDeviceDetailInfo getDetailInfo];
    if([machine rangeOfString:@"iPod4"].location != NSNotFound || [machine rangeOfString:@"iPhone2"].location != NSNotFound)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"确定使用系统浏览器打开？"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        [alertView show];
        [alertView release];
    }
    else
    {
        WebViewViewController *webVC = [[WebViewViewController alloc] init];
        webVC.flag_plan = 0;
        [webVC setStartURL:control.bookingUrlStr];
        [self presentViewController:[QYToolObject getControllerWithBaseController:webVC] animated:YES completion:nil];
        [webVC release];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isUserClick = NO;
    });
}
- (void)clickSafariButton:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"确定使用系统浏览器打开？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [alertView cancelButtonIndex])
    {
        return;
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_bookingUrlStr]];
    }
}


#pragma mark -
#pragma mark --- 展示全部的简介
-(void)showPoiInstructionView
{
    float height = [[_heightDic objectForKey:@"photo"] floatValue];
    orginY = height + poiCommentHeight;
    
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         
                         if(!_flag_show)
                         {
                             [self initIntroductionViewWithFlag:1];
                         }
                         else
                         {
                             [self initIntroductionViewWithFlag:0];
                         }
                         
                         [self initPoiDetailInfoView];
                         [self initTipsView];
                         [self initCommentView];
                         
                     } completion:^(BOOL finished){
                         
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              
                                              if(!_flag_show)
                                              {
                                                  float rotateAngle = M_PI;
                                                  CGAffineTransform transform = CGAffineTransformMakeRotation(rotateAngle);
                                                  _arrowImageView.transform = transform;
                                              }
                                              else
                                              {
                                                  CGAffineTransform transform = CGAffineTransformIdentity;
                                                  _arrowImageView.transform = transform;
                                              }
                                          } completion:^(BOOL finished){
                                              
                                              _flag_show = !_flag_show;
                                          }];
                     }];
}

-(void)comment_success
{
    NSLog(@" 评论成功 ");
    
    [MobClick event:@"poiWrtReviewSuccess"];
    
    _flag_commitPoi = NO;
    _flag_changeComment = YES;
    [self getMinePoiCommentFromServer];
    [self getPoiDetailInfoDataFromServer];
}



#pragma mark -
#pragma mark --- clickBackButton
- (void)clickBackButton:(id)sender
{
    [_getPoiDetailInfo_fromServer cancle];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    didReceiveMemoryWarningFlag = 1;
    
    if(_dataDic)
    {
        [_dataDic release];
        _dataDic = nil;
    }
    if(_commentDataArray)
    {
        [_commentDataArray removeAllObjects];
        [_commentDataArray release];
        _commentDataArray = nil;
    }
    if(_detailinfokeyArray)
    {
        [_detailinfokeyArray removeAllObjects];
        [_detailinfokeyArray release];
        _detailinfokeyArray = nil;
    }
    if(_heightDic)
    {
        [_heightDic removeAllObjects];
        [_heightDic release];
        _heightDic = nil;
    }
    if(_hotelDataArray)
    {
        [_hotelDataArray removeAllObjects];
        [_hotelDataArray release];
        _hotelDataArray = nil;
    }
    if(_myScrollView && _myScrollView.retainCount > 0)
    {
        [_myScrollView removeFromSuperview];
        [_myScrollView release];
        _myScrollView = nil;
    }
    
    self.view = nil;
}

@end
