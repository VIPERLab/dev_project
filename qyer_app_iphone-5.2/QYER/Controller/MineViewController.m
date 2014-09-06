//
//  MineViewController.m
//  QYER
//
//  Created by 我去 on 14-5-4.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "MineViewController.h"
#import "MyGuideViewController.h"
#import "Toast+UIView.h"
#import "MoreViewController.h"
#import "ChangeTableviewContentInset.h"
#import "UserInfoCell.h"
#import "UserInfo.h"
#import "UserInfoData.h"
#import "MyLastMinuteViewController.h"
#import "MyFriendsViewController.h"
#import "CCActiotSheet.h"
#import "WantGoViewController.h"
#import "HasGoneViewController.h"
#import "FollowAndUnfollow.h"
#import "Toast+UIView.h"
#import "PhotoListController.h"
#import "QYToolObject.h"
#import "UserAvatarData.h"
#import "PrivateChatViewController.h"
#import "UserPhotoData.h"
#import "CityLoginViewController.h"
#import "MyPlanViewController.h"
#import "NoteAndChatViewController.h"
#import "ODRefreshControl.h"
#import "DownloadViewController.h"
#import "MobClick.h"
#import "MyPostsViewController.h"
#import "ProduceMyImage.h"



#define   positionY_button_more     (ios7 ? (6+20) : 6)




@interface MineViewController ()

@end



@implementation MineViewController
@synthesize currentVC;
@synthesize user_id;
@synthesize imUserId;
@synthesize loginVC = _loginVC;
//@synthesize from;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut_Success) name:@"loginoutsuccess" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(privateChatUnReadMsgNum) name:@"privateChatUnReadMsgNum" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hotdot_phone:) name:@"hotdot_phone" object:nil];
        
    }
    return self;
}


-(void)dealloc
{
    QY_SAFE_RELEASE(_userInfo);
    QY_SAFE_RELEASE(_type);
    QY_SAFE_RELEASE(_loginVC);
    
    QY_VIEW_RELEASE(_tableview_mine);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"privateChatUnReadMsgNum" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"produceImage" object:nil];
    
    [super dealloc];
}


#pragma mark -
#pragma mark --- 推出登录页面
-(void)showLoginView
{
    CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
    navigationController.navigationBarHidden = YES;
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:navigationController animated:YES completion:nil];
    [cityLoginVC release];
}


#pragma mark -
#pragma mark --- viewWillAppear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"hotdot_phone"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:YES];
    }
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES) //未登录
    {
        if(!_flag_first) //未登录状态下首次进入个人中心弹出登录页面
        {
            _flag_first = YES;
            
            _clickType = @"";
            [self showLoginView];
        }
        else
        {
            [self initTableView];
        }
    }
    else
    {
        if(_userInfo)
        {
            return;
        }
        
        
        
        NSLog(@" self.user_id --- %d",self.user_id);
        NSLog(@"  --- %d",[self.navigationController.viewControllers count]);
        NSLog(@" userid --- %d",[[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue]);
        //只缓存我的详情:
        if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue] || [self.navigationController.viewControllers count] == 0)
        {
            [self getDataFromCache]; //缓存数据
        }
        
        
        if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        {
            _flag_getData = NO;
            return;
        }
        [self getDataFromServer];
    }
}
-(void)getDataFromServer
{
    [self.view makeToastActivity];
    
    //通过imUserId获取用户的详情:
    if(self.imUserId)
    {
        [self getUserInfoWithImUserId];
        return;
    }
    
    NSString *userid = nil;
    if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue]) //自己的个人中心
    {
        userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
        if(!userid)
        {
            [_refreshControl endRefreshing];
            return;
        }
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES && userid)
        {
            //先获取缓存数据:
            [self getCachedMineInfoData];
            
            if(_flag_getData)
            {
                NSLog(@" 已经成功获取到我的个人信息");
                [self.view hideToastActivity];
                //[self LoadDataDone];
                [_refreshControl endRefreshing];
                return;
            }
            else
            {
                [UserInfoData getMineInfoWithUserid:userid
                                         orImUserId:nil
                                            success:^(NSDictionary *dic){
                                                _reloading = NO;
                                                if(dic && [dic objectForKey:@"data"])
                                                {
                                                    NSLog(@" 获取我的个人信息成功 ");
                                                    _flag_getData = YES;
                                                    if(_userInfo)
                                                    {
                                                        [_userInfo release];
                                                    }
                                                    
                                                    [self.view hideToastActivity];
                                                    _userInfo = [[self processUserData:[dic objectForKey:@"data"]] retain];
                                                    
                                                    NSString * avatar = [[dic objectForKey:@"data"]objectForKey:@"avatar"];
                                                    [[NSUserDefaults standardUserDefaults] setObject:avatar forKey:@"usericon"];
                                                    [[NSUserDefaults standardUserDefaults] setObject:avatar forKey:@"avatar"];
                                                    
                                                    [_refreshControl endRefreshing];
                                                    [self initTableView];
                                                    //[self LoadDataDone];
                                                }
                                                else
                                                {
                                                    NSLog(@" 获取我的个人信息失败 --- 1");
                                                    _flag_getData = NO;
                                                    [self.view hideToastActivity];
                                                    [_refreshControl endRefreshing];
                                                }
                                            }
                                             failed:^{
                                                 NSLog(@" 获取我的个人信息失败 --- 2");
                                                 _flag_getData = NO;
                                                 _reloading = NO;
                                                 [self.view hideToastActivity];
                                                 [_refreshControl endRefreshing];
                                             }];
            }
        }
        else
        {
            NSLog(@" 用户未登录 ");
        }
    }
    else //他人的个人中心
    {
        userid = [NSString stringWithFormat:@"%d",self.user_id];
        
        if(_flag_getData)
        {
            NSLog(@" 已经成功获取到TA的个人信息 ");
            [self.view hideToastActivity];
            //[self LoadDataDone];
            [_refreshControl endRefreshing];
            return;
        }
        else
        {
            [UserInfoData getUserInfoWithUserId:userid
                                     orImUserId:nil
                                        success:^(NSDictionary *dic){
                                            _reloading = NO;
                                            if(dic && [dic objectForKey:@"data"])
                                            {
                                                NSLog(@" 获取TA的个人信息成功 ");
                                                _flag_getData = YES;
                                                if(_userInfo)
                                                {
                                                    [_userInfo release];
                                                }
                                                [self.view hideToastActivity];
                                                _userInfo = [[self processUserData:[dic objectForKey:@"data"]] retain];
                                                [_refreshControl endRefreshing];
                                                [self initTableView];
                                                //[self LoadDataDone];
                                            }
                                            else
                                            {
                                                NSLog(@" 获取TA的个人信息失败 --- 1");
                                                _flag_getData = NO;
                                                [self.view hideToastActivity];
                                                //[self LoadDataDone];
                                                [_refreshControl endRefreshing];
                                            }
                                        }
                                         failed:^{
                                             NSLog(@" 获取TA的个人信息失败 --- 2");
                                             _flag_getData = NO;
                                             _reloading = NO;
                                             [self.view hideToastActivity];
                                             //[self LoadDataDone];
                                             [_refreshControl endRefreshing];
                                         }];
        }
    }
}

-(void)getCachedMineInfoData
{
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    [UserInfoData getCachedMineInfoWithUserid:userid
                                   orImUserId:nil
                                      success:^(NSDictionary *dic){
                                          if(dic && [dic objectForKey:@"data"])
                                          {
                                              //NSLog(@" 获取我的个人信息成功 (缓存) ");
                                              
                                              if(_userInfo)
                                              {
                                                  [_userInfo release];
                                              }
                                              
                                              _userInfo = [[self processUserData:[dic objectForKey:@"data"]] retain];
                                              [self initTableView];
                                              //[self LoadDataDone];
                                              
                                          }
                                          else
                                          {
                                              //NSLog(@" 获取我的个人信息失败 (缓存) 1");
                                          }
                                      }
                                       failed:^{
                                           //NSLog(@" 获取我的个人信息失败 (缓存) 2");
                                       }];
}
-(void)getUserInfoWithImUserId
{
    if(_flag_getData)
    {
        //NSLog(@" 已经成功获取到TA的个人信息 ");
        [self.view hideToastActivity];
        return;
    }
    else
    {
        [UserInfoData getUserInfoWithUserId:nil
                                 orImUserId:self.imUserId
                                    success:^(NSDictionary *dic){
                                        _reloading = NO;
                                        if(dic && [dic objectForKey:@"data"])
                                        {
                                            //NSLog(@" 获取TA的个人信息成功 ");
                                            _flag_getData = YES;
                                            if(_userInfo)
                                            {
                                                [_userInfo release];
                                            }
                                            [self.view hideToastActivity];
                                            _userInfo = [[self processUserData:[dic objectForKey:@"data"]] retain];
                                            self.user_id = _userInfo.user_id;
                                            [_refreshControl endRefreshing];
                                            [self initTableView];
                                            //[self LoadDataDone];
                                        }
                                        else
                                        {
                                            //NSLog(@" 获取TA的个人信息失败 --- 1");
                                            _flag_getData = NO;
                                            [self.view hideToastActivity];
                                            //[self LoadDataDone];
                                            [_refreshControl endRefreshing];
                                        }
                                    }
                                     failed:^{
                                         NSLog(@" 获取TA的个人信息失败 --- 2");
                                         _flag_getData = NO;
                                         _reloading = NO;
                                         [self.view hideToastActivity];
                                         //[self LoadDataDone];
                                         [_refreshControl endRefreshing];
                                     }];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _clickType = @"";
    
    [self.view hideToast];
    [self.view hideToastActivity];
    
}

-(UserInfo *)processUserData:(NSDictionary *)dic
{
    UserInfo *userinfo_ = [[UserInfo alloc] init];
    
    userinfo_.user_id = [[dic objectForKey:@"user_id"] intValue];
    userinfo_.im_user_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"im_user_id"]];
    userinfo_.can_dm = [[dic objectForKey:@"can_dm"] boolValue];
    userinfo_.username = [NSString stringWithFormat:@"%@",[dic objectForKey:@"username"]];
    userinfo_.gender = [[dic objectForKey:@"gender"] intValue];
    userinfo_.title = [NSString stringWithFormat:@"%@",[dic objectForKey:@"title"]];
    userinfo_.avatar = [NSString stringWithFormat:@"%@",[dic objectForKey:@"avatar"]];
    userinfo_.cover = [NSString stringWithFormat:@"%@",[dic objectForKey:@"cover"]];
    userinfo_.footprint = [dic objectForKey:@"map"];
    userinfo_.follow_status = [NSString stringWithFormat:@"%@",[dic objectForKey:@"follow_status"]];
    userinfo_.fans = [[dic objectForKey:@"fans"] intValue];
    userinfo_.follow = [[dic objectForKey:@"follow"] intValue];
    userinfo_.countries = [[dic objectForKey:@"countries"] intValue];
    userinfo_.cities = [[dic objectForKey:@"cities"] intValue];
    userinfo_.pois = [[dic objectForKey:@"pois"] intValue];
    userinfo_.trips = [[dic objectForKey:@"trips"] intValue];
    userinfo_.wants = [[dic objectForKey:@"wants"] intValue];
    
    return [userinfo_ autorelease];
}
-(void)getDataFromCache
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"mineinfo_%d",self.user_id]];
    if(dic)
    {
        _userInfo = [[self processUserData:[dic objectForKey:@"data"]] retain];
        [self initTableView];
    }
}

#pragma mark -
#pragma mark --- 构建View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(produceImage:) name:@"produceImage" object:nil];
    
    
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
    rootView.backgroundColor = [UIColor whiteColor];
    rootView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}

-(void)resetRootViewWIthType:(BOOL)flag
{
    if(!flag)
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height;
        self.view.frame = newFrame;
        
        
        newFrame = _tableview_mine.frame;
        if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
        {
            newFrame.size.height = [self.view bounds].size.height-64;
            _tableview_mine.frame = newFrame;
        }
        else
        {
            newFrame.size.height = [self.view bounds].size.height-RootViewControllerFootViewHeight-64;
            _tableview_mine.frame = newFrame;
        }
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        newFrame = _tableview_mine.frame;
        if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
        {
            newFrame.size.height = [self.view bounds].size.height-64;
            _tableview_mine.frame = newFrame;
        }
        else
        {
            newFrame.size.height = [self.view bounds].size.height-RootViewControllerFootViewHeight-64;
            _tableview_mine.frame = newFrame;
        }
    }
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
    _titleLabel.text = @"我的";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    
    
    
    //更多按钮:
    UIButton *button_more = [UIButton buttonWithType:UIButtonTypeCustom];
    button_more.frame = CGRectMake(276, positionY_button_more, 76/2, 62/2);
    [button_more setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [button_more addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:button_more];
    
    
    if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
    {
        _titleLabel.text = @"个人详情";
        
        button_more.hidden = YES;
        
        //返回按钮:
        UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor clearColor];
        _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
        [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:_backButton];
        
    }else{
        
        //消息: add by zyh
        button_meassage = [UIButton buttonWithType:UIButtonTypeCustom];
        button_meassage.frame = CGRectMake(5, positionY_backbutton, 40, 40);
        NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
        NSInteger totalPriChatNum = [myUserDefault integerForKey:TotalPrivateChatNumber];
        
        NSInteger notificationUnreadCount=[myUserDefault integerForKey:NotificationUnreadCount];
        NSString* count=[NSString stringWithFormat:@"%d",notificationUnreadCount+totalPriChatNum];
        [button_meassage setBackgroundImage:[self getMessageButtonImage:[UIImage imageNamed:@"press_remind"] count:count] forState:UIControlStateNormal];
        [button_meassage addTarget:self action:@selector(clickMeassageButton) forControlEvents:UIControlEventTouchUpInside];
        
        [_headView addSubview:button_meassage];
        
    }
    [_titleLabel release];
    
}

-(void)initTableView
{
    if(!_tableview_mine)
    {
        if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
        {
            _tableview_mine = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, [self.view bounds].size.height-64)];
            if(!ios7)
            {
                _tableview_mine.frame = CGRectMake(0, 44, 320, [self.view bounds].size.height-44);
            }
            _tableview_mine.backgroundColor = [UIColor clearColor];
            _tableview_mine.separatorColor = [UIColor clearColor];
            _tableview_mine.dataSource = self;
            _tableview_mine.delegate = self;
        }
        else
        {
            _tableview_mine = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, [self.view bounds].size.height-RootViewControllerFootViewHeight-64)];
            if(!ios7)
            {
                _tableview_mine.frame = CGRectMake(0, 44, 320, [self.view bounds].size.height-RootViewControllerFootViewHeight-44);
            }
            _tableview_mine.backgroundColor = [UIColor clearColor];
            _tableview_mine.separatorColor = [UIColor clearColor];
            _tableview_mine.dataSource = self;
            _tableview_mine.delegate = self;
        }
    }
    
    [self.view addSubview:_tableview_mine];
    [self.view bringSubviewToFront:_headView];
    [_tableview_mine reloadData];
    
    
    
    //下拉刷新:
    if(!_refreshControl && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
    {
        _refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableview_mine];
        [_refreshControl addTarget:self action:@selector(pullRefreshHandler:) forControlEvents:UIControlEventValueChanged];
    }
}



#pragma mark -
#pragma mark --- UITableView - DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //未登录
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
    {
        return 7;
    }
    else
    {
        if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue]) //我的个人中心
        {
            return 7;
        }
        else //TA的个人中心比我的个人中心少了一个‘我的锦囊’条目
        {
            return 5;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return height_imageView_user;
    }
    else if(indexPath.row == 1)
    {
        return height_imageView_map + 51;
    }
    else
    {
        return 44;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        UserImageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserImageViewCell"];
        if(cell == nil)
        {
            cell = [[[UserImageViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserImageViewCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
        {
            NSLog(@"未登录");
            [cell initWithNotLogin];
        }
        
        else if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue]) //我的个人中心
        {
            NSLog(@"我的个人中心");
            [cell initInfoWithUserData:_userInfo mine:YES];
        }
        else
        {
            NSLog(@"TA的个人中心");
            [cell initInfoWithUserData:_userInfo mine:NO];
        }
        
        return cell;
    }
    else if (indexPath.row == 1)
    {
        UserMapCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserMapCell"];
        if(cell == nil)
        {
            cell = [[[UserMapCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserMapCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
        
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
        {
            NSLog(@"未登录－1");
            [cell initWithNotLogin];
        }
        
        else if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue]) //我的个人中心
        {
            NSLog(@"我的个人中心-1");
            [cell initInfoWithUserData:_userInfo mine:YES];
        }
        else
        {
            NSLog(@"TA的个人中心-1");
            [cell initInfoWithUserData:_userInfo mine:NO];
        }
        
        return cell;
    }
    else
    {
        UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserInfoCell"];
        if(cell == nil)
        {
            cell = [[[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserInfoCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.backgroundColor = [UIColor clearColor];
        
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
        {
            NSLog(@"未登录－2");
            if (indexPath.row == 2)
            {
                cell.label_title.text = [NSString stringWithFormat:@"我的想去"];
            }
            else if(indexPath.row == 3)
            {
                cell.label_title.text = @"我的锦囊";
            }
            else if (indexPath.row == 4)
            {
                cell.label_title.text = @"我的行程";
            }
            else if (indexPath.row == 5)
            {
                cell.label_title.text = @"我的折扣";
            }
            else if (indexPath.row == 6)
            {
                cell.label_title.text = @"我的帖子";
            }
        }
        
        else if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue]) //我的个人中心
        {
            if (indexPath.row == 2)
            {
                if(_userInfo.wants == 0)
                {
                    cell.label_title.text = [NSString stringWithFormat:@"我的想去"];
                }
                else
                {
                    cell.label_title.text = [NSString stringWithFormat:@"我的想去（%d）",_userInfo.wants];
                }
            }
            else if(indexPath.row == 3)
            {
                cell.label_title.text = @"我的锦囊";
            }
            else if (indexPath.row == 4)
            {
                if(_userInfo && _userInfo.trips > 0)
                {
                    cell.label_title.text = [NSString stringWithFormat:@"我的行程（%d）",_userInfo.trips];
                }
                else
                {
                    cell.label_title.text = @"我的行程";
                }
            }
            else if (indexPath.row == 5)
            {
                cell.label_title.text = @"我的折扣";
            }
            else if (indexPath.row == 6)
            {
                cell.label_title.text = @"我的帖子";
            }
        }
        else //TA的个人中心
        {
            if (indexPath.row == 2)
            {
                if(_userInfo.wants == 0)
                {
                    cell.label_title.text = [NSString stringWithFormat:@"TA的想去"];
                }
                else
                {
                    cell.label_title.text = [NSString stringWithFormat:@"TA的想去（%d）",_userInfo.wants];
                }
            }
            else if(indexPath.row == 3)
            {
                if(_userInfo.trips == 0)
                {
                    cell.label_title.text = [NSString stringWithFormat:@"TA的行程"];
                }
                else
                {
                    cell.label_title.text = [NSString stringWithFormat:@"TA的行程（%d）",_userInfo.trips];
                }
            }
            else if (indexPath.row == 4)
            {
                cell.label_title.text = @"Ta的游记";
            }
        }
        return cell;
    }
}



#pragma mark -
#pragma mark --- UITableView - Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_flag_click)
    {
        return;
    }
    _flag_click = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    
    
    if(indexPath.row > 1)
    {
        UserInfoCell *cell = (UserInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
        if([cell.label_title.text rangeOfString:@"我的锦囊"].location != NSNotFound)
        {
            [MobClick event:@"mineClickGuide"];
            if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
            {
                [self showMyGuideWithType:1];
            }
            else
            {
                [self showMyGuideWithType:0];
            }
        }
        else if([cell.label_title.text rangeOfString:@"我的行程"].location != NSNotFound)
        {
            [MobClick event:@"mineClickPlan"];
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
            {
                _clickType = @"我的行程";
                [self showLoginView];
            }
            else
            {
                MyPlanViewController *planVC = [[MyPlanViewController alloc] init];
                [self.currentVC.navigationController pushViewController:planVC animated:YES];
                [planVC release];
            }
        }
        else if([cell.label_title.text rangeOfString:@"TA的行程"].location != NSNotFound)
        {
            [MobClick event:@"mineClickPlan"];
            MyPlanViewController *planVC = [[MyPlanViewController alloc] init];
            planVC.userId = [NSString stringWithFormat:@"%d",self.user_id];
            [self.navigationController pushViewController:planVC animated:YES];
            [planVC release];
        }
        else if([cell.label_title.text rangeOfString:@"我的折扣"].location != NSNotFound)
        {
            [MobClick event:@"mineClickDisc"];
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
            {
                _clickType = @"我的折扣";
                [self showLoginView];
            }
            else
            {
                if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
                {
                    MyLastMinuteViewController *lastMinutVC = [[MyLastMinuteViewController alloc] init];
                    [self.navigationController pushViewController:lastMinutVC animated:YES];
                    [lastMinutVC release];
                }
                else
                {
                    MyLastMinuteViewController *lastMinutVC = [[MyLastMinuteViewController alloc] init];
                    [self.currentVC.navigationController pushViewController:lastMinutVC animated:YES];
                    [lastMinutVC release];
                }
            }
        }
        else if([cell.label_title.text rangeOfString:@"我的想去"].location != NSNotFound)
        {
            [MobClick event:@"mineClickLike"];
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
            {
                _clickType = @"我的想去";
                [self showLoginView];
            }
            else
            {
                if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
                {
                    WantGoViewController *wantGoVC = [[WantGoViewController alloc] init];
                    wantGoVC.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue];
                    [self.navigationController pushViewController:wantGoVC animated:YES];
                    [wantGoVC release];
                }
                else
                {
                    WantGoViewController *wantGoVC = [[WantGoViewController alloc] init];
                    wantGoVC.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue];
                    [self.currentVC.navigationController pushViewController:wantGoVC animated:YES];
                    [wantGoVC release];
                }
            }
        }
        else if([cell.label_title.text rangeOfString:@"TA的想去"].location != NSNotFound)
        {
            WantGoViewController *wantGoVC = [[WantGoViewController alloc] init];
            wantGoVC.user_id = self.user_id;
            [self.navigationController pushViewController:wantGoVC animated:YES];
            [wantGoVC release];
        }
        else if([cell.label_title.text rangeOfString:@"我的帖子"].location != NSNotFound)
        {
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
            {
                _clickType = @"我的帖子";
                [self showLoginView];
            }
            else
            {
                if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
                {
                    MyPostsViewController *myPostVC = [[MyPostsViewController alloc] init];
                    myPostVC.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue];
                    [self.navigationController pushViewController:myPostVC animated:YES];
                    [myPostVC release];
                }
                else
                {
                    MyPostsViewController *myPostVC = [[MyPostsViewController alloc] init];
                    myPostVC.user_id = self.user_id;
                    [self.currentVC.navigationController pushViewController:myPostVC animated:YES];
                    [myPostVC release];
                }
            }
        }
        else if([cell.label_title.text rangeOfString:@"Ta的游记"].location != NSNotFound)
        {
            MyPostsViewController *myPostVC = [[MyPostsViewController alloc] init];
            myPostVC.user_id = self.user_id;
            [self.navigationController pushViewController:myPostVC animated:YES];
            [myPostVC release];
        }
    }
}



#pragma mark -
#pragma mark --- 我的锦囊
-(void)showMyGuideWithType:(BOOL)flag
{
    if(flag)
    {
        DownloadViewController *downloadVC = [[DownloadViewController alloc] init];
        downloadVC.showNavigationBar = YES;
        [self.navigationController pushViewController:downloadVC animated:YES];
        [downloadVC release];
    }
    else
    {
        DownloadViewController *downloadVC = [[DownloadViewController alloc] init];
        downloadVC.showNavigationBar = YES;
        [self.currentVC.navigationController pushViewController:downloadVC animated:YES];
        [downloadVC release];
    }
}


#pragma mark -
#pragma mark --- UserImageViewCell - Delegate
-(void)loginIn:(UserImageViewCell *)cell
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view makeToast:@"网络错误" duration:1 position:@"center" isShadow:NO];
        return;
    }
    if(_flag_click)
    {
        return;
    }
    _flag_click = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    
    
    
    CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
    navigationController.navigationBarHidden = YES;
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:navigationController animated:YES completion:nil];
    //[self presentViewController:navigationController animated:YES completion:nil];
    [cityLoginVC release];
}
-(void)addFollow:(UserImageViewCell *)cell
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view makeToast:@"网络错误" duration:1 position:@"center" isShadow:NO];
        return;
    }
    if(_flag_click)
    {
        return;
    }
    _flag_click = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    
    
    
//    _follow_eachother = NO;
    if([cell.follow_status isEqualToString:@"已关注"]) //关注状态 (关注TA/已关注/相互关注)
    {
        NSArray *array = [NSArray arrayWithObjects:@"确定",nil];
        CCActiotSheet *sheet = [[CCActiotSheet alloc] initWithTitle:@"确定要取消关注吗？"
                                                        andDelegate:self
                                                       andArrayData:array];
        sheet.tag = 1;
        [sheet show];
    }
    else if ([cell.follow_status isEqualToString:@"相互关注"])
    {
//        _follow_eachother = YES;
        NSArray *array = [NSArray arrayWithObjects:@"确定",nil];
        CCActiotSheet *sheet = [[CCActiotSheet alloc] initWithTitle:@"确定要取消关注吗？"
                                                        andDelegate:self
                                                       andArrayData:array];
        sheet.tag = 1;
        [sheet show];
    }
    else
    {
        NSLog(@" 加关注");
        [FollowAndUnfollow followWithUserid:[NSString stringWithFormat:@"%d",self.user_id]
                                    success:^(BOOL flag, NSString *status){
                                        if(flag)
                                        {
                                            NSLog(@"关注成功");
                                            
                                            [self.view hideToast];
                                            [self.view hideToastActivity];
                                            [self.view makeToast:@"关注成功" duration:1 position:@"center" isShadow:NO];
                                            
                                            [self processDataWhenFollowSuccess:status];
                                        }
                                        else
                                        {
                                            NSLog(@"关注失败");
                                        }
                                    }
                                     failed:^{
                                         NSLog(@"关注失败");
                                     }];
    }
}
-(void)processDataWhenFollowSuccess:(NSString *)status
{
//    if(_follow_eachother)
//    {
//        _userInfo.follow_status = @"相互关注";
//    }
//    else if(self.from && [self.from isEqualToString:@"fans"])
//    {
//        _userInfo.follow_status = @"相互关注";
//    }
//    else
//    {
//        _userInfo.follow_status = @"已关注";
//    }
    
    if(!status || status.length < 1) //特殊情况
    {
        _userInfo.follow_status = @"已关注";
    }
    else
    {
        _userInfo.follow_status = status;
    }
    _userInfo.fans++;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableview_mine reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)processDataWhenUnFollowSuccess
{
    _userInfo.follow_status = @"关注TA";
    _userInfo.fans--;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_tableview_mine reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)sendPersonaLetter:(UserImageViewCell *)cell
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view makeToast:@"网络错误" duration:1 position:@"center" isShadow:NO];
        return;
    }
    if(_flag_click)
    {
        return;
    }
    _flag_click = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    
    
    
    NSLog(@" 发送私信");
    PrivateChatViewController *privateChatVC = [[PrivateChatViewController alloc] init];
    privateChatVC.toUserInfo = _userInfo;
    if(self.navigationController.viewControllers.count == 0)
    {
        [self.currentVC.navigationController pushViewController:privateChatVC animated:YES];
    }
    else
    {
        [self.navigationController pushViewController:privateChatVC animated:YES];
    }
    [privateChatVC release];
}
-(void)changeUserAvatar:(UserImageViewCell *)cell
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view makeToast:@"网络错误" duration:1 position:@"center" isShadow:NO];
        return;
    }
    if(self.user_id != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
    {
        return;
    }
    if(_flag_click)
    {
        return;
    }
    _flag_click = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    
    
    NSArray *array = [NSArray arrayWithObjects:@"从相册选择",@"拍照",nil];
    CCActiotSheet *sheet = [[CCActiotSheet alloc] initWithTitle:@"更换头像"
                                                    andDelegate:self
                                                   andArrayData:array];
    sheet.tag = 2;
    [sheet show];
}
-(void)changeUserPhoto:(UserImageViewCell *)cell
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view makeToast:@"网络错误" duration:1 position:@"center" isShadow:NO];
        return;
    }
    if(self.user_id != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
    {
        return;
    }
    if(_flag_click)
    {
        return;
    }
    _flag_click = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    NSLog(@" changeUserPhoto  changeUserPhoto ");
    
    
    NSArray *array = [NSArray arrayWithObjects:@"从相册选择",@"拍照",nil];
    CCActiotSheet *sheet = [[CCActiotSheet alloc] initWithTitle:@"更换头图"
                                                    andDelegate:self
                                                   andArrayData:array];
    sheet.tag = 3;
    [sheet show];
}



#pragma mark -
#pragma mark --- CCActiotSheet - Delegate
- (void)ccActionSheet:(CCActiotSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1 && buttonIndex == 1)
    {
        NSLog(@" 确定 --- 取消关注");
        [FollowAndUnfollow unFollowWithUserid:[NSString stringWithFormat:@"%d",self.user_id]
                                      success:^(BOOL flag, NSString *status){
                                          if(flag)
                                          {
                                              NSLog(@"取消关注成功");
                                              
                                              [self.view hideToast];
                                              [self.view hideToastActivity];
                                              [self.view makeToast:@"取消关注成功" duration:1 position:@"center" isShadow:NO];
                                              
                                              [self processDataWhenUnFollowSuccess];
                                          }
                                          else
                                          {
                                              NSLog(@"取消关注失败");
                                              
                                              [self.view hideToast];
                                              [self.view hideToastActivity];
                                              [self.view makeToast:@"取消关注失败" duration:1 position:@"center" isShadow:NO];
                                          }
                                      }
                                       failed:^{
                                           NSLog(@"取消关注失败");
                                           
                                           [self.view hideToast];
                                           [self.view hideToastActivity];
                                           [self.view makeToast:@"取消关注失败" duration:1 position:@"center" isShadow:NO];
                                       }];
    }
    else if (actionSheet.tag == 2)  //头像
    {
        _type = @"avatar";
        
        if(buttonIndex == 1)
        {
            NSLog(@"相册");
            
            if(!_produceMyImage)
            {
                _produceMyImage = [[ProduceMyImage alloc] init];
            }
            [_produceMyImage getVC:[[[[UIApplication sharedApplication] delegate] window] rootViewController] ];
            [_produceMyImage selectImageFromAlbum];
        }
        else if(buttonIndex == 2)
        {
            NSLog(@"拍照");
            
            if(!_produceMyImage)
            {
                _produceMyImage = [[ProduceMyImage alloc] init];
            }
            [_produceMyImage getVC:[[[[UIApplication sharedApplication] delegate] window] rootViewController] ];
            [_produceMyImage takePhoto];
        }
    }
    else if (actionSheet.tag == 3) //头图
    {
        _type = @"photo";
        
        if(buttonIndex == 1)
        {
            NSLog(@"相册");
            
            if(!_produceMyImage)
            {
                _produceMyImage = [[ProduceMyImage alloc] init];
            }
            [_produceMyImage getVC:[[[[UIApplication sharedApplication] delegate] window] rootViewController] ];
            [_produceMyImage selectImageFromAlbum];
        }
        else if(buttonIndex == 2)
        {
            NSLog(@"拍照");
            
            if(!_produceMyImage)
            {
                _produceMyImage = [[ProduceMyImage alloc] init];
            }
            [_produceMyImage getVC:[[[[UIApplication sharedApplication] delegate] window] rootViewController] ];
            [_produceMyImage takePhoto];
        }
    }
}





#pragma mark -
#pragma mark --- UserMapCell - Delegate
-(void)selectedUserFootprint
{
    if(_flag_click)
    {
        return;
    }
    _flag_click = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    
    
    [MobClick event:@"mineClickBeen"];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
    {
        _clickType = @"我的足迹";
        [self showLoginView];
    }
    else
    {
        if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
        {
            HasGoneViewController *hasGoneVC = [[HasGoneViewController alloc] init];
            hasGoneVC.user_id = self.user_id;
            [self.navigationController pushViewController:hasGoneVC animated:YES];
            [hasGoneVC release];
        }
        else
        {
            HasGoneViewController *hasGoneVC = [[HasGoneViewController alloc] init];
            hasGoneVC.user_id = self.user_id;
            [self.currentVC.navigationController pushViewController:hasGoneVC animated:YES];
            [hasGoneVC release];
        }
    }
}




#pragma mark -
#pragma mark --- 我的关注和粉丝
-(void)showFollowsAndFans:(UserImageViewCell *)cell withType:(NSString *)type
{
    if(_flag_click)
    {
        return;
    }
    _flag_click = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    
    
    [MobClick event:@"mineClickFFer"];
    if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
    {
        MyFriendsViewController *friendVC = [[MyFriendsViewController alloc] init];
        friendVC.user_id = self.user_id;
        friendVC.type = type;
        [self.navigationController pushViewController:friendVC animated:YES];
        [friendVC release];
    }
    else
    {
        MyFriendsViewController *friendVC = [[MyFriendsViewController alloc] init];
        friendVC.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue];
        friendVC.type = type;
        [self.currentVC.navigationController pushViewController:friendVC animated:YES];
        [friendVC release];
    }
}




#pragma mark –
#pragma mark --- 下拉刷新
- (void)pullRefreshHandler:(ODRefreshControl *)refreshControl
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [refreshControl endRefreshing];
        
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
    }
    
    else if (_reloading == YES)
    {
        return;
    }
    _reloading = YES;
    
    _flag_getData = NO;
    [self getDataFromServer];
}




#pragma mark -
#pragma mark --- 处理图像
-(void)produceImage:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    UIImage *image = [dic objectForKey:@"image"];
    image = [QYToolObject scaleImage:image toScale:0.6];
    
    
    if(_type && [_type isEqualToString:@"avatar"])
    {
        [self processAvatar:image];
    }
    else if(_type && [_type isEqualToString:@"photo"])
    {
        [self processPhoto:image];
    }
}



#pragma -
#pragma --- 处理用户头像
-(void)processAvatar:(UIImage *)image
{
    [self.view hideToastActivity];
    [self.view makeToastActivity];
    
    [UserAvatarData postAvatarWithImage:image
                                success:^(NSDictionary *dic){
                                    NSLog(@"用户头像:%@",dic);
                                    _userInfo.avatar = [[dic objectForKey:@"data"] objectForKey:@"avatar"];
                                    [self updateAvatar];
                                }
                                 failed:^{
                                     
                                 }];
}
-(void)updateAvatar
{
    [self.view hideToastActivity];
    [_tableview_mine reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}



#pragma -
#pragma --- 处理用户头图
-(void)processPhoto:(UIImage *)image
{
    [self.view hideToastActivity];
    [self.view makeToastActivity];
    
    [UserPhotoData postPhotoWithImage:image
                              success:^(NSDictionary *dic){
                                  NSLog(@"用户头图:%@",dic);
                                  _userInfo.cover = [[dic objectForKey:@"data"] objectForKey:@"cover"];
                                  [self updatePhoto];
                              }
                               failed:^{
                                   
                               }];
}
-(void)updatePhoto
{
    [self.view hideToastActivity];
    [_tableview_mine reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}




#pragma mark -
#pragma mark --- 点击更多
-(void)clickMoreButton:(id)sender
{
    MoreViewController *moreVC = [[MoreViewController alloc] init];
    [self.currentVC.navigationController pushViewController:moreVC animated:YES];
    [moreVC release];
}



#pragma mark -
#pragma mark --- 点击返回
-(void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark --- 登录成功
-(void)loginIn_Success
{
    _flag_loginOut = NO;
    self.imUserId = nil;
    self.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue];

    
    [self getDataFromCache]; //缓存数据
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        _flag_getData = NO;
        return;
    }
    [self getDataFromServer];
    
    
    [self performSelector:@selector(processClickInfo) withObject:nil afterDelay:0.5];
    
    
    //add by zyh
    [self performSelector:@selector(privateChatUnReadMsgNum) withObject:nil afterDelay:0];
}
-(void)loginOut_Success
{
    _flag_loginOut = YES;
    _flag_getData = NO;
    _reloading = NO;

    [button_meassage setBackgroundImage:[self getMessageButtonImage:[UIImage imageNamed:@"press_remind"] count:0] forState:UIControlStateNormal];

    
    if(_refreshControl)
    {
        [_refreshControl removeFromSuperview];
        [_refreshControl release];
        _refreshControl = nil;
    }
    [self initTableView];
}
-(void)resetView
{
    if(_flag_loginOut) //已登出
    {
        self.user_id = 0;
        self.imUserId = nil;
        [UserInfoData cleanInfo:_userInfo];
        [self initTableView];
    }
    
    if(_tableview_mine)
    {
        [_tableview_mine reloadData];
    }
}



#pragma mark -
#pragma mark --- 未登录之前选择‘行程/去过/想去’等
-(void)processClickInfo
{
    if(!_clickType || _clickType.length < 2)
    {
        return;
    }
    else
    {
        if([_clickType isEqualToString:@"我的足迹"])
        {
            [self selectedUserFootprint];
        }
        else if ([_clickType isEqualToString:@"我的行程"])
        {
            MyPlanViewController *planVC = [[MyPlanViewController alloc] init];
            [self.currentVC.navigationController pushViewController:planVC animated:YES];
            [planVC release];
        }
        else if ([_clickType isEqualToString:@"我的折扣"])
        {
            if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
            {
                MyLastMinuteViewController *lastMinutVC = [[MyLastMinuteViewController alloc] init];
                [self.navigationController pushViewController:lastMinutVC animated:YES];
                [lastMinutVC release];
            }
            else
            {
                MyLastMinuteViewController *lastMinutVC = [[MyLastMinuteViewController alloc] init];
                [self.currentVC.navigationController pushViewController:lastMinutVC animated:YES];
                [lastMinutVC release];
            }
        }
        else if ([_clickType isEqualToString:@"我的想去"])
        {
            if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
            {
                WantGoViewController *wantGoVC = [[WantGoViewController alloc] init];
                wantGoVC.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue];
                [self.navigationController pushViewController:wantGoVC animated:YES];
                [wantGoVC release];
            }
            else
            {
                WantGoViewController *wantGoVC = [[WantGoViewController alloc] init];
                wantGoVC.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue];
                [self.currentVC.navigationController pushViewController:wantGoVC animated:YES];
                [wantGoVC release];
            }
        }
        else if ([_clickType isEqualToString:@"我的帖子"])
        {
            if(self.navigationController.viewControllers && self.navigationController.viewControllers.count != 0)
            {
                MyPostsViewController *myPostVC = [[MyPostsViewController alloc] init];
                myPostVC.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue];
                [self.navigationController pushViewController:myPostVC animated:YES];
                [myPostVC release];
            }
            else
            {
                MyPostsViewController *myPostVC = [[MyPostsViewController alloc] init];
                myPostVC.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue];
                [self.currentVC.navigationController pushViewController:myPostVC animated:YES];
                [myPostVC release];
            }
        }
    }
    
    _clickType = @"";
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



#pragma mark -
#pragma mark --- 修改状态
-(void)changeFlag
{
    _flag_click = NO;
}


#pragma mark -
#pragma mark --- 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  add by zyh
 *
 */
-(UIImage*)getMessageButtonImage:(UIImage*)btn_image count:(NSString*)_count{
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue];
    if (_count && isLogin && [_count intValue]!=0) {
        if([_count intValue]>99){
            _count=@"99+";
        }
        UIImage* numberImg=[UIImage imageNamed:@"number_bg.png"];
        CGSize count_size=[_count sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(80, 80) lineBreakMode:NSLineBreakByWordWrapping];
        if (count_size.width<24) {
            count_size=CGSizeMake(24, 24);
        }else if(count_size.width>35){
            count_size=CGSizeMake(35, 24);
        }
        CGSize newImageSize = CGSizeMake(80, 80);
        
        UIGraphicsBeginImageContext(newImageSize);
        
        [btn_image drawInRect:CGRectMake(0, 0, newImageSize.width, newImageSize.height)];
        [numberImg drawInRect:CGRectMake(45, 20, count_size.width+2, count_size.height+2)];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        [_count drawInRect:CGRectMake(46,18,count_size.width,count_size.height) withFont:[UIFont systemFontOfSize:20] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
        
        UIImage *imagePNG = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return imagePNG;
    }
    
    return btn_image;
}


//*************** add by zyh
-(void)clickMeassageButton
{
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue];
    if (!isLogin) {
        //未登录状态用户提示登录
        CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
        navigationController.navigationBarHidden = YES;
        [currentVC presentViewController:navigationController animated:YES completion:nil];
        [cityLoginVC release];
        
    }else{
//        NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
//        NSInteger notificationUnreadCount=[myUserDefault integerForKey:NotificationUnreadCount];
//        if (notificationUnreadCount!=0) {
//            [[NSUserDefaults standardUserDefaults] setInteger:0  forKey:NotificationUnreadCount];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
        
        NoteAndChatViewController *noteVc = [[NoteAndChatViewController alloc]init];
        [self.currentVC.navigationController pushViewController:noteVc animated:YES];
        [noteVc release];
    }
    
}
-(void)privateChatUnReadMsgNum{
    
    NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
    NSInteger totalPriChatNum = [myUserDefault integerForKey:TotalPrivateChatNumber];
    
    NSInteger notificationUnreadCount=[myUserDefault integerForKey:NotificationUnreadCount];
    NSString* count=[NSString stringWithFormat:@"%d",notificationUnreadCount+totalPriChatNum];
    [button_meassage setBackgroundImage:[self getMessageButtonImage:[UIImage imageNamed:@"press_remind"] count:count] forState:UIControlStateNormal];
    
    if ([count intValue] == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isShowNoteMsg" object:nil userInfo:@{@"count":@(YES)}];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"isShowNoteMsg" object:nil userInfo:@{@"count":@(NO)}];
    }
    
    /*
     
     NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
     NSInteger totalPriChatNum = [myUserDefault integerForKey:TotalPrivateChatNumber];
     
     NSInteger notificationUnreadCount=[myUserDefault integerForKey:NotificationUnreadCount];
     NSString* count=[NSString stringWithFormat:@"%d",notificationUnreadCount+totalPriChatNum];
     [button_meassage setBackgroundImage:[self getMessageButtonImage:[UIImage imageNamed:@"press_remind"] count:count] forState:UIControlStateNormal];
     
     */
}
//**************** add by zyh



@end

