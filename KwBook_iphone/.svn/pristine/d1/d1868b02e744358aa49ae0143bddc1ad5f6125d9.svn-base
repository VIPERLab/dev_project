//
//  KBAlertView.h
//  kwbook
//
//  Created by 单 永杰 on 14-3-18.
//  Copyright (c) 2014年 单 永杰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AlertBlock)(NSInteger);

@interface KBAlertView : UIAlertView

@property(nonatomic, copy)AlertBlock block;

-(id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles clickButton:(AlertBlock)_block;

@end
