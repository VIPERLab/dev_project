//
//  MyGuideViewController.m
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "MyGuideViewController.h"
#import "DownloadViewController.h"
#import "BookMarkViewController.h"



@interface MyGuideViewController ()

@end



@implementation MyGuideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)dealloc
{
    QY_SAFE_RELEASE(_headView);
    QY_SAFE_RELEASE(_toolBar);
    QY_SAFE_RELEASE(_downloadVC);
    QY_SAFE_RELEASE(_bookmarkVC);
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- 构建View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    [self initRootView];
    [self initHeadView];
    [self initAllButtonAndDownloadButton];
    [self performSelector:@selector(initDownloadGuideView) withObject:nil afterDelay:0];
}
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
-(void)initHeadView
{
    float height_headView = (ios7 ? 20+44 : 44);
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headView)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(184/2, positionY_titlelabel, 136, height_titlelabel)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"我的锦囊";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    [_titleLabel release];
    
    
    UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
}
-(void)initAllButtonAndDownloadButton
{
    float positionY = 20+44;
    if(!ios7)
    {
        positionY = 44;
    }
    UIImage *image = [UIImage imageNamed:@"download"];
    if(!_toolBar)
    {
        _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, positionY, 320, image.size.height+positionY_button_guideVC*2)];
    }
    _toolBar.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:_toolBar belowSubview:_headView];
    
    
    
    //已下载按钮:
    if(!_button_download)
    {
        _button_download = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _button_download.frame = CGRectMake(0, positionY_button_guideVC, 320/2, image.size.height);
    [_button_download setBackgroundImage:image forState:UIControlStateNormal];
    [_button_download setBackgroundImage:[UIImage imageNamed:@"highlight_download"] forState:UIControlStateSelected];
    [_button_download addTarget:self action:@selector(initDownloadGuideView) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_button_download];
    
    
    
    //书签按钮:
    image = [UIImage imageNamed:@"bookmark"];
    if(!_button_bookmark)
    {
        _button_bookmark = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _button_bookmark.backgroundColor = [UIColor clearColor];
    _button_bookmark.frame = CGRectMake(_button_download.frame.origin.x+_button_download.frame.size.width, positionY_button_guideVC, 320/2, image.size.height);
    [_button_bookmark setBackgroundImage:[UIImage imageNamed:@"bookmark"] forState:UIControlStateNormal];
    [_button_bookmark setBackgroundImage:[UIImage imageNamed:@"highlight_bookmark"] forState:UIControlStateSelected];
    [_button_bookmark addTarget:self action:@selector(initBookMarkView) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_button_bookmark];
    
    
    
    //最下面的分割线:
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, _button_download.frame.origin.y+_button_download.frame.size.height, 320, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:224/255. green:224/255. blue:224/255. alpha:1];
    [_toolBar addSubview:line];
    [line release];
}

-(void)initDownloadGuideView
{
    _button_download.selected = YES;
    _button_bookmark.selected = NO;
    
    if(!_downloadVC)
    {
        _downloadVC = [[DownloadViewController alloc] init];
        _downloadVC.currentVC = self;
    }
    if(_bookmarkVC)
    {
        [_bookmarkVC.view removeFromSuperview];
    }
    [self.view insertSubview:_downloadVC.view belowSubview:_toolBar];
    _selectedView_state = download_state;
}
-(void)initBookMarkView
{
    _button_download.selected = NO;
    _button_bookmark.selected = YES;
    
    if(!_bookmarkVC)
    {
        _bookmarkVC = [[BookMarkViewController alloc] init];
        _bookmarkVC.currentVC = self;
        _bookmarkVC.flag_navigation = YES;
    }
    if(_downloadVC)
    {
        [_downloadVC.view removeFromSuperview];
    }
    [self.view insertSubview:_bookmarkVC.view belowSubview:_toolBar];
    _selectedView_state = bookmark_state;
}




#pragma mark -
#pragma mark --- clickBackButton
-(void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark --- 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

