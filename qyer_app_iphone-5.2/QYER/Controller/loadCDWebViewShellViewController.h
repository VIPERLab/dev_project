//
//  loadCDWebViewShellViewController.h
//  QYER
//
//  Created by Qyer on 14-4-10.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDVWebRedicteViewController.h"
#import "MYActionSheet.h"
#import "QYBaseViewController.h"

@interface loadCDWebViewShellViewController : UIViewController<MYActionSheetDelegate>{
    CDVViewController* cdMianWeb;
    UIButton          *_shareButton;
    UILabel *_titleLabel;
    NSURL* _redicteUrl;
    NSString* title;
    NotReachableView *notReachableView;
}
@property(nonatomic, retain)NotReachableView *notReachableView;
@property(nonatomic, retain)NSURL* _redicteUrl;
@property(nonatomic,retain) UILabel *_titleLabel;

- (id)initWithTitle:(NSString *)_titleValue;
@end
