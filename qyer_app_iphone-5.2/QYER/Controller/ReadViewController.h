//
//  ReadViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-8.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LastMinuteRecommendView.h"
#import "MYActionSheet.h"
#import "ActionListView.h"

@class QYGuide;
@class WebViewViewController;

@interface ReadViewController : UIViewController <UIScrollViewDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,LastMinuteRecommendViewDelegate,MYActionSheetDelegate,ActionListViewDelegate>
{
    UIImageView         *_headView;
    UIImageView         *_statusBar;
    UIButton            *_button_back;              //返回按钮
    UIImageView         *_indicator_left;           //左箭头
    UIImageView         *_indicator_right;          //右箭头
    UILabel             *_label_bookmarkName;       //显示书签名称
    UILabel             *_label_currentPage;        //显示锦囊的页数
    UIButton            *_button_map;               //跳转到地图按钮
    UIButton            *_button_catalog;           //跳转到目录按钮
    UIButton            *_button_bookmark;          //添加书签按钮
    UIButton            *_button_ShareAndCorrect;   //分享&纠错按钮
    UIControl           *_backgroundView_shareAndCorrectView;
    UIImageView         *_shareAndCorrectView;
    UIButton            *_button_bookMark;
    UIImageView         *_imageview_masker;
    UILabel             *_label_toast_whenFullScreen;
    
    NSMutableArray      *_array_bookMark;           //已经添加的书签
    
    UIButton            *_button_lastMinute;
    UIButton            *_button_lastMinute_close;
    NSMutableArray      *_array_lastMinute;
    
    UIScrollView        *_scrollView;
    NSMutableArray      *_array_catalog;
    NSMutableArray      *_array_guideHtml;
    NSInteger           _selectIndex;
    NSMutableDictionary *_dic_pageturning;
    NSInteger           _pageTurning;
    
    QYGuide             *_guide;
    BOOL                _isLoadPoiListInfoSuccessed;
    NSMutableArray      *_poiListInfoArray;
    
    BOOL                _flag_noFreshData;
    BOOL                _flag_isShowToast;
    BOOL                _flag_observe;
}

@property(nonatomic,assign) BOOL            flag_pushFromBookMark;  //是否是从BookMarkViewController过来的
@property(nonatomic,assign) BOOL            flag_isShowGuideCover;  //是否显示锦囊的封面
@property(nonatomic,assign) BOOL            flag_firstLoad;         //第一次打开某本锦囊的标识
@property(nonatomic,retain) NSString        *str_guideName;
@property(nonatomic,retain) NSMutableArray  *array_catalog;
@property(nonatomic,assign) NSInteger       selectIndex;
@property(nonatomic,retain) QYGuide *guide;

@end
