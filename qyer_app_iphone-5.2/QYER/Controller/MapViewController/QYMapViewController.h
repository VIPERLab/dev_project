//
//  QYMapViewController.h
//  QyGuide
//
//  Created by an qing on 13-3-12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MyPoitAnnotation.h"
#import "MyCallOutAnnotationView.h"
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@protocol MapViewControllerDidSelectDelegate;
@class MyPopAnnotation;
@class MyLocationAnnotation;
@class CustomOverlayView;

@interface QYMapViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate,MYCalloutPopViewDelegate,CLLocationManagerDelegate>
{
    BOOL            _isShowPoiFlag;
    UIImageView     *_headView;
    UIButton        *_backButton;
    UIButton        *_locateButton;
    BOOL            _showPopViewFlag;       //是否默认显示popview(单个poi时会默认显示popview)
    BOOL            _isShowCurrentLocation; //是否已定位
    
    BOOL            _isFromReadVCAndOnlyOnePoint;
    
    //*** 在线地图
    MKMapView *_myMapView;
    UITapGestureRecognizer *_tap;
    
    //CLLocationManager *locationManager;
    CLLocationCoordinate2D theCenter;
    MKCoordinateSpan theSpan;
    
    NSDictionary *_poilistInfoDic;
    
    NSMutableArray *_poilistInfoDataArray;
    
    float weidu;
    float jingdu;
    
    NSMutableArray *_pinArray;
    NSMutableArray *_pinArray_copy;
    
    
    MyPopAnnotation *_calloutAnnotation_autoShow;
    MyPopAnnotation *_calloutAnnotation;
    id<MapViewControllerDidSelectDelegate> delegate;
    
    UIActivityIndicatorView *_activityView;
    BOOL isShowPopView;  //是否显示popView
    float tapWeidu;      //点击的大头针的纬度
    float tapJingdu;     //点击的大头针的经度
    
    
    //_ _ 点击的大头针的信息 - GEGIN
    NSString  *_chineseName;
    NSString  *_englishName;
    NSInteger _cateId;
    float     _lat;
    float     _lng;
    NSInteger _poiId;
    //_ _ 点击的大头针的信息 - END
    
    
    MKAnnotationView *_myPositionView;
    
    
    //动态显示手机的方向
    CLLocationCoordinate2D  currentLocation;
    CLLocationDirection     currentHeading;
    
    
    CLLocationManager      *_locationManager;
    MyLocationAnnotation   *_minePoint;
    
    BOOL                   _isRecenter;
    BOOL                   _didUpdateToLocation;
    BOOL                   _isrejectiveUseLocation;\
    BOOL                   _fromPoidetailVC;
    
    
    
    UILabel *testLabel;
    UILabel *testLabel2;
    UILabel *testLabel3;
    UILabel *testLabel4;
    BOOL falseFlag;
    CGAffineTransform headingRotation_copy;
    
    CustomOverlayView *overlayView;
    
    
    UIImageView     *_imageView_mapViewHeader;
    NSMutableArray  *_array_mapViewHeader;
    NSMutableArray  *_array_mapViewHeader_unselect;
    
    NSMutableDictionary     *_dataDic;
    BOOL                    _flag_getDataSuccess;
    BOOL                    _flag_pointOnly; //mapview中只有一个点的情况
}
@property(nonatomic,assign) BOOL showPopViewFlag; //是否从poi详情页推出和autoshowpopview的标志
@property(nonatomic,assign) BOOL isFromReadVCAndOnlyOnePoint;
@property(nonatomic,assign) id<MapViewControllerDidSelectDelegate> delegate;
@property (nonatomic, retain) MyPopAnnotation *pressAnnotation;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) CLLocationDirection currentHeading;
@property(nonatomic,assign) BOOL fromPoidetailVC;
-(void)initPinarray:(NSArray*)array;
-(void)initPinarrayWithDic:(NSDictionary*)dic;
-(void)setNavigationTitle:(NSString*)title;
-(void)setRegion;
-(void)setFromReadVC;
@end


#pragma mark -
#pragma mark --- MapViewControllerDidSelectDelegate
@protocol MapViewControllerDidSelectDelegate <NSObject>

@optional
- (void)customMKMapViewDidSelectedWithInfo:(id)info;

@end

