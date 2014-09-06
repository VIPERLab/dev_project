//
//  MyPopAnnotation.h
//  OnLineMap
//
//  Created by an qing on 13-1-31.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyPopAnnotation : NSObject <MKAnnotation>
{
    CLLocationDegrees _latitude;
    CLLocationDegrees _longitude;
    
    UIImage           *_calloutImage;
    
    NSString    *_title;            //chinesetitle
    NSString    *_subtitle;         //englishtitle
    UIImage     *_image;            //大头针的图片
    NSString    *_imageUrlString;
    NSString    *_type;
    NSString    *_cateIdStr;        //poi类别
    NSInteger   _poiId;
    float       _lat;
    float       _lng;
}

@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;
@property (nonatomic, assign)  NSInteger poiId;
@property (nonatomic, retain)  UIImage *calloutImage;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) UIImage  *image;
@property (nonatomic, retain) NSString *imageUrlString;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *cateIdStr;
@property (nonatomic,assign) float    lat;
@property (nonatomic,assign) float    lng;

- (id)initWithLatitude:(CLLocationDegrees)latitude
		  andLongitude:(CLLocationDegrees)longitude;
@end
