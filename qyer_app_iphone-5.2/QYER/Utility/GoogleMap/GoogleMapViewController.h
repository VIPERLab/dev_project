//
//  GoogleMapViewController.h
//  QYGuide
//
//  Created by 你猜你猜 on 13-10-16.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
@class CompassView;
@class QYControl;

@interface GoogleMapViewController : UIViewController  <GMSMapViewDelegate>
{
    UIImageView         *_headView;
    UILabel             *_titleLabel;
    UIButton            *_backButton;
    
    BOOL                _flag_init;
    BOOL                _flag_isTap;            //是否点击了定位按钮
    BOOL                _flag_isRemoveObserver; //是否删除了监听
    UILabel             *_bottomLine;
    
    UIView              *_mapView_background;
    GMSMapView          *_googleMapView;
    GMSMarker           *_selected_marker;
    NSMutableArray      *_pinArray;
    NSMutableArray      *_array_marks;
    UIImageView         *_overlay_map;
    CLLocationDegrees   _longitude_center;
    CLLocationDegrees   _latitude_center;
    NSString            *_title_navigation;
    NSMutableArray      *_array_in;
    
    UIImageView         *_imageView_mapViewHeader;
    NSMutableArray      *_array_mapViewHeader_name;
    
    UIButton            *_locateButton;
    BOOL                _firstLocationUpdate;
    CompassView         *_compassView;
    
    UIImageView         *_imageView_poi;
    UILabel             *_label_title_poi;
    UILabel             *_label_subtitle_poi;
    UIButton            *_turnToSystemMapButton;
    QYControl           *_turnToPoiDetailControl;
    BOOL                _flag_getDataSuccess;
    NSMutableDictionary *_dic_poiInfo;
    NSInteger           _poiId;
    NSString            *_title_poi;
    NSString            *_subtitle_poi;
    NSString            *_overMerit_poi;       //poi的综合评价
    NSString            *_urlPic_poi;          //poi图片链接
    CGFloat             _lat_poi;
    CGFloat             _lng_poi;
}
@property(nonatomic,assign) BOOL tap_notEnabled;
@property(nonatomic,retain) NSMutableArray *array_in;
@property(nonatomic,retain) NSDictionary *dic_in;
@property(nonatomic,retain) NSString *title_navigation;
@property(nonatomic,retain) NSString *str_countryName; //国家名称
@property(nonatomic,retain) NSString *str_cityId;      //城市id

-(void)setNavigationTitle:(NSString *)mapTitle;

@end
