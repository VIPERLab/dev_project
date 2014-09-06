//
//  LatestGuideViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-2.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "LatestGuideViewController.h"
#import "GuideDetailViewController.h"
#import "QYGuideData.h"
#import "CatalogViewController.h"
#import "ReadViewController.h"
#import "GuideMenuData.h"
#import "GuideMenu.h"
#import "Reachability.h"
#import "Toast+UIView.h"
#import "CityLoginViewController.h"
#import "ChangeTableviewContentInset.h"
#import "FileDecompression.h"



#define     height_headerview       (ios7 ? (46+20) : 46)
#define     positionY_titlelabel    (ios7 ? (6+20) : 6)
#define     height_titlelabel       (ios7 ? (30) : 34)
#define     positionY_backbutton    (ios7 ? (3+20) : 3)
#define     positionY_tableView     (ios7 ? (46+20) : 46)




@interface LatestGuideViewController ()

@end





@implementation LatestGuideViewController

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
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_tableview_latestGuideVC);
    QY_MUTABLERECEPTACLE_RELEASE(_array_guide);
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- viewDidAppear  &  viewDidDisappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [self.view makeToastActivity];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Failed) name:@"logininfailed" object:nil];
    
    
    
    if(_initFlag == 0)
    {
        _initFlag = YES;
        [self initLatestGuideData];
    }
    
    
    //刷新cell [当在详情页点击下载后,cell的状态会有变化]
    [_tableview_latestGuideVC reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:position inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark -
#pragma mark --- initLatestGuideData
-(void)initLatestGuideData
{
    if(!_array_guide)
    {
        _array_guide = [[NSMutableArray alloc] init];
    }
    [_array_guide removeAllObjects];
    
    [self initGuideLatestFromAllGuide];
}
-(void)initGuideLatestFromAllGuide
{
    NSArray *array = [QYGuideData  getAllGuide];
    [self loadView_afterGetData:array];
}
-(void)loadView_afterGetData:(NSArray *)array
{
    if(array.count > 0)
    {
        [_array_guide removeAllObjects];
        for(int i = array.count-1; i >= array.count-newsetGuideNumber; i--)
        {
            [_array_guide addObject:[array objectAtIndex:i]];
        }
        
        //获取已下载的锦囊:
        [QYGuideData replaceGuideStateWithDownloadedGuide:_array_guide];
    }
    
    
    [self.view hideToastActivity];
    
    if(!_tableview_latestGuideVC)
    {
        [self initLatestGuideTableView];
    }
    else
    {
        [_tableview_latestGuideVC reloadData];
    }
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
    
    
    [self initRootView];
    [self setNavigationBar];
}
-(void)initRootView
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
    
    UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(184/2, positionY_titlelabel, 136, height_titlelabel)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"最新锦囊";
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
    [_backButton addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
}
-(void)initLatestGuideTableView
{
    if(ios7)
    {
        if(!_tableview_latestGuideVC)
        {
            _tableview_latestGuideVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
        }
        _tableview_latestGuideVC.backgroundColor = [UIColor clearColor];
        _tableview_latestGuideVC.separatorColor = [UIColor clearColor];
    }
    else
    {
        if(!_tableview_latestGuideVC)
        {
            _tableview_latestGuideVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, ([[UIScreen mainScreen] bounds].size.height-20))];
        }
        _tableview_latestGuideVC.backgroundColor = [UIColor clearColor];
        _tableview_latestGuideVC.separatorColor = [UIColor clearColor];
    }
    _tableview_latestGuideVC.delegate = self;
    _tableview_latestGuideVC.dataSource = self;
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
    headView.backgroundColor = [UIColor clearColor];
    _tableview_latestGuideVC.tableHeaderView = headView;
    [headView release];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
    footView.backgroundColor = [UIColor clearColor];
    _tableview_latestGuideVC.tableFooterView = footView;
    [footView release];
    
    
    [ChangeTableviewContentInset changeWithTableView:_tableview_latestGuideVC];
    [self.view addSubview:_tableview_latestGuideVC];
    [self.view bringSubviewToFront:_headView];
}


#pragma mark -
#pragma mark --- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array_guide count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 234/2.;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
-(void)initGuideDetailCell:(GuideViewCell*)cell andIndexPath:(NSIndexPath *)indexPath
{
    cell.position_section = indexPath.section;
    cell.position_row = indexPath.row;
    [cell initCellWithArray:_array_guide atPosition:indexPath.row];
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
    guideDetailVC.guide = [_array_guide objectAtIndex:cell.position_row];
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
    [array_needToBeUpdated release];
    
    
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
}
-(void)readGuide:(GuideViewCell *)cell
{
    
    [self.view makeToastActivity];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //解压缩zip包:
        [FileDecompression decompressionFileWithFileName:[cell.guide guideName] success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view hideToastActivity];
                
                
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
                
            });
            
            
        } failed:^{
            
        }];
    });
    
}
-(void)readNeedUpdatedGuide
{
    [self.view makeToastActivity];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //解压缩zip包:
        [FileDecompression decompressionFileWithFileName:_guideName_needUpdate success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view hideToastActivity];
                
                
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
                        readVC.selectIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,readVC.str_guideName]] intValue];
                        readVC.flag_isShowGuideCover = 1;
                        [self.navigationController pushViewController:readVC animated:YES];
                        [readVC release];
                    }
                    else
                    {
                        NSLog(@" 文件已损坏 ~~~ ");
                    }
                }
                
            });
            
        } failed:^{
            
        }];
    });
    
}
-(void)updateCellAtIndepath:(NSIndexPath *)indexpath
{
    [_tableview_latestGuideVC reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
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
    //        [[NSUserDefaults standardUserDefaults] setObject:_guideName_needUpdate forKey:@"notlogininwhenupdate_latest"];
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
    QYGuide *guide = [_array_guide objectAtIndex:_position_row_tapCell];
    [FilePath moveDownloadedGuideToAnotherPathWithGuideName:guide.guideName];
    
    //*** 刷新cell:
    NSIndexPath *indepath = [NSIndexPath indexPathForRow:_position_row_tapCell inSection:_position_section_tapCell];
    GuideViewCell *cell = (GuideViewCell *)[_tableview_latestGuideVC cellForRowAtIndexPath:indepath];
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
        GuideViewCell *cell = (GuideViewCell *)[_tableview_latestGuideVC cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        
        
        QYGuide *guide = [QYGuideData getGuideByName:guideName_whenNotLoginin];
        guide.guide_state = GuideDownloading_State; //修改锦囊的状态
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
    
    
    
    //更新:
    else if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_latest"] && _guideName_needUpdate && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_latest"] isEqualToString:_guideName_needUpdate])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_latest"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSelector:@selector(beginUpdateGuide_now) withObject:nil afterDelay:1.2];
    }
}
-(void)loginIn_Failed
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_latest"] && _guideName_needUpdate && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_latest"] isEqualToString:_guideName_needUpdate])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_latest"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}




#pragma mark -
#pragma mark --- doBack
- (void)doBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end