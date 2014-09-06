//
//  MYActionSheet.m
//  NewPackingList
//
//  Created by lide on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MYActionSheet.h"
#import "MYButton.h"
#import <QuartzCore/QuartzCore.h>





//判断是否为iPhone5:
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define kActionSheetRowHeight       102
#define kActionSheetCancelHeight    44+40






@interface MYActionSheet ()
- (void)clickActionSheetButton:(id)sender;
- (void)clickCancelButton:(id)sender;
@end





@implementation MYActionSheet

@synthesize delegate = _delegate;

#pragma mark - private
- (void)clickActionSheetButton:(id)sender
{
    [UIView animateWithDuration:0.4 animations:^{
        _backView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, _backView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        if(_delegate && [_delegate respondsToSelector:@selector(actionSheetButtonDidClickWithType:)])
        {
            MYButton *button = (MYButton*)sender;
            [_delegate actionSheetButtonDidClickWithType:[button shareType]];
        }
    }];
}

- (void)clickCancelButton:(id)sender
{
    [self setAlpha:0];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:1]];
    [animation setToValue:[NSNumber numberWithFloat:0]];
    [animation setDuration:0.25];
    [animation setAutoreverses:NO];
    [self.layer addAnimation:animation forKey:@"doOpacity"];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        _backView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, _backView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        if(_delegate && [_delegate respondsToSelector:@selector(cancelButtonDidClick:)])
        {
            [_delegate cancelButtonDidClick:self];
        }
    }];
}

#pragma mark - super


- (id)initWithTitleArray:(NSArray *)titleArray
              imageArray:(NSArray *)imageArray
{
    if(iPhone5)
    {
        if(ios7)
        {
            self = [super initWithFrame:CGRectMake(0, 0, 320, 460+88+20)];
        }
        else
        {
            self = [super initWithFrame:CGRectMake(0, 20, 320, 460+88)];
        }
    }
    else
    {
        if(ios7)
        {
            self = [super initWithFrame:CGRectMake(0, 0, 320, 460+20)];
        }
        else
        {
            self = [super initWithFrame:CGRectMake(0, 20, 320, 460)];
        }
    }
    if(self != nil)
    {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        NSUInteger row = [titleArray count] % 3 ? [titleArray count] / 3 + 1 : [titleArray count] / 3;
        
        CGFloat height = row * kActionSheetRowHeight + kActionSheetCancelHeight;
        
        if(iPhone5)
        {
            if(ios7)
            {
                _backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 460+20 - height+88, 320, height)];
            }
            else
            {
                _backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 460 - height+88, 320, height)];
            }
        }
        else
        {
            if(ios7)
            {
                _backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 460+20 - height, 320, height)];
            }
            else
            {
                _backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 460 - height, 320, height)];
            }
        }
        
        
        
        _backView.backgroundColor = [UIColor clearColor];
        UIImage *image = [[UIImage imageNamed:@"background_actionsheet_"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        _backView.image = image;
        
        
        
        
        
        _backView.userInteractionEnabled = YES;
        [self addSubview:_backView];
        
        
        
        
        
        for(NSUInteger i = 0; i < [titleArray count]; i++)
        {
            NSUInteger row = i / 3;
            NSUInteger column = i % 3;
            
            MYButton *button = [MYButton buttonWithType:UIButtonTypeCustom];
            button.shareType = [titleArray objectAtIndex:i];
            button.frame = CGRectMake(30 + column * kActionSheetRowHeight, 27 + row * kActionSheetRowHeight, 57, 57);
            [button setBackgroundImage:[UIImage imageNamed:[imageArray objectAtIndex:i]] forState:UIControlStateNormal];
            [button setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(77, 0, 0, 0)];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            //            button.titleLabel.textColor = [UIColor colorWithRed:134/255. green:134/255. blue:134/255. alpha:1];
            //            button.titleLabel.numberOfLines = 0;
            button.tag = i;
            [button addTarget:self action:@selector(clickActionSheetButton:) forControlEvents:UIControlEventTouchUpInside];
            [_backView addSubview:button];
            
            UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x-5, button.frame.origin.y + button.frame.size.height, button.frame.size.width+10, 28)] autorelease];
            label.font = [UIFont systemFontOfSize:12];
            label.backgroundColor = [UIColor clearColor];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [titleArray objectAtIndex:i];
            label.textColor = [UIColor colorWithRed:134/255. green:134/255. blue:134/255. alpha:1];
            [_backView addSubview:label];
        }
        
        _cancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _cancelButton.frame = CGRectMake(10, _backView.frame.size.height - 55, 300, 44);
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_actionsheet_cancel"] forState:UIControlStateNormal];
        //[_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:_cancelButton];
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

- (void)dealloc
{
    _delegate = nil;
    
    [_backView removeFromSuperview];
    [_backView release];
    _backView = nil;
    
    
    [_cancelButton removeFromSuperview];
    [_cancelButton release];
    _cancelButton = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark ---- show
- (void)show
{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [self setAlpha:1];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:0]];
    [animation setToValue:[NSNumber numberWithFloat:1]];
    [animation setDuration:0.3];
    [animation setAutoreverses:NO];
    [self.layer addAnimation:animation forKey:@"doOpacity"];
    
    
    _backView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, _backView.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        _backView.transform = CGAffineTransformIdentity;
    }];
}

@end
