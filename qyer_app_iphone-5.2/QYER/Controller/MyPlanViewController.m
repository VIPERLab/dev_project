//
//  MyPlanViewController.m
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-10.
//
//

#import "MyPlanViewController.h"
#import "UserItineraryData.h"
#import "MyItineraryCell.h"
#import "UserItinerary.h"
#import "CityLoginViewController.h"
#import "WebViewViewController.h"
#import "Reachability.h"
#import "MobClick.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "ChangeTableviewContentInset.h"
//#import "RegexKitLite.h"



#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_tableView         (ios7 ? (44+20) : 44)
#define     positionY_viewBackground    (ios7 ? (44+20) : 44)



@interface MyPlanViewController ()

@end




@implementation MyPlanViewController
@synthesize array_myItinerary = _array_myItinerary;
@synthesize tableView_itineraryVC = _tableView_itineraryVC;
@synthesize userId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hotdot_phone:) name:@"hotdot_phone" object:nil];
        
    }
    return self;
}


-(void)dealloc
{
    QY_VIEW_RELEASE(_view_backGround);
    QY_VIEW_RELEASE(_tableView_itineraryVC);
    QY_VIEW_RELEASE(_imageView_failed);
    QY_MUTABLERECEPTACLE_RELEASE(_array_myItinerary);
    
    self.currentVC = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- 热点 或 打电话
-(void)hotdot_phone:(NSNotification *)noatification
{
    NSDictionary *info = noatification.userInfo;
    if([[info objectForKey:@"type"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:1];
    }
    else if([[info objectForKey:@"type"] isEqualToString:@"0"])
    {
        [self resetRootViewWIthType:0];
    }
}

-(void)resetRootViewWIthType:(BOOL)flag
{
    if(!flag)
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height;
        self.view.frame = newFrame;
        
        
        newFrame = _tableView_itineraryVC.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableView_itineraryVC.frame = newFrame;
        
        
        newFrame = _view_backGround.frame;
        newFrame.size.height = [self.view bounds].size.height - _headView.frame.size.height;
        _view_backGround.frame = newFrame;
        
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        newFrame = _tableView_itineraryVC.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableView_itineraryVC.frame = newFrame;
        
        
        newFrame = _view_backGround.frame;
        newFrame.size.height = [self.view bounds].size.height - _headView.frame.size.height;
        _view_backGround.frame = newFrame;
    }
}






#pragma mark -
#pragma mark --- DidAppear & DidDisappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"hotdot_phone"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:YES];
    }
    

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshDataWhenLogout) name:@"loginoutsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshDataWhenLogin) name:@"logininsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getItinerary_mineData) name:@"freshdata_MyItineraryVC" object:nil];
    
    
    
    if(_array_myItinerary && _array_myItinerary.count > 0)
    {
        return;
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES && !self.userId) //我的行程
    {
        [self getItinerary_mineData];
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES) //未登录
    {
        [self initViewWhenNoLogIn];
        [self.view hideToastActivity];
    }
    else if(self.userId) //TA的行程
    {
        [self getItinerary_otherData];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)getItinerary_mineData
{
    NSString * userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];

    if ( ![userID isEqual:[NSNull null]] && ![userID isEqualToString:@""])
    {
        [self getItineraryDataWithUserId:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]];
    }
}

-(void)getItinerary_otherData
{
    [self getItineraryDataWithUserId:self.userId];
}

-(void)getItineraryDataWithUserId:(NSString *)user_id
{
    if(_imageView_failed)
    {
        _imageView_failed.hidden = YES;
    }
    
    
    [self.view makeToastActivity];
    if(!_array_myItinerary)
    {
        _array_myItinerary = [[NSMutableArray alloc] init];
    }
    
    
    [_array_myItinerary removeAllObjects];
    
    //修正有时候user_id是整数的BUG。
    NSString *user_id_str = [NSString stringWithFormat:@"%@", user_id];
    
    [UserItineraryData getUserItineraryWithUserId:user_id_str
                                      andPageSize:@"100"
                                          success:^(NSArray *array){
                                              
                                              [self.view hideToastActivity];
                                              
                                              [_array_myItinerary removeAllObjects];
                                              [_array_myItinerary addObjectsFromArray:array];
                                              if(_array_myItinerary.count == 0 && [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
                                              {
                                                  [self initDefaultViewWhenFailed];
                                              }
                                              else if(self.array_myItinerary.count > 0)
                                              {
                                                  [self initTableView];
                                              }
                                              else
                                              {
                                                  [self initViewWhenNoData];
                                              }
                                          }
                                           failed:^{
                                               //NSLog(@" getUserItinerary 失败");
                                               
                                               [self.view hideToastActivity];
                                               
                                               if(!self.array_myItinerary || self.array_myItinerary.count == 0)
                                               {
                                                   [self initDefaultViewWhenFailed];
                                               }
                                           }];
    
}



#pragma mark -
#pragma mark --- 构建view
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
}
-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
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
    
    
    UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
    
    float positionY_titleLabel = (ios7 ? 27 : 12);
    UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, positionY_titleLabel, 160, 30)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    if(self.userId)
    {
        _titleLabel.text = @"TA的行程";
    }
    else
    {
        _titleLabel.text = @"我的行程";
    }
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    [_titleLabel release];

    
//    UIImageView *titleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 10, 80, 24)];
//    if(ios7)
//    {
//        titleImgView.frame = CGRectMake(120, 10+20, 80, 24);
//    }
//    titleImgView.backgroundColor = [UIColor clearColor];
//    [titleImgView setImage:[UIImage imageNamed:@"navigation_plan"]];
//    [_headView addSubview:titleImgView];
//    [titleImgView release];

}


-(void)initTableView
{
    if(_view_backGround)
    {
        [_view_backGround removeFromSuperview];
    }
    
    if(!_tableView_itineraryVC)
    {
//        if(ios7)
//        {
            _tableView_itineraryVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [self.view bounds].size.height) style:UITableViewStylePlain];
//        }
//        else
//        {
//            _tableView_itineraryVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, ([self.view bounds].size.height-20)) style:UITableViewStylePlain];
//        }
        
        
        _tableView_itineraryVC.delegate = self;
        _tableView_itineraryVC.dataSource = self;
        _tableView_itineraryVC.backgroundColor = [UIColor clearColor];
        _tableView_itineraryVC.separatorColor = [UIColor clearColor];
        
        
//        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
//        headView.backgroundColor = [UIColor clearColor];
//        _tableView_itineraryVC.tableHeaderView = headView;
//        [headView release];
        
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
        footView.backgroundColor = [UIColor clearColor];
        _tableView_itineraryVC.tableFooterView = footView;
        [footView release];
    }
    
    [ChangeTableviewContentInset changeWithTableView:_tableView_itineraryVC];
    [self.view insertSubview:_tableView_itineraryVC belowSubview:_headView];
    
    [_tableView_itineraryVC reloadData];
}
-(void)initDefaultViewWhenFailed
{
    if(_tableView_itineraryVC)
    {
        [_tableView_itineraryVC removeFromSuperview];
        
        if(_array_myItinerary)
        {
            [_array_myItinerary removeAllObjects];
        }
    }
    
    if(_view_backGround)
    {
        [_view_backGround removeFromSuperview];
        [_view_backGround release];
    }
    
    if(ios7)
    {
        _view_backGround = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44+20, 320, self.view.bounds.size.height-_headView.frame.size.height)];
    }
    else
    {
        _view_backGround = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, (self.view.bounds.size.height-20)-_headView.frame.size.height)];
    }
    
    _view_backGround.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_view_backGround];
    
    
    
    
    if(!_imageView_failed)
    {
        CGFloat y = 130;
        if ([UIScreen mainScreen].bounds.size.height == 480) {
            y = 86;
        }
        
        _imageView_failed = [[UIControl alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 640/2, [[UIScreen mainScreen] bounds].size.height - _headView.frame.size.height)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, 640/2, 360/2)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"notReachable"];
        [_imageView_failed addSubview:imageView];
        [imageView release];
    }
    _imageView_failed.backgroundColor = [UIColor clearColor];
    _imageView_failed.hidden = NO;
    [_imageView_failed addTarget:self action:@selector(getItinerary_otherData) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_imageView_failed];
}
-(void)initViewWhenNoLogIn
{
    if(_tableView_itineraryVC)
    {
        if(_array_myItinerary)
        {
            [_array_myItinerary removeAllObjects];
        }
        [_tableView_itineraryVC removeFromSuperview];
    }
    
    if(_view_backGround)
    {
        [_view_backGround removeFromSuperview];
        [_view_backGround release];
    }
    if(ios7)
    {
        _view_backGround = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44+20, 320, self.view.bounds.size.height-_headView.frame.size.height)];
    }
    else
    {
        _view_backGround = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, (self.view.bounds.size.height-20)-_headView.frame.size.height)];
    }
    _view_backGround.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_view_backGround];
    
    
    UIImage *image = [UIImage imageNamed:@"我的行程_未登录图片"];
    UIImageView *_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, image.size.height)];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.image = image;
    _imageView.userInteractionEnabled = YES;
    _view_backGround.contentSize = CGSizeMake(320, image.size.height);
    
    
    UIButton *button_login = [UIButton buttonWithType:UIButtonTypeCustom];
    button_login.frame = CGRectMake(190, 27, 184/2, 72/2);
    button_login.backgroundColor = [UIColor clearColor];
    [button_login setBackgroundImage:[UIImage imageNamed:@"登录按钮背景"] forState:UIControlStateNormal];
    [button_login addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:button_login];
    [_view_backGround addSubview:_imageView];
    [_imageView release];
}
-(void)initViewWhenNoData
{
    if(_tableView_itineraryVC)
    {
        [_tableView_itineraryVC removeFromSuperview];
    }
    
    if(_view_backGround)
    {
        [_view_backGround removeFromSuperview];
        [_view_backGround release];
    }
    if(ios7)
    {
        _view_backGround = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44+20, 320, self.view.bounds.size.height-_headView.frame.size.height)];
    }
    else
    {
        _view_backGround = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, (self.view.bounds.size.height-20)-_headView.frame.size.height)];
    }
    _view_backGround.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_view_backGround];
    
    
    UIImage *image = [UIImage imageNamed:@"我的行程_没有行程_文字"];
    UIImageView *_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, image.size.height)];
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.image = image;
    [_view_backGround addSubview:_imageView];
    _view_backGround.contentSize = CGSizeMake(320, image.size.height);
    [_imageView release];
}




#pragma mark -
#pragma mark --- 登录
-(void)login
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view makeToast:@"请检查网络连接" duration:1 position:@"center" isShadow:NO];
        return;
    }
    
    
    [MobClick event:@"planClickLogin"];
    
    
    CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
    [cityLoginVC release];
}


#pragma mark -
#pragma mark --- UITableView - DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array_myItinerary count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 394/2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyItineraryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideView_Cell"];
    if(cell == nil)
    {
        cell = [[[MyItineraryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuideView_Cell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //[cell initContentAtPosition:indexPath.row WithArray:_array_myItinerary];
    [cell initMyPlanContentAtPosition:indexPath.row WithArray:_array_myItinerary];
    
    return cell;
}



#pragma mark -
#pragma mark --- UITableView - Delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_array_myItinerary && _array_myItinerary.count > 0)
    {
        [MobClick event:@"myPlanClickPlan"];
        
        [self performSelector:@selector(goToPlanInfo:) withObject:indexPath afterDelay:0];
    }
    
    return nil;
}
-(void)goToPlanInfo:(NSIndexPath *)indexPath
{
    WebViewViewController *webVC = [[WebViewViewController alloc] init];
    webVC.flag_natavie = YES;
    webVC.flag_plan = YES;
    webVC.plan_id = [[_array_myItinerary objectAtIndex:indexPath.row] itineraryId];
    webVC.title = [[_array_myItinerary objectAtIndex:indexPath.row] itineraryPlannerName];
    webVC.startURL = [[_array_myItinerary objectAtIndex:indexPath.row] itineraryLinkString];
    //webVC.startURL = @"http://m.qyer.com/plan/tripv2.php?action=offlinereview&routeid=411190";
    NSLog(@"webVC.startURL:%@",webVC.startURL);
    webVC.updateTime = [[_array_myItinerary objectAtIndex:indexPath.row] itineraryUpdateTime];
    webVC.planName = [[_array_myItinerary objectAtIndex:indexPath.row] itineraryPlannerName];
    //[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:webVC animated:YES];
    [self.navigationController pushViewController:webVC animated:YES];
    [webVC release];
}


#pragma mark -
#pragma mark --- freshData - WhenLogout / Login
-(void)freshDataWhenLogout
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
    {
        [self initViewWhenNoLogIn];
    }
}

-(void)freshDataWhenLogin
{
    NSString * userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    
    if ( ![userID isEqual:[NSNull null]] && ![userID isEqualToString:@""])
    {
        [self getItineraryDataWithUserId:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]];
    }
}


#pragma mark -
#pragma mark --- clickBackButton
-(void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
