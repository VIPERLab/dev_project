//
//  MyFriendsViewController.m
//  QYER
//
//  Created by 我去 on 14-5-12.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "MyFriendsViewController.h"
#import "ChangeTableviewContentInset.h"
#import "MineViewController.h"
#import "MyFriendsCell.h"
#import "FriendsData.h"
#import "Friends.h"
#import "ODRefreshControl.h"



#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (4+20) : 6)
#define     height_titlelabel           (ios7 ? (30) : 34)
#define     positionY_backbutton        (ios7 ? 20 : 0)




@interface MyFriendsViewController ()

@end




@implementation MyFriendsViewController
@synthesize user_id;
@synthesize type;

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
    QY_MUTABLERECEPTACLE_RELEASE(_array_fansData);
    QY_MUTABLERECEPTACLE_RELEASE(_array_followsData);
    
    
    QY_VIEW_RELEASE(_footView);
    QY_VIEW_RELEASE(_activityView);
    QY_VIEW_RELEASE(_tableView_myFriends);
    QY_VIEW_RELEASE(_toolBar);
    
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
        
        
        newFrame = _tableView_myFriends.frame;
        newFrame.size.height = [self.view bounds].size.height-_headView.frame.size.height-_toolBar.frame.size.height;
        _tableView_myFriends.frame = newFrame;
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        newFrame = _tableView_myFriends.frame;
        newFrame.size.height = [self.view bounds].size.height-_headView.frame.size.height-_toolBar.frame.size.height;
        _tableView_myFriends.frame = newFrame;
    }
}




#pragma mark -
#pragma mark --- view - DidAppear & DidDisappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"hotdot_phone"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:YES];
    }
    
    
    
    //*** 网络不好:
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view makeToast:@"网络错误" duration:1 position:@"center" isShadow:NO];
        
        [self performSelector:@selector(initFailedView) withObject:nil afterDelay:0.2];
    }
    else if([self.type isEqualToString:@"follows"] && (!_array_followsData || _array_followsData.count == 0))
    {
        [self initFollowData];
    }
    else if([self.type isEqualToString:@"fans"] && (!_array_fansData || _array_fansData.count == 0))
    {
        [self initFansData];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    [self initFollowsAndFansButton];
    [self initArray];
    [self initTableView];
    
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
    
    
    UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(184/2, positionY_titlelabel, 136, height_titlelabel)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    if(self.user_id != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])//他人的个人中心
    {
        _titleLabel.text = @"TA的好友";
    }
    else
    {
        _titleLabel.text = @"我的好友";
    }
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
-(void)initFollowsAndFansButton
{
    float positionY = 20+44;
    if(!ios7)
    {
        positionY = 44;
    }
    UIImage *image = [UIImage imageNamed:@"follows_mine"];
    if(!_toolBar)
    {
        _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, positionY, 320, image.size.height+positionY_button_guideVC*2)];
    }
    _toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_toolBar];
    [self.view bringSubviewToFront:_headView];
    
    
    
    //我的关注按钮:
    image = [UIImage imageNamed:@"follows_mine"];
    if(!_button_follow)
    {
        _button_follow = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _button_follow.backgroundColor = [UIColor clearColor];
    _button_follow.frame = CGRectMake(0, positionY_button_guideVC, image.size.width, image.size.height);
    if(self.user_id != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])//他人的个人中心
    {
        [_button_follow setBackgroundImage:[UIImage imageNamed:@"follows_ta"] forState:UIControlStateNormal];
        [_button_follow setBackgroundImage:[UIImage imageNamed:@"highlight_follows_ta"] forState:UIControlStateSelected];
    }
    else
    {
        [_button_follow setBackgroundImage:[UIImage imageNamed:@"follows_mine"] forState:UIControlStateNormal];
        [_button_follow setBackgroundImage:[UIImage imageNamed:@"highlight_follows_mine"] forState:UIControlStateSelected];
    }
    [_button_follow addTarget:self action:@selector(initFollowData) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_button_follow];
    
    
    
    //我的粉丝按钮:
    if(!_button_fans)
    {
        _button_fans = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _button_fans.frame = CGRectMake(_button_follow.frame.origin.x+_button_follow.frame.size.width, positionY_button_guideVC, image.size.width, image.size.height);
    if(self.user_id != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])//他人的个人中心
    {
        [_button_fans setBackgroundImage:[UIImage imageNamed:@"fans_ta"] forState:UIControlStateNormal];
        [_button_fans setBackgroundImage:[UIImage imageNamed:@"highlight_fans_ta"] forState:UIControlStateSelected];
    }
    else
    {
        [_button_fans setBackgroundImage:[UIImage imageNamed:@"fans_mine"] forState:UIControlStateNormal];
        [_button_fans setBackgroundImage:[UIImage imageNamed:@"highlight_fans_mine"] forState:UIControlStateSelected];
    }
    
    [_button_fans addTarget:self action:@selector(initFansData) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_button_fans];
    

    
    //最下面的分割线:
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, _button_fans.frame.origin.y+_button_fans.frame.size.height, 320, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:224/255. green:224/255. blue:224/255. alpha:1];
    [_toolBar addSubview:line];
    [line release];
}
-(void)initArray
{
    if(!_array_fansData)
    {
        _array_fansData = [[NSMutableArray alloc] init];
    }
    [_array_fansData removeAllObjects];
    
    if(!_array_followsData)
    {
        _array_followsData = [[NSMutableArray alloc] init];
    }
    [_array_followsData removeAllObjects];
}
-(void)initTableView
{
    if(!_tableView_myFriends)
    {
        _tableView_myFriends = [[UITableView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height+_toolBar.frame.size.height, 320, [self.view bounds].size.height-_headView.frame.size.height-_toolBar.frame.size.height)];
        _tableView_myFriends.backgroundColor = [UIColor clearColor];
        _tableView_myFriends.separatorColor = [UIColor clearColor];
        _tableView_myFriends.dataSource = self;
        _tableView_myFriends.delegate = self;
    }
    [self.view addSubview:_tableView_myFriends];
    [self.view bringSubviewToFront:_toolBar];
    [self.view bringSubviewToFront:_headView];
    
    
    
    //下拉刷新:
    if(!_refreshControl)
    {
        _refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView_myFriends];
        [_refreshControl addTarget:self action:@selector(pullRefreshHandler:) forControlEvents:UIControlEventValueChanged];
    }
}
-(void)initTableViewFootViewWithFlag:(BOOL)flag
{
    if(!flag)
    {
        if(_activityView)
        {
            [_activityView stopAnimating];
        }
        _tableView_myFriends.tableFooterView = nil;
    }
    else
    {
        [self setTableViewFooterView];
    }
}
-(void)setTableViewFooterView
{
    if(!_footView)
    {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(110+20, 5, 100, 27)];
        label.tag = 1;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"加载更多";
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:15.];
        label.textAlignment = NSTextAlignmentCenter;
        [_footView addSubview:label];
        [label release];
    }
    _footView.backgroundColor = [UIColor clearColor];
    if(!_activityView)
    {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    _activityView.backgroundColor = [UIColor clearColor];
    _activityView.center = CGPointMake(110+20, 16.5);
    [_activityView startAnimating];
    [_footView addSubview:_activityView];
    
    _tableView_myFriends.tableFooterView = _footView;
}
-(void)startFooterViewWithType:(NSString *)type_
{
    if(_activityView)
    {
        [_activityView startAnimating];
    }
    [(UILabel*)[_footView viewWithTag:1] setText:@"正在加载..."];
    
    if(type_ && [type_ isEqualToString:@"follows"])
    {
        [self performSelector:@selector(getFollowsDataFromServer) withObject:0 afterDelay:0.1];
    }
    else if(type_ && [type_ isEqualToString:@"fans"])
    {
        [self performSelector:@selector(getFansDataFromServer) withObject:0 afterDelay:0.1];
    }
}



#pragma mark -
#pragma mark --- initFollowData & initFansData
-(void)initFollowData
{
    _selected_state = follow_state;
    _button_fans.selected = NO;
    _button_follow.selected = YES;
    self.type = @"follows";
    
    
    if(_array_followsData && _array_followsData.count > 0)
    {
        if(_imageView_default)
        {
            _imageView_default.hidden = YES;
        }
        if(_array_followsData.count < 20)
        {
            [self initTableViewFootViewWithFlag:NO];
        }
        [_tableView_myFriends reloadData];
        _tableView_myFriends.hidden = NO;
    }
    else
    {
        [self getFollowsDataFromServer];
    }
}
-(void)getFollowsDataFromServer
{
    [self.view makeToastActivity];
    NSString *user_id_ = @"";
    if(self.user_id != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])//他人的个人中心
    {
        user_id_ = [NSString stringWithFormat:@"%d",self.user_id];
    }
    else
    {
        user_id_ = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    }
    
    if(_follows_pageNumber == 0)
    {
        _follows_pageNumber = 1;
    }
    [FriendsData getFriendsDataWithType:@"follows"
                              andUserid:user_id_
                               andCount:@"20"
                                andPage:[NSString stringWithFormat:@"%d",_follows_pageNumber]
                                success:^(NSArray *array){
                                    
                                    if(_imageView_failed)
                                    {
                                        _imageView_failed.hidden = YES;
                                    }
                                    
                                    [self.view hideToastActivity];
                                    _imageView_failed.hidden = YES;
                                    if((!array || array.count == 0) && (!_array_followsData || _array_followsData.count == 0))
                                    {
                                        [self performSelector:@selector(initDefaultView_follows) withObject:nil afterDelay:0.2]; //没有数据
                                    }
                                    
                                    else
                                    {
                                        if(_imageView_default)
                                        {
                                            _imageView_default.hidden = YES;
                                        }
                                        
                                        NSLog(@"array.count:%d",array.count);
                                        
                                        _reloading = NO;
                                        [_refreshControl endRefreshing];
                                        [self.view hideToastActivity];
                                        _follows_pageNumber++;
                                        if([array count] == 20)
                                        {
                                            _flag_canLoadMore_follows = YES;
                                            
                                            [_array_followsData addObjectsFromArray:array];
                                            [self initTableViewFootViewWithFlag:YES];
                                        }
                                        else
                                        {
                                            _flag_canLoadMore_follows = NO;
                                            
                                            [_array_followsData addObjectsFromArray:array];
                                            [self initTableViewFootViewWithFlag:NO];
                                        }
                                        NSLog(@" array_followsData.count : %d",_array_followsData.count);
                                        [_tableView_myFriends reloadData];
                                        _tableView_myFriends.hidden = NO;
                                    }
                                }
                                 failed:^{
                                     NSLog(@"  follows  failed ");
                                     [self.view hideToastActivity];
                                     _reloading = NO;
                                     [_refreshControl endRefreshing];
                                     
                                     [self performSelector:@selector(initFailedView) withObject:nil afterDelay:0.2];
                                 }];
}
-(void)initFansData
{
    _selected_state = fans_state;
    _button_fans.selected = YES;
    _button_follow.selected = NO;
    self.type = @"fans";
    
    if(_array_fansData && _array_fansData.count > 0)
    {
        if(_imageView_default)
        {
            _imageView_default.hidden = YES;
        }
        if(_array_fansData.count < 20)
        {
            [self initTableViewFootViewWithFlag:NO];
        }
        [_tableView_myFriends reloadData];
        _tableView_myFriends.hidden = NO;
    }
    else
    {
        [self getFansDataFromServer];
    }
}
-(void)getFansDataFromServer
{
    NSString *user_id_ = @"";
    if(self.user_id != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])//他人的个人中心
    {
        user_id_ = [NSString stringWithFormat:@"%d",self.user_id];
    }
    else
    {
        user_id_ = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    }
    
    if(_fans_pageNumber == 0)
    {
        _fans_pageNumber = 1;
    }
    [FriendsData getFriendsDataWithType:@"fans"
                              andUserid:user_id_
                               andCount:@"20"
                                andPage:[NSString stringWithFormat:@"%d",_fans_pageNumber]
                                success:^(NSArray *array){
                                    
                                    if(_imageView_failed)
                                    {
                                        _imageView_failed.hidden = YES;
                                    }
                                    
                                    [self.view hideToastActivity];
                                    _imageView_failed.hidden = YES;
                                    if((!array || array.count == 0) && (!_array_fansData || _array_fansData.count == 0))
                                    {
                                        [self performSelector:@selector(initDefaultView_fans) withObject:nil afterDelay:0.2]; //没有数据
                                    }
                                    
                                    else
                                    {
                                        if(_imageView_default)
                                        {
                                            _imageView_default.hidden = YES;
                                        }
                                        
                                        _reloading = NO;
                                        [_refreshControl endRefreshing];
                                        _fans_pageNumber++;
                                        if([array count] == 20)
                                        {
                                            _flag_canLoadMore_fans = YES;
                                            
                                            [_array_fansData addObjectsFromArray:array];
                                            [self initTableViewFootViewWithFlag:YES];
                                        }
                                        else
                                        {
                                            _flag_canLoadMore_fans = NO;
                                            
                                            [_array_fansData addObjectsFromArray:array];
                                            [self initTableViewFootViewWithFlag:NO];
                                        }
                                        [_tableView_myFriends reloadData];
                                        _tableView_myFriends.hidden = NO;
                                    }
                                }
                                 failed:^{
                                     NSLog(@"  fans  failed ");
                                     _reloading = NO;
                                     [_refreshControl endRefreshing];
                                     
                                     [self.view hideToastActivity];
                                     [self performSelector:@selector(initFailedView) withObject:nil afterDelay:0.2];
                                 }];
}
-(void)initDefaultView_fans
{
    if(_tableView_myFriends)
    {
        _tableView_myFriends.hidden = YES;
    }
    
    if(!_imageView_default)
    {
        _imageView_default = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height-373/2)/2, 640/2, 373/2)];
    }
    _imageView_default.hidden = NO;
    _imageView_default.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_imageView_default];
    UIImage *image = [UIImage imageNamed:@"Ta的粉丝为空"];
    if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
    {
        image = [UIImage imageNamed:@"我的粉丝为空"];
    }
    _imageView_default.image = image;
}
-(void)initDefaultView_follows
{
    if(_tableView_myFriends)
    {
        _tableView_myFriends.hidden = YES;
    }
    
    if(_imageView_failed)
    {
        _imageView_failed.hidden = YES;
    }
    if(!_imageView_default)
    {
        _imageView_default = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height-373/2)/2, 640/2, 373/2)];
    }
    _imageView_default.hidden = NO;
    _imageView_default.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_imageView_default];
    UIImage *image = [UIImage imageNamed:@"Ta的关注为空"];
    if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
    {
        image = [UIImage imageNamed:@"我的关注为空"];
    }
    _imageView_default.image = image;
}
-(void)initFailedView
{
    if(_imageView_default)
    {
        _imageView_default.hidden = YES;
    }
    if(!_imageView_failed)
    {
        float positionY = (ios7 ? 260/2 : 230/2);
        
        _imageView_failed = [[UIImageView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 640/2, [[UIScreen mainScreen] bounds].size.height - _headView.frame.size.height)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, positionY, 640/2, 360/2)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"notReachable"];
        [_imageView_failed addSubview:imageView];
        [imageView release];
    }
    _imageView_failed.backgroundColor = [UIColor clearColor];
    _imageView_failed.hidden = NO;
    //[_imageView_failed addTarget:self action:@selector(reloadPlanInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_imageView_failed];
}



#pragma mark -
#pragma mark --- UITableView - DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (_selected_state)
    {
        case follow_state:
        {
            return [_array_followsData count];
        }
            break;
        case fans_state:
        {
            return [_array_fansData count];
        }
            break;
            
        default:
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 138/2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyFriendsCell"];
    if(cell == nil)
    {
        cell = [[[MyFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyFriendsCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    switch (_selected_state)
    {
        case follow_state:
        {
            [cell initInfoWithUserData:_array_followsData atPosition:indexPath.row];
            
            //加载更多
            if(_flag_canLoadMore_follows && indexPath.row == [_array_followsData count]-1)
            {
                [self startFooterViewWithType:@"follows"];
            }
        }
            break;
            
        case fans_state:
        {
            [cell initInfoWithUserData:_array_fansData atPosition:indexPath.row];
            
            //加载更多
            if(_flag_canLoadMore_fans && indexPath.row == [_array_fansData count]-1)
            {
                [self startFooterViewWithType:@"fans"];
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}


#pragma mark -
#pragma mark --- UITableView - Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyFriendsCell *cell = (MyFriendsCell *)[tableView cellForRowAtIndexPath:indexPath];
    MineViewController *mineVC = [[MineViewController alloc] init];
    mineVC.user_id = cell.user_id;
    
//    if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
//    {
//        switch (_selected_state)
//        {
//            case follow_state:
//            {
//                mineVC.from = @"follows";
//            }
//                break;
//                
//            case fans_state:
//            {
//                mineVC.from = @"fans";
//            }
//                break;
//                
//            default:
//                break;
//        }
//    }
//    else
//    {
//        mineVC.from = @"";
//    }
    
    [self.navigationController pushViewController:mineVC animated:YES];
    [mineVC release];
}



#pragma mark –
#pragma mark --- 下拉刷新
- (void)pullRefreshHandler:(ODRefreshControl *)refreshControl
{
    NSLog(@" 下拉刷新 开始加载数据");
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToast:@"网络错误" duration:1 position:@"center" isShadow:NO];
        
        [_refreshControl endRefreshing];
        
        return;
    }
    if (_reloading == YES)
    {
        return;
    }
    _reloading = YES;
    
    if([self.type isEqualToString:@"follows"])
    {
        _follows_pageNumber = 1;
        _flag_canLoadMore_follows = YES;
        
        [_array_followsData removeAllObjects];
        [self getFollowsDataFromServer];
    }
    else if([self.type isEqualToString:@"fans"])
    {
        _fans_pageNumber = 1;
        _flag_canLoadMore_fans = YES;
        
        [_array_fansData removeAllObjects];
        [self getFansDataFromServer];
    }
}


#pragma mark -
#pragma mark --- clickBackButton
-(void)clickBackButton:(id)sender
{
    NSString *user_id_ = @"";
    if(self.user_id != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])//他人的个人中心
    {
        user_id_ = [NSString stringWithFormat:@"%d",self.user_id];
    }
    else
    {
        user_id_ = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    }
    [FriendsData cancleGetFriendsDataWithType:@"follows"
                                    andUserid:user_id_
                                     andCount:@"20"
                                      andPage:[NSString stringWithFormat:@"%d",_follows_pageNumber]
     ];
    [FriendsData cancleGetFriendsDataWithType:@"fans"
                                    andUserid:user_id_
                                     andCount:@"20"
                                      andPage:[NSString stringWithFormat:@"%d",_fans_pageNumber]
     ];
    
    
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
