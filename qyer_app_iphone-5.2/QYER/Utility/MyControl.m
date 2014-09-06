//
//  MyControl.m
//  iPhoneJinNang
//
//  Created by 安庆 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyControl.h"
#import <QuartzCore/QuartzCore.h>


@implementation MyControl
@synthesize info;

- (void)dealloc
{
    [_backGroundColor release];
    self.info = nil;
    
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

-(id)initWithFrame:(CGRect)frame andBackGroundColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _backGroundColor = [color retain];
        
    }
    return self;
}


-(void)removeForegroundColor
{
    self.backgroundColor = [UIColor clearColor];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    self.backgroundColor = _backGroundColor;
    
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@" touchesCancelled  touchesCancelled ");
    
    [super touchesCancelled:touches withEvent:event];
    
    [self removeForegroundColor];
    //[self performSelector:@selector(removeForegroundColor) withObject:nil afterDelay:0];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@" touchesEnded  touchesEnded ");
    
    [super touchesEnded:touches withEvent:event];
    
    [self removeForegroundColor];
    //[self performSelector:@selector(removeForegroundColor) withObject:nil afterDelay:0.1];
}

@end
