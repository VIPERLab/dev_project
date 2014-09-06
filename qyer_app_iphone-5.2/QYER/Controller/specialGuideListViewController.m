//
//  specialGuideListViewController.m
//  QyGuide
//
//  Created by an qing on 12-12-28.
//
//


#import "specialGuideListViewController.h"
#import "specialGuideDetailCell.h"
#import "Toast+UIView.h"
#import "QYGuideData.h"
#import "QYGuide.h"
#import "SpecialGuideDetailCell.h"
#import "GuideDetailViewController.h"
#import "CatalogViewController.h"
#import "ReadViewController.h"
#import "GuideMenuData.h"
#import "GuideMenu.h"
#import "Reachability.h"
#import "CityLoginViewController.h"
#import "ChangeTableviewContentInset.h"




#define     GuidecellHeight         234/2.

#define     height_headerview       (ios7 ? (44+20) : 44)
#define     positionY_titlelabel    (ios7 ? (4+20) : 6)
#define     positionY_backbutton    (ios7 ? (3+20) : 3)
#define     positionY_tableView     (ios7 ? (44+20) : 44)











@interface specialGuideListViewController ()
-(void)setRootView;
-(void)setNavigationBar;
-(void)setTableView;
-(float)countContentLabelHeightByString:(NSString*)content;
@end





@implementation specialGuideListViewController
@synthesize navigationTitle = _navigationTitle;
@synthesize content = _content;
@synthesize array_specialGuide = _array_specialGuide;
@synthesize fromPushFlag;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(didChangeStatusBarFrame:)
//                                                     name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
    QY_SAFE_RELEASE(_navigationTitle);
    QY_SAFE_RELEASE(_content);
    
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_titleDetailLabel);
    QY_VIEW_RELEASE(_contentLabel);
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_tableView_specialGuideListVC);
    
    QY_MUTABLERECEPTACLE_RELEASE(_array_specialGuide);
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- view - Appear & DisAppear
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Failed) name:@"logininfailed" object:nil];
    
    
    if(resetFlag == 0)
    {
        resetFlag = 1;
        
        [self resetCellData];
    }
    else
    {
        [_tableView_specialGuideListVC reloadData];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"logininsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"logininfailed" object:nil];
}


#pragma mark -
#pragma mark --- 构建VIEW
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    [self setRootView];
    [self setNavigationBar];
    //[self setTableView];
    [self performSelector:@selector(setTableView) withObject:nil afterDelay:0];
}
-(void)setRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home_head@2x" ofType:@"png"]];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, positionY_titlelabel, 160, 34)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"专题推荐";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    
    _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
}
-(void)setTableView
{
    if(ios7)
    {
        if(!_tableView_specialGuideListVC)
        {
            _tableView_specialGuideListVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
        }
        _tableView_specialGuideListVC.backgroundColor = [UIColor clearColor];
        _tableView_specialGuideListVC.separatorColor = [UIColor clearColor];
    }
    else
    {
        if(!_tableView_specialGuideListVC)
        {
            _tableView_specialGuideListVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, ([[UIScreen mainScreen] bounds].size.height-20))];
        }
        _tableView_specialGuideListVC.backgroundColor = [UIColor clearColor];
        _tableView_specialGuideListVC.separatorColor = [UIColor clearColor];
    }
    _tableView_specialGuideListVC.delegate = self;
    _tableView_specialGuideListVC.dataSource = self;
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
    headerView.backgroundColor = [UIColor clearColor];
    _tableView_specialGuideListVC.tableHeaderView = headerView;
    [headerView release];
    
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
    footView.backgroundColor = [UIColor clearColor];
    _tableView_specialGuideListVC.tableFooterView = footView;
    [footView release];
    
    
    [ChangeTableviewContentInset changeWithTableView:_tableView_specialGuideListVC];
    [self.view addSubview:_tableView_specialGuideListVC];
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
    return [_array_specialGuide count]+1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        float height = [self countContentLabelHeightByString:self.content];
        
        return SpecialGuideDetailCell_titleDetailLabel_positionY + SpecialGuideDetailCell_titleDetailLabel_height + SpecialGuideDetailCell_contentLabel_positionInterval + height + SpecialGuideDetailCell_titleDetailLabel_positionY;
    }
    else
    {
        return GuidecellHeight;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        SpecialGuideDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpecialGuideDetailCell"];
        if(!cell)
        {
            cell = [[[SpecialGuideDetailCell alloc] init] autorelease];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSpecialGuideDetailCell:cell andIndexPath:indexPath];
        return cell;
    }
    else
    {
        GuideViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideViewCellIdentifier"];
        if(cell == nil)
        {
            cell = [[[GuideViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuideViewCellIdentifier"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        [cell resetCell];
        [self initGuideDetailCell:cell andIndexPath:indexPath];
        
        return cell;
    }
    return nil;
}
-(void)initSpecialGuideDetailCell:(SpecialGuideDetailCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    cell.titleDetailLabel.text = [NSString stringWithFormat:@"%@",self.navigationTitle];
    
    float height = [self countContentLabelHeightByString:self.content];
    CGRect rect = [cell.contentLabel frame];
    rect.size.height = height;
    cell.contentLabel.frame = rect;
    
    rect = [cell.backGroundView frame];
    rect.size.height = SpecialGuideDetailCell_titleDetailLabel_positionY + SpecialGuideDetailCell_titleDetailLabel_height + SpecialGuideDetailCell_contentLabel_positionInterval + height + SpecialGuideDetailCell_titleDetailLabel_positionY;
    cell.backGroundView.frame = rect;
    cell.backGroundView.image = [UIImage imageNamed:@"运营页文字详情背景"];
    
    cell.contentLabel.text = self.content;
    
}
-(void)initGuideDetailCell:(GuideViewCell*)cell andIndexPath:(NSIndexPath *)indexPath
{
    cell.position_section = indexPath.section;
    cell.position_row = indexPath.row;
    [cell initCellWithArray:_array_specialGuide atPosition:indexPath.row-1];
}



#pragma mark -
#pragma mark --- GuideViewCellDelegate
- (void)guideViewCellReadButtonDidClick:(GuideViewCell *)cell
{
    
    
}


#pragma mark -
#pragma mark --- countContentLabelHeightByString
-(float)countContentLabelHeightByString:(NSString *)content
{
    if(ios7)
    {
        CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:SpecialGuideDetailCell_titleDetailLabel_font] constrainedToSize:CGSizeMake(SpecialGuideDetailCell_contentLabel_sizeW, CGFLOAT_MAX)];
        
        return sizeToFit.height;
    }
    else
    {
        CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:@"HiraKakuProN-W3" size:SpecialGuideDetailCell_titleDetailLabel_font] constrainedToSize:CGSizeMake(SpecialGuideDetailCell_contentLabel_sizeW, CGFLOAT_MAX)];
        
        return sizeToFit.height;
    }
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
    
    //记录cell的位置 [当从详情页返回时刷新cell]:
    _position_section_tapCell = cell.position_section;
    _position_row_tapCell = cell.position_row;
    
    GuideDetailViewController *guideDetailVC = [[GuideDetailViewController alloc] init];
    guideDetailVC.guide = [_array_specialGuide objectAtIndex:cell.position_row];
    guideDetailVC.where_from = @"guide";
    [self.navigationController pushViewController:guideDetailVC animated:YES];
    [guideDetailVC release];
}
-(void)guideViewCellSelectedReadGuide:(GuideViewCell *)cell
{
    NSLog(@"阅读锦囊");
    
    
    _position_section_tapCell = cell.position_section;
    _position_row_tapCell = cell.position_row;
    
    NSArray *array_needToBeUpdated = [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] retain];
    BOOL flag = 0;
    for(QYGuide *guide in array_needToBeUpdated)
    {
        if([guide.guideName isEqualToString:cell.guide.guideName])
        {
            flag = 1; //需要进行更新的标志
            
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
    if(![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,[cell.guide guideName]]])
    {
        CatalogViewController *catelogVC = [[CatalogViewController alloc] init];
        catelogVC.str_guideName = cell.guide.guideName;
        catelogVC.guide = cell.guide;
        catelogVC.flag_isShowGuideCover = 1;
        [self.navigationController pushViewController:catelogVC animated:YES];
        [catelogVC release];
    }
    else
    {
        NSMutableArray *catlogArray = (NSMutableArray *)[GuideMenuData getMenuJsonWithGuideName:[cell.guide guideName]];
        
        if(catlogArray && [catlogArray isKindOfClass:[NSArray class]])
        {
            ReadViewController *readVC = [[ReadViewController alloc] init];
            readVC.str_guideName = [cell.guide guideName];
            readVC.guide = cell.guide;
            readVC.array_catalog = catlogArray;
            readVC.selectIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,readVC.str_guideName]] intValue];
            readVC.flag_isShowGuideCover = 1;
            [self.navigationController pushViewController:readVC animated:YES];
            [readVC release];
        }
        else
        {
            NSLog(@" 文件已损坏 ~~~");
        }
    }
}
-(void)readNeedUpdatedGuide
{
    QYGuide *guide = [QYGuideData getGuideByName:_guideName_needUpdate];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,_guideName_needUpdate]])
    {
        CatalogViewController *catelogVC = [[CatalogViewController alloc] init];
        catelogVC.str_guideName = _guideName_needUpdate;
        catelogVC.guide = guide;
        catelogVC.flag_isShowGuideCover = 1;
        [self.navigationController pushViewController:catelogVC animated:YES];
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
            readVC.flag_isShowGuideCover = 1;
            readVC.selectIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,readVC.str_guideName]] intValue];
            [self.navigationController pushViewController:readVC animated:YES];
            [readVC release];
        }
        else
        {
            NSLog(@" 文件已损坏 ~~~");
        }
    }
}
-(void)updateCellAtIndepath:(NSIndexPath *)indexpath
{
    [_tableView_specialGuideListVC reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
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
            [self beginUpdateGuide];
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
#pragma mark --- 更新锦囊
-(void)beginUpdateGuide
{
    //*** 网络不好:
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view makeToast:@"貌似网络有点不好，检查一下吧..." duration:1. position:@"center" isShadow:NO];
        
        [self loginIn_Failed];
        
        return;
    }
    
    
    
    
    //更新时不提示需要登录(小柳):
    [self beginUpdateGuide_now];
    
    //    //*** 未登录:
    //    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
    //    {
    //        [[NSUserDefaults standardUserDefaults] setObject:_guideName_needUpdate forKey:@"notlogininwhenupdate_special"];
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
    //        [self beginUpdateGuide_now];
    //    }
}
-(void)beginUpdateGuide_now
{
    //*** 首先将原先已下载的锦囊保存到另外一个目录下,以防更新失败后原先下的锦囊也阅读不了。
    QYGuide *guide = [_array_specialGuide objectAtIndex:_position_row_tapCell];
    [FilePath moveDownloadedGuideToAnotherPathWithGuideName:guide.guideName];
    
    //*** 刷新cell:
    NSIndexPath *indepath = [NSIndexPath indexPathForRow:_position_row_tapCell inSection:_position_section_tapCell];
    GuideViewCell *cell = (GuideViewCell *)[_tableView_specialGuideListVC cellForRowAtIndexPath:indepath];
    QYGuide *guide_needUpdeted = [QYGuideData getGuideByName:_guideName_needUpdate];
    guide_needUpdeted.guide_state = GuideNoamal_State;
    [cell initCellWithArray:[NSArray arrayWithObject:guide_needUpdeted] atPosition:0];
    
    //*** 下载:
    [cell button_selected:nil];
}



#pragma mark -
#pragma mark --- 登录成功
-(void)loginIn_Success
{
    //下载:
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"download_notlogin"] isEqualToString:@"1"])
    {
        NSString *guideName_whenNotLoginin = [[NSUserDefaults standardUserDefaults] objectForKey:@"guideName_notlogininwhendownload"];
        NSInteger section = [[[NSUserDefaults standardUserDefaults] objectForKey:@"section_notlogininwhendownload"] intValue];
        NSInteger row = [[[NSUserDefaults standardUserDefaults] objectForKey:@"row_notlogininwhendownload"] intValue];
        
        
        NSLog(@" guideName_whenNotLoginin : %@",guideName_whenNotLoginin);
        NSLog(@" section : %d",section);
        NSLog(@" row : %d",row);
        GuideViewCell *cell = (GuideViewCell *)[_tableView_specialGuideListVC cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        
        
        QYGuide *guide = [QYGuideData getGuideByName:guideName_whenNotLoginin];
        guide.guide_state = GuideWating_State; //修改锦囊的状态
        [cell initProgressView:guide];  //进度条和下载进度显示
        [cell changeButtonFuctionStateAndImage_ProgressLabelState];
        [QYGuideData startDownloadWithGuide:guide];
        [cell freshCellWithGuide:guide];
        
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"guideName_notlogininwhendownload"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"section_notlogininwhendownload"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"row_notlogininwhendownload"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"download_notlogin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    
    
    
    
    
    //更新时未登录:
    else if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_special"] && _guideName_needUpdate && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_special"] isEqualToString:_guideName_needUpdate])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_special"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSelector:@selector(beginUpdateGuide_now) withObject:nil afterDelay:1.2];
    }
}
-(void)loginIn_Failed
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_special"] && _guideName_needUpdate && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_special"] isEqualToString:_guideName_needUpdate])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_special"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}



#pragma mark -
#pragma mark --- clickBackButton
- (void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if(pushClass)
    {
        [self performSelector:@selector(releasePushClass) withObject:nil afterDelay:0.5];
    }
}


#pragma mark -
#pragma mark --- getRemoteNotificationClass
-(void)getRemoteNotificationClass:(GetRemoteNotificationData *)class
{
    pushClass = class;
}
-(void)releasePushClass
{
    [pushClass release];
}


#pragma mark -
#pragma mark --- resetCellData
-(void)resetCellData
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObjectsFromArray:[QYGuideData getAllDownloadGuide]];
    [self resetCellView:array];
    [_tableView_specialGuideListVC reloadData];
    
    [array removeAllObjects];
    [array release];
}
-(void)resetCellView:(NSArray*)array
{
    for(int i = 0; i < [array count]; i++)
    {
        QYGuide *guide_Download = [array objectAtIndex:i];
        
        for(int j = 0; j < [_array_specialGuide count]; j++)
        {
            QYGuide *guide = [_array_specialGuide objectAtIndex:j];
            
            if([guide_Download.guideId intValue] == [guide.guideId intValue])
            {
                [_array_specialGuide removeObjectAtIndex:j];
                [_array_specialGuide insertObject:[array objectAtIndex:i] atIndex:j];
            }
        }
    }
}




#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

