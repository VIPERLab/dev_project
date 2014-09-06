//
//  QYAssetCheckBox.m
//  TestAssetsLibrary
//
//  Created by 蔡 小雨 on 13-11-6.
//  Copyright (c) 2013年 蔡 小雨. All rights reserved.
//

#import "QYCheckBox.h"

@implementation QYCheckBox

-(void)dealloc
{
    [_checkedImage release];
    [_unCheckedImage release];
    [_highlightedImage release];
    [_disabledImage release];
    
    [_checkedBgImage release];
    [_unCheckedBgImage release];
    [_highlightedBgImage release];
    [_disabledBgImage release];
    
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
//        UIImage *uncheckedImg = [UIImage imageNamed:@"cb_glossy_off@2x.png"];
//        UIImage *checkedImg = [UIImage imageNamed:@"choosePhoto_check_on.png"];
        
        
        
    }
    return self;
}

-(void)setCheckedImage:(UIImage *)checkedImage
{
    
    if (_checkedImage) {
        [_checkedImage release];
        _checkedImage = nil;
    }
    
    _checkedImage = [checkedImage retain];
    
    [self setImage:_checkedImage forState:UIControlStateSelected];

}

-(void)setUnCheckedImage:(UIImage *)unCheckedImage
{
    if (_unCheckedImage) {
        [_unCheckedImage release];
        _unCheckedImage = nil;
    }
    
    _unCheckedImage = [unCheckedImage retain];
    
    [self setImage:_unCheckedImage forState:UIControlStateNormal];

}

-(void)setHighlightedImage:(UIImage *)highlightedImage
{
    if (_highlightedImage) {
        [_highlightedImage release];
        _highlightedImage = nil;
    }

    _highlightedImage = [highlightedImage retain];
    
    [self setImage:_highlightedImage forState:UIControlStateHighlighted];
    [self setImage:_highlightedImage forState:UIControlStateApplication];
    [self setImage:_highlightedImage forState:UIControlStateReserved];
    
}

-(void)setDisabledImage:(UIImage *)disabledImage
{
    if (_disabledImage) {
        [_disabledImage release];
        _disabledImage = nil;
    }
    
    _disabledImage = [disabledImage retain];
    
    [self setImage:_disabledImage forState:UIControlStateDisabled];

}

- (void)setCheckedBgImage:(UIImage *)checkedBgImage
{
    if (_checkedBgImage) {
        [_checkedBgImage release];
        _checkedBgImage = nil;
    }
    
    _checkedBgImage = [checkedBgImage retain];
    
    [self setBackgroundImage:_checkedBgImage forState:UIControlStateSelected];

}

-(void)setUnCheckedBgImage:(UIImage *)unCheckedBgImage
{
    if (_unCheckedBgImage) {
        [_unCheckedBgImage release];
        _unCheckedBgImage = nil;
    }
    
    _unCheckedBgImage = [unCheckedBgImage retain];
    
    [self setBackgroundImage:_unCheckedBgImage forState:UIControlStateNormal];

}

-(void)setHighlightedBgImage:(UIImage *)highlightedBgImage
{
    if (_highlightedBgImage) {
        [_highlightedBgImage release];
        _highlightedBgImage = nil;
    }
    
    _highlightedBgImage = [highlightedBgImage retain];
    
    [self setBackgroundImage:_highlightedBgImage forState:UIControlStateHighlighted];
}

-(void)setDisabledBgImage:(UIImage *)disabledBgImage
{
    if (_disabledBgImage) {
        [_disabledBgImage release];
        _disabledBgImage = nil;
    }
    
    _disabledBgImage = [disabledBgImage retain];
    
    [self setBackgroundImage:_disabledBgImage forState:UIControlStateDisabled];
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
