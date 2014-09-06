//
//  KSWebView.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-27.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_KSWebView_h
#define KwSing_KSWebView_h

@protocol KSWebViewDelegate;
@protocol KSWebViewGlobalDelegate;

@interface KSWebView:UIView

- (id)initWithFrame:(CGRect)frame;

- (id)initWithFrame:(CGRect)frame allowBounce:(BOOL)bounce useLoading:(BOOL)loading opaque:(BOOL)bOpaque;

- (void)setBackgroundImage:(UIImage*)img;//引用计数加一

- (void)scalesPageToFit:(BOOL)bFit;

- (void)loadUrl:(NSString*)url;

- (void)loadFile:(NSString*)file;

- (void)stop;

- (void)reload;

- (BOOL)isLoading;

- (BOOL)canGoBack;

- (BOOL)canGoForward;

- (void)goBack;

-(void)goForward;

//loading或者error返回FALSE，页面正常显示了返回TRUE
- (BOOL)isSuccessed;

- (NSString*) executeJavaScriptFunc:(NSString*)func;
- (NSString*) executeJavaScriptFunc:(NSString*)func parameter:(NSString*)paras;

//里面会retain
- (void)setDelegate:(id<KSWebViewDelegate>)delegate;

+ (void)setGlobalDelegate:(id<KSWebViewGlobalDelegate>)delegate;

@end

@protocol KSWebViewDelegate <NSObject>
@optional
- (void)webViewDidStartLoad:(KSWebView*)view;
- (void)webViewDidFinishLoad:(KSWebView*)view success:(BOOL)isSuccess;
- (void)webViewRunActionWithParam:(KSWebView*)view action:(NSString*)act parameter:(NSDictionary*)paras;

@end

@protocol KSWebViewGlobalDelegate <NSObject>
- (BOOL)webViewRunActionWithParam:(KSWebView*)view action:(NSString*)act parameter:(NSDictionary*)paras;
@end

#endif
