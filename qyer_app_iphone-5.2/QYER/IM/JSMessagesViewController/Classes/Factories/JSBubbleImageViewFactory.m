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

#import "JSBubbleImageViewFactory.h"
#import "UIImage+JSMessagesView.h"
#import "UIColor+JSMessagesView.h"

@implementation JSBubbleImageViewFactory

#pragma mark - Initialization

+ (void)initialize
{
}

#pragma mark - Public

+ (UIImageView *)bubbleImageViewForType:(JSBubbleMessageType)type
                                  color:(UIColor *)color
{
    UIImage *bubble = [UIImage imageNamed:@"bubble-classic-square"];
    BOOL isNeedBorder = YES;
    if (color == [UIColor clearColor]) {
        isNeedBorder = NO;
    }
    UIImage *normalBubble = [bubble js_imageMaskWithColor:color needBorder:isNeedBorder];
//    UIImage *highlightedBubble = [bubble js_imageMaskWithColor:[color js_darkenColorWithValue:0.12f] needBorder:isNeedBorder];
    
    if (type == JSBubbleMessageTypeIncoming) {
        normalBubble = [normalBubble js_imageFlippedHorizontal];
//        highlightedBubble = [highlightedBubble js_imageFlippedHorizontal];
    }
    
    // make image stretchable from center point
    CGPoint center = CGPointMake(bubble.size.width / 2.0f, bubble.size.height / 2.0f);
    UIEdgeInsets capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
    
    return [[UIImageView alloc] initWithImage:[normalBubble js_stretchableImageWithCapInsets:capInsets]];
}

@end
