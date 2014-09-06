//
//  ListViewController.h
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-6-24.
//
//

#import <UIKit/UIKit.h>
//#import "BaseViewController.h"
#import "SMGridView.h"
#import "LastMinuteView.h"
#import "CategoryButton.h"
#import "SMPageControl.h"
#import "SRRefreshView.h"
#import "CategoryRefreshView.h"

@class ODRefreshControl;
@interface LastMinuteViewController : UIViewController <SMGridViewDelegate, SMGridViewDataSource, UIScrollViewDelegate, LastMinuteViewDelegate, SRRefreshDelegate, CategoryRefreshViewDelegate>
{
    UIImageView         *_logoImageView;
//    UIButton            *_moreButton;
    UIView              *_categoryView;
    UIImageView         *_categoryShadowImageView;
    
    CategoryButton      *_lastMinuteButton;
    CategoryButton      *_placeFromButton;
    CategoryButton      *_orderTimeButton;
    CategoryButton      *_poiButton;
    
    UIView              *_gridHeaderView;
    UIScrollView        *_scrollView;
    SMPageControl       *_pageControl;
    UIImageView         *_bestLine;
    UIImageView         *_numberImageView;
    UILabel             *_numberLabel;
    
    SMGridView          *_gridView;
    SRRefreshView       *_slimeView;
    
    UIView                      *_refreshMoreView;
    UILabel                     *_refreshMoreLabel;
    UIActivityIndicatorView     *_activityIndicatior;
    
    UIView              *_noMoreView;
    UIImageView         *_noMoreIcon;
    
    NSMutableArray      *_lastMinuteArray;
    NSMutableArray      *_bestArray;
    
    BOOL                _refreshing;
    BOOL                _canRefreshMore;
    
    CategoryRefreshView *_categoryRefreshView;
    
    NSUInteger          _categoryType;
    NSString            *_orderTime;
    NSUInteger          _continentId;
    NSUInteger          _countryId;
    NSString            *_departure;
    
    UIView              *_categoryBackView;
    
//    NSTimer             *_timer;
    
//    UIButton            *_drawerButton;
    //    UIView              *_drawerBackView;
    //    UIView              *_drawerTapView;
    //    UITableView         *_drawerTableView;
    
    UIViewController    *_homeViewController;
    
    
    UIView              *_tabBottomView;//TabBar上的半透明View;
    
    
    //************ Insert By ZhangDong 2014.4.8 Start ************
    //判断是否已经触摸单元格的图片，用来排除两个图片同时触摸导致的BUG
    BOOL _isTapedImage;
    //下拉刷新
    ODRefreshControl *_refreshControl;
    //************ Insert By ZhangDong 2014.4.8 End ************
    
    
    UIView                  *_reloadLastMinuteView;//无缓存加载折扣信息的View
    UITapGestureRecognizer  *_screenTapReloadTappp;//点击重新加载的单击方法
    
    BOOL                    _forbidTapDetailView;//滚动的时候禁止点击折扣详情界面
}


@property (assign, nonatomic) UIViewController *homeViewController;


@end
