//
//  Locate.mm
//  KwSing
//
//  Created by 单 永杰 on 13-3-22.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import "Locate.h"
#import "KwConfig.h"
#import "KwConfigElements.h"

@interface KSLocate()<CLLocationManagerDelegate>
@end

@implementation KSLocate

static KSLocate* s_shared_locate = nil;

+ (KSLocate*) sharedInstance{
    if (nil == s_shared_locate) {
        s_shared_locate = [[KSLocate alloc] init];
    }
    
    return s_shared_locate;
}

- (void) startLocate{
    if (nil == m_pLocationManager) {
        m_pLocationManager = [[CLLocationManager alloc] init];
    }
    if ([CLLocationManager locationServicesEnabled]) {
        [m_pLocationManager setDelegate:self];
        m_pLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        [m_pLocationManager startUpdatingLocation];
    }else {
        KwConfig::GetConfigureInstance()->SetConfigStringValue(CURRENT_LOCATE, CITY_LOCATE, "");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation* p_location = (CLLocation*)[locations objectAtIndex:([locations count] - 1)];
    [self startedReverseGeoderWithLatitude:p_location.coordinate.latitude longitude:p_location.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    [self startedReverseGeoderWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    KwConfig::GetConfigureInstance()->SetConfigStringValue(CURRENT_LOCATE, CITY_LOCATE, "");
    if (nil != m_pLocationManager) {
        [m_pLocationManager stopUpdatingLocation];
    }
}

- (void)startedReverseGeoderWithLatitude:(double)f_latitude longitude:(double)f_longitude{
    CLGeocoder* p_geo_coder = [[[CLGeocoder alloc] init] autorelease];
    [p_geo_coder reverseGeocodeLocation:([[[CLLocation alloc] initWithLatitude:f_latitude longitude:f_longitude] autorelease]) completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark* p_place in placemarks) {
            KwConfig::GetConfigureInstance()->SetConfigStringValue(CURRENT_LOCATE, CITY_LOCATE, [((NSString*)[p_place.addressDictionary objectForKey:@"State"]) UTF8String]);
        }
    }];
    
    [m_pLocationManager stopUpdatingLocation];
}

- (void)dealloc{
    if (m_pLocationManager) {
        [m_pLocationManager release];
        m_pLocationManager = nil;
    }
    
    [super dealloc];
}
@end

