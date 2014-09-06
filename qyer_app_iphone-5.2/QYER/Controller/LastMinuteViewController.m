

//
//  ListViewController.m
//  LastMinute
//
//  Created by lide(蔡小雨) on 13-6-24.
//
//



#import "LastMinuteViewController.h"

//#import "LastMinuteDetailViewController.h"
#import "LastMinuteDetailViewControllerNew.h"
#import "LastMinuteDeal.h"

#import "BoardDetailViewController.h"
#import "CityLoginViewController.h"

#import "UIImageView+WebCache.h"
#import "QYAPIClient.h"

#import <QuartzCore/QuartzCore.h>

#import "Toast+UIView.h"

#import "QyYhConst.h"

#import "ODRefreshControl.h"
#import "Reachability.h"

#define     height_headerview           (ios7 ? (44+20) : 44)

#define kBestImageViewTag 12191
#define kScrollViewTag 1384

@interface UIViewController ()

@end

@implementation LastMinuteViewController

@synthesize homeViewController = _homeViewController;




- (void)clickLastMinuteButton:(id)sender
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
    }
    
    else{
        [_orderTimeButton setSelected:NO];
        [_poiButton setSelected:NO];
        [_placeFromButton setSelected:NO];
        //*********** Insert By ZhangDong 2014.4.8 Start ************
        [self changeLabelFontBold:[_orderTimeButton titleLabel] bold:NO];
        [self changeLabelFontBold:[_poiButton titleLabel] bold:NO];
        [self changeLabelFontBold:[_placeFromButton titleLabel] bold:NO];
        //*********** Insert By ZhangDong 2014.4.8 End ************
        
        if([_lastMinuteButton isSelected])
        {
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            [self changeLabelFontBold:[_lastMinuteButton titleLabel] bold:NO];
            //*********** Insert By ZhangDong 2014.4.8 End ************
            [_lastMinuteButton setSelected:NO];
            [_categoryRefreshView hide];
            [_categoryBackView removeFromSuperview];
            
            [_tabBottomView setHidden:YES];
        }
        else
        {
            [_lastMinuteButton setSelected:YES];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            [self changeLabelFontBold:[_lastMinuteButton titleLabel] bold:YES];
            //*********** Insert By ZhangDong 2014.4.8 End ************
            
            [_categoryRefreshView setType:CategoryLastMinute];
            [_categoryRefreshView setSelectedName:_lastMinuteButton.checkTitle];
            [_categoryRefreshView show];
            
            [self.view insertSubview:_categoryBackView belowSubview:_categoryRefreshView];
            [_tabBottomView setHidden:NO];
            
            [[QYAPIClient sharedAPIClient] getCategoryAllWithType:0
                                                            times:_orderTime
                                                      continentId:_continentId
                                                        countryId:_countryId
                                                        departure:_departure
                                                          success:^(NSDictionary *dic) {
                                                              
                                                              if (_categoryRefreshView.type == CategoryLastMinute) {
                                                                  
                                                                  [_categoryRefreshView setCategoryArray:[[dic objectForKey:@"data"] objectForKey:@"type"]];
                                                              }
                                                              
                                                          } failure:^{
                                                              
                                                              [self.view hideToast];
                                                              [self.view hideToastActivity];
                                                              [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
                                                              
                                                              [_categoryRefreshView hide];
                                                              [_categoryBackView removeFromSuperview];
                                                              
                                                              [_tabBottomView setHidden:YES];
                                                          }];
            
        }
    }
    
}


- (void)clickPlaceFromButton:(id)sender
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
    }
    
    else{
        
        [_orderTimeButton setSelected:NO];
        [_poiButton setSelected:NO];
        [_lastMinuteButton setSelected:NO];
        //*********** Insert By ZhangDong 2014.4.8 Start ************
        [self changeLabelFontBold:[_orderTimeButton titleLabel] bold:NO];
        [self changeLabelFontBold:[_poiButton titleLabel] bold:NO];
        [self changeLabelFontBold:[_lastMinuteButton titleLabel] bold:NO];
        //*********** Insert By ZhangDong 2014.4.8 End ************
        
        if([_placeFromButton isSelected])
        {
            
            [_placeFromButton setSelected:NO];
            
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            [self changeLabelFontBold:[_placeFromButton titleLabel] bold:NO];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            [_categoryRefreshView hide];
            [_categoryBackView removeFromSuperview];
            
            [_tabBottomView setHidden:YES];
        }
        else
        {
            [_placeFromButton setSelected:YES];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            [self changeLabelFontBold:[_placeFromButton titleLabel] bold:YES];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            
            [_categoryRefreshView setType:CategoryDeparture];
            [_categoryRefreshView setSelectedName:_placeFromButton.checkTitle];
            [_categoryRefreshView show];
            
            [self.view insertSubview:_categoryBackView belowSubview:_categoryRefreshView];
            [_tabBottomView setHidden:NO];
            
            
            [[QYAPIClient sharedAPIClient] getCategoryAllWithType:_categoryType
                                                            times:_orderTime
                                                      continentId:_continentId
                                                        countryId:_countryId
                                                        departure:@""
                                                          success:^(NSDictionary *dic) {
                                                              
                                                              if (_categoryRefreshView.type == CategoryDeparture) {
                                                                  
                                                                  [_categoryRefreshView setCategoryArray:[[dic objectForKey:@"data"] objectForKey:@"departure"]];
                                                              }
                                                              
                                                          } failure:^{
                                                              
                                                              [self.view hideToast];
                                                              [self.view hideToastActivity];
                                                              [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
                                                              
                                                              [_categoryRefreshView hide];
                                                              [_categoryBackView removeFromSuperview];
                                                              
                                                              [_tabBottomView setHidden:YES];
                                                          }];
        }
    }

}

- (void)clickOrderTimeButton:(id)sender
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
    }
    
    else{
        
        [_lastMinuteButton setSelected:NO];
        [_poiButton setSelected:NO];
        [_placeFromButton setSelected:NO];
        //*********** Insert By ZhangDong 2014.4.8 Start ************
        [self changeLabelFontBold:[_placeFromButton titleLabel] bold:NO];
        [self changeLabelFontBold:[_poiButton titleLabel] bold:NO];
        [self changeLabelFontBold:[_lastMinuteButton titleLabel] bold:NO];
        //*********** Insert By ZhangDong 2014.4.8 End ************
        
        if([_orderTimeButton isSelected])
        {
            [_orderTimeButton setSelected:NO];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            [self changeLabelFontBold:[_orderTimeButton titleLabel] bold:NO];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            
            [_categoryRefreshView hide];
            [_categoryBackView removeFromSuperview];
            
            [_tabBottomView setHidden:YES];
        }
        else
        {
            [_orderTimeButton setSelected:YES];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            [self changeLabelFontBold:[_orderTimeButton titleLabel] bold:YES];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            
            [_categoryRefreshView show];
            [_categoryRefreshView setType:CategoryTime];
            [_categoryRefreshView setSelectedName:_orderTimeButton.checkTitle];
            
            [self.view insertSubview:_categoryBackView belowSubview:_categoryRefreshView];
            [_tabBottomView setHidden:NO];
            
            [[QYAPIClient sharedAPIClient] getCategoryAllWithType:_categoryType
                                                            times:@""
                                                      continentId:_continentId
                                                        countryId:_countryId
                                                        departure:_departure
                                                          success:^(NSDictionary *dic) {
                                                              
                                                              if (_categoryRefreshView.type == CategoryTime) {
                                                                  
                                                                  [_categoryRefreshView setCategoryArray:[[dic objectForKey:@"data"] objectForKey:@"times_drange"]];
                                                              }
                                                              
                                                          } failure:^{
                                                              
                                                              [self.view hideToast];
                                                              [self.view hideToastActivity];
                                                              [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
                                                              
                                                              [_categoryRefreshView hide];
                                                              [_categoryBackView removeFromSuperview];
                                                              
                                                              [_tabBottomView setHidden:YES];
                                                          }];
        }
    }
    
}

- (void)clickPOIButton:(id)sender
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
    }
    
    else{
        [_lastMinuteButton setSelected:NO];
        [_orderTimeButton setSelected:NO];
        [_placeFromButton setSelected:NO];
        //*********** Insert By ZhangDong 2014.4.8 Start ************
        [self changeLabelFontBold:[_orderTimeButton titleLabel] bold:NO];
        [self changeLabelFontBold:[_placeFromButton titleLabel] bold:NO];
        [self changeLabelFontBold:[_lastMinuteButton titleLabel] bold:NO];
        //*********** Insert By ZhangDong 2014.4.8 End ************
        
        if([_poiButton isSelected])
        {
            [_poiButton setSelected:NO];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            [self changeLabelFontBold:[_poiButton titleLabel] bold:NO];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            [_categoryRefreshView hide];
            [_categoryBackView removeFromSuperview];
            
            [_tabBottomView setHidden:YES];
        }
        else
        {
            [_poiButton setSelected:YES];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            [self changeLabelFontBold:[_poiButton titleLabel] bold:YES];
            //*********** Insert By ZhangDong 2014.4.8 Start ************
            
            [_categoryRefreshView show];
            [_categoryRefreshView setType:CategoryPOI];
            [_categoryRefreshView setSelectIndex:0];
            [_categoryRefreshView setSelectedName:_poiButton.checkTitle];
            
            [self.view insertSubview:_categoryBackView belowSubview:_categoryRefreshView];
            [_tabBottomView setHidden:NO];
            
            [[QYAPIClient sharedAPIClient] getCategoryAllWithType:_categoryType
                                                            times:_orderTime
                                                      continentId:0
                                                        countryId:0
                                                        departure:_departure
                                                          success:^(NSDictionary *dic) {
                                                              
                                                              if (_categoryRefreshView.type == CategoryPOI) {
                                                                  
                                                                  [_categoryRefreshView setCategoryArray:[[dic objectForKey:@"data"] objectForKey:@"poi"]];
                                                              }
                                                              
                                                          } failure:^{
                                                              
                                                              [self.view hideToast];
                                                              [self.view hideToastActivity];
                                                              [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
                                                              
                                                              [_categoryRefreshView hide];
                                                              [_categoryBackView removeFromSuperview];
                                                              
                                                              [_tabBottomView setHidden:YES];
                                                          }];
        }
    }
    
}


- (void)clickPageControl:(id)sender
{
    [_scrollView setContentOffset:CGPointMake(_pageControl.currentPage * _scrollView.frame.size.width, 0) animated:YES];
}

- (void)refreshMore
{
    
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
    }
    
    else{
        
        if(_refreshing == YES)
        {
            return;
        }
        
        _refreshing = YES;
        
        if(_canRefreshMore)
        {
            _gridView.loaderView = _refreshMoreView;
            
        }
        else
        {
            _gridView.loaderView = _noMoreView;
        }
        
        [_refreshMoreLabel setHidden:NO];
        [_activityIndicatior startAnimating];
        
        NSUInteger lastID = [[[_lastMinuteArray lastObject] objectForKey:@"id"] integerValue];
        
        
        [[QYAPIClient sharedAPIClient]getLastMinuteListWithType:_categoryType
                                                          maxId:lastID -1
                                                       pageSize:20
                                                          times:_orderTime
                                                    continentId:_continentId
                                                      countryId:_countryId
                                                      departure:_departure
                                                        success:^(NSDictionary *dic) {
                                                            
                                                            NSArray * data = [dic objectForKey:@"data"];
                                                            
                                                            if ([data count] == 0) {
                                                                
                                                                _canRefreshMore = NO;
                                                                _gridView.loaderView = _noMoreView;
                                                                
//                                                                [_noMoreView setHidden:YES];
                                                                
                                                            }
                                                            else{
                                                                
//                                                                [_noMoreView setHidden:NO];
                                                                
                                                                if([data count] == 20)
                                                                {
                                                                    _canRefreshMore = YES;
                                                                }
                                                                else
                                                                {
                                                                    _canRefreshMore = NO;
                                                                    _gridView.loaderView = _noMoreView;
                                                                }
                                                            }
                                                            
                                                            _refreshing = NO;
                                                            [_lastMinuteArray addObjectsFromArray:data];
                                                            [_gridView reloadData];
                                                            
                                                            [_activityIndicatior stopAnimating];
                                                            [_refreshMoreLabel setHidden:YES];
                                                            
                                                        } failure:^{
            
                                                            [self.view hideToast];
                                                            [self.view hideToastActivity];
                                                            [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
                                                            
                                                            _refreshing = NO;
                                                            [_activityIndicatior stopAnimating];
                                                            [_refreshMoreLabel setHidden:YES];
        
                                                        }];
        
    }
    
        
//        [LastMinuteDeal getLastMinuteListWithType:_categoryType
//                                            maxId:lastID -1
//                                         pageSize:20
//                                            times:_orderTime
//                                      continentId:_continentId
//                                        countryId:_countryId
//                                        departure:_departure
//                                          success:^(NSArray *data) {
//                                              
//                                              if ([data count] == 0) {
//                                                  
//                                                  [_noMoreView setHidden:YES];
//                                                  
//                                              }
//                                              else{
//                                                  
//                                                  [_noMoreView setHidden:NO];
//                                                  
//                                                  if([data count] == 20)
//                                                  {
//                                                      _canRefreshMore = YES;
//                                                  }
//                                                  else
//                                                  {
//                                                      _canRefreshMore = NO;
//                                                  }
//                                              }
//                                              
//                                              _refreshing = NO;
//                                              [_lastMinuteArray addObjectsFromArray:data];
//                                              [_gridView reloadData];
//                                              
//                                              [_activityIndicatior stopAnimating];
//                                              [_refreshMoreLabel setHidden:YES];
//                                              
//                                          } failure:^(NSError *error) {
//                                              
//                                              [self.view hideToast];
//                                              [self.view hideToastActivity];
//                                              [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
//                                              
//                                              _refreshing = NO;
//                                              [_activityIndicatior stopAnimating];
//                                              [_refreshMoreLabel setHidden:YES];
//                                          }];
    
}

//*********** Insert By ZhangDong 2014.4.8 Start ************
/**
 *  创建竖线图片视图
 *
 *  @return 图片视图
 */
- (UIImageView*)lineImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LastMinute_line.png"]];
    return [imageView autorelease];
}

/**
 *  改变标签的字体，是否加粗
 *
 *  @param label  标签
 *  @param isBold 是否加粗
 */
- (void)changeLabelFontBold:(UILabel*)label bold:(BOOL)isBold
{
    if (isBold) {
        label.font = [UIFont systemFontOfSize:13];
    }else{
        label.font = [UIFont systemFontOfSize:13];
    }
}

/**
 *  下拉刷新触发的方法
 *
 *  @param refreshControl 下拉刷新控件
 */
- (void)pullRefreshHandler:(ODRefreshControl *)refreshControl
{
    [_reloadLastMinuteView setHidden:YES];
    [_screenTapReloadTappp setEnabled:NO];
    
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [refreshControl endRefreshing];
        
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
    }
    
    else{
    
        [self.view makeToastActivity];
        
        [_lastMinuteButton setEnabled:NO];
        [_placeFromButton setEnabled:NO];
        [_orderTimeButton setEnabled:NO];
        [_poiButton setEnabled:NO];
        
        
        [[QYAPIClient sharedAPIClient]getLastMinuteListWithType:_categoryType
                                                          maxId:0
                                                       pageSize:20
                                                          times:_orderTime
                                                    continentId:_continentId
                                                      countryId:_countryId
                                                      departure:_departure
                                                        success:^(NSDictionary *dic) {
                                                            
                                                            NSArray * data = [dic objectForKey:@"data"];
       
                                                            [_lastMinuteButton setEnabled:YES];
                                                            [_placeFromButton setEnabled:YES];
                                                            [_orderTimeButton setEnabled:YES];
                                                            [_poiButton setEnabled:YES];
                                                            
                                                            [refreshControl endRefreshing];
                                                            
                                                            [self.view hideToastActivity];
                                                            
                                                            if ([data count] == 0) {
//                                                                [_noMoreView setHidden:YES];
                                                                
                                                                UIView * noLastMinutesView = [self.view viewWithTag:556677];
                                                                [noLastMinutesView setHidden:NO];
                                                                _gridView.hidden = YES;
                                                            }
                                                            else{
                                                                
//                                                                [_noMoreView setHidden:NO];
                                                                
                                                                UIView * noLastMinutesView = [self.view viewWithTag:556677];
                                                                [noLastMinutesView setHidden:YES];
                                                                _gridView.hidden = NO;
                                                                
                                                                if([data count] == 20)
                                                                {
                                                                    _canRefreshMore = YES;
                                                                }
                                                                else
                                                                {
                                                                    _canRefreshMore = NO;
                                                                    _gridView.loaderView = _noMoreView;
                                                                }
                                                            }
                                                            
                                                            _refreshing = NO;
                                                            [_lastMinuteArray removeAllObjects];
                                                            [_lastMinuteArray addObjectsFromArray:data];
                                                            [_gridView reloadData];
                                                            [_gridView setContentOffset:CGPointZero animated:YES];
                                                            
                                                        } failure:^{
            
                                                            [self.view hideToast];
                                                            [self.view hideToastActivity];
                                                            [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
                                                            
                                                            [_lastMinuteButton setEnabled:YES];
                                                            [_placeFromButton setEnabled:YES];
                                                            [_orderTimeButton setEnabled:YES];
                                                            [_poiButton setEnabled:YES];
                                                            
                                                            _refreshing = NO;
                                                            [refreshControl endRefreshing];
                                                            
                                                        }];
        
        
        
//        [LastMinuteDeal getLastMinuteListWithType:_categoryType
//                                            maxId:0
//                                         pageSize:20
//                                            times:_orderTime
//                                      continentId:_continentId
//                                        countryId:_countryId
//                                        departure:_departure
//                                          success:^(NSArray *data) {
//                                              
//                                              [_lastMinuteButton setEnabled:YES];
//                                              [_placeFromButton setEnabled:YES];
//                                              [_orderTimeButton setEnabled:YES];
//                                              [_poiButton setEnabled:YES];
//                                              
//                                              [refreshControl endRefreshing];
//                                              
//                                              [self.view hideToastActivity];
//                                              
//                                              if ([data count] == 0) {
//                                                  [_noMoreView setHidden:YES];
//                                                  
//                                                  UIView * noLastMinutesView = [self.view viewWithTag:556677];
//                                                  [noLastMinutesView setHidden:NO];
//                                              }
//                                              else{
//                                                  
//                                                  [_noMoreView setHidden:NO];
//                                                  
//                                                  UIView * noLastMinutesView = [self.view viewWithTag:556677];
//                                                  [noLastMinutesView setHidden:YES];
//                                                  
//                                                  if([data count] == 20)
//                                                  {
//                                                      _canRefreshMore = YES;
//                                                  }
//                                                  else
//                                                  {
//                                                      _canRefreshMore = NO;
//                                                  }
//                                              }
//                                              
//                                              _refreshing = NO;
//                                              [_lastMinuteArray removeAllObjects];
//                                              [_lastMinuteArray addObjectsFromArray:data];
//                                              [_gridView reloadData];
//                                              [_gridView setContentOffset:CGPointZero animated:YES];
//                                              
//                                          } failure:^(NSError *error) {
//                                              
//                                              [self.view hideToast];
//                                              [self.view hideToastActivity];
//                                              [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
//                                              
//                                              [_lastMinuteButton setEnabled:YES];
//                                              [_placeFromButton setEnabled:YES];
//                                              [_orderTimeButton setEnabled:YES];
//                                              [_poiButton setEnabled:YES];
//                                              
//                                              _refreshing = NO;
//                                              
//                                              [refreshControl endRefreshing];
//                                          }];
    }
    
}


//*********** Insert By ZhangDong 2014.4.8 End ************

#pragma mark - super

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _lastMinuteArray = [[NSMutableArray alloc] initWithCapacity:0];
        _bestArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        _orderTime = @"";
        _departure = @"";
    }
    
    return self;
}


- (void)loadView
{
    [super loadView];
    
    //*********** Insert By ZhangDong 2014.4.9 Start ************
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor whiteColor];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
    //*********** Insert By ZhangDong 2014.4.9 Start ************
    
    if (!ios7) {
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-20);
    }
    
    
    self.view.exclusiveTouch = YES;
    self.view.backgroundColor = [UIColor colorWithRed:232.0 / 255.0 green:243.0 / 255.0 blue:248.0 / 255.0 alpha:1.0];

    
    //*********** Mod By ZhangDong 2014.4.8 Start ************
    float height_naviViewHeight = (ios7 ? 20+44 : 44);
    UIView * naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height_naviViewHeight)];
    naviView.backgroundColor = RGB(43, 171, 121);
    [self.view addSubview:naviView];
    [naviView release];
    //*********** Mod By ZhangDong 2014.4.8 End ************
    

    UIImageView *titleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 10, 80, 24)];
    if(ios7)
    {
        titleImgView.frame = CGRectMake(120, 10+20, 80, 24);
    }
    titleImgView.backgroundColor = [UIColor clearColor];
    [titleImgView setImage:[UIImage imageNamed:@"navigation_lastMinute"]];
    [naviView addSubview:titleImgView];
    [titleImgView release];
    
    
    _gridView = [[SMGridView alloc] initWithFrame:CGRectMake(0, height_naviViewHeight +42, 320, self.view.frame.size.height - height_naviViewHeight - 50 -42)];
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.gridDelegate = self;
    _gridView.dataSource = self;
    _gridView.vertical = YES;
    _gridView.padding = 10.0f;
    [self.view addSubview:_gridView];
    
    //********** Insert By ZhangDong 2014.4.8 Start ************
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:_gridView];
    [_refreshControl addTarget:self action:@selector(pullRefreshHandler:) forControlEvents:UIControlEventValueChanged];
    //********** Insert By ZhangDong 2014.4.8 End ************
    
//    _slimeView = [[SRRefreshView alloc] init];
//    _slimeView.delegate = self;
//    _slimeView.upInset = 0;
//    _slimeView.slimeMissWhenGoingBack = YES;
//     _slimeView.slime.bodyColor = [UIColor colorWithRed:1.0 / 255.0 green:176.0 / 255.0 blue:129.0 / 255.0 alpha:1.0];
//     _slimeView.slime.skinColor = [UIColor colorWithRed:1.0 / 255.0 green:176.0 / 255.0 blue:129.0 / 255.0 alpha:1.0];
//     _slimeView.slime.lineWith = 1;
//     _slimeView.slime.shadowBlur = 4;
//     _slimeView.slime.shadowColor = [UIColor clearColor];
//    [_gridView addSubview:_slimeView];
    
    
    
    
//    _gridHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 107)];
//    _gridHeaderView.backgroundColor = [UIColor clearColor];
//    
//    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 107)];
//    _scrollView.backgroundColor = [UIColor clearColor];
//    _scrollView.delegate = self;
//    _scrollView.scrollsToTop = NO;
//    _scrollView.showsHorizontalScrollIndicator = NO;
//    _scrollView.showsVerticalScrollIndicator = NO;
//    _scrollView.pagingEnabled = YES;
//    _scrollView.tag = kScrollViewTag;
//    _scrollView.bounces = NO;
//    [_gridHeaderView addSubview:_scrollView];
//    
//    
//    _pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0, 97, 320, 20)];
//    [_pageControl addTarget:self action:@selector(clickPageControl:) forControlEvents:UIControlEventValueChanged];
//    _pageControl.pageIndicatorImage = [UIImage imageNamed:@"page_control_dot.png"];
//    _pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"page_control_dot_selected.png"];
//    
//    _bestLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 107, 320, 1)];
//    _bestLine.backgroundColor = [UIColor clearColor];
//    _bestLine.image = [UIImage imageNamed:@"best_line.png"];
//    [_gridHeaderView addSubview:_bestLine];
//    
//    
//    _numberImageView = [[UIImageView alloc] initWithFrame:CGRectMake(276, 8, 36, 15)];
//    _numberImageView.backgroundColor = [UIColor clearColor];
//    _numberImageView.image = [UIImage imageNamed:@"lastMinute_number.png"];
//    [_gridHeaderView addSubview:_numberImageView];
//    
//    _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 36, 15)];
//    _numberLabel.backgroundColor = [UIColor clearColor];
//    _numberLabel.textColor = [UIColor whiteColor];
//    _numberLabel.font = [UIFont boldSystemFontOfSize:11.0f];
//    _numberLabel.text = @"1/1";
//    _numberLabel.textAlignment = UITextAlignmentCenter;
//    [_numberImageView addSubview:_numberLabel];
    
    
    
    _refreshMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 34)];
    _refreshMoreView.backgroundColor = [UIColor clearColor];
    
    _refreshMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 0, 100, 30)];//CGRectMake(0, 0, 320, 30)];
    _refreshMoreLabel.backgroundColor = [UIColor clearColor];
    _refreshMoreLabel.textColor = [UIColor grayColor];//[UIColor colorWithRed:100.0 / 255.0 green:100.0 / 255.0 blue:100.0 / 255.0 alpha:1.0];
    _refreshMoreLabel.font = [UIFont systemFontOfSize:13.0f];
    _refreshMoreLabel.text = @"正在加载...";//@"更多折扣";
    _refreshMoreLabel.textAlignment = NSTextAlignmentLeft;
    [_refreshMoreView addSubview:_refreshMoreLabel];
    
    _activityIndicatior = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(105, 0, 30, 30)];
//    _activityIndicatior.frame = CGRectMake(200, (40 - _activityIndicatior.frame.size.height) / 2, _activityIndicatior.frame.size.width, _activityIndicatior.frame.size.height);
    [_activityIndicatior setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [_refreshMoreView addSubview:_activityIndicatior];
    
    _noMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 38)];//60
    _noMoreView.backgroundColor = [UIColor clearColor];
    _noMoreIcon = [[UIImageView alloc] initWithFrame:CGRectMake(120, 1, 80, 24)];//CGRectMake(137, 12, 45, 35)
//    _noMoreIcon.center = _noMoreView.center;
    _noMoreIcon.backgroundColor = [UIColor clearColor];
    _noMoreIcon.image = [UIImage imageNamed:@"lastminute_icon_bottom.png"];
    [_noMoreView addSubview:_noMoreIcon];
    _gridView.loaderView = _noMoreView;
    
    


    
    //没有缓存提示点击加载的图层
    _reloadLastMinuteView = [[UIView alloc]initWithFrame:CGRectMake(0, (self.view.frame.size.height -200)/2, 320, 200)];
    [_reloadLastMinuteView setHidden:YES];
    [_reloadLastMinuteView setBackgroundColor:[UIColor clearColor]];
    [_reloadLastMinuteView setUserInteractionEnabled:YES];
    [self.view addSubview:_reloadLastMinuteView];
    
    UIImageView * noResultImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 320, 180)];
    [noResultImgView setBackgroundColor:[UIColor clearColor]];
    [noResultImgView setImage:[UIImage imageNamed:@"notReachable.png"]];
    [_reloadLastMinuteView addSubview:noResultImgView];
    [noResultImgView release];
    
    _screenTapReloadTappp = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getNewLastMinuteDeals)];
    [self.view addGestureRecognizer:_screenTapReloadTappp];
    [_screenTapReloadTappp setEnabled:NO];
    
    
    _categoryView = [[UIView alloc] initWithFrame:CGRectMake(0, height_naviViewHeight, 320, 42)];
    _categoryView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_categoryView];
    
    //draw 默认图
    [self drawDefaultBlankView];
    
    
    //*********** Del By ZhangDong 2014.4.8 Start ************
//    _categoryShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 42, 320, 3)];
//    _categoryShadowImageView.backgroundColor = [UIColor clearColor];
//    _categoryShadowImageView.image = [UIImage imageNamed:@"tab_shadow.png"];
//    [_categoryView addSubview:_categoryShadowImageView];
    //*********** Del By ZhangDong 2014.4.8 Start ************
    
    _categoryRefreshView = [[CategoryRefreshView alloc] initWithFrame:CGRectMake(0, height_naviViewHeight +2, 320, 40)];
    _categoryRefreshView.delegate = self;
    [self.view insertSubview:_categoryRefreshView belowSubview:_categoryView];
    
    
    _lastMinuteButton = [[CategoryButton buttonWithType:UIButtonTypeCustom] retain];
    _lastMinuteButton.frame = CGRectMake(0, 0, 80, 42);
    _lastMinuteButton.backgroundColor = [UIColor clearColor];
    _lastMinuteButton.adjustsImageWhenHighlighted = NO;
    _lastMinuteButton.selected = NO;
    [_lastMinuteButton setTitle:@"折扣类型" forState:UIControlStateNormal];
    //*********** Mod By ZhangDong 2014.4.8 Start ************
    [_lastMinuteButton setTitleColor:RGB(100, 100, 100) forState:UIControlStateNormal];
    //*********** End By ZhangDong 2014.4.8 Start ************
    [_lastMinuteButton setTitleColor:[UIColor colorWithRed:(float)34/255 green:(float)185/255 blue:(float)119/255 alpha:1.0] forState:UIControlStateSelected];
    _lastMinuteButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [_lastMinuteButton setBackgroundImage:[UIImage imageNamed:@"list_tab_left.png"] forState:UIControlStateNormal];
    [_lastMinuteButton setBackgroundImage:[UIImage imageNamed:@"list_tab_left_selected.png"] forState:UIControlStateSelected];
    [_lastMinuteButton addTarget:self action:@selector(clickLastMinuteButton:) forControlEvents:UIControlEventTouchUpInside];
    [_categoryView addSubview:_lastMinuteButton];
    
    _orderTimeButton = [[CategoryButton buttonWithType:UIButtonTypeCustom] retain];
    _orderTimeButton.frame = CGRectMake(240, 0, 80, 42);
    _orderTimeButton.backgroundColor = [UIColor clearColor];
    _orderTimeButton.adjustsImageWhenHighlighted = NO;
    _orderTimeButton.selected = NO;
    [_orderTimeButton setTitle:@"旅行时间" forState:UIControlStateNormal];
    //*********** Mod By ZhangDong 2014.4.8 Start ************
    [_orderTimeButton setTitleColor:RGB(100, 100, 100) forState:UIControlStateNormal];
    //*********** Mod By ZhangDong 2014.4.8 End ************
    [_orderTimeButton setTitleColor:[UIColor colorWithRed:(float)34/255 green:(float)185/255 blue:(float)119/255 alpha:1.0] forState:UIControlStateSelected];
    _orderTimeButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [_orderTimeButton setBackgroundImage:[UIImage imageNamed:@"list_tab_left.png"] forState:UIControlStateNormal];
    [_orderTimeButton setBackgroundImage:[UIImage imageNamed:@"list_tab_left_selected.png"] forState:UIControlStateSelected];
    [_orderTimeButton addTarget:self action:@selector(clickOrderTimeButton:) forControlEvents:UIControlEventTouchUpInside];
    [_categoryView addSubview:_orderTimeButton];
    
    _poiButton = [[CategoryButton buttonWithType:UIButtonTypeCustom] retain];
    _poiButton.frame = CGRectMake(160, 0, 80, 42);
    _poiButton.backgroundColor = [UIColor clearColor];
    _poiButton.adjustsImageWhenHighlighted = NO;
    _poiButton.selected = NO;
    [_poiButton setTitle:@"目的地" forState:UIControlStateNormal];
    //*********** Mod By ZhangDong 2014.4.8 Start ************
    [_poiButton setTitleColor:RGB(100, 100, 100) forState:UIControlStateNormal];
    //*********** Mod By ZhangDong 2014.4.8 End ************
    [_poiButton setTitleColor:[UIColor colorWithRed:(float)34/255 green:(float)185/255 blue:(float)119/255 alpha:1.0] forState:UIControlStateSelected];
    _poiButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [_poiButton setBackgroundImage:[UIImage imageNamed:@"list_tab_left.png"] forState:UIControlStateNormal];
    [_poiButton setBackgroundImage:[UIImage imageNamed:@"list_tab_left_selected.png"] forState:UIControlStateSelected];
    [_poiButton addTarget:self action:@selector(clickPOIButton:) forControlEvents:UIControlEventTouchUpInside];
    [_categoryView addSubview:_poiButton];
    
    _placeFromButton = [[CategoryButton buttonWithType:UIButtonTypeCustom] retain];
    _placeFromButton.frame = CGRectMake(80, 0, 80, 42);
    _placeFromButton.backgroundColor = [UIColor clearColor];
    _placeFromButton.adjustsImageWhenHighlighted = NO;
    _placeFromButton.selected = NO;
    [_placeFromButton setTitle:@"出发地" forState:UIControlStateNormal];
    //*********** Mod By ZhangDong 2014.4.8 Start ************
    [_placeFromButton setTitleColor:RGB(100, 100, 100) forState:UIControlStateNormal];
    //*********** Mod By ZhangDong 2014.4.8 Start ************
    [_placeFromButton setTitleColor:[UIColor colorWithRed:(float)34/255 green:(float)185/255 blue:(float)119/255 alpha:1.0] forState:UIControlStateSelected];
    _placeFromButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [_placeFromButton setBackgroundImage:[UIImage imageNamed:@"list_tab_left.png"] forState:UIControlStateNormal];
    [_placeFromButton setBackgroundImage:[UIImage imageNamed:@"list_tab_left_selected.png"] forState:UIControlStateSelected];
    [_placeFromButton addTarget:self action:@selector(clickPlaceFromButton:) forControlEvents:UIControlEventTouchUpInside];
    [_categoryView addSubview:_placeFromButton];
    
    //*********** Insert By ZhangDong 2014.4.8 Start ************
    UIImageView *lineImageView1 = [self lineImageView];
    lineImageView1.frame = CGRectMake(_lastMinuteButton.frame.origin.x + _lastMinuteButton.frame.size.width, _lastMinuteButton.frame.origin.y, 1, 42);
    [_categoryView addSubview:lineImageView1];
    
    UIImageView *lineImageView2 = [self lineImageView];
    lineImageView2.frame = CGRectMake(_placeFromButton.frame.origin.x + _placeFromButton.frame.size.width, _placeFromButton.frame.origin.y, 1, 42);
    [_categoryView addSubview:lineImageView2];
    
    UIImageView *lineImageView3 = [self lineImageView];
    lineImageView3.frame = CGRectMake(_poiButton.frame.origin.x + _poiButton.frame.size.width, _poiButton.frame.origin.y, 1, 42);
    [_categoryView addSubview:lineImageView3];

    //*********** Insert By ZhangDong 2014.4.8 End ************
    
    _categoryBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height )];
    _categoryBackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    _categoryBackView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCategoryBackView:)];
    [_categoryBackView addGestureRecognizer:tap];
    [tap release];
    
    
    _tabBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].keyWindow.bounds.size.height -50, 320, 50)];
    [_tabBottomView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    [_tabBottomView setHidden:YES];
    [_tabBottomView setUserInteractionEnabled:YES];
    
    
    [[UIApplication sharedApplication].keyWindow addSubview:_tabBottomView];
    UITapGestureRecognizer *tappp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCategoryBackView:)];
    [_tabBottomView addGestureRecognizer:tappp];
    [tappp release];
    
    
    
    
}

//默认图
- (void)drawDefaultBlankView
{
    //没有折扣结果的View
    UIView * noLastMinutesView = [[UIView alloc]initWithFrame:CGRectMake(0, _categoryView.frame.origin.y+_categoryView.frame.size.height, 320, 340)];
    [noLastMinutesView setTag:556677];
    [noLastMinutesView setHidden:YES];
    [noLastMinutesView setBackgroundColor:[UIColor clearColor]];
    [self.view insertSubview:noLastMinutesView belowSubview:_categoryView];
    [noLastMinutesView release];
    
    
    //默认图 logo
    UIImageView *defaultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 66, 80, 80)];
    defaultImageView.image = [UIImage imageNamed:@"lastMinuteNoResult.png"];
    [noLastMinutesView addSubview:defaultImageView];
    [defaultImageView release];
    
    
    //默认图 没有找到你想要的折扣
    UILabel *noneLastMinuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 162, 320, 17)];
    noneLastMinuteLabel.text = @"没有找到你想要的折扣";
    noneLastMinuteLabel.textAlignment = NSTextAlignmentCenter;
    noneLastMinuteLabel.backgroundColor = [UIColor clearColor];
    noneLastMinuteLabel.font = [UIFont systemFontOfSize:15];
    noneLastMinuteLabel.textColor = [UIColor colorWithRed:162.0/255.0f green:162.0/255.0 blue:162.0/255.0 alpha:1.0];
    [noLastMinutesView addSubview:noneLastMinuteLabel];
    [noneLastMinuteLabel release];
    
    //默认图 你可以设置一个提醒，当出现符合你设置条件
    UILabel *remindALabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 229, 320, 15)];
    remindALabel.text = @"你可以设置一个提醒，当出现符合你设置条件";
    remindALabel.textAlignment = NSTextAlignmentCenter;
    remindALabel.backgroundColor = [UIColor clearColor];
    remindALabel.font = [UIFont systemFontOfSize:13];
    remindALabel.textColor = [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0];
    [noLastMinutesView addSubview:remindALabel];
    [remindALabel release];
    
    //默认图 的折扣时，我们会第一时间通知你！
    UILabel *remindBLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 251, 320, 15)];
    remindBLabel.text = @"的折扣时，我们会第一时间通知你！";
    remindBLabel.textAlignment = NSTextAlignmentCenter;
    remindBLabel.backgroundColor = [UIColor clearColor];
    remindBLabel.font = [UIFont systemFontOfSize:13];
    remindBLabel.textColor = [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0];
    [noLastMinutesView addSubview:remindBLabel];
    [remindBLabel release];
    
    
    //默认图 设置提醒 button
    UIButton *remindButton = [[UIButton alloc] initWithFrame:CGRectMake(93, 283, 134, 33)];
    [remindButton setImage:[UIImage imageNamed:@"lastminute_remindBtn.png"] forState:UIControlStateNormal];
    [remindButton setImage:[UIImage imageNamed:@"lastminute_remindBtn_highlighted.png"] forState:UIControlStateHighlighted];
    [remindButton addTarget:self action:@selector(remindButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [noLastMinutesView addSubview:remindButton];
    [remindButton release];


}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setMultipleTouchEnabled:NO];

    [self getNewLastMinuteDeals];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //*********** Insert By ZhangDong 2014.4.8 Start ************
    _isTapedImage = NO;
    //*********** Insert By ZhangDong 2014.4.8 End ************
    //    [[[UIApplication sharedApplication] keyWindow] insertSubview:_drawerBackView atIndex:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //*********** Insert By ZhangDong 2014.4.8 Start ************
    _isTapedImage = NO;
    //*********** Insert By ZhangDong 2014.4.8 End ************
    //    [_drawerBackView removeFromSuperview];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"折扣"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"折扣"];
}


-(void)getNewLastMinuteDeals
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [self.view hideToast];
        [self.view hideToastActivity];
        [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
        
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"lastMinuteCache"]) {
            
            NSArray * cacheee = (NSArray *)[[NSUserDefaults standardUserDefaults]objectForKey:@"lastMinuteCache"];
            [self.view hideToastActivity];
            [_lastMinuteArray removeAllObjects];
            [_lastMinuteArray addObjectsFromArray:cacheee];
            [_gridView reloadData];
            [_gridView setContentOffset:CGPointZero animated:YES];
        }
        
        else
        {
            [_reloadLastMinuteView setHidden:NO];
            [_screenTapReloadTappp setEnabled:YES];
        }
        
    }
    
    else{
        [self.view makeToastActivity];
        
        [_lastMinuteButton setEnabled:NO];
        [_placeFromButton setEnabled:NO];
        [_orderTimeButton setEnabled:NO];
        [_poiButton setEnabled:NO];
        
        [[QYAPIClient sharedAPIClient]getLastMinuteListWithType:0 maxId:0 pageSize:20 times:@"" continentId:0 countryId:0 departure:@"" success:^(NSDictionary *dict) {
            
            [_reloadLastMinuteView setHidden:YES];
            [_screenTapReloadTappp setEnabled:NO];
            
            [_lastMinuteButton setEnabled:YES];
            [_placeFromButton setEnabled:YES];
            [_orderTimeButton setEnabled:YES];
            [_poiButton setEnabled:YES];
            
            [self.view hideToastActivity];
            
            [_refreshControl endRefreshing];
            
            NSArray * listArray = [dict objectForKey:@"data"];
            
            if ([listArray count] == 0) {
//                [_noMoreView setHidden:YES];
            }
            else{
                //保存缓存
                [[NSUserDefaults standardUserDefaults]setObject:listArray forKey:@"lastMinuteCache"];
                
//                [_noMoreView setHidden:NO];
                
                if([listArray count] == 20)
                {
                    _canRefreshMore = YES;
                }
                else
                {
                    _canRefreshMore = NO;
                    _gridView.loaderView = _noMoreView;
                }
            }
            
            _refreshing = NO;
            
            [_lastMinuteArray removeAllObjects];
            [_lastMinuteArray addObjectsFromArray:listArray];
            [_gridView reloadData];
            [_gridView setContentOffset:CGPointZero animated:YES];
            
        } failure:^{
            
            [self.view hideToast];
            [self.view hideToastActivity];
            [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
            
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"lastMinuteCache"]) {
                
                NSArray * cacheee = (NSArray *)[[NSUserDefaults standardUserDefaults]objectForKey:@"lastMinuteCache"];
                
                [_reloadLastMinuteView setHidden:YES];
                [_screenTapReloadTappp setEnabled:NO];
                
                [_lastMinuteButton setEnabled:YES];
                [_placeFromButton setEnabled:YES];
                [_orderTimeButton setEnabled:YES];
                [_poiButton setEnabled:YES];
                
                [self.view hideToastActivity];
                
                [_refreshControl endRefreshing];
//                [_noMoreView setHidden:NO];
                
                if([cacheee count] == 20)
                {
                    _canRefreshMore = YES;
                }
                else
                {
                    _canRefreshMore = NO;
                    _gridView.loaderView = _noMoreView;
                }
                _refreshing = NO;
                
                [_lastMinuteArray removeAllObjects];
                [_lastMinuteArray addObjectsFromArray:cacheee];
                [_gridView reloadData];
                [_gridView setContentOffset:CGPointZero animated:YES];
            }
            
            else{
                
                [_reloadLastMinuteView setHidden:NO];
                [_screenTapReloadTappp setEnabled:YES];
                
                [_lastMinuteButton setEnabled:YES];
                [_placeFromButton setEnabled:YES];
                [_orderTimeButton setEnabled:YES];
                [_poiButton setEnabled:YES];
                
                [_refreshControl endRefreshing];
                [self.view hideToastActivity];
            }
        }];
    }
    
}

#pragma mark - button click
//默认图 设置提醒 button
- (void)remindButtonClickAction:(id)sender
{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue])
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"你还未登录，请先登录。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 12537;
        [alertView show];
        [alertView release];
        
        return;
    }
    
    NSLog(@"----------_categoryType:'%d', _orderTime:'%@', _countryId:'%d'", _categoryType, _orderTime, _countryId);
    [[QYAPIClient sharedAPIClient] addLastMinuteRemindWithType:_categoryType
                                                         times:_orderTime
                                                 startPosition:_departure
                                                     countryId:_countryId
                                                       success:^(NSDictionary *dic) {
                                                           
                                                           [self.view hideToast];
                                                           [self.view makeToast:@"提醒设置成功" duration:1.2f position:@"center" isShadow:NO];//Toast_Post_Order_Fail
                                                           
                                                           [self performSelector:@selector(clearAllOptions) withObject:nil afterDelay:1.0];
                                                           
                                                       }
                                                       failure:^{
                                                           
                                                           [self.view hideToast];
                                                           [self.view makeToast:@"设置提醒失败" duration:1.2f position:@"center" isShadow:NO];
//                                                           [self.view hideToast];
//                                                           [self.view makeToast:[error localizedDescription] duration:1.2f position:@"center" isShadow:NO];//Toast_Post_Order_Fail
                                                       }];
    
    
    
    
}

-(void)clearAllOptions
{
    
    [self.view hideToast];
    
    _lastMinuteButton.selected = NO;
    [_lastMinuteButton setTitle:@"折扣类型" forState:UIControlStateNormal];
    
    _orderTimeButton.selected = NO;
    [_orderTimeButton setTitle:@"旅行时间" forState:UIControlStateNormal];
    
    _poiButton.selected = NO;
    [_poiButton setTitle:@"目的地" forState:UIControlStateNormal];
    
    _placeFromButton.selected = NO;
    [_placeFromButton setTitle:@"出发地" forState:UIControlStateNormal];
    
    UIView * noLastMinutesView = [self.view viewWithTag:556677];
    [noLastMinutesView setHidden:YES];
    _gridView.hidden = NO;
    
    _categoryType = 0;
    _orderTime = @"";
    _continentId = 0;
    _countryId = 0;
    _departure = @"";
    
    [self getNewLastMinuteDeals];
}


#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 12537 && buttonIndex == 1) {
        CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
        navigationController.navigationBarHidden = YES;
        [self.homeViewController presentViewController:navigationController animated:YES completion:nil];
        [cityLoginVC release];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.tag == kScrollViewTag)
    {
        
    }
    else
    {
        [_slimeView scrollViewDidScroll];
        
        if(_gridView.contentOffset.y + _gridView.frame.size.height > _gridView.contentSize.height - 300)
        {
            [self refreshMore];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView.tag == kScrollViewTag)
    {
        
    }
    else
    {
        [_slimeView scrollViewDidEndDraging];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    //滚动的时候禁止点击折扣详情界面
    _forbidTapDetailView = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //停止滚动时可以点击折扣详情界面
    _forbidTapDetailView = NO;

}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
//{
//    if(scrollView.tag == kScrollViewTag)
//    {
//        NSUInteger currentPage = _scrollView.contentOffset.x / _scrollView.frame.size.width;
//        _numberLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)currentPage, (unsigned long)[_bestArray count]];
//        
//        if(_scrollView.contentOffset.x <= 0)
//        {
//            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * [_bestArray count], 0)];
//            _numberLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)[_bestArray count], (unsigned long)[_bestArray count]];
//        }
//        
//        if(_scrollView.contentOffset.x >= _scrollView.frame.size.width * ([_bestArray count] + 1))
//        {
//            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
//            _numberLabel.text = [NSString stringWithFormat:@"1/%lu", (unsigned long)[_bestArray count]];
//        }
//    }
//    else
//    {
//        
//    }
//}

#pragma mark - SMGridViewDataSource

- (BOOL)smGridViewShowLoader:(SMGridView *)gridView {
    return  YES;
}

- (NSInteger)numberOfSectionsInSMGridView:(SMGridView *)gridView {
    return 1;
}

- (NSInteger)smGridView:(SMGridView *)gridView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)smGridView:(SMGridView *)gridView numberOfItemsInSection:(NSInteger)section {
    return [_lastMinuteArray count];
}

- (UIView *)smGridView:(SMGridView *)gridView viewForIndexPath:(NSIndexPath *)indexPath {
    LastMinuteView *view = (LastMinuteView *)[gridView dequeReusableViewOfClass:[LastMinuteView class]];
    if (!view) {
        view = [[[LastMinuteView alloc] initWithFrame:CGRectMake(0, 0, 148, 168)] autorelease];
        view.backgroundColor = [UIColor clearColor];
        view.delegate = self;
    }
    
    if (_lastMinuteArray.count >0) {
        [view setLastMinute:[_lastMinuteArray objectAtIndex:indexPath.row]];
    }
    
    return view;
}

- (CGSize)smGridView:(SMGridView *)gridView sizeForIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(145, 170);//CGSizeMake(145, 173);
}


- (void)lastMinuteViewDidTap:(LastMinuteDeal *)lastMinute
{
    //滚动的时候禁止点击折扣详情界面
    if (_forbidTapDetailView) {
        return;
    }
    
    //*********** Insert By ZhangDong 2014.4.8 Start ************
    if (_isTapedImage) {
        return;
    }
    _isTapedImage = YES;
    
    NSDictionary * dictttt = (NSDictionary *)lastMinute;
    int dealID = [[dictttt objectForKey:@"id"] intValue];
    
    LastMinuteDetailViewControllerNew * lastDetailVC = [[LastMinuteDetailViewControllerNew alloc]init];
    lastDetailVC.lastMinuteId = dealID;//dealID;
    lastDetailVC.source = NSStringFromClass([self class]);
    [self.homeViewController.navigationController pushViewController:lastDetailVC animated:YES];
    [lastDetailVC release];
    
    
//    BoardDetailViewController * boardDetailVC = [[BoardDetailViewController alloc]init];
//    [self.homeViewController.navigationController pushViewController:boardDetailVC animated:YES];
//    [boardDetailVC release];
    
    
//    NSString * token = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_access_token"];
//    [[QYAPIClient sharedAPIClient]getLastMinuteDetailWithID:dealID OAuthToken:token success:^(NSDictionary *dic) {
//        
//        NSString * detailUrlString = [[dic objectForKey:@"data"] objectForKey:@"app_url"];
//        
//        NSString * originUrlString = @"";
//        if ([[[dic objectForKey:@"data"] objectForKey:@"m_qyer_url"] isKindOfClass:[NSString class]] && ![[[dic objectForKey:@"data"] objectForKey:@"m_qyer_url"] isEqualToString:@""]) {
//            originUrlString = [[dic objectForKey:@"data"] objectForKey:@"m_qyer_url"];
//        }
//        else{
//            originUrlString = [[dic objectForKey:@"data"] objectForKey:@"qyer_url"];
//        }
//        
//        LastMinuteDetailViewController * lastDetailVC = [[LastMinuteDetailViewController alloc]init];
//        lastDetailVC.dealURL = [NSString stringWithFormat:@"%@",detailUrlString];
//        lastDetailVC.originalURL = [NSString stringWithFormat:@"%@",originUrlString];
//        [self.homeViewController.navigationController pushViewController:lastDetailVC animated:YES];
//        [lastDetailVC release];
//        
//    } failure:^{
//        
//    }];
    //*********** Insert By ZhangDong 2014.4.8 End ************
}

#pragma mark - UIGestureRecognizer

- (void)tapCategoryBackView:(UITapGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if([_lastMinuteButton isSelected])
        {
            [_lastMinuteButton setSelected:NO];
        }
        else if([_placeFromButton isSelected])
        {
            [_placeFromButton setSelected:NO];
        }
        else if([_orderTimeButton isSelected])
        {
            [_orderTimeButton setSelected:NO];
        }
        else if([_poiButton isSelected])
        {
            [_poiButton setSelected:NO];
        }
        
        [_categoryRefreshView hide];
        [_categoryBackView removeFromSuperview];
        
        [_tabBottomView setHidden:YES];
    }
}

#pragma mark - slimeRefresh delegate


#pragma mark - CategoryRefreshViewDelegate

- (void)categoryRefreshViewDidSelectWithDictionary:(NSDictionary *)dictionary
{
    
    [_reloadLastMinuteView setHidden:YES];
    [_screenTapReloadTappp setEnabled:NO];
    
    switch (_categoryRefreshView.type)
    {
        case CategoryLastMinute:
        {
            [_lastMinuteButton setSelected:NO];
            _categoryType = [[dictionary objectForKey:@"id"] intValue];
            [_lastMinuteButton setTitle:[dictionary objectForKey:@"catename"] forState:UIControlStateNormal];
        }
            break;
        case CategoryTime:
        {
            [_orderTimeButton setSelected:NO];
            if(_orderTime != nil)
            {
                QY_SAFE_RELEASE(_orderTime);
            }
            _orderTime = [[NSString alloc] initWithString:[dictionary objectForKey:@"times"]];
            [_orderTimeButton setTitle:[dictionary objectForKey:@"description"] forState:UIControlStateNormal];
        }
            break;
        case CategoryDeparture:
        {
            [_placeFromButton setSelected:NO];
            if(_departure != nil)
            {
                QY_SAFE_RELEASE(_departure);
            }
            _departure = [[NSString alloc] initWithString:[dictionary objectForKey:@"city"]];
            [_placeFromButton setTitle:[dictionary objectForKey:@"city_des"] forState:UIControlStateNormal];
        }
            break;
        case CategoryPOI:
        {
            
        }
            break;
        default:
            break;
    }
    
    
    [_categoryRefreshView hide];
    [_categoryBackView removeFromSuperview];
    [_tabBottomView setHidden:YES];
    
    [self.view makeToastActivity];
    
    [_lastMinuteButton setEnabled:NO];
    [_placeFromButton setEnabled:NO];
    [_orderTimeButton setEnabled:NO];
    [_poiButton setEnabled:NO];
    
    
    [[QYAPIClient sharedAPIClient]getLastMinuteListWithType:_categoryType
                                                      maxId:0
                                                   pageSize:20
                                                      times:_orderTime
                                                continentId:_continentId
                                                  countryId:_countryId
                                                  departure:_departure
                                                     success:^(NSDictionary *dict){
                                                         
                                                         NSArray * data = [dict objectForKey:@"data"];
                                                        
                                                         [_lastMinuteButton setEnabled:YES];
                                                         [_placeFromButton setEnabled:YES];
                                                         [_orderTimeButton setEnabled:YES];
                                                         [_poiButton setEnabled:YES];
                                                         
                                                         [self.view hideToastActivity];
                                                         
                                                         if ([data count] == 0) {
//                                                             [_noMoreView setHidden:YES];
                                                             
                                                             UIView * noLastMinutesView = [self.view viewWithTag:556677];
                                                             [noLastMinutesView setHidden:NO];
                                                             _gridView.hidden = YES;
                                                         }
                                                         else{
//                                                             [_noMoreView setHidden:NO];
                                                             
                                                             UIView * noLastMinutesView = [self.view viewWithTag:556677];
                                                             [noLastMinutesView setHidden:YES];
                                                             _gridView.hidden = NO;
                                                             
                                                             if([data count] == 20)
                                                             {
                                                                 _canRefreshMore = YES;
                                                             }
                                                             else
                                                             {
                                                                 _canRefreshMore = NO;
                                                                 _gridView.loaderView = _noMoreView;
                                                             }
                                                         }
                                                         
                                                         _refreshing = NO;
                                                         [_lastMinuteArray removeAllObjects];
                                                         [_lastMinuteArray addObjectsFromArray:data];
                                                         [_gridView reloadData];
                                                         [_gridView setContentOffset:CGPointZero animated:YES];
                                                        
                                                    } failure:^{
    
                                                        [self.view hideToast];
                                                        [self.view hideToastActivity];
                                                        [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
                                                        
                                                        [_lastMinuteButton setEnabled:YES];
                                                        [_placeFromButton setEnabled:YES];
                                                        [_orderTimeButton setEnabled:YES];
                                                        [_poiButton setEnabled:YES];
                                                        
                                                        _refreshing = NO;
                                                    }];

    
    
//    [LastMinuteDeal getLastMinuteListWithType:_categoryType
//                                        maxId:0
//                                     pageSize:20
//                                        times:_orderTime
//                                  continentId:_continentId
//                                    countryId:_countryId
//                                    departure:_departure
//                                      success:^(NSArray *data) {
//                                          
//                                          [_lastMinuteButton setEnabled:YES];
//                                          [_placeFromButton setEnabled:YES];
//                                          [_orderTimeButton setEnabled:YES];
//                                          [_poiButton setEnabled:YES];
//                                          
//                                          [self.view hideToastActivity];
//                                          
//                                          if ([data count] == 0) {
//                                              [_noMoreView setHidden:YES];
//                                              
//                                              UIView * noLastMinutesView = [self.view viewWithTag:556677];
//                                              [noLastMinutesView setHidden:NO];
//                                          }
//                                          else{
//                                              
//                                              [_noMoreView setHidden:NO];
//                                              
//                                              UIView * noLastMinutesView = [self.view viewWithTag:556677];
//                                              [noLastMinutesView setHidden:YES];
//                                              
//                                              if([data count] == 20)
//                                              {
//                                                  _canRefreshMore = YES;
//                                              }
//                                              else
//                                              {
//                                                  _canRefreshMore = NO;
//                                              }
//                                          }
//                                          
//                                          _refreshing = NO;
//                                          [_lastMinuteArray removeAllObjects];
//                                          [_lastMinuteArray addObjectsFromArray:data];
//                                          [_gridView reloadData];
//                                          [_gridView setContentOffset:CGPointZero animated:YES];
//                                          
//                                      } failure:^(NSError *error) {
//                                          
//                                          [self.view hideToast];
//                                          [self.view hideToastActivity];
//                                          [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
//                                          
//                                          [_lastMinuteButton setEnabled:YES];
//                                          [_placeFromButton setEnabled:YES];
//                                          [_orderTimeButton setEnabled:YES];
//                                          [_poiButton setEnabled:YES];
//                                          
//                                          _refreshing = NO;
//                                      }];
}


- (void)categoryRefreshViewDidSelectWithDictionary:(NSDictionary *)dictionary withIndex:(NSIndexPath *)indexPath
{
    [_reloadLastMinuteView setHidden:YES];
    [_screenTapReloadTappp setEnabled:NO];
    
    
    [_poiButton setSelected:NO];
    _continentId = [[dictionary objectForKey:@"continent_id"] intValue];
    _countryId = [[[[dictionary objectForKey:@"country"] objectAtIndex:indexPath.row] objectForKey:@"country_id"] intValue];
    [_poiButton setTitle:[[[dictionary objectForKey:@"country"] objectAtIndex:indexPath.row] objectForKey:@"country_name"] forState:UIControlStateNormal];
    
    [_categoryRefreshView hide];
    [_categoryBackView removeFromSuperview];
    [_tabBottomView setHidden:YES];
    
    [self.view makeToastActivity];
    
    [_lastMinuteButton setEnabled:NO];
    [_placeFromButton setEnabled:NO];
    [_orderTimeButton setEnabled:NO];
    [_poiButton setEnabled:NO];
    
    
     [[QYAPIClient sharedAPIClient]getLastMinuteListWithType:_categoryType
                                                       maxId:0
                                                    pageSize:20
                                                       times:_orderTime
                                                 continentId:_continentId
                                                   countryId:_countryId
                                                   departure:_departure
                                                     success:^(NSDictionary *dic) {
                                                         
                                                         NSArray * data = [dic objectForKey:@"data"];
                                                         
                                                         [_lastMinuteButton setEnabled:YES];
                                                         [_placeFromButton setEnabled:YES];
                                                         [_orderTimeButton setEnabled:YES];
                                                         [_poiButton setEnabled:YES];
                                                         
                                                         [self.view hideToastActivity];
                                                         
                                                         if ([data count] == 0) {
                                                             
//                                                             [_noMoreView setHidden:YES];
                                                             
                                                             UIView * noLastMinutesView = [self.view viewWithTag:556677];
                                                             [noLastMinutesView setHidden:NO];
                                                             _gridView.hidden = YES;
                                                         }
                                                         else{
                                                             
                                                             [_lastMinuteButton setEnabled:YES];
                                                             [_placeFromButton setEnabled:YES];
                                                             [_orderTimeButton setEnabled:YES];
                                                             [_poiButton setEnabled:YES];
                                                             
//                                                             [_noMoreView setHidden:NO];
                                                             
                                                             UIView * noLastMinutesView = [self.view viewWithTag:556677];
                                                             [noLastMinutesView setHidden:YES];
                                                             _gridView.hidden = NO;
                                                             
                                                             if([data count] == 20)
                                                             {
                                                                 _canRefreshMore = YES;
                                                             }
                                                             else
                                                             {
                                                                 _canRefreshMore = NO;
                                                                 _gridView.loaderView = _noMoreView;
                                                             }
                                                         }
                                                         _refreshing = NO;
                                                         [_lastMinuteArray removeAllObjects];
                                                         [_lastMinuteArray addObjectsFromArray:data];
                                                         [_gridView reloadData];
                                                         [_gridView setContentOffset:CGPointZero animated:YES];
                                                         
                                                     } failure:^{
                                                         [self.view hideToast];
                                                         [self.view hideToastActivity];
                                                         [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
                                                         _refreshing = NO;
                                                     }];
}


#pragma mark - private

//- (void)scrollBestView
//{
//    CGPoint contentOffset = _scrollView.contentOffset;
//    if(contentOffset.x >= _scrollView.frame.size.width * [_bestArray count])
//    {
//        [UIView animateWithDuration:0.3 animations:^{
//            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * ([_bestArray count] + 1), 0)];
//            _numberLabel.text = [NSString stringWithFormat:@"1/%i", [_bestArray count]];
//        } completion:^(BOOL finished) {
//            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
//        }];
//    }
//    else
//    {
//        [_scrollView setContentOffset:CGPointMake(contentOffset.x + _scrollView.frame.size.width, 0) animated:YES];
//        NSUInteger currentPage = (contentOffset.x + _scrollView.frame.size.width) / _scrollView.frame.size.width;
//        _numberLabel.text = [NSString stringWithFormat:@"%i/%i", currentPage, [_bestArray count]];
//    }
//}
//
//- (void)startScrollBestView
//{
//    if([_bestArray count] > 0)
//    {
//        if(_timer == nil)
//        {
//            _timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(scrollBestView) userInfo:nil repeats:YES];
//        }
//        [_timer fire];
//    }
//}
//
//- (void)insertFirstImageView
//{
//    NSDictionary * dicttttt = [_bestArray lastObject];
//
//
//    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)] autorelease];
//    imageView.tag = kBestImageViewTag + [_bestArray count] - 1;
//    imageView.backgroundColor = [UIColor clearColor];
//    imageView.userInteractionEnabled = YES;
//
//
//    [imageView setImageWithURL:[NSURL URLWithString:[dicttttt objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"default_best_lastminute.png"]];
//    [_scrollView addSubview:imageView];
//
//    UIImageView *maskView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 57, 320, 50)] autorelease];
//    maskView.backgroundColor = [UIColor clearColor];
//    maskView.image = [UIImage imageNamed:@"image_mask.png"];
//    [imageView addSubview:maskView];
//
//    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 88, 300, 13)] autorelease];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.font = [UIFont systemFontOfSize:12.0f];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.text = [dicttttt objectForKey:@"title"];
//    [imageView addSubview:titleLabel];
//
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//    [imageView addGestureRecognizer:tap];
//    [tap release];
//
//}
//
//
//- (void)insertLastImageView
//{
//    NSDictionary * dicttttt = [_bestArray objectAtIndex:0];
//
//    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width * ([_bestArray count] + 1), 0, _scrollView.frame.size.width, _scrollView.frame.size.height)] autorelease];
//    imageView.tag = kBestImageViewTag;
//    imageView.backgroundColor = [UIColor clearColor];
//    imageView.userInteractionEnabled = YES;
//
//    [imageView setImageWithURL:[NSURL URLWithString:[dicttttt objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"default_best_lastminute.png"]];
//    [_scrollView addSubview:imageView];
//
//    UIImageView *maskView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 57, 320, 50)] autorelease];
//    maskView.backgroundColor = [UIColor clearColor];
//    maskView.image = [UIImage imageNamed:@"image_mask.png"];
//    [imageView addSubview:maskView];
//
//    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 88, 300, 13)] autorelease];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.font = [UIFont systemFontOfSize:12.0f];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.text = [dicttttt objectForKey:@"title"];
//    [imageView addSubview:titleLabel];
//
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//    [imageView addGestureRecognizer:tap];
//    [tap release];
//}
//
//
//- (void)refreshScrollView
//{
//    for(UIView *view in _scrollView.subviews)
//    {
//        if([view tag] >= kBestImageViewTag)
//        {
//            [view removeFromSuperview];
//        }
//    }
//
//    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * ([_bestArray count] + 2), _scrollView.frame.size.height);
//    _pageControl.numberOfPages = [_bestArray count];
//
//    _numberLabel.text = [NSString stringWithFormat:@"1/%lu", (unsigned long)[_bestArray count]];
//
//
//
//    [self insertFirstImageView];
//
//    for(NSUInteger i = 0; i < [_bestArray count]; i++)
//    {
//        NSDictionary * dicccc = [_bestArray objectAtIndex:i];
//
//        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width * (i + 1), 0, _scrollView.frame.size.width, _scrollView.frame.size.height)] autorelease];
//        imageView.tag = kBestImageViewTag + i;
//        imageView.backgroundColor = [UIColor clearColor];
//        imageView.userInteractionEnabled = YES;
//        [imageView setImageWithURL:[NSURL URLWithString:[dicccc objectForKey:@"pic"]] placeholderImage:[UIImage imageNamed:@"default_best_lastminute.png"]];
//        [_scrollView addSubview:imageView];
//
//
//        UIImageView *maskView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 57, 320, 50)] autorelease];
//        maskView.backgroundColor = [UIColor clearColor];
//        maskView.image = [UIImage imageNamed:@"image_mask.png"];
//        [imageView addSubview:maskView];
//
//
//        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 88, 300, 13)] autorelease];
//        titleLabel.backgroundColor = [UIColor clearColor];
//        titleLabel.font = [UIFont systemFontOfSize:12.0f];
//        titleLabel.textColor = [UIColor whiteColor];
//        titleLabel.text = [dicccc objectForKey:@"title"];
//        [imageView addSubview:titleLabel];
//
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//        [imageView addGestureRecognizer:tap];
//        [tap release];
//    }
//
//    [self insertLastImageView];
//
//
//    [_scrollView setContentOffset:CGPointMake(0, 0)];
//
//    [self startScrollBestView];
//}


//-(void)addNotify:(UIButton *)sender
//{
//    BOOL isLogIn = [[[NSUserDefaults standardUserDefaults]objectForKey:@"qyerlogin"] boolValue];
//    if (isLogIn) {
//        
//        AddLastMinuteNotifyViewController * addVC = [[AddLastMinuteNotifyViewController alloc]init];
//        [self.navigationController pushViewController:addVC animated:YES];
//        [addVC release];
//    }
//    else{
//        
//        //未登录状态用户提示登录
//        CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
//        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:cityLoginVC] autorelease];
//        navigationController.navigationBarHidden = YES;
//        
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navigationController animated:YES completion:nil];
//        [cityLoginVC release];
//        
//    }
//}


- (void)dealloc
{
    QY_VIEW_RELEASE(_categoryView);

    QY_VIEW_RELEASE(_lastMinuteButton);
    QY_VIEW_RELEASE(_placeFromButton);
    QY_VIEW_RELEASE(_orderTimeButton);
    QY_VIEW_RELEASE(_poiButton);
    
    QY_VIEW_RELEASE(_scrollView);
    QY_VIEW_RELEASE(_pageControl);
    QY_VIEW_RELEASE(_bestLine);
    QY_VIEW_RELEASE(_numberImageView);
    QY_VIEW_RELEASE(_numberLabel);
    
    QY_VIEW_RELEASE(_gridView);
    QY_VIEW_RELEASE(_slimeView);
    
    QY_VIEW_RELEASE(_refreshMoreView);
    QY_VIEW_RELEASE(_refreshMoreLabel);
    QY_VIEW_RELEASE(_activityIndicatior);
    
    QY_SAFE_RELEASE(_lastMinuteArray);
    QY_SAFE_RELEASE(_bestArray);
    
    QY_VIEW_RELEASE(_categoryRefreshView);
    QY_VIEW_RELEASE(_categoryBackView);
    
    QY_VIEW_RELEASE(_reloadLastMinuteView);
    QY_SAFE_RELEASE(_screenTapReloadTappp);
    
//    [_timer invalidate];
//    [_timer release];
//    _timer = nil;
    
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end



