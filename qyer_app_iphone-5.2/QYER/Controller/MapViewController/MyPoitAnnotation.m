//
//  MyPoitAnnotation.m
//  OnLineMap
//
//  Created by an qing on 13-1-30.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "MyPoitAnnotation.h"

@implementation MyPoitAnnotation
@synthesize coordinate = _coordinate;
@synthesize poiId = _poiId;
@synthesize subtitle = _subtitle;
@synthesize title = _title;
@synthesize image = _image;
@synthesize imageUrlString = _imageUrlString;
@synthesize type = _type;
@synthesize cateIdStr = _cateIdStr;
@synthesize lat = _lat;
@synthesize lng = _lng;

- (void) dealloc
{
    [_subtitle release];
    [_title release];
    [_image release];
    [_imageUrlString release];
    [_type release];
    [_cateIdStr release];
    
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    MyPoitAnnotation *point = [[[self class] allocWithZone:zone] init];
    point.coordinate = _coordinate;
    point.poiId = _poiId;
    point.subtitle = _subtitle;
    point.title = _title;
    point.image = _image;
    point.imageUrlString = _imageUrlString;
    point.type = _type;
    point.cateIdStr = _cateIdStr;
    point.lat = _lat;
    point.lng = _lng;
    
    return point;
}

- (id)initWithCoords:(CLLocationCoordinate2D) coords
{
    self = [super init];
    
    if (self != nil)
    {
        self.coordinate = coords;
    }
    
    return self;
}


@end

