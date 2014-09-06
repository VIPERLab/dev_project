//
//  AboutViewController.m
//  KwSing
//
//  Created by 改 熊 on 12-9-11.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "AboutViewController.h"
#import "KSAppDelegate.h"
#import "ImageMgr.h"
#import "globalm.h"
#import "KSWebView.h"

@interface AboutViewController ()
{
    UIWebView *aboutWebView;
}
@end

@implementation AboutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:@"关于酷我"];
    
    [[self view] setBackgroundColor:[UIColor whiteColor]];

    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [label_title setText:self.title];
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
    rc=BottomRect(rc, rc.size.height-rcna.size.height, 0);
    aboutWebView=[[UIWebView alloc] initWithFrame:rc];

    NSString *resourcePath = [ [NSBundle mainBundle] resourcePath];
    NSString *filePath = [resourcePath stringByAppendingPathComponent:@"about.html"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSURLRequest *req = [NSURLRequest requestWithURL:fileURL];
    [aboutWebView loadRequest:req];
    [aboutWebView setBackgroundColor:UIColorFromRGBValue(0xededed)];
    
    [[self view] addSubview:aboutWebView];
}

-(void)ReturnBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
