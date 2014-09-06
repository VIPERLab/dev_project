//
//  BaseViewController.h
//  CityGuide
//
//  Created by lide on 13-2-16.
//  Copyright (c) 2013年 com.qyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
{
    UIImageView         *_headView;
    UILabel             *_titleLabel;
    UIButton            *_backButton;
    
    UIImageView         *_shadowImageView;
}
- (void)clickBackButton:(id)sender;
@end
