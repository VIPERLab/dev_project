//
//  GuideDownloadingViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-21.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GuideDownloadingViewController.h"
#import "QYGuideData.h"
#import "QYGuide.h"
#import "ChangeTableviewContentInset.h"
#import "MobClick.h"




#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (6+20) : 6)
#define     height_titlelabel           (ios7 ? (30) : 34)
#define     positionY_backbutton        (ios7 ? (3+20) : 3)
#define     positionY_tableView         (ios7 ? (44+20) : 44)




@interface GuideDownloadingViewController ()

@end




@implementation GuideDownloadingViewController
@synthesize array_guideDownloading = _array_guideDownloading;
//@synthesize array_append = _array_append;

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
    QY_VIEW_RELEASE(_tableView_downloadingVC);
    
    QY_MUTABLERECEPTACLE_RELEASE(_array_guideDownloading);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- view - Appear & Disappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [MobClick beginLogPageView:@"正在下载锦囊页"];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guide_download_finished:) name:@"downloadfinished" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guide_download_failed:) name:@"downloadfailed" object:nil];
    
    [_tableView_downloadingVC reloadData];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [MobClick endLogPageView:@"正在下载锦囊页"];
}


#pragma mark -
#pragma mark --- 构建View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initView];
}
-(void)initView
{
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self initRootView];
    [self setNavigationBar];
    [self initTableView];
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
    if(!_headView)
    {
        _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    }
    _headView.backgroundColor = [UIColor clearColor];
    //_headView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home_head@2x" ofType:@"png"]];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    if(!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, positionY_titlelabel, 160, height_titlelabel)];
    }
    //_titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"正在下载";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    
    if(!_backButton)
    {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
}
-(void)initTableView
{
    if(ios7)
    {
        if(!_tableView_downloadingVC)
        {
            _tableView_downloadingVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStylePlain];
        }
    }
    else
    {
        if(!_tableView_downloadingVC)
        {
            _tableView_downloadingVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, ([[UIScreen mainScreen] bounds].size.height-20)) style:UITableViewStylePlain];
        }
    }
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
//    headerView.backgroundColor = [UIColor clearColor];
//    _tableView_downloadingVC.tableHeaderView = headerView;
//    [headerView release];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
    footView.backgroundColor = [UIColor clearColor];
    _tableView_downloadingVC.tableFooterView = footView;
    [footView release];
    _tableView_downloadingVC.delegate = self;
    _tableView_downloadingVC.dataSource = self;
    _tableView_downloadingVC.backgroundColor = [UIColor clearColor];
    _tableView_downloadingVC.separatorColor = [UIColor clearColor];
    
    [ChangeTableviewContentInset changeWithTableView:_tableView_downloadingVC];
    [self.view addSubview:_tableView_downloadingVC];
    [self.view bringSubviewToFront:_headView];
    
    
    [_tableView_downloadingVC reloadData];
}


#pragma mark -
#pragma mark --- UITableView - DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.array_guideDownloading count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240/2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GuideViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideView_Cell"];
    if(cell == nil)
    {
        cell = [[[GuideViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuideView_Cell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;
    cell.flag_isInDownloadigVC = 1;
    [cell resetCell];
    [self initGuideDetailCell:cell andIndexPath:indexPath];
    
    return cell;
}
-(void)initGuideDetailCell:(GuideViewCell*)cell andIndexPath:(NSIndexPath *)indexPath
{
    cell.position_section = indexPath.section;
    cell.position_row = indexPath.row;
    [cell initCellWithArray:self.array_guideDownloading atPosition:indexPath.row];
}



#pragma mark -
#pragma mark --- GuideViewCell - delegate
-(void)guideViewCellCancleDownload:(GuideViewCell *)cell
{
    [self deleteGuideInDownloadingPlistWithGuideName:cell.guide.guideName];
    
    
    [FilePath removeGuideToDownloadPathWithGuideName:cell.guide.guideName];
    
    NSArray *array_allDownload = [QYGuideData getAllDownloadGuide];
    for(QYGuide *guide in array_allDownload)
    {
        if([guide.guideName isEqualToString:cell.guide.guideName])
        {
            BOOL flag = 0;
            for(QYGuide *guide_NeedToBeUpdated in [[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated])
            {
                if([guide.guideName isEqualToString:guide_NeedToBeUpdated.guideName])
                {
                    flag = 1;
                    break;
                }
            }
            if(flag == 0)
            {
                [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] addObject:guide];
            }
            
            break;
        }
    }
    
    [self.array_guideDownloading removeObject:cell.guide];
    [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] removeObject:cell.guide];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hideUpdateButton_updateAllGuide"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    if(self.array_guideDownloading.count > 0)
    {
        [self initTableView];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"freshDownloadAndDownloadingData" object:nil userInfo:nil];
        [self clickBackButton:nil];
    }
}
-(void)deleteGuideInDownloadingPlistWithGuideName:(NSString *)guideName
{
    if(!guideName)
    {
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloading.plist",[pathURL path]];
    BOOL ui;
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&ui])
    {
        NSData *data = [NSData dataWithContentsOfFile:plistPath];
        if(data)
        {
            NSArray *array_tmp = [[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:array_tmp];
            for(QYGuide *guide in array)
            {
                if([guideName isEqualToString:guide.guideName])
                {
                    NSLog(@" 删除原来已存在的 :%@",guideName);
                    [array removeObject:guide];
                    break;
                }
            }
            NSData *data_ = [NSKeyedArchiver archivedDataWithRootObject:array];
            if(data_)
            {
                [data_ writeToFile:plistPath atomically:NO];
            }
            
            [array removeAllObjects];
            [array release];
            [array_tmp release];
            
        }
        
    }
}



#pragma mark -
#pragma mark --- guide_download_finished & guide_download_failed
-(void)guide_download_finished:(NSNotification *)notifition
{
    [self.array_guideDownloading removeAllObjects];
    NSArray *array_tmp = [[QYGuideData sharedQYGuideData] array_guideIsDownloading];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(QYGuide *guide in array_tmp)
    {
        if(guide.guide_state != GuideRead_State)
        {
            [self.array_guideDownloading addObject:guide];
            [array addObject:guide];
        }
    }
    [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] removeAllObjects];
    [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] addObjectsFromArray:array];
    [array release];
    
    for(QYGuide *guide in self.array_guideDownloading)
    {
        if(guide && guide.guide_state == GuideRead_State)
        {
            [self.array_guideDownloading removeObject:guide];
            break;
        }
    }
    
    
    
    if(self.array_guideDownloading.count > 0)
    {
        [self initTableView];
    }
    else
    {
        [self clickBackButton:nil];
    }
    
}
-(void)guide_download_failed:(NSNotification *)notifition
{
    NSDictionary *userinfo = [notifition userInfo];
    
    QYGuide *guide = [QYGuideData getGuideByName:[userinfo objectForKey:@"guideName"]];
    [self.array_guideDownloading removeObject:guide];
    
    
    if(guide.download_type && [guide.download_type isEqualToString:@"update"])
    {
        guide.guide_state = GuideRead_State;
    }
    else
    {
        guide.guide_state = GuideDownloadFailed_State;
        
        NSLog(@"guideName:%@",guide.guideName);
        NSLog(@"guide    :%@",guide);
        NSLog(@" -------------------------------------");
    }
    
    
    
    if(self.array_guideDownloading.count > 0)
    {
        [self initTableView];
    }
    else
    {
        [self clickBackButton:nil];
    }
}



#pragma mark -
#pragma mark --- startDownload
-(void)startDownload
{
    for(int i = 0; i < self.array_guideDownloading.count; i++)
    {
        QYGuide *guide_ = [self.array_guideDownloading objectAtIndex:i];
        if(guide_.guide_state == GuideWating_State || guide_.guide_state == GuideDownloading_State)
        {
            continue;
        }
        
        GuideViewCell *cell = (GuideViewCell *)[_tableView_downloadingVC cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell button_selected:nil];
    }
}


#pragma mark -
#pragma mark --- clickBackButton
-(void)clickBackButton:(id)sender
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
