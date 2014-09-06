//
//  BaseViewController.m
//  CityGuide
//
//  Created by lide on 13-2-16.
//  Copyright (c) 2013年 com.qyer. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

#pragma mark - private

- (void)clickBackButton:(id)sender
{
    if(self.navigationController && [self.navigationController.viewControllers count] > 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_backButton);
    QY_VIEW_RELEASE(_shadowImageView);
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"新登录页面bg" ofType:@"png"]];
    rootView.userInteractionEnabled = YES;
    self.view = rootView;
    [rootView release];
    
    
    
    
//    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
//    if(ios7)
//    {
//        _headView.frame = CGRectMake(0, 0, 320, 46+20);
//    }
//    _headView.backgroundColor = [UIColor clearColor];
//    _headView.image = [UIImage imageNamed:@"home_head"];
//    _headView.userInteractionEnabled = YES;
//    [self.view addSubview:_headView];
    
    
//    
//    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, 200, 30)];
//    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
//    _titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//    _titleLabel.shadowOffset = CGSizeMake(0, 1);
//    if(ios7)
//    {
//        _titleLabel.frame = CGRectMake(60, 10+20, 200, 26);
//    }
//    _titleLabel.backgroundColor = [UIColor clearColor];
//    _titleLabel.textColor = [UIColor whiteColor];
//    _titleLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:_titleLabel];
    
}

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view bringSubviewToFront:_shadowImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
