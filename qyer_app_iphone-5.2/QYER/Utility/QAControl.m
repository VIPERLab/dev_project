//
//  QAControl.m
//  QYGuide
//
//  Created by 你猜你猜 on 13-11-21.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "QAControl.h"

@implementation QAControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}



#pragma mark -
#pragma mark --- Track - event
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    return YES;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    return NO;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    
}
- (void)cancelTrackingWithEvent:(UIEvent *)event   // event may be nil if cancelled for non-event reasons, e.g. removed from window
{
    [super cancelTrackingWithEvent:event];
    
}





#pragma mark -
#pragma mark --- touches - event
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    [self performSelector:@selector(resetBackgroundColor) withObject:nil afterDelay:0.1];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self performSelector:@selector(resetBackgroundColor) withObject:nil afterDelay:0.1];
}
-(void)resetBackgroundColor
{
    self.backgroundColor = [UIColor clearColor];
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
