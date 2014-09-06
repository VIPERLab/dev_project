//
//  LastMinuteDetailViewController.h
//  QYER
//
//  Created by Leno（蔡小雨） on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseViewController.h"
#import "MYActionSheet.h"
#import "BookView.h"

@interface LastMinuteDetailViewController : BaseViewController<UIWebViewDelegate,MYActionSheetDelegate,BookViewDelegate,UIAlertViewDelegate>
{
    UIWebView * _lastMinuteWebView;
    
    BOOL _didFinishLoading;
    
    UIView                  *_reloadLastMinuteView;//无缓存加载折扣信息的View
    UITapGestureRecognizer  *_screenTapReloadTappp;//点击重新加载的单击方法

    
    BookView * _lastMinuteBookView;
}


@property(retain,nonatomic)NSDictionary * dealInfoDictionary;

@property(nonatomic,retain)NSString * originalURL;
@property(nonatomic,retain)NSString * dealURL;

@property(nonatomic,retain)NSString * dealTitle;

//******** Insert By ZhangDong 2014.4.8 Start **********
/**
 *  详情ID
 */
@property (nonatomic, assign) NSInteger dealID;
//******** Insert By ZhangDong 2014.4.8 End **********
@end
