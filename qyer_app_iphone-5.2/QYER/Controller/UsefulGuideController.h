//
//  UsefulGuideController.h
//  QYER
//
//  Created by 张伊辉 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"
#import "MYActionSheet.h"


@interface UsefulGuideController : QYBaseViewController<UIWebViewDelegate,MYActionSheetDelegate>
{
    UIWebView *_webView;
    
    //判断是否已加载完成
    BOOL _didLoadWebSuccess;
}
/**
    type = 1 国家实用指南
    type = 2 城市实用指南
    type = 3 城市下，精选酒店
    type = 4 推荐行程的详情，暂时存这里。
 */
@property(nonatomic,assign)int type;
@property(nonatomic,retain)NSString *strTitle;
@property(nonatomic,assign)NSString *url;
@end
