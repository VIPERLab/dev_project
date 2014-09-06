//
//  ActivityViewController.m
//  KwSing
//
//  Created by 熊 改 on 13-3-14.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import "ActivityViewController.h"
#import "KSWebView.h"
#import "globalm.h"
#import "KSAppDelegate.h"
#import "ImageMgr.h"
#import "MainViewController.h"
#import "MusicLibViewController.h"
#import "MusicListViewController.h"
#import "KSMusicLibDelegate.h"
#import "IUserStatusObserver.h"
#import "MessageManager.h"
#import "User.h"

@interface ActivityViewController ()<KSWebViewDelegate>
{
    KSWebView* _webView;
    
    UIButton* backBtn;
    UIButton* forwardBtn;
    
    KSMusicLibDelegate *delegate;
}
-(void)onBack;
-(void)goForward;
-(void)onRefresh;
@end

@implementation ActivityViewController

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
    
    //GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_MUSICLIB,IMusicLibObserver);
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS, IUserStatusObserver);
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:view_title];
    
    UIImageView* view_back = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_back setImage:CImageMgr::GetImageEx("SpringNavigatorBar.png")];
    [view_title addSubview:view_back];
    
    UIButton* btn_ret = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_ret.frame = CGRectMake(0, 0, 44, 44);
    [btn_ret setBackgroundColor:[UIColor clearColor]];
    btn_ret.imageEdgeInsets = UIEdgeInsetsMake(10, 14.5, 10, 14.5);
    [btn_ret setImage:CImageMgr::GetImageEx("KgeReturnBtn.png") forState:(UIControlStateNormal)];
    [btn_ret addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view_title addSubview:btn_ret];
    
    CGRect rc=[self view].bounds;
    CGRect rcna=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
    CGRect back=BottomRect(rc, rc.size.height-rcna.size.height, 0);
    back.size.height-=70;
    _webView = [[[KSWebView alloc] initWithFrame:back allowBounce:TRUE useLoading:YES opaque:NO] autorelease];
    [_webView setDelegate:self];
    [_webView setBackgroundColor:UIColorFromRGBValue(0xededed)];
    [[self view] addSubview:_webView];
    
    [_webView loadUrl:_url];
    
    UIView *bottomView=[[[UIView alloc] init] autorelease];
    [bottomView setFrame:BottomRect(self.view.bounds, 70, 0)];
    [[self view] addSubview:bottomView];
    
    UIImageView *backView=[[[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("recordbottombk.png")] autorelease];
    [backView setFrame:bottomView.bounds];
    [bottomView addSubview:backView];
    
    backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(20, 5, 43, 43)];
    [backBtn setImage:CImageMgr::GetImageEx("backBtn.png") forState:UIControlStateNormal];
    [backBtn setImage:CImageMgr::GetImageEx("backBtnDown.png") forState: UIControlStateSelected];
    [backBtn setImage:CImageMgr::GetImageEx("backBtnEnable.png") forState:UIControlStateDisabled];
    [backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setEnabled:false];
    [bottomView addSubview:backBtn];
    
    forwardBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [forwardBtn setFrame:CGRectMake(90, 5, 43, 43)];
    [forwardBtn setImage:CImageMgr::GetImageEx("forwardBtn.png") forState:UIControlStateNormal];
    [forwardBtn setImage:CImageMgr::GetImageEx("forwardBtnDown.png") forState:UIControlStateSelected];
    [forwardBtn setImage:CImageMgr::GetImageEx("forwardBtnEnable.png") forState:UIControlStateDisabled];
    [forwardBtn addTarget:self action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [forwardBtn setEnabled:false];
    [bottomView addSubview:forwardBtn];
    
    UIButton *refreshBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [refreshBtn setFrame:CGRectMake(240, 5, 43, 43)];
    [refreshBtn setImage:CImageMgr::GetImageEx("refreshBtn.png") forState:UIControlStateNormal];
    [refreshBtn setImage:CImageMgr::GetImageEx("refreshBtnDown.png") forState:UIControlStateSelected];
    [refreshBtn addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:refreshBtn];
}


-(void)onBack
{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
}
-(void)goForward
{
    if ([_webView canGoForward]) {
        [_webView goForward];
    }
}
-(void)onRefresh
{
    [_webView reload];
}
-(void)ReturnBtnClick:(id)sender
{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS, IUserStatusObserver);
    [(KSAppDelegate *)[[UIApplication  sharedApplication] delegate] setFromKuwoMusic:false];
    [self.navigationController popViewControllerAnimated:true];
}

- (void)webViewDidStartLoad:(KSWebView*)view
{
//    NSLog(@"start");
}
- (void)webViewDidFinishLoad:(KSWebView*)view success:(BOOL)isSuccess
{
//    NSLog(@"finish load");
    if ([view canGoBack]){
//        NSLog(@"can go back");
        [backBtn setEnabled:true];
    }
    else
        [backBtn setEnabled:false];
    
    if ([view canGoForward]) {
//        NSLog(@"can go forward");
        [forwardBtn setEnabled:true];
    }
    else{
        [forwardBtn setEnabled:false];
    }
}
- (void)webViewRunActionWithParam:(KSWebView*)view action:(NSString*)act parameter:(NSDictionary*)paras
{
    NSLog(@"act:%@",act);
    if ([act isEqualToString:@"JumpToKSong"] || [act isEqualToString:@"JumpToKSongPage"]) {
        NSString *strID=(NSString *)[paras objectForKey:@"id"];
        if (strID && ![strID isEqualToString:@""]) {
            NSString *strName=(NSString *)[paras objectForKey:@"name"];
            NSString *strDigest=(NSString *)[paras objectForKey:@"intro"];
            NSString *strImage=(NSString *)[paras objectForKey:@"pic"];
            NSString *strCount=(NSString *)[paras objectForKey:@"count"];
            NSLog(@"%@,%@,%@,%@",strName,strDigest,strImage,strCount);
            ListInfo info;
            info.strID=[strID UTF8String];
            info.strName=[strName UTF8String];
            info.strDigest=[strDigest UTF8String];
            info.strPicUrl=[strImage UTF8String];
            info.nCount=[strCount intValue];
            
            MusicListViewController *musicListViewController=[[[MusicListViewController alloc] initwithListInfo:info] autorelease];
            delegate=[[KSMusicLibDelegate alloc] init];
            [musicListViewController setMusiclibDelegate:delegate];
            [musicListViewController setTitle:strName];
            //[musicListViewController setShowPopView:YES];
            [ROOT_NAVAGATION_CONTROLLER pushViewController:musicListViewController animated:YES];
        }
        else{
            [ROOT_NAVAGATION_CONTROLLER popToRootViewControllerAnimated:NO];
            [[KSMainViewController getInstance] selectSubView:2];
            [(KSMusicLibViewController*)[[KSMainViewController getInstance] getSubViewWithIndex:2] selectSubIndex:0];
        }
    }
}

-(void)dealloc
{
    //GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_MUSICLIB,IMusicLibObserver);
    [delegate release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)IUserStatusObserver_LoginFinish:(LOGIN_TYPE) type :(LOGIN_TIME)first
{
    [_webView executeJavaScriptFunc:@"onRefreshPage" parameter:[NSString stringWithFormat:@"id=%@&loginid=%@&sid=%@&uname=%@&head=%@",User::GetUserInstance()->getUserId(),User::GetUserInstance()->getUserId(),User::GetUserInstance()->getSid(),User::GetUserInstance()->getNickName(),User::GetUserInstance()->getHeadPic()]];
}

@end
