/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  MainViewController.h
//  NativeTableExample
//
//  Created by Administrator on 04/06/11.
//  Copyright SpartakB 2011. All rights reserved.
//
#import "loadCDWebViewShellViewController.h"
#import "CDVWebMainViewController.h"
#import "CountryViewController.h"
#import "CDVWebRedicteViewController.h"
#import "BBSDetailViewController.h"
//#import "LastMinuteDetailViewController.h"
#import "LastMinuteDetailViewControllerNew.h"
#import "GuideDetailViewController.h"
#import "QYGuideData.h"
#import "PoiDetailViewController.h"
#import "webFrameCacheData.h"
#import "ODRefreshControl.h"
#import "WebViewViewController.h"
#import "Toast+UIView.h"
#import "Reachability.h"

#define URL_REDIRECT_PLACE @"http://appview.qyer.com/index.php?action=placeDetail"
#define URL_REDIRECT_STRING @"http://appview.qyer.com"
#define URL_REDIRECT_COUNTRY @"country"
#define URL_REDIRECT_CITY    @"city"
#define URL_REDIRECT_GUIDE    @"guide"
#define URL_REDIRECT_POI      @"poi"
#define URL_REDIRECT_BBS      @"bbs"
#define URL_REDIRECT_TRIP     @"trip"
#define URL_REDIRECT_QUESTION  @"question"
#define URL_REDIRECT_LASTMINUTE  @"deal"

@implementation CDVWebMainViewController
@synthesize currentVC;

-(void)pop_no_data{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"introductory_pages"]){
        [self.view makeToast:@"网络错误,请检查网络后下拉重试" duration:1. position:@"center" isShadow:NO];
    }
}

-(void)refleshWebView{
    isPop_toast=YES;
    NSString *path = [[webFrameCacheData sharedCacheWebData] getCachePath];
    path = [NSString stringWithFormat:@"%@/%@.html",path,@"index1"];
    
    NSString *htmlString = [[NSString alloc] initWithContentsOfFile:path encoding: NSUTF8StringEncoding error:nil];
    
    if (htmlString.length<5000) {
        [htmlString release];
        NSString *path = [[webFrameCacheData sharedCacheWebData] getCachePath];
        path = [NSString stringWithFormat:@"%@/%@.html",path,@"index1"];
        NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"www/index2" ofType:@"html"];
        htmlString = [[NSString alloc] initWithContentsOfFile:htmlPath encoding: NSUTF8StringEncoding error:nil];
        [htmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        //*********** Insert By ZhangDong 2014.4.10 Start ***********
        NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
        
        if (![fileManager fileExistsAtPath:path]){
            NSLog(@"本地html没有写入缓存");
        }
        [[NSUserDefaults standardUserDefaults] setObject:@"1.0" forKey:@"RecommendWebHtml_FrameWork_Version"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *tmpPath= [[NSBundle mainBundle] pathForResource:@"www/index" ofType:@".html"];
    [htmlString writeToFile:tmpPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
   
    [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:tmpPath]];
    
    
    [htmlString release];
    
}

-(void)dealloc{
    [currentVC release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refleshWebView" object:nil];
    [super dealloc];
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}
- (void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    isPop_toast=YES;
    [self refleshWebView];
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.webView.scrollView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refleshWebView) name:@"refleshWebView" object:nil];
    self.webView.dataDetectorTypes=UIDataDetectorTypeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pop_no_data) name:@"pop_no_data" object:nil];
    
//    if(urlCache_qy)
//    {
//        [urlCache_qy release];
//    }
//    NSString *pathName = [NSString stringWithFormat:@"webviewCache/recommend/%@",@"recommend"];
//    [[FilePath sharedFilePath] createFilePath:pathName];
//    NSString *path = [[FilePath sharedFilePath] getFilePath:pathName];
//    urlCache_qy = [[JHURLCache alloc] initWithMemoryCapacity:5*1024*1024 diskCapacity:60*1024*1024 diskPath:path];
//    [NSURLCache setSharedURLCache:urlCache_qy];
}


- (void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

/* Comment out the block below to over-ride */
/*
- (CDVCordovaView*) newCordovaViewWithFrame:(CGRect)bounds
{
    return[super newCordovaViewWithFrame:bounds];
}
*/

/* Comment out the block below to over-ride */
/*
#pragma CDVCommandDelegate implementation

- (id) getCommandInstance:(NSString*)className
{
	return [super getCommandInstance:className];
}

- (BOOL) execute:(CDVInvokedUrlCommand*)command
{
	return [super execute:command];
}

- (NSString*) pathForResource:(NSString*)resourcepath;
{
	return [super pathForResource:resourcepath];
}
 
- (void) registerPlugin:(CDVPlugin*)plugin withClassName:(NSString*)className
{
    return [super registerPlugin:plugin withClassName:className];
}
*/

#pragma UIWebDelegate implementation

- (void) webViewDidFinishLoad:(UIWebView*) theWebView 
{
     // only valid if ___PROJECTNAME__-Info.plist specifies a protocol to handle
    
     // Black base color for background matches the native apps
     theWebView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
    [refreshControl endRefreshing];
    
    // 禁用用户选择
    [theWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    // 禁用长按弹出框
    [theWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    
	return [super webViewDidFinishLoad:theWebView];
}

/* Comment out the block below to over-ride */


- (void) webViewDidStartLoad:(UIWebView*)theWebView 
{
//    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
//    {
//        [self.view hideToast];
//        [self.view makeToast:@"貌似网络有点不好，检查一下吧..." duration:1. position:@"center" isShadow:NO];
//        
//        return;
//    }
	return [super webViewDidStartLoad:theWebView];
}

- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error 
{
    [refreshControl endRefreshing];
	return [super webView:theWebView didFailLoadWithError:error];
}

-(NSString *)EncodeUTF8Str:(NSString *)encodeStr{
    CFStringRef nonAlphaNumValidChars = CFSTR("![DISCUZ_CODE_1]’()*+,-./:;=?@_~《》（）");
    NSString *preprocessedString = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)encodeStr, CFSTR(""), kCFStringEncodingUTF8);
    NSString *newStr = [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)preprocessedString,NULL,nonAlphaNumValidChars,kCFStringEncodingUTF8) autorelease];
    [preprocessedString release];
	return newStr;
}

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    
//    [urlCache_qy cachedResponseForRequest:request];
    
    
    NSURL *url = [request URL];
    NSLog(@"url:%@",url);
    
    NSArray* _arrayError=[[url absoluteString] componentsSeparatedByString:@"#"];
    if (_arrayError.count>1) {
        NSString* str=[_arrayError objectAtIndex:0];
        NSRange foundObj=[str rangeOfString:@"http://error.qyer.com/" options:NSCaseInsensitiveSearch];
        if (foundObj.length>0) {
            NSArray* arr=[[_arrayError objectAtIndex:1] componentsSeparatedByString:@"="];
            if ([arr objectAtIndex:1] && ![[arr objectAtIndex:1] isKindOfClass:[NSNull class]]) {
                

                [[NSUserDefaults standardUserDefaults] setObject:@"1.0" forKey:@"RecommendWebHtml_FrameWork_Version"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
                {
                    
                    return NO;
                }
                [refreshControl endRefreshing];
                if (isPop_toast) {
                    isPop_toast=NO;
                    [self.view makeToast:@"请求数据失败" duration:1.0 position:@"bottom" isShadow:NO];
                }
                
                 return NO;
            }
            
        }
    }
    NSArray* _array=[self spliteRedictUrl:[url absoluteString] withSeparated:URL_REDIRECT_STRING];
    if (_array.count>1) {
        if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_COUNTRY]) {
            [refreshControl endRefreshing];
            CountryViewController *countryVc = [[CountryViewController alloc]init];
            countryVc.type =1;
            countryVc.key = [_array objectAtIndex:2];
            [currentVC.navigationController pushViewController:countryVc animated:YES];
            [countryVc release];
            return NO;
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_CITY]){
            [refreshControl endRefreshing];
            CountryViewController *countryVc = [[CountryViewController alloc]init];
            countryVc.type = 2;
            countryVc.key = [_array objectAtIndex:2];
            [currentVC.navigationController pushViewController:countryVc animated:YES];
            [countryVc release];
            return NO;
        }else if ([[_array objectAtIndex:0] isEqualToString:URL_REDIRECT_GUIDE]){
            [refreshControl endRefreshing];
            GuideDetailViewController *guideDetailVC = [[GuideDetailViewController alloc] init];
            
            guideDetailVC.guideId = [_array objectAtIndex:1];
            guideDetailVC.flag_new = YES;
            [guideDetailVC setGuide:[QYGuideData getGuideById:[_array objectAtIndex:1]]];
            [self.currentVC.navigationController pushViewController:guideDetailVC animated:YES];
            [guideDetailVC release];
            return NO;
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_POI]){
            [refreshControl endRefreshing];
            PoiDetailViewController *poiDetailVC = [[PoiDetailViewController alloc] init];
            poiDetailVC.poiId = [[_array objectAtIndex:2] integerValue];
            [self.currentVC.navigationController pushViewController:poiDetailVC animated:YES];
            [poiDetailVC release];

            return NO;
        }else if ([[_array objectAtIndex:0] isEqualToString:URL_REDIRECT_BBS]){
                        
            [self pushWebViewWithUrl:[url absoluteString] withTitle:[self getTitleStringWithUrl:[url absoluteString]]];
            return NO;
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_TRIP]){
            [self pushWebViewWithUrl:[url absoluteString] withTitle:[self getTitleStringWithUrl:[url absoluteString]]];
            return NO;
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_QUESTION]){
            [self pushWebViewWithUrl:[url absoluteString] withTitle:[self getTitleStringWithUrl:[url absoluteString]]];
            return NO;
        }else if ([[_array objectAtIndex:1] isEqualToString:URL_REDIRECT_LASTMINUTE]){
            [refreshControl endRefreshing];
            

            [MobClick event:@"recClickDisc"];
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
            
            
            return NO;
        }
    }
    
    NSRange foundObj=[[url absoluteString] rangeOfString:URL_REDIRECT_PLACE options:NSCaseInsensitiveSearch];
    if (foundObj.length>0) {
        [self pushWebViewWithUrl:[url absoluteString] withTitle:@"目的地推荐"];
        return NO;
    }
    foundObj=[[url absoluteString] rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
    if (foundObj.length>0){
        [refreshControl endRefreshing];
        WebViewViewController *webVC_inApp = [[WebViewViewController alloc] init];
        
        //webVC_inApp._flag_recommend=YES;
        [webVC_inApp setStartURL:[request.URL absoluteString]];
        [self.currentVC presentViewController:[QYToolObject getControllerWithBaseController:webVC_inApp] animated:YES completion:nil];
        [webVC_inApp release];
        return NO;
    }
	return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
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
        
    [refreshControl endRefreshing];
    
    if ([_strTitle isEqualToString:@"精华游记"]) {
        [MobClick event:@"recClickJournal"];
        BBSDetailViewController * bbsDetailVC = [[BBSDetailViewController alloc]init];
        bbsDetailVC.bbsAllUserLink = _url;
//        bbsDetailVC.bbsAuthorLink = travalll.str_travelUrl_onlyauthor;
        [self.currentVC.navigationController pushViewController:bbsDetailVC animated:YES];
        [bbsDetailVC release];
    }
    
    else{
        [MobClick event:@"recClickDest"];
        loadCDWebViewShellViewController* cdMianWeb=[[loadCDWebViewShellViewController alloc] initWithTitle:_strTitle];
        cdMianWeb._redicteUrl=[NSURL URLWithString:_url];
        cdMianWeb._titleLabel.text=_strTitle;
        [self.currentVC.navigationController pushViewController:cdMianWeb animated:YES];
        [cdMianWeb release];
    }
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


-(void)refreshMore{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [NSString stringWithFormat:@"%@",[infoDictionary objectForKey:@"CFBundleVersion"]];
    [[webFrameCacheData sharedCacheWebData] getRecommendWebHtml:appVersion andWebVer:[[NSUserDefaults standardUserDefaults] objectForKey:@"RecommendWebHtml_FrameWork_Version"]];
}

#pragma mark - slimeRefresh delegate

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)_refreshControl
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view makeToast:@"貌似网络有点不好，检查一下吧..." duration:1. position:@"center" isShadow:NO];
        [refreshControl endRefreshing];
        return;
    }
    [self refreshMore];

}

@end
