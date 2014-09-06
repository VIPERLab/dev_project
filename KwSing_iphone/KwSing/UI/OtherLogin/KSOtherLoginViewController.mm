//
//  KSLoginViewController.m
//  KwSing
//
//  Created by 改 熊 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSOtherLoginViewController.h"
#import "KSWebView.h"
#import "KSLoginDelegate.h"
#import "KSAppDelegate.h"
#import "ImageMgr.h"
#import "MessageManager.h"
#import "AddInformationViewController.h"
#import "iToast.h"
#import "globalm.h"

#define WEIBO_WEB           @"http://i.kuwo.cn/US/platform/orig_kwsing.htm?t=weibo&src=kwsing_ios"
//#define WEIBO_WEB           @"http://60.28.200.79/US/platform/orig_kwsing.htm?t=weibo&src=kwsing_ios"
#define QQ_WEB              @"http://i.kuwo.cn/US/platform/orig_kwsing.htm?t=qq&src=kwsing_ios"
//#define QQ_WEB              @"http://60.28.200.79/US/platform/orig_kwsing.htm?t=qq&src=kwsing_ios"
#define RENREN_WEB          @"http://i.kuwo.cn/US/platform/orig_kwsing.htm?t=renren&src=kwsing_ios"
//#define RENREN_WEB          @"http://60.28.200.79/US/platform/orig_kwsing.htm?t=renren&src=kwsing_ios"
#define TENCENTWEIBO_WEB    @"http://i.kuwo.cn/US/platform/orig_kwsing.htm?t=tencentweibo&src=kwsing_ios"
#define TIME_LIMIT          30.0f

@interface KSOtherLoginViewController()
{
    KSWebView * webView;
    
    BOOL _isShare;
    BOOL _isRegist;
    
    LOGIN_TYPE _type;
    KSLoginDelegate *_loginDelegate;
    UIAlertView *_waitingDialog;
    
    NSTimer *_time;
}
-(void)onTimeout;
@end


@implementation KSOtherLoginViewController
@synthesize isShare=_isShare;
@synthesize isRegist=_isRegist;
@synthesize type=_type;

-(id)initWithType:(LOGIN_TYPE)type
{
    self=[super init];
    if (self) {
        [self setType:type];
        [self setIsShare:FALSE];
        [self setIsRegist:FALSE];
    }
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    
    return self;
}

-(void)viewDidLoad
{
    _waitingDialog=[[UIAlertView alloc] initWithTitle:@"正在验证,请稍后..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    UIActivityIndicatorView *activity=[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [activity setCenter:CGPointMake(150, 50)];
    [activity startAnimating];
    [_waitingDialog addSubview:activity];

    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    switch (_type) {
        case QQ:
        {
            [label_title setText:@"QQ空间"];
            break;
        }
        case SINA:
        {
            [label_title setText:@"新浪微博"];
            break;
        }
        case RENREN:
        {
            [label_title setText:@"人人网"];
            break;
        }
        default:
            break;
    }
    [view_title addSubview:label_title];
    
    UIButton* btn_ret = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_ret.frame = CGRectMake(0, 0, 44, 44);
    [btn_ret setBackgroundColor:[UIColor clearColor]];
    btn_ret.imageEdgeInsets = UIEdgeInsetsMake(10, 14.5, 10, 14.5);
    [btn_ret setImage:CImageMgr::GetImageEx("KgeReturnBtn.png") forState:(UIControlStateNormal)];
    [btn_ret addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view_title addSubview:btn_ret];
    
    CGRect rc=[[self view] bounds];
    rc.origin.y+=ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height;
    
     webView = [[[KSWebView alloc] initWithFrame:rc allowBounce:NO useLoading:YES opaque:NO] autorelease];
    _loginDelegate=[[KSLoginDelegate alloc] init];
    [_loginDelegate setDelegate:self];
    [webView setDelegate:_loginDelegate];
    [webView scalesPageToFit:false];
    
    switch (_type) {
        case SINA:
            if (User::GetUserInstance()->isOnline()) {
                NSString *url=[NSString stringWithFormat:@"%@&sync=1&kid=%@&sid=%@&_=%d",WEIBO_WEB,User::GetUserInstance()->getUserId(),User::GetUserInstance()->getSid(), rand()];
                //NSLog(@"url:%@",url);
                [webView loadUrl:url];
            }
            else {
                [webView loadUrl:WEIBO_WEB];
            }
            break;
        case QQ:
            if (User::GetUserInstance()->isOnline()) {
                NSString *url=[NSString stringWithFormat:@"%@&sync=1&kid=%@&sid=%@&_=%d",QQ_WEB,User::GetUserInstance()->getUserId(),User::GetUserInstance()->getSid(), rand()];
                //NSLog(@"visit web %@",url);
                [webView loadUrl:url];
            }
            else {
                [webView loadUrl:QQ_WEB];
            }
            break;
        case RENREN:
            NSLog(@"renren login");
            if (User::GetUserInstance()->isOnline()) {
                NSString *url=[NSString stringWithFormat:@"%@&sync=1&kid=%@&sid=%@",RENREN_WEB,User::GetUserInstance()->getUserId(),User::GetUserInstance()->getSid()];
                [webView loadUrl:url];
                NSLog(@"url:%@",url);
            }
            else {
                [webView loadUrl:[NSString stringWithFormat:@"%@&%d",RENREN_WEB,rand()]];
                NSLog(@"url:%@",RENREN_WEB);
            }
            break;
        case TENCENTWEIBO:
            if (User::GetUserInstance()->isOnline()) {
                NSString *url=[NSString stringWithFormat:@"%@&sync=1&kid=%@&sid=%@@&_=%d",TENCENTWEIBO_WEB,User::GetUserInstance()->getUserId(),User::GetUserInstance()->getSid(), rand()];
                [webView loadUrl:url];
            }
            else {
                [webView loadUrl:TENCENTWEIBO_WEB];
            }
            break;
        default:
            break;
    }
    //[webView setBackgroundImage:CImageMgr::GetBackGroundImage()];
    [webView setBackgroundColor:UIColorFromRGBValue(0xededed)];
    [[self view] addSubview:webView];
}

-(void)viewDidUnload
{
    _loginDelegate=nil;
    _waitingDialog=nil;
    [super dealloc];
}
-(void)dealloc
{
    [webView setDelegate:nil];
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    [_waitingDialog release];
    [_loginDelegate release];
    [super dealloc];
}
-(void)IUserStatusObserver_LoginStart :(LOGIN_TYPE) type
{
    if (type != KUWO) {
        [_waitingDialog show];
        _time=[NSTimer scheduledTimerWithTimeInterval:TIME_LIMIT target:self selector:@selector(onTimeout) userInfo:nil repeats:false];
    }
}
-(void)onTimeout
{
    [_waitingDialog dismissWithClickedButtonIndex:0 animated:NO];
    [self.navigationController popViewControllerAnimated:false];
    UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"网络连接超时，请稍后再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease];
    [alert show];
}
-(void)IUserStatusObserver_LoginFinish:(LOGIN_TYPE)type :(LOGIN_TIME)first
{
    if (nil != _time) {
        if ([_time isValid]) {
            [_time invalidate];
        }
    }
    //NSLog(@"type:%d,time:%d",type,first);
    [_waitingDialog dismissWithClickedButtonIndex:0 animated:NO];
    if (type == REPEAT_LOGIN) {
        //todo
        [[[[iToast makeText:NSLocalizedString(@"该账号已经绑定了其它酷我账号", @"")]setGravity:iToastGravityCenter] setDuration:4000] show];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (type == FAIL_LOGIN) {
        [[[[iToast makeText:NSLocalizedString(@"登录失败", @"")]setGravity:iToastGravityCenter] setDuration:4000] show];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (_isShare) {
        //分享直接pop
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        // first or not，login or regist
        if (first == IS_FIRST) {
            [[[[iToast makeText:NSLocalizedString(@"请补充资料", @"")]setGravity:iToastGravityCenter] setDuration:4000] show];
            AddInformationViewController *addController=[[AddInformationViewController alloc] init];
            [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:NO];
            if (_isRegist) {
                [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:NO];
            }
            [ROOT_NAVAGATION_CONTROLLER pushViewController:addController animated:YES];
            [addController release];
        }
        else
        {
            if (_isRegist) {
                [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:NO];
            }
            [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:NO];
            [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];
        }
    }
}
-(void)IUserStatusObserver_AddBind:(LOGIN_TYPE)type :(BIND_RES)bindRes
{
    if (nil != _time) {
        if ([_time isValid]) {
            [_time invalidate];
        }
    }
    [_waitingDialog dismissWithClickedButtonIndex:0 animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
    if (bindRes == BIND_SUCCESS) {
        [[[[iToast makeText:NSLocalizedString(@"绑定成功", @"")]setGravity:iToastGravityCenter] setDuration:4000] show];
    }
    else if (bindRes == BIND_FAIL){
        [[[[iToast makeText:NSLocalizedString(@"绑定失败", @"")]setGravity:iToastGravityCenter] setDuration:4000] show];
    }
    else if (bindRes == BIND_REPEAT){
        [[[[iToast makeText:NSLocalizedString(@"第三方账号已经绑定了其它的酷我账号", @"")]setGravity:iToastGravityCenter] setDuration:4000] show];
    }
}
//相应界面上的返回按钮
-(void)ReturnBtnClick:(UIButton *)sender
{
    [self retain];
    [self performSelector:@selector(delayDestroy) withObject:self afterDelay:10.0];//在我们验证框弹出前返回～
    [self.navigationController popViewControllerAnimated:YES];
}
//相应网页上的取消
-(void)onReturn
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)delayDestroy
{
    [self release];
}
@end