//
//  MyPoiImageViewControl.m
//  QyGuide
//
//  Created by an qing on 13-2-19.
//
//

#import "MyPoiImageViewControl.h"

@implementation MyPoiImageViewControl
@synthesize position = _position;
@synthesize hasBackGroundColorflag = _hasBackGroundColorflag;

-(void)dealloc
{
    [_position release];
    
    [super dealloc];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(self.hasBackGroundColorflag == 0)
    {
        self.backgroundColor = [UIColor colorWithRed:88/255. green:88/255. blue:88/255. alpha:0.3];
    }
    
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
