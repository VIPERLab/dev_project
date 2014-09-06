//
//  SearchViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-6.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideViewCell.h"
#import "PlaceSearchCityCell.h"

@class LoadMoreView;
@class PlaceSearchCityCell;
@interface SearchViewController : UIViewController <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,GuideViewCellDelegate,UIScrollViewDelegate, PlaceSearchCityCellDelegate>
{
    UIImageView             *_headView;
    UISearchBar             *_searchBar;
    NSMutableArray          *_array_result;
    UILabel                 *_label_default;
    UITableView             *_tableView_searchVC;
    NSString                *_guideName_needUpdate;
    
    NSInteger               _position_section_tapCell;  //点击cell的位置section
    NSInteger               _position_row_tapCell;      //点击cell的位置row
    BOOL                    _flag_delay;
    
    //************ Insert By ZhangDong 2014.4.3 Start ***********
    NSInteger               _page;
    BOOL                    _isLoading;
    NSString                *_searchText;
    LoadMoreView            *_loadMoreView;
    UIImageView             *_noResultImageView;
    PlaceSearchCityCell     *_placeSearchCell;
    //************ Insert By ZhangDong 2014.4.3 End ***********
}

/**
 *	@brief	是否目的地视图搜索
 */
@property (nonatomic, assign) BOOL isFromPlace;

@end
