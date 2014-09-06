//
//  MusicWebViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "BaseWebViewController.h"
#include "ImageMgr.h"
#include "globalm.h"
#include "KSWebView.h"
#include "IUserStatusObserver.h"
#include "MessageManager.h"

#define REFRESH_INTERVAL        1

@implementation BaseWebViewController
@synthesize strUrl;

- (id)init{
    self = [super init];
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIImageView * imageView = [[[UIImageView alloc]init]autorelease];
    [imageView setFrame:self.navigationController.navigationBar.bounds];
    [imageView setImage:CImageMgr::GetImageEx("topBk.png")];
    [[self view] addSubview:imageView];

    UIImageView * topshadowView = [[[UIImageView alloc]init]autorelease];
    CGRect rcshadow = self.navigationController.navigationBar.bounds;
    rcshadow.origin.y += rcshadow.size.height;
    rcshadow.size.height = 5;
    [topshadowView setFrame:rcshadow];
    [topshadowView setImage:CImageMgr::GetImageEx("topShadow.png")];
    [[self view] addSubview:topshadowView];

    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTag:1];
    [btn setTitle:@"返回" forState: UIControlStateNormal];
    [[btn titleLabel] setShadowOffset:CGSizeMake(0, 1)];
    [[btn titleLabel] setShadowColor:[UIColor blackColor]];
    [btn setBackgroundImage:CImageMgr::GetImageEx("topReturnBtn_6.png") forState:UIControlStateNormal];
    [btn setBackgroundImage:CImageMgr::GetImageEx("topReturnBtnDown_6.png") forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.frame = CGRectMake(10, 9, 47,28);
    [btn addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:btn];
    
    UILabel* lable = [[[UILabel alloc]initWithFrame:CGRectMake(60, 15, self.navigationController.navigationBar.bounds.size.width-120,20)]autorelease];
    lable.textAlignment = UITextAlignmentCenter;
    lable.text = [self title];
    lable.Font = [UIFont systemFontOfSize:15];
    [lable setShadowColor:UIColorFromRGBAValue(0x000000,50)];
    [lable setShadowOffset:CGSizeMake(1, 1)];
    lable.backgroundColor = [UIColor clearColor];
    lable.textColor = [UIColor whiteColor];
    
    [[self view] addSubview:lable];
    
    CGRect rc = [self view].bounds;
    CGRect rcnav = self.navigationController.navigationBar.bounds;
    rc = BottomRect(rc,rc.size.height-rcnav.size.height,0);
    
    webView = [[[KSWebView alloc]initWithFrame:rc allowBounce:FALSE useLoading:YES opaque:NO] autorelease];
    if(strUrl)
        [webView loadUrl:strUrl];
    [webView setBackgroundColor:CImageMgr::GetBackGroundColor()];
    [[self view] addSubview:webView];
    [webView setDelegate:webDelegate];
    [[self view]bringSubviewToFront:topshadowView];

}

-(void) ReturnBtnClick:(id)sender
{
    [self CloseView];
}

-(void)CloseView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    
    [super dealloc];
}

- (void) SetWebDelegate:(id<KSWebViewDelegate>)delegate
{
    webDelegate = delegate;
    [webView setDelegate:webDelegate];
}
-(KSWebView *)getWebView
{
    return webView;
}

-(void)viewDidUnload
{
    [strUrl release];
}
-(void)IUserStatusObserver_LoginFinish:(LOGIN_TYPE) type :(LOGIN_TIME)first
{
    if (type != REPEAT_LOGIN && type != FAIL_LOGIN) {
        [webView reload];
    }
}
@end
