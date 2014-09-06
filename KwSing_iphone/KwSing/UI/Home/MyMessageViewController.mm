//
//  MyMessageViewController.m
//  KwSing
//
//  Created by Zhai HaiPIng on 12-12-14.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "MyMessageViewController.h"
#include "KSWebView.h"
#include "globalm.h"
#include "ImageMgr.h"
#include "KSAppDelegate.h"
#include "CommentViewController.h"

#define MESSAGE_PAGE_URL @"http://changba.kuwo.cn/kge/webmobile/ios/news.html"

@interface MyMessageViewController ()<KSWebViewDelegate>
{
    KSWebView* webView;
}
@end

@implementation MyMessageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [label_title setText:@"消息"];
    [view_title addSubview:label_title];
    
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

    webView = [[[KSWebView alloc] initWithFrame:back allowBounce:TRUE useLoading:YES opaque:NO] autorelease];
    [webView setDelegate:self];
    [webView setBackgroundColor:UIColorFromRGBValue(0xededed)];
    [[self view] addSubview:webView];
    [webView loadUrl:[NSString stringWithFormat:@"%@?%d",MESSAGE_PAGE_URL,rand()]];
}
-(void)reloadPage
{
    [webView reload];
}
-(void)ReturnBtnClick:(id)sender
{
    [webView setDelegate:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)webViewRunActionWithParam:(KSWebView*)view action:(NSString*)act parameter:(NSDictionary*)paras
{
    if ([act isEqualToString:@"goCmt"]) {
        NSString *kid=[paras objectForKey:@"kid"];
        NSString *ssid=[paras objectForKey:@"ssid"];
        NSString *uid=[paras objectForKey:@"uid"];
        CommentViewController *comment=[[[CommentViewController alloc] init] autorelease];
        [comment SetMusicId:[kid UTF8String] subjectID:[ssid UTF8String] UserID:[uid UTF8String]];
        [ROOT_NAVAGATION_CONTROLLER pushViewController:comment animated:YES];
    }
}
@end
