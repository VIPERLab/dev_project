//
//  MyTidingsViewController.m
//  KwSing
//
//  Created by Zhai HaiPIng on 12-12-14.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "MyTidingsViewController.h"
#include "KSWebView.h"
#include "globalm.h"
#include "ImageMgr.h"
#include "User.h"
#include "MessageManager.h"
#include "KSAppDelegate.h"
#include "LoginViewController.h"
#include "IUserStatusObserver.h"
#include "MobClick.h"

#define MYTIDINGS_PAGE_URL @"http://changba.kuwo.cn/kge/webmobile/ios/dynamic.html"
//#define MYTIDINGS_PAGE_URL @"60.28.205.41:8180/kge/webmobile/ios/dynamic.html"

@interface MyTidingsViewController ()<KSWebViewDelegate,IUserStatusObserver>
{
    KSWebView* webView;
    UIView* pNeedLoginMsgView;
    
}
@end

@implementation MyTidingsViewController

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    
    return self;
}

- (void)viewDidLoad
{	
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setText:@"好友动态"];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [view_title addSubview:label_title];
    
    //UIImage *imageBack=CImageMgr::GetBackGroundImage();
    CGRect rc=[self view].bounds;
    CGRect rcna=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
    CGRect back=BottomRect(rc, rc.size.height-rcna.size.height, 0);
    //UIImageView *background=[[UIImageView alloc] initWithImage:imageBack];
    //[background setFrame:back];
    //[[self view] addSubview:background];
    //[background release];
    
    webView = [[[KSWebView alloc] initWithFrame:back allowBounce:TRUE useLoading:YES opaque:NO] autorelease];
    [webView setDelegate:self];
    [webView setBackgroundColor:UIColorFromRGBValue(0xededed)];
    [[self view] addSubview:webView];
    
    if (User::GetUserInstance()->isOnline()) {
        [webView loadUrl:[NSString stringWithFormat:@"%@?%d",MYTIDINGS_PAGE_URL,rand()]];
    } else {
        [self showNeedLoginView];
    }
}

-(void)dealloc
{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    [MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
    [webView setDelegate:nil];
    [super dealloc];
}

- (void)showNeedLoginView
{
    if (!pNeedLoginMsgView) {
        CGRect rc=[self view].bounds;
        CGRect rcna=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
        CGRect back=BottomRect(rc, rc.size.height-rcna.size.height, 0);
        pNeedLoginMsgView=[[UIView alloc] initWithFrame:back];
        [pNeedLoginMsgView setBackgroundColor:[UIColor whiteColor]];
        UIImage *needLoginImage=CImageMgr::GetImageEx("needLogin.png");
        UIImageView *needLoginView=[[[UIImageView alloc] initWithFrame:CGRectMake(35, 116, needLoginImage.size.width,needLoginImage.size.height)] autorelease];
        [needLoginView setImage:needLoginImage];
        [pNeedLoginMsgView addSubview:needLoginView];
        [self.view addSubview:pNeedLoginMsgView];
        
        UITapGestureRecognizer *tapGestureRecognize=[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapErrorViewGestureRecognizer:)] autorelease];
        tapGestureRecognize.numberOfTapsRequired=1;
        [pNeedLoginMsgView addGestureRecognizer:tapGestureRecognize];
    }
    pNeedLoginMsgView.hidden=NO;
}

- (void)singleTapErrorViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    KSLoginViewController* loginController=[[[KSLoginViewController alloc] init] autorelease];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:loginController animated:YES];
}

-(void)IUserStatusObserver_LoginFinish:(LOGIN_TYPE) type :(LOGIN_TIME)first
{
    if (pNeedLoginMsgView) {
        [pNeedLoginMsgView removeFromSuperview];
        [pNeedLoginMsgView release];
        pNeedLoginMsgView=NULL;
    }
    if (!User::GetUserInstance()->isOnline()) {
        [self showNeedLoginView];
    }else {
        [webView loadUrl:[NSString stringWithFormat:@"%@?%d",MYTIDINGS_PAGE_URL,rand()]];
    }
}
-(void)IUserStatusObserver_Logout
{
    [self showNeedLoginView];
}
-(void)IUserStatusObserver_StateChange
{
    [webView reload];
}

@end
