//
//  QYImageView.m
//  QYER
//
//  Created by 张伊辉 on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QYImageView.h"

@implementation QYImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)dealloc{
    
    self.strURL = nil;
    [super dealloc];
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
