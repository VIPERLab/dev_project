//
//  MyPopViewControl.m
//  OnLineMap
//
//  Created by an qing on 13-2-16.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "MyPopViewControl.h"

@implementation MyPopViewControl
@synthesize type = _type;

-(void)dealloc
{
    self.type = nil;
    
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
