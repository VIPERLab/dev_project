//
//  UIViewTap.h
//  Momento
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TapDetectingViewDelegate;

@interface TapDetectingView : UIView {
	id <TapDetectingViewDelegate> tapDelegate;
}
@property (nonatomic, assign) id <TapDetectingViewDelegate> tapDelegate;
- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;
- (void)handleTouch:(UITouch *)touch;
@end

@protocol TapDetectingViewDelegate <NSObject>
@optional
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view touchDetected:(UITouch*)touch;
@end