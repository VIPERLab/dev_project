//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "UIColor+JSMessagesView.h"

@implementation UIColor (JSMessagesView)

#pragma mark - Colors

+ (UIColor *)js_backgroundColorClassic
{
    return [UIColor colorWithRed:232/255. green:243/255. blue:249/255. alpha:1];
}

+ (UIColor *)js_messagesTimestampColorClassic
{
    return [UIColor whiteColor];
}

+ (UIColor *)js_messagesSubtitleColorClassic
{
    return [UIColor colorWithRed:68/255. green:68/255. blue:68/255. alpha:1];
}


#pragma mark - Bubble colors

+ (UIColor *)js_bubbleGreenColor
{
    return [UIColor colorWithHue:130.0f / 360.0f
                      saturation:0.68f
                      brightness:0.80f
                           alpha:1.0f];
}

+ (UIColor *)js_bubbleBlueColor
{
    return [UIColor colorWithHue:210.0f / 360.0f
                      saturation:0.94f
                      brightness:1.0f
                           alpha:1.0f];
}

+ (UIColor *)js_bubbleLightGrayColor
{
    return [UIColor colorWithHue:240.0f / 360.0f
                      saturation:0.02f
                      brightness:0.92f
                           alpha:1.0f];
}

#pragma mark - Utilities

- (UIColor *)js_darkenColorWithValue:(CGFloat)value
{
    NSUInteger totalComponents = CGColorGetNumberOfComponents(self.CGColor);
    BOOL isGreyscale = (totalComponents == 2) ? YES : NO;
    
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents(self.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[2] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[3] = oldComponents[1];
    }
    else {
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[1] - value < 0.0f ? 0.0f : oldComponents[1] - value;
        newComponents[2] = oldComponents[2] - value < 0.0f ? 0.0f : oldComponents[2] - value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
    return retColor;
}

@end