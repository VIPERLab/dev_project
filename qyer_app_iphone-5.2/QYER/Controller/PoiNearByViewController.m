//
//  PoiNearByViewController.m
//  QYER
//
//  Created by 我去 on 14-8-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "PoiNearByViewController.h"
#import "ChangeTableviewContentInset.h"
#import "CityPoiData.h"
#import "GetHotelNearbyPoi.h"
#import "SpotCell.h"
#import "HotelNearByCell.h"
#import "Toast+UIView.h"
#import "PoiDetailViewController.h"
#import "WebViewViewController.h"
#import "CityPoi.h"
#import "GetHotelNearbyPoi.h"




#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (4+20) : 4)
#define     positionY_backbutton        (ios7 ? (3+20) : 3)
#define     pageCount                   10




@interface PoiNearByViewController ()

@end





@implementation PoiNearByViewController
@synthesize navigationTitle;
@synthesize poiId;
@synthesize categoryId;
@synthesize lat;
@synthesize lon;
@synthesize hotel_nearBy;

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
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_tableView_poiNearBy);
    QY_VIEW_RELEASE(_footerView);
    QY_SAFE_RELEASE(_getHotelNearbyPoi_fromServer);
    QY_MUTABLERECEPTACLE_RELEASE(_array_data);
    
    [super dealloc];
}


#pragma mark -
#pragma mark --- view Appear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setNavigationTitle];
    [self getNearByData];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)getNearByData   //32：景点、77：交通、78：餐饮、147：购物、148：活动、149：住宿、 150：实用信息、151：路线
{
    if(_array_data && _array_data.count > 0)
    {
        return;
    }
    else if(!_array_data)
    {
        _array_data = [[NSMutableArray alloc] init];
    }
    [_array_data removeAllObjects];
    
    if(self.hotel_nearBy) //周边酒店
    {
        [self getHotelBearbyPoiDataFromServer];
    }
    else
    {
        [self getNearByPoiData];
    }
}

// 周边poi
-(void)getNearByPoiData
{
//    _reloading = YES;
//    if(_footerView)
//    {
//        UILabel *label = (UILabel *)[_footerView viewWithTag:100];
//        CGRect frame = CGRectMake(0, 0, _footerView.bounds.size.width-30, _footerView.bounds.size.height);
//        label.frame = frame;
//        label.text = @"正在加载...";
//        
//        UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[_footerView viewWithTag:101];
//        [activity startAnimating];
//    }
    
    
    [CityPoiData getPoiNearByWithLat:self.lat
                              andLon:self.lon
                       andCategoryId:self.categoryId
                         andPageSize:[NSString stringWithFormat:@"%d",pageCount]
                             andPage:[NSString stringWithFormat:@"%d",_pageNumber]
                            andPoiId:self.poiId
                             success:^(NSArray *array){
                                 
//                                 if(array.count == pageCount)
//                                 {
//                                     _flag_getMore = YES;
//                                     _pageNumber++;
//                                 }
//                                 else
//                                 {
//                                     _flag_getMore = NO;
//                                 }
                                 
                                 [_array_data addObjectsFromArray:array];
                                 [_tableView_poiNearBy reloadData];
                                 [self setTableViewFooterView];
                                 
//                                 _reloading = NO;
//                                 _flag_pullToLoading = NO;
                             }
                              failed:^{
                                  
//                                  _reloading = NO;
//                                  _flag_pullToLoading = NO;
                              }];
}

// 周边酒店
-(void)getHotelBearbyPoiDataFromServer
{
    [NSThread detachNewThreadSelector:@selector(getHotelData) toTarget:self withObject:nil];
}
-(void)getHotelData
{
//    _reloading = YES;
    if(!_getHotelNearbyPoi_fromServer)
    {
        _getHotelNearbyPoi_fromServer = [[GetHotelNearbyPoi alloc] init];
    }
    
    [_getHotelNearbyPoi_fromServer getNearByHotelWithPoiId:poiId
                                              andPageCount:[NSString stringWithFormat:@"%d",pageCount]
                                                   andPage:[NSString stringWithFormat:@"%d",_pageNumber]
                                                  finished:^(NSArray *array){
                                                      [self getHotelNearbyPoiByClientidSuccess:array];
                                                      
//                                                      _reloading = NO;
//                                                      _flag_pullToLoading = NO;
                                                  }
                                                    failed:^{
                                                        MYLog(@"获取HotelNearbyPo数据失败 !!! ");
                                                        
//                                                        _reloading = NO;
//                                                        _flag_pullToLoading = NO;
                                                    }];
}
-(void)getHotelNearbyPoiByClientidSuccess:(NSArray *)array
{
    MYLog(@"获取HotelNearbyPo数据成功 ~~~ ");
    
    if(array)
    {
//        if(array.count == pageCount)
//        {
//            _flag_getMore = YES;
//            _pageNumber++;
//        }
//        else
//        {
//            _flag_getMore = NO;
//        }
        
        [_array_data addObjectsFromArray:array];
        
        if(_array_data.count > 0)
        {
            MYLog(@" 初始化HotelNearby 数据");
            [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
        }
        else
        {
            MYLog(@"HotelNearby 没有数据");
        }
    }
}
-(void)reloadTableView
{
    [_tableView_poiNearBy reloadData];
    [self setTableViewFooterView];
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
    
    _pageNumber = 1;
    
    [self initRootView];
    [self setNavigationBar];
    [self initTableView];
}
-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor whiteColor];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
}
-(void)setNavigationTitle
{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(184/2, positionY_titlelabel, 136, height_titlelabel)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = self.navigationTitle;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
}
-(void)initTableView
{
    if(ios7)
    {
        if(!_tableView_poiNearBy)
        {
            _tableView_poiNearBy = [[UITableView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, [[UIScreen mainScreen] bounds].size.height - _headView.frame.size.height)];
        }
        _tableView_poiNearBy.backgroundColor = [UIColor clearColor];
        _tableView_poiNearBy.separatorColor = [UIColor clearColor];
    }
    else
    {
        if(!_tableView_poiNearBy)
        {
            _tableView_poiNearBy = [[UITableView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, ([[UIScreen mainScreen] bounds].size.height-20-_headView.frame.size.height))];
        }
        _tableView_poiNearBy.backgroundColor = [UIColor clearColor];
        _tableView_poiNearBy.separatorColor = [UIColor clearColor];
    }
    _tableView_poiNearBy.delegate = self;
    _tableView_poiNearBy.dataSource = self;
    
    [self.view addSubview:_tableView_poiNearBy];
    [self.view bringSubviewToFront:_headView];
}
-(void)setTableViewFooterView
{
//    if(!_footerView)
//    {
//        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//        _footerView.backgroundColor = [UIColor clearColor];
//        
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:_footerView.bounds];
//        [_footerView addSubview:label];
//        label.tag = 100;
//        label.font = [UIFont systemFontOfSize:13];
//        label.backgroundColor = [UIColor clearColor];
//        label.textAlignment = NSTextAlignmentCenter;
//        [label release];
//        
//        
//        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(190, 10, 20, 20)];
//        [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
//        activity.tag = 101;
//        activity.backgroundColor = [UIColor clearColor];
//        [_footerView addSubview:activity];
//        [activity release];
//    }
//    
//    
//    UILabel *label = (UILabel *)[_footerView viewWithTag:100];
//    CGRect frame = _footerView.bounds;
//    label.frame = frame;
//    label.text = @"加载更多";
//    UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[_footerView viewWithTag:101];
//    [activity stopAnimating];
//    
//    
//    if(_flag_getMore && _array_data.count > 0)
//    {
//        NSLog(@" 还可以加载更多");
//        _tableView_poiNearBy.tableFooterView = _footerView;
//    }
//    else
//    {
//        NSLog(@" 已经获取了全部数据");
//        _tableView_poiNearBy.tableFooterView = nil;
//    }
}



#pragma mark -
#pragma mark --- UITableView - datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array_data count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.hotel_nearBy)
    {
        HotelNearByCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hotelnearby"];
        if (!cell)
        {
            cell = [[[HotelNearByCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hotelnearby"] autorelease];
        }
        [cell setInfoWithArray:_array_data atPosition:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        SpotCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell)
        {
            cell = [[[SpotCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        }
        [cell setNearByPoi:[_array_data objectAtIndex:indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}


#pragma mark -
#pragma mark --- UITableView - delegate
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.hotel_nearBy) //周边酒店
    {
        GetHotelNearbyPoi *hotel = (GetHotelNearbyPoi *)[_array_data objectAtIndex:indexPath.row];
        WebViewViewController *webVC = [[WebViewViewController alloc] init];
        webVC.flag_plan = 0;
        [webVC setStartURL:hotel.bookingUrl];
        [self presentViewController:[QYToolObject getControllerWithBaseController:webVC] animated:YES completion:nil];
        [webVC release];
    }
    else
    {
        PoiDetailViewController *poiDetailVc = [[PoiDetailViewController alloc]init];
        CityPoi *poi = (CityPoi *)[_array_data objectAtIndex:indexPath.row];
        poiDetailVc.poiId = [poi.str_poiId intValue];
        [self.navigationController pushViewController:poiDetailVc animated:YES];
        [poiDetailVc release];
    }
    
    return nil;
}



//#pragma mark
//#pragma mark --- UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (!_tableView_poiNearBy.tableFooterView || _flag_pullToLoading == YES)
//    {
//        return;
//    }
//    
//    
//    if(_tableView_poiNearBy.contentOffset.y + _tableView_poiNearBy.frame.size.height - _tableView_poiNearBy.contentSize.height >= 5 && _flag_getMore == YES)
//    {
//        NSLog(@" 再去加载新数据 ");
//        _flag_pullToLoading = YES;  //表示正在上拉加载更多
//        
//        if(self.hotel_nearBy) //周边酒店
//        {
//            [self getHotelBearbyPoiDataFromServer];
//        }
//        else
//        {
//            [self getNearByPoiData];
//        }
//    }
//}


#pragma mark -
#pragma mark --- back
- (void)clickBackButton:(id)sender
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
