//
//  WebViewController.m
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-13.
//  供折扣用
//

#import "WebViewController.h"
#import "Reachability.h"
//#import "MBProgressHUD.h"
//#import "MyOrderViewController.h"
#import "ConfirmOrderSecondViewController.h"
#import "QYCommonUtil.h"
#import "MBProgressHUD.h"
#import "QYCommonToast.h"

@interface WebViewController ()

@property (nonatomic, assign) BOOL isClickingBackBtn;

@end

@implementation WebViewController

@synthesize loadingURL = _loadingURL;
@synthesize titleString = _titleString;

- (void)clickCloseButton:(id)sender
{
    [super clickCloseButton:sender];
    
}

- (void)clickBackButton:(id)sender
{
    //防止用户点击返回按钮过快，延缓1秒点击
    if (!_isClickingBackBtn) {
        _isClickingBackBtn = YES;
        
        [self performSelector:@selector(setStopClickingBackBtn) withObject:nil afterDelay:1];
        
        if([_webView canGoBack]&&![self isFirstWeb])
        {
            [_webView goBack];
        }else{
//            NSLog(@"返回");
            [self clickCloseButton:nil];
        }
        
    }

}

- (void)setStopClickingBackBtn
{
    _isClickingBackBtn = NO;
}



//#pragma mark - private
//
//- (void)clickPrevButton:(id)sender
//{
//    if([_webView canGoBack])
//    {
//        [_webView goBack];
//    }
//}

//- (void)clickNextButton:(id)sender
//{
//    if([_webView canGoForward])
//    {
//        [_webView goForward];
//    }
//}

//- (void)clickRefreshButton:(id)sender
//{
//    [_webView reload];
//}

//- (void)clickSafariButton:(id)sender
//{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"确定使用系统浏览器打开？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    alertView.tag = 18872;
//    [alertView show];
//    [alertView release];
//}

//#pragma mark - UIAlertViewDelegate
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(buttonIndex == 0)
//    {
//        
//    }
//    else
//    {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_currentURL]];
//    }
//}

#pragma mark - super

- (id)init
{
    self = [super init];
    if(self != nil)
    {
//        _needRequestCookie = NO;
        _isClickingBackBtn = NO;
        
    }
    return self;
}

- (void)dealloc
{
//    QY_VIEW_RELEASE(_footView);
//    QY_VIEW_RELEASE(_prevButton);
//    QY_VIEW_RELEASE(_nextButton);
//    QY_VIEW_RELEASE(_refreshButton);
//    QY_VIEW_RELEASE(_safariButton);
    QY_VIEW_RELEASE(_webView);
    QY_SAFE_RELEASE(_loadingURL);
//    QY_SAFE_RELEASE(_currentURL);
    
    [super dealloc];
}

////调整关闭按钮的位置
//- (void)adjustFrameOfCloseButton
//{
//    CGRect frame = _closeButton.frame;
//    frame.origin.x = 320-40;
//    _closeButton.frame = frame;
//    
//}

-(void)setLoadingURL:(NSString *)loadingURL
{
    if (loadingURL) {
        QY_SAFE_RELEASE(_loadingURL);
    }
    
    _loadingURL = [[QYCommonUtil getCorrectUrlWithString:loadingURL] retain];

}

//- (void)loadView
//{
//    [super loadView];
//
//}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0 / 255.0 green:240.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];
    //关闭按钮放置在右边
    _closeButton.frame = CGRectMake(320-40-2, _headView.frame.size.height-40-2, 40, 40);
    
    _titleLabel.text = @"详情";
    _closeButton.hidden = NO;
    //调整关闭按钮的位置
    //    [self adjustFrameOfCloseButton];
    
    
    //    _footView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, 320, 44)];
    //    _footView.backgroundColor = [UIColor colorWithRed:50.0 / 255.0 green:50.0 / 255.0 blue:50.0 / 255.0 alpha:1.0];
    //    [self.view addSubview:_footView];
    
    //    _prevButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    //    _prevButton.frame = CGRectMake(20, 2, 40, 40);
    //    _prevButton.backgroundColor = [UIColor clearColor];
    //    [_prevButton setBackgroundImage:[UIImage imageNamed:@"btn_webview_back.png"] forState:UIControlStateNormal];
    //    [_prevButton addTarget:self action:@selector(clickPrevButton:) forControlEvents:UIControlEventTouchUpInside];
    //    [_footView addSubview:_prevButton];
    
    //    _nextButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    //    _nextButton.frame = CGRectMake(100, 2, 40, 40);
    //    _nextButton.backgroundColor = [UIColor clearColor];
    //    [_nextButton setBackgroundImage:[UIImage imageNamed:@"btn_webview_frw.png"] forState:UIControlStateNormal];
    //    [_nextButton addTarget:self action:@selector(clickNextButton:) forControlEvents:UIControlEventTouchUpInside];
    //    [_footView addSubview:_nextButton];
    
    //    _refreshButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    //    _refreshButton.frame = CGRectMake(180, 2, 40, 40);
    //    _refreshButton.backgroundColor = [UIColor clearColor];
    //    [_refreshButton setBackgroundImage:[UIImage imageNamed:@"btn_webview_refresh.png"] forState:UIControlStateNormal];
    //    [_refreshButton addTarget:self action:@selector(clickRefreshButton:) forControlEvents:UIControlEventTouchUpInside];
    //    [_footView addSubview:_refreshButton];
    
    //    _safariButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    //    _safariButton.frame = CGRectMake(260, 2, 40, 40);
    //    _safariButton.backgroundColor = [UIColor clearColor];
    //    [_safariButton setBackgroundImage:[UIImage imageNamed:@"btn_webview_safari.png"] forState:UIControlStateNormal];
    //    [_safariButton addTarget:self action:@selector(clickSafariButton:) forControlEvents:UIControlEventTouchUpInside];
    //    [_footView addSubview:_safariButton];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, self.view.frame.size.height - _headView.frame.size.height)];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    
    //-----------------------------------------------------------------------------------------------
    
    
    
    
    
    
    
    [self showCloseButton:NO];
    _titleLabel.text = _titleString;
    
//    [self showCookie];
    
}

- (void)showCloseButton:(BOOL)isShow
{
    
//    NSLog(@"----------------pageCount:%d", _webView.pageCount);
//    NSLog(@"----------------url:%@", _webView.request.URL.absoluteString);
    
    //如果是第一个界面则不显示返回按钮
    if ([self isFirstWeb]) {
        isShow = NO;
    }
    
    _closeButton.hidden = !isShow;
    //    _closeButton.hidden = isShow;
    
}

- (BOOL)isFirstWeb
{
    
    if ([_webView.request.URL.absoluteString hasPrefix:_loadingURL]) {
        return YES;
    }else if([_webView.request.URL.absoluteString rangeOfString:@"setuserlogincookie"].length>0){//如果正在访问SetCoockie接口时也是第一页
        return YES;
    
    }
    return NO;


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Setting_Is_WebView_Show];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        MBProgressHUD *hud;
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"无法连接到网络,请检查网络配置";
        hud.yOffset -= 35;
        dispatch_time_t popTime;
        popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (TOAST_DURATION * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            [self dismissModalViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:NULL];
        });
    }
    
    
    if(_needRequestCookie)//[self isNeedSetAuthCookie]
    {
        
//        NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:Setting_Access_Token];
        NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
        NSString *urlStr = [NSString stringWithFormat:@"%@/user/setuserlogincookie?oauth_token=%@&client_secret=%@&client_id=%@", DomainName, access_token, ClientSecret_QY, ClientId_QY];//@"%@/user/gettokentocdbauth?oauth_token=%@&client_secret=%@&client_id=%@"
        
        NSLog(@"--------cookie url:%@", urlStr);
        
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    
    }else{
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_loadingURL]]];
//        _currentURL = [NSString stringWithString:_loadingURL];
    
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:Setting_Is_WebView_Show];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_webView stopLoading];
    _webView.delegate = nil;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.view hideToastActivity];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.view makeToastActivity];
    
    [self showCloseButton:[_webView canGoBack]];
    

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.view hideToastActivity];
//    _currentURL = webView.request.URL.absoluteString;
    
    [self showCloseButton:[_webView canGoBack]];
    

    if(_needRequestCookie)//[self isNeedSetAuthCookie]
    {
//        if ([self getExpiresDate]) {
//            NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//            [settings setObject:[settings objectForKey:Setting_Access_Token] forKey:Setting_Cdb_Auth_Access_Token];
//            [settings synchronize];
//        }
        
        //标记请求过添加cookie的接口
        _needRequestCookie = NO;
        
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_loadingURL]]];
//        _currentURL = [NSString stringWithString:_loadingURL];

    
    
    }
    

}



- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.view hideToastActivity];

    [self showCloseButton:[_webView canGoBack]];


}

//判断是否需要set cbd_auth 的cookie
//"<NSHTTPCookie version:0 name:\"cdb_auth\" value:\"427aq7RgfOvN8AX3ktkpo%2BBz35ECF4A2KOVIP8Ovbwn6yUV%2Bw8ifA8rvFdE6VU%2B6zivJScksuOKV2NkS2pLocjm1hq9HfA\" expiresDate:2015-02-28 10:40:36 +0000 created:2014-02-28 10:40:36 +0000 (4.15277e+08) sessionOnly:FALSE domain:\".qyer.com\" path:\"/\" isSecure:FALSE>",
//- (BOOL)isNeedSetAuthCookie
//{
//    
////    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
////    NSString *access_token = [settings objectForKey:@"user_access_token"];
////    NSString *cdb_auth_access_token = [settings objectForKey:Setting_Cdb_Auth_Access_Token];
////    
////    NSDate *expiresDate = [self getExpiresDate];
////    NSTimeInterval expiresInterval = [expiresDate timeIntervalSince1970];
////    NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
////
////    if (!_isRequestCookie&&(access_token&&[access_token length]>0)) {//如果没有请求过cookie，并且用户登录了再去判断
////        if (!cdb_auth_access_token||[cdb_auth_access_token length]==0||!expiresDate) {//没有种过cookie或者种cookie不成功
////            return YES;
////        }else if (![cdb_auth_access_token isEqualToString:access_token]){//如果用户用其他账户登录、注册
////            return YES;
////            
////        }else if (nowInterval>=expiresInterval){//如果cookie值过期
////            return YES;
////            
////        }
////    }
////    
////    return NO;
//    
//    
//    //--------------用之前的逻辑，cookie有些时候会在使用的过程中失效
////    if (_needRequestCookie) {
////        return YES;
////    }
////    
////    return NO;
//    
//    return _needRequestCookie;
//    
//}

//获得cdb_auth cookie的过期时间
//- (NSDate*)getExpiresDate
//{
//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray *cookieAry = [cookieJar cookies];//cookiesForURL: [NSURL URLWithString:_loadingURL]];
//    NSLog(@"--------------cookieAry:%@", cookieAry);
//    
//    for (int i=0; i<[cookieAry count]; i++) {
//        NSHTTPCookie *cookie = [cookieAry objectAtIndex:i];
//        
//        if ([cookie.name isEqualToString:@"cdb_auth"]) {//存在cdb_auth cookie
//            return cookie.expiresDate;
//            
//        }
//    }
//
//    return nil;
//}

////清除cookie
//- (void)showCookie{
//
//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//
//    NSLog(@"------cookieJar:%@", cookieJar);
//
//    NSArray *cookieAry = [cookieJar cookies];//cookiesForURL: [NSURL URLWithString:_loadingURL]];
//
//    NSLog(@"------cookieAry:%@", cookieAry);
//
//
//}

@end
