//
//  CountryViewController.m
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "CountryViewController.h"
#import "CityListViewController.h"
#import "TravelsListViewController.h"
#import "RecomTravelViewController.h"
#import "AllSpotViewController.h"
#import "HotDiscountViewController.h"
#import "HotelListViewController.h"
#import "UsefulGuideController.h"

#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "PoiPhotoBrowserViewController.h"
#import "GuideListViewController.h"

#import "GoogleMapViewController.h"
#import "TravelSubjectViewController.h"
//#import "LastMinuteDetailViewController.h"
#import "LastMinuteDetailViewControllerNew.h"
#import "BBSDetailViewController.h"

#import "CityLoginViewController.h"

@interface CountryViewController ()

@end

@implementation CountryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString *string;
    if (_type == 1) {
        
        string = @"国家详情";
        
    }else {
    
        string = @"城市详情";
    }
    
    [MobClick beginLogPageView:string];
    
    
    if (_topScrollView && _photosArray.count >0 && [[_photosArray objectAtIndex:0]isKindOfClass:[NSString class]]) {
        [_topScrollView reloadData];
    }
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
        
    NSString *string;
    if (_type == 1) {
        
        string = @"国家详情";
        
    }else{
        string = @"城市详情";
    }
    
    [MobClick endLogPageView:string];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    if (_topScrollView) {
        [_topScrollView destroyTimer];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate * shareDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    MLNavigationController * rootVC = shareDelegate._homeNavVC;
    [rootVC setCanDragBack:NO];
    [self performSelector:@selector(setNavigationCanGoBack) withObject:nil afterDelay:1.0];
    
    
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue];
    //未登录,提示登录
    if (isLogin == NO) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
    }
    
    _rightButton.enabled = NO;
    
    self.view.backgroundColor = RGB(231, 242, 248);
    
    float height_naviViewHeight = (ios7 ? 20+44 : 44);
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, height_naviViewHeight, 320, self.view.frame.size.height - height_naviViewHeight - 44 )];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setContentSize:CGSizeMake(320, 1500)];
    [self.view addSubview:_scrollView];
    
    _bottomImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, 320, 44)];
    [_bottomImgView setBackgroundColor:RGB(69,79,97)];
    [_bottomImgView setUserInteractionEnabled:YES];
    [_bottomImgView setHidden:YES];
    [self.view addSubview:_bottomImgView];
    
    
    if (!ios7) {
        [_scrollView setFrame:CGRectMake(0, height_naviViewHeight, 320, self.view.frame.size.height - height_naviViewHeight - 44 -20)];
        [_bottomImgView setFrame:CGRectMake(0, self.view.frame.size.height - 44 -20, 320, 44)];
    }
    
    _goneBtn = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    [_goneBtn setBackgroundColor:[UIColor clearColor]];
    [_goneBtn setBackgroundImage:[UIImage imageNamed:@"place_Gone@2x"] forState:UIControlStateNormal];
    [_goneBtn setBackgroundImage:[UIImage imageNamed:@"place_Gone_hl@2x"] forState:UIControlStateSelected];
    [_goneBtn setFrame:CGRectMake(0, 0 , 160, 44)];
    [_goneBtn addTarget:self action:@selector(goneBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomImgView addSubview:_goneBtn];
    
    
    _wannaGoBtn = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    [_wannaGoBtn setBackgroundColor:[UIColor clearColor]];
    [_wannaGoBtn setBackgroundImage:[UIImage imageNamed:@"place_wannaGo@2x"] forState:UIControlStateNormal];
    [_wannaGoBtn setBackgroundImage:[UIImage imageNamed:@"place_wannaGo_hl@2x"] forState:UIControlStateSelected];
    [_wannaGoBtn setFrame:CGRectMake(160, 0 , 160, 44)];
    [_wannaGoBtn addTarget:self action:@selector(wannagoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomImgView addSubview:_wannaGoBtn];

    
    _topScrollView = [[XLCycleScrollView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 195)];
    _topScrollView.tapEnabled = NO;
    [_topScrollView setHidden:YES];
    [_topScrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView addSubview:_topScrollView];
    [_scrollView sendSubviewToBack:_scrollView];
    
    
    _shadeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 194)];
    _shadeImageView.image = [UIImage imageNamed:@"shade_name"];
    _shadeImageView.hidden = YES;
    [_scrollView addSubview:_shadeImageView];
    
    
    _chinaNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 10, 310, 30)];
    _chinaNameLabel.backgroundColor = [UIColor clearColor];
    _chinaNameLabel.textAlignment = NSTextAlignmentLeft;
    _chinaNameLabel.font = [UIFont fontWithName:Default_Font size:30.0];
    _chinaNameLabel.textColor = [UIColor whiteColor];
    _chinaNameLabel.shadowColor = [UIColor blackColor];
    _chinaNameLabel.shadowOffset = CGSizeMake(0, 1);
    [_scrollView addSubview:_chinaNameLabel];
    
    
    _englishNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 44, 310, 37)];
    _englishNameLabel.textAlignment = NSTextAlignmentLeft;
    _englishNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:30.0];
    _englishNameLabel.textColor = [UIColor whiteColor];
    _englishNameLabel.shadowColor = [UIColor blackColor];
    _englishNameLabel.shadowOffset = CGSizeMake(0, 1);
    _englishNameLabel.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:_englishNameLabel];
    
    
    if (!IS_IOS7) {
        _chinaNameLabel.frame = CGRectMake(8, 10, 310, 43);
        _englishNameLabel.frame = CGRectMake(12, 40, 300, 35);
    }
    
    
    _photosArray = [[NSMutableArray alloc]init];
    _infoDictionary = [[NSDictionary alloc]init];
    
    _arrGates = [[NSMutableArray alloc]initWithCapacity:0];
    _arrCities = [[NSMutableArray alloc]initWithCapacity:0];
    _arrDiscounts = [[NSMutableArray alloc]initWithCapacity:0];
    _arrThreads = [[NSMutableArray alloc]initWithCapacity:0];
    
    
    _planToStatus = NO;
    _beenToStatus = NO;
    
    if ( _key && _key != 0 ) {
        if (_type == 1 || _type == 2) {
            [self requestDataFromServer];
        }
    }
    
    else{
        [self performSelector:@selector(popBack) withObject:nil afterDelay:1.0f];
    }

}

/**
 *  从网络请求数据
 */
-(void)requestDataFromServer
{
    if (isNotReachable) {
        
        [super setNotReachableView:YES];
        return;
    }else{
        
        [super setNotReachableView:NO];
    }
    
    [self.view makeToastActivity];
    
    
    //类型为国家
    if (_type == 1) {
        
        [[QYAPIClient sharedAPIClient]getCountryDataByCountryId:_key success:^(NSDictionary *dic)
         {
             [self.view hideToastActivity];
             [super setNotReachableView:NO];

             int status = [[dic objectForKey:@"status"]integerValue];
             
             if (status == 1) {
                 
                 if ([[dic objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                     _infoDictionary = [(NSDictionary *)[dic objectForKey:@"data"]retain];
                     [self setSomeInfo];
                     [self createUI];
                 }
                 else{
                     [self performSelector:@selector(popBack) withObject:nil afterDelay:0.5f];
                 }
             }
             
             else{
                 
                 NSString * info = [NSString stringWithFormat:@"%@",[dic objectForKey:@"info"]];
                 [self.view makeToast:info duration:1.2f position:@"center" isShadow:NO];
                 [self performSelector:@selector(popBack) withObject:nil afterDelay:1.5f];
             }
        
         } failed:^{
            
             [self.view hideToastActivity];
             [super setNotReachableView:YES];
             
        }];
        
        
    }
    
    
    //类型为城市
    else if(_type == 2){

        [[QYAPIClient sharedAPIClient]getCityDataByCityId:_key success:^(NSDictionary *dic) {
           
            [self.view hideToastActivity];
            [super setNotReachableView:NO];
            
            int status = [[dic objectForKey:@"status"]integerValue];
            
            if (status == 1) {
                
                if ([[dic objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                    _infoDictionary = [(NSDictionary *)[dic objectForKey:@"data"]retain];
                    
                    [self setSomeInfo];
                    
                    [self createUI];
                }
                
                else{
                    [self performSelector:@selector(popBack) withObject:nil afterDelay:0.5f];
                }
            }
            
            //错误信息
            else{
                NSString * info = [NSString stringWithFormat:@"%@",[dic objectForKey:@"info"]];
                [self.view makeToast:info duration:1.2f position:@"center" isShadow:NO];
                [self performSelector:@selector(popBack) withObject:nil afterDelay:1.5f];
            }
            
            
            
        } failed:^{
            
            [self.view hideToastActivity];
            [super setNotReachableView:YES];
        }];
   
    }
    
}


//设置标题照片等信息
-(void)setSomeInfo
{
    NSString *name;
    
    if ([[_infoDictionary objectForKey:@"chinesename"] isKindOfClass:[NSString class]] && ![[_infoDictionary objectForKey:@"chinesename"] isEqualToString:@""]) {
        name = [_infoDictionary objectForKey:@"chinesename"];
        
        [_chinaNameLabel setText:name];
    }
    
    else{
        name = [_infoDictionary objectForKey:@"englishname"];
    }
    
    [_titleLabel setText:name];
    
    if ([[_infoDictionary objectForKey:@"englishname"] isKindOfClass:[NSString class]] && ![[_infoDictionary objectForKey:@"englishname"] isEqualToString:@""] ) {
        [_englishNameLabel setText:[_infoDictionary objectForKey:@"englishname"]];
    }
    
    NSArray * photoArray = [_infoDictionary objectForKey:@"photos"];
    
    NSLog(@"~~~~~~ %d ~~~~~~~~",photoArray.count);
    
    for (int i = 0; i <photoArray.count; i++) {
        NSString * photoURL = [NSString stringWithFormat:@"%@",[photoArray objectAtIndex:i]];
        [_photosArray addObject:photoURL];
    }
    
    _topScrollView.delegate = self;
    _topScrollView.datasource = self;
    
    [_topScrollView setHidden:NO];
    [_topScrollView reloadData];
    
}


-(void)createUI{

    BOOL wantGo = [[_infoDictionary objectForKey:@"planto"]boolValue];  //判断想去
    BOOL alreadyGone = [[_infoDictionary objectForKey:@"beento"]boolValue]; //判断已去过
    
    
    _planToStatus = wantGo;
    _beenToStatus = alreadyGone;
    
    
    [_wannaGoBtn setSelected:_planToStatus];
    [_goneBtn setSelected:_beenToStatus];
    
    
    
    
    if (_type == 1) {
        
        //国家下加入地图按钮
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"地图button_icon.png"] forState:UIControlStateNormal];
        _rightButton.enabled = YES;
        
        [_rightButton setHidden:NO];
        [_shadeImageView setHidden:NO];
        [_bottomImgView setHidden:NO];

        
        float _totalScrollHeight = 170;   //计算ScrollView整体高度
        
        
        
        NSMutableDictionary *muDict1 = [NSMutableDictionary dictionary];
        [muDict1 setObject:@"guide" forKey:@"title"];
        [_arrGates insertObject:muDict1 atIndex:0];
        
        NSMutableDictionary *muDict2 = [NSMutableDictionary dictionary];
        [muDict2 setObject:@"summary" forKey:@"title"];
        [_arrGates addObject:muDict2];
        
        NSMutableDictionary *muDict3 = [NSMutableDictionary dictionary];
        [muDict3 setObject:@"tripList" forKey:@"title"];
        [_arrGates addObject:muDict3];
        
        NSMutableDictionary *muDict4 = [NSMutableDictionary dictionary];
        [muDict4 setObject:@"recommandPlan" forKey:@"title"];
        [_arrGates addObject:muDict4];
        
        BOOL hasGuide = [[_infoDictionary objectForKey:@"has_guide"]boolValue];//有相关锦囊
        BOOL hasSummary = [[_infoDictionary objectForKey:@"overview_url"] isKindOfClass:[NSString class]] && ![[_infoDictionary objectForKey:@"overview_url"] isEqualToString:@""];//有实用贴士网页
        BOOL hasTripList = [[_infoDictionary objectForKey:@"has_trip_list"] boolValue];//有旅行专题(微锦囊)
        BOOL hasRecommandPlan = [[_infoDictionary objectForKey:@"has_plan"] boolValue];//有推荐行程
        
        
//        if (hasGuide) {
//            NSMutableDictionary *muDict = [NSMutableDictionary dictionary];
//            [muDict setObject:@"guide" forKey:@"title"];
//            [_arrGates insertObject:muDict atIndex:0];
//        }
//        if (hasSummary) {
//            NSMutableDictionary *muDict = [NSMutableDictionary dictionary];
//            [muDict setObject:@"summary" forKey:@"title"];
//            [_arrGates addObject:muDict];
//        }
//        if (hasTripList) {
//            NSMutableDictionary *muDict = [NSMutableDictionary dictionary];
//            [muDict setObject:@"tripList" forKey:@"title"];
//            [_arrGates addObject:muDict];
//        }
//        if (hasRecommandPlan) {
//            NSMutableDictionary *muDict = [NSMutableDictionary dictionary];
//            [muDict setObject:@"recommandPlan" forKey:@"title"];
//            [_arrGates addObject:muDict];
//        }

        
        for (int i = 0; i<_arrGates.count; i++) {
            
            NSMutableDictionary *tempDict = [_arrGates objectAtIndex:i];

            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(80 * i, 195 , 80, 76)];
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn setExclusiveTouch:YES];
            
            if ([[tempDict objectForKey:@"title"] isEqualToString:@"guide"]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_guide@2x"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_guide_hl@2x"] forState:UIControlStateHighlighted];
                
                if (hasGuide ==NO) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"disabled_book@2x"] forState:UIControlStateNormal];
                }
                [btn setTag:8001];
            }
            if ([[tempDict objectForKey:@"title"] isEqualToString:@"summary"]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_tips@2x"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_tips_hl@2x"] forState:UIControlStateHighlighted];
                
                if (hasSummary == NO) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"disabled_tips@2x"] forState:UIControlStateNormal];
                }
                [btn setTag:8002];
            }
            if ([[tempDict objectForKey:@"title"] isEqualToString:@"tripList"]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_trip@2x"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_trip_hl@2x"] forState:UIControlStateHighlighted];
                
                if (hasTripList == NO) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"disabled_trip@2x"] forState:UIControlStateNormal];
                }
                [btn setTag:8003];
            }
            if ([[tempDict objectForKey:@"title"] isEqualToString:@"recommandPlan"]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_plan@2x"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_plan_hl@2x"] forState:UIControlStateHighlighted];
                
                if (hasRecommandPlan == NO) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"disabled_plan@2x"] forState:UIControlStateNormal];
                }
                [btn setTag:8004];
            }
            
            [btn addTarget:self action:@selector(bigBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:btn];
        }
        
        
        int fourBtnCount = _arrGates.count;
        
        if (fourBtnCount == 0) {
            _totalScrollHeight = 205;
        }
        else{
            _totalScrollHeight = 195 + 76;
        }

        
        UIImageView * cityBackGroundImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _totalScrollHeight, 320, 180)];
        [cityBackGroundImgView setBackgroundColor:[UIColor whiteColor]];
        [cityBackGroundImgView setUserInteractionEnabled:YES];
        [_scrollView addSubview:cityBackGroundImgView];
        [cityBackGroundImgView release];

        //上部的分割线
        UIImageView * topLine = [[UIImageView alloc] init];
        topLine.frame = CGRectMake(0, 0, UIScreenWidth, 1);
        topLine.image = [UIImage imageNamed:@"line1"];
        [cityBackGroundImgView addSubview:topLine];
        [topLine release];
        
        //下部的分割线
        UIImageView * bottomLine = [[UIImageView alloc] init];
        bottomLine.frame = CGRectMake(0, 179.5, UIScreenWidth, 1);
        bottomLine.image = [UIImage imageNamed:@"line1"];
        [cityBackGroundImgView addSubview:bottomLine];
        [bottomLine release];
        
        
        UILabel * countryNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 210, 20)];
        if(!ios7)
        {
            countryNameLabel.frame = CGRectMake(10, 13, 210, 26);
        }
        [countryNameLabel setBackgroundColor:[UIColor clearColor]];
        [countryNameLabel setTextAlignment:NSTextAlignmentLeft];
        [countryNameLabel setTextColor:RGB(68, 68, 68)];
        [countryNameLabel setText:[NSString stringWithFormat:@"%@城市",_titleLabel.text]];
        //[countryNameLabel setFont:[UIFont systemFontOfSize:17]];
        [countryNameLabel setFont:[UIFont fontWithName:Default_Font size:17]];
        [cityBackGroundImgView addSubview:countryNameLabel];
        [countryNameLabel release];
        
        
        //全部城市的数组
        _arrCities = (NSMutableArray *)[_infoDictionary objectForKey:@"hot_city"];

        if (_arrCities.count >= 6) {
            UIButton * showAllCityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [showAllCityBtn setFrame:CGRectMake(230, 0, 80, 40)];
            [showAllCityBtn setExclusiveTouch:YES];
            [showAllCityBtn setBackgroundColor:[UIColor clearColor]];
            [showAllCityBtn setBackgroundImage:[UIImage imageNamed:@"countryCityShowAll@2x"] forState:UIControlStateNormal];
            [showAllCityBtn addTarget:self action:@selector(showAllCity:) forControlEvents:UIControlEventTouchUpInside];
            [cityBackGroundImgView addSubview:showAllCityBtn];
        }
        
        for (int i = 0; i<_arrCities.count; i++) {
            NSMutableDictionary *tempDict = [_arrCities objectAtIndex:i];
            
            NSString * photoURL = [NSString stringWithFormat:@"%@",[tempDict objectForKey:@"photo"]];
            
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(10 + i%3 * 103, 40 + i/3 * 69, 94, 60)];
            [btn setBackgroundColor:[UIColor whiteColor]];
            [btn setExclusiveTouch:YES];
            [btn setTag:[[tempDict objectForKey:@"id"] integerValue]];
            [btn addTarget:self action:@selector(cityBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btn setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"default_ls_back.png"]];
            
            UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 40, 94, 20)];
            [backView setBackgroundColor:[UIColor clearColor]];
            [btn addSubview:backView];
            [backView release];
            
            UIView * viewww = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 94, 20)];
            [viewww setBackgroundColor:[UIColor blackColor]];
            [viewww setAlpha:0.45];
            [backView addSubview:viewww];
            [viewww release];
            
            UILabel * nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 84, 20)];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setText:[tempDict objectForKey:@"name"]];
            [nameLabel setTextColor:[UIColor whiteColor]];
            [nameLabel setTextAlignment:NSTextAlignmentLeft];
            [nameLabel setFont:[UIFont systemFontOfSize:12]];
            [nameLabel setAlpha:0.9];
            [nameLabel setShadowColor:[UIColor blackColor]];
            [nameLabel setShadowOffset:CGSizeMake(1, 0)];
            [backView addSubview:nameLabel];
            [nameLabel release];
            
            [cityBackGroundImgView addSubview:btn];
        }
        
        int citiesCount = _arrCities.count;
        
        if (citiesCount >= 0 && citiesCount <= 3) {
            
            [cityBackGroundImgView setFrame:CGRectMake(0, _totalScrollHeight, 320, 110)];

            _totalScrollHeight = _totalScrollHeight + 110 + 10;
            
        }
        if (citiesCount > 3) {
            [cityBackGroundImgView setFrame:CGRectMake(0, _totalScrollHeight, 320, 180)];

            _totalScrollHeight = _totalScrollHeight + 180 + 10;
        }
        
        //全部折扣的数组
        _arrDiscounts = (NSMutableArray *)[_infoDictionary objectForKey:@"new_discount"];

        //判断是否有相关折扣
        if (![_arrDiscounts isEqual:[NSNull null]] && _arrDiscounts.count > 0) {
            
            UIImageView * discountBackGroundImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _totalScrollHeight, 320, 380)];
            [discountBackGroundImgView setBackgroundColor:[UIColor whiteColor]];
            [discountBackGroundImgView setUserInteractionEnabled:YES];
            [_scrollView addSubview:discountBackGroundImgView];
            [discountBackGroundImgView release];

            
            //上部的分割线
            UIImageView * topLine = [[UIImageView alloc] init];
            topLine.frame = CGRectMake(0, 0, UIScreenWidth, 1);
            topLine.image = [UIImage imageNamed:@"line1"];
            [discountBackGroundImgView addSubview:topLine];
            [topLine release];
            
            //下部的分割线
            UIImageView * bottomLine = [[UIImageView alloc] init];
            bottomLine.frame = CGRectMake(0, 379.5, UIScreenWidth, 1);
            bottomLine.image = [UIImage imageNamed:@"line1"];
            [discountBackGroundImgView addSubview:bottomLine];
            [bottomLine release];

            
            UILabel * discountLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 160, 20)];
            if(!ios7)
            {
                discountLabel.frame = CGRectMake(10, 13, 160, 26);
            }
            [discountLabel setBackgroundColor:[UIColor clearColor]];
            [discountLabel setTextAlignment:NSTextAlignmentLeft];
            [discountLabel setTextColor:RGB(68, 68, 68)];
            [discountLabel setText:@"最新折扣"];
            //[discountLabel setFont:[UIFont systemFontOfSize:17]];
            [discountLabel setFont:[UIFont fontWithName:Default_Font size:17]];
            [discountBackGroundImgView addSubview:discountLabel];
            [discountLabel release];
            
            if (_arrDiscounts.count >= 4) {
                UIButton * showDiscountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [showDiscountBtn setFrame:CGRectMake(230, 0, 80, 40)];
                [showDiscountBtn setBackgroundColor:[UIColor clearColor]];
                [showDiscountBtn setBackgroundImage:[UIImage imageNamed:@"countryCityShowAll@2x"] forState:UIControlStateNormal];
                [showDiscountBtn addTarget:self action:@selector(showAllDiscount:) forControlEvents:UIControlEventTouchUpInside];
                [discountBackGroundImgView addSubview:showDiscountBtn];
            }
            
            for (int i = 0; i<_arrDiscounts.count; i++) {
                
                NSMutableDictionary *tempDict = [_arrDiscounts objectAtIndex:i];
                
                CountryCityDiscountView * discountView = [[CountryCityDiscountView alloc]initWithFrame:CGRectMake(160 * (i%2), 33 + i/2 * 175, 160, 176)];
                [discountView setDelegate:self];
                [discountView setDiscountInfo:tempDict];
                [discountBackGroundImgView addSubview:discountView];
                [discountView release];
            }
            
            int discountsCount = _arrDiscounts.count;
            
            UIImageView * horizonLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 208, 320, 1)];
            [horizonLine setBackgroundColor:[UIColor clearColor]];
            [horizonLine setImage:[UIImage imageNamed:@"countrydiscount_horizon@2x"]];
            [discountBackGroundImgView addSubview:horizonLine];
            [horizonLine release];
            
            UIImage * verizon = [UIImage imageNamed:@"countrydiscount_verizon@2x"];
            verizon = [verizon stretchableImageWithLeftCapWidth:0 topCapHeight:20];
            
            UIImageView * verizonLine = [[UIImageView alloc]initWithFrame:CGRectMake(160, 40, 1, 80)];
            [verizonLine setBackgroundColor:[UIColor clearColor]];
            [verizonLine setImage:verizon];
            [discountBackGroundImgView addSubview:verizonLine];
            [verizonLine release];
            
            if (discountsCount <= 2) {
                [verizonLine setFrame:CGRectMake(160, 40, 1, 168)];
                [discountBackGroundImgView setFrame:CGRectMake(0, _totalScrollHeight, 320, 208)];
                
                [bottomLine setFrame:CGRectMake(0, 207.5, UIScreenWidth, 1)];
                
                _totalScrollHeight = _totalScrollHeight + 208 + 10;
            }
            else{
                [verizonLine setFrame:CGRectMake(160, 40, 1, 344)];
                [discountBackGroundImgView setFrame:CGRectMake(0, _totalScrollHeight, 320, 384)];
                
                [bottomLine setFrame:CGRectMake(0, 383.5, UIScreenWidth, 1)];

                _totalScrollHeight = _totalScrollHeight + 384 + 10;
            }
        }
        
        
        _arrThreads = (NSMutableArray *)[_infoDictionary objectForKey:@"new_trip"];
        
        if (![_arrThreads isEqual:[NSNull null]] && _arrThreads.count >0) {
            
            UIImageView * threadBackImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _totalScrollHeight, 320, 515)];
            [threadBackImgView setBackgroundColor:[UIColor whiteColor]];
            [threadBackImgView setUserInteractionEnabled:YES];
            [_scrollView addSubview:threadBackImgView];
            
            //上部的分割线
            UIImageView * topLine = [[UIImageView alloc] init];
            topLine.frame = CGRectMake(0, 0, UIScreenWidth, 1);
            topLine.image = [UIImage imageNamed:@"line1"];
            [threadBackImgView addSubview:topLine];
            [topLine release];
            
            //下部的分割线
            UIImageView * bottomLine = [[UIImageView alloc] init];
            bottomLine.frame = CGRectMake(0, 514.5, UIScreenWidth, 1);
            bottomLine.image = [UIImage imageNamed:@"line1"];
            [threadBackImgView addSubview:bottomLine];
            [bottomLine release];

            
            
            UILabel * threadLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 160, 20)];
            if(!ios7)
            {
                threadLabel.frame = CGRectMake(10, 13, 160, 26);
            }
            [threadLabel setBackgroundColor:[UIColor clearColor]];
            [threadLabel setTextAlignment:NSTextAlignmentLeft];
            [threadLabel setTextColor:RGB(68, 68, 68)];
            [threadLabel setText:@"新鲜好游记"];
            //[threadLabel setFont:[UIFont systemFontOfSize:17]];
            [threadLabel setFont:[UIFont fontWithName:Default_Font size:17]];
            [threadBackImgView addSubview:threadLabel];
            [threadLabel release];
            
            if (_arrThreads.count >= 5) {
                UIButton * showThreadsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [showThreadsBtn setFrame:CGRectMake(230, 0, 80, 40)];
                [showThreadsBtn setBackgroundColor:[UIColor clearColor]];
                [showThreadsBtn setBackgroundImage:[UIImage imageNamed:@"countryCityShowAll@2x"] forState:UIControlStateNormal];
                [showThreadsBtn addTarget:self action:@selector(showAllThreads:) forControlEvents:UIControlEventTouchUpInside];
                [threadBackImgView addSubview:showThreadsBtn];
            }
            
            for (int i = 0; i < _arrThreads.count; i++) {
                
                NSMutableDictionary *tempDict = [_arrThreads objectAtIndex:i];
                
                CountryCityThreadView * threadView = [[CountryCityThreadView alloc]initWithFrame:CGRectMake(0, 40 + i * 88, 320, 88)];
                [threadView setThreadInfo:tempDict];
                [threadView setDelegate:self];
                [threadBackImgView addSubview:threadView];
                [threadView release];
            }
            
            [threadBackImgView setFrame:CGRectMake(0, _totalScrollHeight, 320, 88 * _arrThreads.count + 40)];
            [threadBackImgView release];

            bottomLine.frame = CGRectMake(0, 88 * _arrThreads.count + 39.5, UIScreenWidth, 1);
            
            _totalScrollHeight = _totalScrollHeight + 88 * _arrThreads.count + 40;
        }
        
        [_scrollView setContentSize:CGSizeMake(320, _totalScrollHeight)];
    }
    
    
    if (_type == 2) {

        [_rightButton setHidden:YES];
        [_shadeImageView setHidden:NO];
        [_bottomImgView setHidden:NO];
        
        
        float _totalScrollHeight = 170;   //计算ScrollView整体高度
        
        NSMutableDictionary *muDict1 = [NSMutableDictionary dictionary];
        [muDict1 setObject:@"guide" forKey:@"title"];
        [_arrGates insertObject:muDict1 atIndex:0];
        
        NSMutableDictionary *muDict2 = [NSMutableDictionary dictionary];
        [muDict2 setObject:@"summary" forKey:@"title"];
        [_arrGates addObject:muDict2];
        
        NSMutableDictionary *muDict3 = [NSMutableDictionary dictionary];
        [muDict3 setObject:@"tripList" forKey:@"title"];
        [_arrGates addObject:muDict3];
        
        NSMutableDictionary *muDict4 = [NSMutableDictionary dictionary];
        [muDict4 setObject:@"recommandPlan" forKey:@"title"];
        [_arrGates addObject:muDict4];
        
        BOOL hasGuide = [[_infoDictionary objectForKey:@"has_guide"]boolValue];//有相关锦囊
        BOOL hasSummary = [[_infoDictionary objectForKey:@"overview_url"] isKindOfClass:[NSString class]] && ![[_infoDictionary objectForKey:@"overview_url"] isEqualToString:@""];//有实用贴士网页
        BOOL hasTripList = [[_infoDictionary objectForKey:@"has_trip_list"] boolValue];//有旅行专题(微锦囊)
        BOOL hasRecommandPlan = [[_infoDictionary objectForKey:@"has_plan"] boolValue];//有推荐行程
        for (int i = 0; i<_arrGates.count; i++) {
            
            NSMutableDictionary *tempDict = [_arrGates objectAtIndex:i];
            
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(80 * i, 195 , 80, 76)];
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn setExclusiveTouch:YES];
            
            if ([[tempDict objectForKey:@"title"] isEqualToString:@"guide"]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_guide@2x"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_guide_hl@2x"] forState:UIControlStateHighlighted];
                
                if (hasGuide == NO) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"disabled_book@2x"] forState:UIControlStateNormal];
                }
                [btn setTag:8001];
            }
            if ([[tempDict objectForKey:@"title"] isEqualToString:@"summary"]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_tips@2x"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_tips_hl@2x"] forState:UIControlStateHighlighted];
                
                if (hasSummary == NO) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"disabled_tips@2x"] forState:UIControlStateNormal];
                }
                [btn setTag:8002];
            }
            if ([[tempDict objectForKey:@"title"] isEqualToString:@"tripList"]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_trip@2x"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_trip_hl@2x"] forState:UIControlStateHighlighted];
                
                if (hasTripList == NO) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"disabled_trip@2x"] forState:UIControlStateNormal];
                }
                [btn setTag:8003];
            }
            if ([[tempDict objectForKey:@"title"] isEqualToString:@"recommandPlan"]) {
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_plan@2x"] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:@"detail_plan_hl@2x"] forState:UIControlStateHighlighted];
                
                if (hasRecommandPlan == NO) {
                    [btn setBackgroundImage:[UIImage imageNamed:@"disabled_plan@2x"] forState:UIControlStateNormal];
                }
                [btn setTag:8004];
            }
            
            [btn addTarget:self action:@selector(bigBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:btn];
        }
        
        
        int fourBtnCount = _arrGates.count;
        
        if (fourBtnCount == 0) {
            _totalScrollHeight = 205;
        }
        else{
            _totalScrollHeight = 195 + 76;
        }
        
        
        UIImageView * spotsBackGroundImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _totalScrollHeight, 320, 186)];
        [spotsBackGroundImgView setBackgroundColor:[UIColor whiteColor]];
        [spotsBackGroundImgView setUserInteractionEnabled:YES];
        [_scrollView addSubview:spotsBackGroundImgView];
        [spotsBackGroundImgView release];
        
        
        //上部的分割线
        UIImageView * topLine = [[UIImageView alloc] init];
        topLine.frame = CGRectMake(0, 0, UIScreenWidth, 1);
        topLine.image = [UIImage imageNamed:@"line1"];
        [spotsBackGroundImgView addSubview:topLine];
        [topLine release];
        
        //下部的分割线
        UIImageView * bottomLine = [[UIImageView alloc] init];
        bottomLine.frame = CGRectMake(0, 185.5, UIScreenWidth, 1);
        bottomLine.image = [UIImage imageNamed:@"line1"];
        [spotsBackGroundImgView addSubview:bottomLine];
        [bottomLine release];
        
        
        
        UILabel * spotNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 160, 20)];
        if(!ios7)
        {
            spotNameLabel.frame = CGRectMake(10, 13, 160, 26);
        }
        [spotNameLabel setBackgroundColor:[UIColor clearColor]];
        [spotNameLabel setTextAlignment:NSTextAlignmentLeft];
        [spotNameLabel setTextColor:RGB(68, 68, 68)];
        [spotNameLabel setText:@"旅行地"];
        //[spotNameLabel setFont:[UIFont systemFontOfSize:17]];
        [spotNameLabel setFont:[UIFont fontWithName:Default_Font size:17]];
        [spotsBackGroundImgView addSubview:spotNameLabel];
        [spotNameLabel release];
   
        
        UIImageView * horizonLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 39, 320, 1)];
        [horizonLine setBackgroundColor:[UIColor clearColor]];
        [horizonLine setImage:[UIImage imageNamed:@"countrydiscount_horizon@2x"]];
        [spotsBackGroundImgView addSubview:horizonLine];
        [horizonLine release];
        
        UIImageView * horizonLine1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 112, 320, 1)];
        [horizonLine1 setBackgroundColor:[UIColor clearColor]];
        [horizonLine1 setImage:[UIImage imageNamed:@"countrydiscount_horizon@2x"]];
        [spotsBackGroundImgView addSubview:horizonLine1];
        [horizonLine1 release];
        
        UIImage * verizon = [UIImage imageNamed:@"countrydiscount_verizon@2x"];
        verizon = [verizon stretchableImageWithLeftCapWidth:0 topCapHeight:20];
        UIImageView * verizonLine = [[UIImageView alloc]initWithFrame:CGRectMake(160, 40, 1, 146)];
        [verizonLine setBackgroundColor:[UIColor clearColor]];
        [verizonLine setImage:verizon];
        [spotsBackGroundImgView addSubview:verizonLine];
        [verizonLine release];
        
        
        for (int i = 0; i< 4; i++) {
            
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setExclusiveTouch:YES];
            [btn setBackgroundColor:[UIColor clearColor]];
            [btn setFrame:CGRectMake( i%2 * 160, 39 + i/2 * 73, 160, 73)];
            [btn setTag:9000 + i ];
            
            NSString * normal = [NSString stringWithFormat:@"city_icon_%d",i];
            NSString * hightLight = [NSString stringWithFormat:@"city_icon_%d_hl",i];

//            [btn setBackgroundImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
//            [btn setBackgroundImage:[UIImage imageNamed:hightLight] forState:UIControlStateHighlighted];
            [btn setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
//            [btn setImage:[UIImage imageNamed:hightLight] forState:UIControlStateHighlighted];
            
            [btn addTarget:self action:@selector(showSpot:) forControlEvents:UIControlEventTouchUpInside];
            
            [spotsBackGroundImgView addSubview:btn];
        }
        
        _totalScrollHeight = _totalScrollHeight + 186 + 10;
        
        
        //存在热门推荐酒店列表
        if ([[_infoDictionary objectForKey:@"selecthotel_url"] isKindOfClass:[NSString class]] && ![[_infoDictionary objectForKey:@"selecthotel_url"] isEqualToString:@""]) {
            
            UIImageView * hotelListBackImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _totalScrollHeight, 320, 40)];
            [hotelListBackImgView setBackgroundColor:[UIColor whiteColor]];
            [hotelListBackImgView setUserInteractionEnabled:YES];
            [_scrollView addSubview:hotelListBackImgView];
            [hotelListBackImgView release];
            
            //上部的分割线
            UIImageView * topLine = [[UIImageView alloc] init];
            topLine.frame = CGRectMake(0, 0, UIScreenWidth, 1);
            topLine.image = [UIImage imageNamed:@"line1"];
            [hotelListBackImgView addSubview:topLine];
            [topLine release];
            
            //下部的分割线
            UIImageView * bottomLine = [[UIImageView alloc] init];
            bottomLine.frame = CGRectMake(0, 39.5, UIScreenWidth, 1);
            bottomLine.image = [UIImage imageNamed:@"line1"];
            [hotelListBackImgView addSubview:bottomLine];
            [bottomLine release];
            
            UIButton * hotelListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [hotelListBtn setFrame:CGRectMake(0, 0, 320, 40)];
            [hotelListBtn setBackgroundColor:[UIColor clearColor]];
            [hotelListBtn addTarget:self action:@selector(hotelListBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [hotelListBtn addTarget:self action:@selector(hotelListBtnOutside:) forControlEvents:UIControlEventTouchUpOutside];
            [hotelListBtn addTarget:self action:@selector(hotelListBtnDown:) forControlEvents:UIControlEventTouchDown];
            [hotelListBtn addTarget:self action:@selector(hotelListBtnCancel:) forControlEvents:UIControlEventTouchCancel];
            [hotelListBackImgView addSubview:hotelListBtn];

          
            UIView * hotelListBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
            [hotelListBackView setTag:678678];
            [hotelListBackView setBackgroundColor:RGB(188, 198, 188)];
            [hotelListBackView setAlpha:0.4];
            [hotelListBackView setHidden:YES];
            [hotelListBtn addSubview:hotelListBackView];
            [hotelListBackView release];
            
            UIImageView * pinkLabel = [[UIImageView alloc]initWithFrame:CGRectMake(0, 8, 38, 24)];
            [pinkLabel setBackgroundColor:[UIColor clearColor]];
            [pinkLabel setImage:[UIImage imageNamed:@"city_pink_label@2x"]];
            [hotelListBtn addSubview:pinkLabel];
            [pinkLabel release];
            
            
            UILabel * HotelLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 200, 20)];
            [HotelLabel setBackgroundColor:[UIColor clearColor]];
            [HotelLabel setTextAlignment:NSTextAlignmentCenter];
            [HotelLabel setTextColor:RGB(68, 68, 68)];
            [HotelLabel setFont:[UIFont systemFontOfSize:15]];
            [HotelLabel setText:[NSString stringWithFormat:@"%@热门酒店",_titleLabel.text]];
            [hotelListBtn addSubview:HotelLabel];
            [HotelLabel release];
            
            UIImageView * arrow = [[UIImageView alloc]initWithFrame:CGRectMake(288, 8, 24, 24)];
            [arrow setBackgroundColor:[UIColor clearColor]];
            [arrow setImage:[UIImage imageNamed:@"city_arrows@2x"]];
            [hotelListBtn addSubview:arrow];
            [arrow release];
            
            _totalScrollHeight = _totalScrollHeight + 50;
        }
        
        
        _arrThreads = (NSMutableArray *)[_infoDictionary objectForKey:@"new_trip"];
        
        if (![_arrThreads isEqual:[NSNull null]] && _arrThreads.count >0) {
            
            UIImageView * threadBackImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _totalScrollHeight, 320, 515)];
            [threadBackImgView setBackgroundColor:[UIColor whiteColor]];
            [threadBackImgView setUserInteractionEnabled:YES];
            [_scrollView addSubview:threadBackImgView];

            //上部的分割线
            UIImageView * topLine = [[UIImageView alloc] init];
            topLine.frame = CGRectMake(0, 0, UIScreenWidth, 1);
            topLine.image = [UIImage imageNamed:@"line1"];
            [threadBackImgView addSubview:topLine];
            [topLine release];
            
            //下部的分割线
            UIImageView * bottomLine = [[UIImageView alloc] init];
            bottomLine.frame = CGRectMake(0, 514.5, UIScreenWidth, 1);
            bottomLine.image = [UIImage imageNamed:@"line1"];
            [threadBackImgView addSubview:bottomLine];
            [bottomLine release];
            
            
            UILabel * threadLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 160, 20)];
            [threadLabel setBackgroundColor:[UIColor clearColor]];
            [threadLabel setTextAlignment:NSTextAlignmentLeft];
            [threadLabel setTextColor:RGB(68, 68, 68)];
            [threadLabel setText:@"新鲜好游记"];
            [threadLabel setFont:[UIFont systemFontOfSize:17]];
            [threadBackImgView addSubview:threadLabel];
            [threadLabel release];
            
            if (_arrThreads.count >= 5) {
                UIButton * showThreadsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [showThreadsBtn setFrame:CGRectMake(230, 0, 80, 40)];
                [showThreadsBtn setBackgroundColor:[UIColor clearColor]];
                [showThreadsBtn setBackgroundImage:[UIImage imageNamed:@"countryCityShowAll@2x"] forState:UIControlStateNormal];
                [showThreadsBtn addTarget:self action:@selector(showAllThreads:) forControlEvents:UIControlEventTouchUpInside];
                [threadBackImgView addSubview:showThreadsBtn];
            }

            for (int i = 0; i < _arrThreads.count; i++) {
                
                NSMutableDictionary *tempDict = [_arrThreads objectAtIndex:i];
                
                CountryCityThreadView * threadView = [[CountryCityThreadView alloc]initWithFrame:CGRectMake(0, 40 + i * 88, 320, 88)];
                [threadView setThreadInfo:tempDict];
                [threadView setDelegate:self];
                [threadBackImgView addSubview:threadView];
                [threadView release];
            }
            
            [threadBackImgView setFrame:CGRectMake(0, _totalScrollHeight, 320, 88 * _arrThreads.count + 40)];
            [threadBackImgView release];

            bottomLine.frame = CGRectMake(0, 88 * _arrThreads.count + 39.5, UIScreenWidth, 1);

            
            _totalScrollHeight = _totalScrollHeight + 88 * _arrThreads.count + 40;
        }
        
        [_scrollView setContentSize:CGSizeMake(320, _totalScrollHeight)];
        
    }
    
}



-(void)hotelListBtnClicked:(id)sender
{
    UIView * hotelListBackView = [self.view viewWithTag:678678];
    [hotelListBackView setHidden:NO];
    
    NSString * hotelListUrl = [NSString stringWithFormat:@"%@",[_infoDictionary objectForKey:@"selecthotel_url"]];
    
    UsefulGuideController *usefulVc = [[UsefulGuideController alloc]init];
    usefulVc.type = 3; //type=3，代表进入UsefulGuideController是酒店
    usefulVc.strTitle = @"精选酒店";
    usefulVc.url = hotelListUrl;
    [self.navigationController pushViewController:usefulVc animated:YES];
    [usefulVc release];
    
    [MobClick event:@"cityClickHotel"];
    
    [self performSelector:@selector(resetHotlistView) withObject:nil afterDelay:0.15f];
}




-(void)goneBtnClicked:(id)sender
{
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue];

    NSLog(@"-----点击去过-----");

    //未登录,提示登录
    if (isLogin == NO) {
        
        CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
        navigationController.navigationBarHidden = YES;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        [cityLoginVC release];
    }
    else{
        
        NSString * typeee ;
        
        if (_type == 1) {
            typeee = @"country";
            
            [MobClick event:@"countryClickBeenTo"];
        }
        else{
            typeee = @"city";
            
            [MobClick event:@"cityClickBeenTo"];
        }
        
        //去过
        if (_beenToStatus == NO) {
            
            [self.view makeToastActivity];
            
            [[QYAPIClient sharedAPIClient]addCountryCityPlanOrBeenToWithType:typeee
                                                                          ID:_key
                                                                      status:@"beento"
                                                                     success:^(NSDictionary *dic) {
                                                                         
                                                                         [self.view hideToastActivity];
                                                                         
                                                                         int statusss = [[dic objectForKey:@"status"]integerValue];
                                                                         
                                                                         if (statusss == 1) {
                                                                             [_goneBtn setSelected:YES];
                                                                             _beenToStatus = YES;
                                                                             
                                                                             [self.view makeToast:@"成功添加足迹" duration:1.2f position:@"center" isShadow:NO];
                                                                         }
                                                                         else{
                                                                             
                                                                             NSString * info = [dic objectForKey:@"info"];
                                                                             [self.view makeToast:info duration:1.2f position:@"center" isShadow:NO];
                                                                             
                                                                             if (statusss == 2) {
                                                                                 _beenToStatus = YES;
                                                                                 [_goneBtn setSelected:YES];
                                                                             }
                                                                             
                                                                         }
                                                                         
                                                                     } failed:^{
                                                                         
                                                                         [self.view hideToastActivity];
                                                                         [self.view makeToast:@"网络连接错误" duration:1.2f position:@"center" isShadow:NO];
                                                                         
                                                                     }];
        }
        
        //取消去过
        if (_beenToStatus == YES) {
            
            [self.view makeToastActivity];
            
            [[QYAPIClient sharedAPIClient]removeCountryCityPlanOrBeenToWithType:typeee
                                                                             ID:_key
                                                                         status:@"beento"
                                                                        success:^(NSDictionary *dic) {
                                                                            
                                                                            [self.view hideToastActivity];
                                                                            
                                                                            int statusss = [[dic objectForKey:@"status"]integerValue];
                                                                            
                                                                            if (statusss == 1) {
                                                                                [_goneBtn setSelected:NO];
                                                                                _beenToStatus = NO;
                                                                            }
                                                                            else{
                                                                                
                                                                                NSString * info = [dic objectForKey:@"info"];
                                                                                [self.view makeToast:info duration:1.2f position:@"center" isShadow:NO];
                                                                            }
                                                                            
                                                                        } failed:^{
                                                                            
                                                                            [self.view hideToastActivity];
                                                                            [self.view makeToast:@"网络连接错误" duration:1.2f position:@"center" isShadow:NO];
                                                                            
                                                                        }];
        }
        
    }
}


-(void)wannagoBtnClicked:(id)sender
{
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue];
    
    NSLog(@"-----点击想去-----");
    
    //未登录,提示登录
    if (isLogin == NO) {
        CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
        navigationController.navigationBarHidden = YES;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        [cityLoginVC release];
    }
    else{
        
        NSLog(@"------%d--------%@--------",_type,_key);
        
        NSString * typeee ;
        
        if (_type == 1) {
            typeee = @"country";
            [MobClick event:@"countryClickWishTo"];
        }
        else{
            typeee = @"city";
            [MobClick event:@"cityClickWishTo"];
        }
        
        //想去
        if (_planToStatus == NO) {
            
            [self.view makeToastActivity];
            
            [[QYAPIClient sharedAPIClient]addCountryCityPlanOrBeenToWithType:typeee
                                                                          ID:_key
                                                                      status:@"planto"
                                                                     success:^(NSDictionary *dic) {
                                                                         
                                                                         NSLog(@"\n\n%@\n\n",dic);
                                                                         
                                                                         [self.view hideToastActivity];
                                                                         
                                                                         int statusss = [[dic objectForKey:@"status"]integerValue];
                                                                         
                                                                         if (statusss == 1) {
                                                                             [_wannaGoBtn setSelected:YES];
                                                                             _planToStatus = YES;
                                                                         }
                                                                         else{
                                                                             NSString * info = [dic objectForKey:@"info"];
                                                                              [self.view makeToast:info duration:1.2f position:@"center" isShadow:NO];
                                                                             
                                                                             if (statusss == 2) {
                                                                                 _planToStatus = YES;
                                                                                 [_wannaGoBtn setSelected:YES];
                                                                             }
                                                                             
                                                                         }
                                                                     } failed:^{
                                                                         
                                                                         [self.view hideToastActivity];
                                                                         [self.view makeToast:@"网络连接错误" duration:1.2f position:@"center" isShadow:NO];
                                                                     }];
        }
        
        //取消想去
        if (_planToStatus == YES) {
            
            [self.view makeToastActivity];
            
            [[QYAPIClient sharedAPIClient]removeCountryCityPlanOrBeenToWithType:typeee
                                                                             ID:_key
                                                                         status:@"planto"
                                                                        success:^(NSDictionary *dic) {
                                                                           
                                                                            [self.view hideToastActivity];
                                                                            
                                                                            NSLog(@"\n\n%@\n\n",dic);

                                                                            int statusss = [[dic objectForKey:@"status"]integerValue];
                                                                            
                                                                            if (statusss == 1) {
                                                                                [_wannaGoBtn setSelected:NO];
                                                                                _planToStatus = NO;
                                                                            }
                                                                            else{
                                                                                
                                                                                NSString * info = [dic objectForKey:@"info"];
                                                                                [self.view makeToast:info duration:1.2f position:@"center" isShadow:NO];
                                                                            }
                                                                            
                                                                        } failed:^{
                                                                            [self.view hideToastActivity];
                                                                            [self.view makeToast:@"网络连接错误" duration:1.2f position:@"center" isShadow:NO];
                                                                        }];
        }
    }
    
}



-(void)bigBtnClicked:(id)sender
{
    BOOL hasGuide = [[_infoDictionary objectForKey:@"has_guide"]boolValue];//有相关锦囊
    BOOL hasSummary = [[_infoDictionary objectForKey:@"overview_url"] isKindOfClass:[NSString class]] && ![[_infoDictionary objectForKey:@"overview_url"] isEqualToString:@""];//有实用贴士网页
    BOOL hasTripList = [[_infoDictionary objectForKey:@"has_trip_list"] boolValue];//有旅行专题(微锦囊)
    BOOL hasRecommandPlan = [[_infoDictionary objectForKey:@"has_plan"] boolValue];//有推荐行程
    
    
    UIButton * btn = (UIButton *)sender;
    
    int xxx = btn.tag - 8000;
    
    //锦囊
    if (xxx == 1) {
        if (_type == 1) {
            [MobClick event:@"countryClickGuide"];
        }else if(_type == 2){
            [MobClick event:@"cityClickGuide"];
        }
        
        if (hasGuide) {
            GuideListViewController *guideListVC = [[GuideListViewController alloc] init];
            guideListVC.type_id = self.key;
            guideListVC.type = (self.type == 1 ? @"country" : @"city");
            guideListVC.where_from = (self.type == 1 ? @"country" : @"city");
            [self.navigationController pushViewController:guideListVC animated:YES];
            [guideListVC release];
        }
        else{
            [self.view hideToast];
            [self.view makeToast:@"该目的地没有相关锦囊" duration:1.2f position:@"center" isShadow:NO];
        }

    }
    
    
    //实用贴士
    if (xxx == 2) {
        
        if (hasSummary) {
            
            UsefulGuideController *usefulVc = [[UsefulGuideController alloc]init];
            usefulVc.strTitle = @"实用贴士";
        
            if (_type == 1) {
                [MobClick event:@"countryClickInfo"];
                usefulVc.type = 1;
                usefulVc.url = [_infoDictionary objectForKey:@"overview_url"];
                
            }else{
                [MobClick event:@"cityClickInfo"];
                usefulVc.type = 2;
                usefulVc.url = [_infoDictionary objectForKey:@"overview_url"];
            }
            [self.navigationController pushViewController:usefulVc animated:YES];
            [usefulVc release];
        }
        else{
            [self.view hideToast];
            [self.view makeToast:@"该目的地没有相关实用贴士" duration:1.2f position:@"center" isShadow:NO];
        }
  
    }
    
    //旅行专题
    if (xxx == 3) {
        
        if (hasTripList) {
            if (_type == 1) {
                [MobClick event:@"countryClickMcGuide"];
            }
            else{
                [MobClick event:@"cityClickMcGuide"];
            }
            TravelSubjectViewController *travelSubjectVC = [[TravelSubjectViewController alloc] init];
            travelSubjectVC.type = [NSString stringWithFormat:@"%d",self.type];
            travelSubjectVC.ID = [_infoDictionary objectForKey:@"id"];
            [self.navigationController pushViewController:travelSubjectVC animated:YES];
            [travelSubjectVC release];
        }
        else{
            [self.view hideToast];
            [self.view makeToast:@"该目的地没有相关旅行专题" duration:1.2f position:@"center" isShadow:NO];
        }
        
    
    }
    
    //推荐行程
    if (xxx == 4) {
        
        if (hasRecommandPlan) {
            if (_type == 1) {
                [MobClick event:@"countryClickPlan"];
            }else if (_type == 2){
                [MobClick event:@"cityClickPlan"];
            }
            RecomTravelViewController *recomTraVc = [[RecomTravelViewController alloc]init];
            recomTraVc.key = _key;
            recomTraVc.type = _type;
            [self.navigationController pushViewController:recomTraVc animated:YES];
            [recomTraVc release];
        }
        
        else{
            [self.view hideToast];
            [self.view makeToast:@"该目的地没有相关推荐行程" duration:1.2f position:@"center" isShadow:NO];
        }
        
    }

}


-(void)cityBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    int xxx = btn.tag;
    
    [MobClick event:@"countryClickCityList"];
    
    CountryViewController *countryVc = [[CountryViewController alloc]init];
    countryVc.type = 2;
    countryVc.key = [NSString stringWithFormat:@"%d",xxx];
    [self.navigationController pushViewController:countryVc animated:YES];
    [countryVc release];
}


-(void)didClickDiscount:(id)sender
{
    [MobClick event:@"countryClickDisc"];
    
    CountryCityDiscountView * viewww = (CountryCityDiscountView *)sender;
    [viewww performSelector:@selector(setBackBtnColor) withObject:nil afterDelay:0.15f];
    
    int xxx = (int)viewww.tag - 10000;
    
    //by jessica
    LastMinuteDetailViewControllerNew * lastDetailVC = [[LastMinuteDetailViewControllerNew alloc]init];
    lastDetailVC.lastMinuteId = xxx;
    lastDetailVC.source = NSStringFromClass([self class]);
    [self.navigationController pushViewController:lastDetailVC animated:YES];
    [lastDetailVC release];
}


-(void)didClickThread:(id)sender
{
    CountryCityThreadView * viewww = (CountryCityThreadView *)sender;
    [viewww performSelector:@selector(setBackBtnColor) withObject:nil afterDelay:0.15f];
    
    NSString * url = viewww.linkURL;
    
    if (_type == 1) {
        [MobClick event:@"countryClickJournal"];
    }
    else if (_type == 2){
        [MobClick event:@"cityClickJournal"];
    }
    
    BBSDetailViewController * bbsDetailVC = [[BBSDetailViewController alloc]init];
    bbsDetailVC.bbsAllUserLink = url;
    [self.navigationController pushViewController:bbsDetailVC animated:YES];
    [bbsDetailVC release];
}


-(void)showAllCity:(id)sender
{
    if (_type == 1) {
       
        /**
         *  热门城市
         */
        [MobClick event:@"countryClickAllCities"];
        
        CityListViewController *cityListVc = [[CityListViewController alloc]init];
        cityListVc.key = self.key;
        [self.navigationController pushViewController:cityListVc animated:YES];
        [cityListVc release];
    }
    
    if (_type == 2) {
        
        [MobClick event:@"cityClickPOI"];

        AllSpotViewController *spotVc = [[AllSpotViewController alloc]init];
        spotVc.cityId = _key;
        spotVc.cityName = _titleLabel.text;
        [self.navigationController pushViewController:spotVc animated:YES];
        [spotVc release];
    }
}


-(void)showAllDiscount:(id)sender
{
    if (_type == 1) {
        /**
         *  国家折扣
         */
        [MobClick event:@"countryClickAllDisc"];
    }
    
    //折扣
    HotDiscountViewController *hotDisCount = [[HotDiscountViewController alloc]init];
    hotDisCount.countryID = [_key integerValue];
    [self.navigationController pushViewController:hotDisCount animated:YES];
    [hotDisCount release];
}


-(void)showAllThreads:(id)sender
{
    if (_type == 1) {
        [MobClick event:@"countryClickAllJournal"];
    }else if (_type == 2){
        [MobClick event:@"cityClickAllJournal"];
    }
    
    //游记
    TravelsListViewController *travelListVc = [[TravelsListViewController alloc]init];
    travelListVc.key = _key;
    travelListVc.type = _type;
    [self.navigationController pushViewController:travelListVc animated:YES];
    [travelListVc release];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark 
- (NSInteger)numberOfPages
{
    NSLog(@"**** %d ****",_photosArray.count);

    if (_photosArray.count == 0) {
        [_photosArray addObject:@""];
    }
    
    NSLog(@"____ %d ____",_photosArray.count);
    
    return _photosArray.count;
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    if (_photosArray.count > 0) {
        UIImageView*_topImageView = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 195)] autorelease];
        _topImageView.backgroundColor = [UIColor clearColor];
        _topImageView.userInteractionEnabled = YES;
        _topImageView.layer.masksToBounds = YES;
        _topImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topImageView.clipsToBounds = YES;
        
        if ([[_photosArray objectAtIndex:index] isKindOfClass:[NSString class]] && ![[_photosArray objectAtIndex:index] isEqualToString:@""]) {
                [_topImageView setImageWithURL:[NSURL URLWithString:[_photosArray objectAtIndex:index]] placeholderImage:[UIImage imageNamed:@"default_co_back"]];
        }
        
        return _topImageView;
    }
    
    return nil;
}


#pragma mark
#pragma mark clickRightButton
/**
 *  点击右上角地图按钮
 *
 *  @param btn nil
 */
-(void)clickRightButton:(UIButton *)btn{
    
    NSString *name;
    
    if ([[_infoDictionary objectForKey:@"chinesename"] isKindOfClass:[NSString class]] && ![[_infoDictionary objectForKey:@"chinesename"] isEqualToString:@""]) {
        name = [_infoDictionary objectForKey:@"chinesename"];
    }
    else{
        name = [_infoDictionary objectForKey:@"englishname"];
    }
    
    NSLog(@" ## %@ ## ",name);
    
    [MobClick event:@"countryClickMap"];
    
    GoogleMapViewController *googleMapVC = [[GoogleMapViewController alloc] init];
    googleMapVC.array_in = nil;
    googleMapVC.dic_in = nil;
    googleMapVC.str_countryName = name; //国家名称
    googleMapVC.title_navigation = name;
    [self.navigationController pushViewController:googleMapVC animated:YES];
    [googleMapVC release];
    
}

//点击城市的POI分类
-(void)showSpot:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    int xxx = btn.tag - 9000 ;
    
    [MobClick event:@"cityClickPOI"];

    AllSpotViewController *spotVc = [[AllSpotViewController alloc]init];
    spotVc.cityId = _key;
    spotVc.cityName = _titleLabel.text;
    spotVc.select = xxx;
    
    NSLog(@"####### %d ######",xxx);
    
    [self.navigationController pushViewController:spotVc animated:YES];
    [spotVc release];
}




-(void)loginIn_Success
{
    NSLog(@"登录成功，重新连接接口获取用户数据");
    
    [self.view makeToastActivity];
    
    if (_type == 1) {
        [[QYAPIClient sharedAPIClient]getCountryDataByCountryId:_key
                                                        success:^(NSDictionary *dic) {
                                                            
                                                            [self.view hideToastActivity];
                                                            int status = [[dic objectForKey:@"status"]integerValue];
                                                            
                                                            if (status == 1) {
                                                                
                                                                NSDictionary * dict = (NSDictionary *)[dic objectForKey:@"data"];
                                                                
                                                                BOOL wantGo = [[dict objectForKey:@"planto"]boolValue];  //判断想去
                                                                BOOL alreadyGone = [[dict objectForKey:@"beento"]boolValue]; //判断已去过
                                                                
                                                                _planToStatus = wantGo;
                                                                _beenToStatus = alreadyGone;
                                                                
                                                                [_wannaGoBtn setSelected:_planToStatus];
                                                                [_goneBtn setSelected:_beenToStatus];
                                                            }
                                                            
                                                        } failed:^{
                                                            
                                                            [self.view hideToastActivity];
                                                            
                                                        }];
    }
    
    
    else if (_type == 2){
        [[QYAPIClient sharedAPIClient]getCityDataByCityId:_key
                                                  success:^(NSDictionary *dic) {
                                                      
                                                      [self.view hideToastActivity];
                                                      int status = [[dic objectForKey:@"status"]integerValue];
                                                      
                                                      if (status == 1) {
                                                          
                                                          NSDictionary * dict = (NSDictionary *)[dic objectForKey:@"data"];
                                                          
                                                          BOOL wantGo = [[dict objectForKey:@"planto"]boolValue];  //判断想去
                                                          BOOL alreadyGone = [[dict objectForKey:@"beento"]boolValue]; //判断已去过
                                                          
                                                          _planToStatus = wantGo;
                                                          _beenToStatus = alreadyGone;
                                                          
                                                          [_wannaGoBtn setSelected:_planToStatus];
                                                          [_goneBtn setSelected:_beenToStatus];
                                                      }
                                                      
                                                  } failed:^{
        
                                                      [self.view hideToastActivity];
                                                  }];
    
    }
    
    
}




/**
 *  继承父类返回
 *
 *  @param btn 返回btn
 */


-(void)popBack
{
    [super clickBackButton:nil];
}

- (void)clickBackButton:(UIButton *)btn{
    
    [_topScrollView destroyTimer];
    [super clickBackButton:btn];
}

/**
 *  点击屏幕重新加载
 */
-(void)touchesView{
    
    NSLog(@"touchesView");
    [self requestDataFromServer];
}


-(void)hotelListBtnOutside:(id)sender
{
    UIView * hotelListBackView = [self.view viewWithTag:678678];
    [hotelListBackView setHidden:YES];
}

-(void)hotelListBtnDown:(id)sender
{
    UIView * hotelListBackView = [self.view viewWithTag:678678];
    [hotelListBackView setHidden:NO];
}

-(void)hotelListBtnCancel:(id)sender
{
    UIView * hotelListBackView = [self.view viewWithTag:678678];
    [hotelListBackView setHidden:YES];
}
-(void)resetHotlistView
{
    UIView * hotelListBackView = [self.view viewWithTag:678678];
    [hotelListBackView setHidden:YES];
}

//让导航控制器可侧滑返回
-(void)setNavigationCanGoBack
{
    AppDelegate * shareDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    MLNavigationController * rootVC = shareDelegate._homeNavVC;
    [rootVC setCanDragBack:YES];
}


-(void)dealloc{
 
    QY_SAFE_RELEASE(_infoDictionary);
    QY_SAFE_RELEASE(_photosArray);
    
    QY_VIEW_RELEASE(_scrollView);
    QY_VIEW_RELEASE(_topScrollView);
    
    QY_VIEW_RELEASE(_bottomImgView);
    QY_VIEW_RELEASE(_goneBtn);
    QY_VIEW_RELEASE(_wannaGoBtn);
    
    QY_VIEW_RELEASE(_chinaNameLabel);
    QY_VIEW_RELEASE(_englishNameLabel);
    QY_VIEW_RELEASE(_numberPicLabel);
    QY_VIEW_RELEASE(_numBackImageView);
    QY_VIEW_RELEASE(_shadeImageView);
    
    [super dealloc];
}


@end
