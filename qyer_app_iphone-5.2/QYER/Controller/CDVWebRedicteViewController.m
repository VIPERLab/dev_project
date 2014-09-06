//
//  CDVWebRedicteViewController.m
//  QYER
//
//  Created by Qyer on 14-4-8.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CDVWebRedicteViewController.h"
#import "CountryViewController.h"
#import "Toast+UIView.h"
//#import "LastMinuteDetailViewController.h"
#import "Reachability.h"
#import "PoiDetailViewController.h"
#import "loadCDWebViewShellViewController.h"

#define URL_REDIRECT_STRING @"http://appview.qyer.com"
#define URL_REDIRECT_COUNTRY @"country"
#define URL_REDIRECT_CITY    @"city"
#define URL_REDIRECT_GUIDE    @"guide"
#define URL_REDIRECT_POI      @"poi"
#define URL_REDIRECT_BBS      @"bbs"
#define URL_REDIRECT_TRIP     @"trip"
#define URL_REDIRECT_QUESTION  @"question"
#define URL_REDIRECT_LASTMINUTE  @"deal"
@interface CDVWebRedicteViewController ()

@end

@implementation CDVWebRedicteViewController

@synthesize _redicteUrl;
@synthesize currentVc;
-(void)dealloc{
    [_redicteUrl release];
    _redicteUrl=nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_redicteUrl) {
        
        NSTimeInterval webTimeOut=10;  //timeout時間設定為10秒
        
        NSURLRequest *requestObject = [NSURLRequest requestWithURL:_redicteUrl cachePolicy:NSURLCacheStorageAllowed timeoutInterval:webTimeOut];
        [self.webView loadRequest:requestObject];
        
        refreshControl = [[ODRefreshControl alloc] initInScrollView:self.webView.scrollView];
        [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        if (isNotReachable) {
            [self setWebNotReachableView:YES];
        }
    }
    
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



#pragma UIWebDelegate implementation

- (void) webViewDidFinishLoad:(UIWebView*) theWebView
{
    // only valid if ___PROJECTNAME__-Info.plist specifies a protocol to handle
    //     if (self.invokeString)
    //     {
    //        // this is passed before the deviceready event is fired, so you can access it in js when you receive deviceready
    //        NSString* jsString = [NSString stringWithFormat:@"var invokeString = \"%@\";", self.invokeString];
    //        [theWebView stringByEvaluatingJavaScriptFromString:jsString];
    //     }
    
    // Black base color for background matches the native apps
    //theWebView.backgroundColor = [UIColor blackColor];
   
    [refreshControl endRefreshing];
    if (notReachableView) {
        [notReachableView removeFromSuperview];
        notReachableView = nil;

    }
        // 禁用用户选择
    [theWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用长按弹出框
    [theWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    [self.view hideToastActivity];
	return [super webViewDidFinishLoad:theWebView];
}

/* Comment out the block below to over-ride */

/**
 *  是否显示没有网络视图
 */
- (void)setWebNotReachableView:(BOOL)isVisible
{
    if (isVisible) {
         notReachableView = (NotReachableView*)[self.view viewWithTag:444];
        if (!notReachableView) {
            CGFloat height = self.view.bounds.size.height - RootViewControllerFootViewHeight - height_headerview;
            notReachableView = [[NotReachableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, 0, UIWidth, height)];
            notReachableView.backgroundColor = [UIColor clearColor];
            notReachableView.delegate = self;
            notReachableView.tag = 444;
            [self.view addSubview:notReachableView];
            [notReachableView release];
            [self.view hideToastActivity ];
        }
    }else{
        [notReachableView removeFromSuperview];
        notReachableView = nil;
    }
}

- (void)touchesView
{
    if (!isNotReachable) {
        
        [self setWebNotReachableView:NO];

        NSTimeInterval webTimeOut=10;  //timeout時間設定為10秒
        
        NSURLRequest *requestObject = [NSURLRequest requestWithURL:_redicteUrl cachePolicy:NSURLCacheStorageAllowed timeoutInterval:webTimeOut];
        [self.webView loadRequest:requestObject];
    }else{
        [self.view hideToast];
        [self.view makeToast:@"貌似网络有点不好，检查一下吧..." duration:1. position:@"center" isShadow:NO];
    }
    
}

- (void) webViewDidStartLoad:(UIWebView*)theWebView

{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        return;
    }

    
    [self.view makeToastActivity];
    
    
     theWebView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
	return [super webViewDidStartLoad:theWebView];
}

- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
    
        [self.view hideToastActivity];
    [self setWebNotReachableView:YES];
    
	return [super webView:theWebView didFailLoadWithError:error];
}

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSLog(@"url:%@",url);
    
    NSArray* _arrayError=[self spliteRedictUrl:[url absoluteString] withSeparated:@"#"];
    if (_arrayError.count>1) {
        if ([[_arrayError objectAtIndex:0] isEqualToString:@"http://error.qyer.come"]) {
            if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
            {
                
                return NO;
            }
            NSArray* arr=[[_arrayError objectAtIndex:1] componentsSeparatedByString:@"="];
            if ([arr objectAtIndex:1] && ![[arr objectAtIndex:1] isKindOfClass:[NSNull class]]) {
                [self.view makeToast:[arr objectAtIndex:1] duration:1.0 position:@"center" isShadow:NO];
            }
            return NO;
        }
    }
    NSArray* _array=[self spliteRedictUrl:[url absoluteString] withSeparated:URL_REDIRECT_STRING];
    if (_array.count>1) {
        if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_COUNTRY]) {
            [refreshControl endRefreshing];
            CountryViewController *countryVc = [[CountryViewController alloc]init];
            countryVc.type = 1;
            countryVc.key = [_array objectAtIndex:2];
            [self.currentVc.navigationController pushViewController:countryVc animated:YES];
            [countryVc release];
            return NO;
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_CITY]){
            [refreshControl endRefreshing];
            CountryViewController *countryVc = [[CountryViewController alloc]init];
            countryVc.type = 2;
            countryVc.key = [_array objectAtIndex:2];
            [self.currentVc.navigationController pushViewController:countryVc animated:YES];
            [countryVc release];
            return NO;
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_GUIDE]){
            return NO;
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_POI]){
            [refreshControl endRefreshing];
            PoiDetailViewController *poiDetailVC = [[PoiDetailViewController alloc] init];
            poiDetailVC.poiId = [[_array objectAtIndex:2] integerValue];
            [self.currentVc.navigationController pushViewController:poiDetailVC animated:YES];
            [poiDetailVC release];
            return NO;
        }

    }
    
    NSRange foundObj=[[url absoluteString] rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
    if (foundObj.length>0) {
        
        return YES;
    }
	return NO;
}

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


-(void)pushWebViewWithUrl:(NSString*)_url withTitle:(NSString*)_strTitle{
    CDVViewController* cdMianWeb=[[CDVWebRedicteViewController alloc] init];
    ((CDVWebRedicteViewController*)cdMianWeb)._redicteUrl=[NSURL URLWithString:_url];
    
    
    
    [self.navigationController pushViewController:cdMianWeb animated:YES];
    [cdMianWeb release];
}


- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)_refreshControl
{
    NSTimeInterval webTimeOut=10;  //timeout時間設定為10秒
    
    NSURLRequest *requestObject = [NSURLRequest requestWithURL:_redicteUrl cachePolicy:NSURLCacheStorageAllowed timeoutInterval:webTimeOut];
    [self.webView loadRequest:requestObject];
}
@end
