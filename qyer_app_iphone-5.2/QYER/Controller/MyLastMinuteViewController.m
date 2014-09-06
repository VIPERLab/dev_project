//
//  MyLastMinuteViewController.m
//  QYER
//
//  Created by 我去（蔡小雨） on 14-5-9.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "MyLastMinuteViewController.h"
#import "CollectionCell.h"
#import "RemindCell.h"
#import "QYAPIClient.h"
//#import "LastMinuteDetailViewController.h"
#import "LastMinuteDetailViewControllerNew.h"
#import "AddRemindViewController.h"
#import "QYCommonToast.h"
#import "LastMinuteUserOrder.h"
#import "MyOrderYukuanCell.h"
#import "MyOrderQuankuanCell.h"

//height
#define Height_Cell_Space         10.0f

#define k_page_more_size          5

#define Color_Bg_Blue             [UIColor colorWithRed:232.0/255.0f green:242.0/255.0f blue:249.0/255.0f alpha:1.0]

@interface MyLastMinuteViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
MyOrderQuankuanCellDelegate,
MyOrderYukuanCellDelegate
>

@property (nonatomic, retain) UIButton            *myCollectionTab;
@property (nonatomic, retain) UIButton            *myReminderTab;
@property (nonatomic, retain) UIButton            *myOrderTab;

@property (nonatomic, retain) UIView              *myCollectionContentView;
@property (nonatomic, retain) UIView              *myReminderContentView;
@property (nonatomic, retain) UIView              *myOrderContentView;

@property (nonatomic, retain) UITableView         *myCollectionTableView;
@property (nonatomic, retain) UITableView         *myReminderTableView;
@property (nonatomic, retain) UITableView         *myOrderTableView;

@property (nonatomic, retain) NSMutableArray      *myCollectionArray;
@property (nonatomic, retain) NSMutableArray      *myReminderArray;
@property (nonatomic, retain) NSMutableArray      *myOrderArray;

@property (nonatomic, assign) NSUInteger           selectIndex;

@property (nonatomic, retain) UIImageView         *myCollectionEmptyView;
@property (nonatomic, retain) UIImageView         *myReminderEmptyView;
@property (nonatomic, retain) UIImageView         *myOrderEmptyView;

@property (nonatomic, retain) UIButton            *myReminderAddButton;

@property (nonatomic, assign) BOOL                 myOrderRefreshing;
@property (nonatomic, assign) NSInteger            myOrderCurrentPage;
@property (nonatomic, assign) NSInteger            myOrderTotalCount;

@property (nonatomic, retain) LastMinuteUserOrder *curPayingUserOrder;

@end

@implementation MyLastMinuteViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    QY_VIEW_RELEASE(_myCollectionTab);
    QY_VIEW_RELEASE(_myReminderTab);
    QY_VIEW_RELEASE(_myOrderTab);
    
    QY_VIEW_RELEASE(_myCollectionContentView);
    QY_VIEW_RELEASE(_myReminderContentView);
    QY_VIEW_RELEASE(_myOrderContentView);
    
    QY_VIEW_RELEASE(_myCollectionTableView);
    QY_VIEW_RELEASE(_myReminderTableView);
    QY_VIEW_RELEASE(_myOrderTableView);
    
    QY_SAFE_RELEASE(_myCollectionArray);
    QY_SAFE_RELEASE(_myReminderArray);
    QY_SAFE_RELEASE(_myOrderArray);
    
    QY_VIEW_RELEASE(_myCollectionEmptyView);
    QY_VIEW_RELEASE(_myReminderEmptyView);
    QY_VIEW_RELEASE(_myOrderEmptyView);
    
    QY_VIEW_RELEASE(_myReminderAddButton);
    
    QY_SAFE_RELEASE(_curPayingUserOrder);
    [super dealloc];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _myCollectionArray = [[NSMutableArray alloc] initWithCapacity:0];
        _myReminderArray = [[NSMutableArray alloc] initWithCapacity:0];
        _myOrderArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //请求 我的收藏 数据
    [self requestMyCollectionData];
    //请求 我的提醒 数据
    [self requestMyReminderData];
    //请求 我的订单 数据
    [self requestMyOrderData];
    
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _titleLabel.text = @"我的折扣";
    self.view.backgroundColor = Color_Bg_Blue;
    
    //我的收藏
    _myCollectionTab = [[UIButton alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 106, 38)];
    _myCollectionTab.titleLabel.font = [UIFont systemFontOfSize:14];
    [_myCollectionTab setBackgroundImage:[UIImage imageNamed:@"myLastMin_collectTab.png"] forState:UIControlStateNormal];
    [_myCollectionTab setBackgroundImage:[UIImage imageNamed:@"myLastMin_collectTab_highlighted.png"] forState:UIControlStateSelected];
    [_myCollectionTab setBackgroundColor:[UIColor whiteColor]];
    [_myCollectionTab addTarget:self action:@selector(myCollectionTabClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_myCollectionTab];
    _myCollectionTab.selected = YES;
    
//    //竖线
//    UIImageView *verticalLine = [[UIImageView alloc] initWithFrame:CGRectMake(107-1, _headView.frame.size.height+11, 1, 15)];
//    [verticalLine setImage:[UIImage imageNamed:@"myLastMin_vertical_line.png"]];
//    [self.view addSubview:verticalLine];
//    [verticalLine release];

    //我的提醒
    _myReminderTab = [[UIButton alloc] initWithFrame:CGRectMake(106, _headView.frame.size.height, 106, 38)];
    _myReminderTab.titleLabel.font = [UIFont systemFontOfSize:14];
    [_myReminderTab setBackgroundImage:[UIImage imageNamed:@"myLastMin_remindTab.png"] forState:UIControlStateNormal];
    [_myReminderTab setBackgroundImage:[UIImage imageNamed:@"myLastMin_remindTab_highlighted.png"] forState:UIControlStateSelected];
    [_myReminderTab setBackgroundColor:[UIColor whiteColor]];
    [_myReminderTab addTarget:self action:@selector(myReminderTabClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_myReminderTab];
    
//    //竖线
//    UIImageView *verticalLine_2 = [[UIImageView alloc] initWithFrame:CGRectMake(107*2-1, _headView.frame.size.height+11, 1, 15)];
//    [verticalLine_2 setImage:[UIImage imageNamed:@"myLastMin_vertical_line.png"]];
//    [self.view addSubview:verticalLine_2];
//    [verticalLine_2 release];
    
    //我的订单
    _myOrderTab = [[UIButton alloc] initWithFrame:CGRectMake(106*2, _headView.frame.size.height, 107, 38)];
    _myOrderTab.titleLabel.font = [UIFont systemFontOfSize:14];
    [_myOrderTab setBackgroundImage:[UIImage imageNamed:@"myLastMin_orderTab.png"] forState:UIControlStateNormal];
    [_myOrderTab setBackgroundImage:[UIImage imageNamed:@"myLastMin_orderTab_highlighted.png"] forState:UIControlStateSelected];
    [_myOrderTab setBackgroundColor:[UIColor whiteColor]];
    [_myOrderTab addTarget:self action:@selector(myOrderTabClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_myOrderTab];
    
    //横线
    UIImageView *horizontalLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, _myCollectionTab.frame.origin.y+_myCollectionTab.frame.size.height, 320, 1)];
    horizontalLine.image = [[UIImage imageNamed:@"myLastMin_horizontal_line.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self.view addSubview:horizontalLine];
    [horizontalLine release];
    
    //我的收藏
    [self configMyCollectionView];
    //我的提醒
    [self configMyReminderView];
    //我的订单
    [self configMyOrderView];
    
    
    
    //notification //刷新数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMyOrderData) name:Notification_MyOrder_Refresh object:nil];
    
    //App 从后台进入前端
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMyOrderData) name:@"Notification_AppWillEnterForeground" object:nil];

    
}

//我的收藏
- (void)configMyCollectionView
{
    CGFloat contentY = _myCollectionTab.frame.origin.y + _myCollectionTab.frame.size.height + 1;
    
    CGFloat yPadding = ios7?0:20;
    
    //我的收藏 ContentView
    _myCollectionContentView = [[UIView alloc] initWithFrame:CGRectMake(0, contentY, 320, self.view.frame.size.height-contentY-yPadding)];
    _myCollectionContentView.backgroundColor = Color_Bg_Blue;//[UIColor colorWithRed:232.0/255.0f green:242.0/255.0f blue:249.0/255.0f alpha:1.0];
//    _myCollectionContentView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_myCollectionContentView];
    
    //我的收藏 tableView
    _myCollectionTableView = [[UITableView alloc] initWithFrame:_myCollectionContentView.bounds];
    _myCollectionTableView.dataSource = self;
    _myCollectionTableView.delegate = self;
    _myCollectionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myCollectionTableView.backgroundColor = [UIColor whiteColor];
    [_myCollectionContentView addSubview:_myCollectionTableView];
    
    //我的收藏 为空界面
    _myCollectionEmptyView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 159)];
    _myCollectionEmptyView.center = self.myCollectionTableView.center;
    _myCollectionEmptyView.backgroundColor = [UIColor clearColor];
    _myCollectionEmptyView.image = [UIImage imageNamed:@"myLastMin_collect_empty.png"];
    [_myCollectionContentView addSubview:_myCollectionEmptyView];
    _myCollectionEmptyView.hidden = YES;

}

//我的提醒
- (void)configMyReminderView
{
    
    _myReminderAddButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _myReminderAddButton.frame = CGRectMake(278, _headView.frame.size.height-40-2, 40, 40);
    _myReminderAddButton.backgroundColor = [UIColor clearColor];
    [_myReminderAddButton setBackgroundImage:[UIImage imageNamed:@"myLastMin_btn_add_remind.png"] forState:UIControlStateNormal];
    [_myReminderAddButton setBackgroundImage:[UIImage imageNamed:@"myLastMin_btn_add_remind_highlighted.png"] forState:UIControlStateHighlighted];
    [_myReminderAddButton addTarget:self action:@selector(clickAddReminderButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_myReminderAddButton];
    _myReminderAddButton.hidden = YES;
    
    //我的提醒 ContentView
    _myReminderContentView = [[UIView alloc] initWithFrame:_myCollectionContentView.frame];
    _myReminderContentView.backgroundColor = Color_Bg_Blue;//[UIColor colorWithRed:232.0/255.0f green:242.0/255.0f blue:249.0/255.0f alpha:1.0];
    [self.view addSubview:_myReminderContentView];
    _myReminderContentView.hidden = YES;
    
    //我的提醒 tableView
    _myReminderTableView = [[UITableView alloc] initWithFrame:_myReminderContentView.bounds];
    _myReminderTableView.dataSource = self;
    _myReminderTableView.delegate = self;
    _myReminderTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myReminderTableView.backgroundColor = [UIColor clearColor];
    [_myReminderContentView addSubview:_myReminderTableView];
    
    //headerSpaceView 10px
    UIView *headerSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, Height_Cell_Space)];
    _myReminderTableView.tableHeaderView = headerSpaceView;
    [headerSpaceView release];
    
    //我的提醒 为空界面
    _myReminderEmptyView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 172)];
    _myReminderEmptyView.center = self.myReminderTableView.center;
    _myReminderEmptyView.backgroundColor = [UIColor clearColor];
    _myReminderEmptyView.image = [UIImage imageNamed:@"myLastMin_empty_remind.png"];
    [_myReminderContentView addSubview:_myReminderEmptyView];
    _myReminderEmptyView.hidden = YES;


}

//我的订单
- (void)configMyOrderView
{
    //我的提醒 ContentView
    _myOrderContentView = [[UIView alloc] initWithFrame:_myCollectionContentView.frame];
    _myOrderContentView.backgroundColor = Color_Bg_Blue;//[UIColor colorWithRed:232.0/255.0f green:242.0/255.0f blue:249.0/255.0f alpha:1.0];
    [self.view addSubview:_myOrderContentView];
    _myOrderContentView.hidden = YES;
    
    //我的提醒 tableView
    _myOrderTableView = [[UITableView alloc] initWithFrame:_myOrderContentView.bounds];
    _myOrderTableView.dataSource = self;
    _myOrderTableView.delegate = self;
    _myOrderTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myOrderTableView.backgroundColor = [UIColor clearColor];
    [_myOrderContentView addSubview:_myOrderTableView];
    
    //headerSpaceView 10px
    UIView *headerSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, Height_Cell_Space)];
    _myOrderTableView.tableHeaderView = headerSpaceView;
    [headerSpaceView release];
    
    //我的提醒 为空界面
    _myOrderEmptyView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 187)];
    _myOrderEmptyView.center = self.myReminderTableView.center;
    _myOrderEmptyView.backgroundColor = [UIColor clearColor];
    _myOrderEmptyView.image = [UIImage imageNamed:@"myLastMin_empty_order.png"];
    [_myOrderContentView addSubview:_myOrderEmptyView];
    _myOrderEmptyView.hidden = YES;


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma Mark - request data
//请求 我的收藏 数据
- (void)requestMyCollectionData
{
    [self.view makeToastActivity];
    
    [LastMinute getLastMinuteFavorListWithMaxId:0
                                       pageSize:1000
                                        success:^(NSArray *data) {
                                            [self.view hideToastActivity];
                                            
                                            [_myCollectionArray removeAllObjects];
                                            [_myCollectionArray addObjectsFromArray:data];
                                            
                                            //刷新数据
                                            [self reloadDataOfMyCollection];
                                            
                                            
                                        } failure:^{
                                            
                                            [self.view hideToastActivity];
                                            
                                            //刷新数据
                                            [self reloadDataOfMyCollection];
                                            
                                        }];

}

//请求 我的提醒 数据
- (void)requestMyReminderData
{
//    [self.view makeToastActivity];
    
    [Remind getRemindListWithMaxId:0 pageSize:1000
                           success:^(NSArray *data) {
//                               [self.view hideToastActivity];
                               
                               [_myReminderArray removeAllObjects];
                               [_myReminderArray addObjectsFromArray:data];
                               
                               //刷新数据
                               [self reloadDataOfMyReminder];
                               
                               
                           } failure:^{
                               
//                               [self.view hideToastActivity];
                               
                               //刷新数据
                               [self reloadDataOfMyReminder];
                               
                           }];
    
    
}

//刷新 我的订单 数据
- (void)refreshMyOrderData
{
    if ([self.navigationController.topViewController isKindOfClass:[self class]]) {
        [self requestMyOrderData];
    }

}

//请求 我的订单 数据
- (void)requestMyOrderData
{
//    [self.view makeToastActivity];
    _myOrderCurrentPage = 1;
    [LastMinuteUserOrder getLastMinuteUserOrderListWithCount:k_page_more_size
                                                        page:_myOrderCurrentPage
                                                     success:^(NSArray *data, NSInteger count){
//                                                         [self.view hideToastActivity];
                                                         
                                                         if([data isKindOfClass:[NSArray class]] && [data count] > 0)
                                                         {
                                                             self.myOrderArray = [NSMutableArray arrayWithArray:data];
                                                             self.myOrderTotalCount = count;
                                                             
                                                         }
                                                         
                                                         [self reloadDataOfMyOrder];
                                                         
                                                     } failure:^(NSError *error) {
//                                                         [self.view hideToastActivity];
                                                         //刷新数据
                                                         [self reloadDataOfMyOrder];
                                                         
                                                     }];

}


#pragma mark - click
- (void)myCollectionTabClick:(id)sender//我的收藏
{
    //tab
    _myCollectionTab.selected = YES;
    _myReminderTab.selected = NO;
    _myOrderTab.selected = NO;
    
    //ui
    _myCollectionContentView.hidden = NO;
    _myReminderContentView.hidden = YES;
    _myOrderContentView.hidden = YES;
    
    //隐藏我的提醒 button
    _myReminderAddButton.hidden = YES;

}

- (void)myReminderTabClick:(id)sender//我的提醒
{
    //tab
    _myCollectionTab.selected = NO;
    _myReminderTab.selected = YES;
    _myOrderTab.selected = NO;

    //ui
    _myCollectionContentView.hidden = YES;
    _myReminderContentView.hidden = NO;
    _myOrderContentView.hidden = YES;
    
    //显示我的提醒 button
    _myReminderAddButton.hidden = NO;
}

- (void)myOrderTabClick:(id)sender//我的订单
{
    //tab
    _myCollectionTab.selected = NO;
    _myReminderTab.selected = NO;
    _myOrderTab.selected = YES;
    
    //ui
    _myCollectionContentView.hidden = YES;
    _myReminderContentView.hidden = YES;
    _myOrderContentView.hidden = NO;
    
    //隐藏我的提醒 button
    _myReminderAddButton.hidden = YES;


}


#pragma mark - 刷新数据
- (void)reloadDataOfMyCollection//我的收藏
{
    if([_myCollectionArray count] == 0)
    {
        _myCollectionEmptyView.hidden = NO;
        _myCollectionTableView.hidden = YES;
    }
    else
    {
        _myCollectionEmptyView.hidden = YES;
        _myCollectionTableView.hidden = NO;
    }
    
    [_myCollectionTableView reloadData];
}

- (void)reloadDataOfMyReminder//我的提醒
{
    if([_myReminderArray count] == 0)
    {
        _myReminderEmptyView.hidden = NO;
        _myReminderTableView.hidden = YES;
    }
    else
    {
        _myReminderEmptyView.hidden = YES;
        _myReminderTableView.hidden = NO;
    }
    [_myReminderTableView reloadData];
}

- (void)reloadDataOfMyOrder//我的订单
{
    if([_myOrderArray count] == 0)
    {
        _myOrderEmptyView.hidden = NO;
        _myOrderTableView.hidden = YES;
    }
    else
    {
        _myOrderEmptyView.hidden = YES;
        _myOrderTableView.hidden = NO;
    }
    [_myOrderTableView reloadData];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _myCollectionTableView) {//我的收藏
        return CollectionCellHeight;//78;
        
    }else if (tableView == _myReminderTableView){//我的提醒
        
        if (indexPath.row%2==0) {
            return RemindCellHeight;//150.0f-9;
        }else{//Cell间间隔10像素
            return Height_Cell_Space;
        }
        
        
    }else if (tableView == _myOrderTableView){//我的订单
        
        if ([_myOrderArray count]>0 ) {
            if (indexPath.row%2 == 0) {
                NSInteger index = indexPath.row/2;
                NSLog(@"-------my orderIndex:%d", index);
                
                LastMinuteUserOrder *userOrder = [_myOrderArray objectAtIndex:index];//indexPath.row
                
                if (userOrder.orderBalanceOrder) {//尾款订单
                    return MyOrderYukuanCellHeight;//444.0f
                    
                }else{//全款订单
                    return MyOrderQuankuanCellHeight;//235.0f
                    
                }
                
            }else{//Cell间间隔10像素
                return Height_Cell_Space;
                
                
            }
            
            
        }else{
            return 44;
        }

    
    }
    
    return 0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _myCollectionTableView) {
        return [_myCollectionArray count];
    }else if (tableView == _myReminderTableView){
        return [_myReminderArray count]*2;//Cell间间隔10像素
    }else if (tableView == _myOrderTableView){
        return [_myOrderArray count]*2;//Cell间间隔10像素
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _myCollectionTableView) {//我的收藏
        CollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCellIdentifier"];
        if (cell == nil) {
            cell = [[[CollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CollectionCellIdentifier"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell setLastMinute:[_myCollectionArray objectAtIndex:indexPath.row]];
        
        return cell;

        
    }else if(tableView == _myReminderTableView){//我的提醒
        
        if (indexPath.row%2==0) {
            
            NSInteger index = indexPath.row/2;
            
            RemindCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemindCellIdentifier"];
            if (cell == nil) {
                cell = [[[RemindCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RemindCellIdentifier"] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.remind = [_myReminderArray objectAtIndex:index];
            return cell;
            
        }else{//Cell间间隔10像素
            return [self getCommentSpaceCellWithTableView:tableView];
        
        }
        
    
    }else if(tableView == _myOrderTableView){//我的订单
        
        if (indexPath.row%2==0) {
            
            NSInteger index = indexPath.row/2;
            LastMinuteUserOrder *userOrder = [_myOrderArray objectAtIndex:index];
            
            if (userOrder.orderBalanceOrder) {//尾款订单
                MyOrderYukuanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderYukuanCellIdentifier"];
                if (cell == nil) {
                    cell = [[[MyOrderYukuanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyOrderYukuanCellIdentifier"] autorelease];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.delegate = self;
                cell.userOrder = userOrder;
                cell.homeViewController = self;
                return cell;
                
            }else{//全款订单
                MyOrderQuankuanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyOrderQuankuanCellIdentifier"];
                if (cell == nil) {
                    cell = [[[MyOrderQuankuanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyOrderQuankuanCellIdentifier"] autorelease];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.delegate = self;
                cell.userOrder = userOrder;
                cell.homeViewController = self;
                return cell;
                
            }
            
            
        }else{//Cell间间隔10像素
            
            return [self getCommentSpaceCellWithTableView:tableView];
        }
    
    }
    
    return nil;
    
}

- (UITableViewCell*)getCommentSpaceCellWithTableView:(UITableView*)aTableView
{
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellIdentifier"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}

#pragma mark - UITableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _myCollectionTableView) {//我的收藏
        NSLog(@"-----------我的收藏");
        
        LastMinute *lastMinute = [_myCollectionArray objectAtIndex:indexPath.row];
        [self showLastMinuteDetailViewControllerWithId:[lastMinute.str_id intValue]];
        
//        LastMinuteDetailViewController * lastDetailVC = [[LastMinuteDetailViewController alloc]init];
//        lastDetailVC.dealID = [lastMinute.str_id intValue];
//        [self.navigationController pushViewController:lastDetailVC animated:YES];
//        [lastDetailVC release];
        
    }else if (tableView == _myReminderTableView){//我的提醒
        NSLog(@"-----------我的提醒");
    
    }else if (tableView == _myOrderTableView){//我的订单
        NSLog(@"-----------我的订单");
    
    }
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == _myCollectionTableView) {//我的收藏
        
        if(_myCollectionArray.count != 0)
        {
            return UITableViewCellEditingStyleDelete;
        }
        
    }else if (tableView == _myReminderTableView){//我的提醒
        
        if(_myReminderArray.count != 0)
        {
            return UITableViewCellEditingStyleDelete;
        }

    
    }else if (tableView == _myOrderTableView){//我的订单
        
        if(_myOrderArray.count != 0)
        {
            return UITableViewCellEditingStyleDelete;
        }
    
    }
    
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    
    if (tableView == _myCollectionTableView) {//我的收藏
        return YES;
    }else if (tableView == _myReminderTableView){//我的提醒
        
        if (indexPath.row%2==0) {
            return YES;
        }
    }else if (tableView == _myOrderTableView){//我的订单
        
        NSInteger index = indexPath.row/2;
        if ([_myOrderArray count]>0) {
            
            if (indexPath.row%2==0) {
                
                LastMinuteUserOrder *userOrder = index<[_myOrderArray count]?[_myOrderArray objectAtIndex:index]:nil;
                if (userOrder&&!userOrder.orderBalanceOrder) {//全款订单
                    
                    //如果是为支付订单，则可删除，否则不可删除
                    return userOrder.orderPayment!=OrderPaymentPayed?YES:NO;
                    
                }else{//尾款订单
                    return NO;
                }
                
            }else{//Cell间间隔10像素
                
                return NO;
                
            }
            
            
        }
    }
    
    return NO;
    
}

//修改编辑时的删除按钮
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _myCollectionTableView) {//我的收藏
        
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            _selectIndex = indexPath.row;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定取消收藏此折扣？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 14337;
            [alertView show];
            [alertView release];
            
            return;
        }
        
    }else if (tableView == _myReminderTableView){//我的提醒
        
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            _selectIndex = indexPath.row/2;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定取消此提醒？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 14338;
            [alertView show];
            [alertView release];
            
            return;
        }

    
    }else if (tableView == _myOrderTableView){//我的订单
        
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            _selectIndex = indexPath.row/2;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:Alert_Message_Delete_Order delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 14339;
            [alertView show];
            [alertView release];
            
            return;
        }
    
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 14337:
        {
            if(buttonIndex == 0)
            {
                
            }
            else
            {
                [self.view makeToastActivity];
                [[QYAPIClient sharedAPIClient] lastMinuteDeleteFavorWithId:[[(LastMinute *)[_myCollectionArray objectAtIndex:_selectIndex] str_id] intValue]
                                                                   success:^(NSDictionary *dic) {
                                                                       [self.view hideToastActivity];
                                                                       
                                                                       [_myCollectionArray removeObjectAtIndex:_selectIndex];
                                                                       
                                                                       //刷新数据
                                                                       [self reloadDataOfMyCollection];
                                                                       
                                                                   } failure:^{
                                                                       [self.view hideToastActivity];
                                                                   }];
            }
        
        }
            break;
            
        case 14338:
        {
            if(buttonIndex == 0)
            {
                
            }
            else
            {
                NSUInteger remindId = [[[_myReminderArray objectAtIndex:_selectIndex] remindId] intValue];
                
                [self.view makeToastActivity];
                [[QYAPIClient sharedAPIClient] deleteLastMinuteRemindWithId:remindId
                                                                    success:^(NSDictionary *dic) {
                                                                        
                                                                        [self.view hideToastActivity];
                                                                        
                                                                        [_myReminderArray removeObjectAtIndex:_selectIndex];
                                                                        
                                                                        
                                                                        //刷新数据
                                                                        [self reloadDataOfMyReminder];
                                                                        
                                                                    } failure:^{
                                                                        
                                                                        [self.view hideToastActivity];
                                                                        
                                                                    }];
            }

        
        }
            break;
            
        case 14339:
        {
            if(buttonIndex == 0)
            {
                
            }
            else
            {
                
                LastMinuteUserOrder *userOrder = [_myOrderArray objectAtIndex:_selectIndex];
                NSUInteger orderId = [userOrder.orderId intValue];
                
                [self.view makeToastActivity];
                [LastMinuteUserOrder deleteLastMinuteUserOrderWithId:orderId success:^(NSDictionary *dic) {
                    
                    [self.view hideToastActivity];
                    [_myOrderArray removeObjectAtIndex:_selectIndex];
                    self.myOrderTotalCount--;
                    
                    //刷新数据
                    [self reloadDataOfMyOrder];
                    
                } failure:^(NSError *error) {
                    [self.view hideToastActivity];
                    
                    [self.view hideToast];
                    [self.view makeToast:[error localizedDescription] duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//@"删除订单失败，请稍后重试！"
                    
                }];
                
            }

        
        }
            break;
            
        default:
            break;
    }
}

//添加提醒按钮
- (void)clickAddReminderButton:(id)sender
{
//    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue])
//    {
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你还未登录，请先登录。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        alertView.tag = 12538;
//        [alertView show];
//        [alertView release];
//        
//        return;
//    }
    
    AddRemindViewController *addRemindVC = [[[AddRemindViewController alloc] init] autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:addRemindVC] autorelease];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:NULL];


}

#pragma mark - MyOrderYukuanCellDelegate
//title button 点击
- (void)MyOrderYukuanCellTitleButtonClickAction:(id)sender cell:(MyOrderYukuanCell*)aCell
{
    [self showLastMinuteDetailViewControllerWithId:[aCell.userOrder.orderLastminuteId intValue]];
}

//立即支付按钮 余款
- (void)MyOrderYukuanCellStyleNotPayZhifuButtonClickAction:(id)sender cell:(MyOrderYukuanCell*)aCell
{
    self.curPayingUserOrder = aCell.userOrder.orderBalanceOrder;
}

#pragma mark - MyOrderQuankuanCellDelegate
//titile 按钮点击
- (void)MyOrderQuankuanCellTitleButtonClickAction:(id)sender cell:(MyOrderQuankuanCell*)aCell
{
    [self showLastMinuteDetailViewControllerWithId:[aCell.userOrder.orderLastminuteId intValue]];
    
}

//立即支付按钮 全款
- (void)MyOrderQuankuanCellStyleNotPayZhifuButtonClickAction:(id)sender cell:(MyOrderQuankuanCell*)aCell
{
    self.curPayingUserOrder = aCell.userOrder;
}

//不可支付余款 通知我
- (void)MyOrderQuankuanCellStyleNotPayBalanceNotifyButtonClickAction:(id)sender cell:(MyOrderQuankuanCell*)aCell
{
    LastMinuteUserOrder *userOrder = aCell.userOrder;
    int timeInterval = [userOrder.orderSecondpayStartTime intValue]-LocalNotification_Ahead_Minute;
    int nowInterval = [[NSDate date] timeIntervalSince1970];
    
    
    if (timeInterval-nowInterval<=0) {
        //提示toast
        [self.view hideToast];
        [self.view makeToast:LocalNotification_Body_In_Minutes duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
    }else{
        
        //设置提醒
        [MyOrderQuankuanCell setReminderWithUserOrder:userOrder timeInterval:timeInterval];
        
        //提示toast
        [self.view hideToast];
        [self.view makeToast:LocalNotification_Body_In_Minutes_Succ duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        
    }
    
}

//全款订单 重新购买按钮
- (void)MyOrderQuankuanCellStyleFinishRebuyButtonClickAction:(id)sender cell:(MyOrderQuankuanCell*)aCell
{
    //显示折扣详情界面
    [self showLastMinuteDetailViewControllerWithId:[aCell.userOrder.orderLastminuteId intValue]];
    
    
}

//显示折扣详情界面
- (void)showLastMinuteDetailViewControllerWithId:(NSInteger)aId
{
//    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
//    CGContextRef contentRef = UIGraphicsGetCurrentContext();
//    [self.view.layer renderInContext:contentRef];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    LastMinuteDetailViewControllerNew *lastMinuteDetailVC = [[LastMinuteDetailViewControllerNew alloc] init];
    [lastMinuteDetailVC setLastMinuteId:aId];
    lastMinuteDetailVC.source = NSStringFromClass([self class]);
    //    [lastMinuteDetailVC setLastMinute:lastMinute];
    //    [lastMinuteDetailVC setLastMinuteTitle:lastMinute.lastMinuteTitle];
//    [lastMinuteDetailVC setPopImage:image];
    
    [self.navigationController pushViewController:lastMinuteDetailVC animated:YES];
    [lastMinuteDetailVC release];
    
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(self.myOrderTableView.contentOffset.y + self.myOrderTableView.frame.size.height > self.myOrderTableView.contentSize.height - 20)
    {
        [self refreshMyOrderMore];
    }
    
}

//下拉加载更多
- (void)refreshMyOrderMore{
    
    if (_myOrderRefreshing == YES) {//如果正在刷新，则不刷新
        return;
    }
    
    if ([_myOrderArray count]>=self.myOrderTotalCount) {//当数据加载完后，则停止加载
        return;
    }
    
    //开始加载更多UI效果
    [self startLoadingMoreAnimation];
    _myOrderCurrentPage++;//页数+1
    [LastMinuteUserOrder getLastMinuteUserOrderListWithCount:k_page_more_size
                                                        page:_myOrderCurrentPage
                                                     success:^(NSArray *data, NSInteger count){
                                                         
                                                         if([data isKindOfClass:[NSArray class]] && [data count] > 0)
                                                         {
                                                             [self.myOrderArray addObjectsFromArray:data];
                                                             [self reloadDataOfMyOrder];
                                                             
                                                         }
                                                         //停止加载更多UI效果
                                                         [self stopLoadingMoreAnimation];
                                                         
                                                     } failure:^(NSError *error) {
                                                         //停止加载更多UI效果
                                                         [self stopLoadingMoreAnimation];
                                                         
                                                     }];
    
}

//开始加载更多UI效果
- (void)startLoadingMoreAnimation
{
    _myOrderRefreshing = YES;
    //    self.tableView.tableFooterView = [self getRefreshView];
    
    //    [self.view makeToastActivity];
}

//停止加载更多UI效果
- (void)stopLoadingMoreAnimation
{
    //    self.tableView.tableFooterView = nil;
    _myOrderRefreshing = NO;
    
    //    [self.view hideToastActivity];
    
}



@end
