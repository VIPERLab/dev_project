//
//  PoiDetailInfoControl.m
//  QyGuide
//
//  Created by an qing on 13-2-26.
//
//


#import "PoiDetailInfoControl.h"


@implementation PoiDetailInfoControl
@synthesize type = _type;
@synthesize bgColorType = _bgColorType;
@synthesize bookingUrlStr = _bookingUrlStr;

-(void)dealloc
{
    [_type release];
    self.bookingUrlStr = nil;
    
    [super dealloc];
}
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(self.bgColorType == 0)
    {
        self.backgroundColor = [UIColor colorWithRed:232/255. green:232/255. blue:232/255. alpha:1];
    }
    else if(self.bgColorType == 1)
    {
        self.backgroundColor = [UIColor colorWithRed:88/255. green:88/255. blue:88/255. alpha:1];
    }
    
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor clearColor];
}
- (void)cancelTrackingWithEvent:(UIEvent *)event{
    
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
