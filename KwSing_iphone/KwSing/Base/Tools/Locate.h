//
//  Locate.h
//  KwSing
//
//  Created by 单 永杰 on 13-3-22.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface KSLocate : NSObject<CLLocationManagerDelegate>{
    CLLocationManager* m_pLocationManager;
}

+ (KSLocate*) sharedInstance;
- (void) startLocate;

@end
