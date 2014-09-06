//
//  BBSDetailViewController.h
//  QYER
//
//  Created by Leno on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//



//论坛游记详情的WebView


#import "BaseViewController.h"
#import "UIPlaceHolderTextView.h"
#import "MYActionSheet.h"

@interface BBSDetailViewController : BaseViewController<UIWebViewDelegate,UITextViewDelegate,UIScrollViewDelegate,MYActionSheetDelegate>
{
    UIWebView               * _BBSDetailWebView;
    
    UIImageView             * _bottomImgView;//底部的背景图
    UIImageView             * _txvBackImgView;//评论背景
    UIPlaceHolderTextView   * _commentTextView;//回复评论的TXV
    UIButton                * _sendButton;
    
    UIButton                * _pageButton;//翻页按钮
    UIButton                * _commentButton;//回复按钮
    UIImageView             * _pageTabBar;//翻页的tabbar
    UILabel                 * _pageLable;

    
    float                   _keyBoradOrigin;
    
    UIButton                * _onlyPosterButton;//只看楼主按钮
    BOOL                    _isOnlyPoster;//是否只看楼主
    
    UIButton                * _collectButton;//收藏按钮
    
    BOOL                    _didLoadBBSDetail;//是否已成功加载帖子
    
    UIImageView             *_bigPicImgView;//点击大图的ImgView;
    UIActivityIndicatorView *_activityIndicator;//旋转的菊花
    
   
    UIView                  *_reloadLastMinuteView;//无缓存加载折扣信息的View
    UITapGestureRecognizer  *_screenTapReloadTappp;//点击重新加载的单击方法
}


@property(nonatomic,retain) NSString * bbsAllUserLink;
@property(nonatomic,retain) NSString * bbsAuthorLink;

@property(nonatomic,retain) NSString * threadTitle;

@property(assign,nonatomic)int                      _threadUserID;//发帖用户的ID
@property(retain,nonatomic)NSString               * _threadUserName;//发帖用户的用户名
@property(assign,nonatomic)int                      _threadID;//该帖子的ID
@property(assign,nonatomic)int                      _floorID;//楼层的ID
@property(assign,nonatomic)int                      _floorIndex;//该楼层在帖子中的序列


@property(assign, nonatomic) int totalPageCount;//帖子总页数
@property(assign, nonatomic) int currentPage;//当前页数
/**
 *  标记跳转到此页的来源
 */
@property(copy, nonatomic) NSString *source;

@end
