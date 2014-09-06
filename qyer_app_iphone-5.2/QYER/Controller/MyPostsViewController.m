//
//  MyPostsViewController.m
//  QYER
//
//  Created by 我去 on 14-7-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "MyPostsViewController.h"
#import "TravelsCell.h"
#import "MicroTravelData.h"
#import "BBSDetailViewController.h"
#import "Toast+UIView.h"



#define     positionY_titlelabel        (ios7 ? (4+20) : 6)
#define     positionY_backbutton        (ios7 ? 20 : 0)
#define     TravelListCountOfOnePage    10




@interface MyPostsViewController ()

@end






@implementation MyPostsViewController
@synthesize user_id;

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
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_toolBar);
    QY_VIEW_RELEASE(_footerView);
    QY_VIEW_RELEASE(_tableView_myPost);
    QY_VIEW_RELEASE(_imageView_default);
    
    QY_MUTABLERECEPTACLE_RELEASE(_array_travel);
    QY_MUTABLERECEPTACLE_RELEASE(_array_collect);
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- viewDidAppear & viewDidDisappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(_select_state == 0)  //首次appear
    {
        [self selectDefault];
    }
    else if(_select_state == travel_state)
    {
        [self selectDefault];
    }
    else if(_select_state == collect_state)
    {
        [self selectMyCollect];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}
-(void)getTravelData
{
    if(_footerView)
    {
        UILabel *label = (UILabel *)[_footerView viewWithTag:100];
        CGRect frame = CGRectMake(0, 0, _footerView.bounds.size.width-30, _footerView.bounds.size.height);
        label.frame = frame;
        label.text = @"正在加载...";
        
        UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[_footerView viewWithTag:101];
        [activity startAnimating];
    }
    
    if(_flag_pullToLoading_travel)
    {
        return;
    }
    _flag_pullToLoading_travel = YES;
    
    [MicroTravelData getUserTravelDataWithUserId:self.user_id
                                         andType:@"post"
                                        andCount:TravelListCountOfOnePage
                                         andPage:_page_user
                                         success:^(NSArray *array){
                                             
                                             _page_user++;
                                             if(array && array.count == TravelListCountOfOnePage)
                                             {
                                                 _flag_getMore_travel = YES;
                                             }
                                             else
                                             {
                                                 _flag_getMore_travel = NO;
                                             }
                                             
                                             if(_array_travel.count == 0 && array.count == 0)
                                             {
                                                 [self initDefaultViewWithType:@"travel"];
                                             }
                                             else
                                             {
                                                 _imageView_default.hidden = YES;
                                                 [_array_travel addObjectsFromArray:array];
                                                 [self initTableView];
                                                 [self setTableViewFooterView];
                                             }
                                             
                                             _flag_pullToLoading_travel = NO;
                                         }
                                          failed:^{
                                              
                                              [self initTableView];
                                              [self setTableViewFooterView];
                                              
                                              _flag_pullToLoading_travel = NO;
                                          }];
}
-(void)getCollectData
{
    if(_footerView)
    {
        UILabel *label = (UILabel *)[_footerView viewWithTag:100];
        CGRect frame = CGRectMake(0, 0, _footerView.bounds.size.width-30, _footerView.bounds.size.height);
        label.frame = frame;
        label.text = @"正在加载...";
        
        UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[_footerView viewWithTag:101];
        [activity startAnimating];
    }
    
    if(_flag_pullToLoading_collect)
    {
        return;
    }
    _flag_pullToLoading_collect = YES;
    
    
    [MicroTravelData getUserCollectTravelDataWithUserId:self.user_id
                                                andType:@"fav"
                                               andCount:TravelListCountOfOnePage
                                                andPage:_page_userCollect
                                                success:^(NSArray *array){
                                                    _page_userCollect++;
                                                    if(array && array.count == TravelListCountOfOnePage)
                                                    {
                                                        _flag_getMore_collect = YES;
                                                    }
                                                    else
                                                    {
                                                        _flag_getMore_collect = NO;
                                                    }
                                                    
                                                    if(_array_collect.count == 0 && array.count == 0)
                                                    {
                                                        [self initDefaultViewWithType:@"collect"];
                                                    }
                                                    else
                                                    {
                                                        _imageView_default.hidden = YES;
                                                        [_array_collect addObjectsFromArray:array];
                                                        [self initTableView];
                                                        [self setTableViewFooterView];
                                                    }
                                                    
                                                    _flag_pullToLoading_collect = NO;
                                                }
                                                 failed:^{
                                                     
                                                     [self initTableView];
                                                     [self setTableViewFooterView];
                                                     
                                                     _flag_pullToLoading_collect = NO;
                                                 }];
}
-(void)selectDefault //我的帖子
{
    [_button_travel setSelected:YES];
    [_button_collector setSelected:NO];
    _select_state = travel_state;
    
    if(_array_travel.count > 0)
    {
        _imageView_default.hidden = YES;
        _tableView_myPost.hidden = NO;
        [_tableView_myPost reloadData];
        [self setTableViewFooterView];
    }
    else
    {
        [_tableView_myPost reloadData];
        _tableView_myPost.tableFooterView = nil;
        [self getTravelData];
    }
}
-(void)selectMyCollect //我的收藏
{
    [_button_collector setSelected:YES];
    [_button_travel setSelected:NO];
    _select_state = collect_state;
    
    if(_array_collect.count > 0)
    {
        _imageView_default.hidden = YES;
        _tableView_myPost.hidden = NO;
        [_tableView_myPost reloadData];
        [self setTableViewFooterView];
    }
    else
    {
        [_tableView_myPost reloadData];
        _tableView_myPost.tableFooterView = nil;
        [self getCollectData];
    }
}
-(void)initDefaultViewWithType:(NSString *)type
{
    if(!_imageView_default)
    {
        _imageView_default = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height - 373/2.)/2., 640/2, 373/2.)];
        _imageView_default.backgroundColor = [UIColor clearColor];
    }
    _imageView_default.hidden = NO;
    [self.view addSubview:_imageView_default];
    
    if([type isEqualToString:@"travel"])
    {
        _imageView_default.image = [UIImage imageNamed:@"游记为空"];
    }
    else
    {
        _imageView_default.image = [UIImage imageNamed:@"帖子收藏为空"];
    }
    _tableView_myPost.hidden = YES;
}


#pragma mark -
#pragma mark --- 构建View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _page_user = 1;
    _page_userCollect = 1;
    [self initRootView];
    [self initHeadView];
    [self initToolBar];
    [self initArray];
}
-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor whiteColor];
    rootView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
    rootView.userInteractionEnabled = YES;
    self.view = rootView;
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
    _titleLabel.backgroundColor = [UIColor clearColor];
    if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue] && self.user_id > 0)
    {
        _titleLabel.text = @"我的帖子";
    }
    else
    {
        _titleLabel.text = @"Ta的游记";
    }
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    [_headView addSubview:_titleLabel];
    [_titleLabel release];
    
    
    UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
}
-(void)initToolBar
{
    if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue] && self.user_id > 0)
    {
        if(!_toolBar)
        {
            _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, 78/2)];
            _toolBar.backgroundColor = [UIColor whiteColor];
        }
        _toolBar.hidden = NO;
        [self.view addSubview:_toolBar];
        [self initToolBarButton];
    }
    else
    {
        _toolBar.hidden = YES;
    }
}
-(void)initToolBarButton
{
    _button_travel = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_travel.frame = CGRectMake(0, 0, 320/2, 78/2);
    _button_travel.backgroundColor = [UIColor clearColor];
    [_button_travel setBackgroundImage:[UIImage imageNamed:@"my_tirp"] forState:UIControlStateNormal];
    [_button_travel setBackgroundImage:[UIImage imageNamed:@"highlight_my_tirp"] forState:UIControlStateSelected];
    [_button_travel addTarget:self action:@selector(selectDefault) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_button_travel];
    
    
    _button_collector = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_collector.frame = CGRectMake(320/2, 0, 320/2, 78/2);
    _button_collector.backgroundColor = [UIColor clearColor];
    [_button_collector setBackgroundImage:[UIImage imageNamed:@"my_collect"] forState:UIControlStateNormal];
    [_button_collector setBackgroundImage:[UIImage imageNamed:@"highlight_my_collect"] forState:UIControlStateSelected];
    [_button_collector addTarget:self action:@selector(selectMyCollect) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_button_collector];
}
-(void)initArray
{
    if(!_array_collect)
    {
        _array_collect = [[NSMutableArray alloc] init];
    }
    [_array_collect removeAllObjects];
    
    if(!_array_travel)
    {
        _array_travel = [[NSMutableArray alloc] init];
    }
    [_array_travel removeAllObjects];
}
-(void)initTableView
{
    if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue] && self.user_id > 0) //我的帖子
    {
        if(!_tableView_myPost)
        {
            float positionY = _toolBar.frame.origin.y + _toolBar.frame.size.height;
            float height = [[UIScreen mainScreen] bounds].size.height - positionY;
            if(!ios7)
            {
                height = [[UIScreen mainScreen] bounds].size.height - positionY - 20;
            }
            _tableView_myPost = [[UITableView alloc] initWithFrame:CGRectMake(0, positionY, 320, height) style:UITableViewStylePlain];
            _tableView_myPost.backgroundColor = [UIColor clearColor];
            _tableView_myPost.separatorColor = [UIColor clearColor];
            _tableView_myPost.dataSource = self;
            _tableView_myPost.delegate = self;
        }
        [self.view addSubview:_tableView_myPost];
        [_tableView_myPost reloadData];
    }
    else //Ta的游记
    {
        if(!_tableView_myPost)
        {
            float positionY = _headView.frame.origin.y + _headView.frame.size.height;
            float height = [[UIScreen mainScreen] bounds].size.height - positionY;
            if(!ios7)
            {
                height = [[UIScreen mainScreen] bounds].size.height - positionY - 20;
            }
            _tableView_myPost = [[UITableView alloc] initWithFrame:CGRectMake(0, positionY, 320, height) style:UITableViewStylePlain];
            _tableView_myPost.backgroundColor = [UIColor clearColor];
            _tableView_myPost.separatorColor = [UIColor clearColor];
            _tableView_myPost.dataSource = self;
            _tableView_myPost.delegate = self;
        }
        _tableView_myPost.hidden = NO;
        [self.view addSubview:_tableView_myPost];
        [_tableView_myPost reloadData];
    }
}
-(void)setTableViewFooterView
{
    if(!_footerView)
    {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:_footerView.bounds];
        [_footerView addSubview:label];
        label.tag = 100;
        label.font = [UIFont systemFontOfSize:13];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [label release];
        
        
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(190, 10, 20, 20)];
        [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        activity.tag = 101;
        activity.backgroundColor = [UIColor clearColor];
        [_footerView addSubview:activity];
        [activity release];
    }
    
    
    UILabel *label = (UILabel *)[_footerView viewWithTag:100];
    CGRect frame = _footerView.bounds;
    label.frame = frame;
    label.text = @"加载更多";
    UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[_footerView viewWithTag:101];
    [activity stopAnimating];
    
    
    if(_select_state == travel_state)
    {
        if(_flag_getMore_travel && _array_travel.count > 0)
        {
            NSLog(@" 还可以加载更多");
            _tableView_myPost.tableFooterView = _footerView;
        }
        else
        {
            NSLog(@" 已经获取了全部数据");
            _tableView_myPost.tableFooterView = nil;
        }
    }
    else
    {
        if(_flag_getMore_collect && _array_collect.count > 0)
        {
            NSLog(@" 还可以加载更多");
            _tableView_myPost.tableFooterView = _footerView;
        }
        else
        {
            NSLog(@" 已经获取了全部数据");
            _tableView_myPost.tableFooterView = nil;
        }
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
    if(_select_state == travel_state)
    {
        return [_array_travel count];
    }
    else
    {
        return [_array_collect count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_select_state == collect_state && indexPath.row == [_array_collect count]-1)
    {
        return 140+10;
    }
    else if(_select_state == travel_state && indexPath.row == [_array_travel count]-1)
    {
        return 140+10;
    }
    return 140;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TravelsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserImageViewCell"];
    if(cell == nil)
    {
        cell = [[[TravelsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TravelsCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(_select_state == travel_state)
    {
        [cell updateCell:[_array_travel objectAtIndex:indexPath.row]];
    }
    else
    {
        [cell updateCell:[_array_collect objectAtIndex:indexPath.row]];
    }
    
    return cell;
}



#pragma mark -
#pragma mark --- UITableView - Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBSDetailViewController * bbsDetailVC = [[BBSDetailViewController alloc] init];
    MicroTravel *traval;
    if(_select_state == travel_state)
    {
         traval = [_array_travel objectAtIndex:indexPath.row];
    }
    else
    {
        traval = [_array_collect objectAtIndex:indexPath.row];
    }
    bbsDetailVC.bbsAllUserLink = traval.str_travelUrl_all;
    bbsDetailVC.source = @"MyPostsViewController";//代表是从我的收藏进的帖子
    [self.navigationController pushViewController:bbsDetailVC animated:YES];
    [bbsDetailVC release];
}



#pragma mark
#pragma mark --- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_tableView_myPost.tableFooterView
        || (_select_state == travel_state && _flag_pullToLoading_travel == YES)
        || (_select_state == collect_state && _flag_pullToLoading_collect == YES))
    {
        return;
    }
    
    if(_tableView_myPost.contentOffset.y + _tableView_myPost.frame.size.height - _tableView_myPost.contentSize.height >= 5)
    {
        if(_select_state == travel_state && _flag_getMore_travel == YES)
        {
            NSLog(@" 再去加载新数据 ");
            
            [self getTravelData];
        }
        else if(_select_state == collect_state && _flag_getMore_collect == YES)
        {
            NSLog(@" 再去加载新数据 ");
            
            [self getCollectData];
        }
    }
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
