//
//  GoogleMapViewController.m
//  QYGuide
//
//  Created by 你猜你猜 on 13-10-16.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "GoogleMapViewController.h"
#import "GetPoiListFromGuide.h"
#import "RichGMSMarker.h"
#import "GetPoiDetailInfo.h"
#import "UIImageView+WebCache.h"
#import "GetInfo.h"
#import <MapKit/MapKit.h>
#import "PoiDetailViewController.h"
#import "CompassView.h"
#import "QYControl.h"
#import "Toast+UIView.h"
#import "GetPoiPositionData.h"



#define  kOverlayHeight         128/2
#define  offsetX_popView        10
#define  height_mapViewHead     38
#define  positionY_mapView      height_mapViewHead




@interface GoogleMapViewController ()

@end





@implementation GoogleMapViewController
@synthesize tap_notEnabled;
@synthesize array_in = _array_in;
@synthesize dic_in;
@synthesize title_navigation = _title_navigation;
@synthesize str_countryName;
@synthesize str_cityId;

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
    self.array_in = nil;
    self.str_countryName = nil;
    self.str_cityId = nil;
    
    [_compassView removeFromSuperview];
    [_compassView release];
    
    [_dic_poiInfo release];
    
    [_array_mapViewHeader_name removeAllObjects];
    [_array_mapViewHeader_name release];
    
    [_pinArray removeAllObjects];
    [_pinArray release];
    
    
    [_array_marks removeAllObjects];
    [_array_marks release];
    
    QY_SAFE_RELEASE(_bottomLine);
    QY_SAFE_RELEASE(_backButton);
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_overlay_map);
    QY_VIEW_RELEASE(_imageView_mapViewHeader);
    QY_VIEW_RELEASE(_imageView_poi);
    QY_VIEW_RELEASE(_label_title_poi);
    QY_VIEW_RELEASE(_label_subtitle_poi);
    QY_VIEW_RELEASE(_turnToPoiDetailControl);
    QY_VIEW_RELEASE(_mapView_background);
    
    QY_SAFE_RELEASE(_selected_marker);
    QY_SAFE_RELEASE(_title_navigation);
    QY_SAFE_RELEASE(_title_poi);
    QY_SAFE_RELEASE(_subtitle_poi);
    QY_SAFE_RELEASE(_overMerit_poi);
    QY_SAFE_RELEASE(_urlPic_poi);
    
    [super dealloc];
}




#pragma mark -
#pragma mark --- viewDidAppear  &  viewDidDisappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(_googleMapView)
    {
        _googleMapView.delegate = self;
    }
    
    
    _flag_isTap = NO;
    if(_flag_init == 1)
    {
        return;
    }
    _flag_init = 1;
    
    
    if(!self.array_in && !self.dic_in) //从目的地页面过来的
    {
        if([self.str_cityId isKindOfClass:[NSString class]] && ![self.str_cityId isEqualToString:@""]) //城市下的poi
        {
            [GetPoiPositionData getAllPoiPositionByCityId:self.str_cityId
                                                           success:^(NSArray *array){
                                                               
                                                               NSLog(@" getAllPoiPositionByCityId - 成功");
                                                               
                                                               if(!_array_in)
                                                               {
                                                                   _array_in = [[NSMutableArray alloc] init];
                                                               }
                                                               [_array_in removeAllObjects];
                                                               
                                                               for(NSDictionary *infoDic in array)
                                                               {
                                                                   if(infoDic && [infoDic objectForKey:@"lat"] && [infoDic objectForKey:@"lng"])
                                                                   {
                                                                       GetPoiListFromGuide *poilistInfo = [[GetPoiListFromGuide alloc] init];
                                                                       poilistInfo.poiId = [[infoDic objectForKey:@"id"] intValue];
                                                                       
                                                                       if([infoDic objectForKey:@"cateid"])
                                                                       {
                                                                           poilistInfo.cateId = [[infoDic objectForKey:@"cateid"] intValue];
                                                                       }
                                                                       else
                                                                       {
                                                                           poilistInfo.cateId = 0;
                                                                       }
                                                                       if([infoDic objectForKey:@"chinesename"])
                                                                       {
                                                                           poilistInfo.chineseName = [infoDic objectForKey:@"chinesename"];
                                                                       }
                                                                       else
                                                                       {
                                                                           poilistInfo.chineseName = @" ";
                                                                       }
                                                                       if([infoDic objectForKey:@"englishname"])
                                                                       {
                                                                           poilistInfo.englishName = [infoDic objectForKey:@"englishname"];
                                                                       }
                                                                       else
                                                                       {
                                                                           poilistInfo.englishName = @"";
                                                                       }
                                                                       poilistInfo.lat = [[infoDic objectForKey:@"lat"] floatValue];
                                                                       poilistInfo.lng = [[infoDic objectForKey:@"lng"] floatValue];
                                                                       if([infoDic objectForKey:@"type"])
                                                                       {
                                                                           poilistInfo.categoryName = [infoDic objectForKey:@"type"];
                                                                       }
                                                                       else
                                                                       {
                                                                           poilistInfo.categoryName = @"";
                                                                       }
                                                                       [_array_in addObject:poilistInfo];
                                                                       [poilistInfo release];
                                                                   }
                                                               }
                                                               
                                                               
                                                               // Ask for My Location data after the map has already been added to the UI.
                                                               if(_array_in && _array_in.count > 0)
                                                               {
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       
                                                                       [self initMapViewHeader];
                                                                       [self initPinarray:_array_in];
                                                                       [self setPoiMarkers];
                                                                       [self fitBounds];
                                                                   });
                                                               }
                                                               
                                                           }
                                                            failed:^{
                                                                NSLog(@" getAllPoiPositionByCityId - 失败");
                                                            }];
        }
        else if([self.str_countryName isKindOfClass:[NSString class]] && ![self.str_countryName isEqualToString:@""]) //国家地图
        {
            [GetPoiPositionData getMapByCountryName:self.str_countryName
                                            success:^(NSArray *array){
                                                
                                                NSLog(@" getMapByCountryName - 成功");
                                                NSLog(@" array : %@",array);
                                                
                                                NSMutableArray *array_in_tmp = [[[NSMutableArray alloc] init] autorelease];
                                                for(NSDictionary *dic_ in array)
                                                {
                                                    if([dic_ objectForKey:@"geometry"])
                                                    {
                                                        NSDictionary *dic__ne = [[[dic_ objectForKey:@"geometry"] objectForKey:@"viewport"] objectForKey:@"northeast"];
                                                        GetPoiListFromGuide *poilistInfo__ne = [[GetPoiListFromGuide alloc] init];
                                                        poilistInfo__ne.lat = [[dic__ne objectForKey:@"lat"] floatValue];
                                                        poilistInfo__ne.lng = [[dic__ne objectForKey:@"lng"] floatValue];
                                                        poilistInfo__ne.cateId = -1; //特殊标识
                                                        [array_in_tmp addObject:poilistInfo__ne];
                                                        [poilistInfo__ne release];
                                                        
                                                        
                                                        
                                                        NSDictionary *dic__sw = [[[dic_ objectForKey:@"geometry"] objectForKey:@"viewport"] objectForKey:@"southwest"];
                                                        GetPoiListFromGuide *poilistInfo_sw = [[GetPoiListFromGuide alloc] init];
                                                        poilistInfo_sw.lat = [[dic__sw objectForKey:@"lat"] floatValue];
                                                        poilistInfo_sw.lng = [[dic__sw objectForKey:@"lng"] floatValue];
                                                        poilistInfo_sw.cateId = -1; //特殊标识
                                                        [array_in_tmp addObject:poilistInfo_sw];
                                                        [poilistInfo_sw release];
                                                        
                                                        
                                                        
                                                        
                                                        // Ask for My Location data after the map has already been added to the UI.
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            if(array_in_tmp.count > 0)
                                                            {
                                                                _googleMapView.frame = CGRectMake(_mapView_background.bounds.origin.x, 0, _mapView_background.bounds.size.width, _mapView_background.bounds.size.height);
                                                                _googleMapView.hidden = YES;
                                                                [self initPinarray:array_in_tmp];
                                                                [self setPoiMarkers];
                                                                [self fitBounds];
                                                                [_googleMapView clear];
                                                                _googleMapView.hidden = NO;
                                                                
                                                                [array_in_tmp removeAllObjects];
//                                                                [array_in_tmp release];
                                                            }
                                                        });
                                                    }
                                                    
                                                }
                                                
                                                if(array_in_tmp.count == 0)
                                                {
                                                    [self clickBackButton:nil];
                                                    
                                                    [array_in_tmp removeAllObjects];
//                                                    [array_in_tmp release];
                                                }
                                            }
                                             failed:^{
                                                 NSLog(@" getAllPoiPositionByCountryOrCityId - 失败");
                                                 [self clickBackButton:nil];
                                             }];
        }
    }
    else
    {
        // Ask for My Location data after the map has already been added to the UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(self.array_in && self.array_in.count > 0)   //多个poi点
            {
                [self initMapViewHeader];
                
                [self initPinarray:self.array_in];
                [self setPoiMarkers];
                [self fitBounds];
            }
            else if(self.dic_in && self.dic_in.count > 0)  //单个poi点
            {
                NSLog(@"frame : %@ ",NSStringFromCGRect(_mapView_background.frame));
                _googleMapView.frame = CGRectMake(_mapView_background.bounds.origin.x, 0, _mapView_background.bounds.size.width, _mapView_background.bounds.size.height);
                NSLog(@"frame : %@ ",NSStringFromCGRect(_googleMapView.frame));
                
                [self setPoiMarkers];
                [self fitBoundsWithOnePoint];
                [self showPoiInfo];
            }
        });
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
    //记录地图的位置:
    if(_googleMapView)
    {
        CGPoint center_frame =  _googleMapView.center;
        CLLocationCoordinate2D center_location = [_googleMapView.projection coordinateForPoint:center_frame];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"location_center"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",center_location.latitude] forKey:@"location_lat"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",center_location.longitude] forKey:@"location_lon"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    
    if(_googleMapView)
    {
        if(_flag_isTap == YES)
        {
            [_googleMapView removeObserver:self
                                forKeyPath:@"myLocation"
                                   context:NULL];
            _flag_isRemoveObserver = YES;
        }
        _googleMapView.myLocationEnabled = NO;
        _googleMapView.delegate = nil;
    }
}


#pragma mark -
#pragma mark --- 构建View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    [self initHomeView];
    [self initNavigationBar];
    [self initMapView];
}
-(void)initHomeView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image =[UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
-(void)initNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    if(ios7)
    {
        _headView.frame = CGRectMake(0, 0, 320, 44+20);
    }
    _headView.backgroundColor = [UIColor colorWithRed:43/255. green:171/255. blue:121/255. alpha:1];
    //_headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    _backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, 3, 40, 40);
    if(ios7)
    {
        _backButton.frame = CGRectMake(0, 3+20, 40, 40);
    }
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
    [self setNavigationTitle:self.title_navigation];
}
-(void)setNavigationTitle:(NSString *)mapTitle
{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 11, 160, 30)];
    if(ios7)
    {
        _titleLabel.frame = CGRectMake(50, 5+20, 320-2*(50), 30);
    }
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.text = [NSString stringWithFormat:@"%@地图",mapTitle];
    [_headView addSubview:_titleLabel];
}
-(void)initMapView
{
    //***(1) googleMap背景:
    if(ios7)
    {
        _mapView_background = [[UIView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, [[UIScreen mainScreen] bounds].size.height - _headView.frame.size.height)];
    }
    else
    {
        _mapView_background = [[UIView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, ([[UIScreen mainScreen] bounds].size.height-20) - _headView.frame.size.height)];
    }
    _mapView_background.backgroundColor = [UIColor clearColor];
    _mapView_background.alpha = 0;
    [self.view addSubview:_mapView_background];
    [self.view makeToastActivity];
    
    
    //***(2) googleMap:
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"location_center"])
    {
        _latitude_center = [[[NSUserDefaults standardUserDefaults] objectForKey:@"location_lat"] floatValue];
        _longitude_center = [[[NSUserDefaults standardUserDefaults] objectForKey:@"location_lon"] floatValue];
    }
    else
    {
        _latitude_center = 39.964;
        _longitude_center = 116.36299;
    }
    //创建google地图:
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_latitude_center
                                                            longitude:_longitude_center
                                                                 zoom:9];
    CGRect bounds = CGRectMake(_mapView_background.bounds.origin.x, positionY_mapView, _mapView_background.bounds.size.width, _mapView_background.bounds.size.height-positionY_mapView);
    if(!_googleMapView)
    {
        _googleMapView = [GMSMapView mapWithFrame:bounds camera:camera];
        _googleMapView.delegate = self;
        //[_googleMapView.settings setAllGesturesEnabled:YES];
        _googleMapView.settings.rotateGestures = NO;
        _googleMapView.settings.zoomGestures = YES;
        _googleMapView.settings.consumesGesturesInView = YES;
        //_googleMapView.settings.compassButton = YES;      //指南针按钮
        //_googleMapView.settings.myLocationButton = YES;   //定位按钮
    }
    [_mapView_background addSubview:_googleMapView];
    _googleMapView.padding = UIEdgeInsetsMake(0, 5, 5, 0);
    
    
    
    //***(3) 定位按钮:
    if(!_locateButton)
    {
        _locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    _locateButton.frame = CGRectMake(320-107/2-5, _mapView_background.frame.size.height-106/2-5, 107/2, 106/2);
    _locateButton.backgroundColor = [UIColor clearColor];
    [_locateButton addTarget:self action:@selector(observerUserLocation) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image = [UIImage imageNamed:@"手动地图icon"];
    [_locateButton setBackgroundImage:image forState:UIControlStateNormal];
    [_mapView_background addSubview:_locateButton];
}



#pragma mark -
#pragma mark --- 接收大头针数据
-(void)initPinarray:(NSArray *)array
{
    if(!array || array.count == 0)
    {
        return;
    }
    
    if(!_pinArray)
    {
        _pinArray = [[NSMutableArray alloc] init];
    }
    [_pinArray removeAllObjects];
    [_pinArray addObjectsFromArray:array];
}
-(void)setPoiMarkers
{
    if(_pinArray && _pinArray.count > 0)
    {
        if(!_array_marks)
        {
            _array_marks = [[NSMutableArray alloc] init];
        }
        [_array_marks removeAllObjects];
        
        for(int i = 0; i < [_pinArray count]; i++)
        {
            GetPoiListFromGuide *poilistInfo = (GetPoiListFromGuide *)[_pinArray objectAtIndex:i];
            
            RichGMSMarker *marker_poi = [[RichGMSMarker alloc] init];
            marker_poi.icon = [self setImageByCateid:poilistInfo.cateId];
            if(poilistInfo && poilistInfo.chineseName)
            {
                //marker_poi.snippet = poilistInfo.chineseName;
                marker_poi.title = [NSString stringWithFormat:@"%@",poilistInfo.chineseName];
            }
            else
            {
                //marker_poi.snippet = @" ";
                marker_poi.title = @" ";
            }
            if(poilistInfo && poilistInfo.englishName)
            {
                marker_poi.subtitle = [NSString stringWithFormat:@"%@",poilistInfo.englishName];
            }
            else
            {
                marker_poi.subtitle = @" ";
            }
            marker_poi.poiId = [NSString stringWithFormat:@"%d",poilistInfo.poiId];
            marker_poi.cateId = [NSString stringWithFormat:@"%d",poilistInfo.cateId];
            CLLocationCoordinate2D theCenterofMarker;
            theCenterofMarker.latitude = poilistInfo.lat;
            theCenterofMarker.longitude = poilistInfo.lng;
            marker_poi.position = theCenterofMarker;
            marker_poi.map = _googleMapView;
            [_array_marks addObject:marker_poi];
            [marker_poi release];
        }
        
    }
    else if(self.dic_in && self.dic_in.count > 0)
    {
        RichGMSMarker *marker_poi = [[RichGMSMarker alloc] init];
        marker_poi.icon = [self setImageByCateid:[[self.dic_in valueForKey:@"cateid"] intValue]];
        if([self.dic_in valueForKey:@"_chineseTitle"])
        {
            //marker_poi.snippet = [self.dic_in valueForKey:@"_chineseTitle"];
            marker_poi.title = [self.dic_in valueForKey:@"_chineseTitle"];
        }
        else
        {
            //marker_poi.snippet = @" ";
            marker_poi.title = @" ";
        }
        if([self.dic_in objectForKey:@"_englishTitle"])
        {
            marker_poi.subtitle = [self.dic_in objectForKey:@"_englishTitle"];
        }
        else
        {
            marker_poi.subtitle = @" ";
        }
        marker_poi.poiId = [NSString stringWithFormat:@"%@",[self.dic_in valueForKey:@"poiId"]];
        marker_poi.cateId = [NSString stringWithFormat:@"%@",[self.dic_in valueForKey:@"cateid"]];
        CLLocationCoordinate2D theCenterofMarker;
        theCenterofMarker.latitude = [[self.dic_in valueForKey:@"lat"] floatValue];
        theCenterofMarker.longitude = [[self.dic_in valueForKey:@"lng"] floatValue];
        marker_poi.position = theCenterofMarker;
        marker_poi.map = _googleMapView;
        [_array_marks addObject:marker_poi];
        [marker_poi release];
        
        
        _poiId = [[self.dic_in valueForKey:@"poiId"] intValue];
        _title_poi = [[NSString stringWithFormat:@"%@",[self.dic_in valueForKey:@"_chineseTitle"]] retain];
        _subtitle_poi = [[NSString stringWithFormat:@"%@",[self.dic_in valueForKey:@"_englishTitle"]] retain];
        _lat_poi = [[self.dic_in valueForKey:@"lat"] floatValue];
        _lng_poi = [[self.dic_in valueForKey:@"lng"] floatValue];
    }
}
-(UIImage *)setImageByCateid:(NSInteger)cate_id
{
    if(cate_id == 32) //景点
    {
        UIImage *image = [UIImage imageNamed:@"景点"];
        
        return image;
    }
    else if(cate_id == 77) //交通
    {
        UIImage *image = [UIImage imageNamed:@"交通"];
        
        return image;
    }
    else if(cate_id == 78) //美食
    {
        UIImage *image = [UIImage imageNamed:@"美食"];
        
        return image;
    }
    else if(cate_id == 147) //购物
    {
        UIImage *image = [UIImage imageNamed:@"购物"];
        
        return image;
    }
    else if(cate_id == 148) //活动
    {
        UIImage *image = [UIImage imageNamed:@"活动"];
        
        return image;
    }
    else if(cate_id == 149) //酒店
    {
        UIImage *image = [UIImage imageNamed:@"酒店"];
        
        return image;
    }
    else if(cate_id == -1)
    {
        UIImage *image = [UIImage imageNamed:@""];
        
        return image;
    }
    //else if(cate_id == 150) //实用信息
    //{
    //    return nil;
    //}
    //else if(cate_id == 151) //路线
    //{
    //    return nil;
    //}
    else
    {
        UIImage *image = [UIImage imageNamed:@"其他"];
        
        return image;
    }
    
    return nil;
}
-(void)fitBounds
{
    GMSCoordinateBounds *bounds = nil;
    for(GMSMarker *marker in _array_marks)
    {
        if(bounds == nil)
        {
            bounds = [[[GMSCoordinateBounds alloc] initWithCoordinate:marker.position
                                                          coordinate:marker.position] autorelease];
        }
        bounds = [bounds includingCoordinate:marker.position];
    }
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds
                                             withPadding:50.];
    [_googleMapView moveCamera:update];
    
    
    _mapView_background.alpha = 1;
    [self.view hideToastActivity];
}
-(void)fitBoundsWithOnePoint
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.1];  //animation second
    CLLocationCoordinate2D position;
    position.latitude = _lat_poi;
    position.longitude = _lng_poi;
    GMSCameraPosition *camera = [[GMSCameraPosition alloc] initWithTarget:position
                                                                     zoom:16
                                                                  bearing:0
                                                             viewingAngle:90];
    [_googleMapView animateToCameraPosition:camera];
    [camera release];
    [CATransaction commit];
    
    _mapView_background.alpha = 1;
    [self.view hideToastActivity];
}



#pragma mark -
#pragma mark --- 定位
-(void)observerUserLocation
{
    if(_flag_isTap && !_flag_isRemoveObserver)
    {
        [_googleMapView removeObserver:self
                            forKeyPath:@"myLocation"
                               context:NULL];
        _firstLocationUpdate = NO;
    }
    _flag_isTap = YES;
    _flag_isRemoveObserver = NO;
    
    _googleMapView.myLocationEnabled = YES;
    
    
    //Listen to the myLocation property of GMSMapView.
    [_googleMapView addObserver:self
                     forKeyPath:@"myLocation"
                        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                        context:NULL];
}
//KVO updates:
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if([keyPath isEqualToString:@"myLocation"])
    {
        [self initUserdirection];
        
        if(!_firstLocationUpdate)
        {
            // If the first location update has not yet been recieved, then jump to that
            // location.
            if(_googleMapView)
            {
                _firstLocationUpdate = YES;
                CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
                _googleMapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                                       zoom:16];
                
                
                
                
                //保存位置:
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"lat_user"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"lon_user"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
        }
    }
    
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}
-(void)initUserdirection
{
    float positionY = 5;
    if(self.array_in && self.array_in.count > 0)
    {
        positionY = 5 + _imageView_mapViewHeader.frame.size.height;
    }
    
    if(!_compassView)
    {
        _compassView = [[CompassView alloc] initWithFrame:CGRectMake(275, positionY, 40, 40) andImage:[UIImage imageNamed:@"我得位置"]];
    }
    else
    {
        CGRect frame = _compassView.frame;
        frame.origin.y = positionY;
        _compassView.frame = frame;
    }
    
    [_mapView_background addSubview:_compassView];
}



#pragma mark -
#pragma mark --- GMSMapViewDelegate
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    NSLog(@"  自定义点击大头针的popview  ");
    
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 70/2)];
    [background setBackgroundColor:[UIColor clearColor]];
    
    
    UIImageView *imageView_arrow = [[UIImageView alloc] initWithFrame:CGRectMake((background.frame.size.width - 40/2)/2, background.frame.size.height - 16/2, 40/2, 16/2)];
    imageView_arrow.backgroundColor = [UIColor clearColor];
    imageView_arrow.image = [UIImage imageNamed:@"气泡_箭头"];
    
    
    
    UIImage *image_pop = [UIImage imageNamed:@"气泡"];
    UIImageView *imageView_pop = [[UIImageView alloc] initWithFrame:CGRectMake((background.frame.size.width - image_pop.size.width)/2, -6, image_pop.size.width, image_pop.size.height)];
    imageView_pop.userInteractionEnabled = YES;
    imageView_pop.backgroundColor = [UIColor clearColor];
    image_pop = [image_pop stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    imageView_pop.image = image_pop;
    
    
    
    
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(offsetX_popView, 3, imageView_pop.frame.size.width-2*offsetX_popView, imageView_pop.frame.size.height-8)];
    label.backgroundColor = [UIColor clearColor];
    if(_title_poi && _title_poi.length > 0 && ![_title_poi isEqualToString:@" "])
    {
        label.text = _title_poi;
    }
    else if(_subtitle_poi)
    {
        label.text = _subtitle_poi;
    }
    else
    {
        label.text = @" ";
    }
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    
    
    
    float width = [self countContentLengthByString:label.text andFontNmae:label.font.fontName andHeight:image_pop.size.height andFontSize:15];
    width = ceilf(width)+1;
    if(width - label.frame.size.width > 0)
    {
        CGRect frame = label.frame;
        frame.size.width = width;
        label.frame = frame;
    }
    else if(width - 300 >= 0) //特殊情况
    {
        CGRect frame = label.frame;
        frame.size.width = 300;
        label.frame = frame;
    }
    
    width = width + 2*offsetX_popView;
    if(width - image_pop.size.width > 0)
    {
        CGRect frame = imageView_pop.frame;
        frame.size.width = width;
        frame.origin.x = (320 - width)/2.;
        imageView_pop.frame = frame;
    }
    else if(width - 320 >= 0) //特殊情况
    {
        CGRect frame = imageView_pop.frame;
        frame.size.width = 320;
        frame.origin.x = 0;
        imageView_pop.frame = frame;
    }
    
    
    
    [imageView_pop addSubview:label];
    [label release];
    [background addSubview:imageView_pop];
    [imageView_pop release];
    [background addSubview:imageView_arrow];
    [imageView_arrow release];
    return [background autorelease];
    
}
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    NSLog(@"  点击大头针时调用  ");
    
    mapView.selectedMarker = nil;
    RichGMSMarker *rich_mark = (RichGMSMarker *)marker;
    
    
    
    UIEdgeInsets padding = _googleMapView.padding;
    NSLog(@"  padding.bottom : %f",padding.bottom);
    if((((rich_mark && rich_mark.title && _title_poi && [rich_mark.title isEqualToString:_title_poi]) && !(self.dic_in && self.dic_in.count) && (padding.bottom - 0. != 0)) &&
        ((rich_mark && _subtitle_poi && [rich_mark.subtitle isEqualToString:_subtitle_poi])))&& !(self.dic_in && self.dic_in.count) && (padding.bottom - 0. != 0))
    {
        return NO;
    }
    
    
    _poiId = [rich_mark.poiId intValue];
    if(_title_poi && _title_poi.retainCount > 0)
    {
        [_title_poi release];
    }
    _title_poi = [rich_mark.title retain];
    if(_subtitle_poi && _subtitle_poi.retainCount > 0)
    {
        [_subtitle_poi release];
    }
    _subtitle_poi = [rich_mark.subtitle retain];
    _lat_poi = marker.position.latitude;
    _lng_poi = marker.position.longitude;
    [self showPoiInfo];
    
    
    return NO;
}
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    //NSLog(@"  点击大头针的popview时调用  ");
}
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    //NSLog(@"  点击地图上大头针以外的地方时调用  ");
    [self hidePoiInfo];
}



#pragma mark -
#pragma mark --- 计算String所占的高度
-(float)countContentLengthByString:(NSString*)content andFontNmae:(NSString *)fontName andHeight:(float)height andFontSize:(float)font
{
    if(!fontName)
    {
        CGSize sizeToFit = [content sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)];
        return sizeToFit.width;
    }
    else
    {
        CGSize sizeToFit = [content sizeWithFont:[UIFont fontWithName:fontName size:font] constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)];
        return sizeToFit.width;
    }
}



#pragma mark -
#pragma mark --- 单个poi的地图页自动弹出详情
-(void)showPoiInfo
{
    [self initOverlay];
    
    UIEdgeInsets padding = _googleMapView.padding;
    if(padding.top - kOverlayHeight == 0)
    {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGSize size = _mapView_background.bounds.size;
        _overlay_map.frame = CGRectMake(0, size.height - kOverlayHeight, size.width, kOverlayHeight);
        _googleMapView.padding = UIEdgeInsetsMake(kOverlayHeight, 5, kOverlayHeight+5, 0);
        //_googleMapView.padding = UIEdgeInsetsMake(0, 0, kOverlayHeight, 0);
        
        _locateButton.frame = CGRectMake(320-107/2-5, _mapView_background.frame.size.height-106/2-5 -kOverlayHeight, 107/2, 106/2);
    }];
}
-(void)initOverlay
{
    if(!_overlay_map)
    {
        _overlay_map = [[UIImageView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, 320, kOverlayHeight)];
        _overlay_map.userInteractionEnabled = YES;
        _overlay_map.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _overlay_map.backgroundColor = [UIColor colorWithRed:241/255. green:240/255. blue:238/255. alpha:1];
        _overlay_map.image = [UIImage imageNamed:@"dock_bg"];
    }
    [_mapView_background addSubview:_overlay_map];
    
    [self initPoiInfo];
}
-(void)hidePoiInfo
{
    _poiId = 0;
    _lat_poi = 0.;
    _lng_poi = 0.;
    
    
    UIEdgeInsets padding = _googleMapView.padding;
    if(padding.bottom - 0. == 0)
    {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGSize size = _mapView_background.bounds.size;
        _overlay_map.frame = CGRectMake(0, size.height, size.width, kOverlayHeight);
        //_googleMapView.padding = UIEdgeInsetsZero;
        _googleMapView.padding = UIEdgeInsetsMake(0, 5, 5, 0);
        
        _locateButton.frame = CGRectMake(320-107/2-5, _mapView_background.frame.size.height-106/2-5, 107/2, 106/2);
    }];
}
-(void)initPoiInfo
{
    if(self.tap_notEnabled == NO)
    {
        if(!_turnToPoiDetailControl)
        {
            _turnToPoiDetailControl = [[QYControl alloc] initWithFrame:CGRectMake(0, 1, 245, kOverlayHeight-1) andBackGroundColor:[UIColor colorWithRed:245/255. green:245/255. blue:245/255. alpha:1]];
            [_turnToPoiDetailControl setBackgroundColor:[UIColor clearColor]];
            [_turnToPoiDetailControl addTarget:self action:@selector(turnToPoiDetail) forControlEvents:UIControlEventTouchUpInside];
        }
        [_overlay_map addSubview:_turnToPoiDetailControl];
    }
    
    
    if(!_label_title_poi)
    {
        if(ios7)
        {
            _label_title_poi = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 230, 22)];
        }
        else
        {
            _label_title_poi = [[UILabel alloc] initWithFrame:CGRectMake(10, 13+2, 230, 24)];
        }
        _label_title_poi.backgroundColor = [UIColor clearColor];
        _label_title_poi.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        _label_title_poi.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
        _label_title_poi.textAlignment = NSTextAlignmentLeft;
    }
    _label_title_poi.text = @" ";
    [_overlay_map addSubview:_label_title_poi];
    
    
    if(!_label_subtitle_poi)
    {
        _label_subtitle_poi = [[UILabel alloc] initWithFrame:CGRectMake(_label_title_poi.frame.origin.x, _label_title_poi.frame.origin.y+_label_title_poi.frame.size.height+4, 230, 18)];
        _label_subtitle_poi.backgroundColor = [UIColor clearColor];
        _label_subtitle_poi.textAlignment = NSTextAlignmentLeft;
    }
    _label_subtitle_poi.frame = CGRectMake(_label_title_poi.frame.origin.x, _label_title_poi.frame.origin.y+_label_title_poi.frame.size.height+4, 230, 18);
    _label_subtitle_poi.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:11];
    _label_subtitle_poi.textColor = [UIColor colorWithRed:158/255. green:163/255. blue:171/255. alpha:1];
    _label_subtitle_poi.text = @" ";
    [_overlay_map addSubview:_label_subtitle_poi];
    
    
    if(!_turnToSystemMapButton)
    {
        _turnToSystemMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _turnToSystemMapButton.frame = CGRectMake(320-128/2-10, 0, 128/2, 128/2);
        [_turnToSystemMapButton setBackgroundColor:[UIColor clearColor]];
        UIImage *image_turnToSystemMapButton = [UIImage imageNamed:@"路线"];
        [_turnToSystemMapButton setBackgroundImage:image_turnToSystemMapButton forState:UIControlStateNormal];
        //UIImage *image_turnToSystemMapButton_select = [UIImage imageNamed:@"路线pressed"];
        //[_turnToSystemMapButton setBackgroundImage:image_turnToSystemMapButton_select forState:UIControlStateHighlighted];
        [_turnToSystemMapButton addTarget:self action:@selector(turnToSystemMap) forControlEvents:UIControlEventTouchUpInside];
    }
    [_overlay_map addSubview:_turnToSystemMapButton];
    
    
    _label_title_poi.text = _title_poi;
    _label_subtitle_poi.text = _subtitle_poi;
    
    
    //特殊情况处理(没有中文名称):
    if(!_title_poi || [_title_poi isEqualToString:@" "] || _title_poi.length == 0 )
    {
        _label_subtitle_poi.frame = CGRectMake(_label_title_poi.frame.origin.x, (_overlay_map.frame.size.height-1-18)/2, 230, 18);
        _label_subtitle_poi.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
        _label_subtitle_poi.textColor = [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
    }
    
}



#pragma mark -
#pragma mark --- turnToSystemMap  &  turnToPoiDetail
-(void)turnToSystemMap
{
    NSString *version = [[GetInfo getDeviceInfoSystemVersion] retain];
    if([version floatValue] - 6. < 0)
    {
        [version release];
        
        //***(1).通过坐标跳转到google地图
        float latitudeTurnTo = _lat_poi;
        float longitudeTurnTo = _lng_poi;
        NSString *url = [NSString stringWithFormat:@"http://maps.google.com/?q=%f,%f",latitudeTurnTo,longitudeTurnTo];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    else
    {
        [version release];
        
        CLLocationCoordinate2D location;
        location.latitude = _lat_poi;
        location.longitude = _lng_poi;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil];
        MKMapItem *item = [[[MKMapItem alloc] initWithPlacemark:placemark] autorelease];
        [placemark release];
        if(_title_poi && _title_poi.length > 0)
        {
            [item setName:_title_poi];
        }
        else
        {
            [item setName:_subtitle_poi];
        }
        //[item setPhoneNumber:@"+86 15501197655"];
        //[item setUrl:[NSURL URLWithString:@"http://www.m.qyer.com"]];
        NSDictionary *mapLaunchOptions = [NSDictionary dictionaryWithObjectsAndKeys:@"title",@"title", nil];
        [item openInMapsWithLaunchOptions:mapLaunchOptions];
    }
}
-(void)turnToPoiDetail
{
    PoiDetailViewController *poiDetailVC = [[PoiDetailViewController alloc] init];
    poiDetailVC.poiId = _poiId;
    [self.navigationController pushViewController:poiDetailVC animated:YES];
    [poiDetailVC release];
}


#pragma mark -
#pragma mark --- init - MapViewHeader
-(void)initMapViewHeader
{
    if(ios7)
    {
        if(!_imageView_mapViewHeader)
        {
            _imageView_mapViewHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_mapViewHead)];
            //_imageView_mapViewHeader.image = [UIImage imageNamed:@"背景"];
            _imageView_mapViewHeader.userInteractionEnabled = YES;
            _imageView_mapViewHeader.backgroundColor = [UIColor clearColor];
        }
    }
    else
    {
        if(!_imageView_mapViewHeader)
        {
            _imageView_mapViewHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_mapViewHead)];
            //_imageView_mapViewHeader.image = [UIImage imageNamed:@"背景"];
            _imageView_mapViewHeader.userInteractionEnabled = YES;
            _imageView_mapViewHeader.backgroundColor = [UIColor clearColor];
        }
    }
    [_mapView_background addSubview:_imageView_mapViewHeader];
    
    [self initArray_mapViewHeader];
    [self initPoiStytleInView];
}
-(void)initArray_mapViewHeader
{
    if(!_array_mapViewHeader_name)
    {
        _array_mapViewHeader_name = [[NSMutableArray alloc] init];
    }
    [_array_mapViewHeader_name removeAllObjects];
    
    [_array_mapViewHeader_name addObject:@"全部"];
    [_array_mapViewHeader_name addObject:@"景点"];
    [_array_mapViewHeader_name addObject:@"美食"];
    [_array_mapViewHeader_name addObject:@"购物"];
    [_array_mapViewHeader_name addObject:@"娱乐"];
}
-(void)initPoiStytleInView
{
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, _imageView_mapViewHeader.frame.size.height-1, 320, 1)];
    line.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [_imageView_mapViewHeader addSubview:line];
    [line release];
    
    if(!_bottomLine)
    {
        _bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 38-2, 64, 2)];
        _bottomLine.backgroundColor = [UIColor colorWithRed:43/255. green:171/255. blue:121/255. alpha:1];
        [_imageView_mapViewHeader addSubview:_bottomLine];
    }
    
    for(int i = 0; i < _array_mapViewHeader_name.count; i++)
    {
        NSString *name = [_array_mapViewHeader_name objectAtIndex:i];
        NSInteger positionX = 63*i;
        
        UIButton *button_poiStytle = [UIButton buttonWithType:UIButtonTypeCustom];
        button_poiStytle.backgroundColor = [UIColor clearColor];
        button_poiStytle.frame = CGRectMake(positionX, 0, 63, 38);
        button_poiStytle.tag = i+10;
        button_poiStytle.titleLabel.font = [UIFont systemFontOfSize:14];
        [button_poiStytle setTitle:name forState:UIControlStateNormal];
        [button_poiStytle setTitleColor:[UIColor colorWithRed:130/255. green:153/255. blue:165/255. alpha:1] forState:UIControlStateNormal];
        [button_poiStytle setTitleColor:[UIColor colorWithRed:44/255. green:171/255. blue:121/255. alpha:1] forState:UIControlStateSelected];
        [button_poiStytle addTarget:self action:@selector(select_style:) forControlEvents:UIControlEventTouchUpInside];
        [_imageView_mapViewHeader addSubview:button_poiStytle];
        
        
        if(i < _array_mapViewHeader_name.count-1)
        {
            UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(button_poiStytle.frame.origin.x+button_poiStytle.frame.size.width, button_poiStytle.frame.origin.y+11, 1, button_poiStytle.frame.size.height-22)];
            line.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
            [_imageView_mapViewHeader addSubview:line];
            [line release];
        }
        
        
        if(i == 0)
        {
            [self select_style:button_poiStytle];
        }
    }
}
-(void)select_style:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if(button.selected)
    {
        return;
    }
    [self changeState:button];
    
    switch (button.tag)
    {
        case 10:
        {
            NSLog(@" 选择－全部");
            
            CGRect frame = _bottomLine.frame;
            frame.origin.x = 0;
            _bottomLine.frame = frame;
            [self screenOutPoiByStytle:@"0"];
        }
            break;
        case 11:
        {
            NSLog(@" 选择－景点");
            
            CGRect frame = _bottomLine.frame;
            frame.origin.x = 64;
            _bottomLine.frame = frame;
            [self screenOutPoiByStytle:@"32"];
        }
            break;
        case 12:
        {
            NSLog(@" 选择－美食");
            
            CGRect frame = _bottomLine.frame;
            frame.origin.x = 64*2;
            _bottomLine.frame = frame;
            [self screenOutPoiByStytle:@"78"];
        }
            break;
        case 13:
        {
            NSLog(@" 选择－购物");
            
            CGRect frame = _bottomLine.frame;
            frame.origin.x = 64*3;
            _bottomLine.frame = frame;
            [self screenOutPoiByStytle:@"147"];
        }
            break;
        case 14:
        {
            NSLog(@" 选择－活动");
            
            CGRect frame = _bottomLine.frame;
            frame.origin.x = 64*4;
            _bottomLine.frame = frame;
            [self screenOutPoiByStytle:@"148"];
        }
            break;
            
        default:
            break;
    }
}
-(void)changeState:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    switch (button.tag)
    {
        case 10:
        {
            NSLog(@"全部");
            
            [button setSelected:YES];
            button.userInteractionEnabled = NO;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:11];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:12];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:13];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:14];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
        }
            break;
        case 11:
        {
            NSLog(@"景点");
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:10];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:11];
            [button setSelected:YES];
            button.userInteractionEnabled = NO;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:12];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:13];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:14];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
        }
            break;
        case 12:
        {
            NSLog(@"美食");
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:10];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:11];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:12];
            [button setSelected:YES];
            button.userInteractionEnabled = NO;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:13];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:14];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
        }
            break;
        case 13:
        {
            NSLog(@"购物");
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:10];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:11];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:12];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:13];
            [button setSelected:YES];
            button.userInteractionEnabled = NO;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:14];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
        }
            break;
        case 14:
        {
            NSLog(@"活动");
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:10];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:11];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:12];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:13];
            [button setSelected:NO];
            button.userInteractionEnabled = YES;
            
            button = (UIButton *)[_imageView_mapViewHeader viewWithTag:14];
            [button setSelected:YES];
            button.userInteractionEnabled = NO;
            
        }
            break;
            
        default:
            break;
    }
}



-(void)screenOutPoiByStytle:(NSString *)cate_id
{
    switch ([cate_id intValue])
    {
        case 0:
        {
            [_googleMapView clear];
            
            [self initPinarray:self.array_in];
            [self setPoiMarkers];
        }
            break;
        default:
        {
            [self screenOutWithCateId:cate_id];
        }
            break;
    }
}
-(void)screenOutWithCateId:(NSString *)cate_id
{
    if(_pinArray)
    {
        [_googleMapView clear];
        [_pinArray removeAllObjects];
    }
    
    for(GetPoiListFromGuide *poilistInfo in self.array_in)
    {
        if([[NSString stringWithFormat:@"%d",poilistInfo.cateId] isEqualToString:cate_id])
        {
            [_pinArray addObject:poilistInfo];
        }
    }
    
    if(_pinArray && _pinArray.count > 0)
    {
        [self setPoiMarkers];
    }
}



#pragma mark -
#pragma mark --- clickBackButton
-(void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

