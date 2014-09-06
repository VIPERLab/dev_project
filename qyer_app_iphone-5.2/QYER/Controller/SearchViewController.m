//
//  SearchViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-6.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "SearchViewController.h"
#import "QYGuideData.h"
#import "GuideViewCell.h"
#import "GuideDetailViewController.h"
#import "CatalogViewController.h"
#import "ReadViewController.h"
#import "GuideMenuData.h"
#import "GuideMenu.h"
#import "CityLoginViewController.h"
#import "Reachability.h"
#import "Toast+UIView.h"
#import "ChangeTableviewContentInset.h"
#import "CityCell.h"
#import "FileDamaged.h"
#import "PlaceSearchCityCell.h"
#import "UIImageView+WebCache.h"
#import "MobClick.h"
#import "PlaceSearchData.h"
#import "LoadMoreView.h"
#import "PlaceSearchModel.h"
#import "FileDecompression.h"


#import "CountryViewController.h"
#import "PoiDetailViewController.h"



//#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (6+20) : 6)
#define     positionY_tableView         (ios7 ? (44+20) : 44)
#define     positionY_canclebutton      (ios7 ? (6+20) : 6)
#define     positionY_searchBar         (ios7 ? (22) : 3)




@interface SearchViewController ()

@end





@implementation SearchViewController

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
    QY_VIEW_RELEASE(_searchBar);
    QY_VIEW_RELEASE(_label_default);
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_tableView_searchVC);
    
    [_searchText release];
    _searchText = nil;
    
    [_loadMoreView removeFromSuperview];
    [_loadMoreView release];
    _loadMoreView = nil;
    
    QY_MUTABLERECEPTACLE_RELEASE(_array_result);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}




#pragma mark -
#pragma mark --- view - WillAppear & Appear & Disappear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Success) name:@"logininsuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginIn_Failed) name:@"logininfailed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDamaged:) name:@"FileDamaged" object:nil];
    
    
    if(!_array_result || _array_result.count == 0)
    {
        [_searchBar becomeFirstResponder];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.isFromPlace)
    {
        [MobClick beginLogPageView:@"目的地搜索"];
    }
    else
    {
        [MobClick beginLogPageView:@"锦囊搜索"];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (ios7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if(self.isFromPlace)
    {
        [MobClick endLogPageView:@"目的地搜索"];
    }
    else
    {
        [MobClick endLogPageView:@"锦囊搜索"];
    }
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
    [self setNavigationBar];
    [self initDefaultLabel];
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
    //headView.backgroundColor = [UIColor colorWithRed:10/255. green:10/255. blue:10/255. alpha:0.8];
    _headView.image = [UIImage imageNamed:@"搜索头bg"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    //*** 搜索框:
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, positionY_searchBar, 264, 40)];
    //_searchBar.barStyle = UIBarStyleBlackTranslucent;
    _searchBar.tintColor = [UIColor clearColor];
    _searchBar.backgroundColor = [UIColor clearColor];
    //********** Mod By ZhangDong 2014.3.27 Start *********
//    _searchBar.placeholder = !self.isFromPlace ? @" 搜索锦囊" : @" 搜索国家、城市、旅行地";
    //********** Mod By ZhangDong 2014.3.27 End *********
    _searchBar.delegate = self;
    [_headView addSubview:_searchBar];
    _searchBar.tintColor = [UIColor colorWithRed:150/255. green:150/255. blue:150/255. alpha:1];
    
    _searchBar.backgroundImage = [UIImage imageNamed:@"搜索头bg"];
    
    for (UIView *subview in _searchBar.subviews)
    {
        if(ios7)
        {
            for (id thing in subview.subviews)
            {
                if ([thing isKindOfClass:NSClassFromString(@"UISearchBarTextField")])
                {
                    [thing setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"搜索框"]]];
                    
                    break;
                }
            }
        }
        else
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField")])
            {
                //[subview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"搜索框"]]];
                break;
            }
        }
    }
    
    
    
    
    
    
    
    
    //*** 取消按钮:
    UIButton *button_cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    button_cancel.frame = CGRectMake(268, positionY_canclebutton, 48, 33);
    [button_cancel setBackgroundColor:[UIColor clearColor]];
    [button_cancel setBackgroundImage:[UIImage imageNamed:@"搜索Cancle.png"] forState:UIControlStateNormal];
    [button_cancel addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:button_cancel];
    
}
-(void)initDefaultLabel
{
    if(_tableView_searchVC)
    {
        //**************** Mod By ZhangDong 2014.4.9 Start **************
        [_tableView_searchVC removeFromSuperview];
        [_tableView_searchVC release];
        _tableView_searchVC = nil;
        //**************** Mod By ZhangDong 2014.4.9 End **************
    }
    
    //********** Mod By ZhangDong 2014.3.27 Start *********
    if(!_label_default)
    {
        _label_default = [[UILabel alloc] initWithFrame:CGRectMake(0, (ios7 ? 100 : 80), 320, 30)];
        _label_default.backgroundColor = [UIColor clearColor];
        _label_default.textColor = [UIColor grayColor];
        _label_default.textAlignment = NSTextAlignmentCenter;
        _label_default.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:16];
        [self.view addSubview:_label_default];
    }
    _label_default.text = !self.isFromPlace ? @"请输入国家或锦囊名称的中/英文" : @"请输入国家、城市、旅行地的中/英文";
    //********** Mod By ZhangDong 2014.3.27 End *********
    _label_default.alpha = 1;
}
-(void)initFailedLabel
{
    if(_tableView_searchVC)
    {
        //**************** Mod By ZhangDong 2014.4.9 Start **************
        [_tableView_searchVC removeFromSuperview];
        [_tableView_searchVC release];
        _tableView_searchVC = nil;
        //**************** Mod By ZhangDong 2014.4.9 End **************
    }
    if (_noResultImageView) {
        _noResultImageView.alpha = 0;
    }
    
    //********** Mod By ZhangDong 2014.3.27 Start *********
    _label_default.alpha = 1;
    _label_default.text = !self.isFromPlace ? @"没有找到相关锦囊" : @"没有找到相关国家、城市、旅行地";
    
//    [self.view addSubview:_label_default];
    //********** Mod By ZhangDong 2014.3.27 End *********
}
-(void)initTableView
{
    if(_label_default)
    {
        //**************** Mod By ZhangDong 2014.4.9 Start **************
        _label_default.alpha = 0;
        //**************** Mod By ZhangDong 2014.4.9 End **************
    }
    if (_noResultImageView) {
        _noResultImageView.alpha = 0;
    }
    
    //**************** Mod By ZhangDong 2014.4.9 Start **************
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    
    if (_tableView_searchVC) {
        [_tableView_searchVC removeFromSuperview];
        [_tableView_searchVC release];
        _tableView_searchVC = nil;
    }
    _tableView_searchVC = [[UITableView alloc] initWithFrame:CGRectMake(0, -2, UIWidth, (ios7 ? height : height - 20)) style:UITableViewStylePlain];
    
    _tableView_searchVC.backgroundColor = [UIColor clearColor];
    
    _tableView_searchVC.separatorColor = [UIColor clearColor];
    _tableView_searchVC.dataSource = self;
    _tableView_searchVC.delegate = self;
    
    [ChangeTableviewContentInset changeWithTableView:_tableView_searchVC];
    [self.view addSubview:_tableView_searchVC];
    [self.view bringSubviewToFront:_headView];
    [_tableView_searchVC reloadData];
    
    
    if (self.isFromPlace)
    {
        //加载更多
        if (!_loadMoreView) {
            _loadMoreView = [[LoadMoreView alloc] initWithFrame:CGRectMake(0, 0, UIWidth, 40)];
            _loadMoreView.backgroundColor = [UIColor clearColor];
            _tableView_searchVC.tableFooterView = _loadMoreView;
        }
    }
    else
    {
        _tableView_searchVC.tableFooterView = nil;
    }
    //**************** Mod By ZhangDong 2014.4.9 End **************
}

//**************** Mod By ZhangDong 2014.4.10 Start **************
/**
 *  目的地搜索没有结果的时候，显示的图片视图
 */
- (void)initNoResultImageView
{
    if(_tableView_searchVC)
    {
        _tableView_searchVC.alpha = 0;
    }
    if(_label_default)
    {
        _label_default.alpha = 0;
    }

    if (!_noResultImageView) {
        _noResultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 150, 320, 150)];
        _noResultImageView.image = [UIImage imageNamed:@"place_searchNoResult.png"];
        [self.view addSubview:_noResultImageView];
    }
    _noResultImageView.alpha = 1;
}
//**************** Mod By ZhangDong 2014.4.10 End **************

#pragma mark -
#pragma mark --- UISearchBar - Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(!searchText || searchText.length == 0 || [searchText isEqualToString:@""])
    {
        if(_array_result)
        {
            [_array_result removeAllObjects];
        }
        [self initDefaultLabel];
        return;
    }
    
    
    //********** Mod By ZhangDong 2014.3.27 Start *********
    if (self.isFromPlace) {
        if (isNotReachable) {
             [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
            return;
        }
        _page = 1;
        
        [self.view performSelector:@selector(makeToastActivity) withObject:nil afterDelay:0];
        
        _searchText = [searchText retain];
        [PlaceSearchData searchDataByText:searchText page:_page success:^(NSArray *array) {
            
            [self loadView_afterGetData:array];
            [self.view hideToastActivity];
            //********** Mod By ZhangDong 2014.4.9 Start *********
            if (array.count < [reqNumber integerValue]) {
                _loadMoreView.hidden = YES;
            }else{
                _loadMoreView.hidden = NO;
            }
            if ([array count] == 0) {
                [self initNoResultImageView];
            }
            
            //********** Mod By ZhangDong 2014.4.9 End *********
        } failed:^{
            [self initFailedLabel];
            [self.view performSelector:@selector(hideToastActivity) withObject:nil afterDelay:0];
        }];
    }else{
        [QYGuideData searchGuideWithString:searchText finished:^(NSArray *array){
            [self loadView_afterGetData:array];
            
            //********** Mod By ZhangDong 2014.4.9 Start *********
            if ([array count] == 0) {
                [self initNoResultImageView];
            }
            
            //********** Mod By ZhangDong 2014.4.9 End *********
        } failed:^{
            [self initFailedLabel];
        }];
    }
    //********** Mod By ZhangDong 2014.3.27 End *********
}
-(void)loadView_afterGetData:(NSArray *)array
{
    if(!array)
    {
        return;
    }
    else
    {
        if(!_array_result)
        {
            _array_result = [[NSMutableArray alloc] init];
        }
        [_array_result removeAllObjects];
        [_array_result addObjectsFromArray:array];
        
        [self initTableView];
    }
}

//********** Mod By ZhangDong 2014.4.3 Start *********
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
//********** Mod By ZhangDong 2014.4.3 End *********


#pragma mark -
#pragma mark --- UITableView - DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array_result count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isFromPlace)
    {
        return 76;
    }
    else
    {
        if(indexPath.row == _array_result.count - 1)
        {
            return 240/2 + 1;
        }
        return 240/2;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //********** Mod By ZhangDong 2014.3.27 Start *********
    
    if (self.isFromPlace) {
        static NSString *cellString = @"placeSearchCityCell";
        PlaceSearchCityCell *placeSearchCityCell = [tableView dequeueReusableCellWithIdentifier:cellString];
        if (!placeSearchCityCell) {
            placeSearchCityCell = [[[PlaceSearchCityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString] autorelease];
            placeSearchCityCell.selectionStyle = UITableViewCellSelectionStyleNone;
            placeSearchCityCell.delegate = self;
        }
        placeSearchCityCell.indexPath = indexPath;
        placeSearchCityCell.bottomShadowImageView.alpha = (indexPath.row == _array_result.count - 1);
        if ([_array_result count] > indexPath.row) {
            PlaceSearchModel *model = _array_result[indexPath.row];
            [placeSearchCityCell configData:model];
        }
        return placeSearchCityCell;
    }
    //********** Mod By ZhangDong 2014.3.27 End *********
    
    GuideViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil)
    {
        cell = [[[GuideViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
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
    
    [cell initCellWithArray:_array_result atPosition:indexPath.row];
}

//********** Mod By ZhangDong 2014.4.3 Start *********
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isFromPlace) {
        
        PlaceSearchModel *model = _array_result[indexPath.row];
        switch ([model.type integerValue]) {
            case PlaceSearchTypePOI:
            {
                PoiDetailViewController *poiDetailVc = [[PoiDetailViewController alloc]init];
                poiDetailVc.poiId = [model.modelId intValue];
                [self.navigationController pushViewController:poiDetailVc animated:YES];
                [poiDetailVc release];
                
                break;
            }
            case PlaceSearchTypeCity:
            {
                CountryViewController *countryVc = [[CountryViewController alloc]init];
                countryVc.type = 2;
                countryVc.key = model.modelId;
                [self.navigationController pushViewController:countryVc animated:YES];
                [countryVc release];
                
                break;
            }
            case PlaceSearchTypeCountry:
            {
                
                CountryViewController *countryVc = [[CountryViewController alloc]init];
                countryVc.type = 1;
                countryVc.key = model.modelId;
                [self.navigationController pushViewController:countryVc animated:YES];
                [countryVc release];
                
                break;
            }
        }
    }
}

//********** Mod By ZhangDong 2014.4.3 End *********

#pragma mark -
#pragma mark --- GuideViewCell - Delegate
-(void)guideViewCellCancleDownload:(GuideViewCell *)cell
{
    [[[QYGuideData sharedQYGuideData] array_guideIsDownloading] removeObject:cell.guide];
}
-(void)guideViewCellSelectedDetail:(GuideViewCell *)cell
{
    NSLog(@"查看锦囊详情");
    
    [_searchBar resignFirstResponder];
    
    //记录cell的位置 [当从详情页返回时刷新cell]:
    _position_section_tapCell = cell.position_section;
    _position_row_tapCell = cell.position_row;
    
    GuideDetailViewController *guideDetailVC = [[GuideDetailViewController alloc] init];
    guideDetailVC.flag_new = YES;
    guideDetailVC.where_from = @"guide";
    guideDetailVC.guideId = [[_array_result objectAtIndex:cell.position_row] guideId];
    guideDetailVC.guide = [_array_result objectAtIndex:cell.position_row];
    [self.navigationController pushViewController:guideDetailVC animated:YES];
    [guideDetailVC release];
    
}
-(void)guideViewCellSelectedReadGuide:(GuideViewCell *)cell
{
    NSLog(@"阅读锦囊");
    
    [_searchBar resignFirstResponder];
    
    
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
    if(_flag_delay)
    {
        return;
    }
    _flag_delay = YES;
    self.view.userInteractionEnabled = NO;
    
    
    
    [self.view makeToastActivity];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //解压缩zip包:
        [FileDecompression decompressionFileWithFileName:[cell.guide guideName] success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view hideToastActivity];
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
                        NSLog(@" 文件已损坏 ~~~");
                        
                        [self.view hideToast];
                        [self.view makeToast:@"文件损坏，需要您重新下载。" duration:1.5 position:@"center" isShadow:NO];
                        [FileDamaged processDamagedFileWithFileName:[cell.guide guideName]];
                    }
                }
                
            });
            
        } failed:^{
            
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
    
    
    
    [self.view makeToastActivity];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //解压缩zip包:
        [FileDecompression decompressionFileWithFileName:_guideName_needUpdate success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view hideToastActivity];
                self.view.userInteractionEnabled = YES;
                [self performSelector:@selector(changeDelayFlag) withObject:nil afterDelay:1];
                
                
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
-(void)updateCellAtIndepath:(NSIndexPath *)indexpath
{
    [_tableView_searchVC reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)changeDelayFlag
{
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
        [self.view makeToast:@"貌似网络有点不好，检查一下吧..." duration:1 position:@"center" isShadow:NO];
        
        [self loginIn_Failed];
        
        return;
    }
    
    
    
    
    //更新时不提示需要登录(小柳):
    [self beginUpdateGuide_now];
    
    //    //*** 未登录:
    //    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == NO)
    //    {
    //        [[NSUserDefaults standardUserDefaults] setObject:_guideName_needUpdate forKey:@"notlogininwhenupdate_search"];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //
    //        [_searchBar resignFirstResponder];
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
    QYGuide *guide = [_array_result objectAtIndex:_position_row_tapCell];
    [FilePath moveDownloadedGuideToAnotherPathWithGuideName:guide.guideName];
    
    
    //*** 刷新cell:
    NSIndexPath *indepath = [NSIndexPath indexPathForRow:_position_row_tapCell inSection:_position_section_tapCell];
    GuideViewCell *cell = (GuideViewCell *)[_tableView_searchVC cellForRowAtIndexPath:indepath];
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
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_search"] && _guideName_needUpdate && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_search"] isEqualToString:_guideName_needUpdate])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_search"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSelector:@selector(beginUpdateGuide_now) withObject:nil afterDelay:1.2];
    }
}
-(void)loginIn_Failed
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_search"] && _guideName_needUpdate && [[[NSUserDefaults standardUserDefaults] objectForKey:@"notlogininwhenupdate_search"] isEqualToString:_guideName_needUpdate])
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"notlogininwhenupdate_search"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}








#pragma mark -
#pragma mark --- UIScrollView - Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y + 64 != 0)
    {
        [_searchBar resignFirstResponder];
    }
    
    
    //********** Mod By ZhangDong 2014.4.3 Start *********
    if (self.isFromPlace)
    {
        if (_loadMoreView.hidden == YES) {
            return;
        }
        
        if(_tableView_searchVC.contentOffset.y > 0 && _tableView_searchVC.contentOffset.y + _tableView_searchVC.frame.size.height > _tableView_searchVC.contentSize.height - 230 && !_isLoading)
        {
            _isLoading = YES;
            
            [_loadMoreView changeLoadingStatus:_isLoading];
            
            _page ++;
            [PlaceSearchData searchDataByText:_searchText page:_page success:^(NSArray *array) {
                
                if (array.count < [reqNumber integerValue]) {
                    _loadMoreView.hidden = YES;
                }else{
                    _loadMoreView.hidden = NO;
                }
                [_array_result addObjectsFromArray:array];
                
                _isLoading = NO;
                [_loadMoreView changeLoadingStatus:_isLoading];
                
                [_tableView_searchVC reloadData];
                
            } failed:^{
                _isLoading = NO;
                [_loadMoreView changeLoadingStatus:_isLoading];
                [self initFailedLabel];
                [self.view hideToastActivity];
            }];
        }
    }
    //********** Mod By ZhangDong 2014.4.3 End *********
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


#pragma mark -
#pragma mark --- clickCancelButton
-(void)clickCancelButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"footViewHidden" object:nil userInfo:@{@"hidden":@NO}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark -
#pragma mark --- 文件损坏
-(void)fileDamaged:(NSNotification *)notfification
{
    NSDictionary *info_dic = [notfification userInfo];
    if(info_dic && [info_dic objectForKey:@"guidename"])
    {
        NSLog(@"  guideDetailVC_损坏的是: %@",[info_dic objectForKey:@"guidename"]);
        [_tableView_searchVC reloadData];
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
