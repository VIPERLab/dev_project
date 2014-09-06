//
//  ThirdLoginViewController.h
//  CityGuide
//
//  Created by lide on 13-3-7.
//  Copyright (c) 2013年 com.qyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ThirdLoginViewController : BaseViewController <UIWebViewDelegate>
{
    UIButton            *_closeButton;
    UIWebView           *_webView;
    
    NSString            *_titleText;
    NSString            *_loginURL;
}

@property (retain, nonatomic) NSString *titleText;
@property (retain, nonatomic) NSString *loginURL;

@end
