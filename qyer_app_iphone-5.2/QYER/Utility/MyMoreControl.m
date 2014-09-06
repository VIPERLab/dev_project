//
//  MyMoreControl.m
//  iPhoneJinNang
//
//  Created by 安庆 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyMoreControl.h"
#import <QuartzCore/QuartzCore.h>

@implementation MyMoreControl
@synthesize url,appName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    self.appName = nil;
    self.url = nil;
    [frontView removeFromSuperview];
    [frontView release];
    
    [super dealloc];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if(!frontView)
    {
        frontView = [[UIView alloc] init];
    }
    [self setForegroundColor:[UIColor colorWithRed:193./255 green:222./255 blue:233./255 alpha:1]];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self performSelector:@selector(removeForegroundColor) withObject:nil afterDelay:0.2];
    //[self removeForegroundColor];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self performSelector:@selector(removeForegroundColor) withObject:nil afterDelay:0.2];
    //[self removeForegroundColor];
}


-(void)setForegroundColor:(UIColor *) frontColor
{
    frontView.frame = self.frame;
    
    [frontView.layer setCornerRadius:9];
    frontView.backgroundColor = frontColor;
    [frontView setAlpha:0.6];
    [self addSubview:frontView];
}

-(void)removeForegroundColor
{
    if(frontView && frontView.retainCount > 0)
    {
        frontView.backgroundColor = [UIColor clearColor];
        [frontView removeFromSuperview];
        [frontView release];
        frontView = nil;
    }
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
