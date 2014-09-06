//
//  CompassView.h
//  QYGuide
//
//  Created by 你猜你猜 on 13-11-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLHeading.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface CompassView : UIView <CLLocationManagerDelegate,CLLocationManagerDelegate>
{
    CLLocationManager       *_locationManager;
    CLLocationDirection     _currentHeading;
    UIImageView             *_compassView;
}

@property (nonatomic, retain) CLLocationManager   *locationManager;
@property (nonatomic, assign) CLLocationDirection currentHeading;

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image;

@end
