//
//  KBAlertView.m
//  kwbook
//
//  Created by 单 永杰 on 14-3-18.
//  Copyright (c) 2014年 单 永杰. All rights reserved.
//

#import "KBAlertView.h"

@implementation KBAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles clickButton:(AlertBlock)click_block{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self) {
        self.block = click_block;
    }
    
    return self;
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.block(buttonIndex);
}

@end
