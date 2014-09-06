//
//  MyPoitAnnotation.h
//  OnLineMap
//
//  Created by an qing on 13-1-30.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MyPoitAnnotation : NSObject <MKAnnotation,NSCopying>
{
    CLLocationCoordinate2D _coordinate;
    NSString        *_title;            //chinesetitle
    NSString        *_subtitle;         //englishtitle
    UIImage         *_image;            //大头针的图片
    NSString        *_imageUrlString;
    NSString        *_type;
    NSString        *_cateIdStr;        //poi类别
    NSInteger       _poiId;
    float           _lat;
    float           _lng;
}

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,assign) NSInteger      poiId;
@property (nonatomic,retain) NSString       *title;
@property (nonatomic,retain) NSString       *subtitle;
@property (nonatomic,retain) UIImage        *image;
@property (nonatomic,retain) NSString       *imageUrlString;
@property (nonatomic,retain) NSString       *type;
@property (nonatomic,retain) NSString       *cateIdStr;
@property (nonatomic,assign) float          lat;
@property (nonatomic,assign) float          lng;

-(id)initWithCoords:(CLLocationCoordinate2D) coords;


@end
