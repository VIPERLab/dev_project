//
//  CalloutButton.m
//  QyGuide
//
//  Created by an qing on 13-4-8.
//
//

#import "CalloutButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation CalloutButton
@synthesize colorFlag = _colorFlag;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(void)dealloc
{
    [frontView release];
    [super dealloc];
}

-(void)setForegroundColor:(UIColor *) frontColor
{
    frontView.frame = self.frame;
    frontView.backgroundColor = frontColor;
    
    [self.superview insertSubview:frontView atIndex:1];
    
}
-(void)removeForegroundColor
{
    if(frontView)
    {
        frontView.backgroundColor = [UIColor clearColor];
        [frontView removeFromSuperview];
        [frontView release];
        frontView = nil;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    MYLog(@" touchesBegan colorFlag :%d",self.colorFlag);
    
    [super touchesBegan:touches withEvent:event];
    
    if(frontView)
    {
        [frontView setBackgroundColor:[UIColor clearColor]];
        [frontView removeFromSuperview];
        [frontView release];
        frontView = nil;
    }
    frontView = [[UIView alloc] init];
    
    if(self.colorFlag == 1)
    {
        [self setForegroundColor:[UIColor colorWithRed:3.0 / 255.0 green:3.0 / 255.0 blue:3.0 / 255.0 alpha:0.3]];
    }
    if(self.colorFlag == 2)
    {
        [self setForegroundColor:[UIColor clearColor]];
    }
    else
    {
        
        [self setForegroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3]];
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self performSelector:@selector(removeForegroundColor) withObject:nil afterDelay:0.1];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self performSelector:@selector(removeForegroundColor) withObject:nil afterDelay:0.1];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
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
