//
//  GuideViewController.m
//  QYER
//
//  Created by 我去 on 14-3-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GuideViewController.h"
#import "BookMarkViewController.h"
#import "SearchViewController.h"
#import "DownloadViewController.h"
#import "AllGuideViewController.h"
#import "Reachability.h"
#import "Toast+UIView.h"
#import "MobClick.h"
#import "QYGuideData.h"




#define     positionY_button_bookmark       (ios7 ? 20 : 0)
#define     positionY_button_search         (ios7 ? 20 : 0)





@interface GuideViewController ()

@end




@implementation GuideViewController
@synthesize currentVC = _currentVC;

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
    QY_SAFE_RELEASE(_currentVC);
    QY_SAFE_RELEASE(_downloadVC);
    QY_SAFE_RELEASE(_allGuideVC);
    
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_firstLoad_failed);
    QY_VIEW_RELEASE(_toolBar);
    
    
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- viewDidAppear  &  viewDidDisappear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showtoolbar) name:@"showtoolbar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstrequestfailed) name:@"firstrequestfailed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestfailed) name:@"requestfailed" object:nil];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"锦囊页"];
    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"firstGuideData"] isEqualToString:@"1"] &&
       [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) //首次打开没有网络
    {
        [self initFailedView];
    }
    [self getGuideData];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [MobClick endLogPageView:@"锦囊页"];
    
    
    [self cancleGetGuideData];
}
-(void)getGuideData
{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"firstGuideData"] isEqualToString:@"1"] &&
       [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) //首次打开没有网络
    {
        return;
    }
    
    
    
    _firstLoad_failed.hidden = YES;
    if(_selectedView_state == allGuide_state)
    {
        [self getAllGuide];
    }
    else if(_selectedView_state == download_state)
    {
        [self getDownloadGuide];
    }
}
-(void)cancleGetGuideData
{
    [_allGuideVC cancleGetGuideData];
}
-(void)firstrequestfailed
{
    [self.view hideToastActivity];
    [self initFailedView];
}
-(void)requestfailed
{
    NSLog(@" ==================   requestfailed ");
    
    [self.view hideToastActivity];
    [self.view hideToast];
    [self.view makeToast:@"网络错误,请检查网络后重试" duration:1 position:@"center" isShadow:NO];
}


#pragma mark -
#pragma mark --- 首次打开没有网络
-(void)initFailedView
{
    //取消获取锦囊数据:
    [QYGuideData cancleGetGuideData];
    
    
    if(!_firstLoad_failed)
    {
        CGFloat y = 130;
        if ([UIScreen mainScreen].bounds.size.height == 480) {
            y = 86;
        }
        
        _firstLoad_failed = [[UIControl alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 640/2, [[UIScreen mainScreen] bounds].size.height - _headView.frame.size.height)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, 640/2, 360/2)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"notReachable"];
        [_firstLoad_failed addSubview:imageView];
        [imageView release];
    }
    _firstLoad_failed.backgroundColor = [UIColor clearColor];
    _firstLoad_failed.hidden = NO;
    [_firstLoad_failed addTarget:self action:@selector(getGuideData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_firstLoad_failed];
    
    _button_all.selected = NO;
    _button_download.selected = NO;
    if(_allGuideVC)
    {
        [_allGuideVC release];
        _allGuideVC = nil;
    }
}



#pragma mark -
#pragma mark --- 构建View
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(ios7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    [self initRootView];
    [self initHeadView];
    [self initAllButtonAndDownloadButton];
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
    
    //add by zyh
    //增加一个返回按钮
    UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_button_bookmark, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
    UIImageView *titleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 10, 80, 24)];
    if(ios7)
    {
        titleImgView.frame = CGRectMake(120, 10+20, 80, 24);
    }
    titleImgView.backgroundColor = [UIColor clearColor];
    [titleImgView setImage:[UIImage imageNamed:@"navigation_guide"]];
    [_headView addSubview:titleImgView];
    [titleImgView release];
    
    
    //书签:
    UIButton *button_bookmark = [UIButton buttonWithType:UIButtonTypeCustom];
    button_bookmark.frame = CGRectMake(280 - 80/2 - 14/2, positionY_button_bookmark, 80/2, 80/2);
    [button_bookmark setBackgroundImage:[UIImage imageNamed:@"btn_bookmark"] forState:UIControlStateNormal];
    [button_bookmark addTarget:self action:@selector(clickBookmarkButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:button_bookmark];
    
    
    //搜索:
    UIButton *button_search = [UIButton buttonWithType:UIButtonTypeCustom];
    button_search.frame = CGRectMake(280, positionY_button_search, 80/2, 80/2);
    button_search.backgroundColor = [UIColor clearColor];
    [button_search setBackgroundImage:[UIImage imageNamed:@"btn_search"] forState:UIControlStateNormal];
    [button_search addTarget:self action:@selector(clickSearchButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:button_search];
    
    
}
/**
 *  返回事件
 */
-(void)clickBackButton{
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)initAllButtonAndDownloadButton
{
    float positionY = ios7 ? 64 : 44;
    
    UIImage *image = [UIImage imageNamed:@"allGuide"];
    if(!_toolBar)
    {
        _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, positionY, 320, image.size.height+positionY_button_guideVC*2)];
    }
    _toolBar.hidden = YES;
    _toolBar.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:_toolBar belowSubview:_headView];
    
    
    if(!_button_all)
    {
        _button_all = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _button_all.backgroundColor = [UIColor clearColor];
    _button_all.frame = CGRectMake(0, positionY_button_guideVC, image.size.width, image.size.height);
    [_button_all setBackgroundImage:[UIImage imageNamed:@"highlight_allGuide"] forState:UIControlStateNormal];
    [_button_all addTarget:self action:@selector(getAllGuide) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_button_all];
    
    
    if(!_button_download)
    {
        _button_download = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    image = [UIImage imageNamed:@"download"];
    _button_download.frame = CGRectMake(_button_all.frame.origin.x+_button_all.frame.size.width, positionY_button_guideVC, image.size.width, image.size.height);
    [_button_download setBackgroundImage:image forState:UIControlStateNormal];
    [_button_download addTarget:self action:@selector(getDownloadGuide) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_button_download];
    
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, _button_download.frame.origin.y+_button_download.frame.size.height, 320, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:224/255. green:224/255. blue:224/255. alpha:1];
    [_toolBar addSubview:line];
    [line release];
    
    _toolBar.hidden = YES;
}
-(void)showtoolbar
{
    _toolBar.hidden = NO;
    _firstLoad_failed.hidden = YES;
}



#pragma mark -
#pragma mark --- 获取全部锦囊 / 已下载锦囊
-(void)getAllGuide
{
    [self.view hideToast];
    
    if(_allGuideVC) //initFailedView后_allGuideVC被置为空.
    {
        NSLog(@"  _allGuideVC  已存在～～～");
        
        
        [_button_all setBackgroundImage:[UIImage imageNamed:@"highlight_allGuide"] forState:UIControlStateNormal];
        [_button_download setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        _button_all.selected = YES;
        _button_download.selected = NO;
        
        
        [self showtoolbar];
        _allGuideVC.view.hidden = NO;
        _allGuideVC.currentVC = self.currentVC;
        [self.view insertSubview:_allGuideVC.view belowSubview:_toolBar];
        _selectedView_state = allGuide_state;
        [_allGuideVC getData];
        
    }
    
    else
    {
        if(_button_all.selected)
        {
            return;
        }
        
        NSLog(@"  _allGuideVC  不存在");
        
        
        [MobClick beginLogPageView:@"全部锦囊页"];
        [MobClick endLogPageView:@"已下载锦囊页"];
        
        [_button_all setBackgroundImage:[UIImage imageNamed:@"highlight_allGuide"] forState:UIControlStateNormal];
        [_button_download setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        _button_all.selected = YES;
        _button_download.selected = NO;
        
        
        _allGuideVC = [[AllGuideViewController alloc] init];
        _allGuideVC.view.hidden = NO;
        _allGuideVC.currentVC = self.currentVC;
        [self.view insertSubview:_allGuideVC.view belowSubview:_toolBar];
        _selectedView_state = allGuide_state;
        [_allGuideVC getData];

    }
}
-(void)getDownloadGuide
{
    [self.view hideToast];
    
    if(_downloadVC)
    {
        if(_button_download.selected)
        {
            return;
        }
        
        _downloadVC.view.hidden = NO;
        _downloadVC.currentVC = self.currentVC;
        [self.view insertSubview:_downloadVC.view belowSubview:_toolBar];
        _selectedView_state = download_state;
        [_downloadVC freshDownloadAndDownloadingData];
        
        [_button_all setBackgroundImage:[UIImage imageNamed:@"allGuide"] forState:UIControlStateNormal];
        [_button_download setBackgroundImage:[UIImage imageNamed:@"highlight_download"] forState:UIControlStateNormal];
        _button_download.selected = YES;
        _button_all.selected = NO;
        
        [_downloadVC performSelector:@selector(didShow) withObject:nil afterDelay:0.1];
    }
    
    else
    {
        if(_button_download.selected)
        {
            return;
        }
        
        [MobClick beginLogPageView:@"已下载锦囊页"];
        [MobClick endLogPageView:@"全部锦囊页"];
        
        [_button_all setBackgroundImage:[UIImage imageNamed:@"allGuide"] forState:UIControlStateNormal];
        [_button_download setBackgroundImage:[UIImage imageNamed:@"highlight_download"] forState:UIControlStateNormal];
        _button_download.selected = YES;
        _button_all.selected = NO;
        
        [self loadData_download];
    }
}
-(void)loadData_download
{
    if(_allGuideVC)
    {
        _allGuideVC.view.hidden = YES;
    }
    
    _downloadVC = [[DownloadViewController alloc] init];
    _downloadVC.view.hidden = NO;
    _downloadVC.currentVC = self.currentVC;
    [self.view insertSubview:_downloadVC.view belowSubview:_toolBar];
    _selectedView_state = download_state;
    
    [_downloadVC performSelector:@selector(didShow) withObject:nil afterDelay:0.2];
}
-(void)reloadTableView
{
    if(_selectedView_state == allGuide_state)
    {
        if(_allGuideVC)
        {
            [_allGuideVC reloadTableView];
            
            if([[QYGuideData sharedQYGuideData] flag_getAllNew] != YES) //已经getall最新的锦囊
            {
                [_allGuideVC initGuideDataFromServe];
            }
        }
    }
    else if (_selectedView_state == download_state)
    {
        if(_downloadVC)
        {
            [_downloadVC reloadTableView];
        }
    }
}



#pragma mark -
#pragma mark --- 搜索 & 书签
-(void)clickBookmarkButton:(id)sender
{
    BookMarkViewController *bookMarkVC = [[BookMarkViewController alloc] init];
    [self.currentVC.navigationController pushViewController:bookMarkVC animated:YES];
    [bookMarkVC release];
}
-(void)clickSearchButton:(id)sender
{
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [searchVC release];
    navVC.navigationBarHidden = YES;
    [self.currentVC presentViewController:navVC animated:YES completion:nil];
    [navVC release];
}




#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
