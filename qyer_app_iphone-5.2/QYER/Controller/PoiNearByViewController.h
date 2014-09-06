//
//  PoiNearByViewController.h
//  QYER
//
//  Created by 我去 on 14-8-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GetHotelNearbyPoi;

@interface PoiNearByViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    UIImageView         *_headView;
    UILabel             *_titleLabel;
    UIButton            *_backButton;
    NSMutableArray      *_array_data;
    UITableView         *_tableView_poiNearBy;
    NSInteger           _pageNumber;
    GetHotelNearbyPoi   *_getHotelNearbyPoi_fromServer;
    UIView              *_footerView;
    
//    BOOL                _flag_getMore;          //是否还可以加载更多数据
//    BOOL                _reloading;             //是否还在请求数据
//    BOOL                _flag_pullToLoading;    //是否正在上拉加载更多
}

@property(nonatomic,retain) NSString *navigationTitle;
@property(nonatomic,assign) NSInteger poiId;
@property(nonatomic,assign) NSInteger categoryId;
@property(nonatomic,assign) float lat;
@property(nonatomic,assign) float lon;
@property(nonatomic,assign) BOOL hotel_nearBy;

@end
