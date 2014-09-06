//
//  KSLoginDelegate.h
//  KwSing
//
//  Created by 改 熊 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSWebView.h"
#import "IObserverApp.h"

@protocol OLoginView <NSObject>

-(void)onReturn;

@end

@interface KSLoginDelegate : NSObject<KSWebViewDelegate,IObserverApp>
{
    id<OLoginView> delegate;
}
@property (nonatomic,assign) id<OLoginView> delegate;
-(void)dealWithBindRes:(NSDictionary*)retDic;
-(void)dealWithLoginRes:(NSDictionary*)retDic;
-(void)webViewRunActionWithParam:(KSWebView *)view action:(NSString *)act parameter:(NSDictionary *)paras;


@end
