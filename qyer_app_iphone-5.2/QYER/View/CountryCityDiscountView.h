//
//  CountryCityDiscountBtn.h
//  QYER
//
//  Created by Leno on 14-7-15.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIImageView+WebCache.h"

@protocol ClickCountryCityDiscountDelegate;


@interface CountryCityDiscountView : UIView
{
    UIButton            * _backButton;
    
    UIView              * _backView;
    
    UIImageView         * _discountImgView;
    UIImageView         * _pinkLabel;
    
    UILabel             * _prefixLabel;
    UILabel             * _priceLabel;
    UILabel             * _suffixLabel;
    
    UILabel             * _detailLabel;
    
    UIImageView         * _clockIconImgView;
    
    UILabel             * _timeLabel;
}

-(void)setDiscountInfo:(NSDictionary *)dict;

-(void)setBackBtnColor;

@property (assign, nonatomic) id<ClickCountryCityDiscountDelegate> delegate;

@end


@protocol ClickCountryCityDiscountDelegate<NSObject>

-(void)didClickDiscount:(id)sender;
@end



