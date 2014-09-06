//
//  KSFansFollowViewController.m
//  KwSing
//
//  Created by 单 永杰 on 14-4-14.
//  Copyright (c) 2014年 酷我音乐. All rights reserved.
//

#import "KSFansFollowViewController.h"
#include "KSWebView.h"
#include "globalm.h"
#include "ImageMgr.h"
#include "KSAppDelegate.h"
#include "User.h"
#include "BaseWebViewController.h"

#define MY_FANS_URL @"http://changba.kuwo.cn/kge/webmobile/ios/user_list.html?type=getfans&uid=%@&t=%d"
#define MY_FOLLOW_URL @"http://changba.kuwo.cn/kge/webmobile/ios/user_list.html?type=getfav&uid=%@&t=%d"

@interface KSFansFollowViewController ()<KSWebViewDelegate>{
    NSString* str_view_title;
    KSWebView* webView;
}

@end

@implementation KSFansFollowViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [super viewDidLoad];
	[self setTitle:str_view_title];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [label_title setText:str_view_title];
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
    if ([str_view_title isEqualToString:@"我的关注"]) {
        NSString* str_url = [NSString stringWithFormat:MY_FOLLOW_URL,User::GetUserInstance()->getUserId(),rand()];
        [webView loadUrl:[NSString stringWithFormat:MY_FOLLOW_URL,User::GetUserInstance()->getUserId(),rand()]];
    }else if([str_view_title isEqualToString:@"我的粉丝"]){
        [webView loadUrl:[NSString stringWithFormat:MY_FANS_URL,User::GetUserInstance()->getUserId(),rand()]];
    }
}

-(id)initWithType:(NSString*)str_page_type{
    self=[super init];
    if (self) {
        if (nil == str_view_title) {
            str_view_title = [str_page_type retain];
        }else {
            if (str_view_title != str_page_type) {
                [str_view_title release];
                str_view_title = [str_page_type retain];
            }
        }
    }

    return self;
}
-(void)reloadPage{
    [webView reload];
}

-(void)ReturnBtnClick:(id)sender
{
    [webView setDelegate:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)webViewRunActionWithParam:(KSWebView*)view action:(NSString*)act parameter:(NSDictionary*)paras
{

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
