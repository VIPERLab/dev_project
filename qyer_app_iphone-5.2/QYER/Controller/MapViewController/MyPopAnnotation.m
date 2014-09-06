//
//  MyPopAnnotation.m
//  OnLineMap
//
//  Created by an qing on 13-1-31.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "MyPopAnnotation.h"

@implementation MyPopAnnotation
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize poiId = _poiId;
@synthesize calloutImage = _calloutImage;
@synthesize subtitle = _subtitle;
@synthesize title = _title;
@synthesize image = _image;
@synthesize imageUrlString = _imageUrlString;
@synthesize type = _type;
@synthesize cateIdStr = _cateIdStr;
@synthesize lat = _lat;
@synthesize lng = _lng;


-(void)dealloc
{
    self.calloutImage = nil;
    self.title = nil;
    self.subtitle = nil;
    self.type = nil;
    self.imageUrlString = nil;
    self.cateIdStr = nil;
    self.image = nil;
    
    [super dealloc];
}

- (id)initWithLatitude:(CLLocationDegrees)latitude
		  andLongitude:(CLLocationDegrees)longitude
{
	if (self = [super init]) {
		self.latitude = latitude;
		self.longitude = longitude;
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate
{
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = self.latitude;
	coordinate.longitude = self.longitude;
	return coordinate;
}

@end
