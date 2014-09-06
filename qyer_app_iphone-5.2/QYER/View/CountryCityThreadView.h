//
//  CountryCityThreadView.h
//  QYER
//
//  Created by Leno on 14-7-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIImageView+WebCache.h"

@protocol ClickCountryCityThreadDelegate;

@interface CountryCityThreadView : UIView
{
    UIButton            * _backButton;
    
    UIView              * _backView;
    
    UIImageView         * _topLineImgView;
    
    UIImageView         * _threadImgView;

    UILabel             * _titleLabel;
    
    UILabel             * _authorTimeLabel;
}

-(void)setThreadInfo:(NSDictionary *)dict;

-(void)setBackBtnColor;

@property(retain, nonatomic) NSString * linkURL;

@property (assign, nonatomic) id<ClickCountryCityThreadDelegate> delegate;
@end


@protocol ClickCountryCityThreadDelegate<NSObject>

-(void)didClickThread:(id)sender;

@end

