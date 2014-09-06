//
//  WebViewController.h
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-13.
//  供折扣用
//

#import <UIKit/UIKit.h>
//#import "QYBaseViewController.h"
#import "QYLMBaseViewController.h"

@protocol WebViewControllerDelegate;
//只支持Present
@interface WebViewController : QYLMBaseViewController <UIWebViewDelegate>
{
//    UIView          *_footView;
    
//    UIButton        *_prevButton;
//    UIButton        *_nextButton;
//    UIButton        *_refreshButton;
//    UIButton        *_safariButton;
    
    UIWebView       *_webView;
    
    NSString        *_loadingURL;
//    NSString        *_currentURL;
    
    NSString        *_titleString;
}

@property (retain, nonatomic) NSString                  *loadingURL;
@property (retain, nonatomic) NSString                  *titleString;
@property (nonatomic, assign) BOOL                       needRequestCookie;

@end
