//
//  GuideDetailViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GuideDetailViewController.h"
#import "GuideDetailCell.h"
#import "AddGuideCommentCell.h"
#import "GuideCommentCell.h"
#import "GuideAuthorDetailCell.h"
#import "UIImageView+WebCache.h"
#import "QYGuideComment.h"
#import "CommentGuideViewController.h"
#import "FilePath.h"
#import "DownloadData.h"
#import "QYGuideData.h"
#import "CatalogViewController.h"
#import "ReadViewController.h"
#import "GuideMenuData.h"
#import "GuideMenu.h"
#import "ReadViewController.h"
#import "MobClick.h"
#import "Reachability.h"
#import "Toast+UIView.h"
#import "ASIHTTPRequest.h"
#import "Toast+UIView.h"
#import "QyerSns.h"
#import "CityLoginViewController.h"
#import "ChangeTableviewContentInset.h"
#import "FileDamaged.h"
#import "FileDecompression.h"



#define     SectionHeight               50
#define     CommentNumberOneTimeGet     10 //加载一次获取的评论条数


#define     kAboutButtonOriginX         10
#define     KAboutButtonOriginY         0
#define     kAboutButtonSizeWidth       144/2
#define     kAboutButtonSizeHeight      100/2

#define     kCommentButtonOriginX       75
#define     kCommentButtonOriginY       0
#define     kCommentButtonSizeWidth     144/2
#define     kCommentButtonSizeHeight    100/2

#define     kRelationButtonOriginX      145
#define     kRelationButtonOriginY      0
#define     kRelationButtonSizeWidth    144/2
#define     kRelationButtonSizeHeight   100/2

#define     kDownloadButtonOriginX      232
#define     kDownloadButtonOriginY      (SectionHeight-kDownloadButtonSizeHeight)/2
#define     kDownloadButtonSizeWidth    160/2
#define     kDownloadButtonSizeHeight   64/2


#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (6+20) : 6)
#define     height_titlelabel           (ios7 ? (30) : 34)
#define     positionY_backbutton        (ios7 ? (3+20) : 3)
#define     positionY_sharebutton       (ios7 ? (2+20) : 2)
#define     positionY_tableView         (ios7 ? (44+20) : 44)





@interface GuideDetailViewController ()

@end







@implementation GuideDetailViewController
@synthesize navigationTitle = _navigationTitle;
@synthesize guide = _guide;
@synthesize fromPushFlag;
@synthesize image_share;
@synthesize guideId;
@synthesize flag_new = _flag_new;
@synthesize where_from;


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
    cell_guideCover.delegate = nil;
    [cell_guideCover release];
    
    QY_MUTABLERECEPTACLE_RELEASE(_dic_height);
    QY_MUTABLERECEPTACLE_RELEASE(_array_abountGuide);
    QY_MUTABLERECEPTACLE_RELEASE(_array_guideComment);
    QY_MUTABLERECEPTACLE_RELEASE(_array_relatedGuide);
    
    QY_SAFE_RELEASE(_titleLabel);
    QY_SAFE_RELEASE(_guideName_needUpdate);
    QY_SAFE_RELEASE(_navigationTitle);
    QY_SAFE_RELEASE(_activityView);
    
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_tableview_guideDetail);
    QY_VIEW_RELEASE(_footView);
    QY_VIEW_RELEASE(_imageView_speration);
    QY_VIEW_RELEASE(_myTableView);
    QY_VIEW_RELEASE(_imageView_failed);
    
    self.guideId = nil;
    self.image_share = nil;
    self.guide = nil;
    
    
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
        
        
        newFrame = _tableview_guideDetail.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableview_guideDetail.frame = newFrame;
        
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        newFrame = _tableview_guideDetail.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableview_guideDetail.frame = newFrame;
        
    }
}


#pragma mark -
#pragma mark --- 从后台返回来
-(void)becomeActive
{
    if(_tableview_guideDetail)
    {
        [_tableview_guideDetail reloadData];
    }
}


#pragma mark -
#pragma mark --- view - Appear & Disappear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [MobClick beginLogPageView:@"锦囊详情页"];
    
    
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"hotdot_phone"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:YES];
    }
    
    
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Failed) name:@"logininfailed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDamaged:) name:@"FileDamaged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:@"BecomeActive" object:nil];
    //评论锦囊成功:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentGuide_success:) name:@"commentGuide_success" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guide_download_failed:) name:@"downloadfailed" object:nil];
    
    
    
    
    if(_flag_getDetailInfo == NO) //从其他页面pop回来时不需要重新获取数据
    {
        _flag_getDetailInfo = YES;
        _tableview_guideDetail.hidden = YES;
        
        [self getGuideDetailInfoFromCache];
        
        if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        {
            [self.view hideToastActivity];
            [self.view hideToast];
            [self.view makeToast:@"网络错误" duration:1 position:@"center" isShadow:NO];
            
            
            return;
        }
        
        
        NSLog(@" --------------- 1 请求");
        NSLog(@"  服务器 ");
        _tableview_guideDetail.userInteractionEnabled = NO;
        [self getGuideDetailInfoFromServer];
        
    }
    else
    {
        _tableview_guideDetail.userInteractionEnabled = YES;
        [_tableview_guideDetail reloadData];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [MobClick endLogPageView:@"锦囊详情页"];
    
    
    NSLog(@" 取消获取锦囊的详情页");
    [QYGuideData cancleGuideDetailInfoWithGuideId:self.guide.guideId];
    
}




#pragma mark -
#pragma mark --- getGuideDetailInfo --- FromCache
-(void)getGuideDetailInfoFromCache
{
    //缓存:
    [QYGuideData getGuideDetailInfoFromCacheWithGuideId:self.guideId
                                                success:^(QYGuide *guide){
                                                    
                                                    if(guide)
                                                    {
                                                        NSLog(@"  获取锦囊详情 [缓存] 成功 !!!");
                                                        [self addGuideInfoWithGuide:guide];
                                                    }
                                                    [self setGuideDetailInfoView];
                                                    
                                                }
                                                 failed:^{
                                                     NSLog(@"  获取锦囊详情 [缓存] 失败");
                                                     
                                                     NSLog(@" self.guide : %@",self.guide);
                                                     [self setGuideDetailInfoView];
                                                     [self setNavigationBar];
                                                 }];
}



#pragma mark -
#pragma mark --- getGuideDetailInfo --- FromServer
-(void)getGuideDetailInfoFromServer
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        _tableview_guideDetail.userInteractionEnabled = YES;
        return;
    }
    
    
    
    
    [self.view hideToastActivity];
    [self.view makeToastActivity];
    
    
    
    
    if([[QYGuideData sharedQYGuideData] flag_getAllNew] == YES) //已经getall成功
    {
        [self loadServerData];
    }
    else //还没有getall
    {
        //首先getall加载所有数据:
        [QYGuideData fromV4_getAllGuideIncludeCache:NO
                                     success:^(NSArray *array,BOOL isCache){
                                         
                                         [self loadServerData];
                                         
                                     } failed:^{
                                         NSLog(@" fromV4_getAllGuide 失败 --- ");
                                         
                                         [self.view hideToastActivity];
                                         _tableview_guideDetail.userInteractionEnabled = YES;
                                     }];
    }
    
}
-(void)loadServerData
{
    //服务器:
    [QYGuideData getGuideDetailInfoWithGuideId:self.guideId
                                       success:^(QYGuide *guide){
                                           if(guide)
                                           {
                                               NSLog(@"\n  获取锦囊详情 [服务器] 成功 !!!\n\n%@\n\n",guide);
                  
                                               [self.view hideToastActivity];
                                               _flag_getData = YES;
                                               [self addGuideInfoWithGuide:guide];
                                               [self setGuideDetailInfoView];
                                               [self setNavigationBar];
                                           }
                                           _tableview_guideDetail.userInteractionEnabled = YES;
                                       }
                                        failed:^{
                                            NSLog(@"  获取锦囊详情 [服务器] 失败");
                                            
                                            [self.view hideToastActivity];
                                            _tableview_guideDetail.userInteractionEnabled = YES;
                                        }];
}




-(void)addGuideInfoWithGuide:(QYGuide *)guide
{
    if(!self.guide)
    {
        NSLog(@" 替换 guide");
        self.guide = guide;
    }
    else
    {
        NSLog(@" 追加 guide 信息");
        self.guide.guideCoverImage_big = guide.guideCoverImage_big;
        self.guide.guideBriefinfo = guide.guideBriefinfo;
        self.guide.guideFilePath = guide.guideFilePath;
        self.guide.guideCatalog = guide.guideCatalog;
        self.guide.guideCreate_time = guide.guideCreate_time;
        self.guide.guideAuthor_id = guide.guideAuthor_id;
        self.guide.guideAuthor_name = guide.guideAuthor_name;
        self.guide.guideAuthor_icon = guide.guideAuthor_icon;
        self.guide.guideAuthor_intro = guide.guideAuthor_intro;
        self.guide.guideData_iPhone = guide.guideData_iPhone;
        self.guide.guideData_iPad = guide.guideData_iPad;
        self.guide.guide_relatedGuide_ids = guide.guide_relatedGuide_ids;
        self.guide.guidePages = guide.guidePages;
    }
}
-(void)setGuideDetailInfoView
{
    [self setTableView];
    _tableview_guideDetail.hidden = NO;
    _imageView_failed.hidden = YES;
    
    [self getRelatedGuide];     //获取关联锦囊
    [self countCellHeight];     //计算cell的高度
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
    
    
    [self setRootView];
    [self setNavigationBar];
}
-(void)setRootView
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
        _headView.backgroundColor = [UIColor clearColor];
        _headView.image = [UIImage imageNamed:@"home_head"];
        _headView.userInteractionEnabled = YES;
    }
    [self.view addSubview:_headView];
    
    
    if(!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, positionY_titlelabel, 240, height_titlelabel)];
        _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = self.navigationTitle;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
        //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    }
    _titleLabel.text = self.guide.guideName;
    if(!self.guide.guideName)
    {
        _titleLabel.text = self.guide.guideName_en;
    }
    [_headView addSubview:_titleLabel];
    
    if(!_backButton)
    {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor clearColor];
        _backButton.frame = CGRectMake(0, positionY_backbutton, 40, 40);
        [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    [_headView addSubview:_backButton];
    
    if(!_shareButton)
    {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.frame = CGRectMake(279, positionY_sharebutton, 40, 40);
        [_shareButton setBackgroundImage:[UIImage imageNamed:@"btn_detail_share"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(clickShareButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    [_headView addSubview:_shareButton];
}
-(void)setTableView
{
    if(!_tableview_guideDetail)
    {
        _tableview_guideDetail = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [self.view bounds].size.height)];
    }
    _tableview_guideDetail.backgroundColor = [UIColor clearColor];
    _tableview_guideDetail.separatorColor = [UIColor clearColor];
//    if(ios7)
//    {
//        if(!_tableview_guideDetail)
//        {
//            _tableview_guideDetail = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, [self.view bounds].size.height)];
//        }
//        _tableview_guideDetail.backgroundColor = [UIColor clearColor];
//        _tableview_guideDetail.separatorColor = [UIColor clearColor];
//    }
//    else
//    {
//        if(!_tableview_guideDetail)
//        {
//            _tableview_guideDetail = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, ([self.view bounds].size.height-20))];
//        }
//        _tableview_guideDetail.backgroundColor = [UIColor clearColor];
//        _tableview_guideDetail.separatorColor = [UIColor clearColor];
//    }
    _tableview_guideDetail.delegate = self;
    _tableview_guideDetail.dataSource = self;
    [_tableview_guideDetail reloadData];
    
    
    [ChangeTableviewContentInset changeWithTableView:_tableview_guideDetail];
    [self.view addSubview:_tableview_guideDetail];
    [self.view bringSubviewToFront:_headView];
    
    
    //初始化时选择关于:
    NSLog(@"  _state_tableView  : %d",_state_tableView);
    if(_state_tableView > 0)
    {
        
    }
    else
    {
        _state_tableView = Guide_about;
    }
    
}



#pragma mark -
#pragma mark --- 获取相关锦囊
-(void)getRelatedGuide
{
    if(!_array_relatedGuide)
    {
        _array_relatedGuide = [[NSMutableArray alloc] init];
    }
    [_array_relatedGuide removeAllObjects];
    
    NSArray *array = [self.guide.guide_relatedGuide_ids componentsSeparatedByString:@","];
    if(array && array.count > 0)
    {
        for(int i = 0; i < array.count; i++)
        {
            NSString *idString = [array objectAtIndex:i];
            if(idString)
            {
                QYGuide *guide = [QYGuideData getGuideById:idString];
                if(guide)
                {
                    [_array_relatedGuide addObject:guide];
                }
            }
        }
    }
}




#pragma mark -
#pragma mark --- 点击关于按钮 & 点击评论按钮 & 点击关联锦囊按钮 & 点击下载／取消／阅读按钮
-(void)clickAboutButton:(id)sender
{
    _state_tableView = Guide_about;
    [_tableview_guideDetail reloadData];
    [self resetTableFooterView:0];
}
-(void)clickCommentButton:(id)sender
{
    NSLog(@" --- click-CommentButton ");
    
    _state_tableView = Guide_comment;
    [_tableview_guideDetail reloadData];
    
    if(!_array_guideComment || _array_guideComment.count == 0)
    {
        [self resetTableFooterView:3];   //菊花转圈
        [self getGuideCommentByGuideId];
    }
    else
    {
        [self resetTableFooterView:1];
    }
}
-(void)clickRelationButton:(id)sender
{
    _state_tableView = Guide_related;
    [_tableview_guideDetail reloadData];
    [self resetTableFooterView:0];
}
-(void)clickFuctionButton:(id)sender
{
    if(self.guide.guide_state == GuideNoamal_State || self.guide.guide_state == GuideDownloadFailed_State)
    {
        NSLog(@"下载锦囊");
        
        
        //*** 网络不好:
        if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        {
            [self.view hideToast];
            [self.view hideToastActivity];
            [self.view makeToast:@"网络错误" duration:1 position:@"center" isShadow:NO];
            return;
        }
        
    
        _flag_isRefresh = 1;
        
        
        //3g网络:
        if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN)
        {
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"WIFISwitch"] boolValue] == NO) //3g环境下允许下载
            {
                NSLog(@" 3g环境下允许下载 ");
                
                
                //未登录:
                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
                {
                    NSInteger limit_counts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mobileDownloadLimit"] intValue];
                    NSInteger times = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mobileDownloadCount"] intValue];
                    if(times < limit_counts)
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",times+1] forKey:@"mobileDownloadCount"]; //未登录状态下的下载次数
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
                        if([[DownloadData sharedDownloadData] requestListDic].count == 0)
                        {
                            self.guide.guide_state = GuideDownloading_State;
                        }
                        else
                        {
                            self.guide.guide_state = GuideWating_State;
                        }
                        [self startDownload];
                        [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"download_notlogin_detailVC"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
                        UIAlertView *alertView = [[UIAlertView alloc]
                                                  initWithTitle:Nil
                                                  message:@"您登录之后才能下载更多锦囊"
                                                  delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"立即登录",nil];
                        alertView.tag = 788;
                        alertView.delegate = self;
                        [alertView show];
                        [alertView release];
                        
                        return;
                    }
                }
                
                
                
                
                else
                {
                    if([[DownloadData sharedDownloadData] requestListDic].count == 0)
                    {
                        self.guide.guide_state = GuideDownloading_State;
                    }
                    else
                    {
                        self.guide.guide_state = GuideWating_State;
                    }
                    [self startDownload];
                    
                    [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }
                
            }
            else //仅允许wifi环境下下载:
            {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:nil
                                          message:@"当前处于移动网络，已为您暂停了所有下载"
                                          delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"允许本次下载", @"始终允许移动网络下载", @"暂停下载", nil];
                alertView.tag = 12;
                alertView.delegate = self;
                [alertView show];
                [alertView release];
                
                return;
            }
        }
        
        
        //未登录:
        else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
        {
            NSInteger limit_counts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mobileDownloadLimit"] intValue];
            NSInteger times = [[[NSUserDefaults standardUserDefaults] objectForKey:@"mobileDownloadCount"] intValue];
            if(times < limit_counts)
            {
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",times+1] forKey:@"mobileDownloadCount"]; //未登录状态下的下载次数
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                if([[DownloadData sharedDownloadData] requestListDic].count == 0)
                {
                    self.guide.guide_state = GuideDownloading_State;
                }
                else
                {
                    self.guide.guide_state = GuideWating_State;
                }
                [self startDownload];
                [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"download_notlogin_detailVC"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:Nil
                                          message:@"您登录之后才能下载更多锦囊"
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"立即登录",nil];
                alertView.tag = 788;
                alertView.delegate = self;
                [alertView show];
                [alertView release];
                
                return;
            }
        }
        
        else
        {
            if([[DownloadData sharedDownloadData] requestListDic].count == 0)
            {
                self.guide.guide_state = GuideDownloading_State;
            }
            else
            {
                self.guide.guide_state = GuideWating_State;
            }
            [self startDownload];
            
            [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }
    else if(self.guide.guide_state == GuideWating_State)
    {
        NSLog(@"取消下载锦囊");
        _flag_isRefresh = 0;
        
        self.guide.guide_state = GuideNoamal_State;
        [self suspend];
        
        [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    else if(self.guide.guide_state == GuideDownloading_State)
    {
        NSLog(@"取消下载锦囊");
        _flag_isRefresh = 0;
        
        self.guide.guide_state = GuideNoamal_State;
        [self suspend];
        
        [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    else if(self.guide.guide_state == GuideRead_State)
    {
        NSLog(@"阅读锦囊");
        
        NSArray *array_needToBeUpdated = [[[QYGuideData sharedQYGuideData] array_guideNeedToBeUpdated] retain];
        BOOL flag = 0;
        for(QYGuide *guide in array_needToBeUpdated)
        {
            if([guide.guideName isEqualToString:self.guide.guideName])
            {
                flag = 1; //需要进行更新的标志
                
                break;
            }
        }
        [array_needToBeUpdated release];
        
        
        
        if(flag == 1) //提示需要进行更新
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"本锦囊有更新，更新内容："
                                                                message:self.guide.guideUpdate_log
                                                               delegate:self
                                                      cancelButtonTitle:@"忽略"
                                                      otherButtonTitles:@"立即更新", nil];
            alertView.tag = 789;
            [alertView show];
            [alertView release];
        }
        else
        {
            [self readGuide];
        }
    }
}
-(void)startDownload
{
    if(self.where_from && [self.where_from isEqualToString:@"guide"])
    {
        [MobClick event:@"guideGuideDetailDownload"];
    }
    else if(self.where_from && [self.where_from isEqualToString:@"country"])
    {
        [MobClick event:@"countryGuideListGuideDetailDownload"];
    }
    else if(self.where_from && [self.where_from isEqualToString:@"city"])
    {
        [MobClick event:@"cityGuideListGuideDetailDownload"];
    }
    
    
    
    [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self setButtonStateByGuideState];
    self.guide.guide_state = GuideWating_State;
    [QYGuideData startDownloadWithGuide:self.guide];
    
}
-(void)suspend
{
    [QYGuideData suspend:self.guide];
    
    [self setButtonStateByGuideState];
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
            break;
        }
    }
}
-(void)readGuide
{
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    self.view.userInteractionEnabled = NO;
    
    
    
    [self.view makeToastActivity];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //解压缩zip包:
        [FileDecompression decompressionFileWithFileName:[self.guide guideName] success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view hideToastActivity];
                self.view.userInteractionEnabled = YES;
                [self performSelector:@selector(changeDelayFlag) withObject:nil afterDelay:1];
                
                if(![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,[self.guide guideName]]])
                {
                    CatalogViewController *catelogVC = [[CatalogViewController alloc] init];
                    catelogVC.str_guideName = [self.guide guideName];
                    catelogVC.guide = self.guide;
                    catelogVC.flag_isShowGuideCover = 1;
                    [self.navigationController pushViewController:catelogVC animated:YES];
                    [catelogVC release];
                }
                else
                {
                    NSMutableArray *catlogArray = (NSMutableArray *)[GuideMenuData getMenuJsonWithGuideName:[self.guide guideName]];
                    
                    if(catlogArray && [catlogArray isKindOfClass:[NSArray class]])
                    {
                        ReadViewController *readVC = [[ReadViewController alloc] init];
                        readVC.str_guideName = [self.guide guideName];
                        readVC.guide = self.guide;
                        readVC.array_catalog = catlogArray;
                        readVC.selectIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,readVC.str_guideName]] intValue];
                        readVC.flag_isShowGuideCover = 1;
                        [self.navigationController pushViewController:readVC animated:YES];
                        [readVC release];
                    }
                    else
                    {
                        NSLog(@" 文件已损坏 ~~~");
                        
                        [self.view hideToast];
                        [self.view makeToast:@"文件损坏，需要您重新下载。" duration:1.5 position:@"center" isShadow:NO];
                        [FileDamaged processDamagedFileWithFileName:[self.guide guideName]];
                    }
                }
                
            });
            
            
        } failed:^{
            
            self.view.userInteractionEnabled = YES;
        }];
    });
    
}

-(void)changeDelayFlag
{
    _flag_delay = NO;
}



#pragma mark -
#pragma mark --- GuideCoverCell - Delegate
-(void)readGuideWhenClickPic
{
    [self readGuide];
}
-(void)guideDownloadFinished
{
    [self setButtonStateByGuideState];
}


#pragma mark -
#pragma mark --- resetTableFooterView & setTableViewFooterView & resetTableFooterViewTitle
-(void)resetTableFooterView:(NSInteger)flag
{
    if(flag == 0)  //没有footerView
    {
        _tableview_guideDetail.tableFooterView = nil;
    }
    else if(flag == 2)  //当下载了锦囊的最后一条评论时,再加上8像素高的tableFooterView。
    {
        [self setTableViewFooterView:2];
    }
    else if(flag == 3)
    {
        [self setTableViewFooterView:3];
    }
    else
    {
        [self setTableViewFooterView:0];
    }
}
-(void)setTableViewFooterView:(NSInteger)flag
{
    if(flag == 2)
    {
        if(_activityView)
        {
            [_activityView stopAnimating];
        }
        
        UIView *footView_bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)];
        footView_bottom.backgroundColor = [UIColor clearColor];
        _tableview_guideDetail.tableFooterView = footView_bottom;
        [footView_bottom release];
        
        return;
    }
    else if(flag == 3)
    {
        [self initFooterViewWithStatus:1];
        
        return;
    }
    
    [self initFooterViewWithStatus:0];
}
-(void)initFooterViewWithStatus:(BOOL)flag
{
    if(!_footView)
    {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        _footView.backgroundColor = [UIColor clearColor];
    }
    _footView.userInteractionEnabled = YES;
    if(![_footView viewWithTag:19191])
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 20)];
        label.tag = 19191;
        label.backgroundColor = [UIColor clearColor];
        label.text = @"获取更多评论";
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        [_footView addSubview:label];
        [label release];
    }
    
    if(![_footView viewWithTag:19192])
    {
        UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        control.tag = 19192;
        [control setBackgroundColor:[UIColor clearColor]];
        [control addTarget:self action:@selector(getGuideCommentByGuideId) forControlEvents:UIControlEventTouchUpInside];
        [_footView addSubview:control];
        [control release];
    }
    
    
    if(flag == 1)
    {
        [self resetTableFooterViewTitle];
    }
    _tableview_guideDetail.tableFooterView = _footView;
}
-(void)resetTableFooterViewTitle
{
    [(UILabel *)[_footView viewWithTag:19191] setText:@"      正在加载..."];
    if(!_activityView)
    {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    _activityView.backgroundColor = [UIColor clearColor];
    _activityView.center = CGPointMake(120, 15);
    [_footView addSubview:_activityView];
    [_activityView startAnimating];
}


#pragma mark -
#pragma mark --- 计算cell的高度
-(void)countCellHeight
{
    //锦囊简介:
    [self countCellHeightWithValue:self.guide.guideBriefinfo andKey:@"guide_detail" andFontNmae:@"HiraKakuProN-W3" andLength:guideDetailCellguideDetailLabelFrame.size.width andFontSize:13.];
    
    //锦囊作者相关信息:
    [self countCellHeightWithValue:self.guide.guideAuthor_intro andKey:@"guide_author" andFontNmae:@"HiraKakuProN-W3" andLength:guideAuthorDetailCellIntroductionLabelFrame.size.width andFontSize:13];
}
-(void)countGuideCommentHeight:(NSArray *)array
{
    if(array)
    {
        NSInteger position = [_array_guideComment count];
        for(int i = 0; i < [array count]; i++)
        {
            QYGuideComment *guideComment = [array objectAtIndex:i];
            
            [self countCellHeightWithValue:guideComment.str_content andKey:[NSString stringWithFormat:@"%d",position+i] andFontNmae:@"HiraKakuProN-W3" andLength:guideCommentCellIntroductionLabelFrame.size.width andFontSize:13.];
        }
    }
}
-(void)countCellHeightWithValue:(NSString *)value andKey:(NSString *)key andFontNmae:(NSString *)fontName andLength:(float)length andFontSize:(float)fontSize
{
    if(!_dic_height)
    {
        _dic_height = [[NSMutableDictionary alloc] init];
    }
    
    CGFloat height = [self countContentLabelHeightByString:value andFontNmae:fontName andLength:length andFontSize:fontSize];
    [_dic_height setObject:[NSString stringWithFormat:@"%f",height] forKey:key];
}


#pragma mark -
#pragma mark --- 计算String所占的高度
-(float)countContentLabelHeightByString:(NSString*)content andFontNmae:(NSString *)fontName  andLength:(float)length andFontSize:(float)font
{
    CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:fontName size:font] constrainedToSize:CGSizeMake(length, CGFLOAT_MAX)];
    
    return sizeToFit.height;
}



#pragma mark -
#pragma mark --- UITableView - DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        return SectionHeight;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        UIImageView *headerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _tableview_guideDetail.frame.size.width, SectionHeight)] autorelease];
        headerView.backgroundColor = [UIColor clearColor];
        headerView.image = [UIImage imageNamed:@"bg_tab"];
        headerView.userInteractionEnabled = YES;
        
        
        //两条竖线:
        _imageView_speration = [[UIImageView alloc] initWithFrame:CGRectMake(kCommentButtonOriginX, kCommentButtonOriginY, kCommentButtonSizeWidth, kCommentButtonSizeHeight)];
        [_imageView_speration setImage:[UIImage imageNamed:@"bg_detail_line"]];
        [headerView addSubview:_imageView_speration];
        
        
        //关于按纽:
        _button_about = [UIButton buttonWithType:UIButtonTypeCustom];
        _button_about.frame = CGRectMake(kAboutButtonOriginX-6, KAboutButtonOriginY, kAboutButtonSizeWidth, kAboutButtonSizeHeight);
        [_button_about addTarget:self action:@selector(clickAboutButton:) forControlEvents:UIControlEventTouchUpInside];
        [_button_about setBackgroundImage:[UIImage imageNamed:@"btn_detailtab_about_highlight"] forState:UIControlStateHighlighted];
        [_button_about setBackgroundImage:[UIImage imageNamed:@"btn_detailtab_about_normal"] forState:UIControlStateNormal];
        [_button_about setBackgroundImage:[UIImage imageNamed:@"btn_detailtab_about_selected"] forState:UIControlStateSelected];
        [headerView addSubview:_button_about];
        
        
        //评论按纽:
        _button_comment = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _button_comment.frame = CGRectMake(kCommentButtonOriginX, kCommentButtonOriginY, kCommentButtonSizeWidth, kCommentButtonSizeHeight);
        [_button_comment addTarget:self action:@selector(clickCommentButton:) forControlEvents:UIControlEventTouchUpInside];
        [_button_comment setBackgroundImage:[UIImage imageNamed:@"btn_detailtab_comment_highlight"] forState:UIControlStateHighlighted];
        [_button_comment setBackgroundImage:[UIImage imageNamed:@"btn_detailtab_comment_normal"] forState:UIControlStateNormal];
        [_button_comment setBackgroundImage:[UIImage imageNamed:@"btn_detailtab_comment_selected"] forState:UIControlStateSelected];
        [_button_comment setAdjustsImageWhenHighlighted:NO];
        [headerView addSubview:_button_comment];
        
        
        //相关锦囊按纽:
        _button_relation = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _button_relation.frame = CGRectMake(kRelationButtonOriginX, kRelationButtonOriginY, kRelationButtonSizeWidth, kRelationButtonSizeHeight);
        [_button_relation setBackgroundImage:[UIImage imageNamed:@"btn_detailtab_relation_highlight"] forState:UIControlStateHighlighted];
        [_button_relation setBackgroundImage:[UIImage imageNamed:@"btn_detailtab_relation_normal"] forState:UIControlStateNormal];
        [_button_relation setBackgroundImage:[UIImage imageNamed:@"btn_detailtab_relation_selected"] forState:UIControlStateSelected];
        [_button_relation addTarget:self action:@selector(clickRelationButton:) forControlEvents:UIControlEventTouchUpInside];
        [_button_relation setAdjustsImageWhenHighlighted:NO];
        [headerView addSubview:_button_relation];
        
        
        //下载/暂停/阅读按纽:
        _button_fuction = [UIButton buttonWithType:UIButtonTypeCustom];
        _button_fuction.frame = CGRectMake(kDownloadButtonOriginX, kDownloadButtonOriginY, kDownloadButtonSizeWidth, kDownloadButtonSizeHeight);
        [_button_fuction setBackgroundColor:[UIColor clearColor]];
        _button_fuction.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [_button_fuction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button_fuction addTarget:self action:@selector(clickFuctionButton:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:_button_fuction];
        [self setButtonStateByGuideState];  //根据锦囊的状态设置button的title
        
        
        
        
        //判断各个按钮的状态:
        switch (_state_tableView)
        {
            case Guide_about:
            {
                [_button_about setSelected:YES];
                [_button_comment setSelected:NO];
                [_button_relation setSelected:NO];
            }
                break;
            case Guide_comment:
            {
                [_button_comment setSelected:YES];
                [_button_about setSelected:NO];
                [_button_relation setSelected:NO];
            }
                break;
            case Guide_related:
            {
                [_button_relation setSelected:YES];
                [_button_about setSelected:NO];
                [_button_comment setSelected:NO];
            }
                break;
            default:
                break;
        }
        
        return headerView;
    }
    return nil;
}
-(void)setButtonStateByGuideState
{
    NSLog(@"  self.guide.guide_state : %d",self.guide.guide_state);
    
    self.guide.download_type = nil;
    
    if(self.guide.guide_state == GuideNoamal_State)
    {
        [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_detail_download"] forState:UIControlStateNormal];
    }
    else if(self.guide.guide_state == GuideWating_State)
    {
        [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_detail_cancel"] forState:UIControlStateNormal];
    }
    else if(self.guide.guide_state == GuideDownloading_State)
    {
        [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_detail_cancel"] forState:UIControlStateNormal];
    }
    else if(self.guide.guide_state == GuideRead_State)
    {
        [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_detail_open"] forState:UIControlStateNormal];
    }
    else if(self.guide.guide_state == GuideDownloadFailed_State)
    {
        [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_detail_download"] forState:UIControlStateNormal];
    }
    else
    {
        [_button_fuction setBackgroundImage:[UIImage imageNamed:@"btn_detail_download"] forState:UIControlStateNormal];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return GuideCoverImageviewHeight;
    }
    else
    {
        switch (_state_tableView)
        {
            case Guide_about:
            {
                if(indexPath.row == 0) //锦囊简介的高度
                {
                    return [GuideDetailCell cellHeightWithContent:self.guide.guideBriefinfo];
                }
                else if(indexPath.row == 1) //锦囊作者简介的高度
                {
                    return [GuideAuthorDetailCell cellHeightWithContent:self.guide.guideAuthor_intro];
                }
            }
            case Guide_comment:  //锦囊评论
            {
                if(indexPath.row == 0)
                {
                    return 45;  //添加点评
                }
                //                else if(indexPath.row == 1)
                //                {
                //                    return 35;
                //                }
                else
                {
                    float height = [GuideCommentCell cellHeightWithContent:[(QYGuideComment *)[_array_guideComment objectAtIndex:indexPath.row-1] str_content]];
                    return height;
                }
            }
            case Guide_related: //相关锦囊
            {
                if(indexPath.row == _array_relatedGuide.count) //空行
                {
                    return 8;
                }
                else if(_array_relatedGuide.count-1 == indexPath.row)
                {
                    return 240/2 + 2;
                }
                return 240/2;
            }
            default:
                break;
        }
    }
    return 0.;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    else
    {
        switch (_state_tableView)
        {
            case Guide_about:   //锦囊简介和作者简介
            {
                return 2;
            }
            case Guide_comment: //锦囊评论
            {
                if(_array_guideComment.count > 0)
                {
                    return _array_guideComment.count+1; //'+1'的原因是做了一个添加评论按钮
                }
                
                return 1;
            }
            case Guide_related: //相关锦囊
            {
                return _array_relatedGuide.count+1;     //'+1'的原因是做了一个空行
            }
            default:
                break;
        }
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) //锦囊封面大图
    {
        cell_guideCover = [tableView dequeueReusableCellWithIdentifier:@"GuideCoverCell"];
        if(!cell_guideCover)
        {
            cell_guideCover = [[GuideCoverCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuideCoverCell"];
        }
        cell_guideCover.selectionStyle = UITableViewCellSelectionStyleNone;
        cell_guideCover.delegate = self;
        [cell_guideCover initCellWithGuide:self.guide finished:^(UIImage *image){
        } failed:^{
        }];
        return cell_guideCover;
    }
    else
    {
        switch (_state_tableView)
        {
            case Guide_about:
            {
                if(indexPath.row == 0) //锦囊简介
                {
                    GuideDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideDetailCell"];
                    if(cell == nil)
                    {
                        cell = [[[GuideDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuideDetailCell"] autorelease];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    [cell initCellWithGuideDetailInfo:self.guide];
                    
                    return cell;
                }
                else //作者简介
                {
                    GuideAuthorDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideAuthorDetailCell"];
                    if(cell == nil)
                    {
                        cell = [[[GuideAuthorDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuideAuthorDetailCell"] autorelease];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    [cell initCellWithGuideAuthorInfo:self.guide];
                    
                    return cell;
                }
            }
            case Guide_comment:
            {
                if(indexPath.row == 0) //添加评论
                {
                    AddGuideCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCommentCell"];
                    if(cell == nil)
                    {
                        cell = [[[AddGuideCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddCommentCell"] autorelease];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    cell.contentView.backgroundColor = [UIColor clearColor];
                    return cell;
                }
                //                else if(indexPath.row == 1) //点评的title
                //                {
                //                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titlecell"];
                //                    if(cell == nil)
                //                    {
                //                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"titlecell"] autorelease];
                //                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                //                        cell.backgroundColor = [UIColor clearColor];
                //                    }
                //
                //                    if([cell.contentView viewWithTag:11911])
                //                    {
                //                        [[cell.contentView viewWithTag:11911] removeFromSuperview];
                //                    }
                //                    if([cell.contentView viewWithTag:11912])
                //                    {
                //                        [[cell.contentView viewWithTag:11912] removeFromSuperview];
                //                    }
                //
                //                    UIImageView *imageView_titleBackground = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 0, 320-7.5*2, 35)];
                //                    imageView_titleBackground.tag = 11911;
                //                    imageView_titleBackground.backgroundColor = [UIColor clearColor];
                //                    imageView_titleBackground.image = [UIImage imageNamed:@"详情页_列表title.png"];
                //                    [cell.contentView addSubview:imageView_titleBackground];
                //                    [imageView_titleBackground release];
                //                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 1, 100, 30)];
                //                    label.backgroundColor = [UIColor clearColor];
                //                    label.text = @"点评";
                //                    label.tag = 11912;
                //                    [cell.contentView addSubview:label];
                //                    [label release];
                //
                //                    return cell;
                //                }
                else //锦囊的评论列表
                {
                    GuideCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideCommentCell"];
                    if(cell == nil)
                    {
                        cell = [[[GuideCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuideCommentCell"] autorelease];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    [cell initCellWithArray:_array_guideComment atPosition:indexPath.row-1];
                    
                    return cell;
                }
            }
            case Guide_related: //关联锦囊
            {
                if(indexPath.row == [_array_relatedGuide count])
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"spacecell"];
                    if(cell == nil)
                    {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"spacecell"] autorelease];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.backgroundColor = [UIColor clearColor];
                    }
                    
                    return cell;
                }
                else
                {
                    GuideViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideRelatedCell"];
                    if(cell == nil)
                    {
                        cell = [[[GuideViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuideRelatedCell"] autorelease];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    cell.delegate = self;
                    [cell resetCell];
                    [self initGuideDetailCell:cell andIndexPath:indexPath];
                    
                    return cell;
                }
            }
            default:
                return nil;
        }
    }
}
-(void)initGuideDetailCell:(GuideViewCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    cell.position_section = indexPath.section;
    cell.position_row = indexPath.row;
    [cell initCellWithArray:_array_relatedGuide atPosition:indexPath.row];
}




#pragma mark -
#pragma mark --- UITableView - Delagate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_state_tableView == Guide_comment && indexPath.section == 1 && indexPath.row == 0) //添加评论
    {
        [self addGuideComment];
    }
    
    return nil;
}


#pragma mark -
#pragma mark --- 添加锦囊的评论
-(void)addGuideComment
{
    _flag_notLoginWhenCommentGuide = NO;
    
    // 未登录:
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
    {
        _flag_notLoginWhenCommentGuide = YES;
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:Nil
                                  message:@"您需要登录才可以点评锦囊"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  otherButtonTitles:@"现在登录",nil];
        alertView.tag = 792;
        alertView.delegate = self;
        [alertView show];
        [alertView release];
    }
    else
    {
        [self showCommentGuideVC];
    }
}
-(void)showCommentGuideVC
{
    CommentGuideViewController *commentGuideVC = [[CommentGuideViewController alloc] init];
    commentGuideVC.str_title = @"添加评论";
    commentGuideVC.str_guideId = self.guide.guideId;
    [self presentViewController:commentGuideVC animated:YES completion:nil];
    [commentGuideVC release];
}



#pragma mark -
#pragma mark --- 获取锦囊的点评
-(void)getGuideCommentByGuideId
{
    NSLog(@" ------getGuideCommentByGuideId");
    
    if(!_array_guideComment)
    {
        _array_guideComment = [[NSMutableArray alloc] init];
        _maxId = 0;
    }
    else if([_array_guideComment count] == 0)
    {
        _maxId = 0;
    }
    
    
    NSInteger guide_id = [self.guide.guideId intValue];
    [[QYGuideComment sharedQYGuideComment] getCommentListByGuideId:guide_id
                                                             count:CommentNumberOneTimeGet
                                                             maxId:_maxId
                                                           success:^(NSArray *array){
                                                               NSLog(@"获取锦囊的评论成功");
                                                               [self loadView_afterGetData:array];
                                                           }
                                                           failure:^{
                                                               NSLog(@"获取锦囊的评论失败");
                                                               [self loadView_afterGetDataFailed];
                                                           }];
}
-(void)loadView_afterGetData:(NSArray *)array
{
    _flag_downloadNewDataFlag = 0;
    
    //锦囊没有评论:
    if((!array || array.count == 0) && _array_guideComment.count == 0)
    {
        UIImageView *imageview_footerview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
        imageview_footerview.backgroundColor = [UIColor clearColor];
        imageview_footerview.image = [UIImage imageNamed:@"bg_comment_default"];
        _tableview_guideDetail.tableFooterView = imageview_footerview;
        [imageview_footerview release];
    }
    
    else
    {
        if(array.count < CommentNumberOneTimeGet)
        {
            _flag_downloadNewDataFlag = 1;
            
            [self resetTableFooterView:2];
        }
        [self countGuideCommentHeight:array];
        [_array_guideComment addObjectsFromArray:array];
        _maxId = [[(QYGuideComment *)[_array_guideComment lastObject] str_commentId] intValue]-1;
        [_tableview_guideDetail reloadData];
        
        [(UILabel *)[_footView viewWithTag:19191] setText:@"获取更多评论"];
        [_activityView stopAnimating];
    }
}
-(void)loadView_afterGetDataFailed
{
    //锦囊没有评论:
    if(!_array_guideComment || _array_guideComment.count == 0)
    {
        UIImageView *imageview_footerview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
        imageview_footerview.backgroundColor = [UIColor clearColor];
        imageview_footerview.image = [UIImage imageNamed:@"bg_comment_default"];
        _tableview_guideDetail.tableFooterView = imageview_footerview;
        [imageview_footerview release];
    }
    
    else
    {
        [(UILabel *)[_footView viewWithTag:19191] setText:@"获取更多评论"];
        [_activityView stopAnimating];
        
        [self.view hideToast];
        [self.view makeToast:@"获取评论失败" duration:1 position:@"center" isShadow:NO];
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
    NSLog(@"查看锦囊详情 ----------- ");
    
    
    //记录cell的位置 [当从详情页返回时刷新cell]:
    _position_section_tapCell = cell.position_section;
    _position_row_tapCell = cell.position_row;
    
    GuideDetailViewController *guideDetailVC = [[GuideDetailViewController alloc] init];
    guideDetailVC.flag_new = self.flag_new;
    guideDetailVC.where_from = @"guide";
    guideDetailVC.guideId = [[_array_relatedGuide objectAtIndex:_position_row_tapCell] guideId];
    guideDetailVC.guide = [_array_relatedGuide objectAtIndex:_position_row_tapCell];
    [self.navigationController pushViewController:guideDetailVC animated:YES];
    [guideDetailVC release];
}
-(void)guideViewCellSelectedReadGuide:(GuideViewCell *)cell
{
    NSLog(@"阅读锦囊 ---------- ");
    
    
    //记录cell的位置 [当需要更新本本锦囊的关联锦囊时]:
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
    
    
    
    if(flag == 1)
    {
        NSLog(@" 提示需要进行更新 ");
    }
    else
    {
        NSLog(@" 不需要更新");
    }
    
    
    
    if(flag == 1) //提示需要进行更新
    {
        if(_guideName_needUpdate && _guideName_needUpdate.retainCount > 0)
        {
            [_guideName_needUpdate release];
        }
        _guideName_needUpdate = [cell.guide.guideName retain];
        
        
        QYGuide *guide_needUpdated = [QYGuideData getGuideById:cell.guide.guideId];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"本锦囊有更新，更新内容："
                                                            message:guide_needUpdated.guideUpdate_log
                                                           delegate:self
                                                  cancelButtonTitle:@"忽略"
                                                  otherButtonTitles:@"立即更新", nil];
        alertView.tag = 791;
        [alertView show];
        [alertView release];
    }
    else
    {
        [self readGuide_ralated:cell];
    }
}
-(void)readGuide_ralated:(GuideViewCell *)cell
{
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    self.view.userInteractionEnabled = NO;
    
    
    
    [self.view makeToastActivity];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //解压缩zip包:
        [FileDecompression decompressionFileWithFileName:[[_array_relatedGuide objectAtIndex:cell.position_row] guideName] success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view hideToastActivity];
                self.view.userInteractionEnabled = YES;
                [self performSelector:@selector(changeDelayFlag) withObject:nil afterDelay:1];
                
                if(![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,[[_array_relatedGuide objectAtIndex:cell.position_row] guideName]]])
                {
                    CatalogViewController *catelogVC = [[CatalogViewController alloc] init];
                    catelogVC.str_guideName = [[_array_relatedGuide objectAtIndex:cell.position_row] guideName];
                    catelogVC.guide = [_array_relatedGuide objectAtIndex:cell.position_row];
                    catelogVC.flag_isShowGuideCover = 1;
                    [self.navigationController pushViewController:catelogVC animated:YES];
                    [catelogVC release];
                }
                else
                {
                    NSMutableArray *catlogArray = (NSMutableArray *)[GuideMenuData getMenuJsonWithGuideName:[[_array_relatedGuide objectAtIndex:cell.position_row] guideName]];
                    
                    if(catlogArray && [catlogArray isKindOfClass:[NSArray class]])
                    {
                        ReadViewController *readVC = [[ReadViewController alloc] init];
                        readVC.str_guideName = [[_array_relatedGuide objectAtIndex:cell.position_row] guideName];
                        readVC.guide = [_array_relatedGuide objectAtIndex:cell.position_row];
                        readVC.array_catalog = catlogArray;
                        readVC.selectIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,readVC.str_guideName]] intValue];
                        readVC.flag_isShowGuideCover = 1;
                        [self.navigationController pushViewController:readVC animated:YES];
                        [readVC release];
                    }
                    else
                    {
                        NSLog(@" 文件已损坏 ~~~");
                        [self.view hideToast];
                        [self.view makeToast:@"文件损坏，需要您重新下载。" duration:1.5 position:@"center" isShadow:NO];
                        [FileDamaged processDamagedFileWithFileName:[[_array_relatedGuide objectAtIndex:cell.position_row] guideName]];
                    }
                }
                
            });
            
            
        } failed:^{
            
            self.view.userInteractionEnabled = YES;
        }];
    });
    
}
-(void)updateCellAtIndepath:(NSIndexPath *)indexpath
{
    [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
}



#pragma mark -
#pragma mark --- 阅读未进行更新的锦囊
-(void)readNeedUpdatedGuide
{
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    self.view.userInteractionEnabled = NO;
    
    
    [self.view makeToastActivity];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //解压缩zip包:
        [FileDecompression decompressionFileWithFileName:[self.guide guideName] success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view hideToastActivity];
                self.view.userInteractionEnabled = YES;
                [self performSelector:@selector(changeDelayFlag) withObject:nil afterDelay:1];
                
                
                if(![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",TheNumberOfPagesReadStr,self.guide.guideName]])
                {
                    CatalogViewController *catelogVC = [[CatalogViewController alloc] init];
                    catelogVC.str_guideName = self.guide.guideName;
                    catelogVC.guide = self.guide;
                    catelogVC.flag_isShowGuideCover = 1;
                    [self.navigationController pushViewController:catelogVC animated:YES];
                    [catelogVC release];
                }
                else
                {
                    NSMutableArray *catlogArray = (NSMutableArray *)[GuideMenuData getMenuJsonWithGuideName:self.guide.guideName];
                    
                    if(catlogArray && [catlogArray isKindOfClass:[NSArray class]])
                    {
                        ReadViewController *readVC = [[ReadViewController alloc] init];
                        readVC.str_guideName = self.guide.guideName;
                        readVC.guide = self.guide;
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
                        [FileDamaged processDamagedFileWithFileName:self.guide.guideName];
                    }
                }
                
            });
            
            
        } failed:^{
            
            self.view.userInteractionEnabled = YES;
        }];
    });
}
-(void)readNeedUpdatedGuide_related  //相关锦囊
{
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    self.view.userInteractionEnabled = NO;
    
    
    [self.view makeToastActivity];
    
    QYGuide *guide = [QYGuideData getGuideByName:_guideName_needUpdate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //解压缩zip包:
        [FileDecompression decompressionFileWithFileName:_guideName_needUpdate success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view hideToastActivity];
                self.view.userInteractionEnabled = YES;
                [self performSelector:@selector(changeDelayFlag) withObject:nil afterDelay:1];
                
                
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
            
            self.view.userInteractionEnabled = YES;
        }];
    });
    
}




#pragma mark -
#pragma mark --- UIAlertView - Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 12)     //3g环境下载锦囊
    {
        if(buttonIndex == 0)    //允许本次下载
        {
            NSLog(@" 允许本次下载");
            
            if([[DownloadData sharedDownloadData] requestListDic].count == 0)
            {
                self.guide.guide_state = GuideDownloading_State;
            }
            else
            {
                self.guide.guide_state = GuideWating_State;
            }
            [self startDownload];
            
            [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
            return;
        }
        else if(buttonIndex == 1) //始终允许移动网络下载
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WIFISwitch"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@" 始终允许移动网络下载");
            
            
            if([[DownloadData sharedDownloadData] requestListDic].count == 0)
            {
                self.guide.guide_state = GuideDownloading_State;
            }
            else
            {
                self.guide.guide_state = GuideWating_State;
            }
            [self startDownload];
            
            [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if(buttonIndex == 2) //暂停下载
        {
            NSLog(@" 暂停下载");
            return;
        }
    }
    
    else
    {
        if(buttonIndex == [alertView cancelButtonIndex])
        {
            if(alertView.tag == 789)
            {
                NSLog(@"取消更新锦囊,继续阅读!");
                [self readNeedUpdatedGuide];
            }
            else if(alertView.tag == 791)
            {
                NSLog(@"取消更新锦囊,继续阅读!");
                [self readNeedUpdatedGuide_related];
            }
            
            return;
        }
        
        else
        {
            if(alertView.tag == 788)
            {
                NSLog(@"下载时未登录");
                
                CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
                UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
                navigationController.navigationBarHidden = YES;
                [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:navigationController animated:YES completion:nil];
                [cityLoginVC release];
            }
            
            else if(alertView.tag == 789)
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
            
            else if(alertView.tag == 791)
            {
                NSLog(@"更新本本锦囊的关联锦囊");
                
                [self beginUpdateRelatedGuide];
            }
            
            else if(alertView.tag == 792)
            {
                NSLog(@"点评锦囊之前先登录");
                
                CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
                UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
                navigationController.navigationBarHidden = YES;
                [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:navigationController animated:YES completion:nil];
                [cityLoginVC release];
            }
        }
    }
}




#pragma mark -
#pragma mark --- 更新本本锦囊的关联锦囊
-(void)beginUpdateRelatedGuide
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
    [self beginUpdateRelated_Guide];
    
    
    //    //*** 未登录:
    //    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
    //    {
    //        [[NSUserDefaults standardUserDefaults] setObject:_guideName_needUpdate forKey:@"notlogininwhenupdate_detail"];
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
    //        [self beginUpdateRelated_Guide];
    //    }
    
}
-(void)beginUpdateRelated_Guide
{
    //*** 首先将原先已下载的锦囊保存到另外一个目录下,以防更新失败后原先下的锦囊也阅读不了。
    [FilePath moveDownloadedGuideToAnotherPathWithGuideName:_guideName_needUpdate];
    
    
    //*** 刷新cell:
    GuideViewCell *cell = (GuideViewCell *)[_tableview_guideDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_position_row_tapCell inSection:_position_section_tapCell]];
    cell.guide.guide_state = GuideNoamal_State;
    QYGuide *guide = [cell.guide retain];
    [cell initCellWithArray:[NSArray arrayWithObject:guide] atPosition:_position_row_tapCell];
    [guide release];
    
    
    //*** 下载:
    [cell button_selected:nil];
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
    //        [[NSUserDefaults standardUserDefaults] setObject:self.guide.guideName forKey:@"notlogininwhenupdate_detail"];
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
    self.guide.download_type = @"update";
    
    //*** 首先更新tableview的cell:
    [self refreshCell];
    
    //*** 开始下载更新锦囊:
    [self reloadGuide];
}
-(void)refreshCell
{
    QYGuide *guide_needUpdated = [QYGuideData getGuideById:self.guide.guideId];
    guide_needUpdated.guide_state = GuideNoamal_State;
    self.guide = guide_needUpdated;
    
    
    //[_tableview_guideDetail reloadData];
    [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)reloadGuide
{
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view  hideToast];
        [self.view  makeToast:@"貌似网络有点不好，检查一下吧..." duration:1 position:@"center" isShadow:NO];
        
        return;
    }
    else if (self.flag_new == NO) //详情页目前显示的还是缓存数据
    {
        [self.view  hideToast];
        [self.view  makeToast:@"貌似网络有点不好，检查一下吧..." duration:1 position:@"center" isShadow:NO];
        
        return;
    }
    else if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN)
    {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"WIFISwitch"] boolValue] == NO) //3g环境下允许下载
        {
            NSLog(@" 3g环境下允许下载 ");
        }
        else //仅允许wifi环境下下载:
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:nil
                                      message:@"当前处于移动网络，已为您暂停了所有下载"
                                      delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"允许本次下载", @"始终允许移动网络下载", @"暂停下载", nil];
            alertView.tag = 12;
            alertView.delegate = self;
            [alertView show];
            [alertView release];
            
            return;
        }
    }
    
    
    
    
    
    //*** 首先将原先已下载的锦囊保存到另外一个目录下,以防更新失败后原先下的锦囊也阅读不了。
    [FilePath moveDownloadedGuideToAnotherPathWithGuideName:self.guide.guideName];
    
    
    self.guide.guide_state = GuideWating_State;
    [self startDownload];
}



#pragma mark -
#pragma mark --- 登录成功 & 登录失败
-(void)loginIn_Success
{
    //下载:
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"download_notlogin_detailVC"] isEqualToString:@"1"])
    {
        
        if([[DownloadData sharedDownloadData] requestListDic].count == 0)
        {
            self.guide.guide_state = GuideDownloading_State;
        }
        else
        {
            self.guide.guide_state = GuideWating_State;
        }
        [self startDownload];
        [_tableview_guideDetail reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"download_notlogin_detailVC"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"download_notlogin"] isEqualToString:@"1"])
    {
        NSString *guideName_whenNotLoginin = [[NSUserDefaults standardUserDefaults] objectForKey:@"guideName_notlogininwhendownload"];
        NSInteger section = [[[NSUserDefaults standardUserDefaults] objectForKey:@"section_notlogininwhendownload"] intValue];
        NSInteger row = [[[NSUserDefaults standardUserDefaults] objectForKey:@"row_notlogininwhendownload"] intValue];
        
        
        NSLog(@" guideName_whenNotLoginin : %@",guideName_whenNotLoginin);
        NSLog(@" section : %d",section);
        NSLog(@" row : %d",row);
        GuideViewCell *cell = (GuideViewCell *)[_tableview_guideDetail cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        
        
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
    else if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_detail"] && self.guide.guideName && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_detail"] isEqualToString:self.guide.guideName])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_detail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSelector:@selector(beginUpdateGuide_now) withObject:nil afterDelay:0.2];
    }
    else if(_flag_notLoginWhenCommentGuide) //点评锦囊的时候还未登录
    {
        [self performSelector:@selector(showCommentGuideVC) withObject:nil afterDelay:0.2];
    }
}
-(void)loginIn_Failed
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_detail"] && self.guide.guideName && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_detail"] isEqualToString:self.guide.guideName])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_detail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}



#pragma mark -
#pragma mark --- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( _state_tableView == Guide_comment && _flag_isDownloadAllData == 0 && self.flag_downloadNewDataFlag == 0 && _tableview_guideDetail.contentOffset.y+_tableview_guideDetail.frame.size.height - _tableview_guideDetail.contentSize.height >= 20)
    {
        //NSLog(@"再去网上加载数据 ^ ^ ");
        self.flag_downloadNewDataFlag = 1;
        
        [self resetTableFooterViewTitle];
        
        [self performSelector:@selector(getGuideCommentByGuideId) withObject:nil afterDelay:0.1];
    }
}



#pragma mark -
#pragma mark --- 评论锦囊成功 刷新数据
-(void)commentGuide_success:(NSNotification *)notfification
{
    self.flag_downloadNewDataFlag = 1;
    _maxId = 0;
    
    //重新获取锦囊的点评:
    [_array_guideComment removeAllObjects];
    [self performSelector:@selector(getGuideCommentByGuideId) withObject:nil afterDelay:0];
}


#pragma mark -
#pragma mark --- 文件损坏
-(void)fileDamaged:(NSNotification *)notfification
{
    NSDictionary *info_dic = [notfification userInfo];
    if(info_dic && [info_dic objectForKey:@"guidename"])
    {
        NSLog(@"  guideDetailVC_损坏的是: %@",[info_dic objectForKey:@"guidename"]);
        [_tableview_guideDetail reloadData];
    }
}



#pragma mark -
#pragma mark --- clickShareButton
-(void)clickShareButton:(id)sender
{
    [self initActionSheetView];
}
-(void)initActionSheetView
{
    BOOL flag = [[QyerSns sharedQyerSns] getIsWeixinInstalled];
    NSString *versonStr = [[QyerSns sharedQyerSns] getWeixinVerson];
    BOOL SMSFlag = [[QyerSns sharedQyerSns] isCanSendSMS];
    
    if (SMSFlag)
    {
        if(flag == 1 && iPhone5)
        {
            MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",@"短信", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo", @"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
            actionSheet.delegate = self;
            
            [actionSheet show];
            [actionSheet release];
        }
        else
        {
            if(flag == 0 || [versonStr floatValue] - 1.1 < 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"腾讯微博",@"邮件", @"短信", nil] imageArray:[NSArray arrayWithObjects: @"btn_actionsheet_weibo",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
            else if(flag == 1 && [versonStr floatValue] - 1.1 >= 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",@"短信",  nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo",@"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
        }
    }
    else
    {
        if(flag == 1 && iPhone5)
        {
            MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo", @"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
            actionSheet.delegate = self;
            
            [actionSheet show];
            [actionSheet release];
        }
        else
        {
            if(flag == 0 || [versonStr floatValue] - 1.1 < 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"腾讯微博",@"邮件", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
            else if(flag == 1 && [versonStr floatValue]  - 1.1 >= 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",  nil] imageArray:[NSArray arrayWithObjects: @"btn_actionsheet_weibo", @"btn_actionsheet_weixin",@"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
                actionSheet.delegate = self;
                
                [actionSheet show];
                [actionSheet release];
            }
        }
    }
}



#pragma mark -
#pragma mark --- MYActionSheet - Delegate
-(void)cancelButtonDidClick:(MYActionSheet *)actionSheet
{
    
}
-(void)actionSheetButtonDidClickWithType:(NSString*)type
{
    if([type isEqualToString:@"邮件"])
    {
        [self shareToMail];
    }
    if([type isEqualToString:@"短信"])
    {
        [self sendmessage];
    }
    else if([type isEqualToString:@"新浪微博"])
    {
        [self shareToSinaWeibo];
    }
    else if([type isEqualToString:@"微信"])
    {
        [self shareToWeixinFriend];
    }
    else if([type isEqualToString:@"微信朋友圈"])
    {
        [self shareToWeixinFriendCircle];
    }
    else if([type isEqualToString:@"腾讯微博"])
    {
        [self shareToTencentWeibo];
    }
}



#pragma mark -
#pragma mark --- 分享
-(void)shareToMail
{
    [[QyerSns sharedQyerSns] shareToMailWithMailTitle:[NSString stringWithFormat:@"Hi~我在穷游网的#穷游APP#里下载了【%@】锦囊",self.guide.guideName] andMailInfo:[NSString stringWithFormat:@"\tHi~\n\t我在穷游网的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！加上穷游APP里其它的功能和内容，森森赶脚出境游有这么一个APP就够了。好东西要分享，快去下一个吧！\n\n\tp.s.目前穷游APP有iPhone、Android和iPad版本，扫描二维码即可轻松下载\n\n\t http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang",self.guide.guideName] andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)sendmessage
{
    [[QyerSns sharedQyerSns] shareWithShortMessage:[NSString stringWithFormat:@"我在穷游网的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！出境游还是要用穷游APP，你也下一个备着吧！http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang", self.guide.guideName] inViewController:self];
}

-(void)shareToWeixinFriend
{
    [[QyerSns sharedQyerSns] shareToWeixinWithAPPTitle:@"穷游APP" andDescription:[NSString stringWithFormat:@"我在穷游网的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！出境游还是要用穷游APP，你也下一个备着吧！", self.guide.guideName]  andImage:[UIImage imageNamed:@"120icon"] andUrl:@"http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang"];
}

-(void)shareToWeixinFriendCircle
{
    [[QyerSns sharedQyerSns] shareToWeixinFriendCircleWithAPPTitle:[NSString stringWithFormat:@"我在穷游网的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！出境游还是要用穷游APP，你也下一个备着吧！", self.guide.guideName] andDescription:@"" andImage:[UIImage imageNamed:@"120icon"] andUrl:@"http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang"];
}

-(void)shareToSinaWeibo
{
    [[QyerSns sharedQyerSns] shareToSinaWeiboWithTitle:@"分享到新浪微博" andText:[NSString stringWithFormat:@"我在@穷游网 的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！出境游还是要用穷游APP，你也下一个备着吧！http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang", self.guide.guideName] andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)shareToTencentWeibo
{
    [[QyerSns sharedQyerSns] shareToTencentWeiboWithText:[NSString stringWithFormat:@"我在@穷游网 的#穷游APP#里下载了【%@】锦囊，里面的内容有趣又实用！出境游还是要用穷游APP，你也下一个备着吧！http://app.qyer.com/guide/?campaign=app_share_qy&category=iPhone_jinnang", self.guide.guideName] andImage:[UIImage imageNamed:@"iphone_sina_sns"] andDelegate:self];
}


#pragma mark -
#pragma mark --- clickBackButton
-(void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if(_flag_isRefresh == 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pop_from_guidedetail" object:nil userInfo:nil];
    }
    
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
#pragma mark --- 取消了所有的请求
-(void)guide_download_failed:(NSNotification *)notifition
{
    if(self.guide.guide_state == GuideDownloading_State)
    {
        if(self.guide.download_type && [self.guide.download_type isEqualToString:@"update"])
        {
            self.guide.guide_state = GuideRead_State;
        }
        else
        {
            self.guide.guide_state = GuideNoamal_State;
        }
        //self.guide.guide_state = GuideNoamal_State;
    }
    
    [_tableview_guideDetail reloadData];
}




#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
