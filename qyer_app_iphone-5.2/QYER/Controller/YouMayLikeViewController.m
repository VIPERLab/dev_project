//
//  YouMayLikeViewController.m
//  QYER
//
//  Created by chenguanglin on 14-7-10.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "YouMayLikeViewController.h"
#import "BannerRootView.h"
#import "MayLikeBBSModel.h"
#import "MayLikeMyLastMinModel.h"
#import "MayLikePlaceModel.h"
#import "QYAPIClient.h"
//#import "LastMinuteDetailViewController.h"
#import "LastMinuteDetailViewControllerNew.h"
#import "BBSDetailViewController.h"
#import "TSDetailViewController.h"
#import "MobClick.h"

#define navigationBarHight      (ios7 ? (44 + 20) : 44)

@interface YouMayLikeViewController ()<BannerRootViewDelegate, UIScrollViewDelegate>
/**
 *  目的地模型数组
 */
@property (nonatomic, strong) NSArray *placeModelArray;
/**
 *  游记模型数组
 */
@property (nonatomic, strong) NSArray *BBSModelArray;
/**
 *  折扣模型数组
 */
@property (nonatomic, strong) NSArray *myLastMinModelArray;
/**
 *  返回按钮
 */
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIScrollView *rootScrollView;

@property (nonatomic, strong) NSMutableArray *bannerViewArray;

@property (nonatomic, strong) NSMutableArray *marginLineArray;
/**
 *  tap开关防止多线程操作
 */
@property (nonatomic, assign) BOOL tapFlag;
@end

@implementation YouMayLikeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)setYouMayLikeDict:(NSDictionary *)YouMayLikeDict{
    _YouMayLikeDict = YouMayLikeDict;
    
    _placeModelArray = [YouMayLikeDict objectForKey:@"subject"];
    _BBSModelArray = [YouMayLikeDict objectForKey:@"trip"];
    _myLastMinModelArray = [YouMayLikeDict objectForKey:@"discount"];
    
    NSMutableArray *placeModelArray = [NSMutableArray array];
    for (NSDictionary *dict in _placeModelArray) {
        MayLikePlaceModel *placeModel = [MayLikePlaceModel placeModeWithDict:dict];
        [placeModelArray addObject:placeModel];
    }
    _placeModelArray = placeModelArray;
    
    NSMutableArray *BBSModelArray = [NSMutableArray array];
    for (NSDictionary *dict in _BBSModelArray) {
        MayLikeBBSModel *BBSModel = [MayLikeBBSModel BBSModeWithDict:dict];
        [BBSModelArray addObject:BBSModel];
    }
    _BBSModelArray = BBSModelArray;
    
    NSMutableArray *discountModelArray = [NSMutableArray array];
    for (NSDictionary *dict in _myLastMinModelArray) {
        MayLikeMyLastMinModel *discountModel = [MayLikeMyLastMinModel ModeWithDict:dict];
        [discountModelArray addObject:discountModel];
    }
    _myLastMinModelArray = discountModelArray;

}
#pragma mark-
#pragma mark-----View的初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initRootView];
    
    [self initNavigationBar];
    
    [self initMainView];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    self.tapFlag = true;
}

/**
 *  初始化主View
 */
-(void)initMainView
{
    CGFloat rootScrollViewH = 728;
    _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, navigationBarHight, self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height - navigationBarHight)];
    _rootScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, rootScrollViewH);
    _rootScrollView.delegate = self;
    _rootScrollView.showsVerticalScrollIndicator = NO;
    _rootScrollView.contentInset = ios7 ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, 0, 20, 0);
    [self.view addSubview:_rootScrollView];
    
    _bannerViewArray = [NSMutableArray array];
    _marginLineArray = [NSMutableArray array];
    
    CGFloat placeViewX = 0;
    CGFloat placeViewY = 0;
    CGFloat placeViewW = 320;
    CGFloat placeViewH = 221 + 2;
    
    if (self.placeModelArray.count > 0) {
        BannerRootView *placeBannerView = [[BannerRootView alloc] initWithFrame:CGRectMake(placeViewX, placeViewY, placeViewW, placeViewH)];
        
        UIView *marginline1 = [[UIView alloc] initWithFrame:CGRectMake(0, 221, placeViewW, 2)];
        marginline1.backgroundColor = [UIColor whiteColor];
        [placeBannerView addSubview:marginline1];
        [_marginLineArray addObject:marginline1];
        
        placeBannerView.type = BannerTypePlace;
        placeBannerView.delegate = self;
        //传递数据
        placeBannerView.mayLikePlaceModelArray = [self placeModelArray];
        [_rootScrollView addSubview:placeBannerView];
        [_bannerViewArray addObject:placeBannerView];
    }else{
        rootScrollViewH -= placeViewH;
        placeViewH = 0;
    }
    
    CGFloat bbsViewX = 0;
    CGFloat bbsViewY = placeViewY + placeViewH;
    CGFloat bbsViewW = placeViewW;
    CGFloat bbsViewH = 197 + 2;
    if (self.BBSModelArray.count > 0) {
        BannerRootView *bbsBannerView = [[BannerRootView alloc] initWithFrame:CGRectMake(bbsViewX, bbsViewY, bbsViewW, bbsViewH)];
        
        UIView *marginline2 = [[UIView alloc] initWithFrame:CGRectMake(0, 197, bbsViewW, 2)];
        marginline2.backgroundColor = [UIColor whiteColor];
        [bbsBannerView addSubview:marginline2];
        [_marginLineArray addObject:marginline2];
        
        bbsBannerView.type = BannerTypeBBS;
        bbsBannerView.delegate = self;
        //传递数据
        bbsBannerView.mayLikeBBSModelArray = [self BBSModelArray];
        [_rootScrollView addSubview:bbsBannerView];
        [_bannerViewArray addObject:bbsBannerView];
    }else{
        rootScrollViewH -= bbsViewH;
        bbsViewH = 0;
    }
    
    CGFloat myLastMinViewX = 0;
    CGFloat myLastMinViewY = bbsViewY + bbsViewH;
    CGFloat myLastMinViewW = placeViewW;
    CGFloat myLastMinViewH = 306 + 2;
    if (self.myLastMinModelArray.count > 0) {
        BannerRootView *myLastMinBannerView = [[BannerRootView alloc] initWithFrame:CGRectMake(myLastMinViewX, myLastMinViewY, myLastMinViewW, myLastMinViewH)];
        
        UIView *marginline3 = [[UIView alloc] initWithFrame:CGRectMake(0, 306, bbsViewW, 2)];
        marginline3.backgroundColor = [UIColor whiteColor];
        [myLastMinBannerView addSubview:marginline3];
        [_marginLineArray addObject:marginline3];
        
        myLastMinBannerView.type = BannerTypeMyLastMin;
        myLastMinBannerView.delegate = self;
        //传递数据
        myLastMinBannerView.mayLikeMyLastMinModelArray = self.myLastMinModelArray;
        [_rootScrollView addSubview:myLastMinBannerView];
        [_bannerViewArray addObject:myLastMinBannerView];
    }else{
        rootScrollViewH -= myLastMinViewH;
    }
    
    if (rootScrollViewH < ([UIScreen mainScreen].bounds.size.height - navigationBarHight)) {
        rootScrollViewH = [UIScreen mainScreen].bounds.size.height - navigationBarHight + 1;
    }
    _rootScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, rootScrollViewH);
    _rootScrollView.backgroundColor = [[self.bannerViewArray lastObject] backgroundColor];
    [[self.marginLineArray lastObject] setHidden:YES];
}

/**
 *  初始化导航栏
 */
-(void)initNavigationBar
{
    UIView *navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, navigationBarHight)];
    navigationBar.backgroundColor = RGB(85, 206, 199);
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor = [UIColor clearColor];
    CGFloat backButtonY = (ios7 ? 20 : 0);
    backButton.frame = CGRectMake(0, backButtonY, 40, 40);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar addSubview:backButton];
    
    CGFloat titleLableY = (ios7 ? 27 : 8);
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(80, titleLableY, 160, 30)];
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.text = @"智能推荐";
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.textColor = [UIColor whiteColor];
    titleLable.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    [navigationBar addSubview:titleLable];
    [self.view addSubview:navigationBar];
    
}
/**
 *  初始化根View
 */
-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor whiteColor];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
}
/**
 *  返回按钮的点击
 */
-(void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-
#pragma mark-----BannerRootView的代理

- (void)DiscountClick:(long)ID
{
    if(self.tapFlag){
        [MobClick event:@"youLikeClickDisc"];
        
        LastMinuteDetailViewControllerNew *lastMinuteDetailVC = [[LastMinuteDetailViewControllerNew alloc] init];
        lastMinuteDetailVC.lastMinuteId = ID;
        lastMinuteDetailVC.source = NSStringFromClass([self class]);
        [self.navigationController pushViewController:lastMinuteDetailVC animated:YES];
        
        self.tapFlag = false;
    }
}

- (void)tripClick:(NSString *)viewURL
{
    if(self.tapFlag){
        [MobClick event:@"youLikeClickJournal"];
        BBSDetailViewController * bbsDetailVC = [[BBSDetailViewController alloc]init];
        bbsDetailVC.bbsAllUserLink = viewURL;
        bbsDetailVC.source = NSStringFromClass([self class]);
        [self.navigationController pushViewController:bbsDetailVC animated:YES];
        self.tapFlag = false;
    }
}

- (void)placeClick:(long)ID
{
    if(self.tapFlag){
        [MobClick event:@"youLikeClickMcGuide"];
        TSDetailViewController *TSDetailVC = [[TSDetailViewController alloc] init];
        TSDetailVC.ID = [NSString stringWithFormat:@"%ld",ID];
        TSDetailVC.source = NSStringFromClass([self class]);
        [self.navigationController pushViewController:TSDetailVC animated:YES];
        self.tapFlag = false;
    }
}

#pragma mark-
#pragma mark-----UIScrollView的代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    if (scrollView.contentOffset.y > 0) {
        scrollView.backgroundColor = [[self.bannerViewArray lastObject] backgroundColor];
    }else{
        scrollView.backgroundColor = [[self.bannerViewArray firstObject] backgroundColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
