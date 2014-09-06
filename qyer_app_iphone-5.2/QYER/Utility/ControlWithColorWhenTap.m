//
//  ControlWithColorWhenTap.m
//  QyGuide
//
//  Created by 回头蓦见 on 13-7-16.
//
//

#import "ControlWithColorWhenTap.h"

@implementation ControlWithColorWhenTap


- (void)dealloc
{
    [_backGroundColor release];
    
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
-(id)initWithFrame:(CGRect)frame andColorWhenTap:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        
        _backGroundColor = [color retain];
    }
    return self;
}

-(void)resetBackgroundColor
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
    
    [self performSelector:@selector(resetBackgroundColor) withObject:nil afterDelay:0.05];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@" touchesEnded  touchesEnded ");
    
    [super touchesEnded:touches withEvent:event];
    
    [self performSelector:@selector(resetBackgroundColor) withObject:nil afterDelay:0.1];
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
