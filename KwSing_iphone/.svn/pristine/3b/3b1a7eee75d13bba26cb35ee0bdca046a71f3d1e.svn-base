//
//  BaseWebViewController.h
//  KwSing
//
//  Created by Qian Hu on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSWebView.h"

@interface BaseWebViewController : UIViewController
{
    KSWebView * webView;
    id<KSWebViewDelegate> webDelegate;
}

@property (retain, nonatomic) NSString *strUrl;

- (void) CloseView;
- (void) SetWebDelegate:(id<KSWebViewDelegate>)delegate;
- (KSWebView *) getWebView;
@end
