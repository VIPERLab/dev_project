//
//  LinkControl.m
//  JinNangFrameApp
//
//  Created by 回头蓦见 on 13-5-22.
//
//

#import "LinkControl.h"


@implementation LinkControl
@synthesize siteLabel,siteLineLabel;


-(void)dealloc
{
    self.siteLabel = nil;
    self.siteLineLabel = nil;
    
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


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    self.siteLineLabel.backgroundColor = [UIColor colorWithRed:0 green:120/255. blue:182/255. alpha:1];
    self.siteLabel.textColor = [UIColor colorWithRed:0 green:120/255. blue:182/255. alpha:1];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    self.siteLineLabel.backgroundColor = [UIColor colorWithRed:0 green:168/255. blue:1 alpha:1];
    self.siteLabel.textColor = [UIColor colorWithRed:0 green:168/255. blue:1 alpha:1];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
//    
//    self.siteLineLabel.backgroundColor = [UIColor colorWithRed:0 green:168/255. blue:1 alpha:1];
//    self.siteLabel.textColor = [UIColor colorWithRed:0 green:168/255. blue:1 alpha:1];
    self.siteLineLabel.backgroundColor = [UIColor whiteColor];
    self.siteLabel.textColor = [UIColor whiteColor];
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
