//
//  HotDiscountViewController.h
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "QYBaseViewController.h"
#import "QYLMBaseViewController.h"
#import "SMGridView.h"
#import "LastMinuteView.h"
#import "QYAPIClient.h"

@interface HotDiscountViewController : QYLMBaseViewController<SMGridViewDelegate, SMGridViewDataSource,LastMinuteViewDelegate>

{
    UIImageView         *_logoImageView;
    SMGridView          *_gridView;
    UIView                      *_refreshMoreView;
    UILabel                     *_refreshMoreLabel;
    UIActivityIndicatorView     *_activityIndicatior;
    
    UIView              *_noMoreView;
    UIImageView         *_noMoreIcon;
    
    NSMutableArray      *_lastMinuteArray;
    BOOL                _refreshing;
    BOOL                _canRefreshMore;
}

@property(assign,nonatomic)NSUInteger contientID;
@property(assign,nonatomic)NSUInteger countryID;

@end


