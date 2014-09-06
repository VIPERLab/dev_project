//
//  ThirdLoginViewController.m
//  CityGuide
//
//  Created by lide on 13-3-7.
//  Copyright (c) 2013年 com.qyer. All rights reserved.
//

#import "ThirdLoginViewController.h"
#import "NSString+SBJSON.h"
#import "NSObject+SBJson.h"
#import "Toast+UIView.h"
#import "MobClick.h"
#import "Account.h"
//#import "MBProgressHUD.h"
//#import "QYSignConstant.h"






@interface ThirdLoginViewController ()

@end





@implementation ThirdLoginViewController

@synthesize titleText = _titleText;
@synthesize loginURL = _loginURL;

#pragma mark - private

- (void)clickCloseButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - super

- (id)init
{
    self = [super init];
    if(self != nil)
    {
    
    }
    return self;
}

- (void)dealloc
{
    QY_VIEW_RELEASE(_closeButton);
    QY_VIEW_RELEASE(_webView);
    QY_SAFE_RELEASE(_titleText);
    QY_SAFE_RELEASE(_loginURL);
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"第三方登录"];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MobClick endLogPageView:@"第三方登录"];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
    
    
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
    if(ios7)
    {
        _headView.frame = CGRectMake(0, 0, 320, 46+20);
    }
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, 200, 30)];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
//    _titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//    _titleLabel.shadowOffset = CGSizeMake(0, 1);
    if(ios7)
    {
        _titleLabel.frame = CGRectMake(60, 10+20, 200, 26);
    }
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_headView addSubview:_titleLabel];
    
    
    
    _backButton.hidden = YES;
    _titleLabel.text = _titleText;
    
    
    _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _closeButton.frame = CGRectMake(0, 3, 40, 40);
    if(ios7)
    {
        _closeButton.frame = CGRectMake(0, 3+20, 40, 40);
    }
    [_closeButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_closeButton];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 46, 320, [[UIScreen mainScreen] bounds].size.height-(20+46))];
    if(ios7)
    {
        _webView.frame = CGRectMake(0, 46+20, 320, self.view.frame.size.height-(20+46));
    }
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.backgroundColor = [UIColor clearColor];
    
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    if(ios7)
    {
        float height_top = 46+20;
        _webView.frame = frame;
        _webView.scrollView.contentInset = UIEdgeInsetsMake(height_top, 0, 0, 0);
        _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(height_top, 0, 0, 0);
        _webView.scrollView.contentOffset = CGPointMake(0, -height_top);
    }
    else
    {
        float height_top = 46;
        float height_frame = frame.size.height;
        height_frame = height_frame-20;
        frame.size.height = height_frame;
        _webView.frame = frame;
        _webView.scrollView.contentInset = UIEdgeInsetsMake(height_top, 0, 0, 0);
        _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(height_top, 0, 0, 0);
        _webView.scrollView.contentOffset = CGPointMake(0, -height_top);
    }
    
    [self.view addSubview:_webView];
    [self.view bringSubviewToFront:_headView];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_loginURL]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view makeToastActivity];
    
    if(!ios7 && [_titleText rangeOfString:@"QQ"].location != NSNotFound)
    {
        _webView.alpha = 0;
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.view hideToastActivity];
    
    //登录失败
    [self.view hideToastActivity];
    [self.view hideToast];
    [self.view makeToast:@"网络不给力" duration:1 position:@"center" isShadow:NO];
    [self performSelector:@selector(quit) withObject:Nil afterDelay:1];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(!ios7 && [_titleText rangeOfString:@"QQ"].location != NSNotFound)
    {
        _webView.scrollView.contentOffset = CGPointMake(0, -46);
    }
    [self.view hideToastActivity];
    _webView.alpha = 1;
    
    
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText"];
    NSMutableDictionary *dic = [html JSONValue];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qqlogin"] isEqualToString:@"1"])
    {
        [MobClick event:@"loginqqsuccess"];
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"weibologin"] isEqualToString:@"1"])
    {
        [MobClick event:@"loginweibosuccess"];
    }
    
    
    
    if(dic != nil)
    {
        webView.hidden = YES;
        
        NSInteger status = [[dic objectForKey:@"status"] intValue];
        
        
        if(status == 1)
        {
            [self.view hideToast];
            [self.view makeToast:@"登录成功" duration:1. position:@"center" isShadow:NO];
            
            dic = [dic objectForKey:@"data"];
            NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
            
            [myDefault setObject:[NSNumber numberWithBool:YES] forKey:@"qyerlogin"];
            [myDefault setValue:[dic valueForKey:@"access_token"] forKey:@"user_access_token"];
            
            if (![[dic objectForKey:@"im_user_id"] isEqual:[NSNull null]]) {
                [myDefault setValue:[dic valueForKey:@"im_user_id"] forKey:@"userid_im"];
            }
            
            [myDefault setObject:[[dic objectForKey:@"userinfo"] objectForKey:@"uid"] forKey:@"userid"];
            [myDefault setObject:[[dic objectForKey:@"userinfo"] objectForKey:@"username"] forKey:@"username"];
            [myDefault setObject:[[dic objectForKey:@"userinfo"] objectForKey:@"avatar"] forKey:@"usericon"];
            [myDefault setObject:[[dic objectForKey:@"userinfo"] objectForKey:@"avatar"] forKey:@"avatar"];
            [myDefault setObject:[[dic objectForKey:@"userinfo"] objectForKey:@"title"] forKey:@"title"];
            
            
            [myDefault synchronize];
            
            

            
            [[Account sharedAccount] initAccountWhenThirdLoginWithDic:dic];
            
            
            
            
            [self performSelector:@selector(thirdLoginSuccess) withObject:nil afterDelay:0];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            //登录失败
            [self.view hideToast];
            [self.view makeToast:@"登录失败" duration:1 position:@"center" isShadow:NO];
            
            [self performSelector:@selector(quit) withObject:Nil afterDelay:1];
        }
    }
    
    //NSLog(@"%@", html);
}


-(void)quit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)thirdLoginSuccess
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"THIRD_LOGIN_SUCCESS" object:nil userInfo:nil];
}

@end
