//
//  AllGuideViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "AllGuideViewController.h"
#import "CategoryCell.h"
#import "QYGuideCategoryData.h"
#import "Toast+UIView.h"
#import "QYGuideData.h"
#import "ChangeTableviewContentInset.h"
#import "GuideCell.h"
#import "FUCKButton.h"
#import "QYGuideCategory.h"
#import "SortStringWithChinese.h"
#import "GuideDetailViewController.h"
#import "OceaniaCell.h"
#import "Reachability.h"




#define     positionY_tableView         (ios7 ? (20+44) : 44)
#define     height_leftRow              108/2
#define     height_headView             (ios7 ? (20+44) : 44)





@interface AllGuideViewController ()

@end





@implementation AllGuideViewController
@synthesize currentVC;

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
    QY_MUTABLERECEPTACLE_RELEASE(_array_allGuideCategory);
    QY_MUTABLERECEPTACLE_RELEASE(_array_allGuide);
    QY_MUTABLERECEPTACLE_RELEASE(_array_country);
    QY_MUTABLERECEPTACLE_RELEASE(_dic_guide);
    
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_scrollView_background);
    QY_VIEW_RELEASE(_tableView_GuideVC);
    QY_VIEW_RELEASE(_tableView_category);
    
    QY_SAFE_RELEASE(_currentVC);
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
        
        
        newFrame = _tableView_GuideVC.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableView_GuideVC.frame = newFrame;
        
    }
    else
    {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = [UIScreen mainScreen].bounds.size.height-20;
        self.view.frame = newFrame;
        
        
        newFrame = _tableView_GuideVC.frame;
        newFrame.size.height = [self.view bounds].size.height;
        _tableView_GuideVC.frame = newFrame;
        
    }
}





#pragma mark -
#pragma mark --- viewDidAppear  &  viewDidDisappear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@" viewDidAppear  --------------------  AllGuideVC");
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"hotdot_phone"] isEqualToString:@"1"])
    {
        [self resetRootViewWIthType:YES];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(do_timeout) object:nil];
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeDelayFlag) object:nil];
}

-(void)getData
{
    NSLog(@"  allguideVC  getdata ");
    
    if([[QYGuideData sharedQYGuideData] flag_getAllNew] == YES) //已经getall最新的锦囊
    {
        NSLog(@"  已经getall ");
        
        
        if(!_array_allGuide)
        {
            _array_allGuide = [[NSMutableArray alloc] init];
            [_array_allGuide addObjectsFromArray:[QYGuideData getAllGuide]];
            
            //发消息,获取服务器的数据成功
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showtoolbar" object:nil userInfo:nil];
            
            
            //从锦囊里获取锦囊所属的目录
            [self initCategoryData:_array_allGuide];
            _flag_freshData = NO;
            [self reloadData];
        }
        else
        {
            [_array_allGuide removeAllObjects];
            [_array_allGuide addObjectsFromArray:[QYGuideData getAllGuide]];
            
            
            //发消息,获取服务器的数据成功
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showtoolbar" object:nil userInfo:nil];
            
            
            //从锦囊里获取锦囊所属的目录
            [self initCategoryData:_array_allGuide];
            _flag_freshData = NO;
            [self reloadData];
            
        }
        
    }
    else
    {
        if(!_array_allGuide || _array_allGuide.count == 0)
        {
            NSLog(@"  还未成功getall , 还没有缓存数据");
            
            _selectedButtont_state = 0;
            [self.view makeToastActivity];
            
            [self initGuideData];   //获取锦囊数据(包含缓存 和 服务器数据)
        }
        else if(_array_allGuide && _array_allGuide.count > 0)
        {
            NSLog(@"  还未成功getall , 已有缓存数据");
            
            [self.view hideToastActivity];
            
            [_tableView_GuideVC reloadData];
            [self initGuideDataFromServe];   //从服务器获取数据
        }
    }
}
-(void)cancleGetGuideData
{
    NSLog(@"取消获取锦囊数据");
    [QYGuideData cancleGetGuideData];
}



//请求超时:
-(void)do_timeout
{
    _flag_timeout = YES;
    NSLog(@" ------------------------------ do_timeout : %d",_getData_status);
    
    
    //取消获取锦囊数据:
    [QYGuideData cancleGetGuideData];
    
    
    
    switch (_getData_status)
    {
        case 0:  //获取数据超
        {
            NSLog(@" 10秒超时的时候,既没有缓存数据,也没有从服务器获取到数据");
            
            if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"firstGuideData"] isEqualToString:@"1"]) //首次请求,请求失败
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"firstrequestfailed" object:nil userInfo:nil];
                [self.view hideToastActivity];
            }
            else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"firstGuideData"] isEqualToString:@"1"]) //非首次请求,请求失败
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"requestfailed" object:nil userInfo:nil];
                [self.view hideToastActivity];
            }
        }
            break;
        case 1:  //缓存数据
            
            NSLog(@" 10秒超时的时候,有缓存数据");
            
            break;
        case 2:  //服务器数据
            
            NSLog(@" 10秒超时的时候,有服务器数据");
            
            break;
            
        default:
            break;
    }
}



-(void)initCategoryData:(NSArray *)array
{
    if(!_array_allGuideCategory)
    {
        _array_allGuideCategory = [[NSMutableArray alloc] init];
    }
    [_array_allGuideCategory removeAllObjects];
    
    
    
    for(QYGuide *guide in array)
    {
        NSString *category = guide.guideCategory_name;
        NSLog(@"  guideCategory_name （1） : %@",category);
        NSString *category_id = guide.guideCategory_id;
        NSString *str = [NSString stringWithFormat:@"%@__%@",category_id,category];
        if([_array_allGuideCategory indexOfObject:str] >= _array_allGuideCategory.count)
        {
            [_array_allGuideCategory addObject:str];
        }
        NSLog(@"  guideCategory_name （2）: %@",category);
        NSLog(@"  guideName          : %@",guide.guideName);
    }
    
    
    
    NSArray *array_sort = [[_array_allGuideCategory sortedArrayUsingComparator:^(NSString *obj1, NSString *obj2){
        
        BOOL result = [obj1 compare:obj2];
        if(result < 0)
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        else if(result > 0)
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }] retain];
    NSLog(@" array_sort.count : %d",array_sort.count);
    NSLog(@" array_sort : %@",array_sort);
    
    
    
    [_array_allGuideCategory removeAllObjects];
    NSString *i = @"__";
    for(NSString *str in array_sort)
    {
        NSRange range = [str rangeOfString:i];
        str = [str substringFromIndex:range.location+i.length];
        if(str && ![str isEqualToString:@"专题锦囊"])
        {
            [_array_allGuideCategory addObject:str];
        }
        else
        {
            NSLog(@" 00000000000000000000000000000000000000000");
            NSLog(@" 00000000000000000000000000000000000000000");
            NSLog(@" str : %@",str);
            NSLog(@" 00000000000000000000000000000000000000000");
            NSLog(@" 00000000000000000000000000000000000000000");
        }
    }
    NSLog(@"  guideCategory_name : %@",_array_allGuideCategory);
    [array_sort release];
}


//获取锦囊数据:
-(void)initGuideDataFromServe
{
    NSLog(@" ========= 请求数据(服务器)");
    
    
    _flag_timeout = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(do_timeout) object:nil];
    [self performSelector:@selector(do_timeout) withObject:nil afterDelay:10];
    
    
    [QYGuideData fromV4_getAllGuideIncludeCache:NO
                                        success:^(NSArray *array,BOOL isCache){
                                            if(_flag_timeout)
                                            {
                                                NSLog(@" 已经超时了亲～ ,不再做任何处理");
                                            }
                                            
                                            else
                                            {
                                                NSLog(@" initGuideDataFromServe 成功!");
                                                
                                                
                                                NSLog(@"  已成功获取服务器数据 ");
                                                NSLog(@"  已成功获取服务器数据 ");
                                                NSLog(@"  已成功获取服务器数据 ");
                                                NSLog(@"  已成功获取服务器数据 ");
                                                NSLog(@"  已成功获取服务器数据 ");
                                                if(!_array_allGuide)
                                                {
                                                    _array_allGuide = [[NSMutableArray alloc] init];
                                                }
                                                for(QYGuide *guide in _array_allGuide)
                                                {
                                                    if(guide.guide_state == GuideWating_State)
                                                    {
                                                        NSLog(@" GuideWating_State : %@",guide.guideName);
                                                        
                                                        QYGuide *guide_ = [QYGuideData getGuideById:guide.guideId];
                                                        guide_.guide_state = GuideWating_State;
                                                        [self updateDownloadingGuideWithGuide:guide_];
                                                    }
                                                    else if(guide.guide_state == GuideDownloading_State)
                                                    {
                                                        NSLog(@" GuideDownloading_State : %@",guide.guideName);
                                                        
                                                        QYGuide *guide_ = [QYGuideData getGuideById:guide.guideId];
                                                        guide_.guide_state = GuideDownloading_State;
                                                        guide_.progressValue = guide.progressValue;
                                                        [self updateDownloadingGuideWithGuide:guide_];
                                                    }
                                                    else if(guide.guide_state == GuideDownloadFailed_State)
                                                    {
                                                        NSLog(@" GuideDownloadFailed_State : %@",guide.guideName);
                                                        
                                                        QYGuide *guide_ = [QYGuideData getGuideById:guide.guideId];
                                                        guide_.guide_state = GuideDownloadFailed_State;
                                                    }
                                                    else if(guide.guide_state == GuideRead_State)
                                                    {
                                                        NSLog(@" GuideRead_State : %@",guide.guideName);
                                                        
                                                        QYGuide *guide_ = [QYGuideData getGuideById:guide.guideId];
                                                        guide_.guide_state = GuideRead_State;
                                                    }
                                                }
                                                [_array_allGuide removeAllObjects];
                                                [_array_allGuide addObjectsFromArray:array];
                                                
                                                
                                                
                                                
                                                
                                                
                                                //从锦囊里获取锦囊所属的目录
                                                [self initCategoryData:_array_allGuide];
                                                
                                                _flag_freshData = YES;
                                                [self reloadData];
                                                if(!isCache) //不是缓存数据
                                                {
                                                    NSLog(@"  不是缓存 ");
                                                    _getData_status = 2; //服务器数据
                                                    
                                                }
                                            }
                                            
                                        } failed:^{
                                            if(_flag_timeout)
                                            {
                                                NSLog(@" 已经超时了亲～,不再做任何处理");
                                            }
                                            
                                            else
                                            {
                                                NSLog(@" initGuideDataFromServe 失败!");
                                                
                                                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"firstGuideData"] isEqualToString:@"1"]) //非首次请求,请求失败
                                                {
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"requestfailed" object:nil userInfo:nil];
                                                    [self.view hideToastActivity];
                                                }
                                            }
                                        }];
}


-(void)updateDownloadingGuideWithGuide:(QYGuide *)guide_
{
    
    NSArray *array = [QYGuideData getDownloadingGuide];
    NSLog(@" ------ begin array.count : %d",array.count);
    
    NSMutableArray *array_tmp = [[NSMutableArray alloc] init];
    if(array)
    {
        for(QYGuide *guide in array)
        {
            if([guide.guideName isEqualToString:guide_.guideName])
            {
                NSLog(@"  guide.guideName  : %@",guide.guideName);
            }
            else
            {
                [array_tmp addObject:guide_];
            }
        }
    }
    
    
    NSLog(@" ------ end array.count : %d",array_tmp.count);
    [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] removeAllObjects];
    [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] addObjectsFromArray:array_tmp];
    
    [array_tmp removeAllObjects];
    [array_tmp release];
}






//获取锦囊数据:
-(void)initGuideData
{
    NSLog(@" ========= 请求数据(缓存 和  服务器)");
    
    
    _flag_timeout = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(do_timeout) object:nil];
    [self performSelector:@selector(do_timeout) withObject:nil afterDelay:10];
    
    
    //'YES'表示首先会获取缓存数据:
    _flag_freshData = NO;
    [QYGuideData fromV4_getAllGuideIncludeCache:YES
                                        success:^(NSArray *array,BOOL isCache){
                                            
                                            if(_flag_timeout)
                                            {
                                                NSLog(@" 已经超时了亲～ ,不再做任何处理");
                                            }
                                            
                                            else
                                            {
                                                if(array && array.count > 0)
                                                {
                                                    //取消定时的方法:
                                                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(do_timeout) object:nil];
                                                    
                                                    if(!isCache) //不是缓存数据
                                                    {
                                                        NSLog(@"  服务器数据 ");
                                                        
                                                        
                                                        _flag_freshData = YES;
                                                        
                                                        
                                                        if(!_array_allGuide)
                                                        {
                                                            _array_allGuide = [[NSMutableArray alloc] init];
                                                        }
                                                        for(QYGuide *guide in _array_allGuide)
                                                        {
                                                            if(guide.guide_state == GuideWating_State)
                                                            {
                                                                QYGuide *guide_ = [QYGuideData getGuideById:guide.guideId];
                                                                guide_.guide_state = GuideWating_State;
                                                            }
                                                            else if(guide.guide_state == GuideDownloading_State)
                                                            {
                                                                QYGuide *guide_ = [QYGuideData getGuideById:guide.guideId];
                                                                guide_.guide_state = GuideDownloading_State;
                                                                guide_.progressValue = guide.progressValue;
                                                            }
                                                            else if(guide.guide_state == GuideDownloadFailed_State)
                                                            {
                                                                QYGuide *guide_ = [QYGuideData getGuideById:guide.guideId];
                                                                guide_.guide_state = GuideDownloadFailed_State;
                                                            }
                                                            else if(guide.guide_state == GuideRead_State)
                                                            {
                                                                QYGuide *guide_ = [QYGuideData getGuideById:guide.guideId];
                                                                guide_.guide_state = GuideRead_State;
                                                            }
                                                        }
                                                        [_array_allGuide removeAllObjects];
                                                        [_array_allGuide addObjectsFromArray:array];
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        //从锦囊里获取锦囊所属的目录:
                                                        [self initCategoryData:_array_allGuide];
                                                        
                                                        NSLog(@"  initTableView －－－－－ 1");
                                                        if(!_getData_status) //没有缓存数据
                                                        {
                                                            _getData_status = 2; //服务器数据
                                                            [self initTableView];
                                                        }
                                                        else if (_getData_status == 1) //已有缓存数据
                                                        {
                                                            _getData_status = 2; //服务器数据
                                                            [_tableView_GuideVC reloadData];
                                                        }
                                                        
                                                    }
                                                    else
                                                    {
                                                        NSLog(@"  缓存数据 ");
                                                        
                                                        
                                                        if(!_array_allGuide)
                                                        {
                                                            _array_allGuide = [[NSMutableArray alloc] init];
                                                        }
                                                        [_array_allGuide removeAllObjects];
                                                        [_array_allGuide addObjectsFromArray:array];
                                                        
                                                        //从锦囊里获取锦囊所属的目录:
                                                        [self initCategoryData:_array_allGuide];
                                                        _getData_status = 1;  //缓存数据
                                                        
                                                        
                                                        [self initTableView];
                                                        
                                                    }
                                                }
                                            }
                                            
                                        } failed:^{
                                            if(_flag_timeout)
                                            {
                                                NSLog(@" 已经超时了亲～,不再做任何处理");
                                            }
                                            
                                            else
                                            {
                                                NSLog(@" initGuideData 失败!");
                                                
                                                //取消定时的方法:
                                                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(do_timeout) object:nil];
                                                
                                                
                                                if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"firstGuideData"] isEqualToString:@"1"]) //首次请求,请求失败
                                                {
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"firstrequestfailed" object:nil userInfo:nil];
                                                    [self.view hideToastActivity];
                                                }
                                                else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"firstGuideData"] isEqualToString:@"1"]) //非首次请求,请求失败
                                                {
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"requestfailed" object:nil userInfo:nil];
                                                    [self.view hideToastActivity];
                                                }
                                            }
                                        }];
    
}



-(void)initTableView //初始化数据(缓存或服务器数据)
{
    if(_array_allGuide && _array_allGuide.count > 0 && _array_allGuideCategory && _array_allGuideCategory.count > 0)
    {
        [self.view hideToastActivity];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showtoolbar" object:nil userInfo:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstGuideData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self initTableView_Category];
        [self initTableView_guide];
    }
}
-(void)reloadData  //刷新数据(服务器数据)
{
    if(_array_allGuide && _array_allGuide.count > 0 && _array_allGuideCategory && _array_allGuideCategory.count > 0)
    {
        NSLog(@" guideViewController  刷新数据(服务器数据)");
        [self.view hideToastActivity];
        [self initTableView_Category];
        [self initTableView_guide];
    }
}



-(void)initTableView_Category
{
    if(!_tableView_category)
    {
        _tableView_category = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 142/2, [self.view bounds].size.height) style:UITableViewStylePlain];
//        if(ios7)
//        {
//            _tableView_category = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 142/2, [self.view bounds].size.height) style:UITableViewStylePlain];
//        }
//        else
//        {
//            _tableView_category = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 142/2, ([self.view bounds].size.height-20)) style:UITableViewStylePlain];
//        }
        _tableView_category.backgroundColor = [UIColor colorWithRed:232/255. green:242/255. blue:249/255. alpha:1];
        
        
        //左侧表格下拉时候，头部右侧的竖线
        UIImageView *rightLineImageViewTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"place_line"]];
        rightLineImageViewTop.frame = CGRectMake(_tableView_category.frame.size.width-1, -200, 1, 200);
        rightLineImageViewTop.backgroundColor = [UIColor clearColor];
        [_tableView_category addSubview:rightLineImageViewTop];
        [rightLineImageViewTop release];
        
        
        //左侧表格下拉时候，底部右侧的竖线
        UIImageView *rightLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_tableView_category.frame.size.width-1, height_leftRow*[_array_allGuideCategory count], 1, 200)];
        rightLineImageView.backgroundColor = [UIColor clearColor];
        rightLineImageView.image = [UIImage imageNamed:@"place_line"];
        rightLineImageView.tag = 1000;
        [_tableView_category addSubview:rightLineImageView];
        [rightLineImageView release];
        
    }
    
    [ChangeTableviewContentInset changeTableView:_tableView_category withOffSet:height_offset_tableView];
    [self.view addSubview:_tableView_category];
    _tableView_category.separatorColor = [UIColor clearColor];
    _tableView_category.dataSource = self;
    _tableView_category.delegate = self;
    _tableView_category.tag = 322;
    _tableView_category.showsVerticalScrollIndicator = NO;
    [_tableView_category reloadData];
}

-(void)initTableView_guide
{
    if(!_tableView_GuideVC)
    {
        _tableView_GuideVC = [[UITableView alloc] initWithFrame:CGRectMake(_tableView_category.frame.size.width, 0, 320-_tableView_category.frame.size.width, [self.view bounds].size.height) style:UITableViewStylePlain];
        _tableView_GuideVC.backgroundColor = [UIColor whiteColor];
        _tableView_GuideVC.separatorColor = [UIColor clearColor];
        _tableView_GuideVC.dataSource = self;
        _tableView_GuideVC.delegate = self;
        _tableView_GuideVC.tag = 321;
        [ChangeTableviewContentInset changeTableView:_tableView_GuideVC withOffSet:height_offset_tableView];
//        if(ios7)
//        {
//            _tableView_GuideVC = [[UITableView alloc] initWithFrame:CGRectMake(_tableView_category.frame.size.width, 0, 320-_tableView_category.frame.size.width, [self.view bounds].size.height) style:UITableViewStylePlain];
//            _tableView_GuideVC.backgroundColor = [UIColor whiteColor];
//            _tableView_GuideVC.separatorColor = [UIColor clearColor];
//            _tableView_GuideVC.dataSource = self;
//            _tableView_GuideVC.delegate = self;
//            _tableView_GuideVC.tag = 321;
//            [ChangeTableviewContentInset changeTableView:_tableView_GuideVC withOffSet:height_offset_tableView];
//        }
//        else
//        {
//            _tableView_GuideVC = [[UITableView alloc] initWithFrame:CGRectMake(_tableView_category.frame.size.width, 0, 320-_tableView_category.frame.size.width, ([self.view bounds].size.height-20)) style:UITableViewStylePlain];
//            _tableView_GuideVC.backgroundColor = [UIColor whiteColor];
//            _tableView_GuideVC.separatorColor = [UIColor clearColor];
//            _tableView_GuideVC.dataSource = self;
//            _tableView_GuideVC.delegate = self;
//            _tableView_GuideVC.tag = 321;
//            [ChangeTableviewContentInset changeTableView:_tableView_GuideVC withOffSet:height_offset_tableView];
//        }
        [self.view insertSubview:_tableView_GuideVC belowSubview:_tableView_category];
        
        NSLog(@" contentOffset : %@",NSStringFromCGPoint(_tableView_GuideVC.contentOffset));
        
        //获取数据成功后的初始状态:
        NSLog(@"  _selectedButtont_state : %d",_selectedButtont_state);
        [self tableView:_tableView_category didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedButtont_state inSection:0]];
    }
    else
    {
        NSLog(@" contentOffset : %@",NSStringFromCGPoint(_tableView_GuideVC.contentOffset));
        CGPoint point = _tableView_GuideVC.contentOffset;
        
        _tableView_GuideVC.frame = CGRectMake(_tableView_category.frame.size.width, 0, 320-_tableView_category.frame.size.width, [self.view bounds].size.height);
//        if(ios7)
//        {
//            _tableView_GuideVC.frame = CGRectMake(_tableView_category.frame.size.width, 0, 320-_tableView_category.frame.size.width, [self.view bounds].size.height);
//        }
//        else
//        {
//            _tableView_GuideVC.frame = CGRectMake(_tableView_category.frame.size.width, 0, 320-_tableView_category.frame.size.width, ([self.view bounds].size.height-20));
//        }
        
        
        //获取数据成功后的当前状态:
        [self tableView:_tableView_category didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedButtont_state inSection:0]];
        [_tableView_GuideVC setContentOffset:point];
    }
    [_tableView_GuideVC reloadData];
}

-(void)selectDataWithCategory:(NSString *)continentName
{
    NSLog(@"  大洲名称 : %@",continentName);
    
    if(!_array_country)
    {
        _array_country = [[NSMutableArray alloc] init];
    }
    [_array_country removeAllObjects];
    if(!_dic_guide)
    {
        _dic_guide = [[NSMutableDictionary alloc] init];
    }
    [_dic_guide removeAllObjects];
    
    
    
    //获取已下载的锦囊:
    [QYGuideData replaceGuideStateWithDownloadedGuide:_array_allGuide];
    
    
    
    for (int i = 0; i < _array_allGuide.count; i++)
    {
        QYGuide *guide = [_array_allGuide objectAtIndex:i];
        if(guide && continentName && [continentName isEqualToString:guide.guideCategory_name] && [_array_country containsObject:[guide guideCountry_name_cn]] == NO)
        {
            [_array_country addObject:[[_array_allGuide objectAtIndex:i] guideCountry_name_cn]];
            [_dic_guide setValue:[NSMutableArray arrayWithObject:guide] forKey:guide.guideCountry_name_cn];
        }
        else if(guide)
        {
            NSMutableArray *array = [_dic_guide valueForKey:guide.guideCountry_name_cn];
            [array insertObject:guide atIndex:0];
        }
    }
    
    
    
    
    //    //*** 以拼音升序对国家名进行排序:
    //    SortStringWithChinese *chineseSort = [[SortStringWithChinese alloc] initWithArray:_array_country];
    //    [_array_country removeAllObjects];
    //    [_array_country addObjectsFromArray:[chineseSort getSortArray]];
    //    [chineseSort release];
    
    
    
    NSMutableArray *array_tmp = [[NSMutableArray alloc] init];
    for(NSString *country_name in _array_country)
    {
        NSArray *array = [_dic_guide objectForKey:country_name];
        [array_tmp addObject:[NSString stringWithFormat:@"%d___%@",array.count,country_name]];
    }
    
    
    //根据锦囊本数的多少进行排序(by_方便面 2014/04/17):
    NSArray *array_sort = [[array_tmp sortedArrayUsingComparator:^(NSString *obj1, NSString *obj2){
        
        //BOOL result = [obj1 compare:obj2];
        BOOL result = [obj1 intValue] - [obj2 intValue];
        if(result > 0)
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        else if(result <= 0)
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }] retain];
    
    
    [_array_country removeAllObjects];
    for(NSString *str in array_sort)
    {
        NSRange range = [str rangeOfString:@"___"];
        str = [str substringFromIndex:range.location+range.length];
        [_array_country addObject:str];
    }
    
    
    
    [array_sort release];
    [array_tmp removeAllObjects];
    [array_tmp release];
    
    
    if(!_flag_freshData) //如果不是刷新数据，则将tableview的位移移到最上端。
    {
        _tableView_GuideVC.scrollEnabled = NO;
        UIImage *image = [UIImage imageNamed:@"allGuide"];
        [_tableView_GuideVC setContentOffset:CGPointMake(0, -(positionY_tableView+positionY_button_guideVC+image.size.height+positionY_button_guideVC)) animated:NO];
        _tableView_GuideVC.scrollEnabled = YES;
    }
    else
    {
        NSLog(@" 获取到服务器数据后，重新刷新~~~~~~");
    }
    _flag_freshData = NO;
    
    
    [_tableView_GuideVC reloadData];
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





#pragma mark -
#pragma mark --- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView.tag == 322)
    {
        return 1;
    }
    
    return [_array_country count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == 322) //左侧大洲列表
    {
        return [_array_allGuideCategory count];
    }
    
    
    NSArray *array = [_dic_guide objectForKey:[_array_country objectAtIndex:section]];
    NSInteger count = array.count;
    if(count % 2 == 0)
    {
        return count/2;
    }
    else
    {
        return count/2 + 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView.tag == 322)
    {
        return 0;
    }
    
    
    return 52/2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 322)
    {
        return height_leftRow;
    }
    
    NSArray *array = [_dic_guide objectForKey:[_array_country objectAtIndex:indexPath.section]];
    if((array.count-1)/2 != indexPath.row)
    {
        return 330/2+7;
    }
    else if((array.count-1)/2 == indexPath.row && (_array_country.count-1) == indexPath.section) //最后一行
    {
        return 330/2+7;
    }
    
    return 330/2;
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView.tag == 322)
    {
        return nil;
    }
    
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 52/2)];
    UIImageView *imageView_backGround = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, customView.frame.size.width, customView.frame.size.height)];
    imageView_backGround.backgroundColor = [UIColor whiteColor];
    imageView_backGround.alpha = 0.96;
    [customView addSubview:imageView_backGround];
    
    float positionY = 7;
    float height = (ios7 ? 13 : 20);
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, positionY, imageView_backGround.frame.size.width-10*2, height)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.text = [_array_country objectAtIndex:section];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor colorWithRed:130/255. green:153/255. blue:165/255. alpha:1];
    headerLabel.adjustsFontSizeToFitWidth = YES;
    headerLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:14];
    [customView addSubview:headerLabel];
    [headerLabel release];
    
    [imageView_backGround release];
    return [customView autorelease];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 322)
    {
        OceaniaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categroyCell"];
        if(cell == nil)
        {
            cell = [[[OceaniaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"categroyCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSString *category = [_array_allGuideCategory objectAtIndex:indexPath.row];
        NSLog(@" ---------------- %@",category);
        cell.label_name.text = category;
        
        return cell;
    }
    
    
    GuideCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuideCell"];
    if(cell == nil)
    {
        cell = [[[GuideCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuideCell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.delegate = self;
    [self initGuideCell:cell andIndexPath:indexPath];
    
    return cell;
}
-(void)initGuideCell:(GuideCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [_dic_guide objectForKey:[_array_country objectAtIndex:indexPath.section]];
    [cell initWithData:array atIndexPath:indexPath];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 322)
    {
        NSIndexPath *old_indexPath = [NSIndexPath indexPathForRow:_selectedButtont_state inSection:0];
        OceaniaCell *old_cell = (OceaniaCell *)[tableView cellForRowAtIndexPath:old_indexPath];
        old_cell.imageView_select.hidden = YES;
        [old_cell setReselectedState];
        
        
        _selectedButtont_state = indexPath.row;
        OceaniaCell *cell = (OceaniaCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell setSelectedState];
        cell.imageView_select.hidden = NO;
//        NSString *selectOceania = cell.label_name.text;
//        [self selectDataWithCategory:selectOceania];
        [self selectDataWithCategory:[_array_allGuideCategory objectAtIndex:indexPath.row]];
    }
}



#pragma mark -
#pragma mark --- GuideCell - Delegate
-(void)clickAtIndexPath:(NSIndexPath *)indexPath
{
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    [self performSelector:@selector(changeDelayFlag) withObject:nil afterDelay:0.5];
    
    
    NSString *sectionName = [_array_country objectAtIndex:indexPath.section];
    if(sectionName)
    {
        NSArray *array_guide = [_dic_guide objectForKey:sectionName];
        if(array_guide && array_guide.count > indexPath.row)
        {
            GuideDetailViewController *guideDetailVC = [[GuideDetailViewController alloc] init];
            guideDetailVC.flag_new = _getData_status;
            guideDetailVC.where_from = @"guide";
            guideDetailVC.guideId = [[array_guide objectAtIndex:indexPath.row] guideId];
            [guideDetailVC setGuide:[array_guide objectAtIndex:indexPath.row]];
            [self performSelector:@selector(push:) withObject:guideDetailVC afterDelay:0.1];
        }
    }
}
-(void)push:(GuideDetailViewController *)guideDetailVC
{
    [self.currentVC.navigationController pushViewController:guideDetailVC animated:YES];
    [guideDetailVC release];
}
-(void)changeDelayFlag
{
    _flag_delay = NO;
}



#pragma mark -
#pragma mark --- pop_from_guidedetail
-(void)pop_from_guidedetail:(NSNotification *)notfification
{
    //若在详情页有锦囊下载则刷新cell的状态:
    [_tableView_GuideVC reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_position_row_tapCell inSection:_position_section_tapCell]] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark -
#pragma mark --- reloadTableView
-(void)reloadTableView
{
    [_tableView_GuideVC reloadData];
}


#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end



