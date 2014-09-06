//
//  AboutViewController.m
//  kwbook
//
//  Created by 熊 改 on 13-12-26.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import "AboutViewController.h"
#import "globalm.h"
#import "ImageMgr.h"
#import "KBAppDelegate.h"



@interface AboutViewController ()
@property (nonatomic , strong) UIView                   *topBar;
@property (nonatomic , strong) UIWebView                *contentView;
@end

@implementation AboutViewController

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
	// Do any additional setup after loading the view.
    float gap = 0.0;
    if (isIOS7()) {
        gap = 20;
    }
    float width  = self.view.bounds.size.width;
    float height = self.view.bounds.size.height;
    self.topBar = ({
        UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44+gap)];
        UIImageView *backView = [[UIImageView alloc] initWithFrame:topBar.bounds];
        if (isIOS7()) {
            [backView setImage:CImageMgr::GetImageEx("RecoTopBackFor7.png")];
        }
        else{
            [backView setImage:CImageMgr::GetImageEx("RecoTopBackFor6.png")];
        }
        [topBar addSubview:backView];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setImage:CImageMgr::GetImageEx("TopBackBtn.png") forState:UIControlStateNormal];
        [backBtn setFrame:CGRectMake(0, gap, 44, 44)];
        [backBtn addTarget:self action:@selector(onBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [topBar addSubview:backBtn];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, gap, 180, 44)];
        [titleLabel setText:@"关于"];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:20.0]];
        [topBar addSubview:titleLabel];
        topBar;
    });
    [[self view] addSubview:self.topBar];
    
    self.contentView = ({
        UIWebView *contentView =  [[UIWebView alloc] initWithFrame:CGRectMake(0, 44+gap, width, height-44-gap)];
        NSString *resourcePath = [ [NSBundle mainBundle] resourcePath];
        NSString *filePath = [resourcePath stringByAppendingPathComponent:@"about.html"];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        NSURLRequest *req = [NSURLRequest requestWithURL:fileURL];
        [contentView loadRequest:req];
        contentView;
    });
    [[self view] addSubview:self.contentView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)onBackBtnClick:(id)sender
{
    [ROOT_NAVI_CONTROLLER popViewControllerAnimated:YES];
}
@end
