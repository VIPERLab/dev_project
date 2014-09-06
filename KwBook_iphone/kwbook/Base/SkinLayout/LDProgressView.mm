//
//  LDProgressView.m
//  LDProgressView
//
//  Created by Christian Di Lorenzo on 9/27/13.
//  Copyright (c) 2013 Light Design. All rights reserved.
//

#import "LDProgressView.h"
//#import "UIColor+RGBValues.h"
#include "globalm.h"

@interface LDProgressView ()
@property (nonatomic) CGFloat offset;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat stripeWidth;
@property (nonatomic, strong) UIImage *gradientProgress;
@property (nonatomic) CGSize stripeSize;

// Animation of progress
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic) CGFloat progressToAnimateTo;
@end

@implementation LDProgressView
@synthesize animate=_animate, color=_color;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
}

- (void)setAnimate:(NSNumber *)animate {
    _animate = animate;
    if ([animate boolValue]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementOffset) userInfo:nil repeats:YES];
    } else if (self.timer) {
        [self.timer invalidate];
    }
}

- (void)setProgress:(CGFloat)progress {
    self.progressToAnimateTo = progress;
    if (self.animationTimer) {
        [self.animationTimer invalidate];
    }
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(incrementAnimatingProgress) userInfo:nil repeats:YES];
}

- (void)incrementAnimatingProgress {
    if (_progress >= self.progressToAnimateTo-0.01 && _progress <= self.progressToAnimateTo+0.01) {
        _progress = self.progressToAnimateTo;
        [self.animationTimer invalidate];
        [self setNeedsDisplay];
    } else {
        _progress = (_progress < self.progressToAnimateTo) ? _progress + 0.01 : _progress - 0.01;
        [self setNeedsDisplay];
    }
}

- (void)incrementOffset {
    if (self.offset >= 0) {
        self.offset = -self.stripeWidth;
    } else {
        self.offset += 1;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawProgressBackground:context inRect:rect];
    if (self.progress > 0) {
        [self drawProgress:context withFrame:rect];
    }
}

- (void)drawProgressBackground:(CGContextRef)context inRect:(CGRect)rect {
    CGContextSaveGState(context);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.borderRadius.floatValue];
    CGContextSetFillColorWithColor(context, UIColorFromRGBValue(0xCBCBCC).CGColor);
    [roundedRect fill];
    
    UIBezierPath *roundedRectangleNegativePath = [UIBezierPath bezierPathWithRect:CGRectMake(-10, -10, rect.size.width+10, rect.size.height+10)];
    [roundedRectangleNegativePath appendPath:roundedRect];
    roundedRectangleNegativePath.usesEvenOddFillRule = YES;

//    CGSize shadowOffset = CGSizeMake(0.5, 1);
//    CGContextSaveGState(context);
//    CGFloat xOffset = shadowOffset.width + round(rect.size.width);
//    CGFloat yOffset = shadowOffset.height;
//    CGContextSetShadowWithColor(context,
//            CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)), 5, [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor);

    [roundedRect addClip];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(rect.size.width), 0);
    [roundedRectangleNegativePath applyTransform:transform];
    [[UIColor grayColor] setFill];
    [roundedRectangleNegativePath fill];
    CGContextRestoreGState(context);

    // Add clip for drawing progress
    [roundedRect addClip];
}

- (void)drawProgress:(CGContextRef)context withFrame:(CGRect)frame {
    CGRect rectToDrawIn = CGRectMake(0, 0, frame.size.width * self.progress, frame.size.height);

    CGContextSaveGState(context);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rectToDrawIn cornerRadius:self.borderRadius.floatValue];
    CGContextSetFillColorWithColor(context, UIColorFromRGBValue(0x0690D3).CGColor);
    [roundedRect fill];
    
    UIBezierPath *roundedRectangleNegativePath = [UIBezierPath bezierPathWithRect:CGRectMake(-10, -10, rectToDrawIn.size.width+10, rectToDrawIn.size.height+10)];
    [roundedRectangleNegativePath appendPath:roundedRect];
    roundedRectangleNegativePath.usesEvenOddFillRule = YES;
    
    //    CGSize shadowOffset = CGSizeMake(0.5, 1);
    //    CGContextSaveGState(context);
    //    CGFloat xOffset = shadowOffset.width + round(rect.size.width);
    //    CGFloat yOffset = shadowOffset.height;
    //    CGContextSetShadowWithColor(context,
    //            CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)), 5, [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor);
    
    [roundedRect addClip];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(rectToDrawIn.size.width), 0);
    [roundedRectangleNegativePath applyTransform:transform];
    [[UIColor grayColor] setFill];
    [roundedRectangleNegativePath fill];
    CGContextRestoreGState(context);
    
    // Add clip for drawing progress
    [roundedRect addClip];

    if ([self.showText boolValue]) {
        [self drawRightAlignedLabelInRect:rectToDrawIn];
    }
}

- (void)drawGradients:(CGContextRef)context inRect:(CGRect)rect {
    self.stripeSize = CGSizeMake(self.stripeWidth, rect.size.height);
    CGContextSaveGState(context);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.borderRadius.floatValue] addClip];
    CGFloat xStart = self.offset;
    while (xStart < rect.size.width) {
        [self.gradientProgress drawAtPoint:CGPointMake(xStart, 0)];
        xStart += self.stripeWidth;
    }
    CGContextRestoreGState(context);
}

- (void)drawStripes:(CGContextRef)context inRect:(CGRect)rect {
    CGContextSaveGState(context);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.borderRadius.floatValue] addClip];
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.2].CGColor);
    CGFloat xStart = self.offset, height = rect.size.height, width = self.stripeWidth;
    while (xStart < rect.size.width) {
        CGContextSaveGState(context);
        CGContextMoveToPoint(context, xStart, height);
        CGContextAddLineToPoint(context, xStart + width * 0.25, 0);
        CGContextAddLineToPoint(context, xStart + width * 0.75, 0);
        CGContextAddLineToPoint(context, xStart + width * 0.50, height);
        CGContextClosePath(context);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
        xStart += width;
    }
    CGContextRestoreGState(context);
}

- (void)drawRightAlignedLabelInRect:(CGRect)rect {
}

#pragma mark - Accessors

- (NSNumber *)animate {
    if (_animate == nil) {
        return @YES;
    }
    return _animate;
}

- (NSNumber *)showText {
    if (_showText == nil) {
        return @YES;
    }
    return _showText;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.gradientProgress = nil;
}

- (UIColor *)color {
    if (!_color) {
        return [UIColor colorWithRed:0.07 green:0.56 blue:1.0 alpha:1.0];
    }
    return _color;
}

- (CGFloat)stripeWidth {
    switch (self.type) {
        case LDProgressGradient:
            _stripeWidth = 15;
            break;
        default:
            _stripeWidth = 50;
            break;
    }
    return _stripeWidth;
}

- (NSNumber *)borderRadius {
    if (!_borderRadius) {
        return @(self.frame.size.height / 2.0);
    }
    return _borderRadius;
}

@end