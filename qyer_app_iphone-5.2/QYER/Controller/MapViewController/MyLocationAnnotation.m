//
//  MyLocationAnnotation.m
//  QyGuide
//
//  Created by an qing on 13-3-15.
//
//

#import "MyLocationAnnotation.h"

@implementation MyLocationAnnotation
@synthesize coordinate;
@synthesize subtitle = _subtitle;
@synthesize title = _title;
@synthesize image = _image;
@synthesize type = _type;

- (void) dealloc
{
    [_type release];
    [_title release];
    [_subtitle release];
    [_image release];
    
    [super dealloc];
}

- (id)initWithCoords:(CLLocationCoordinate2D) coords
{
    self = [super init];
    
    if (self != nil)
    {
        coordinate = coords;
    }
    
    return self;
}

@end
