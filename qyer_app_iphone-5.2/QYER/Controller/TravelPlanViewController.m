//
//  TravelPlanViewController.m
//  QYER
//
//  Created by Leno on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "TravelPlanViewController.h"
#import "Toast+UIView.h"

@interface TravelPlanViewController ()

@end

#define     height_headerview           (ios7 ? (46+20) : 46)

@implementation TravelPlanViewController

@synthesize planLink = _planLink;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initRootView];
}

-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
    
    UIImageView * naviBarImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)] autorelease];
    if(ios7)
    {
        naviBarImgView.frame = CGRectMake(0, 0, 320, 46 + 20);
    }
    naviBarImgView.backgroundColor = [UIColor clearColor];
    naviBarImgView.image = [UIImage imageNamed:@"home_head"];
    naviBarImgView.userInteractionEnabled = YES;
    [self.view addSubview:naviBarImgView];
    
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 13, 220, 30)];
    if(ios7)
    {
        titleLabel.frame = CGRectMake(80, 6+20, 160, 30);
    }
    [titleLabel setTag:888];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"行程详情";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
//    titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//    titleLabel.shadowOffset = CGSizeMake(0, 1);
    [naviBarImgView addSubview:titleLabel];
    [titleLabel release];
    
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor = [UIColor clearColor];
    backButton.frame = CGRectMake(0, 3, 40, 40);
    if(ios7)
    {
        backButton.frame = CGRectMake(0, 3+20, 40, 40);
    }
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_webview_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [naviBarImgView addSubview:backButton];
    
    
    
    //初始化WebView
    if(ios7)
    {
        _planDetailWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, height_headerview, 320, [[UIScreen mainScreen] bounds].size.height -height_headerview)];
    }
    else
    {
        _planDetailWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, height_headerview, 320, ([[UIScreen mainScreen] bounds].size.height-20) -height_headerview)];
    }
    
    _planDetailWebView.delegate = self;
    _planDetailWebView.scalesPageToFit = YES;
    _planDetailWebView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_planDetailWebView];
    
    
    //发起获取详情的请求
    [_planDetailWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.planLink]]];
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view makeToastActivity];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.view hideToastActivity];
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.view hideToastActivity];
    
    //获取并设置标题
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    UILabel * titleLabel = (UILabel *)[self.view viewWithTag:888];
    [titleLabel setText:title];
    
}


//返回POI介绍
- (void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)dealloc
{
    QY_VIEW_RELEASE(_planDetailWebView);
    QY_SAFE_RELEASE(_planLink);
    
    [super dealloc];
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

@end
