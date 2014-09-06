//
//  WebViewViewController.h
//  iPhoneJinNang
//
//  Created by 安庆 on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYGuide.h"
#import "GetRemoteNotificationData.h"
#import "QYURLCache.h"
#import "MYActionSheet.h"
#import "ActionListView.h"


@interface WebViewViewController : UIViewController<UIWebViewDelegate, UIScrollViewDelegate,QYURLCacheDelegate,MYActionSheetDelegate,UIAlertViewDelegate>
{
    UIWebView       *_webView;
    
    UIImageView     *_headView;
    UIImageView     *_footView;
    UILabel         *_label_title;
    
    UIButton        *_closeButton;
    UIButton        *_backButton;
    UIButton        *_nextButton;
    UIButton        *_refreshButton;
    UIButton        *_safariButton;
    
    NSString        *_startURL;
    NSString        *_planName; //行程名称
    BOOL            _flag_shared;
    
    GetRemoteNotificationData *pushClass;
    BOOL _flag_plan; //是否行程的标志
    QYURLCache *urlCache_qy;
    BOOL _flag_observe;
    UIControl *_imageView_failed;
}

@property(nonatomic,assign) bool fromPushFlag;
@property(nonatomic,assign) BOOL flag_plan;
@property(nonatomic,assign) BOOL flag_natavie;
@property(nonatomic,assign) BOOL flag_remote; //是否来自推送的标识
@property(nonatomic,assign) UILabel  *label_title;
@property(retain,nonatomic) NSString *startURL;
@property(retain,nonatomic) NSString *title_navigationBar;
@property(retain,nonatomic) NSString *plan_id;
@property(nonatomic,retain) NSString *planName;
@property(nonatomic,retain) NSString *updateTime;

-(void)getRemoteNotificationClass:(GetRemoteNotificationData*)class;

@end
