
//
//  GuideListViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-25.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GuideListViewController.h"
#import "QYGuide.h"
#import "GuideDetailCell.h"
#import "SortStringWithChinese.h"
#import "GuideDetailViewController.h"
#import "QYGuideData.h"
#import "CatalogViewController.h"
#import "ReadViewController.h"
#import "GuideMenuData.h"
#import "GuideMenu.h"
#import "CityLoginViewController.h"
#import "Reachability.h"
#import "Toast+UIView.h"
#import "ChangeTableviewContentInset.h"
#import "FileDamaged.h"
#import "MobClick.h"
#import "FileDecompression.h"




#define     PositionXSectionView            7
#define     height_headerview               (ios7 ? (44+20) : 44)
#define     positionY_titlelabel            (ios7 ? (6+20) : 6)
#define     height_titlelabel               (ios7 ? (30) : 34)
#define     positionY_backbutton            (ios7 ? (3+20) : 3)
#define     positionY_sendbutton            (ios7 ? (6+20) : 6)
#define     positionY_tableView             (ios7 ? (44+20) : 44)
#define     interval_betweenSections        6  //两个section之间的间隔






@interface GuideListViewController ()

@end





@implementation GuideListViewController
@synthesize type;
@synthesize type_id;
@synthesize where_from;

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
    QY_SAFE_RELEASE(_guideName_needUpdate);
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_tableView_guideListVC);
    self.type_id = nil;
    
    [super dealloc];
}



#pragma mark -
#pragma mark --- DidAppear & DidDisappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view makeToastActivity];
    
    
    [MobClick beginLogPageView:@"锦囊列表页"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Failed) name:@"logininfailed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDamaged:) name:@"FileDamaged" object:nil];
    
    
    if(!_array_guide || _array_guide.count == 0)
    {
        //*** 网络不好:
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        {
            [self.view hideToastActivity];
            [self performSelector:@selector(initFailedView) withObject:Nil afterDelay:0.2];
        }
        else
        {
            [self getAllGuide];
        }
    }
    else
    {
        [self.view hideToastActivity];
        if(_imageView_failed)
        {
            _imageView_failed.hidden = YES;
        }
        [_tableView_guideListVC reloadData];
    }
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [MobClick endLogPageView:@"锦囊列表页"];
    
}


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
        
        _imageView_failed.userInteractionEnabled = YES;
        UIControl *control = [[UIControl alloc] initWithFrame:_imageView_failed.bounds];
        [_imageView_failed addSubview:control];
        [control addTarget:self action:@selector(tapToReGetData) forControlEvents:UIControlEventTouchUpInside];
        [control release];
    }
    _imageView_failed.backgroundColor = [UIColor clearColor];
    _imageView_failed.hidden = NO;
    [self.view addSubview:_imageView_failed];
}
-(void)tapToReGetData
{
    [self getAllGuide];
}



#pragma mark -
#pragma mark --- 获取锦囊列表
-(void)getAllGuide
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToastActivity];
        return;
    }
    
    [QYGuideData getGuideListWithType:self.type
                                andId:self.type_id
                              success:^(NSArray *array){
                                  
                                  if(_imageView_failed)
                                  {
                                      _imageView_failed.hidden = YES;
                                  }
                                  [self.view hideToastActivity];
                                  
                                  if(!array || array.count == 0)
                                  {
                                      [self performSelector:@selector(clickBackButton:) withObject:nil afterDelay:0];
                                  }
                                  else
                                  {
                                      if(!_array_guide)
                                      {
                                          _array_guide = [[NSMutableArray alloc] init];
                                      }
                                      [_array_guide removeAllObjects];
                                      [_array_guide addObjectsFromArray:array];
                                      
                                      
                                      //*** 获取已下载的锦囊:
                                      [QYGuideData replaceGuideStateWithDownloadedGuide:_array_guide];
                                      [_tableView_guideListVC reloadData];
                                  }
                                  
                              }
                               failed:^{
                                   
                                   [self.view hideToastActivity];
                                   [self performSelector:@selector(clickBackButton:) withObject:nil afterDelay:0];
                               }];
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
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home_head@2x" ofType:@"png"]];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(184/2, positionY_titlelabel, 136, height_titlelabel)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"锦囊";
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
-(void)initTableView
{
    if(ios7)
    {
        if(!_tableView_guideListVC)
        {
            _tableView_guideListVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height)];
        }
        _tableView_guideListVC.backgroundColor = [UIColor clearColor];
        _tableView_guideListVC.separatorColor = [UIColor clearColor];
    }
    else
    {
        if(!_tableView_guideListVC)
        {
            _tableView_guideListVC = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, ([[UIScreen mainScreen] bounds].size.height-20))];
        }
        _tableView_guideListVC.backgroundColor = [UIColor clearColor];
        _tableView_guideListVC.separatorColor = [UIColor clearColor];
    }
    _tableView_guideListVC.tag = 123;
    _tableView_guideListVC.delegate = self;
    _tableView_guideListVC.dataSource = self;
    
    
    [ChangeTableviewContentInset changeWithTableView:_tableView_guideListVC];
    [self.view addSubview:_tableView_guideListVC];
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
    return [_array_guide count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_array_guide.count-1 == indexPath.row)
    {
        return 240/2 + 2;
    }
    return 240/2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GuideViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideListView_Cell"];
    if(cell == nil)
    {
        cell = [[[GuideViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuideListView_Cell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;
    if(self.where_from)
    {
        cell.where_from = self.where_from;
    }
    else
    {
        cell.where_from = @"guide";
    }
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
#pragma mark --- clickBackButton
- (void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    
    
    
    //记录cell的位置 [当从详情页返回时刷新cell]:
    _position_section_tapCell = cell.position_section;
    _position_row_tapCell = cell.position_row;
    
    GuideDetailViewController *guideDetailVC = [[GuideDetailViewController alloc] init];
    guideDetailVC.flag_new = YES;
    if(self.where_from)
    {
        guideDetailVC.where_from = self.where_from;
    }
    else
    {
        guideDetailVC.where_from = @"guide";
    }
    guideDetailVC.guideId = [[_array_guide objectAtIndex:cell.position_row] guideId];
    guideDetailVC.guide = [_array_guide objectAtIndex:cell.position_row];
    
    [self.navigationController pushViewController:guideDetailVC animated:YES];
    [guideDetailVC release];
    [self performSelector:@selector(changeDelayFlag) withObject:nil afterDelay:1];
    
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
            
            if(_guideName_needUpdate && _guideName_needUpdate.retainCount > 0)
            {
                [_guideName_needUpdate release];
            }
            _guideName_needUpdate = [cell.guide.guideName retain];
            
            break;
        }
    }
    
    
    if(flag == 1) //提示需要进行更新
    {
        QYGuide *guide_needUpdated = [QYGuideData getGuideByName:_guideName_needUpdate];
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
        [FileDecompression decompressionFileWithFileName:[cell.guide guideName] success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view hideToastActivity];
                self.view.superview.userInteractionEnabled = YES;
                self.view.userInteractionEnabled = YES;
                [self performSelector:@selector(changeDelayFlag) withObject:nil afterDelay:1];
                
                
                
                
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
                        NSLog(@" 文件已损坏 ~~~ ");
                        
                        [self.view hideToast];
                        [self.view makeToast:@"文件损坏，需要您重新下载。" duration:1.5 position:@"center" isShadow:NO];
                        [FileDamaged processDamagedFileWithFileName:[cell.guide guideName]];
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
                        
                        [self.view hideToast];
                        [self.view makeToast:@"文件损坏，需要您重新下载。" duration:1.5 position:@"center" isShadow:NO];
                        [FileDamaged processDamagedFileWithFileName:_guideName_needUpdate];
                    }
                }
                
            });
            
            
        } failed:^{
            
        }];
    });
    
}
-(void)updateCellAtIndepath:(NSIndexPath *)indexpath
{
    [_tableView_guideListVC reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
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
#pragma mark --- UpdateGuide
-(void)beginUpdateGuide
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
    [self beginUpdateGuide_now];
    
    
    //    //*** 未登录:
    //    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
    //    {
    //        [[NSUserDefaults standardUserDefaults] setObject:_guideName_needUpdate forKey:@"notlogininwhenupdate_guidelist"];
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
    [FilePath moveDownloadedGuideToAnotherPathWithGuideName:_guideName_needUpdate];
    
    
    //*** 刷新cell:
    QYGuide *guide_needUpdeted = [QYGuideData getGuideByName:_guideName_needUpdate];
    guide_needUpdeted.guide_state = GuideNoamal_State;
    NSIndexPath *indepath = [NSIndexPath indexPathForRow:_position_row_tapCell inSection:_position_section_tapCell];
    GuideViewCell *cell = (GuideViewCell *)[_tableView_guideListVC cellForRowAtIndexPath:indepath];
    [cell initCellWithArray:[NSArray arrayWithObject:guide_needUpdeted] atPosition:_position_row_tapCell];
    
    
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
        GuideViewCell *cell = (GuideViewCell *)[_tableView_guideListVC cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        
        
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
    
    
    
    
    
    
    
    
    //更新:
    else if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_guidelist"] && _guideName_needUpdate && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_guidelist"] isEqualToString:_guideName_needUpdate])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_guidelist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSelector:@selector(beginUpdateGuide_now) withObject:nil afterDelay:1.2];
    }
}
-(void)loginIn_Failed
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_guidelist"] && _guideName_needUpdate && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_guidelist"] isEqualToString:_guideName_needUpdate])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_guidelist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


-(void)changeDelayFlag
{
    self.view.superview.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    _flag_delay = NO;
}




#pragma mark -
#pragma mark --- 文件损坏
-(void)fileDamaged:(NSNotification *)notfification
{
    NSDictionary *info_dic = [notfification userInfo];
    if(info_dic && [info_dic objectForKey:@"guidename"])
    {
        NSLog(@"  guideListVC_损坏的是: %@",[info_dic objectForKey:@"guidename"]);
        [_tableView_guideListVC reloadData];
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

