//
//  GoneAndWantGoCitiesViewController.m
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "GoneAndWantGoCitiesViewController.h"
#import "ChangeTableviewContentInset.h"
#import "GoneAndWantGoCitiesData.h"
#import "ChangeTableviewContentInset.h"
#import "GoneAndWantGoCities.h"
#import "PoiDetailViewController.h"
#import "PoiRateView.h"
#import "CountryViewController.h"
#import "MyControl.h"


#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (4+20) : 6)
#define     height_titlelabel           (ios7 ? (30) : 34)
#define     positionY_backbutton        (ios7 ? 22 : 2)





@interface GoneAndWantGoCitiesViewController ()

@end





@implementation GoneAndWantGoCitiesViewController
@synthesize user_id;
@synthesize city_id;
@synthesize titleName;
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
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_tableView_GoneAndWantGoCities);
    QY_VIEW_RELEASE(_imageView_default);
    
    QY_MUTABLERECEPTACLE_RELEASE(_array_GoneAndWantGoCities);
    
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
        
        
        newFrame = _tableView_GoneAndWantGoCities.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableView_GoneAndWantGoCities.frame = newFrame;
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        newFrame = _tableView_GoneAndWantGoCities.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableView_GoneAndWantGoCities.frame = newFrame;
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
    
    
    
    if(!_array_GoneAndWantGoCities || _array_GoneAndWantGoCities.count == 0)
    {
        [self initGoneAndWantGoCitiesData];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentDidSuccess) name:@"comment_success" object:nil];
    
    [self initRootView];
    [self initHeadView];
    [self initDic];
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
    _titleLabel.text = self.titleName;
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
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(320-80/2, positionY_backbutton, 80/2, 80/2);
    button.backgroundColor = [UIColor clearColor];
    [button setBackgroundImage:[UIImage imageNamed:@"icon_detail2"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showCityInfo:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:button];
}
-(void)initDic
{
    if(!_array_GoneAndWantGoCities)
    {
        _array_GoneAndWantGoCities = [[NSMutableArray alloc] init];
    }
    [_array_GoneAndWantGoCities removeAllObjects];
    
}
-(void)initTableView
{
    if(!_tableView_GoneAndWantGoCities)
    {
        _tableView_GoneAndWantGoCities = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [self.view bounds].size.height)];
//        if(!ios7)
//        {
//            _tableView_GoneAndWantGoCities.frame = CGRectMake(0, 0, 320, ([self.view bounds].size.height-20));
//        }
        _tableView_GoneAndWantGoCities.backgroundColor = [UIColor clearColor];
        _tableView_GoneAndWantGoCities.separatorColor = [UIColor clearColor];
        _tableView_GoneAndWantGoCities.dataSource = self;
        _tableView_GoneAndWantGoCities.delegate = self;
    }
    
    _tableView_GoneAndWantGoCities.hidden = NO;
    [ChangeTableviewContentInset changeWithTableView:_tableView_GoneAndWantGoCities];
    [self.view addSubview:_tableView_GoneAndWantGoCities];
    [self.view bringSubviewToFront:_headView];
    [_tableView_GoneAndWantGoCities reloadData];
    
    if(_flag_fresh)
    {
        _flag_fresh = NO;
        _tableView_GoneAndWantGoCities.contentOffset = point_src;
    }
    
}
-(void)initTableViewFootViewWithFlag:(BOOL)flag
{
    if(!flag)
    {
        _tableView_GoneAndWantGoCities.tableFooterView = nil;
    }
    else
    {
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        footView.backgroundColor = [UIColor clearColor];
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, footView.frame.size.height)] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"加载更多";
        _tableView_GoneAndWantGoCities.tableFooterView = footView;
        [footView release];
    }
}



#pragma mark -
#pragma mark ---
-(void)initGoneAndWantGoCitiesData
{
    if(_array_GoneAndWantGoCities && _array_GoneAndWantGoCities.count > 0)
    {
        [_tableView_GoneAndWantGoCities reloadData];
    }
    else
    {
        [self getGoneAndWantGoCitiesDataFromServer];
    }
}
-(void)getGoneAndWantGoCitiesDataFromServer
{
    [self.view makeToastActivity];
    
    
    point_src = _tableView_GoneAndWantGoCities.contentOffset;
    NSString *user_id_ = [NSString stringWithFormat:@"%d",self.user_id];
    if(_pageNumber == 0)
    {
        _pageNumber = 1;
    }
    
    [GoneAndWantGoCitiesData getGoneAndWantGoCitiesDataWithUserid:user_id_
                                                        andCityId:[NSString stringWithFormat:@"%d",self.city_id]
                                                          andType:self.type
                                                          success:^(GoneAndWantGoCities *obj){
                                                              NSLog(@" getGoneAndWantGoCitiesData 成功 : %@",obj);
                                                              
                                                              if(_imageView_default)
                                                              {
                                                                  _imageView_default.hidden = YES;
                                                              }
                                                              [self.view hideToastActivity];
                                                              if(obj && obj.array_poiInfo && obj.array_poiInfo.count > 0)
                                                              {
                                                                  [_array_GoneAndWantGoCities addObjectsFromArray:obj.array_poiInfo];
                                                                  [self performSelector:@selector(initTableView) withObject:nil afterDelay:0.2];
                                                                  NSLog(@" _array_GoneAndWantGoCities : %@",_array_GoneAndWantGoCities);
                                                              }
                                                              else
                                                              {
                                                                  [self performSelector:@selector(initDefaultView) withObject:nil afterDelay:0.2]; //没有数据
                                                              }
                                                          }
                                                           failed:^{
                                                               NSLog(@" getGoneAndWantGoCitiesData 失败");
                                                               [self.view hideToastActivity];
                                                           }];
}
-(void)initDefaultView
{
    if(_tableView_GoneAndWantGoCities)
    {
        _tableView_GoneAndWantGoCities.hidden = YES;
    }
    
    if(!_imageView_default)
    {
        _imageView_default = [[UIImageView alloc] init];
        _imageView_default.backgroundColor = [UIColor clearColor];
        if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
        {
            _imageView_default.frame = CGRectMake(0, (self.view.bounds.size.height-340/2)/2, 640/2, 340/2);
            _imageView_default.image = [UIImage imageNamed:@"旅行地为空"];
        }
        else
        {
            _imageView_default.frame = CGRectMake(0, (self.view.bounds.size.height-300/2)/2, 640/2, 300/2);
            _imageView_default.image = [UIImage imageNamed:@"Ta旅行地为空"];
        }
    }
    [self.view addSubview:_imageView_default];
    _imageView_default.hidden = NO;
}



#pragma mark -
#pragma mark --- UITableView - DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = [_array_GoneAndWantGoCities count];
    if(number%2 == 0)
    {
        number = number/2;
    }
    else
    {
        number = number/2 + 1;
    }
    return number;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.type && [self.type isEqualToString:@"hasgone"])
    {
        return (20+224+134+20)/2;
    }
    else if(self.type && [self.type isEqualToString:@"wantgo"])
    {
        return (20+274+20)/2;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WantGo_hasGoneCitiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WantGoOrHasGoneCell"];
    if(cell == nil)
    {
        if(self.type && [self.type isEqualToString:@"hasgone"])
        {
//            BOOL flag = NO;
//            if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
//            {
//                flag = YES;
//            }
            cell = [[[WantGo_hasGoneCitiesCell alloc] initHasGoneWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WantGoOrHasGoneCell" andType:YES] autorelease];
        }
        else if(self.type && [self.type isEqualToString:@"wantgo"])
        {
            cell = [[[WantGo_hasGoneCitiesCell alloc] initWantGoWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WantGoOrHasGoneCell"] autorelease];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    BOOL flag = NO;
    if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
    {
        flag = YES;
    }
    [cell initDataWithArray:_array_GoneAndWantGoCities atIndex:indexPath.row withType:self.type isMinInfo:flag];
    return cell;
}



#pragma mark -
#pragma mark --- WantGo_hasGoneCitiesCell - Delegate
-(void)selectedLeftImageViewWithPoiId:(NSInteger)poiid
{
    NSLog(@"    选择的poiid : %d",poiid);
    
    PoiDetailViewController *poidetailVC = [[PoiDetailViewController alloc] init];
    poidetailVC.poiId = poiid;
    [self.navigationController pushViewController:poidetailVC animated:YES];
    [poidetailVC release];
}
-(void)selectedRightImageViewWithPoiId:(NSInteger)poiid
{
    NSLog(@"    选择的poiid : %d",poiid);
    
    PoiDetailViewController *poidetailVC = [[PoiDetailViewController alloc] init];
    poidetailVC.poiId = poiid;
    [self.navigationController pushViewController:poidetailVC animated:YES];
    [poidetailVC release];
}
-(void)addCommentLeft:(WantGo_hasGoneCitiesCell *)cell
{
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    
    
    NSInteger poiId = cell.poiId_left;
    NSInteger positionY = 44;
    if(ios7)
    {
        positionY = positionY + 20;
    }
    PoiRateView *_poiRateView = [[PoiRateView alloc] initWithFrame:CGRectMake((320-580/2)/2., positionY, 580/2, 1136/2) andLeftButTitle:@"取消" andRightButTitle:@"发送" andRate:@"0" andVC:self];
    [_poiRateView setTextViewText:@""];
    _poiRateView.poiTitle = cell.label_poiName_cn_left.text;
    _poiRateView.poiId = poiId;
    [_poiRateView release];
}
-(void)addCommentRight:(WantGo_hasGoneCitiesCell *)cell
{
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    
    NSInteger poiId = cell.poiId_right;
    NSInteger positionY = 44;
    if(ios7)
    {
        positionY = positionY + 20;
    }
    PoiRateView *_poiRateView = [[PoiRateView alloc] initWithFrame:CGRectMake((320-580/2)/2., positionY, 580/2, 1136/2) andLeftButTitle:@"取消" andRightButTitle:@"发送" andRate:@"0" andVC:self];
    [_poiRateView setTextViewText:@""];
    _poiRateView.poiTitle = cell.label_poiName_cn_right.text;
    _poiRateView.poiId = poiId;
    [_poiRateView release];
}
-(void)updateCommentLeft:(MyControl *)control
{
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    
    NSDictionary *dic = control.info;
    NSInteger poiId = [[dic objectForKey:@"poiid"] intValue];
    NSString *text = [dic objectForKey:@"review"];
    NSString *rate = [dic objectForKey:@"rate"];
    
    NSInteger positionY = 44;
    if(ios7)
    {
        positionY = positionY + 20;
    }
    PoiRateView *_poiRateView = [[PoiRateView alloc] initWithFrame:CGRectMake((320-580/2)/2., positionY, 580/2, 1136/2) andLeftButTitle:@"取消" andRightButTitle:@"发送" andRate:rate andVC:self];
    [_poiRateView setTextViewText:text];
    _poiRateView.poiId = poiId;
    _poiRateView.commentId_user = [dic objectForKey:@"comment_id"];
    [_poiRateView release];
}
-(void)updateCommentRight:(MyControl *)control
{
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    [self performSelector:@selector(changeFlag) withObject:nil afterDelay:0.5];
    
    NSDictionary *dic = control.info;
    NSInteger poiId = [[dic objectForKey:@"poiid"] intValue];
    NSString *text = [dic objectForKey:@"review"];
    NSString *rate = [dic objectForKey:@"rate"];
    
    NSInteger positionY = 44;
    if(ios7)
    {
        positionY = positionY + 20;
    }
    PoiRateView *_poiRateView = [[PoiRateView alloc] initWithFrame:CGRectMake((320-580/2)/2., positionY, 580/2, 1136/2) andLeftButTitle:@"取消" andRightButTitle:@"发送" andRate:rate andVC:self];
    [_poiRateView setTextViewText:text];
    _poiRateView.poiId = poiId;
    _poiRateView.commentId_user = [dic objectForKey:@"comment_id"];
    [_poiRateView release];
}
-(void)changeFlag
{
    _flag_delay = NO;
}



#pragma mark -
#pragma mark --- 计算String所占的宽度
-(float)countContentLabelHeightByString:(NSString *)content andHeight:(float)height andFontSize:(float)font
{
    //CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:fontName_ size:font] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)];
    
    return sizeToFit.width;
}



#pragma mark -
#pragma mark --- 点评成功
-(void)commentDidSuccess
{
    _flag_fresh = YES;
    [_array_GoneAndWantGoCities removeAllObjects];
    [self getGoneAndWantGoCitiesDataFromServer];
}



#pragma mark -
#pragma mark --- 城市详情
-(void)showCityInfo:(id)sender
{
    CountryViewController *countryVC = [[CountryViewController alloc]init];
    countryVC.type = 2;
    countryVC.key = [NSString stringWithFormat:@"%d",self.city_id];
    [self.navigationController pushViewController:countryVC animated:YES];
    [countryVC release];
}



#pragma mark -
#pragma mark --- clickBackButton
-(void)clickBackButton:(id)sender
{
    NSString *user_id_ = [NSString stringWithFormat:@"%d",self.user_id];
    [GoneAndWantGoCitiesData cancleGetGoneAndWantGoCitiesDataWithUserid:user_id_
                                                              andCityId:[NSString stringWithFormat:@"%d",self.city_id]
                                                                andType:self.type];
    
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
