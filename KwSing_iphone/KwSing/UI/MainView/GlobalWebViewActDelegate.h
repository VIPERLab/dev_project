//
//  GlobalWebViewActDelegate.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-1.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__GlobalWebViewActDelegate__
#define __KwSing__GlobalWebViewActDelegate__

#include "KSWebView.h"

@interface GlobalWebViewActDelegate:NSObject<KSWebViewGlobalDelegate>
- (BOOL)webViewRunActionWithParam:(KSWebView*)view action:(NSString*)act parameter:(NSDictionary*)paras;
@end

#endif


