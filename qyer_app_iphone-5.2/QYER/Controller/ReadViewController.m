//
//  ReadViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-8.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "ReadViewController.h"
#import "FilePath.h"
#import "Toast+UIView.h"
#import "WebViewViewController.h"
#import "ImageBrowserViewController.h"
#import "PoiDetailViewController.h"
#import "QYMapViewController.h"
#import "GetPoiListFromGuide.h"
#import "MobClick.h"
#import "QYGuide.h"
#import "CatalogViewController.h"
#import "BookMark.h"
#import "BookMarkData.h"
#import "GuideHtml.h"
#import "LastMinute.h"
#import "LastMinuteData.h"
#import "LastMinuteRecommendView.h"
#import "QyerSns.h"
#import "CorrectErrorsViewController.h"
#import "ShowGuideCover.h"
#import "ActionListView.h"
#import "ErrorCorrectionViewController.h"
#import "GoogleMapViewController.h"
#import "GuideMenuData.h"
#import "GuideMenu.h"


#define     WebviewNumber                   3
#define     LeftWebViewTag                  1111
#define     MiddleWebViewTag                1112
#define     RightWebViewTag                 1113
#define     TmpWebViewTag                   1114

#define     timeDelay_showLastMinuteView    0


#define     height_headerview                   (ios7 ? (44+20) : 44)
#define     positionY_titlelabel                (ios7 ? (6+20) : 6)
#define     positionY_backbutton                (ios7 ? (6+20) : 6)
#define     positionY_button_catalog            (ios7 ? (2+20) : 2)
#define     positionY_button_ShareAndCorrect    (ios7 ? (2+20) : 2)
#define     positionY_button_map                (ios7 ? (3+20) : 3)
#define     positionY_shareAndCorrectView       (ios7 ? (45+20) : 45)
#define     height_label_bookmarkName           (ios7 ? 30 : 36)



@interface ReadViewController ()

@end




@implementation ReadViewController
@synthesize str_guideName;
@synthesize guide;
@synthesize array_catalog = _array_catalog;
@synthesize selectIndex = _selectIndex;
@synthesize flag_pushFromBookMark;
@synthesize flag_isShowGuideCover;


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
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_scrollView);
    QY_VIEW_RELEASE(_statusBar);
    QY_VIEW_RELEASE(_indicator_left);
    QY_VIEW_RELEASE(_indicator_right);
    QY_VIEW_RELEASE(_label_bookmarkName);
    QY_VIEW_RELEASE(_label_currentPage);
    QY_VIEW_RELEASE(_backgroundView_shareAndCorrectView);
    QY_VIEW_RELEASE(_shareAndCorrectView);
    QY_VIEW_RELEASE(_imageview_masker);
    QY_VIEW_RELEASE(_label_toast_whenFullScreen);
    QY_VIEW_RELEASE(_scrollView);
    
    QY_MUTABLERECEPTACLE_RELEASE(_array_bookMark);
    QY_MUTABLERECEPTACLE_RELEASE(_array_lastMinute);
    if(_array_catalog && _array_catalog.count > 0)
    {
        QY_MUTABLERECEPTACLE_RELEASE(_array_catalog);
    }
    QY_MUTABLERECEPTACLE_RELEASE(_array_guideHtml);
    QY_MUTABLERECEPTACLE_RELEASE(_dic_pageturning);
    QY_MUTABLERECEPTACLE_RELEASE(_poiListInfoArray);
    
    QY_SAFE_RELEASE(_guide);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
        
        
        newFrame = _scrollView.frame;
        newFrame.size.height = [self.view bounds].size.height-20;
        _scrollView.frame = newFrame;
        
        
        UIWebView *webView_r = (UIWebView *)[_scrollView viewWithTag:RightWebViewTag];
        if(webView_r)
        {
            newFrame = webView_r.frame;
            newFrame.size.height = [_scrollView bounds].size.height;
            webView_r.frame = newFrame;
        }
        
        UIWebView *webView_l = (UIWebView *)[_scrollView viewWithTag:LeftWebViewTag];
        if(webView_l)
        {
            newFrame = webView_l.frame;
            newFrame.size.height = [_scrollView bounds].size.height;
            webView_l.frame = newFrame;
        }
        
        UIWebView *webView_m = (UIWebView *)[_scrollView viewWithTag:MiddleWebViewTag];
        if(webView_m)
        {
            newFrame = webView_m.frame;
            newFrame.size.height = [_scrollView bounds].size.height;
            webView_m.frame = newFrame;
        }
        
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        newFrame = _scrollView.frame;
        newFrame.size.height = [self.view bounds].size.height-20;
        _scrollView.frame = newFrame;
        
    }
    
}




#pragma mark -
#pragma mark --- view - Appear & Disappear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"锦囊阅读页"];
    
    
    //状态栏的样式:
    if(_headView.transform.ty == -95)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    else
    {
        if (ios7) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
    }
    
    
    if(self.flag_isShowGuideCover == 1)
    {
        [self showGuideCover];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [MobClick beginLogPageView:@"锦囊阅读页"];
    
    
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"hotdot_phone"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:YES];
    }
    
    
    
    //从目录页返回:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fresh_readVC:) name:@"fresh_readVC" object:nil];
    
    
    
    //如果是从‘guide详情页’pop出来 或 ‘地图页’pop出来 或 ‘查看大图页’pop出来 或 '分享/纠错页面'pop出来 或从webview回来，则不刷新当前页面数据:
    if(_flag_noFreshData == 1)
    {
        _flag_noFreshData = 0;
        return;
    }
    
    
    [self initBookMarkData];
    [self initGuideHtml];
    
    
    if(_isLoadPoiListInfoSuccessed == 0)
    {
        [self performSelector:@selector(getPoilistInfo) withObject:nil afterDelay:0];
    }
//    if(!_array_lastMinute || _array_lastMinute.count == 0)
//    {
//        [self getLastMinuteInfo];
//    }
    
    
    
//    [date release];
//    [dateFormatter release];
//    [str_date release];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.view hideToast];
    [self.view hideToastActivity];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
-(void)fresh_readVC:(NSNotification *)notifation
{
    NSDictionary *userInfo = notifation.userInfo;
    if(userInfo && [userInfo objectForKey:@"row_select"])
    {
        if(self.selectIndex == [[userInfo objectForKey:@"row_select"] intValue])
        {
            return;
        }
        
        
        UIWebView *webView_r = (UIWebView *)[_scrollView viewWithTag:RightWebViewTag];
        if(webView_r)
        {
            [webView_r stopLoading];
            webView_r.delegate = nil;
            [webView_r removeFromSuperview];
            [webView_r release];
        }
        UIWebView *webView_l = (UIWebView *)[_scrollView viewWithTag:LeftWebViewTag];
        if(webView_l)
        {
            [webView_l stopLoading];
            webView_l.delegate = nil;
            [webView_l removeFromSuperview];
            [webView_l release];
        }
        UIWebView *webView_m = (UIWebView *)[_scrollView viewWithTag:MiddleWebViewTag];
        if(webView_m)
        {
            [webView_m stopLoading];
            webView_m.delegate = nil;
            [webView_m removeFromSuperview];
            [webView_m release];
        }
        
        self.selectIndex = [[userInfo objectForKey:@"row_select"] intValue];
        if([userInfo objectForKey:@"guideName"])
        {
            self.str_guideName = [userInfo objectForKey:@"guideName"];
        }
        _scrollView.contentOffset = CGPointMake(self.selectIndex*320, 0);
        [self initStatusBar];
        [self initGuideHtml];
    }
}
-(void)initBookMarkData
{
    if(!_array_bookMark)
    {
        _array_bookMark = [[NSMutableArray alloc] init];
    }
    [_array_bookMark removeAllObjects];
    [_array_bookMark addObjectsFromArray:[[[BookMarkData sharedBookMarkData] getBookmarkList] objectForKey:self.guide.guideName]];
}
-(void)initGuideHtml
{
    if(!_dic_pageturning)
    {
        _dic_pageturning = [[NSMutableDictionary alloc] init];
    }
    [_dic_pageturning removeAllObjects];
    
    if(!_array_guideHtml)
    {
        _array_guideHtml = [[NSMutableArray alloc] init];
    }
    [_array_guideHtml removeAllObjects];
    [GuideHtml getGuideHtmlToArray:_array_guideHtml withGuideName:self.str_guideName];
    
    
    
    if ((!self.array_catalog) || ([self.array_catalog isKindOfClass:[NSNull class]]) || (self.array_catalog && [self.array_catalog isKindOfClass:[NSArray class]] && self.array_catalog.count == 0) || (![_array_guideHtml isKindOfClass:[NSArray class]]) || [_array_guideHtml count] == 0)
    {
        return;
    }
    else if(self.array_catalog.count >= WebviewNumber)
    {
        //*** middle-webview:
        [self initMiddleWebView];
        
        //*** left-webview:
        if(self.selectIndex > 0)
        {
            [self initLeftWebView];
        }
        
        //*** right-webview:
        if(self.selectIndex+1 < _array_guideHtml.count)
        {
            [self initRightWebView];
        }
    }
    else
    {
        //*** middle-webview:
        [self initMiddleWebView];
        
        //*** right-webview:
        if(self.selectIndex == 0)
        {
            [self initRightWebView];
        }
        else //*** left-webview:
        {
            [self initLeftWebView];
        }
    }
    
    NSLog(@" initGuideHtml 结束 ");
}
-(void)initMiddleWebView
{
    NSLog(@" ### initMiddleWebView");
    
    if(_array_guideHtml && _array_guideHtml.count > 0 && _array_guideHtml.count <= self.selectIndex)
    {
        self.selectIndex = 0;
    }
    else if(!_array_guideHtml || _array_guideHtml.count == 0)
    {
        return;
    }
    
    UIWebView *webView_m = [[UIWebView alloc] initWithFrame:CGRectMake(self.selectIndex*320, 0, 320, _scrollView.frame.size.height)];
    [_scrollView addSubview:webView_m];
    webView_m.backgroundColor = [UIColor clearColor];
    webView_m.delegate = self;
    webView_m.scalesPageToFit = YES;
    webView_m.tag = MiddleWebViewTag;
    NSLog(@"_array_guideHtml:%@",_array_guideHtml);
    NSString *filePath = [[FilePath sharedFilePath] getFilePath:[NSString stringWithFormat:@"file/%@_html/%@",self.str_guideName,[_array_guideHtml objectAtIndex:self.selectIndex]]];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView_m loadRequest:request];
}
-(void)initLeftWebView
{
    NSLog(@" ### initLeftWebView");
    
    if(_array_guideHtml.count == 0 || self.selectIndex - 1 < 0)
    {
        return;
    }
    
    UIWebView *webView_l = [[UIWebView alloc] initWithFrame:CGRectMake((self.selectIndex-1)*320, 0, 320, _scrollView.frame.size.height)];
    [_scrollView addSubview:webView_l];
    webView_l.backgroundColor = [UIColor clearColor];
    webView_l.delegate = self;
    webView_l.scalesPageToFit = YES;
    webView_l.tag = LeftWebViewTag;
    NSString *filePath = [[FilePath sharedFilePath] getFilePath:[NSString stringWithFormat:@"file/%@_html/%@",self.str_guideName,[_array_guideHtml objectAtIndex:self.selectIndex-1]]];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView_l loadRequest:request];
}
-(void)initRightWebView
{
    NSLog(@" ### initRightWebView");
    
    if(_array_guideHtml.count <= self.selectIndex+1)
    {
        return;
    }
    
    UIWebView *webView_r = [[UIWebView alloc] initWithFrame:CGRectMake((self.selectIndex+1)*320, 0, 320, _scrollView.frame.size.height)];
    [_scrollView addSubview:webView_r];
    webView_r.backgroundColor = [UIColor clearColor];
    webView_r.delegate = self;
    webView_r.scalesPageToFit = YES;
    webView_r.tag = RightWebViewTag;
    NSString *filePath = [[FilePath sharedFilePath] getFilePath:[NSString stringWithFormat:@"file/%@_html/%@",self.str_guideName,[_array_guideHtml objectAtIndex:self.selectIndex+1]]];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView_r loadRequest:request];
}




#pragma mark -
#pragma mark --- 构建view
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initRootView];
    [self setNavigationBar];
}
-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
    //rootView.image =[UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
    
    
    [self initScrollView];
    [self initStatusBar];
}
-(void)initScrollView
{
    float height = [self.view bounds].size.height-20;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    if(ios7)
    {
        _scrollView.frame = CGRectMake(0, 20, 320, height);
    }
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*[_array_catalog count], height);
    _scrollView.pagingEnabled = YES;  //一次滑动一页
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.directionalLockEnabled = YES;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.contentOffset = CGPointMake(self.selectIndex*320, 0);
    [self.view addSubview:_scrollView];
    
    
    //添加手势:
    UITapGestureRecognizer *tap_hideAndShow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_hideAndShowHeaderView:)];
    tap_hideAndShow.delegate = self;
    [_scrollView addGestureRecognizer:tap_hideAndShow];
    [tap_hideAndShow release];
}
-(void)initStatusBar
{
    //    if(!self.array_catalog || self.array_catalog.count == 0)
    //    {
    //        self.array_catalog = (NSMutableArray *)[GuideMenuData getMenuJsonWithGuideName:self.str_guideName];
    //    }
    if(!self.array_catalog || self.array_catalog.count == 0)
    {
        [self performSelector:@selector(somethingWrongWhenInitCatalog) withObject:nil afterDelay:3];
        return;
    }
    
    
    
    if(!_statusBar)
    {
        _statusBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, height_headerview, 320, 30)];
    }
    _statusBar.backgroundColor = [UIColor clearColor];
    _statusBar.image = [UIImage imageNamed:@"bg_reader_status_bar"];
    [self.view addSubview:_statusBar];
    
    
    
    if(!_label_bookmarkName)
    {
        _label_bookmarkName = [[UILabel alloc] initWithFrame:CGRectMake(95, 0, 130, height_label_bookmarkName)];
    }
    _label_bookmarkName.backgroundColor = [UIColor clearColor];
    _label_bookmarkName.textColor = [UIColor colorWithRed:3/255. green:97/255. blue:89/255. alpha:1];
    _label_bookmarkName.textAlignment = NSTextAlignmentCenter;
    _label_bookmarkName.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:16];
    if(self.selectIndex < _array_catalog.count)
    {
        GuideMenu *menu = [_array_catalog objectAtIndex:self.selectIndex];
        _label_bookmarkName.text = menu.title_menu;
    }
    [_statusBar addSubview:_label_bookmarkName];
    
    
    
    
    
    if(!_label_currentPage)
    {
        _label_currentPage = [[UILabel alloc] initWithFrame:CGRectMake(240, 5, 70, 24)];
        if(ios7)
        {
            _label_currentPage.frame = CGRectMake(240, 3, 70, 24);
        }
    }
    _label_currentPage.backgroundColor = [UIColor clearColor];
    _label_currentPage.textColor = [UIColor grayColor];
    _label_currentPage.textAlignment = NSTextAlignmentRight;
    _label_currentPage.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
    if([_array_catalog count] > self.selectIndex+1)
    {
        _label_currentPage.text = [NSString stringWithFormat:@"%d/%d页",self.selectIndex+1,[_array_catalog count]];
    }
    [_statusBar addSubview:_label_currentPage];
    
    
    if(!_indicator_left)
    {
        _indicator_left = [[UIImageView alloc] initWithFrame:CGRectMake(80, 8, 9, 14)];
    }
    _indicator_left.backgroundColor = [UIColor clearColor];
    _indicator_left.image = [UIImage imageNamed:@"bg_reader_left"];
    [_statusBar addSubview:_indicator_left];
    
    
    if(!_indicator_right)
    {
        _indicator_right = [[UIImageView alloc] initWithFrame:CGRectMake(231, 8, 9, 14)];
    }
    _indicator_right.backgroundColor = [UIColor clearColor];
    _indicator_right.image = [UIImage imageNamed:@"bg_reader_right"];
    [_statusBar addSubview:_indicator_right];
}
-(void)somethingWrongWhenInitCatalog
{
    [self.view hideToast];
    [self.view makeToast:@"文件损坏,请重新下载" duration:3 position:@"center" isShadow:NO];
}

-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    _button_back = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_back.backgroundColor = [UIColor clearColor];
    _button_back.frame = CGRectMake(4, positionY_backbutton, 48, 33);
    [_button_back setBackgroundImage:[UIImage imageNamed:@"btn_reader_book"] forState:UIControlStateNormal];
    [_button_back addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_button_back];
    
    
    _button_catalog = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_catalog.frame = CGRectMake(60, positionY_button_catalog, 40, 40);
    _button_catalog.backgroundColor = [UIColor clearColor];
    [_button_catalog setBackgroundImage:[UIImage imageNamed:@"btn_reader_catalog"] forState:UIControlStateNormal];
    [_button_catalog addTarget:self action:@selector(clickCatalogButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_button_catalog];
    
    
    
    _button_ShareAndCorrect = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_ShareAndCorrect.frame = CGRectMake(275, positionY_button_ShareAndCorrect, 40, 40);
    _button_ShareAndCorrect.backgroundColor = [UIColor clearColor];
    [_button_ShareAndCorrect setBackgroundImage:[UIImage imageNamed:@"btn_reader_share"] forState:UIControlStateNormal];
    [_button_ShareAndCorrect addTarget:self action:@selector(clickShareAndCorrectAndBookmarkButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_button_ShareAndCorrect];
    
}

-(void)initShareAndCorrectAndBookmarkView
{
    BOOL flag = NO;
    if(_array_bookMark && _array_bookMark.count > 0)
    {
        for(BookMark *bookMark in _array_bookMark)
        {
            if([bookMark.str_bookMarkTitle isEqualToString:_label_bookmarkName.text])
            {
                flag = YES;
                break;
            }
        }
    }
    
    if(flag)
    {
        [[ActionListView sharedActionListView] changeBookMarImageViewWithNormalImage:[UIImage imageNamed:@"btn_reader_bookmarkdelete_"] andHighLightImage:[UIImage imageNamed:@"btn_reader_bookmarkdelete_pressed"]];
    }
    else
    {
        [[ActionListView sharedActionListView] changeBookMarImageViewWithNormalImage:[UIImage imageNamed:@"btn_reader_bookmark_"] andHighLightImage:[UIImage imageNamed:@"btn_reader_bookmark_pressed"]];
    }
    
    [[ActionListView sharedActionListView] showActionListViewInGuideReaderView:self.view andDelegate:self];
}



#pragma mark -
#pragma mark --- ActionListView - Delegate
-(void)share
{
    [self performSelector:@selector(removeShareAndCorrectAndBookmarkView) withObject:nil afterDelay:0.1];
    
    
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

-(void)feedBack
{
    ErrorCorrectionViewController *errorCorrectionVC = [[ErrorCorrectionViewController alloc] init];
    errorCorrectionVC.guideName = self.guide.guideName;
    errorCorrectionVC.strPageNumber = [NSString stringWithFormat:@"%d",_selectIndex+1];
    errorCorrectionVC.updateTime = self.guide.guideUpdate_time;
    [self presentViewController:errorCorrectionVC animated:YES completion:nil];
    [errorCorrectionVC release];
    
    _flag_noFreshData = 1;
    [self performSelector:@selector(removeShareAndCorrectAndBookmarkView) withObject:nil afterDelay:0.2];
}


- (void)addBookMark
{
    BOOL flag = 0;
    for(BookMark *bookMark in _array_bookMark)
    {
        if([bookMark.str_bookMarkTitle isEqualToString:_label_bookmarkName.text])
        {
            flag = 1;
            break;
        }
    }
    
    
    if(flag == 1) //如果已经添加了书签则取消添加
    {
        [[ActionListView sharedActionListView] changeBookMarImageViewWithNormalImage:[UIImage imageNamed:@"btn_reader_bookmark_"] andHighLightImage:[UIImage imageNamed:@"btn_reader_bookmark_pressed"]];

        
        BookMark *bookMark = [[BookMark alloc] init];
        bookMark.str_guideName = self.guide.guideName;
        bookMark.str_bookMarkPageNumber = [NSString stringWithFormat:@"%d",self.selectIndex];
        bookMark.str_bookMarkTitle = _label_bookmarkName.text;
        bookMark.str_guideHtmlInfoPath = @"";
        [[BookMarkData sharedBookMarkData] removeBookmark:bookMark];
        [bookMark release];
        
        
        [self.view hideToast];
        [self.view makeToast:@"书签已取消" duration:1 position:@"center" isShadow:NO];
    }
    else
    {
        [[ActionListView sharedActionListView] changeBookMarImageViewWithNormalImage:[UIImage imageNamed:@"btn_reader_bookmarkdelete_"] andHighLightImage:[UIImage imageNamed:@"btn_reader_bookmarkdelete_pressed"]];
        
        BookMark *bookMark = [[BookMark alloc] init];
        bookMark.str_guideName = self.guide.guideName;
        bookMark.str_bookMarkPageNumber = [NSString stringWithFormat:@"%d",self.selectIndex];
        bookMark.str_bookMarkTitle = _label_bookmarkName.text;
        bookMark.str_guideHtmlInfoPath = @"";
        [[BookMarkData sharedBookMarkData] addBookmark:bookMark];
        [bookMark release];
        
        [self.view hideToast];
        [self.view makeToast:@"已添加到书签列表" duration:1 position:@"center" isShadow:NO];
    }
    [self initBookMarkData];
    
    [self performSelector:@selector(removeShareAndCorrectAndBookmarkView) withObject:nil afterDelay:0.3];
}

-(void)removeShareAndCorrectAndBookmarkView
{
    [[ActionListView sharedActionListView] doCancle];
}




#pragma mark -
#pragma mark --- UIScrollView - Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_flag_isShowToast == 0 && scrollView.contentOffset.x < 0)
    {
        _flag_isShowToast = 1;
        [self performSelector:@selector(changeShowToastFlag) withObject:nil afterDelay:1];
        
        [self.view hideToast];
        [self.view makeToast:@"当前已是第一页" duration:1 position:@"center" isShadow:NO];
    }
    if(_flag_isShowToast == 0 && scrollView.contentOffset.x > scrollView.contentSize.width - scrollView.frame.size.width)
    {
        _flag_isShowToast = 1;
        [self performSelector:@selector(changeShowToastFlag) withObject:nil afterDelay:1];
        
        [self.view hideToast];
        [self.view makeToast:@"当前已是最后一页" duration:1 position:@"center" isShadow:NO];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger position = _scrollView.contentOffset.x/320;
    
    if(self.selectIndex - position == 0)
    {
        return;
    }
    
    else if(self.selectIndex - position > 0) //从左往右
    {
        NSLog(@" 从左往右翻页");
        _pageTurning++;
        
        self.selectIndex = position;
        [self pageTurningFromLeftToRight];
    }
    else if(self.selectIndex - position < 0) //从右往左
    {
        NSLog(@" 从右往左翻页");
        _pageTurning++;
        
        self.selectIndex = position;
        [self pageTurningFromRightToLeft];
    }
    
    
    //更新页数和title:
    [self updateLabelBookmarkNameAndLabelCurrentPage];
    
    //显示页数的toast:
    [self show_label_toast_whenFullScreen];
    
    //记录锦囊的阅读页数:
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.selectIndex+1] forKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,self.str_guideName]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}
-(void)pageTurningFromRightToLeft
{
    UIWebView *webView_r = (UIWebView *)[_scrollView viewWithTag:LeftWebViewTag];
    if(webView_r)
    {
        webView_r.tag = TmpWebViewTag;
        webView_r.backgroundColor = [UIColor clearColor];
    }
    
    if (_array_guideHtml.count > self.selectIndex-1) {
        UIWebView *webView_l = (UIWebView *)[_scrollView viewWithTag:MiddleWebViewTag];
        webView_l.backgroundColor = [UIColor clearColor];
        webView_l.frame = CGRectMake((self.selectIndex-1)*320, 0, 320, _scrollView.frame.size.height);
        webView_l.tag = LeftWebViewTag;
        NSString *filePath_l = [[FilePath sharedFilePath] getFilePath:[NSString stringWithFormat:@"file/%@_html/%@",self.str_guideName,[_array_guideHtml objectAtIndex:self.selectIndex-1]]];
        NSURL *url_l = [NSURL fileURLWithPath:filePath_l];
        NSURLRequest *request_l = [NSURLRequest requestWithURL:url_l];
        [webView_l loadRequest:request_l];
    }
    
    if (_array_guideHtml.count > self.selectIndex) {
        UIWebView *webView_m = (UIWebView *)[_scrollView viewWithTag:RightWebViewTag];
        webView_m.backgroundColor = [UIColor clearColor];
        webView_m.frame = CGRectMake(self.selectIndex*320, 0, 320, _scrollView.frame.size.height);
        webView_m.tag = MiddleWebViewTag;
        NSString *filePath_m = [[FilePath sharedFilePath] getFilePath:[NSString stringWithFormat:@"file/%@_html/%@",self.str_guideName,[_array_guideHtml objectAtIndex:self.selectIndex]]];
        NSURL *url_m = [NSURL fileURLWithPath:filePath_m];
        NSURLRequest *request_m = [NSURLRequest requestWithURL:url_m];
        [webView_m loadRequest:request_m];
    }
    
    
    webView_r = (UIWebView *)[_scrollView viewWithTag:TmpWebViewTag];
    if(webView_r)
    {
        if([webView_r isLoading])
        {
            [webView_r stopLoading];
        }
        webView_r.delegate = nil;
        [webView_r removeFromSuperview];
        [webView_r release];
        webView_r = nil;
    }
    if(self.selectIndex+1 < _array_guideHtml.count)
    {
        webView_r = [[UIWebView alloc] initWithFrame:CGRectMake((self.selectIndex+1)*320, 0, 320, _scrollView.frame.size.height)];
        [_scrollView addSubview:webView_r];
        webView_r.delegate = self;
        webView_r.scalesPageToFit = YES;
        webView_r.tag = RightWebViewTag;
        NSString *filePath_r = [[FilePath sharedFilePath] getFilePath:[NSString stringWithFormat:@"file/%@_html/%@",self.str_guideName,[_array_guideHtml objectAtIndex:self.selectIndex+1]]];
        NSURL *url_r = [NSURL fileURLWithPath:filePath_r];
        NSURLRequest *request_r = [NSURLRequest requestWithURL:url_r];
        [webView_r loadRequest:request_r];
    }
}
-(void)pageTurningFromLeftToRight
{
    UIWebView *webView_l = (UIWebView *)[_scrollView viewWithTag:RightWebViewTag];
    if(webView_l)
    {
        webView_l.tag = TmpWebViewTag;
    }
    
    
    UIWebView *webView_r = (UIWebView *)[_scrollView viewWithTag:MiddleWebViewTag];
    webView_r.backgroundColor = [UIColor clearColor];
    webView_r.frame = CGRectMake((self.selectIndex+1)*320, 0, 320, _scrollView.frame.size.height);
    webView_r.tag = RightWebViewTag;
    NSString *filePath_r = [[FilePath sharedFilePath] getFilePath:[NSString stringWithFormat:@"file/%@_html/%@",self.str_guideName,[_array_guideHtml objectAtIndex:self.selectIndex+1]]];
    NSURL *url_r = [NSURL fileURLWithPath:filePath_r];
    NSURLRequest *request_r = [NSURLRequest requestWithURL:url_r];
    [webView_r loadRequest:request_r];
    
    
    
    UIWebView *webView_m = (UIWebView *)[_scrollView viewWithTag:LeftWebViewTag];
    webView_m.backgroundColor = [UIColor clearColor];
    webView_m.frame = CGRectMake(self.selectIndex*320, 0, 320, _scrollView.frame.size.height);
    webView_m.tag = MiddleWebViewTag;
    NSString *filePath_m = [[FilePath sharedFilePath] getFilePath:[NSString stringWithFormat:@"file/%@_html/%@",self.str_guideName,[_array_guideHtml objectAtIndex:self.selectIndex]]];
    NSURL *url_m = [NSURL fileURLWithPath:filePath_m];
    NSURLRequest *request_m = [NSURLRequest requestWithURL:url_m];
    [webView_m loadRequest:request_m];
    
    
    webView_l = (UIWebView *)[_scrollView viewWithTag:TmpWebViewTag];
    if(webView_l)
    {
        if([webView_l isLoading])
        {
            [webView_l stopLoading];
        }
        webView_l.delegate = nil;
        [webView_l removeFromSuperview];
        [webView_l release];
        webView_l = nil;
    }
    
    if(self.selectIndex-1 >= 0)
    {
        webView_l = [[UIWebView alloc] initWithFrame:CGRectMake((self.selectIndex-1)*320, 0, 320, _scrollView.frame.size.height)];
        webView_l.backgroundColor = [UIColor clearColor];
        webView_l.delegate = self;
        webView_l.scalesPageToFit = YES;
        webView_l.tag = LeftWebViewTag;
        NSString *filePath = [[FilePath sharedFilePath] getFilePath:[NSString stringWithFormat:@"file/%@_html/%@",self.str_guideName,[_array_guideHtml objectAtIndex:self.selectIndex-1]]];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView_l loadRequest:request];
        [_scrollView addSubview:webView_l];
    }
}

-(void)updateLabelBookmarkNameAndLabelCurrentPage
{
    if(!self.array_catalog || self.array_catalog.count == 0)
    {
        return;
    }
    
    GuideMenu *menu = [_array_catalog objectAtIndex:self.selectIndex];
    _label_bookmarkName.text = menu.title_menu;
    _label_currentPage.text = [NSString stringWithFormat:@"%d/%d页",[menu.str_pageNumber intValue],[_array_catalog count]];
}

-(void)changeShowToastFlag
{
    _flag_isShowToast = 0;
}



#pragma mark -
#pragma mark --- UIWebView - Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //*** UIWebViewNavigationType 类型:
    //UIWebViewNavigationTypeLinkClicked,
    //UIWebViewNavigationTypeFormSubmitted,
    //UIWebViewNavigationTypeBackForward,
    //UIWebViewNavigationTypeReload,
    //UIWebViewNavigationTypeFormResubmitted,
    //UIWebViewNavigationTypeOther
    
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSString *link_click = [request.URL absoluteString];
        NSArray *array_link_property = [link_click componentsSeparatedByString:@":"];
        //NSLog(@"array_link_property : %@",array_link_property);
        if(array_link_property && array_link_property.count <= 2)
        {
            NSString *type_click = [array_link_property objectAtIndex:0]; //将要加载的数据的类型
            
            if ([type_click isEqualToString:@"tel"]) //呼叫电话
            {
                self.flag_isShowGuideCover = 0;
                
                [[UIApplication sharedApplication] openURL:request.URL];
            }
            else if ([type_click isEqualToString:@"enlarge"]) //对锦囊中的地图进行放大查看
            {
                self.flag_isShowGuideCover = 0;
                
                NSString *filePath = [[FilePath sharedFilePath] getFilePath:[NSString stringWithFormat:@"file/%@_html/",self.str_guideName]];
                NSString *imagePath = [filePath stringByAppendingPathComponent:[array_link_property objectAtIndex:1]];
                if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
                {
                    ImageBrowserViewController *imageBrowserVC = [[ImageBrowserViewController alloc] init];
                    [imageBrowserVC setImagePath:imagePath];
                    [self.navigationController pushViewController:imageBrowserVC animated:YES];
                    [imageBrowserVC release];
                    
                    _flag_noFreshData = 1;
                }
            }
            else if ([type_click isEqualToString:@"http"]) //打开浏览器
            {
                self.flag_isShowGuideCover = 0;
                
                WebViewViewController *webVC_inApp = [[WebViewViewController alloc] init];
                webVC_inApp.flag_plan = 0;
                _flag_noFreshData = 1;
                [webVC_inApp setStartURL:[request.URL absoluteString]];
                [self presentViewController:[QYToolObject getControllerWithBaseController:webVC_inApp] animated:YES completion:nil];
                [webVC_inApp release];
                
                return NO;
            }
            else if ([type_click isEqualToString:@"LocalPoi"]) //锦囊详情页
            {
                if(array_link_property && [array_link_property isKindOfClass:[NSArray class]] && [array_link_property count] > 1)
                {
                    self.flag_isShowGuideCover = 0;
                    
                    NSString *str = [array_link_property objectAtIndex:1];
                    NSRange range = [str rangeOfString:@"local_poi_id="];
                    NSString *poiidstr = [str substringFromIndex:range.location+range.length];
                    PoiDetailViewController *poiDetailVC = [[PoiDetailViewController alloc] init];
                    poiDetailVC.poiId = [poiidstr intValue];
                    [self.navigationController pushViewController:poiDetailVC animated:YES];
                    [poiDetailVC release];
                    
                    _flag_noFreshData = 1;
                }
                else
                {
                    UIAlertView *prompt = [[UIAlertView alloc]
                                           initWithTitle:@"带有地图功能的穷游锦囊最新版本即将推出，敬请期待。"
                                           message:@""
                                           delegate:self
                                           cancelButtonTitle:@"我知道了"
                                           otherButtonTitles:nil, nil];
                    [prompt setTransform:CGAffineTransformMakeTranslation(0, 10)];
                    [prompt show];
                    [prompt release];
                }
            }
            else if([type_click isEqualToString:@"LocalMap"]) //显示所有POI的地图页
            {
                if(array_link_property && [array_link_property isKindOfClass:[NSArray class]] && [array_link_property count] > 1)
                {
                    NSString *str = [array_link_property objectAtIndex:1];
                    NSRange range = [str rangeOfString:@"local_poi_id="];
                    NSString *poiidstr = [str substringFromIndex:range.location+range.length];
                    
                    [self getPoilistInfoAndTurnToMap:[poiidstr intValue]];
                }
                else
                {
                    UIAlertView *prompt = [[UIAlertView alloc]
                                           initWithTitle:@"带有地图功能的穷游锦囊最新版本即将推出，敬请期待。"
                                           message:@""
                                           delegate:self
                                           cancelButtonTitle:@"我知道了"
                                           otherButtonTitles:nil, nil];
                    [prompt setTransform:CGAffineTransformMakeTranslation(0, 10)];
                    [prompt show];
                    [prompt release];
                }
            }
            else
            {
                NSLog(@"  链接点击的类型错误");
                return NO;
            }
        }
    }
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_dic_pageturning removeObjectForKey:[NSString stringWithFormat:@"%d",self.selectIndex]];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_dic_pageturning removeObjectForKey:[NSString stringWithFormat:@"%d",self.selectIndex]];
}



#pragma mark -
#pragma mark --- 显示／隐藏 headerView
- (void)tap_hideAndShowHeaderView:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTouchesRequired == 1)
    {
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            [self performSelector:@selector(showOrHideHeaderAndLMButton) withObject:nil afterDelay:0];
        }
    }
}
-(void)showOrHideHeaderAndLMButton
{
    [UIView animateWithDuration:0.3 animations:^{
        
        if(CGAffineTransformEqualToTransform(_headView.transform, CGAffineTransformIdentity))
        {
            _headView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, -95);
            _statusBar.transform = CGAffineTransformMake(1, 0, 0, 1, 0, -95);
            
            _button_lastMinute.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 90);
            _button_lastMinute_close.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 90);
            
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            
        }
        else
        {
            _headView.transform = CGAffineTransformIdentity;
            _statusBar.transform = CGAffineTransformIdentity;
            
            _button_lastMinute.transform = CGAffineTransformIdentity;
            _button_lastMinute_close.transform = CGAffineTransformIdentity;
            
            if (ios7) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }
            
        }
    }];
}


#pragma mark -
#pragma mark --- UIGestureRecognizer - Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


#pragma mark -
#pragma mark --- getPoilistInfoAndTurnToMap
-(void)getPoilistInfoAndTurnToMap:(NSInteger)poi_id
{
    BOOL exist = 0;
    for(int i = 0; i < [_poiListInfoArray count]; i++)
    {
        GetPoiListFromGuide *poilistInfo = (GetPoiListFromGuide *)[_poiListInfoArray objectAtIndex:i];
        if(poilistInfo.poiId != poi_id)
        {
            continue;
        }
        else
        {
            exist = 1;
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:poilistInfo.chineseName forKey:@"_chineseTitle"];
            [dic setObject:poilistInfo.englishName forKey:@"_englishTitle"];
            [dic setObject:[NSString stringWithFormat:@"%f",poilistInfo.lat] forKey:@"lat"];
            [dic setObject:[NSString stringWithFormat:@"%f",poilistInfo.lng] forKey:@"lng"];
            [dic setObject:[NSString stringWithFormat:@"%d",poilistInfo.cateId] forKey:@"cateid"];
            [dic setObject:[NSString stringWithFormat:@"%d",poilistInfo.poiId] forKey:@"poiId"];
            [self doTurntoMap:dic];
            [dic release];
            
            break;
        }
    }
    if(exist == 0)
    {
        [self.view hideToast];
        [self.view makeToast:@"获取数据失败" duration:1. position:@"center" isShadow:NO];
    }
}
-(void)doTurntoMap:(id)sender
{
    //readClickMap
    [MobClick event:@"readClickMap" label:self.guide.guideName];
    [MobClick event:@"poiMap"];
    
    _flag_noFreshData = 1;
    self.flag_isShowGuideCover = 0;
    
    
    if([sender isKindOfClass:[UIButton class]])
    {
        if(ios5)
        {
            QYMapViewController *qyMapVC = [[QYMapViewController alloc] init];
            [qyMapVC initPinarray:_poiListInfoArray];
            qyMapVC.showPopViewFlag = 0;
            qyMapVC.isFromReadVCAndOnlyOnePoint = 0;
            [self.navigationController pushViewController:qyMapVC animated:YES];
            [qyMapVC setNavigationTitle:_guide.guideName];
            [qyMapVC release];
        }
        else
        {
            GoogleMapViewController *googleMapVC = [[GoogleMapViewController alloc] init];
            googleMapVC.array_in = _poiListInfoArray;
            googleMapVC.title_navigation = self.guide.guideName;
            [self.navigationController pushViewController:googleMapVC animated:YES];
            [googleMapVC release];
        }
    }
    else
    {
        if(ios5)
        {
            QYMapViewController *qyMapVC = [[QYMapViewController alloc] init];
            NSMutableDictionary *dic = (NSMutableDictionary*)sender;
            [qyMapVC initPinarrayWithDic:dic];
            qyMapVC.showPopViewFlag = 0;
            qyMapVC.isFromReadVCAndOnlyOnePoint = 1;
            [self.navigationController pushViewController:qyMapVC animated:YES];
            [qyMapVC setNavigationTitle:[dic objectForKey:@"_chineseTitle"]];
            [qyMapVC setRegion];
            [qyMapVC release];
        }
        else
        {
            NSDictionary *dic = (NSDictionary *)sender;
            GoogleMapViewController *googleMapVC = [[GoogleMapViewController alloc] init];
            googleMapVC.array_in = nil;
            googleMapVC.dic_in = dic;
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
        }
    }
}



#pragma mark -
#pragma mark --- getPoilistInfo
-(void)getPoilistInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[GetPoiListFromGuide sharedGetPoiListFromGuide] getPoiListFromGuideByGuideName:self.guide.guideName finished:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                MYLog(@"获取PoiList信息成功 :)");
                _isLoadPoiListInfoSuccessed = 1;
                if(!_poiListInfoArray)
                {
                    _poiListInfoArray = [[NSMutableArray alloc] init];
                }
                [_poiListInfoArray removeAllObjects];
                [_poiListInfoArray addObjectsFromArray:[[GetPoiListFromGuide sharedGetPoiListFromGuide] poilistArray]];
                
                
                if(_poiListInfoArray && _poiListInfoArray.count > 0)
                {
                    [self addTurntoMapButton];
                }
                
            });
            return 0;
        } failed:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                MYLog(@"获取PoiList信息失败");
                _isLoadPoiListInfoSuccessed = 0;
                
            });
            return -1;
        }];
    });
}
-(void)addTurntoMapButton
{
    [self showMaskLayer];
    
    _button_map = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_map.frame = CGRectMake(230, positionY_button_map, 40, 40);
    _button_map.backgroundColor = [UIColor clearColor];
    NSString *str =[NSString stringWithFormat:@"%@@2x",@"地图button_icon"];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:str ofType:@"png"]];
    [_button_map setBackgroundImage:image forState:UIControlStateNormal];
    [_button_map setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [_headView addSubview:_button_map];
    [_button_map addTarget:self action:@selector(doTurntoMap:) forControlEvents:UIControlEventTouchUpInside];
}



#pragma mark -
#pragma mark --- click - Button
-(void)clickBackButton:(id)sender
{
    _flag_isShowToast = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeShowToastFlag) object:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",self.selectIndex] forKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,self.guide.guideName]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    if(self.flag_firstLoad)
    {
        UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 3];
        [self.navigationController popToViewController:viewController animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)clickCatalogButton:(id)sender
{
    [MobClick event:@"readClickCatelog"];
    
    _flag_noFreshData = 1;
    self.flag_isShowGuideCover = 0;
    
    CatalogViewController *catalogVC = [[CatalogViewController alloc] init];
    catalogVC.flag_fromReadVC = 1;
    catalogVC.str_guideName = self.str_guideName;
    catalogVC.position = self.selectIndex;
    catalogVC.guide = self.guide;
    [self.navigationController pushViewController:catalogVC animated:YES];
    [catalogVC release];
}
-(void)clickShareAndCorrectAndBookmarkButton:(id)sender  //分享 & 纠错 & 书签
{
    [self initShareAndCorrectAndBookmarkView];
}
-(void)initActionSheetView
{
    BOOL flag = [[QyerSns sharedQyerSns] getIsWeixinInstalled];
    NSString *versonStr = [[QyerSns sharedQyerSns] getWeixinVerson];
    BOOL SMSFlag = [[QyerSns sharedQyerSns] isCanSendSMS];
    
    if (SMSFlag)
    {
        if(flag == 1 && iPhone5)
        {
            MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",@"短信", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo", @"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_mail",@"btn_actionsheet_message",@"btn_actionsheet_tengxun", nil]];
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



#pragma mark -
#pragma mark --- MYActionSheet - Delegate
-(void)cancelButtonDidClick:(MYActionSheet *)actionSheet
{
    
}
-(void)actionSheetButtonDidClickWithType:(NSString*)type
{
    if([type isEqualToString:@"邮件"])
    {
        //[MobClick event:@"setting" label:@"邮件分享"];
        [self shareToMail];
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



#pragma mark -
#pragma mark --- 分享
-(void)shareToMail
{
    _flag_noFreshData = 1;
    
    //    NSString *htmlPath = [FilePath getGuideHtmlPathByGuideName:self.guide.guideName];
    //    NSString *shareImgPath = [htmlPath stringByAppendingPathComponent:@"coverbg.jpg"];
    //    UIImage *sharePic = [UIImage imageWithContentsOfFile:shareImgPath];
    //    if(sharePic == nil)
    //    {
    //        sharePic = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default@2x" ofType:@"png"]];
    //    }
    
    [[QyerSns sharedQyerSns] shareToMailWithMailTitle:[NSString stringWithFormat:@"Hi~我在穷游网的#穷游APP#里下载了【%@】锦囊",self.guide.guideName] andMailInfo:[NSString stringWithFormat:@"\tHi~\n\t我在穷游网的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！加上穷游APP里其它的功能和内容，森森赶脚出境游有这么一个APP就够了。好东西要分享，快去下一个吧！\n\n\tp.s.目前穷游APP有iPhone、Android和iPad版本，扫描二维码即可轻松下载\n\n\thttp://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang",self.guide.guideName] andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)sendmessage
{
    _flag_noFreshData = 1;
    
    [[QyerSns sharedQyerSns] shareWithShortMessage:[NSString stringWithFormat:@"我在穷游网的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！出境游还是要用穷游APP，你也下一个备着吧！http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang", self.guide.guideName] inViewController:self];
}

-(void)shareToWeixinFriend
{
    _flag_noFreshData = 1;
    
    [[QyerSns sharedQyerSns] shareToWeixinWithAPPTitle:@"穷游APP" andDescription:[NSString stringWithFormat:@"我在穷游网的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！出境游还是要用穷游APP，你也下一个备着吧！", self.guide.guideName]  andImage:[UIImage imageNamed:@"120icon"] andUrl:@"http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang"];
    
}
-(void)shareToWeixinFriendCircle
{
    _flag_noFreshData = 1;
  
     [[QyerSns sharedQyerSns] shareToWeixinFriendCircleWithAPPTitle:[NSString stringWithFormat:@"我在穷游网的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！出境游还是要用穷游APP，你也下一个备着吧", self.guide.guideName] andDescription:@"" andImage:[UIImage imageNamed:@"120icon"] andUrl:@" http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang"];
    
}
-(void)shareToSinaWeibo
{
    _flag_noFreshData = 1;
    
    [[QyerSns sharedQyerSns] shareToSinaWeiboWithTitle:@"分享到新浪微博" andText:[NSString stringWithFormat:@"我在@穷游网 的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！出境游还是要用穷游APP，你也下一个备着吧！http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang", self.guide.guideName] andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)shareToTencentWeibo
{
    _flag_noFreshData = 1;
    
    [[QyerSns sharedQyerSns] shareToTencentWeiboWithText:[NSString stringWithFormat:@"我在@穷游网 的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！出境游还是要用穷游APP，你也下一个备着吧！http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang", self.guide.guideName] andImage:[UIImage imageNamed:@"iphone_sina_sns"] andDelegate:self];
}


#pragma mark -
#pragma mark --- getLastMinuteInfo
-(void)getLastMinuteInfo
{
    [LastMinuteData getLastMinuteInfoWithGuideId:[NSString stringWithFormat:@"%@",self.guide.guideId]
                                         success:^(NSArray *array){
                                             NSLog(@" getLastMinuteInfo 成功 ");
                                             
                                             if(!_array_lastMinute)
                                             {
                                                 _array_lastMinute = [[NSMutableArray alloc] init];
                                             }
                                             [_array_lastMinute removeAllObjects];
                                             [_array_lastMinute addObjectsFromArray:array];
                                             
                                             
                                             if(_array_lastMinute.count > 0)
                                             {
                                                 [self initButton_lastminute];
                                             }
                                         }
                                          failed:^{
                                              NSLog(@" getLastMinuteInfo 失败 ");
                                          }];
}
-(void)initButton_lastminute
{
    _button_lastMinute = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _button_lastMinute.frame = CGRectMake(8, self.view.frame.size.height-74/2.-8, 530/2., 74/2.);
    [_button_lastMinute setBackgroundImage:[UIImage imageNamed:@"折扣提醒_左.png"] forState:UIControlStateNormal];
    [_button_lastMinute setTitle:[NSString stringWithFormat:@"      发现%@有%d条超值折扣",self.guide.guideCountry_name_cn,_array_lastMinute.count] forState:UIControlStateNormal];
    [_button_lastMinute.titleLabel setFont:[UIFont systemFontOfSize:15.]];
    _button_lastMinute.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_button_lastMinute addTarget:self action:@selector(showLastMinutInfo) forControlEvents:UIControlEventTouchUpInside];
    _button_lastMinute.alpha = 0;
    [self.view addSubview:_button_lastMinute];
    
    _button_lastMinute_close = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_button_lastMinute_close setBackgroundImage:[UIImage imageNamed:@"折扣提醒_x.png"] forState:UIControlStateNormal];
    _button_lastMinute_close.frame = CGRectMake(_button_lastMinute.frame.origin.x+_button_lastMinute.frame.size.width, _button_lastMinute.frame.origin.y, 80/2., 74/2.);
    [_button_lastMinute_close addTarget:self action:@selector(closeLastMinuteToast) forControlEvents:UIControlEventTouchUpInside];
    _button_lastMinute_close.alpha = 0;
    [self.view addSubview:_button_lastMinute_close];
    
    
    [self performSelector:@selector(showLastMinutButton) withObject:nil afterDelay:timeDelay_showLastMinuteView];
    
    
    if(_imageview_masker)
    {
        [self.view bringSubviewToFront:_imageview_masker];
    }
}
-(void)showLastMinutButton
{
    [UIView animateWithDuration:0.3 animations:^{
        _button_lastMinute.alpha = 1;
        _button_lastMinute_close.alpha = 1;
    } completion:^(BOOL finished){
    }];
}
-(void)showLastMinutInfo
{
    [MobClick event:@"readClickDiscount"];
    
    LastMinuteRecommendView *lastMinuteView = [[LastMinuteRecommendView alloc] init];
    lastMinuteView.delegate = self;
    [lastMinuteView showWithArray:_array_lastMinute andTitle:self.guide.guideCountry_name_cn inView:self.view];
    [lastMinuteView release];
}
-(void)closeLastMinuteToast
{
    [UIView animateWithDuration:0.2 animations:^{
        _button_lastMinute.alpha = 0;
        _button_lastMinute_close.alpha = 0;
    } completion:^(BOOL finished){
        [_button_lastMinute removeFromSuperview];
        [_button_lastMinute_close removeFromSuperview];
    }];
}




#pragma mark -
#pragma mark --- LastMinuteRecommendView - Delegate
-(void)LastMinuteCellSelectedPosition:(NSInteger)position
{
    WebViewViewController *webVC_lastMinute = [[WebViewViewController alloc] init];
    webVC_lastMinute.flag_plan = 0;
    _flag_noFreshData = 1;
    webVC_lastMinute.title = [[_array_lastMinute objectAtIndex:position] str_title];
    [webVC_lastMinute setStartURL:[[_array_lastMinute objectAtIndex:position] str_web_url]];
    NSLog(@" webVC_lastMinute.title : %@",webVC_lastMinute.title);
    NSLog(@" str_web_url : %@",[[_array_lastMinute objectAtIndex:position] str_web_url]);
    [self presentViewController:[QYToolObject getControllerWithBaseController:webVC_lastMinute] animated:YES completion:nil];
    [webVC_lastMinute release];
}
-(void)LastMinuteViewDidHide
{
    _flag_noFreshData = 0;
}



#pragma mark -
#pragma mark --- showGuideCover
-(void)showGuideCover
{
    [ShowGuideCover showGuideCoverWithGuideName:self.guide.guideName];
}



#pragma mark -
#pragma mark --- 首次打开时添加遮罩层
-(void)showMaskLayer
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [NSString stringWithFormat:@"%@",[infoDictionary objectForKey:@"CFBundleVersion"]];
    appVersion = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    NSString *key = [NSString stringWithFormat:@"readguide_V%@",appVersion];
    if(![[NSUserDefaults standardUserDefaults] objectForKey:key]) //*** 首次阅读
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        float height = 480;
        if(iPhone5)
        {
            height = 568;
        }
        if(!_imageview_masker)
        {
            if(ios7)
            {
                _imageview_masker = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
            }
            else
            {
                _imageview_masker = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, 320, height)];
            }
        }
        _imageview_masker.userInteractionEnabled = YES;
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"阅读页面_提示960@2x" ofType:@"png"]];
        _imageview_masker.image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:420];
        [self.view addSubview:_imageview_masker];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_masker:)];
        [_imageview_masker addGestureRecognizer:tap];
        [tap release];
        
    }
}
-(void)tap_masker:(UITapGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.3 animations:^{
            _imageview_masker.alpha = 0;
        } completion:^(BOOL finished) {
            [_imageview_masker removeFromSuperview];
        }];
    }
}



#pragma mark -
#pragma mark --- show_toast_whenFullScreen  &  hide_toast_whenFullScreen
-(void)show_label_toast_whenFullScreen
{
    if(_headView.frame.origin.y >= 0)
    {
        return;
    }
    
    if(!_label_toast_whenFullScreen)
    {
        _label_toast_whenFullScreen = [[UILabel alloc] initWithFrame:CGRectMake(320-50-13, self.view.bounds.size.height-26-13, 50, 26)];
        _label_toast_whenFullScreen.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [_label_toast_whenFullScreen.layer setCornerRadius:3.];
        _label_toast_whenFullScreen.adjustsFontSizeToFitWidth = YES;
        _label_toast_whenFullScreen.font = [UIFont systemFontOfSize:13.];
        _label_toast_whenFullScreen.textColor = [UIColor whiteColor];
        _label_toast_whenFullScreen.textAlignment = NSTextAlignmentCenter;
        _label_toast_whenFullScreen.alpha = 0;
    }
    _label_toast_whenFullScreen.text = [NSString stringWithFormat:@"%d / %d",self.selectIndex+1,[_array_catalog count]];
    [self.view addSubview:_label_toast_whenFullScreen];
    
    
    if(_label_toast_whenFullScreen.alpha == 1)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide_label_toast_whenFullScreen) object:nil];
        
        [self performSelector:@selector(hide_label_toast_whenFullScreen) withObject:nil afterDelay:1];
    }
    else
    {
        [UIView animateWithDuration:0.1 animations:^{
            _label_toast_whenFullScreen.alpha = 1;
        } completion:^(BOOL finished){
            [self performSelector:@selector(hide_label_toast_whenFullScreen) withObject:nil afterDelay:1];
        }];
    }
}
-(void)hide_label_toast_whenFullScreen
{
    [UIView animateWithDuration:0.1 animations:^{
        _label_toast_whenFullScreen.alpha = 0;
    } completion:^(BOOL finished){
        [_label_toast_whenFullScreen removeFromSuperview];
    }];
}



#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
