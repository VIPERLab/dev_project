//
//  QYBaseViewController.m
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QYBaseViewController.h"
#import "ILTranslucentView.h"


@interface QYBaseViewController ()

@end

@implementation QYBaseViewController
@synthesize buttontype;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        _isScolling = NO;
    }
    return self;
}

-(void)loadView{
    
    [super loadView];
    
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    //rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // [self initRootView];
    
    [self setNavigationBar];
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor = RGB(255, 255, 255);

	// Do any additional setup after loading the view.
}
/*
-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor whiteColor];
    //rootView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
    //rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
*/
-(void)setNavigationBar
{
//    _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
//    _headView.backgroundColor = RGB(43, 171, 121);
//    _headView.userInteractionEnabled = YES;
//    [self.view addSubview:_headView];
    
//    _headView = [[ILTranslucentView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
//    _headView.userInteractionEnabled = YES;
//    [self.view addSubview:_headView];
//    
//    _headView.translucentAlpha = 0.97;
//    _headView.translucentStyle = UIBarStyleDefault;
//    _headView.translucentTintColor = RGB(0, 120, 82);
//    _headView.backgroundColor = (ios7 ? [UIColor clearColor] : RGB(43, 171, 121));
    
    _headView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, height_headerview)];
    _headView.userInteractionEnabled = YES;
    _headView.image = [UIImage imageNamed:@"home_head"];
    [self.view addSubview:_headView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, positionY_titlelabel, 240, height_titlelabel)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    
    
    
    if([self.buttontype isEqualToString:@"cancle"])
    {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor clearColor];
        _backButton.frame = CGRectMake(6, 6, 47, 33);
        if(ios7)
        {
            _backButton.frame = CGRectMake(6, 6+20, 47, 33);
        }
        [_backButton setBackgroundImage:[UIImage imageNamed:@"btn_more_cancel"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:_backButton];
    }
    else
    {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor clearColor];
        _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
        [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:_backButton];
    }
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(280, positionY_sharebutton, 40, 40);
    //[_rightButton setBackgroundImage:[UIImage imageNamed:@"btn_detail_share.png"] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_rightButton];
    
    _notDataImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 150)];
    _notDataImageView.hidden = YES;
    _notDataImageView.center = self.view.center;
    [self.view addSubview:_notDataImageView];
    
    
    //关闭按钮
    _closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _closeButton.frame = CGRectMake(2, _headView.frame.size.height-40-2, 40, 40);//CGRectMake(2, 2, 40, 40);
    _closeButton.backgroundColor = [UIColor clearColor];
    [_closeButton setBackgroundImage:[UIImage imageNamed:@"btn_webview_close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_closeButton];
    _closeButton.hidden = YES;
    
}

/**
 *  是否显示没有网络视图
 */
- (void)setNotReachableView:(BOOL)isVisible
{
    NotReachableView *notReachableView = (NotReachableView*)[self.view viewWithTag:444];
    if (isVisible) {
        if (!notReachableView) {
            CGFloat height = self.view.bounds.size.height - RootViewControllerFootViewHeight - height_headerview;
            notReachableView = [[NotReachableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, height_headerview, UIWidth, height)];
            notReachableView.backgroundColor = [UIColor clearColor];
            notReachableView.delegate = self;
            notReachableView.tag = 444;
            [self.view addSubview:notReachableView];
            [notReachableView release];
        }
    }else{
        [notReachableView removeFromSuperview];
        notReachableView = nil;
    }
}

#pragma mark
#pragma mark NotReachableViewDelegate

- (void)touchesView
{
    //subclass override
}

#pragma mark - click
- (void)clickBackButton:(UIButton *)btn{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)clickCloseButton:(id)sender
{
    [self clickCloseButton:sender completion:NULL];
}

- (void)clickCloseButton:(id)sender completion: (void (^)(void))completion
{
    [self dismissViewControllerAnimated:YES completion:completion];
}

- (void)dealloc
{
    [_headView release];
    _headView = nil;
    
    [_titleLabel release];
    _titleLabel = nil;
    
    [_notDataImageView release];
    _notDataImageView = nil;
    
    [super dealloc];
}

- (void)clickRightButton:(UIButton *)btn{
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
