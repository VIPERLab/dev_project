//
//  TravelPlanViewController.h
//  QYER
//
//  Created by Leno on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseViewController.h"

@interface TravelPlanViewController : BaseViewController<UIWebViewDelegate>
{
    UIWebView * _planDetailWebView;
    
}

@property(nonatomic,retain) NSString * planLink;

@end
