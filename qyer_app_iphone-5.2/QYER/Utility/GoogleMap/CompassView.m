//
//  CompassView.m
//  QYGuide
//
//  Created by 你猜你猜 on 13-11-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "CompassView.h"


#define toRad(X) (X*M_PI/180.0)



@implementation CompassView
@synthesize locationManager = _locationManager;
@synthesize currentHeading = _currentHeading;


-(void)dealloc
{
    [_compassView removeFromSuperview];
    [_compassView release];
    
    self.locationManager = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _compassView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _compassView.image = image;
        [self addSubview:_compassView];
        
        [self customInitialize];
        [self adjustImageViewDirection];
    }
    return self;
}



#pragma mark -
#pragma mark --- 动态显示手机的方向
- (void)customInitialize
{
    self.currentHeading = 0.0;
}
-(void)adjustImageViewDirection
{
    [self startLocationHeadingEvents];
    [self updateHeadingDisplays];
}
- (void)startLocationHeadingEvents
{
    if (_locationManager == nil)
    {
        _locationManager =  [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable])
    {
        _locationManager.headingFilter = kCLHeadingFilterNone;
        [_locationManager startUpdatingHeading];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
    self.currentHeading = theHeading;
    
    [self updateHeadingDisplays];
}

- (void)updateHeadingDisplays
{
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGAffineTransform headingRotation;
                         //headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, toRad(self.currentHeading));
                         headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-toRad(self.currentHeading)); //指北针
                         _compassView.transform = headingRotation;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
