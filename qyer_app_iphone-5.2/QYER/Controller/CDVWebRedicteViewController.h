//
//  CDVWebRedicteViewController.h
//  QYER
//
//  Created by Qyer on 14-4-8.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDVWebMainViewController.h"
#import "ODRefreshControl.h"

@interface CDVWebRedicteViewController : CDVViewController<NotReachableViewDelegate>{
    
    NSURL* _redicteUrl;
    ODRefreshControl *refreshControl;
    UIViewController* currentVc;
    NotReachableView *notReachableView;
}
@property(nonatomic, retain)NSURL* _redicteUrl;
@property(nonatomic,retain)UIViewController* currentVc;
@end
