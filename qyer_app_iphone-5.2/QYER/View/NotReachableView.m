//
//  NotReachableView.m
//  QYER
//
//  Created by Frank on 14-4-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "NotReachableView.h"

@implementation NotReachableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat y = 130;
        if ([UIScreen mainScreen].bounds.size.height == 480) {
            y = 86;
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, 320, 180)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"notReachable"];
        [self addSubview:imageView];
        [imageView release];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //调用委托类的touchesView方法
    if ([self.delegate respondsToSelector:@selector(touchesView)]) {
        [self.delegate touchesView];
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
