//
//  UserMap.h
//  QYER
//
//  Created by 我去 on 14-5-15.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface UserMap : UIView <GMSMapViewDelegate>
{
    GMSMapView          *_googleMapView;
    UIView              *_mapView_background;
    CLLocationDegrees   _longitude_center;
    CLLocationDegrees   _latitude_center;
    NSMutableArray      *_array_marks;
    CGFloat             _lat_poi;
    CGFloat             _lng_poi;
}
-(void)showMapWithArray:(NSArray *)array inView:(UIView *)view;
@end
