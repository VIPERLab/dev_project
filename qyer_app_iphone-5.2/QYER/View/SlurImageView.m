//
//  SlurImageView.m
//  QyGuide
//
//  Created by 你猜你猜 on 14-1-2.
//
//

#import "SlurImageView.h"



@interface SlurImageView ()
@property (nonatomic, strong) UINavigationBar *slurNavigationbar;
@end



@implementation SlurImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setup];
        
    }
    return self;
}



- (void)setup
{
    // If we don't clip to bounds the toolbar draws a thin shadow on top
    [self setClipsToBounds:YES];
    
    if (!self.slurNavigationbar)
    {
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:[self bounds]];
        self.slurNavigationbar = navigationBar;
        [navigationBar release];
        [self.layer insertSublayer:self.slurNavigationbar.layer atIndex:0];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.slurNavigationbar setFrame:[self bounds]];
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
