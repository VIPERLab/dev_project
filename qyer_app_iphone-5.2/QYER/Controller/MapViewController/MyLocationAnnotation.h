//
//  MyLocationAnnotation.h
//  QyGuide
//
//  Created by an qing on 13-3-15.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyLocationAnnotation : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *_title;
    NSString *_subtitle;
    UIImage  *_image;
    NSString *_type;
}

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *subtitle;
@property (nonatomic,retain) UIImage *image;
@property (nonatomic,retain) NSString *type;

-(id)initWithCoords:(CLLocationCoordinate2D) coords;

@end

