//
//  WebViewViewController.m
//  iPhoneJinNang
//
//  Created by 安庆 on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WebViewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "MyControl.h"
#import "Toast+UIView.h"
#import "GetPoiListFromGuide.h"
#import "QYMapViewController.h"
#import "MobClick.h"
#import "QYGuideData.h"
#import "Reachability.h"
#import "PlanFreshDate.h"
#import "FilePath.h"
#import "NSString+SBJSON.h"
#import "NSObject+SBJson.h"
#import "QyerSns.h"

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





#define  webViewTag     12306

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





@interface WebViewViewController ()

@end




@implementation WebViewViewController
@synthesize startURL = _startURL;
@synthesize planName = _planName;
@synthesize title_navigationBar;
@synthesize fromPushFlag;
@synthesize flag_plan;
@synthesize plan_id;
@synthesize flag_natavie;
@synthesize label_title = _label_title;
@synthesize flag_remote;
@synthesize updateTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"  dealloc --- WebViewViewController");
    
    
    self.planName = nil;
    
    QY_VIEW_RELEASE(_label_title);
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_closeButton);
    QY_VIEW_RELEASE(_footView);
    QY_VIEW_RELEASE(_backButton);
    QY_VIEW_RELEASE(_nextButton);
    QY_VIEW_RELEASE(_refreshButton);
    QY_VIEW_RELEASE(_safariButton);
    
    QY_SAFE_RELEASE(_startURL);
    urlCache_qy.delegate = nil;
    [urlCache_qy release];
    urlCache_qy = nil;
    self.updateTime = nil;
    
    
    //因程序返回造成卡死现象，故改之。
    //    NSLog(@" urlCache_qy.retainCount : %d",urlCache_qy.retainCount);
    //    for(;;)
    //    {
    //        if(urlCache_qy.retainCount >= 1)
    //        {
    //            urlCache_qy.delegate = nil;
    //            [urlCache_qy release];
    //            break;
    //        }
    //    }
    
    
    _webView.delegate = nil;
    [_webView removeFromSuperview];
    [_webView release];
    
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- WillAppear / Disappear
- (void)viewWillAppear:(BOOL)animated
{
    if ([_label_title.text isEqualToString:@""] || _label_title.text == nil) {
        
        NSString *strTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        if (!strTitle) {
            strTitle = @"穷游";
        }
        _label_title.text = strTitle;
    }

    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
   
    [MobClick beginLogPageView:@"内置浏览器"];
    
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MobClick endLogPageView:@"内置浏览器"];
    
   // [_webView stopLoading];
   // _webView.delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}




#pragma mark -
#pragma mark --- 构建View
- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
      
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    
    UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //imageView_background.image = [UIImage imageNamed:@"qyer_background"];
    imageView_background.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
    self.view = imageView_background;
    self.view.userInteractionEnabled = YES;
    [imageView_background release];
    
    
    
    if(ios7)
    {
        _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44+20)];
    }
    else
    {
        _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    }
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    _label_title = [[UILabel alloc] initWithFrame:CGRectMake(50, 12, 220, 30)];
    if(ios7)
    {
        _label_title.frame = CGRectMake(50, 6+20, 220, 30);
    }
    _label_title.backgroundColor = [UIColor clearColor];
    _label_title.textColor = [UIColor whiteColor];
    _label_title.textAlignment = NSTextAlignmentCenter;
    _label_title.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:19];
    [_headView addSubview:_label_title];
    
    if(self.flag_natavie == 1)  //native push出来的页面
    {
        _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _closeButton.frame = CGRectMake(0, 2, 40, 40);
        if(ios7)
        {
            _closeButton.frame = CGRectMake(0, 2+20, 40, 40);
        }
        _closeButton.backgroundColor = [UIColor clearColor];
        [_closeButton setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:_closeButton];
        
        
        
        
        
        
        
        if(self.flag_plan) //行程
        {
            _label_title.text = self.planName;
            
            UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
            moreButton.frame = CGRectMake(280, 2, 40, 40);
            if(ios7)
            {
                moreButton.frame = CGRectMake(280, 2+20, 40, 40);
            }
            moreButton.backgroundColor = [UIColor clearColor];
            [moreButton setBackgroundImage:[UIImage imageNamed:@"btn_reader_share"] forState:UIControlStateNormal];
            [moreButton addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
            [_headView addSubview:moreButton];
            
        }
        
        //        _refreshButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        //        _refreshButton.frame = CGRectMake(280, 2, 40, 40);
        //        if(ios7)
        //        {
        //            _refreshButton.frame = CGRectMake(280, 2+20, 40, 40);
        //        }
        //        _refreshButton.backgroundColor = [UIColor clearColor];
        //        [_refreshButton setImage:[UIImage imageNamed:@"navigation_refresh"] forState:UIControlStateNormal];
        //        [_refreshButton addTarget:self action:@selector(clickRefreshButton:) forControlEvents:UIControlEventTouchUpInside];
        //        [_headView addSubview:_refreshButton];
        
        
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height-(44+20))];
        _webView.tag = webViewTag;
        if(ios7)
        {
            _webView.frame = CGRectMake(0, 44+20, 320, self.view.frame.size.height-(44+20));
        }
        _webView.backgroundColor = [UIColor clearColor];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        [self.view addSubview:_webView];
        
    }
    else
    {
        _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _closeButton.frame = CGRectMake(0, 2, 40, 40);
        if(ios7)
        {
            _closeButton.frame = CGRectMake(0, 2+20, 40, 40);
        }
        _closeButton.backgroundColor = [UIColor clearColor];
        [_closeButton setImage:[UIImage imageNamed:@"btn_webview_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:_closeButton];
        
        
        
        _footView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, 320, 44)];
        if(!ios7)
        {
            _footView.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - (44+20), 320, 44);
        }
        _footView.backgroundColor = [UIColor redColor];
        _footView.image = [UIImage imageNamed:@"bg_webview_foot"];
        _footView.userInteractionEnabled = YES;
        [self.view addSubview:_footView];
        
        
        _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _backButton.frame = CGRectMake(20, 2, 40, 40);
        _backButton.backgroundColor = [UIColor clearColor];
        [_backButton setImage:[UIImage imageNamed:@"btn_webview_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        _backButton.enabled = NO;
        [_footView addSubview:_backButton];
        
        _nextButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _nextButton.frame = CGRectMake(100, 2, 40, 40);
        _nextButton.backgroundColor = [UIColor clearColor];
        [_nextButton setImage:[UIImage imageNamed:@"btn_webview_next"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(clickNextButton:) forControlEvents:UIControlEventTouchUpInside];
        [_footView addSubview:_nextButton];
        _nextButton.enabled = NO;
        
        _refreshButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _refreshButton.frame = CGRectMake(180, 2, 40, 40);
        _refreshButton.backgroundColor = [UIColor clearColor];
        [_refreshButton setImage:[UIImage imageNamed:@"btn_webview_refresh"] forState:UIControlStateNormal];
        [_refreshButton addTarget:self action:@selector(clickRefreshButton:) forControlEvents:UIControlEventTouchUpInside];
        [_footView addSubview:_refreshButton];
        
        _safariButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _safariButton.frame = CGRectMake(260, 2, 40, 40);
        _safariButton.backgroundColor = [UIColor clearColor];
        [_safariButton setImage:[UIImage imageNamed:@"btn_webview_safari"] forState:UIControlStateNormal];
        [_safariButton addTarget:self action:@selector(clickSafariButton:) forControlEvents:UIControlEventTouchUpInside];
        [_footView addSubview:_safariButton];
        
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height-20-44-44)];
        _webView.tag = webViewTag;
        if(ios7)
        {
            _webView.frame = CGRectMake(0, 44+20, 320, self.view.frame.size.height - (44+20)-44);
        }
        _webView.backgroundColor = [UIColor clearColor];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        [self.view addSubview:_webView];
    }
    
    
    /**
     *  下面这段代码，是在viewwillappear里面的。
     */
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"updatecache_webview"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [NSURLCache setSharedURLCache:nil];
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"updatecache_webview"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSLog(@" _startURL  : %@",_startURL);
    NSLog(@" _planName  : %@",_planName);
    
    
    if(self.flag_plan == 1)
    {
        NSString *pathName = [NSString stringWithFormat:@"webviewCache/plan/%@",_planName];
        [[FilePath sharedFilePath] createFilePath:pathName];
        NSString *path = [[FilePath sharedFilePath] getFilePath:pathName];
        if(!urlCache_qy)
        {
            urlCache_qy = [[QYURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:path];
        }
        urlCache_qy.delegate = self;
        [NSURLCache setSharedURLCache:urlCache_qy];
        NSLog(@" urlCache_qy.retainCount--- : %d",urlCache_qy.retainCount);
        
        
        //06.25修改:
        if(self.updateTime && (![[NSUserDefaults standardUserDefaults] objectForKey:self.startURL] || ![[[NSUserDefaults standardUserDefaults] objectForKey:self.startURL] isEqualToString:self.updateTime]))
        {
            urlCache_qy.donotgetdatafromserver = NO;
        }
        else
        {
            urlCache_qy.donotgetdatafromserver = YES;
        }
    }
    
    if(_webView)
    {
        //[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_startURL]]];
        
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_startURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10]];
    }
}


#pragma mark -
#pragma mark --- Close / Back / Next / fresh / turnto Safari
- (void)clickCloseButton:(id)sender
{
    if(self.flag_natavie == YES)
    {
        //[self.navigationController popToRootViewControllerAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        //        [self dismissModalViewControllerAnimated:YES];
    }
    
    if(pushClass)
    {
        [self performSelector:@selector(releasePushClass) withObject:nil afterDelay:1];
    }
}
- (void)clickBackButton:(id)sende
{
    if([_webView canGoBack])
    {
        [_webView goBack];
    }
}
- (void)clickNextButton:(id)sender
{
    if([_webView canGoForward])
    {
        [_webView goForward];
    }
}
- (void)clickRefreshButton:(id)sender
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        return;
    }
    
    
    [_webView reload];
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


#pragma mark -
#pragma mark --- UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [alertView cancelButtonIndex])
    {
        return;
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_startURL]];
    }
}



#pragma mark -
#pragma mark --- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _webView;
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
-(void)pushWebViewWithUrl:(NSString*)_url withTitle:(NSString*)_strTitle{
    
    _url = [_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([_strTitle isEqualToString:@"精华游记"]) {
        [MobClick event:@"recClickJournal"];
        BBSDetailViewController * bbsDetailVC = [[BBSDetailViewController alloc]init];
        bbsDetailVC.bbsAllUserLink = _url;
        //        bbsDetailVC.bbsAuthorLink = travalll.str_travelUrl_onlyauthor;
        [self.navigationController pushViewController:bbsDetailVC animated:YES];
        [bbsDetailVC release];
    }
    
    else{
        [MobClick event:@"recClickDest"];
        loadCDWebViewShellViewController* cdMianWeb=[[loadCDWebViewShellViewController alloc] initWithTitle:_strTitle];
        cdMianWeb._redicteUrl=[NSURL URLWithString:_url];
        cdMianWeb._titleLabel.text=_strTitle;
        [self.navigationController pushViewController:cdMianWeb animated:YES];
        [cdMianWeb release];
    }
}
#pragma mark -
#pragma mark --- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *url = [[request URL] absoluteString];
    NSLog(@"url is %@",url);
    
    if ([url isEqualToString:self.startURL]) {
        return YES;
    }
    
    NSArray* _array = [self spliteRedictUrl:url withSeparated:URL_REDIRECT_STRING];
    if (_array.count>1) {
        
        if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_COUNTRY]) {
            
            CountryViewController *countryVc = [[CountryViewController alloc]init];
            countryVc.type =1;
            countryVc.key = [_array objectAtIndex:2];
            [self.navigationController pushViewController:countryVc animated:YES];
            [countryVc release];
            
            return NO;
            
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_CITY]){
            
            CountryViewController *countryVc = [[CountryViewController alloc]init];
            countryVc.type = 2;
            countryVc.key = [_array objectAtIndex:2];
            [self.navigationController pushViewController:countryVc animated:YES];
            [countryVc release];
            
            return NO;
            
            
        }else if ([[_array objectAtIndex:0] isEqualToString:URL_REDIRECT_GUIDE]){
            
            GuideDetailViewController *guideDetailVC = [[GuideDetailViewController alloc] init];
            
            guideDetailVC.guideId = [_array objectAtIndex:1];
            guideDetailVC.flag_new = YES;
            [guideDetailVC setGuide:[QYGuideData getGuideById:[_array objectAtIndex:1]]];
            [self.navigationController pushViewController:guideDetailVC animated:YES];
            [guideDetailVC release];
            
            return NO;
            
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_POI]){
            
            PoiDetailViewController *poiDetailVC = [[PoiDetailViewController alloc] init];
            poiDetailVC.poiId = [[_array objectAtIndex:2] integerValue];
            [self.navigationController pushViewController:poiDetailVC animated:YES];
            [poiDetailVC release];
            
            return NO;
            
        }else if ([[_array objectAtIndex:0] isEqualToString:URL_REDIRECT_BBS]){
            
            [self pushWebViewWithUrl:url withTitle:[self getTitleStringWithUrl:url]];
            return NO;
            
            
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_TRIP]){
            
            [self pushWebViewWithUrl:url withTitle:[self getTitleStringWithUrl:url]];
            return NO;
            
            
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_QUESTION]){
            
            [self pushWebViewWithUrl:url withTitle:[self getTitleStringWithUrl:url]];
            return NO;
            
            
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_LASTMINUTE]){
            
            [MobClick event:@"recClickDisc"];
//            LastMinuteDetailViewController * lastDetailVC = [[LastMinuteDetailViewController alloc]init];
//            lastDetailVC.dealID = [[_array objectAtIndex:2] integerValue];
//            [self.navigationController pushViewController:lastDetailVC animated:YES];
//            [lastDetailVC release];
            
            //by jessica
            LastMinuteDetailViewControllerNew * lastDetailVC = [[LastMinuteDetailViewControllerNew alloc]init];
            lastDetailVC.lastMinuteId = [[_array objectAtIndex:2] integerValue];
            lastDetailVC.source = NSStringFromClass([self class]);
            [self.navigationController pushViewController:lastDetailVC animated:YES];
            [lastDetailVC release];
            
            return NO;
            
            
        }
    }
    
    NSRange foundObj=[url rangeOfString:URL_REDIRECT_PLACE options:NSCaseInsensitiveSearch];
    if (foundObj.length>0) {
        [self pushWebViewWithUrl:url withTitle:@"目的地推荐"];
        return NO;
        
    }
    
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if(!([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable))
    {
        [self.view makeToastActivity];
    }
    
    if([_webView canGoBack])
    {
        _backButton.enabled = YES;
    }
    else
    {
        _backButton.enabled = NO;
    }
    
    if([_webView canGoForward])
    {
        _nextButton.enabled = YES;
    }
    else
    {
        _nextButton.enabled = NO;
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.view hideToastActivity];
    
    
    if(_imageView_failed)
    {
        [_imageView_failed removeFromSuperview];
        _imageView_failed.hidden = YES;
    }
    
    
    if([_webView canGoBack])
    {
        _backButton.enabled = YES;
    }
    else
    {
        _backButton.enabled = NO;
    }
    
    if([_webView canGoForward])
    {
        _nextButton.enabled = YES;
    }
    else
    {
        _nextButton.enabled = NO;
    }
    
    
    NSLog(@"   webViewDidFinishLoad :");
    if(self.flag_plan == 1)
    {
        [urlCache_qy processCacheData];
        
        if(self.updateTime)
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.updateTime forKey:self.startURL];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    // 禁用用户选择
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用长按弹出框
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    //推送相关:(04/09)
    if(flag_remote)
    {
        NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        NSLog(@" title : %@",title);
        self.label_title.text = title;
    }
    
    static BOOL isFromJavaScript = NO;
    
    if (isFromJavaScript == YES) {
        
        NSString *strTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        if (!strTitle) {
            strTitle = @"穷游";
        }
        _label_title.text = strTitle;
        
    }else{
        
        if ([_label_title.text isEqualToString:@""] || _label_title.text == nil) {
            
            NSString *strTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            if (!strTitle) {
                strTitle = @"穷游";
            }
            _label_title.text = strTitle;
            
            isFromJavaScript = YES;
        }
    }
   
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.view hideToastActivity];
    
    
    
    //我的行程:
    if(self.flag_plan)
    {
//        [self initFailedView];
    }
    
    
    
    if([_webView canGoBack])
    {
        _backButton.enabled = YES;
    }
    else
    {
        _backButton.enabled = NO;
    }
    
    if([_webView canGoForward])
    {
        _nextButton.enabled = YES;
    }
    else
    {
        _nextButton.enabled = NO;
    }
}



#pragma mark -
#pragma mark --- 无网络是的错误提示
-(void)initFailedView
{
    [self.view hideToastActivity];
    
    if(!_imageView_failed)
    {
        float positionY = (ios7 ? 260/2 : 230/2);
        
        _imageView_failed = [[UIControl alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 640/2, [[UIScreen mainScreen] bounds].size.height - _headView.frame.size.height)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, positionY, 640/2, 360/2)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"notReachable"];
        [_imageView_failed addSubview:imageView];
        [imageView release];
    }
    _imageView_failed.backgroundColor = [UIColor clearColor];
    _imageView_failed.hidden = NO;
    [_imageView_failed addTarget:self action:@selector(reloadPlanInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_imageView_failed];
}
-(void)reloadPlanInfo
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        return;
    }
    
    
    if(_webView)
    {
        [_webView stopLoading];
        _webView.delegate = nil;
        [_webView removeFromSuperview];
        if(_webView.retainCount > 0)
        {
            [_webView release];
        }
    }
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height-(44+20))];
    _webView.tag = webViewTag;
    if(ios7)
    {
        _webView.frame = CGRectMake(0, 44+20, 320, self.view.frame.size.height-(44+20));
    }
    _webView.backgroundColor = [UIColor clearColor];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];
    
    if(urlCache_qy)
    {
        [urlCache_qy release];
    }
    NSString *pathName = [NSString stringWithFormat:@"webviewCache/plan/%@",_planName];
    [[FilePath sharedFilePath] createFilePath:pathName];
    NSString *path = [[FilePath sharedFilePath] getFilePath:pathName];
    urlCache_qy = [[QYURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:path];
    urlCache_qy.delegate = self;
    [NSURLCache setSharedURLCache:urlCache_qy];
    
    
    
    //06.25修改:
    if(self.updateTime && (![[NSUserDefaults standardUserDefaults] objectForKey:self.startURL] || ![[[NSUserDefaults standardUserDefaults] objectForKey:self.startURL] isEqualToString:self.updateTime]))
    {
        urlCache_qy.donotgetdatafromserver = NO;
    }
    else
    {
        urlCache_qy.donotgetdatafromserver = YES;
    }
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_startURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10]];
    
}




#pragma mark -
#pragma mark --- getRemoteNotificationClass
-(void)getRemoteNotificationClass:(GetRemoteNotificationData *)class
{
    pushClass = class;
}
-(void)releasePushClass
{
    [pushClass release];
}



#pragma mark -
#pragma mark --- countHeightWithString
-(float)countHeightWithString:(NSString*)content andHeight:(float)height andTypeSize:(float)size
{
    CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:@"HiraKakuProN-W3" size:size] constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)];
    
    return sizeToFit.width;
}



#pragma mark -
#pragma mark --- QYURLCache - Delegate
-(void)reloadWebViewData
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        return;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_webView reload];
    });
}




#pragma mark -
#pragma mark --- clickMoreButton
-(void)clickMoreButton:(id)sender
{
    [[ActionListView sharedActionListView] showActionListViewInMyPlanView:self.view andDelegate:self];
}



#pragma mark -
#pragma mark --- ActionListView - Delegate
-(void)share
{
    [self performSelector:@selector(removeMoreImageView) withObject:nil afterDelay:0.1];
    
    
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
-(void)clickRefresh_plan
{
    [self performSelector:@selector(removeMoreImageView) withObject:nil afterDelay:0.1];
    
    
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToast:@"请检查网络连接" duration:1 position:@"center" isShadow:NO];
        
        return;
    }
    
    if(self.flag_plan == 1)
    {
        NSLog(@"   行程之强制刷新 ");
        
        [[QYURLCache sharedQYURLCache] deleteAllLocalCachesWithFileName:_planName andUrl:_startURL];
        
        if(_webView)
        {
            [_webView stopLoading];
            _webView.delegate = nil;
            [_webView removeFromSuperview];
            if(_webView.retainCount > 0)
            {
                [_webView release];
            }
        }
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height-(44+20))];
        _webView.tag = webViewTag;
        if(ios7)
        {
            _webView.frame = CGRectMake(0, 44+20, 320, self.view.frame.size.height-(44+20));
        }
        _webView.backgroundColor = [UIColor clearColor];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        [self.view addSubview:_webView];
        
        if(urlCache_qy)
        {
            [urlCache_qy release];
        }
        NSString *pathName = [NSString stringWithFormat:@"webviewCache/plan/%@",_planName];
        [[FilePath sharedFilePath] createFilePath:pathName];
        NSString *path = [[FilePath sharedFilePath] getFilePath:pathName];
        urlCache_qy = [[QYURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:path];
        urlCache_qy.delegate = self;
        urlCache_qy.donotgetdatafromserver = NO;
        [NSURLCache setSharedURLCache:urlCache_qy];
        
        //[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_startURL]]];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_startURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10]];
        
        
        return;
    }
    
    [_webView reload];
    
}
-(void)removeMoreImageView
{
    [[ActionListView sharedActionListView] doCancle];
}


#pragma mark -
#pragma mark --- MYActionSheet - Delegate
-(void)actionSheetButtonDidClickWithType:(NSString *)type
{
    if([type isEqualToString:@"邮件"])
    {
        [self youjianfenxiang];
    }
    if([type isEqualToString:@"短信"])
    {
        [self sendmessage];
    }
    else if([type isEqualToString:@"新浪微博"])
    {
        [self shareToSinaWeibo];
    }
    else if([type isEqualToString:@"微信"])
    {
        [self shareToWeixinFriend];
    }
    else if([type isEqualToString:@"微信朋友圈"])
    {
        [self shareToWeixinFriendCircle];
    }
    else if([type isEqualToString:@"腾讯微博"])
    {
        [self shareToTencentWeibo];
    }
}



-(void)youjianfenxiang
{
    _flag_shared = YES;
        
    [[QyerSns sharedQyerSns] shareToMailWithMailTitle:[NSString stringWithFormat:@"Hi~我刚用@穷游网 的#行程助手#规划了行程【%@】",self.planName] andMailInfo:[NSString stringWithFormat:@"Hi~\n\t我刚用@穷游网 的#行程助手#规划了行程【%@】，景点美食购物闲逛都被我安排妥当啦，这次旅行，放心跟我走吧！\n\t详细行程来这里看→_→ %@\n\n\t关于出境游，这一切，尽在穷游。\n\n只需免费下载穷游APP，你就进入了穷游的世界，这里不仅有准确的指南和给力的折扣，这里还有由经验丰富的穷游网友所组成的社区，通过问答和发帖，大家可以彼此互助。\n\n从此，你将永远不会独行，伴随你旅行始终的，将是穷游和穷游的几千万新老朋友。\n\n有了穷游APP，你就放心出行吧。 穷游，陪你体验整个世界的精彩。\n\n穷游App有iPhone、Android和iPad版本，扫描二维码即可轻松下载！http://www.qyer.com/getapp/guide?campaign=app_share_qy&category=iPhone_myplan",self.planName,_startURL] andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)sendmessage
{
    _flag_shared = YES;
    [[QyerSns sharedQyerSns] shareWithShortMessage:[NSString stringWithFormat:@"刚用@穷游网 的#行程助手#规划了行程【%@】，景点美食购物闲逛都被我安排妥当啦，这次旅行，放心跟我走吧！详细行程来这里看→_→ %@",self.planName,_startURL] inViewController:self];
}

-(void)shareToWeixinFriend
{
    _flag_shared = YES;
    
    [[QyerSns sharedQyerSns] shareToWeixinWithAPPTitle:@"穷游APP" andDescription:[NSString stringWithFormat:@"刚用@穷游网 的#行程助手#规划了行程【%@】，景点美食购物闲逛都被我安排妥当啦，这次旅行，放心跟我走吧！详细行程来这里看→_→",self.planName] andImage:[UIImage imageNamed:@"120icon"] andUrl:_startURL];
}

-(void)shareToWeixinFriendCircle
{
    _flag_shared = YES;
    
    [[QyerSns sharedQyerSns] shareToWeixinFriendCircleWithAPPTitle:[NSString stringWithFormat:@"刚用@穷游网 的#行程助手#规划了行程【%@】，景点美食购物闲逛都被我安排妥当啦，这次旅行，放心跟我走吧！详细行程来这里看→_→",self.planName] andDescription:@"" andImage:[UIImage imageNamed:@"120icon"] andUrl:_startURL];
}

-(void)shareToSinaWeibo
{
    _flag_shared = YES;
    [[QyerSns sharedQyerSns] shareToSinaWeiboWithTitle:@"分享到新浪微博" andText:[NSString stringWithFormat:@"我用@穷游网 的#行程助手#规划了行程【%@】，景点美食购物闲逛都被我安排妥当啦，超有成就感！小伙伴们快进来点赞！详情→_→ %@",self.planName,_startURL] andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)shareToTencentWeibo
{
    _flag_shared = YES;
    
    [[QyerSns sharedQyerSns] shareToTencentWeiboWithText:[NSString stringWithFormat:@"我用@穷游网 的#行程助手#规划了行程【%@】，景点美食购物闲逛都被我安排妥当啦，超有成就感！小伙伴们快进来点赞！详情→_→ %@",self.planName,_startURL] andImage:[UIImage imageNamed:@"iphone_sina_sns"] andDelegate:self];
}



#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end


