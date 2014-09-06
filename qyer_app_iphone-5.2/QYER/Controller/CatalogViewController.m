//
//  CatalogViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "CatalogViewController.h"
#import "QYGuideCategory.h"
#import "FilePath.h"
#import "NSString+SBJSON.h"
#import "CatalogCell.h"
#import "ReadViewController.h"
#import "GuideMenuData.h"
#import "GuideMenu.h"
#import "MobClick.h"
#import "ShowGuideCover.h"
#import "BookMarkData.h"
#import "ChangeTableviewContentInset.h"




#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (6+20) : 6)
#define     height_titlelabel           (ios7 ? (30) : 34)
#define     positionY_backbutton        (ios7 ? (3+20) : 3)
#define     positionY_continuebutton    (ios7 ? (6+20) : 6)
#define     positionY_tableView         (ios7 ? (44+20) : 44)




@interface CatalogViewController ()

@end





@implementation CatalogViewController
@synthesize str_guideName = _str_guideName;
@synthesize guide;
@synthesize flag_isShowGuideCover;
@synthesize flag_fromReadVC;

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
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_tableview_CatalogVC);
    
    QY_SAFE_RELEASE(_title_navigation);
    QY_MUTABLERECEPTACLE_RELEASE(_array_catalog);
    QY_MUTABLERECEPTACLE_RELEASE(_array_bookmark);
    
    
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
        
        
        newFrame = _tableview_CatalogVC.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableview_CatalogVC.frame = newFrame;
        
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        newFrame = _tableview_CatalogVC.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableview_CatalogVC.frame = newFrame;
        
    }
    
}





#pragma mark -
#pragma mark --- WillAppear & DidAppear & DidDisappear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"hotdot_phone"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:YES];
    }
    
    
    
    if(self.flag_isShowGuideCover == 1)
    {
        [self showGuideCover];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!_array_catalog || _array_catalog.count == 0)
    {
        [self getMenuJson];
        [self initTableView];
    }
    if(!_array_bookmark || _array_bookmark.count == 0)
    {
        if(!_array_bookmark)
        {
            _array_bookmark = [[NSMutableArray alloc] init];
        }
        [_array_bookmark addObjectsFromArray:[[[BookMarkData sharedBookMarkData] getBookmarkList] objectForKey:self.str_guideName]];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
-(void)getMenuJson
{
    NSArray *array = [[GuideMenuData getMenuJsonWithGuideName:self.str_guideName] retain];
    if(!_array_catalog)
    {
        _array_catalog = [[NSMutableArray alloc] init];
    }
    [_array_catalog removeAllObjects];
    [_array_catalog addObjectsFromArray:array];
    
    [array release];
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
    
    [self initRootView];
    [self setNavigationBar];
}
-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
    //rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    //_headView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home_head@2x" ofType:@"png"]];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, positionY_titlelabel, 160, height_titlelabel)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = self.str_guideName;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
//    _titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//    _titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    
    
    if(self.flag_fromReadVC == 0)
    {
        _button_back = [UIButton buttonWithType:UIButtonTypeCustom];
        _button_back.backgroundColor = [UIColor clearColor];
        _button_back.frame = CGRectMake(0, positionY_backbutton, 40, 40);
        [_button_back setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
        [_button_back addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:_button_back];
    }
    else
    {
        _button_continue = [UIButton buttonWithType:UIButtonTypeCustom];
        _button_continue.frame = CGRectMake(4, positionY_continuebutton, 48, 33);
        _button_continue.backgroundColor = [UIColor clearColor];
        [_button_continue setBackgroundImage:[UIImage imageNamed:@"btn_catalog_continue"] forState:UIControlStateNormal];
        [_button_continue addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:_button_continue];
    }
    
}
-(void)initTableView
{
    if(!_tableview_CatalogVC)
    {
        _tableview_CatalogVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [self.view bounds].size.height) style:UITableViewStylePlain];
    }
    _tableview_CatalogVC.delegate = self;
    _tableview_CatalogVC.dataSource = self;
    _tableview_CatalogVC.backgroundColor = [UIColor clearColor];
    _tableview_CatalogVC.separatorColor = [UIColor clearColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
    headerView.backgroundColor = [UIColor clearColor];
    _tableview_CatalogVC.tableHeaderView = headerView;
    [headerView release];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
    footView.backgroundColor = [UIColor clearColor];
    _tableview_CatalogVC.tableFooterView = footView;
    [footView release];
    
    [ChangeTableviewContentInset changeWithTableView:_tableview_CatalogVC];
    [self.view addSubview:_tableview_CatalogVC];
    [self.view bringSubviewToFront:_headView];
}


#pragma mark -
#pragma mark --- UITableView - DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array_catalog count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GuideMenu *menu = [_array_catalog objectAtIndex:indexPath.row];
    if(indexPath.row+1 == _array_catalog.count)
    {
        return ([menu.str_titleHeight floatValue] + 2*positionY_label_catalogName) +2;
    }
    if(!ios7)
    {
        return [menu.str_titleHeight floatValue] + 2*positionY_label_catalogName -6;
    }
    return [menu.str_titleHeight floatValue] + 2*positionY_label_catalogName;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CatalogCell"];
    if(cell == nil)
    {
        cell = [[[CatalogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CatalogCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell initWithCatelogArray:_array_catalog andBookmarkArray:_array_bookmark atPosition:indexPath.row];
    
    
    if(self.flag_fromReadVC == 1)
    {
        if(indexPath.row == self.position)
        {
            cell.label_catalogName.textColor = [UIColor orangeColor];
            cell.label_pageNumber.textColor = [UIColor orangeColor];
        }
        else
        {
            cell.label_catalogName.textColor = [UIColor blackColor];
            cell.label_pageNumber.textColor = [UIColor blackColor];
        }
    }
    
    return cell;
}



#pragma mark -
#pragma mark --- UITableView - Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",indexPath.row] forKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,self.str_guideName]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(self.flag_fromReadVC == YES)
    {
        NSLog(@"  从阅读页push过来，此时要pop到阅读页 ");
        
        NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
        [dic setObject:[NSString stringWithFormat:@"%d",indexPath.row] forKey:@"row_select"];
        [dic setObject:self.str_guideName forKey:@"guideName"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fresh_readVC" object:nil userInfo:dic];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        ReadViewController *readVC = [[ReadViewController alloc] init];
        readVC.str_guideName = self.str_guideName;
        readVC.guide = self.guide;
        readVC.array_catalog = _array_catalog;
        readVC.selectIndex = indexPath.row;
        readVC.flag_firstLoad = YES;
        [self.navigationController pushViewController:readVC animated:YES];
        [readVC release];
    }
}



#pragma mark -
#pragma mark --- showGuideCover
-(void)showGuideCover
{
    [ShowGuideCover showGuideCoverWithGuideName:self.str_guideName];
}




#pragma mark -
#pragma mark --- clickBackButton
- (void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
