//
//  HasGoneViewController.m
//  QYER
//
//  Created by 我去 on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "HasGoneViewController.h"
#import "ChangeTableviewContentInset.h"
#import "HasGoneData.h"
#import "HasGone.h"
#import "CountryViewController.h"
#import "GoneAndWantGoCitiesViewController.h"



#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (4+20) : 6)
#define     height_titlelabel           (ios7 ? (30) : 34)
#define     positionY_backbutton        (ios7 ? 20 : 0)
#define     interval_countrynamecn_countrynameen 10





@interface HasGoneViewController ()

@end




@implementation HasGoneViewController

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
    QY_VIEW_RELEASE(_tableView_hasGone);
    
    QY_MUTABLERECEPTACLE_RELEASE(_array_country)
    QY_MUTABLERECEPTACLE_RELEASE(_array_country_en)
    QY_MUTABLERECEPTACLE_RELEASE(_dic_hasGone)
    
    QY_VIEW_RELEASE(_imageView_default);
    
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
        
        
        newFrame = _tableView_hasGone.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableView_hasGone.frame = newFrame;
        
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        newFrame = _tableView_hasGone.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableView_hasGone.frame = newFrame;
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
    
    
    
    if(!_dic_hasGone || _dic_hasGone.count == 0)
    {
        [self initHasGoneData];
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
    [self initDic];
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
    if(self.user_id != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
    {
        _titleLabel.text = @"TA的足迹";
    }
    else
    {
        _titleLabel.text = @"我的足迹";
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
-(void)initDic
{
    if(!_dic_hasGone)
    {
        _dic_hasGone = [[NSMutableDictionary alloc] init];
    }
    [_dic_hasGone removeAllObjects];
    
    if(!_array_country)
    {
        _array_country = [[NSMutableArray alloc] init];
    }
    [_array_country removeAllObjects];
}
-(void)initTableView
{
    if(!_tableView_hasGone)
    {
        _tableView_hasGone = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [self.view bounds].size.height)];
        if(!ios7)
        {
            _tableView_hasGone.frame = CGRectMake(0, 0, 320, ([self.view bounds].size.height-20));
        }
        _tableView_hasGone.backgroundColor = [UIColor clearColor];
        _tableView_hasGone.separatorColor = [UIColor clearColor];
        _tableView_hasGone.dataSource = self;
        _tableView_hasGone.delegate = self;
    }
    
    [ChangeTableviewContentInset changeWithTableView:_tableView_hasGone];
    [self.view addSubview:_tableView_hasGone];
    [self.view bringSubviewToFront:_headView];
}
-(void)initTableViewFootViewWithFlag:(BOOL)flag
{
    if(!flag)
    {
        _tableView_hasGone.tableFooterView = nil;
    }
    else
    {
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        footView.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, footView.frame.size.height)];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"加载更多";
        [footView addSubview:label];
        _tableView_hasGone.tableFooterView = footView;
        [label release];
        [footView release];
    }
}
-(void)initDefaultView
{
    if(!_imageView_default)
    {
        _imageView_default = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height-294/2)/2, 320, 294/2)];
    }
    _imageView_default.backgroundColor = [UIColor clearColor];
    _imageView_default.hidden = NO;
    [self.view addSubview:_imageView_default];
    if(self.user_id == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] intValue])
    {
        _imageView_default.image = [UIImage imageNamed:@"default_我的去过"];
    }
    else
    {
        _imageView_default.image = [UIImage imageNamed:@"default_他的去过"];
    }
}



#pragma mark -
#pragma mark --- initFollowData & initFansData
-(void)initHasGoneData
{
    if(_dic_hasGone && _dic_hasGone.count > 0)
    {
        [_tableView_hasGone reloadData];
    }
    else
    {
        [self loadHasGoneData];
    }
}
-(void)loadHasGoneData
{
    if(self.user_id && [[NSString stringWithFormat:@"%d",self.user_id] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"]])
    {
        [self getHasGoneDataFromCache];
    }
    
    if(!([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable))
    {
        [self getHasGoneDataFromServer];
    }
}
-(void)getHasGoneDataFromCache
{
    NSString *user_id_ = [NSString stringWithFormat:@"%d",self.user_id];
    [HasGoneData getCachedHasGoneDataWithUserid:user_id_
                                  success:^(NSDictionary *dic,NSArray *array_countryname_cn,NSArray *array_countryname_en){
                                      NSLog(@" getWantGoData 成功 : %@",dic);
                                      
                                      if(_imageView_failed)
                                      {
                                          _imageView_failed.hidden = YES;
                                      }
                                      if(_imageView_default)
                                      {
                                          _imageView_default.hidden = YES;
                                      }
                                      
                                      if(array_countryname_cn)
                                      {
                                          if(_array_country)
                                          {
                                              [_array_country removeAllObjects];
                                              [_array_country release];
                                          }
                                          _array_country = [[NSMutableArray alloc] initWithArray:array_countryname_cn copyItems:YES];
                                      }
                                      if(array_countryname_en)
                                      {
                                          if(_array_country_en)
                                          {
                                              [_array_country_en removeAllObjects];
                                              [_array_country_en release];
                                          }
                                          _array_country_en = [[NSMutableArray alloc] initWithArray:array_countryname_en copyItems:YES];
                                      }
                                      NSLog(@" _array_country_en : %@",_array_country_en);
                                      
                                      
                                      
                                      for(NSString *str in array_countryname_cn)
                                      {
                                          NSObject *obj = [dic objectForKey:str];
                                          [_dic_hasGone setObject:obj forKey:str];
                                      }
                                      
                                      if(_array_country && _array_country.count > 0)
                                      {
                                          [_tableView_hasGone reloadData];
                                      }
                                      else if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
                                      {
                                          [self.view hideToastActivity];
                                          
                                          if(_imageView_default)
                                          {
                                              _imageView_default.hidden = YES;
                                          }
                                          
                                          [self performSelector:@selector(initFailedView) withObject:nil afterDelay:0.2];
                                      }
                                  }
                                   failed:^{
                                       NSLog(@" getWantGoData 失败");
                                       
                                       
                                       if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
                                       {
                                           [self.view hideToastActivity];
                                           
                                           if(_imageView_default)
                                           {
                                               _imageView_default.hidden = YES;
                                           }
                                           
                                           [self performSelector:@selector(initFailedView) withObject:nil afterDelay:0.2];
                                       }
                                       
                                   }];
}
-(void)getHasGoneDataFromServer
{
    [self.view makeToastActivity];
    
    NSString *user_id_ = [NSString stringWithFormat:@"%d",self.user_id];
    [HasGoneData getHasGoneDataWithUserid:user_id_
                                success:^(NSDictionary *dic,NSArray *array_countryname_cn,NSArray *array_countryname_en){
                                    NSLog(@" getHasGoneData 成功 : %@",dic);
                                    
                                    [self.view hideToastActivity];
                                    if(array_countryname_cn)
                                    {
                                        if(_array_country)
                                        {
                                            [_array_country removeAllObjects];
                                            [_array_country release];
                                        }
                                        _array_country = [[NSMutableArray alloc] initWithArray:array_countryname_cn copyItems:YES];
                                    }
                                    if(array_countryname_en)
                                    {
                                        if(_array_country_en)
                                        {
                                            [_array_country_en removeAllObjects];
                                            [_array_country_en release];
                                        }
                                        _array_country_en = [[NSMutableArray alloc] initWithArray:array_countryname_en copyItems:YES];
                                    }
                                    NSLog(@" _array_country_en : %@",_array_country_en);
                                    
                                    
                                    
                                    
                                    for(NSString *str in array_countryname_cn)
                                    {
                                        NSObject *obj = [dic objectForKey:str];
                                        [_dic_hasGone setObject:obj forKey:str];
                                    }
                                    
                                    
                                    
                                    if(!_array_country || _array_country.count == 0)
                                    {
                                        if(_imageView_failed)
                                        {
                                            _imageView_failed.hidden = YES;
                                        }
                                        [self performSelector:@selector(initDefaultView) withObject:nil afterDelay:0.3];
                                    }
                                    else
                                    {
                                        if(_imageView_failed)
                                        {
                                            _imageView_failed.hidden = YES;
                                        }
                                        [_tableView_hasGone reloadData];
                                    }
                                    
                                }
                                 failed:^{
                                     NSLog(@" getWantGoData 失败");
                                     [self.view hideToastActivity];
                                 }];
}


#pragma mark -
#pragma mark --- 无网络时的错误提示
-(void)initFailedView
{
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
    return [_array_country count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    HasGone *hasGone_ = [_dic_hasGone objectForKey:[_array_country objectAtIndex:section]];
    NSInteger number = [hasGone_.array_cityInfo count];
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
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 68/2.;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger height = 68/2.;
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    backView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(10, height-0.5, 300, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:217/255. green:217/255. blue:217/255. alpha:1];
    [backView addSubview:line];
    [line release];
    
    
    NSString *str_countryName = [_array_country objectAtIndex:section];
    float width = [self countContentLabelHeightByString:str_countryName andHeight:14 andFontSize:15];
    UILabel *titleLabel_cn = [[UILabel alloc] initWithFrame:CGRectMake(10, height-14-10, width, 14)];
    titleLabel_cn.backgroundColor = [UIColor clearColor];
    titleLabel_cn.text = str_countryName;
    titleLabel_cn.font = [UIFont systemFontOfSize:15];
    titleLabel_cn.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
    [backView addSubview:titleLabel_cn];
    
    
    float positionX = titleLabel_cn.frame.origin.x+titleLabel_cn.frame.size.width+interval_countrynamecn_countrynameen;
    NSString *str_countryName_en = [_array_country_en objectAtIndex:section];
    width = [self countContentLabelHeightByString:str_countryName_en andHeight:14 andFontSize:13];
    if(width + positionX >= 300)
    {
        width = 300 - positionX;
    }
    UILabel *titleLabel_en = [[UILabel alloc] initWithFrame:CGRectMake(positionX, height-14-10, width, 14)];
    titleLabel_en.backgroundColor = [UIColor clearColor];
    titleLabel_en.text = str_countryName_en;
    titleLabel_en.font = [UIFont systemFontOfSize:13];
    titleLabel_en.textColor = [UIColor colorWithRed:158/255. green:163/255. blue:171/255. alpha:1];
    [backView addSubview:titleLabel_en];
    [titleLabel_en release];
    [titleLabel_cn release];
    
    
    HasGone *hasGone_ = [_dic_hasGone objectForKey:[_array_country objectAtIndex:section]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(320-48/2-18/2, (height-48/2)/2, 48/2, 48/2);
    button.backgroundColor = [UIColor clearColor];
    [button setBackgroundImage:[UIImage imageNamed:@"press_icon_detail"] forState:UIControlStateNormal];
    [backView addSubview:button];
    button.tag = [hasGone_.country_idstring intValue];
    [button addTarget:self action:@selector(showCountryInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    return [backView autorelease];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HasGone *hasGone_ = [_dic_hasGone objectForKey:[_array_country objectAtIndex:indexPath.section]];
    NSInteger number = [hasGone_.array_cityInfo count];
    if(number%2 == 0)
    {
        number = number/2;
    }
    else
    {
        number = number/2 + 1;
    }
    
    if(number == indexPath.row + 1)
    {
        return (20+224+76+20)/2;
    }
    
    return (20+224+76)/2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WantGo_hasGoneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WantGoCell"];
    if(cell == nil)
    {
        cell = [[[WantGo_hasGoneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WantGoCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    HasGone *hasGone_ = [_dic_hasGone objectForKey:[_array_country objectAtIndex:indexPath.section]];
    [cell initDataWithWantGoData:hasGone_.array_cityInfo atIndex:indexPath.row type:@"hasgone"];
    
    return cell;
}



#pragma mark -
#pragma mark --- WantGo_hasGoneCell - Delegate
-(void)selectedLeftImageViewWithCityId:(NSInteger)cityid andCityName:(NSString *)cityname
{
    GoneAndWantGoCitiesViewController *vc = [[GoneAndWantGoCitiesViewController alloc] init];
    vc.user_id = self.user_id;
    vc.type = @"hasgone";
    vc.city_id = cityid;
    vc.titleName = cityname;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}
-(void)selectedRightImageViewWithCityId:(NSInteger)cityid andCityName:(NSString *)cityname
{
    GoneAndWantGoCitiesViewController *vc = [[GoneAndWantGoCitiesViewController alloc] init];
    vc.user_id = self.user_id;
    vc.type = @"hasgone";
    vc.city_id = cityid;
    vc.titleName = cityname;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
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
#pragma mark --- 显示国家详情
-(void)showCountryInfo:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger countryId = button.tag;
    
    CountryViewController *countryVC = [[CountryViewController alloc]init];
    countryVC.type = 1;
    countryVC.key = [NSString stringWithFormat:@"%d",countryId];
    [self.navigationController pushViewController:countryVC animated:YES];
    [countryVC release];
}



#pragma mark -
#pragma mark --- clickBackButton
-(void)clickBackButton:(id)sender
{
    NSString *user_id_ = [NSString stringWithFormat:@"%d",self.user_id];
    [HasGoneData cancleGetHasGoneDataWithUserid:user_id_];
    
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
