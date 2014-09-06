//
//  TSDetailViewController.m
//  TravelSubject
//
//  Created by chenguanglin on 14-7-18.
//  Copyright (c) 2014年 chenguanglin. All rights reserved.
//

#import "TSDetailViewController.h"
#import "TSDetailTableViewCell.h"
#import "UIImage+resize.h"
#import "QYAPIClient.h"
#import "LoadMoreView.h"
#import "TSDetailCellModel.h"
#import "TSDetailCellFrame.h"
#import "UIImageView+WebCache.h"
#import "UIImage+resize.h"
#import "PoiDetailViewController.h"
#import "QYToolObject.h"

#define navigationBarHight      (ios7 ? (44 + 20) : 44)

@interface TSDetailViewController ()<UITableViewDelegate,UITableViewDataSource,TSDetailTableViewCellDelegate>

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIImageView *topImageView;

@property (nonatomic, strong) UIImageView *userIcon;

@property (nonatomic, strong) UILabel *userNameLable;

@property (nonatomic, strong) UILabel *titleLable;

@property (nonatomic, strong) UILabel *subTitleLable;

@property (nonatomic, strong) UIButton *placeNumButton;

@property (nonatomic, strong) UIImageView *leftMark;

@property (nonatomic, strong) UIImageView *rightMark;

@property (nonatomic, strong) UILabel *descriptionLable;

@property (nonatomic, strong) NSMutableArray *TSDetailFrames;


@property (nonatomic, strong) LoadMoreView *footView;

@property (nonatomic, assign) int page;

@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, strong) UITableView *travelTableView;

@property (nonatomic, strong) NSMutableDictionary *detailDict;
/**
 *  点击标志防止多次一起点击poi
 */
@property (nonatomic, assign) BOOL clickFlag;

@property (nonatomic, strong) UIView *userImageBackground;

@end

@implementation TSDetailViewController
- (int)page
{
    if(_page == 0){
        _page = 1;
    }
    return _page;
}

- (NSString *)source
{
    if (!_source) {
        _source = @"";
    }
    return _source;
}
- (NSMutableArray *)TSDetailFrames
{
    if (!_TSDetailFrames) {
        _TSDetailFrames = [NSMutableArray array];
    }
    return _TSDetailFrames;
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
    
    [self initNavigationBar];
    
    [self initTableView];
    
    [self loadDataFromRemote];
}
- (void)viewWillAppear:(BOOL)animated
{
    self.clickFlag = true;
}

- (void)initTableView
{
    _travelTableView = [[UITableView alloc] init];
    _travelTableView.backgroundColor = RGB(232, 242, 249);
    _travelTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _travelTableView.delegate = self;
    _travelTableView.dataSource = self;
    _travelTableView.contentInset = ios7 ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, 0, 20, 0);
    _travelTableView.showsVerticalScrollIndicator = NO;

    _footView = [[LoadMoreView alloc]initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
    _footView.hidden = YES;
    _footView.backgroundColor = [UIColor clearColor];
    [_travelTableView setTableFooterView:_footView];
    
    CGFloat W = [UIScreen mainScreen].bounds.size.width;
    CGFloat H = [UIScreen mainScreen].bounds.size.height - navigationBarHight;
    CGFloat X = 0;
    CGFloat Y = navigationBarHight;
    _travelTableView.frame = CGRectMake(X, Y, W, H);
    
    [self.view addSubview:_travelTableView];
    
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 397)];
    _topView.backgroundColor = RGB(232, 242, 249);
    
    _topImageView = [[UIImageView alloc] init];
    CGFloat topImageViewX = 0;
    CGFloat topImageViewY = 0;
    CGFloat topImageViewW = [UIScreen mainScreen].bounds.size.width;
    CGFloat topImageViewH = 170;
    _topImageView.frame = CGRectMake(topImageViewX, topImageViewY, topImageViewW, topImageViewH);
    _topImageView.backgroundColor = [UIColor clearColor];
    _topImageView.contentMode = UIViewContentModeScaleAspectFill;
    _topImageView.clipsToBounds = YES;
    [self.topView addSubview:_topImageView];
    
    //旅行地数量
    CGFloat placeW = 80;
    CGFloat placeH = 20;
    CGFloat placeX = topImageViewW - 10 - placeW;
    CGFloat placeY = 10;
    _placeNumButton = [[UIButton alloc] init];
    _placeNumButton.userInteractionEnabled = NO;
    _placeNumButton.hidden = YES;
    _placeNumButton.frame = CGRectMake(placeX, placeY, placeW, placeH);
    _placeNumButton.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:12];
    [_placeNumButton setBackgroundImage:[UIImage resizedImageWithName:@"bg_旅行地"] forState:UIControlStateNormal];
    [_topImageView addSubview:_placeNumButton];
    
    //头像白色背景
    CGFloat userIconBackgroundW = 58;
    CGFloat userIconBackgroundH = 58;
    CGFloat userIconBackgroundX = (topImageViewW - userIconBackgroundW) / 2;
    CGFloat userIconBackgroundY = topImageViewH - userIconBackgroundH / 12 * 7;
    _userImageBackground = [[UIView alloc] init];
    _userImageBackground.frame = CGRectMake(userIconBackgroundX, userIconBackgroundY, userIconBackgroundW, userIconBackgroundH);
    _userImageBackground.backgroundColor = [UIColor whiteColor];
    _userImageBackground.hidden = YES;
    _userImageBackground.layer.cornerRadius = userIconBackgroundW / 2;
    _userImageBackground.layer.masksToBounds = YES;
    _userImageBackground.clipsToBounds = YES;
    [_topView addSubview:_userImageBackground];
    
    //头像
    _userIcon = [[UIImageView alloc] init];
    _userIcon.backgroundColor = [UIColor clearColor];
    CGFloat userIconW = 54;
    CGFloat userIconH = 54;
    CGFloat userIconX = 2;
    CGFloat userIconY = 2;
    _userIcon.frame = CGRectMake(userIconX, userIconY, userIconW, userIconH);
    _userIcon.layer.cornerRadius = userIconW / 2;
    _userIcon.layer.masksToBounds = YES;
    _userIcon.clipsToBounds = YES;
    [_userImageBackground addSubview:_userIcon];
    
    //用户昵称
    _userNameLable = [[UILabel alloc] init];
    _userNameLable.textColor = RGB(158, 163, 171);
    _userNameLable.backgroundColor = [UIColor clearColor];
    _userNameLable.textAlignment = NSTextAlignmentCenter;
    _userNameLable.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    CGFloat userNameW = topImageViewW;
    CGFloat userNameH = 20;
    CGFloat userNameX = 0;
    CGFloat userNameY = userIconBackgroundY + userIconH + 5;
    _userNameLable.frame = CGRectMake(userNameX, userNameY, userNameW, userNameH);
    [_topView addSubview:_userNameLable];
    //标题
    _titleLable = [[UILabel alloc] init];
    _titleLable.backgroundColor = [UIColor clearColor];
    _titleLable.textColor = RGB(68, 68, 68);
    _titleLable.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:22];
    _titleLable.numberOfLines = 0;
    [_topView addSubview:_titleLable];
    //左引号
    _leftMark = [[UIImageView alloc] init];
    _leftMark.backgroundColor = [UIColor clearColor];
    _leftMark.image = [UIImage imageNamed:@"quote_left"];
    [_topView addSubview:_leftMark];
    //右引号
    _rightMark = [[UIImageView alloc] init];
    _rightMark.backgroundColor = [UIColor clearColor];
    _rightMark.image = [UIImage imageNamed:@"quote_right"];
    [_topView addSubview:_rightMark];
    //简介
    _descriptionLable = [[UILabel alloc] init];
    _descriptionLable.numberOfLines = 0;
    _descriptionLable.textColor = RGB(68, 68, 68);
    _descriptionLable.font = [UIFont systemFontOfSize:14];
    _descriptionLable.backgroundColor = [UIColor clearColor];
    [_topView addSubview:_descriptionLable];
    
    [_travelTableView setTableHeaderView:_topView];
    
}

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
    titleLable.text = @"主题详情";
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
/**
 *  数据字典的设置方法
 */
- (void)setDetailDict:(NSMutableDictionary *)detailDict
{
    _detailDict = detailDict;
    
    self.userImageBackground.hidden = NO;
    
    [self.topImageView setImageWithURL:[NSURL URLWithString:[detailDict objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"default_co_back"]];
    self.topImageView.contentMode = UIViewContentModeScaleToFill;
    [self.userIcon setImageWithURL:[NSURL URLWithString:[detailDict objectForKey:@"avatar"]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    self.userNameLable.text = [detailDict objectForKey:@"username"];
    [self.placeNumButton setTitle:[NSString stringWithFormat:@"%@个旅行地",[detailDict objectForKey:@"count"]] forState:UIControlStateNormal];
    self.placeNumButton.hidden = NO;
    self.titleLable.text = [detailDict objectForKey:@"title"];
    self.descriptionLable.text = [detailDict objectForKey:@"description"];
    CGFloat titleX = 36;
    CGFloat titleY = self.userNameLable.frame.origin.y + self.userNameLable.frame.size.height + 8;
    CGFloat titleW = [UIScreen mainScreen].bounds.size.width - titleX * 2;
    CGSize titleSize = [self.titleLable.text sizeWithFont:self.titleLable.font constrainedToSize:CGSizeMake(titleW, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    titleW = titleSize.width;
    titleX = ([UIScreen mainScreen].bounds.size.width - titleW) / 2;
    CGFloat titleH = titleSize.height;
    _titleLable.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    CGFloat leftMarkX = 9;
    CGFloat leftMarkY = titleY + titleH + 5;
    CGFloat leftMarkW = 24;
    CGFloat leftMarkH = leftMarkW;
    self.leftMark.frame = CGRectMake(leftMarkX, leftMarkY, leftMarkW, leftMarkH);
    
    CGFloat descriptionX = leftMarkX + leftMarkW + 6;
    CGFloat descriptionY = leftMarkY + 13;
    CGFloat descriptionW = UIScreenWidth - 66;
    CGFloat descriptionH;
//    CGSize descriptionSize = [self.descriptionLable.text sizeWithFont:self.descriptionLable.font constrainedToSize:CGSizeMake(descriptionW, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize descriptionSize = [QYToolObject getContentSize:self.descriptionLable.text font:self.descriptionLable.font width:descriptionW];
    descriptionW = descriptionSize.width;
    descriptionH = descriptionSize.height;
    self.descriptionLable.frame = CGRectMake(descriptionX, descriptionY, descriptionW, descriptionH);
    
    CGFloat rightMarkX = UIScreenWidth - 33;
    CGFloat rightMarkY = descriptionY + descriptionH - 6;
    CGFloat rightMarkW = leftMarkW;
    CGFloat rightMarkH = rightMarkW;
    self.rightMark.frame = CGRectMake(rightMarkX, rightMarkY, rightMarkW, rightMarkH);
    
    self.topView.frame = CGRectMake(0, 0, UIScreenWidth, rightMarkY + rightMarkH + 11);
    
    [self.travelTableView setTableHeaderView:self.topView];
    
    
    NSMutableArray *models = [NSMutableArray array];
    for (NSDictionary *dict in detailDict[@"pois"]) {

        TSDetailCellModel *detailModel = [[TSDetailCellModel alloc] initWithDict:dict];
        
        TSDetailCellFrame *detailFrame = [[TSDetailCellFrame alloc] init];
        
        detailFrame.TSDetailModel = detailModel;
        
        [models addObject:detailFrame];

    }

    [self.TSDetailFrames addObjectsFromArray:models];

    if (models.count < 10) {
        _footView.isHaveData = NO;

    }else{

        _footView.isHaveData = YES;

    }
    _footView.hidden = NO;

    [_travelTableView reloadData];

    
}
/**
 *  从网络上加载数据
 */
- (void)loadDataFromRemote
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
    
    [[QYAPIClient sharedAPIClient] getTravelSubjectDetailWithID:self.ID page:self.page source:self.source success:^(NSDictionary *dic) {
        
        
        if ([[dic objectForKey:@"status"] intValue] == 1){

            _isLoading = NO;
            [_footView changeLoadingStatus:_isLoading];

            [self.view hideToastActivity];
            self.page++;
            self.detailDict = [dic objectForKey:@"data"];
            
        }

    } failed:^{
        
    }];

}


#pragma mark-
#pragma mark-----TableView的代理方法和数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.TSDetailFrames.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSDetailTableViewCell *cell = [TSDetailTableViewCell cellWithTableView:tableView];
    
    cell.TSDetailFrame = self.TSDetailFrames[indexPath.row];
    cell.delegate = self;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.TSDetailFrames.count - 1) {
        return [self.TSDetailFrames[indexPath.row] cellHeight] - 10;
    }else{
        return [self.TSDetailFrames[indexPath.row] cellHeight];
    }
}

#pragma mark-
#pragma mark-----UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_footView.isHaveData == NO) {
        return;
    }
    if(_travelTableView.contentOffset.y + _travelTableView.frame.size.height - _travelTableView.contentSize.height >= 10 && _isLoading == NO)
    {
        _isLoading = YES;
        
        [_footView changeLoadingStatus:_isLoading];
        
        [self loadDataFromRemote];
        
    }
    
}
#pragma mark-
#pragma mark-----TSDetailTableViewCellDelegate
- (void)poiClick:(NSInteger)ID
{
    if (self.clickFlag) {
        
        PoiDetailViewController *poiVC = [[PoiDetailViewController alloc] init];
        poiVC.poiId = ID;
        [self.navigationController pushViewController:poiVC animated:YES];
        self.clickFlag = false;
    }
    
}
@end
