//
//  UserMap.m
//  QYER
//
//  Created by 我去 on 14-5-15.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "UserMap.h"
#import "RichGMSMarker.h"


@implementation UserMap

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(void)showMapWithArray:(NSArray *)array inView:(UIView *)view
{
    [view addSubview:self];
    
    
    self.backgroundColor = [UIColor yellowColor];
    NSLog(@" width  : %f",self.bounds.size.width);
    NSLog(@" height : %f",self.bounds.size.height);
    
    
    
    
    //***(1) googleMap背景:
    _mapView_background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _mapView_background.backgroundColor = [UIColor clearColor];
    [self addSubview:_mapView_background];
    
    
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
                                                                 zoom:0];
    CGRect bounds = CGRectMake(_mapView_background.bounds.origin.x, _mapView_background.bounds.origin.y, _mapView_background.bounds.size.width, _mapView_background.bounds.size.height);
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
    //_googleMapView.userInteractionEnabled = NO;
    
    
    [self setPoiMarkersWithArray:array];
    [self fitBounds];
}
-(void)setPoiMarkersWithArray:(NSArray *)array
{
    if(!_array_marks)
    {
        _array_marks = [[NSMutableArray alloc] init];
    }
    [_array_marks removeAllObjects];
    
    for(int i = 0; i < [array count]; i++)
    {
        NSDictionary *dic = [array objectAtIndex:i];
        
        RichGMSMarker *marker_poi = [[RichGMSMarker alloc] init];
        if(dic && [dic objectForKey:@"city_cn"])
        {
            marker_poi.title = [NSString stringWithFormat:@"%@",[dic objectForKey:@"city_cn"]];
        }
        else
        {
            marker_poi.title = @" ";
        }
        if(dic && [dic objectForKey:@"city_en"])
        {
            marker_poi.subtitle = [NSString stringWithFormat:@"%@",[dic objectForKey:@"city_en"]];
        }
        else
        {
            marker_poi.subtitle = @" ";
        }
        //marker_poi.poiId = [NSString stringWithFormat:@"%d",poilistInfo.poiId];
        //marker_poi.cateId = [NSString stringWithFormat:@"%d",poilistInfo.cateId];
        CLLocationCoordinate2D theCenterofMarker;
        theCenterofMarker.latitude = [[dic objectForKey:@"lat"] floatValue];
        theCenterofMarker.longitude = [[dic objectForKey:@"lon"] floatValue];
        marker_poi.position = theCenterofMarker;
        marker_poi.map = _googleMapView;
        [_array_marks addObject:marker_poi];
        [marker_poi release];
    }
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
    
}
-(void)fitBoundsWithOnePoint
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.1];  //animation second
    CLLocationCoordinate2D position;
    position.latitude = _lat_poi;
    position.longitude = _lng_poi;
    GMSCameraPosition *camera = [[GMSCameraPosition alloc] initWithTarget:position
                                                                     zoom:0
                                                                  bearing:0
                                                             viewingAngle:90];
    [_googleMapView animateToCameraPosition:camera];
    [camera release];
    [CATransaction commit];
    
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
