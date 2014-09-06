//
//  SegmentControl.h
//  KWPlayer
//
//  Created by mistyzyq on 11-10-15.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//  从音乐盒搬过来

#import <UIKit/UIKit.h>
#import "SegmentControlDelegate.h"

@interface UIButton (Categories)
+ (UIButton*) buttonWithTitle:(NSString*)title 
                  imageNormal:(UIImage*)imageNormal
             imageHighlighted:(UIImage*)imageHighlighted
                       target:(id)target
                       action:(SEL)action;
@end


enum SEGMENT_ALIGNMENT {
	SEGMENT_ALIGNMENT_DEFAULT = (1 << 0) | (1 << 3) | (1 << 6),	// SEGMENT_ALIGNMENT_DISTRIBUTED | SEGMENT_ALIGNMENT_CENTER | SEGMENT_ALIGNMENT_MIDDLE
	SEGMENT_ALIGNMENT_DISTRIBUTED = 1 << 0,
    SEGMENT_ALIGNMENT_AVERAGE = 1 << 1,
	SEGMENT_ALIGNMENT_LEFT = 1 << 2,
	SEGMENT_ALIGNMENT_CENTER = 1 << 3,
	SEGMENT_ALIGNMENT_RIGHT = 1 << 4,
	SEGMENT_ALIGNMENT_TOP = 1 << 5,
	SEGMENT_ALIGNMENT_MIDDLE = 1 << 6,
	SEGMENT_ALIGNMENT_BOTTOM = 1 << 7,
};

@interface SegmentControl : UIControl {
	id<SegmentControlDelegate> delegate;
	
	NSMutableArray* _items;	// UIButton item
	NSInteger _selectedSegmentIndex;

	CGSize _segmentSpace;
	CGSize _segmentSize;
    UIEdgeInsets _edgeInsets;
	
	NSUInteger _segmentAlignment;
	NSUInteger _maxNumberOfItemsPerLine;

	UIColor* _textColor;
	UIColor* _textColorSelected;

	UIColor* _textShadowColor;
	UIColor* _textShadowColorSelected;
	
	UIImageView* _backgroundImageView;
	
	UIImage* _segmentBackgroundImageFirst;
	UIImage* _segmentBackgroundImageSelectedFirst;
	UIImage* _segmentBackgroundImage;
	UIImage* _segmentBackgroundImageSelected;
	UIImage* _segmentBackgroundImageLast;
	UIImage* _segmentBackgroundImageSelectedLast;
}

@property (nonatomic, assign) id<SegmentControlDelegate> delegate;

@property (nonatomic, readonly) NSUInteger numberOfSegments;

// Set this property to -1 (default) to turn off the current selection
@property (nonatomic) NSInteger selectedSegmentIndex;

@property (nonatomic) CGSize segmentSpace;
@property (nonatomic) CGSize segmentSize;

@property (nonatomic) UIEdgeInsets edgeInsets;

@property (nonatomic) NSUInteger segmentAlignment;
@property (nonatomic) NSUInteger maxNumberOfItemsPerLine;

@property (nonatomic, retain) UIColor* textColor;
@property (nonatomic, retain) UIColor* textColorSelected;

@property (nonatomic, retain) UIColor* textShadowColor;
@property (nonatomic, retain) UIColor* textShadowColorSelected;

@property (nonatomic, retain) UIImage* backgroundImage;

@property (nonatomic, retain) UIImage* segmentBackgroundImageFirst;
@property (nonatomic, retain) UIImage* segmentBackgroundImageSelectedFirst;
@property (nonatomic, retain) UIImage* segmentBackgroundImage;
@property (nonatomic, retain) UIImage* segmentBackgroundImageSelected;
@property (nonatomic, retain) UIImage* segmentBackgroundImageLast;
@property (nonatomic, retain) UIImage* segmentBackgroundImageSelectedLast;


// An array of NSString objects (for segment titles) or UIImage objects (for segment images).
- (id) initWithItems:(NSArray*)items;

- (void) setSegmentBackgroundImage:(UIImage *)img selectedImage:(UIImage*)imgSel;
- (void) setSegmentBackgroundImageFirst:(UIImage *)img selectedImage:(UIImage*)imgSel;
- (void) setSegmentBackgroundImageLast:(UIImage *)img selectedImage:(UIImage*)imgSel;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;
- (NSString*) titleForSegmentAtIndex:(NSUInteger)segment;

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;
- (UIImage*) imageForSegmentAtIndex:(NSUInteger)segment;

- (NSUInteger) numberOfItemsPerLineThatFitsWidth:(CGFloat)width;

- (UIButton*) segmentButtonAtIndex:(NSUInteger)segment;
- (NSUInteger) segmentIndexForObject:(id)object;

- (CGRect) contentRectForBounds:(CGRect)bounds;

- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated;
- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated;

- (void) removeAllSegments;
- (void) removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated;

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment;
- (BOOL) isEnabledForSegmentAtIndex:(NSUInteger)segment;

- (void) onSegmentTouched:(id)sender;
- (void) onSegmentDowned:(id)sender;

@end
