//
//  DownloadViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "DownloadViewController.h"
#import "QYGuideData.h"
#import "QYGuide.h"
#import "GuideDetailViewController.h"
#import "FilePath.h"
#import "CatalogViewController.h"
#import "ReadViewController.h"
#import "GuideMenuData.h"
#import "GuideMenu.h"
#import "GuideDownloadingViewController.h"
#import "DownloadingCell.h"
#import "Reachability.h"
#import "MobClick.h"
#import "Toast+UIView.h"
#import "FilePath.h"
#import "ShowDownloadMask.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "CityLoginViewController.h"
#import "ChangeTableviewContentInset.h"
#import "BookMarkData.h"
#import "FileDamaged.h"
#import "BookMarkViewController.h"
#import "FileDecompression.h"




#define     positionY_tableView         (ios7 ? (44+20) : 44)
#define     height_downloadingView      68/2
#define     title_updateGuide           @"一键更新%d本锦囊"
#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (4+20) : 4)
#define     height_titleLabel           (ios7 ? 30 : 34)
#define     positionY_backbutton        (ios7 ? (2+20) : 2)
#define     positionY_button_bookmark   (ios7 ? 22 : 2)




@interface DownloadViewController ()

@end




@implementation DownloadViewController
@synthesize currentVC = _currentVC;
@synthesize showNavigationBar;

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
    QY_VIEW_RELEASE(_tableView_downloadVC);
    QY_VIEW_RELEASE(_imageView_default);
    QY_VIEW_RELEASE(_backGroundView_update);
    
    QY_SAFE_RELEASE(_currentVC);
    QY_SAFE_RELEASE(_guideDownloadingVC);
    QY_SAFE_RELEASE(_guide_needUpdeted);
    
    QY_MUTABLERECEPTACLE_RELEASE(_array_download);
    QY_MUTABLERECEPTACLE_RELEASE(_array_downloading);
    QY_MUTABLERECEPTACLE_RELEASE(_array_needToBeUpdated);
    QY_MUTABLERECEPTACLE_RELEASE(_array_guideName_needUpdate);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- 获取上次退出时还正在下载的锦囊
-(NSArray *)getDownloadingGuideWhenQuitLastTime
{
    NSMutableArray *array_tmp = [[NSMutableArray alloc]init];
    NSArray *guideName_array = [[QYGuideData getDownloadingGuideWhenQuit] retain];
    if(guideName_array && guideName_array.count > 0 )
    {
        for(NSString *guideName in guideName_array)
        {
            QYGuide *guide = [QYGuideData getGuideByName:guideName];
            if(guide)
            {
                [array_tmp addObject:guide];
            }
        }
    }
    [guideName_array release];
    return [array_tmp autorelease];
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
        
        
        newFrame = _tableView_downloadVC.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableView_downloadVC.frame = newFrame;
        
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        newFrame = _tableView_downloadVC.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableView_downloadVC.frame = newFrame;
        
    }
}







#pragma mark -
#pragma mark --- 全部页面是否已成功下载所有的锦囊(getall)
-(void)getall_Success
{
    _flag_new = YES;
    
    [self freshDownloadAndDownloadingData];
}


#pragma mark -
#pragma mark --- view - Appear & Disappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guide_download_finished:) name:@"downloadfinished" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guide_download_failed:) name:@"downloadfailed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshDownloadAndDownloadingData) name:@"freshDownloadAndDownloadingData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Failed) name:@"logininfailed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getall_Success) name:@"allnew" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDamaged:) name:@"FileDamaged" object:nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"allnew" object:nil userInfo:nil];
    
    
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"hotdot_phone"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:YES];
    }
    
    
    
    
    
    if([[QYGuideData sharedQYGuideData] flag_getAllNew])
    {
        _flag_new = YES;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self freshDownloadAndDownloadingData];
}
-(void)didShow
{
    _flag_show = 1;
    if(_array_download && _array_download.count > 0)
    {
        [ShowDownloadMask showMask];
    }
    
    [self setTableHeaderViewAndFooterView];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _flag_show = 0;
}
-(void)freshDownloadAndDownloadingData
{
    [self getDownloadingGuide];
    [self getAllDownloadGuide];
    
    if((_array_downloading && _array_downloading.count > 0) || (_array_download && _array_download.count > 0))
    {
        [self initTableView];
    }
    
    //获取需要更新的锦囊:
    [self getGuideNeedToBeUpdated];
    if(_array_needToBeUpdated.count == 0)
    {
        [self clickHideUpdateButton];
    }
    else
    {
        [_button_update setTitle:[NSString stringWithFormat:title_updateGuide,_array_needToBeUpdated.count] forState:UIControlStateNormal];
    }
}
-(void)getDownloadingGuide
{
    if(!_array_downloading)
    {
        _array_downloading = [[NSMutableArray alloc] init];
    }
    [_array_downloading removeAllObjects];
    [_array_downloading addObjectsFromArray:[QYGuideData getDownloadingGuide]];
    
}
-(void)getGuideNeedToBeUpdated
{
    if(!_array_needToBeUpdated)
    {
        _array_needToBeUpdated = [[NSMutableArray alloc] init];
    }
    [_array_needToBeUpdated removeAllObjects];
    [_array_needToBeUpdated addObjectsFromArray:[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated]];
    
    if(_array_needToBeUpdated.count > 0 && ![[NSUserDefaults standardUserDefaults] objectForKey:@"hideUpdateButton_updateAllGuide"])
    {
        [self initNeedToBeUpdatedButton];
    }
    else
    {
        if(_backGroundView_update)
        {
            [_backGroundView_update removeFromSuperview];
        }
    }
}
-(void)initNeedToBeUpdatedButton
{
    if(!_backGroundView_update)
    {
        _backGroundView_update = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-72/2, 320, 72/2)];
    }
    if(!ios7)
    {
        _backGroundView_update.frame = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height-20)-72/2, 320, 72/2);
    }
    _backGroundView_update.alpha = 1;
    _backGroundView_update.backgroundColor = [UIColor clearColor];
    
    if(!_button_update)
    {
        _button_update = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _button_update.backgroundColor = [UIColor clearColor];
    _button_update.frame = CGRectMake (0, 0, 568/2, 72/2);
    [_button_update setBackgroundImage:[UIImage imageNamed:@"btn_update"] forState:UIControlStateNormal];
    [_button_update addTarget:self action:@selector(clickUpdateAllGuideButton) forControlEvents:UIControlEventTouchUpInside];
    _button_update.titleLabel.textColor = [UIColor whiteColor];
    _button_update.titleLabel.font = [UIFont systemFontOfSize:16];
    [_button_update setTitle:[NSString stringWithFormat:title_updateGuide,_array_needToBeUpdated.count] forState:UIControlStateNormal];
    [_backGroundView_update addSubview:_button_update];
    
    if(!_button_close)
    {
        _button_close = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _button_close.backgroundColor = [UIColor clearColor];
    _button_close.frame = CGRectMake(_button_update.frame.origin.x+_button_update.frame.size.width, 0, 72/2, 72/2);
    [_button_close setBackgroundImage:[UIImage imageNamed:@"btn_updat_close"] forState:UIControlStateNormal];
    [_button_close addTarget:self action:@selector(clickHideUpdateButton) forControlEvents:UIControlEventTouchUpInside];
    [_backGroundView_update addSubview:_button_close];
    
    
    [self.view addSubview:_backGroundView_update];
}



#pragma mark -
#pragma mark --- getAllDownloadGuide
-(void)getAllDownloadGuide
{
    if(!_array_download)
    {
        _array_download = [[NSMutableArray alloc] init];
    }
    [_array_download removeAllObjects];
    
    NSArray *array = [[QYGuideData getAllDownloadGuide] retain];
    if(array && array.count > 0)
    {
        [_array_download addObjectsFromArray:array];
        if(_array_download.count > 0)
        {
            [self sortGuide];
        }
    }
    else
    {
        [self initDefaultImageView];
    }
    
    [array release];
}
-(void)sortGuide  //按下载时间对锦囊进行排序:
{
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloadtime.plist",[pathURL path]];
    NSMutableDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
    
    
    
    
    
    NSArray *array_tmp = [dic allValues];
    NSMutableArray *my_array = [[NSMutableArray alloc] init];
    for(NSString *str in array_tmp)
    {
        if(str.length != [@"1397113698" length])
        {
            [my_array addObject:str];
        }
    }
    
    
    
    NSArray *sortedArray = [my_array sortedArrayUsingComparator: ^(id obj1, id obj2)
                            {
                                if ([obj1 longLongValue] >= [obj2 longLongValue])
                                {
                                    return (NSComparisonResult)NSOrderedAscending;
                                }
                                if ([obj1 longLongValue] < [obj2 longLongValue])
                                {
                                    return (NSComparisonResult)NSOrderedDescending;
                                }
                                return (NSComparisonResult)NSOrderedSame;
                            }];
    
    
    
    NSArray *nameKeys = [dic allKeys];
    NSMutableArray *array_guideName = [[NSMutableArray alloc] init];
    for(NSString *downloadTime in sortedArray)
    {
        for(NSString *str_guideName in nameKeys)
        {
            if([dic objectForKey:str_guideName] && [[dic objectForKey:str_guideName] isEqualToString:downloadTime])
            {
                [array_guideName addObject:str_guideName];
                break;
            }
        }
    }
    
    
    
    if(array_guideName && array_guideName.count > 0)
    {
        NSMutableArray *arr_ = [[NSMutableArray alloc] initWithArray:_array_download];
        [_array_download removeAllObjects];
        for(NSString *guideName in array_guideName)
        {
            for(QYGuide *guide in arr_)
            {
                if([guideName isEqualToString:guide.guideName])
                {
                    [_array_download addObject:guide];
                    break;
                }
            }
        }
        
        [arr_ removeAllObjects];
        [arr_ release];
    }
    [array_guideName removeAllObjects];
    [array_guideName release];
    
    
    
    
    //如果file目录下没有则删除本本锦囊:
    NSArray *array_guideInFile = [QYGuideData getAllDownloadGuide];
    NSMutableArray *array_needDelete = [[NSMutableArray alloc] init];
    for(QYGuide *guide in _array_download)
    {
        if(guide && guide.guideName)
        {
            BOOL flag = NO;
            for(QYGuide *guide_ in array_guideInFile)
            {
                if([guide_.guideName isEqualToString:guide.guideName])
                {
                    flag = YES;
                }
            }
            if(!flag)
            {
                [array_needDelete addObject:guide];
            }
        }
    }
    [_array_download removeObjectsInArray:array_needDelete];
    [array_needDelete removeAllObjects];
    [array_needDelete release];
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
    if(self.showNavigationBar)
    {
        [self setNavigationBar];
    }
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
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(184/2, positionY_titlelabel, 136, height_titleLabel)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"我的锦囊";
    //_titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    [_titleLabel release];
    
    
    
    //书签:
    UIButton *button_bookmark = [UIButton buttonWithType:UIButtonTypeCustom];
    button_bookmark.frame = CGRectMake(320 - 80/2, positionY_button_bookmark, 80/2, 80/2);
    [button_bookmark setBackgroundImage:[UIImage imageNamed:@"btn_bookmark"] forState:UIControlStateNormal];
    [button_bookmark addTarget:self action:@selector(clickBookmarkButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:button_bookmark];
    
    
    
    //返回按钮:
    UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
}
-(void)initTableView
{
    if(_imageView_default)
    {
        [_imageView_default removeFromSuperview];
    }
    
    if(!_tableView_downloadVC)
    {
        _tableView_downloadVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [self.view bounds].size.height) style:UITableViewStylePlain];
        _tableView_downloadVC.backgroundColor = [UIColor clearColor];
        _tableView_downloadVC.separatorColor = [UIColor clearColor];
        _tableView_downloadVC.delegate = self;
        _tableView_downloadVC.dataSource = self;
        if(self.showNavigationBar)
        {
            [ChangeTableviewContentInset changeTableView:_tableView_downloadVC withOffSet:0];
        }
        else
        {
            [ChangeTableviewContentInset changeTableView:_tableView_downloadVC withOffSet:height_offset_tableView];
        }
    }
    [self setTableHeaderViewAndFooterView];
    
    [self.view addSubview:_tableView_downloadVC];
    [self.view bringSubviewToFront:_headView];
    if(_backGroundView_update)
    {
        [self.view bringSubviewToFront:_backGroundView_update];
    }
    
    [_tableView_downloadVC reloadData];
}
-(void)initDefaultImageView
{
    if(_tableView_downloadVC)
    {
        [_tableView_downloadVC removeFromSuperview];
    }
    if(!_imageView_default)
    {
        _imageView_default = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height-150)/2., 320, 150)];
        _imageView_default.backgroundColor = [UIColor clearColor];
    }
    _imageView_default.image = [UIImage imageNamed:@"bg_empty_guide"];
    [self.view addSubview:_imageView_default];
}
-(void)setTableHeaderViewAndFooterView
{
    if(!_array_downloading)
    {
        _array_downloading = [[NSMutableArray alloc] init];
    }
    [_array_downloading removeAllObjects];
    [_array_downloading addObjectsFromArray:[QYGuideData getDownloadingGuide]];
    
    if(_array_downloading && _array_downloading.count > 0)
    {
        UIView *view_header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height_downloadingView)];
        view_header.backgroundColor = [UIColor clearColor];
        UILabel *label_downloading = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, height_downloadingView)];
        label_downloading.backgroundColor = [UIColor colorWithRed:214/255. green:214/255. blue:214/255. alpha:1];
        label_downloading.textAlignment = NSTextAlignmentCenter;
        label_downloading.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
        label_downloading.text = [NSString stringWithFormat:@"%d本锦囊正在下载     ",[_array_downloading count]];
        label_downloading.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        [view_header addSubview:label_downloading];
        [label_downloading release];
        UIImageView *imageView_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(280, (height_downloadingView-20)/2, 20, 20)];
        imageView_arrow.backgroundColor = [UIColor clearColor];
        imageView_arrow.image = [UIImage imageNamed:@"箭头"];
        [view_header addSubview:imageView_arrow];
        [imageView_arrow release];
        UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, height_downloadingView)];
        [control addTarget:self action:@selector(showDownloadingGuide) forControlEvents:UIControlEventTouchUpInside];
        [view_header addSubview:control];
        [control release];
        
        
        _tableView_downloadVC.tableHeaderView = view_header;
        [view_header release];
    }
    else
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
        headerView.backgroundColor = [UIColor whiteColor];
        _tableView_downloadVC.tableHeaderView = headerView;
        [headerView release];
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
    return [_array_download count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_array_download.count-1 == indexPath.row)
    {
        return 240/2 + 2;
    }
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
    [cell resetCell];
    [self initGuideDetailCell:cell andIndexPath:indexPath];
    
    return cell;
}
-(void)initGuideDetailCell:(GuideViewCell*)cell andIndexPath:(NSIndexPath *)indexPath
{
    cell.position_section = indexPath.section;
    cell.position_row = indexPath.row;
    [cell initCellWithArray:_array_download atPosition:indexPath.row];
}



#pragma mark -
#pragma mark --- showDownloadingGuide
-(void)showDownloadingGuide
{
    if(!_array_downloading)
    {
        _array_downloading = [[NSMutableArray alloc] init];
    }
    [_array_downloading removeAllObjects];
    [_array_downloading addObjectsFromArray:[QYGuideData getDownloadingGuide]];
    
    
    GuideDownloadingViewController *guideDownloadingVC_ = [[GuideDownloadingViewController alloc] init];
    guideDownloadingVC_.array_guideDownloading = _array_downloading;
    if(self.showNavigationBar)
    {
        [self.navigationController pushViewController:guideDownloadingVC_ animated:YES];
    }
    else
    {
        [self.currentVC.navigationController pushViewController:guideDownloadingVC_ animated:YES];
    }
    [guideDownloadingVC_ release];
}



#pragma mark -
#pragma mark --- UITableView - 删除cell操作
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        NSInteger position = indexPath.row;
        
        
        
        //*** 更改锦囊的状态:
        QYGuide *guide = [_array_download objectAtIndex:position];
        [self reSetGuide:guide.guideName withState:GuideNoamal_State];
        guide.progressValue = 0;
        
        
        //*** 更改锦囊的下载/更新状态:
        guide.download_type = nil;
        
        
        //*** 删除已记录的本本锦囊的阅读页数:
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,guide.guideName]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
        //*** 删除本本锦囊里已保存的书签:
        [[BookMarkData sharedBookMarkData] removeBookmarkByGuideName:guide.guideName];
        
        
        
        
        //*** 从记录锦囊的下载时间的plist文件中删除:
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
        NSString *plistPath = [NSString stringWithFormat:@"%@/guide_downloadtime.plist",[pathURL path]];
        if([fileManager fileExistsAtPath:plistPath])
        {
            NSMutableDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
            if(dic)
            {
                [dic removeObjectForKey:guide.guideName];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
                if(data)
                {
                    [data writeToFile:plistPath atomically:NO];
                }
            }
        }
        
        
        
        //*** 从保存本地已下载的锦囊的plist文件中删除:
        NSMutableArray *array_download_new = [[NSMutableArray alloc] init];
        if([CacheData getDownloadedGuideCache] && [CacheData getDownloadedGuideCache].count > 0)
        {
            [array_download_new addObjectsFromArray:[CacheData getDownloadedGuideCache]];
        }
        for(QYGuide *guide_download in array_download_new)
        {
            if([guide_download.guideName isEqualToString:guide.guideName])
            {
                [array_download_new removeObject:guide_download];
                break;
            }
        }
        [CacheData cacheDownloadedGuideData:array_download_new];
        [array_download_new release];
        
        
        
        //*** 从沙盒中删除:
        NSString *filePath = [[FilePath sharedFilePath] getZipFilePath];
        NSString *htmlPath = [NSString stringWithFormat:@"%@/%@_html",filePath,[[_array_download objectAtIndex:position] guideName]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:htmlPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:htmlPath error:nil];
        }
        NSString *zipPath = [NSString stringWithFormat:@"%@/%@.zip",filePath,[[_array_download objectAtIndex:position] guideName]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
        }
        
        
        
        //*** 从数组中删除: [ 先从数组中删除再刷新tableView ]
        [_array_download removeObjectAtIndex:position];
        GuideViewCell *cell = (GuideViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSString *guideName_delete = cell.label_guideName.text;
        
        
        
        
        //*** tableView删除cell:
        [_tableView_downloadVC deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:position inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        
        
        
        //*** 刷新tableView数据:
        if(_array_download.count == 0 && _array_downloading.count == 0)
        {
            [self performSelector:@selector(initDefaultImageView) withObject:nil afterDelay:0.2];
        }
        else
        {
            ////////[_tableView_downloadVC reloadData];
            
            [self performSelector:@selector(resetCellBelowThePosition:) withObject:indexPath afterDelay:0.2];
        }
        
        
        [self performSelector:@selector(updateNumberOfNeedUpdatedWithGuideName:) withObject:guideName_delete afterDelay:0];
    }
    else
    {
        return;
    }
}
-(void)reSetGuide:(NSString *)guide_name withState:(Guide_state_fuction)state
{
    NSArray *array = [QYGuideData getAllGuide];
    for(int i = 0; i < array.count; i++)
    {
        QYGuide *guide = [array objectAtIndex:i];
        if([guide.guideName isEqualToString:guide_name])
        {
            guide.guide_state = state;
            guide.progressValue = 0;
            break;
        }
    }
}
-(void)resetCellBelowThePosition:(NSIndexPath *)indexPath
{
    GuideViewCell *cell = (GuideViewCell *)[_tableView_downloadVC cellForRowAtIndexPath:indexPath];
    for(int i = cell.position_row-1 ; i < _array_download.count ; i++)
    {
        [_tableView_downloadVC reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}




#pragma mark -
#pragma mark --- 刷新需要更新的锦囊的个数:
-(void)updateNumberOfNeedUpdatedWithGuideName:(NSString *)guideName_delete
{
    //*** 更新‘一键更新N本锦囊’显示的个数:
    if(_button_update)
    {
        for(QYGuide *guide_needToBeUpdated in [[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated])
        {
            if(![guide_needToBeUpdated.guideName isEqualToString:guideName_delete])
            {
                continue;
            }
            
            [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] removeObject:guide_needToBeUpdated];
            [_array_needToBeUpdated removeAllObjects];
            [_array_needToBeUpdated addObjectsFromArray:[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated]];
            [_button_update setTitle:[NSString stringWithFormat:title_updateGuide,_array_needToBeUpdated.count] forState:UIControlStateNormal];
            if(_array_needToBeUpdated.count == 0)
            {
                [self clickHideUpdateButton];
            }
            break;
        }
    }
    
    
//    //*** 更新tabbar右上角显示的个数:
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    UINavigationController *navVC = (UINavigationController *)[[delegate window] rootViewController];
//    NSLog(@" topViewController : %@",(RootViewController *)navVC.topViewController);
//    if(navVC.topViewController && [(RootViewController *)navVC.topViewController updateCountButton])
//    {
//        [[(RootViewController *)navVC.topViewController updateCountButton] setTitle:[NSString stringWithFormat:@"%d",_array_needToBeUpdated.count] forState:UIControlStateNormal];
//        if(_array_needToBeUpdated.count == 0)
//        {
//            [(RootViewController *)navVC.topViewController updateCountButton].hidden = YES;
//        }
//    }
}



#pragma mark -
#pragma mark --- GuideViewCell - Delegate
-(void)guideViewCellCancleDownload:(GuideViewCell *)cell
{
    [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] removeObject:cell.guide];
}
-(void)guideViewCellSelectedDetail:(GuideViewCell *)cell
{
    NSLog(@"查看锦囊详情");
    
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    self.view.userInteractionEnabled = NO;
    self.view.superview.userInteractionEnabled = NO;
    [self performSelector:@selector(changeDelayFlag) withObject:nil afterDelay:1];
    
    
    
    
    
    GuideDetailViewController *guideDetailVC = [[GuideDetailViewController alloc] init];
    guideDetailVC.flag_new = _flag_new;
    guideDetailVC.where_from = @"guide";
    guideDetailVC.guideId = [[_array_download objectAtIndex:cell.position_row] guideId];
    guideDetailVC.guide = [_array_download objectAtIndex:cell.position_row];
    if(self.showNavigationBar)
    {
        [self.navigationController pushViewController:guideDetailVC animated:YES];
    }
    else
    {
        [self.currentVC.navigationController pushViewController:guideDetailVC animated:YES];
    }
    [guideDetailVC release];
}
-(void)guideViewCellSelectedReadGuide:(GuideViewCell *)cell
{
    NSLog(@"阅读锦囊");
    
    
    //记录cell的位置:
    _position_section_tapCell = cell.position_section;
    _position_row_tapCell = cell.position_row;
    
    
    NSArray *array_needToBeUpdated = [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] retain];
    BOOL flag = 0;
    for(QYGuide *guide in array_needToBeUpdated)
    {
        if([guide.guideName isEqualToString:cell.guide.guideName])
        {
            flag = 1; //需要进行更新的标志
            
            if(_guide_needUpdeted)
            {
                [_guide_needUpdeted release];
            }
            _guide_needUpdeted = [cell.guide retain];
            
            break;
        }
    }
    
    
    if(flag == 1) //提示需要进行更新
    {
        QYGuide *guide_needUpdated = [QYGuideData getGuideById:cell.guide.guideId];
        if(_guideName_needUpdate && _guideName_needUpdate.retainCount > 0)
        {
            [_guideName_needUpdate release];
        }
        _guideName_needUpdate = [guide_needUpdated.guideName retain];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"本锦囊有更新，更新内容："
                                                            message:guide_needUpdated.guideUpdate_log
                                                           delegate:self
                                                  cancelButtonTitle:@"忽略"
                                                  otherButtonTitles:@"立即更新", nil];
        alertView.tag = 789;
        [alertView show];
        [alertView release];
    }
    else
    {
        [self readGuide:cell];
    }
    
    [array_needToBeUpdated release];
}
-(void)readGuide:(GuideViewCell *)cell
{
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    self.view.userInteractionEnabled = NO;
    self.view.superview.userInteractionEnabled = NO;
    
    
    
    [self.view makeToastActivity];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //解压缩zip包:
        [FileDecompression decompressionFileWithFileName:[[_array_download objectAtIndex:cell.position_row] guideName] success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view hideToastActivity];
                self.view.superview.userInteractionEnabled = YES;
                self.view.userInteractionEnabled = YES;
                [self performSelector:@selector(changeDelayFlag) withObject:nil afterDelay:1];
                
                if(![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,[[_array_download objectAtIndex:cell.position_row] guideName]]])
                {
                    CatalogViewController *catelogVC = [[CatalogViewController alloc] init];
                    catelogVC.str_guideName = [[_array_download objectAtIndex:cell.position_row] guideName];
                    catelogVC.guide = [_array_download objectAtIndex:cell.position_row];
                    catelogVC.flag_isShowGuideCover = 1;
                    if(self.showNavigationBar)
                    {
                        [self.navigationController pushViewController:catelogVC animated:YES];
                    }
                    else
                    {
                        [self.currentVC.navigationController pushViewController:catelogVC animated:YES];
                    }
                    [catelogVC release];
                }
                else
                {
                    NSMutableArray *catlogArray = (NSMutableArray *)[GuideMenuData getMenuJsonWithGuideName:[[_array_download objectAtIndex:cell.position_row] guideName]];
                    
                    if(catlogArray && [catlogArray isKindOfClass:[NSArray class]])
                    {
                        ReadViewController *readVC = [[ReadViewController alloc] init];
                        readVC.str_guideName = [[_array_download objectAtIndex:cell.position_row] guideName];
                        readVC.guide = [_array_download objectAtIndex:cell.position_row];
                        readVC.array_catalog = catlogArray;
                        readVC.selectIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,readVC.str_guideName]] intValue];
                        readVC.flag_isShowGuideCover = 1;
                        if(self.showNavigationBar)
                        {
                            [self.navigationController pushViewController:readVC animated:YES];
                        }
                        else
                        {
                            [self.currentVC.navigationController pushViewController:readVC animated:YES];
                        }
                        [readVC release];
                    }
                    else
                    {
                        NSLog(@" 文件已损坏 ~~~");
                        [self.view hideToast];
                        [self.view makeToast:@"文件损坏，需要您重新下载。" duration:1.5 position:@"center" isShadow:NO];
                        [FileDamaged processDamagedFileWithFileName:[[_array_download objectAtIndex:cell.position_row] guideName]];
                    }
                }
                
            });
            
            
        } failed:^{
            
            self.view.superview.userInteractionEnabled = YES;
            self.view.userInteractionEnabled = YES;
        }];
    });
    
}
-(void)readNeedUpdatedGuide
{
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    self.view.userInteractionEnabled = NO;
    self.view.superview.userInteractionEnabled = NO;
    
    
    
    
    QYGuide *guide = [QYGuideData getGuideByName:_guideName_needUpdate];
    [self.view makeToastActivity];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //解压缩zip包:
        [FileDecompression decompressionFileWithFileName:[guide guideName] success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view hideToastActivity];
                self.view.superview.userInteractionEnabled = YES;
                self.view.userInteractionEnabled = YES;
                [self performSelector:@selector(changeDelayFlag) withObject:nil afterDelay:1];
                
                if(![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,_guideName_needUpdate]])
                {
                    CatalogViewController *catelogVC = [[CatalogViewController alloc] init];
                    catelogVC.str_guideName = _guideName_needUpdate;
                    catelogVC.guide = guide;
                    catelogVC.flag_isShowGuideCover = 1;
                    if(self.showNavigationBar)
                    {
                        [self.navigationController pushViewController:catelogVC animated:YES];
                    }
                    else
                    {
                        [self.currentVC.navigationController pushViewController:catelogVC animated:YES];
                    }
                    [catelogVC release];
                }
                else
                {
                    NSMutableArray *catlogArray = (NSMutableArray *)[GuideMenuData getMenuJsonWithGuideName:_guideName_needUpdate];
                    
                    if(catlogArray && [catlogArray isKindOfClass:[NSArray class]])
                    {
                        ReadViewController *readVC = [[ReadViewController alloc] init];
                        readVC.str_guideName = _guideName_needUpdate;
                        readVC.guide = guide;
                        readVC.array_catalog = catlogArray;
                        readVC.selectIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,readVC.str_guideName]] intValue];
                        readVC.flag_isShowGuideCover = 1;
                        if(self.showNavigationBar)
                        {
                            [self.navigationController pushViewController:readVC animated:YES];
                        }
                        else
                        {
                            [self.currentVC.navigationController pushViewController:readVC animated:YES];
                        }
                        [readVC release];
                    }
                    else
                    {
                        NSLog(@" 文件已损坏 ~~~ ");
                        [self.view hideToast];
                        [self.view makeToast:@"文件损坏，需要您重新下载。" duration:1.5 position:@"center" isShadow:NO];
                        [FileDamaged processDamagedFileWithFileName:_guideName_needUpdate];
                    }
                }
                
            });
            
            
        } failed:^{
            
            self.view.superview.userInteractionEnabled = YES;
            self.view.userInteractionEnabled = YES;
        }];
    });
    
}
-(void)updateCellAtIndepath:(NSIndexPath *)indexpath
{
    [_tableView_downloadVC reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)changeDelayFlag
{
    self.view.superview.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    _flag_delay = NO;
}



#pragma mark -
#pragma mark --- UIAlertView - Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [alertView cancelButtonIndex])
    {
        if(alertView.tag == 789)
        {
            NSLog(@"取消更新锦囊,继续阅读!");
            [self readNeedUpdatedGuide];
        }
        
        return;
    }
    
    else
    {
        if(alertView.tag == 789)
        {
            NSLog(@"更新本本锦囊");
            
            [self beginUpdateOneGuide];
        }
        else if(alertView.tag == 790)
        {
            NSLog(@"更新之前先登录");
            
            CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
            UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
            navigationController.navigationBarHidden = YES;
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:navigationController animated:YES completion:nil];
            [cityLoginVC release];
        }
    }
}



#pragma mark -
#pragma mark --- 登录成功
-(void)loginIn_Success
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_one"] && _guideName_needUpdate && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_one"] isEqualToString:_guideName_needUpdate])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_one"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSelector:@selector(beginUpdateOneGuide_now) withObject:nil afterDelay:1.2];
    }
    
    else if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_all"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_all"] isEqualToString:@"1"])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_all"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hideUpdateButton_updateAllGuide"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
        //隐藏一键更新按钮:
        [self hideUpdateButton];
        
        
        //隐藏红色的圆圈圈(显示的是需要更新的锦囊数):
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        UINavigationController *navVC = (UINavigationController *)[[delegate window] rootViewController];
//        if([(RootViewController *)navVC.topViewController updateCountButton])
//        {
//            [(RootViewController *)navVC.topViewController updateCountButton].hidden = YES;
//        }
        
        
        [self performSelector:@selector(beginUpdateAllGuide_now) withObject:nil afterDelay:1.2];
    }
}
-(void)loginIn_Failed
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_one"] && _guideName_needUpdate && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_one"] isEqualToString:_guideName_needUpdate])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_one"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    else if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_all"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_all"] isEqualToString:@"1"])
    {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_all"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}



#pragma mark -
#pragma mark --- 更新某一本锦囊
-(void)beginUpdateOneGuide
{
    //*** 网络不好:
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view makeToast:@"貌似网络有点不好，检查一下吧..." duration:1. position:@"center" isShadow:NO];
        
        [self loginIn_Failed];
        
        return;
    }
    
    
    
    //更新时不提示需要登录(小柳):
    [self beginUpdateOneGuide_now];
    
    //    //*** 未登录:
    //    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
    //    {
    //        [[NSUserDefaults standardUserDefaults] setObject:_guideName_needUpdate forKey:@"notlogininwhenupdate_one"];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //
    //
    //        UIAlertView *alertView = [[UIAlertView alloc]
    //                                  initWithTitle:Nil
    //                                  message:@"您登录之后才能更新锦囊"
    //                                  delegate:self
    //                                  cancelButtonTitle:@"取消"
    //                                  otherButtonTitles:@"立即登录",nil];
    //        alertView.tag = 790;
    //        alertView.delegate = self;
    //        [alertView show];
    //        [alertView release];
    //    }
    //    else
    //    {
    //        [self beginUpdateOneGuide_now];
    //    }
}
-(void)beginUpdateOneGuide_now
{
    //*** 首先更新tableview的cell:
    [self refreshOneCell];
    
    //*** 开始下载更新锦囊:
    [self reloadOneGuideNeedUpdated];
    
    //*** 更新'需要更新的锦囊按钮'个数:
    [self performSelector:@selector(updateNumberOfNeedUpdatedWithGuideName:) withObject:_guideName_needUpdate afterDelay:0];
}
-(void)refreshOneCell
{
    NSMutableArray *array_download_tmp = [[NSMutableArray alloc] init];
    [array_download_tmp addObjectsFromArray:_array_download];
    for(int i = 0; i < _array_needToBeUpdated.count; i++)
    {
        QYGuide *guide_needToBeUpdated = [_array_needToBeUpdated objectAtIndex:i];
        if(![guide_needToBeUpdated.guideName isEqualToString:_guideName_needUpdate])
        {
            continue;
        }
        QYGuide *guide_ = [QYGuideData getGuideById:guide_needToBeUpdated.guideId];
        NSLog(@" 这本需要更新的锦囊是:");
        NSLog(@" guide_.guideName   : %@",guide_.guideName);
        
        guide_.download_type = @"update"; //表示该本锦囊在更新
        
        
        
        if(!_array_guideName_needUpdate)
        {
            _array_guideName_needUpdate = [[NSMutableArray alloc] init];
        }
        [_array_guideName_needUpdate removeObject:guide_.guideName];
        [_array_guideName_needUpdate addObject:guide_.guideName];
        
        
        
        
        for(int j = 0; j < array_download_tmp.count; j++)
        {
            QYGuide *guide_download_tmp = [array_download_tmp objectAtIndex:j];
            if([guide_needToBeUpdated.guideName isEqualToString:guide_download_tmp.guideName])
            {
                [_array_download removeObject:guide_download_tmp];
                
                if(!_array_downloading)
                {
                    _array_downloading = [[NSMutableArray alloc] init];
                }
                [_array_downloading removeObject:guide_];
                [_array_downloading addObject:guide_];
                guide_.guide_state = GuideNoamal_State;
                
                
                [QYGuideData cacheDownloadingGuide:guide_];
                
                
                break;
            }
        }
        
        [_array_needToBeUpdated removeObject:guide_needToBeUpdated];
        
        NSLog(@"  refreshOneCell :");
        NSLog(@"  array_needToBeUpdated.count : %d",_array_needToBeUpdated.count);
        
        
        break;
    }
    [array_download_tmp release];
    
    
    [self setTableHeaderViewAndFooterView];
    [_tableView_downloadVC reloadData];
}
-(void)reloadOneGuideNeedUpdated
{
    //*** 首先将原先已下载的锦囊保存到另外一个目录下,以防更新失败后原先下载的锦囊也阅读不了。
    [FilePath moveDownloadedGuideToAnotherPathWithGuideName:_guideName_needUpdate];
    
    
    //*** 开始下载:
    [self performSelector:@selector(startUpdateGuide) withObject:nil afterDelay:0.01];
}
-(void)startUpdateGuide
{
    if(!_guideDownloadingVC)
    {
        _guideDownloadingVC = [[GuideDownloadingViewController alloc] init];
    }
    
    
    _guideDownloadingVC.array_guideDownloading = _array_downloading;
    [_guideDownloadingVC initView];
    [_guideDownloadingVC startDownload];
    
    
    
    
    //*** 更新button的文字:
    [_array_needToBeUpdated removeAllObjects];
    [_array_needToBeUpdated addObjectsFromArray:[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated]];
    
    
    if(_array_needToBeUpdated.count == 0)
    {
        [self clickHideUpdateButton];
    }
    else
    {
        [_button_update setTitle:[NSString stringWithFormat:title_updateGuide,_array_needToBeUpdated.count] forState:UIControlStateNormal];
    }
}



#pragma mark -
#pragma mark --- 点击'一键更新N本锦囊'按钮
-(void)clickUpdateAllGuideButton
{
    [self updateAllGuide];
}
-(void)clickHideUpdateButton
{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hideUpdateButton_updateAllGuide"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self hideUpdateButton];
}
-(void)hideUpdateButton
{
    if(_backGroundView_update)
    {
        [UIView animateWithDuration:0.2
                         animations:^{
                             _backGroundView_update.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             [_backGroundView_update removeFromSuperview];
                         }];
    }
}
-(void)updateAllGuide
{
    //*** 网络不好:
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view makeToast:@"貌似网络有点不好，检查一下吧..." duration:1 position:@"center" isShadow:NO];
        
        [self loginIn_Failed];
        
        return;
    }
    
    
    
    
    //更新时不提示需要登录(小柳):
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    UINavigationController *navVC = (UINavigationController *)[[delegate window] rootViewController];
//    if([(RootViewController *)navVC.topViewController updateCountButton])
//    {
//        [(RootViewController *)navVC.topViewController updateCountButton].hidden = YES;
//    }
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hideUpdateButton_updateAllGuide"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self hideUpdateButton];
    [self beginUpdateAllGuide_now];
    
    
    
//    //*** 未登录:
//    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notlogininwhenupdate_all"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        
//        UIAlertView *alertView = [[UIAlertView alloc]
//                                  initWithTitle:nil
//                                  message:@"您登录之后才能更新锦囊"
//                                  delegate:self
//                                  cancelButtonTitle:@"取消"
//                                  otherButtonTitles:@"立即登录",nil];
//        alertView.tag = 790;
//        alertView.delegate = self;
//        [alertView show];
//        [alertView release];
//    }
//    else
//    {
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        UINavigationController *navVC = (UINavigationController *)[[delegate window] rootViewController];
//        if([(RootViewController *)navVC.topViewController updateCountButton])
//        {
//            [(RootViewController *)navVC.topViewController updateCountButton].hidden = YES;
//        }
//        
//        
//        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hideUpdateButton_updateAllGuide"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        
//        [self hideUpdateButton];
//        
//        [self beginUpdateAllGuide_now];
//    }
}
-(void)beginUpdateAllGuide_now
{
    //*** 首先更新tableview的cell:
    [self refreshAllCell];
    
    //*** 开始下载更新锦囊:
    [self reloadAllGuideNeedUpdated];
}
-(void)refreshAllCell
{
    
    NSLog(@"  refreshAllCell :");
    NSLog(@"  array_needToBeUpdated.count : %d",_array_needToBeUpdated.count);
    
    if(!_array_guideName_needUpdate)
    {
        _array_guideName_needUpdate = [[NSMutableArray alloc] init];
    }
    [_array_guideName_needUpdate removeAllObjects];
    
    NSMutableArray *array_download_tmp = [[NSMutableArray alloc] init];
    [array_download_tmp addObjectsFromArray:_array_download];
    for(int i = 0; i < _array_needToBeUpdated.count; i++)
    {
        QYGuide *guide_needToBeUpdated = [_array_needToBeUpdated objectAtIndex:i];
        QYGuide *guide_ = [QYGuideData getGuideById:guide_needToBeUpdated.guideId];
        
        
        //*** 更新存放‘需要更新的锦囊’的数组:
        [QYGuideData deleteGuideNeedToBeUpdatedWithGuideName:guide_.guideName];
        
        
        
        [_array_guideName_needUpdate removeObject:guide_.guideName];
        [_array_guideName_needUpdate addObject:guide_.guideName];
        
        
        
        
        for(int j = 0; j < array_download_tmp.count; j++)
        {
            QYGuide *guide_download_tmp = [array_download_tmp objectAtIndex:j];
            NSLog(@" guide_download_tmp.guideName (1) : %@",guide_download_tmp.guideName);
            if([guide_needToBeUpdated.guideName isEqualToString:guide_download_tmp.guideName])
            {
                NSLog(@" guide_download_tmp.guideName (2) : %@",guide_download_tmp.guideName);
                [_array_download removeObject:guide_download_tmp];
                
                if(!_array_downloading)
                {
                    _array_downloading = [[NSMutableArray alloc] init];
                }
                [_array_downloading removeObject:guide_];
                [_array_downloading addObject:guide_];
                guide_.guide_state = GuideNoamal_State;
                
                
                [QYGuideData cacheDownloadingGuide:guide_];
                
                
                break;
            }
        }
        
    }
    [array_download_tmp release];
    
    
    [self setTableHeaderViewAndFooterView];
    [_tableView_downloadVC reloadData];
}

-(void)reloadAllGuideNeedUpdated
{
    //*** 首先将原先已下载的锦囊保存到另外一个目录下,以防更新失败后原先下载的锦囊也阅读不了。
    for(NSString *guidename in _array_guideName_needUpdate)
    {
        [FilePath moveDownloadedGuideToAnotherPathWithGuideName:guidename];
    }
    
    //*** 开始下载:
    [self performSelector:@selector(startUpdateAllGuide) withObject:nil afterDelay:0.01];
}
-(void)startUpdateAllGuide
{
    if(!_guideDownloadingVC)
    {
        _guideDownloadingVC = [[GuideDownloadingViewController alloc] init];
    }
    
    
    
    
    [_array_downloading removeAllObjects];
    //[_array_downloading addObjectsFromArray:[QYGuideData getDownloadingGuide]];
    for(QYGuide *guide in [QYGuideData getDownloadingGuide])
    {
        if(guide.guide_state != GuideDownloadFailed_State)
        {
            guide.download_type = @"update"; //表示该本锦囊在更新
            [_array_downloading addObject:guide];
        }
    }
    _guideDownloadingVC.array_guideDownloading = _array_downloading;
    [_guideDownloadingVC initView];
    [_guideDownloadingVC startDownload];
    
    
    
    
    //*** 更新button的文字:
    [_array_needToBeUpdated removeAllObjects];
    [_array_needToBeUpdated addObjectsFromArray:[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated]];
    
    
    if(_array_needToBeUpdated.count == 0)
    {
        [self clickHideUpdateButton];
    }
    else
    {
        [_button_update setTitle:[NSString stringWithFormat:title_updateGuide,_array_needToBeUpdated.count] forState:UIControlStateNormal];
    }
}




#pragma mark -
#pragma mark --- guide_download_finished & guide_download_failed
-(void)guide_download_finished:(NSNotification *)notifition
{
    NSLog(@" --- downloadVC -- guide_download_finished ");
    
    
    //*** 将下载成功的锦囊保存到本地的plist中:
    NSDictionary *userinfo = [notifition userInfo];
    NSMutableArray *array_download = [[NSMutableArray alloc] init];
    if([CacheData getDownloadedGuideCache] && [CacheData getDownloadedGuideCache].count > 0)
    {
        [array_download addObjectsFromArray:[CacheData getDownloadedGuideCache]];
    }
    for(QYGuide *guide_download in array_download)
    {
        if([guide_download.guideName isEqualToString:[userinfo objectForKey:@"guideName"]])
        {
            [array_download removeObject:guide_download];
            break;
        }
    }
    QYGuide *guide = [QYGuideData getGuideByName:[userinfo objectForKey:@"guideName"]];
    guide.download_type = nil;
    [array_download addObject:guide];
    [CacheData cacheDownloadedGuideData:array_download];
    [array_download release];
    
    
    //更新正在下载的锦囊数组:
    [QYGuideData deleteGuideIsDownloadingWithGuideName:[userinfo objectForKey:@"guideName"]];
    [self setTableHeaderViewAndFooterView];
    
    
    //*** 更新需要更新的锦囊的个数:
    [QYGuideData deleteGuideNeedToBeUpdatedWithGuideName:[userinfo objectForKey:@"guideName"]];
    
    
    //*** 刷新tableView:
    [self getAllDownloadGuide];
    [self initTableView];
    
    
    //显示遮罩:
    if(_array_download && _array_download.count > 0)
    {
        if(_flag_show == 1)
        {
            [ShowDownloadMask showMask];
        }
    }
}
-(void)guide_download_failed:(NSNotification *)notifition
{
    NSDictionary *userinfo = [notifition userInfo];
    
    if(userinfo && [userinfo objectForKey:@"names"])
    {
        [self processUpdateData:[userinfo objectForKey:@"names"]];
    }
    
    
    [self getAllDownloadGuide];
    [self getGuideNeedToBeUpdated];
    
    
    
    
    //更新失败后的逻辑,继续提示'一键更新N本锦囊'。
    //更新正在下载的锦囊数组:
    if(userinfo && [userinfo objectForKey:@"names"])
    {
        NSArray *array = [userinfo objectForKey:@"names"];
        NSLog(@"  names  : %@",array);
        for(NSString *guideName in array)
        {
            QYGuide *guide_ = [QYGuideData getGuideByName:guideName];
            if(![guide_.download_type isEqualToString:@"update"])
            {
                guide_.guide_state = GuideDownloadFailed_State;
                continue;
            }
            
            if(_array_downloading)
            {
                [_array_downloading removeObject:guide_];
            }
            if(guide_)
            {
                if(guide_.download_type && [guide_.download_type isEqualToString:@"update"])
                {
                    guide_.guide_state = GuideRead_State;
                }
                else
                {
                    guide_.guide_state = GuideDownloadFailed_State;
                }
                [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] removeObject:guide_];
            }
        }
        NSLog(@" array_guideIsDownloading.count : %d",[[QYGuideData sharedQYGuideData] array_guideIsDownloading].count);
        NSLog(@" array_downloading.count : %d",_array_downloading.count);
    }
    
    
    
    
    
    if([[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated].count > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"someGuideNeedToBeUpdated" object:nil userInfo:nil];
    }
    [self initTableView];
}


-(void)processUpdateData:(NSArray *)array
{
    //更新出错时恢复原来的数据:
    for(NSString *name in array)
    {
        if([FilePath isExitGuideWithGuideName:name]) //如果是进行更新的数据,则恢复的数据
        {
            QYGuide *guide = [QYGuideData getGuideByName:name];
            if(guide)
            {
                [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] addObject:guide];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"hideUpdateButton_updateAllGuide"];
                [[NSUserDefaults standardUserDefaults] synchronize];

            }
        }
        
        
        //将锦囊移动到沙盒中的file目录下(更新锦囊的情况):
        [self processUpdateDataWithFileName:name];
    }
}
-(void)processUpdateDataWithFileName:(NSString *)name
{
    [FilePath removeGuideToDownloadPathWithGuideName:name];
}



#pragma mark -
#pragma mark --- reload - TableView
-(void)reloadTableView
{
    [self freshDownloadAndDownloadingData];
}



#pragma mark -
#pragma mark --- 文件损坏
-(void)fileDamaged:(NSNotification *)notfification
{
    NSDictionary *info_dic = [notfification userInfo];
    if(info_dic && [info_dic objectForKey:@"guidename"])
    {
        NSLog(@"  downloadVC_损坏的是: %@",[info_dic objectForKey:@"guidename"]);
        [_tableView_downloadVC reloadData];
    }
}


#pragma mark -
#pragma mark --- 书签
-(void)clickBookmarkButton:(id)sender
{
    BookMarkViewController *bookMarkVC = [[BookMarkViewController alloc] init];
    [self.navigationController pushViewController:bookMarkVC animated:YES];
    [bookMarkVC release];
}



#pragma mark -
#pragma mark --- doBack
-(void)doBack
{
    if(_flag_delay)
    {
        return;
    }
    
    [self.view hideToast];
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
