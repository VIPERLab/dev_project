//
//  TravelSubjectViewController.m
//  QYER
//
//  Created by chenguanglin on 14-7-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "TravelSubjectViewController.h"
#import "TravelSubjectModel.h"
#import "TravelSubjectTableViewCell.h"
#import "TSDetailViewController.h"
#import "QYAPIClient.h"


#define navigationBarHight      (ios7 ? (44 + 20) : 44)

@interface TravelSubjectViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *TSModelArray;

@property (nonatomic, strong) UITableView *travelTableView;

@property (nonatomic, strong) LoadMoreView *footView;

@property (nonatomic, assign) int page;

@property (nonatomic, assign) BOOL isLoading;

@end

@implementation TravelSubjectViewController

- (int)page
{
    if(_page == 0)
    {
        _page = 1;
    }
    return _page;
}
- (void)setType:(NSString *)type
{
    if ([type isEqualToString:@"1"]) {
        _type = @"country";
        
        [MobClick event:@"countryClickMcGuide"];
    }
    if ([type isEqualToString:@"2"]) {
        _type = @"city";
        
        [MobClick event:@"cityClickMcGuide"];
    }
}
- (NSMutableArray *)TSModelArray
{
    if (!_TSModelArray) {
        _TSModelArray = [NSMutableArray array];
    }
    return _TSModelArray;
}
-(void)touchesView{
    
    [self.view makeToastActivity];
    [self loadDataFromInternet];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-
#pragma mark-----View的初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    //导航栏的初始化
    [self initNavigationBar];
    
    //tableView的初始化
    [self initTableView];
    
    [self loadDataFromInternet];
    
    
}
/**
 *  TableView 的初始化
 */
- (void)initTableView
{
    _travelTableView = [[UITableView alloc] init];
    _travelTableView.backgroundColor = RGB(232, 242, 249);
    _travelTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _travelTableView.delegate = self;
    _travelTableView.dataSource = self;
    _travelTableView.contentInset = ios7 ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, 0, 20, 0);
    _travelTableView.showsVerticalScrollIndicator = NO;
    
    CGFloat W = [UIScreen mainScreen].bounds.size.width;
    CGFloat H = [UIScreen mainScreen].bounds.size.height - navigationBarHight;
    CGFloat X = 0;
    CGFloat Y = navigationBarHight;
    _travelTableView.frame = CGRectMake(X, Y, W, H);
    
    [self.view addSubview:_travelTableView];
    
    _footView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
    _footView.hidden = YES;
    _footView.backgroundColor = [UIColor clearColor];
    [_travelTableView setTableFooterView:_footView];
    
}

/**
 *  导航栏的初始化
 */
-(void)initNavigationBar
{
    UIView *navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, navigationBarHight)];
    navigationBar.backgroundColor = RGB(44, 171, 121);
    
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
    titleLable.text = @"主题推荐";
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.textColor = [UIColor whiteColor];
    titleLable.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    [navigationBar addSubview:titleLable];
    [self.view addSubview:navigationBar];
}
/**
 *  返回按钮的点击
 */
-(void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)loadDataFromInternet
{
    if (isNotReachable && self.page == 1) {
        
        [super setNotReachableView:YES];
        [self.view hideToastActivity];
        return;
    }else{
        
        [super setNotReachableView:NO];
    }
    if (self.page == 1) {
        [self.view makeToastActivity];
    }
    NSLog(@"self.page%d",self.page);
    
    [[QYAPIClient sharedAPIClient] getTravelSubjectListWithType:self.type ID:self.ID count: 10 page:self.page success:^(NSDictionary *dic) {
        if ([[dic objectForKey:@"status"] intValue] == 1){
            
            _isLoading = NO;
            [_footView changeLoadingStatus:_isLoading];
            
            [self.view hideToastActivity];
            self.page++;
            
            NSMutableArray *models = [NSMutableArray array];
            for (NSDictionary *dict in dic[@"data"]) {
                
                TravelSubjectModel *TSModel = [[TravelSubjectModel alloc] initWithDict:dict];
                if(TSModel.ID.length > 0){
                    [models addObject:TSModel];
                }
            }
            
            [self.TSModelArray addObjectsFromArray:models];
            
            if (models.count < 10) {
                _footView.isHaveData = NO;
                
            }else{
                
                _footView.isHaveData = YES;
                
            }
            _footView.hidden = NO;
            
            [_travelTableView reloadData];

        }
    } failed:^{
//        NSLog(@"=================失败了");
        _isLoading = NO;
//        _footView.isHaveData = NO;
        [_footView changeLoadingStatus:_isLoading];
    }];
}
#pragma mark-
#pragma mark-----TableView的代理方法及数据源方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.TSModelArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TravelSubjectTableViewCell *cell = [TravelSubjectTableViewCell cellWithTableView:tableView];
    
    cell.TSModel = self.TSModelArray[indexPath.row];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.TSModelArray.count - 1) {
        return 239;
    }else{
        return 249;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TravelSubjectModel *model = self.TSModelArray[indexPath.row];
    TSDetailViewController *TSDetailVC = [[TSDetailViewController alloc] init];
    TSDetailVC.ID = model.ID;
    [self.navigationController pushViewController:TSDetailVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_footView.isHaveData == NO) {
        return;
    }
    if(_travelTableView.contentOffset.y + _travelTableView.frame.size.height - _travelTableView.contentSize.height >= 10 && _isLoading == NO)
    {
        _isLoading = YES;
        
        [_footView changeLoadingStatus:_isLoading];
        
        [self loadDataFromInternet];
        
    }

}

@end
