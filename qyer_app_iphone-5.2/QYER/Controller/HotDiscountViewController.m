//
//  HotDiscountViewController.m
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "HotDiscountViewController.h"
//#import "LastMinuteDetailViewController.h"
#import "LastMinuteDetailViewControllerNew.h"
#import "DiscountCell.h"
@interface HotDiscountViewController ()

@end

@implementation HotDiscountViewController

@synthesize contientID = _contientID;
@synthesize countryID = _countryID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(232, 243, 248);
    
    float height_naviViewHeight = (ios7 ? 20+46 : 46);
    
    _titleLabel.text = @"超值折扣";
    
    _gridView = [[SMGridView alloc] initWithFrame:CGRectMake(0, height_naviViewHeight, 320, self.view.frame.size.height - height_naviViewHeight)];
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.gridDelegate = self;
    _gridView.dataSource = self;
    _gridView.vertical = YES;
    _gridView.padding = 10.0f;
    [self.view addSubview:_gridView];

    
    _refreshMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 34)];
    _refreshMoreView.backgroundColor = [UIColor clearColor];
    
    _refreshMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 0, 100, 30)];//CGRectMake(0, 20, 320, 20)
    _refreshMoreLabel.backgroundColor = [UIColor clearColor];
    _refreshMoreLabel.textColor = [UIColor grayColor];//[UIColor colorWithRed:100.0 / 255.0 green:100.0 / 255.0 blue:100.0 / 255.0 alpha:1.0];
    _refreshMoreLabel.font = [UIFont systemFontOfSize:13.0f];
    _refreshMoreLabel.text = @"正在加载...";//@"更多折扣";
    _refreshMoreLabel.textAlignment = NSTextAlignmentLeft;
    [_refreshMoreView addSubview:_refreshMoreLabel];
    
    _activityIndicatior = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(105, 0, 30, 30)];//[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    _activityIndicatior.frame = CGRectMake(200, (60 - _activityIndicatior.frame.size.height) / 2, _activityIndicatior.frame.size.width, _activityIndicatior.frame.size.height);
    [_activityIndicatior setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [_refreshMoreView addSubview:_activityIndicatior];
    
    _noMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 38)];//60
    _noMoreView.backgroundColor = [UIColor clearColor];
    _noMoreIcon = [[UIImageView alloc] initWithFrame:CGRectMake(120, 1, 80, 24)];//CGRectMake(0, 0, 80, 24)   CGRectMake(137, 12, 45, 35)
//    _noMoreIcon.center = _noMoreView.center;
    _noMoreIcon.backgroundColor = [UIColor clearColor];
    _noMoreIcon.image = [UIImage imageNamed:@"lastminute_icon_bottom.png"];
    [_noMoreView addSubview:_noMoreIcon];
    _gridView.loaderView = _noMoreView;
    
    
    _lastMinuteArray = [[NSMutableArray alloc]init];
    [self getNewLastMinuteDeals];

}

-(void)getNewLastMinuteDeals
{
    NSLog(@"-------");
    
    [self.view makeToastActivity];
    [[QYAPIClient sharedAPIClient] getLastMinuteListWithType:0
                                                       maxId:0
                                                    pageSize:20
                                                       times:@""
                                                 continentId:_contientID
                                                   countryId:_countryID
                                                   departure:@""
                                                     success:^(NSDictionary *dict) {
                                                         
                                                         [self.view hideToastActivity];
                                                         
                                                         NSArray * listArray = [dict objectForKey:@"data"];
                                                         
                                                         if ([listArray count] == 0) {
                                                             
                                                             //            [_noMoreView setHidden:YES];
                                                             
                                                         }
                                                         else{
                                                             
                                                             //            [_noMoreView setHidden:NO];
                                                             
                                                             if([listArray count] == 20)
                                                             {
                                                                 _canRefreshMore = YES;
                                                             }
                                                             else
                                                             {
                                                                 _canRefreshMore = NO;
                                                                 _gridView.loaderView = _noMoreView;
                                                             }
                                                         }
                                                         
                                                         _refreshing = NO;
                                                         
                                                         [_lastMinuteArray removeAllObjects];
                                                         [_lastMinuteArray addObjectsFromArray:listArray];
                                                         [_gridView reloadData];
                                                         [_gridView setContentOffset:CGPointZero animated:YES];
        
        
        
                                                     } failure:^{
                                                         
                                                         [self.view hideToastActivity];
        
        
                                                     }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if(_gridView.contentOffset.y + _gridView.frame.size.height > _gridView.contentSize.height - 300)
    {
        [self refreshMore];
    }
}

- (void)refreshMore
{
    if(_refreshing == YES)
    {
        return;
    }
    
    _refreshing = YES;
    
    if(_canRefreshMore)
    {
        _gridView.loaderView = _refreshMoreView;
    }
    else
    {
        _gridView.loaderView = _noMoreView;
    }
    
    [_refreshMoreLabel setHidden:NO];
    [_activityIndicatior startAnimating];
    
    NSUInteger lastID = [[[_lastMinuteArray lastObject] objectForKey:@"id"] integerValue];
    
    [[QYAPIClient sharedAPIClient] getLastMinuteListWithType:0
                                                       maxId:lastID -1
                                                    pageSize:20
                                                       times:@""
                                                 continentId:_contientID
                                                   countryId:_countryID
                                                   departure:@""
                                                     success:^(NSDictionary *dict) {
                                                         
                                                         NSArray * data = [dict objectForKey:@"data"];
                                                         
                                                         if ([data count] == 0) {
                                                             
                                                             _canRefreshMore = NO;
                                                             _gridView.loaderView = _noMoreView;
                                                             
                                                             //                                              [_noMoreView setHidden:YES];
                                                             
                                                         }
                                                         else{
                                                             
                                                             //                                              [_noMoreView setHidden:NO];
                                                             
                                                             if([data count] == 20)
                                                             {
                                                                 _canRefreshMore = YES;
                                                             }
                                                             else
                                                             {
                                                                 _canRefreshMore = NO;
                                                                 _gridView.loaderView = _noMoreView;
                                                             }
                                                         }
                                                         
                                                         _refreshing = NO;
                                                         [_lastMinuteArray addObjectsFromArray:data];
                                                         [_gridView reloadData];
                                                         [_activityIndicatior stopAnimating];
                                                         [_refreshMoreLabel setHidden:YES];

                                          
                                                         
                                                     } failure:^{
                                                         [self.view hideToast];
                                                         [self.view hideToastActivity];
                                                         [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];

                                                         
                                                         _refreshing = NO;
                                                         [_activityIndicatior stopAnimating];
                                                         [_refreshMoreLabel setHidden:YES];
                                                     }];
}





#pragma mark - SMGridViewDataSource

- (BOOL)smGridViewShowLoader:(SMGridView *)gridView {
    return  YES;
}

- (NSInteger)numberOfSectionsInSMGridView:(SMGridView *)gridView {
    return 1;
}

- (int)smGridView:(SMGridView *)gridView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (int)smGridView:(SMGridView *)gridView numberOfItemsInSection:(NSInteger)section {
    return [_lastMinuteArray count];
}

- (UIView *)smGridView:(SMGridView *)gridView viewForIndexPath:(NSIndexPath *)indexPath {
    LastMinuteView *view = (LastMinuteView *)[gridView dequeReusableViewOfClass:[LastMinuteView class]];
    if (!view) {
        view = [[[LastMinuteView alloc] initWithFrame:CGRectMake(0, 0, 148, 168)] autorelease];
        view.backgroundColor = [UIColor clearColor];
        view.delegate = self;
    }
    
    if (_lastMinuteArray.count >0) {
        [view setLastMinute:[_lastMinuteArray objectAtIndex:indexPath.row]];
    }
    
    return view;
}

- (CGSize)smGridView:(SMGridView *)gridView sizeForIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(145, 170);//CGSizeMake(145, 173);
}

//- (UIView *)smGridView:(SMGridView *)gridView viewForHeaderInSection:(NSInteger)section {
//    return nil;
//}
//
//- (CGSize)smGridView:(SMGridView *)gridView sizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeZero;
//}


- (void)lastMinuteViewDidTap:(LastMinuteDeal *)lastMinute
{
    NSDictionary * dictttt = (NSDictionary *)lastMinute;
    int dealID = [[dictttt objectForKey:@"id"] integerValue];
    
    //*********** Insert By ZhangDong 2014.4.8 Start ***********
//    LastMinuteDetailViewController * lastDetailVC = [[LastMinuteDetailViewController alloc]init];
//    lastDetailVC.dealID = dealID;
//    [self.navigationController pushViewController:lastDetailVC animated:YES];
//    [lastDetailVC release];
    
    //by jessica
    LastMinuteDetailViewControllerNew * lastDetailVC = [[LastMinuteDetailViewControllerNew alloc]init];
    lastDetailVC.lastMinuteId = dealID;
    lastDetailVC.source = NSStringFromClass([self class]);
    [self.navigationController pushViewController:lastDetailVC animated:YES];
    [lastDetailVC release];
    
    
    //*********** Insert By ZhangDong 2014.4.8 End ***********
    
    //*********** Del By ZhangDong 2014.4.8 Start ***********
//    NSString * token = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_access_token"];
//    
//    [[QYAPIClient sharedAPIClient]getLastMinuteDetailWithID:dealID OAuthToken:token success:^(NSDictionary *dic) {
//        
//        NSString * detailUrlString = [[dic objectForKey:@"data"] objectForKey:@"app_url"];
//        
//        NSString * originUrlString = @"";
//        if ([[[dic objectForKey:@"data"] objectForKey:@"m_qyer_url"] isKindOfClass:[NSString class]] && ![[[dic objectForKey:@"data"] objectForKey:@"m_qyer_url"] isEqualToString:@""]) {
//            originUrlString = [[dic objectForKey:@"data"] objectForKey:@"m_qyer_url"];
//        }
//        else{
//            originUrlString = [[dic objectForKey:@"data"] objectForKey:@"qyer_url"];
//        }
//        
//        LastMinuteDetailViewController * lastDetailVC = [[LastMinuteDetailViewController alloc]init];
//        lastDetailVC.dealURL = [NSString stringWithFormat:@"%@",detailUrlString];
//        lastDetailVC.originalURL = [NSString stringWithFormat:@"%@",originUrlString];
//        [self.navigationController pushViewController:lastDetailVC animated:YES];
//        [lastDetailVC release];
//        
//    } failure:^{
//        
//    }];
    //*********** Del By ZhangDong 2014.4.8 Start ***********
}







-(void)dealloc
{
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
