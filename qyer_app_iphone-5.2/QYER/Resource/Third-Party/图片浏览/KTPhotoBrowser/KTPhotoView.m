//
//  KTPhotoView.m
//  Sample
//
//  Created by Kirby Turner on 2/24/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "KTPhotoView.h"
#import "KTPhotoScrollViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface KTPhotoView (KTPrivateMethods)
- (void)loadSubviewsWithFrame:(CGRect)frame;
- (BOOL)isZoomed;
- (void)toggleChromeDisplay;
@end

@implementation KTPhotoView

@synthesize scroller = scroller_;
@synthesize index = index_;

- (void)dealloc
{
    [imageView_ release], imageView_ = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        [self setDelegate:self];
        
        
        
        
        
//        [self setDelegate:self];
//        [self setDelegate:self];
//        [self setMaximumZoomScale:2];
//        [self setShowsHorizontalScrollIndicator:NO];
//        [self setShowsVerticalScrollIndicator:NO];
//        [self loadSubviewsWithFrame:frame];
    }
    return self;
}


//- (void)loadSubviewsWithFrame:(CGRect)frame
//{
//    imageView_ = [[UIImageView alloc] initWithFrame:frame];
//    [imageView_ setContentMode:UIViewContentModeScaleAspectFit];
//    [self addSubview:imageView_];
//}
//
//- (void)setImage:(UIImage *)newImage
//{
////    float positionX = 0;
////    float positionY = 0;
////    float width = newImage.size.width/2;
////    float height = newImage.size.height/2;
////    float screen_height = [[UIScreen mainScreen] bounds].size.height;
////    float screen_width = [[UIScreen mainScreen] bounds].size.width;
////    
////    if(newImage.size.width >= 320)
////    {
////        if(height >= [[UIScreen mainScreen] bounds].size.height)
////        {
////            float scale_h = height/screen_height;
////            float scale_w = width/screen_width;
////            
////            if(scale_h - scale_w >= 0) //上下满屏
////            {
////                positionX = (width-screen_width)/2;
////                width = width*height/height;
////            }
////            else if(scale_w - scale_h >= 0) //左右满屏
////            {
////                positionY = (height-screen_height)/2;
////                height = height*screen_width/width;
////            }
////        }
////        else if(height < [[UIScreen mainScreen] bounds].size.height)
////        {
////            height = height*screen_width/width;
////            width = 320;
////            positionX = 0;
////            positionY = ([[UIScreen mainScreen] bounds].size.height-height)/2;
////        }
////    }
////    else if(newImage.size.width < 320)
////    {
////        if(newImage.size.height < [[UIScreen mainScreen] bounds].size.height)
////        {
////            
////        }
////        else if(newImage.size.height >= [[UIScreen mainScreen] bounds].size.height)
////        {
////            positionX = ([[UIScreen mainScreen] bounds].size.width-newImage.size.width)/2;
////        }
////    }
////    CGRect frame = CGRectMake(positionX, positionY, width, height);
////    [self loadSubviewsWithFrame:frame];
//    [imageView_ setImage:newImage];
//}
//
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    if ([self isZoomed] == NO && CGRectEqualToRect([self bounds], [imageView_ frame]) == NO)
//    {
//        NSLog(@" === FUCK ===");
//        [imageView_ setFrame:[self bounds]];
//    }
//}
//
//- (void)toggleChromeDisplay
//{
//    if (scroller_)
//    {
//        [scroller_ toggleChromeDisplay];
//    }
//}
//
//- (BOOL)isZoomed
//{
//    return !([self zoomScale] == [self minimumZoomScale]);
//}
//
//- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
//{
//    
//    CGRect zoomRect;
//    
//    // the zoom rect is in the content view's coordinates.
//    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
//    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
//    zoomRect.size.height = [self frame].size.height / scale;
//    zoomRect.size.width  = [self frame].size.width  / scale;
//    
//    
//    
//    // choose an origin so as to get the right center.
//    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
//    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
//    
//    return zoomRect;
//}
//
//- (void)zoomToLocation:(CGPoint)location
//{
//    float newScale;
//    CGRect zoomRect;
//    if ([self isZoomed])
//    {
//        zoomRect = [self bounds];
//    }
//    else
//    {
//        newScale = [self maximumZoomScale];
//        zoomRect = [self zoomRectForScale:newScale withCenter:self.center];
//    }
//    
//    NSLog(@" zoomRect : %@",NSStringFromCGRect(zoomRect));
//    [self zoomToRect:zoomRect animated:YES];
//}
//
//- (void)turnOffZoom
//{
//    if ([self isZoomed])
//    {
//        [self zoomToLocation:CGPointZero];
//    }
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    
//    if ([touch view] == self)
//    {
//        if([touch tapCount] == 1)
//        {
//            scroller_.hidenStatusFlag = !scroller_.hidenStatusFlag;
//        }
//        else if ([touch tapCount] == 2)
//        {
//            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleChromeDisplay) object:nil];
//            [self zoomToLocation:[touch locationInView:self]];
//        }
//    }
//}
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    
//    if ([touch view] == self)
//    {
//        if([touch tapCount] == 1)
//        {
//            scroller_.hidenStatusFlag = !scroller_.hidenStatusFlag;
//        }
//    }
//}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    
//    if ([touch view] == self)
//    {
//        if ([touch tapCount] == 1)
//        {
//            [self performSelector:@selector(toggleChromeDisplay) withObject:nil afterDelay:0.0];
//        }
//    }
//}
//
//
//#pragma mark -
//#pragma mark UIScrollViewDelegate Methods
//
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    UIView *viewToZoom = imageView_;
//    return viewToZoom;
//}
//
//
//#pragma mark -
//#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image
//
//- (void)setMaxMinZoomScalesForCurrentBounds
//{
////    CGSize boundsSize = self.bounds.size;
////    CGSize imageSize = imageView_.bounds.size;
////    
////    // calculate min/max zoomscale
////    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
////    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
////    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
////    
////    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
////    // maximum zoom scale to 0.5.
////    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
////    
////    
////    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
////    if (minScale > maxScale) {
////        minScale = maxScale;
////    }
////    
////    self.maximumZoomScale = maxScale;
////    self.minimumZoomScale = minScale;
//}
//
//// returns the center point, in image coordinate space, to try to restore after rotation.
//- (CGPoint)pointToCenterAfterRotation
//{
////    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
////    return [self convertPoint:boundsCenter toView:imageView_];
//    
//    
//    return CGPointZero;
//}
//
//// returns the zoom scale to attempt to restore after rotation.
//- (CGFloat)scaleToRestoreAfterRotation
//{
////    CGFloat contentScale = self.zoomScale;
////    
////    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
////    // allowable scale when the scale is restored.
////    if (contentScale <= self.minimumZoomScale + FLT_EPSILON)
////        contentScale = 0;
////    
////    return contentScale;
//    
//    
//    
//    return 0;
//}
//
//- (CGPoint)maximumContentOffset
//{
////    CGSize contentSize = self.contentSize;
////    CGSize boundsSize = self.bounds.size;
////    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
//    
//    
//    return CGPointZero;
//}
//
//- (CGPoint)minimumContentOffset
//{
//    return CGPointZero;
//}
//
//// Adjusts content offset and scale to try to preserve the old zoomscale and center.
//- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale
//{
////    // Step 1: restore zoom scale, first making sure it is within the allowable range.
////    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, oldScale));
////    
////    
////    // Step 2: restore center point, first making sure it is within the allowable range.
////    
////    // 2a: convert our desired center point back to our own coordinate space
////    CGPoint boundsCenter = [self convertPoint:oldCenter fromView:imageView_];
////    // 2b: calculate the content offset that would yield that center point
////    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
////                                 boundsCenter.y - self.bounds.size.height / 2.0);
////    // 2c: restore offset, adjusted to be within the allowable range
////    CGPoint maxOffset = [self maximumContentOffset];
////    CGPoint minOffset = [self minimumContentOffset];
////    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
////    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
////    self.contentOffset = offset;
//}





- (void)setImage:(UIImage *)image
{
    
    if(!image)
    {
        return;
    }
    imageView_ = [[UIImageView alloc] initWithImage:image];
    
    if(imageView_.image.size.width / imageView_.image.size.height > 320 / self.frame.size.height)
    {
        self.contentSize = CGSizeMake(imageView_.image.size.width / imageView_.image.size.height * self.frame.size.height, self.frame.size.height);
    }
    else
    {
        self.contentSize = CGSizeMake(self.frame.size.width, imageView_.image.size.height / imageView_.image.size.width * self.frame.size.width);
    }
    
    imageView_.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    imageView_.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView_];
    
    self.minimumZoomScale = MIN(self.frame.size.width / self.contentSize.width, self.frame.size.height / self.contentSize.height);
    self.maximumZoomScale = imageView_.image.size.width / 320;
    self.zoomScale = self.minimumZoomScale;
    
    
    
    imageView_.userInteractionEnabled = YES;
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [imageView_ addGestureRecognizer:twoFingerTapRecognizer];
    [twoFingerTapRecognizer release];
    
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [imageView_ addGestureRecognizer:doubleTapRecognizer];
    [doubleTapRecognizer release];
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [imageView_ addGestureRecognizer:tap];
    [tap requireGestureRecognizerToFail:doubleTapRecognizer];
    [tap release];
}

-(void)tap:(UITapGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        scroller_.hidenStatusFlag = !scroller_.hidenStatusFlag;
        [self performSelector:@selector(toggleChromeDisplay) withObject:nil afterDelay:0.0];
    }
}

- (void)centerScrollViewContents
{
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = imageView_.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    imageView_.frame = contentsFrame;
}


- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer
{
    // 1
    CGPoint pointInView = [recognizer locationInView:imageView_];
    
    // 2
    CGFloat newZoomScale;// = _scrollView.zoomScale * 1.5f;
    //    newZoomScale = MIN(newZoomScale, _scrollView.maximumZoomScale);
    
    if(self.zoomScale == self.maximumZoomScale)
    {
        newZoomScale = self.minimumZoomScale;
    }
    else
    {
        newZoomScale = self.maximumZoomScale;
    }
    
    // 3
    CGSize scrollViewSize = self.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer
{
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.minimumZoomScale);
    [self setZoomScale:newZoomScale animated:YES];
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView_;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}
- (void)turnOffZoom
{

}
- (void)toggleChromeDisplay
{
    if (scroller_)
    {
        [scroller_ toggleChromeDisplay];
    }
}


@end
