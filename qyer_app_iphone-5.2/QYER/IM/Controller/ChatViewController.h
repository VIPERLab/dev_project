//
//  ChatViewController.h
//  IMTest
//
//  Created by Frank on 14-4-21.
//  Copyright (c) 2014年 Frank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"
#import "CustomPickerImageDelegate.h"
#import "CCActiotSheet.h"
#import "CXPhotoBrowser.h"
#import "JSBubbleView.h"
@class LoadMoreView;
@class UserInfo;
@class OtherMessage;

#if NS_BLOCKS_AVAILABLE
typedef void (^UploadImageBlock)(NSDictionary *resultItem, BOOL status);
#endif

/**
 *  IM视图控制器
 */
@interface ChatViewController : JSMessagesViewController<JSMessagesViewDataSource, JSMessagesViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,CustomPickerImageDelegate, CCActiotSheetDelegate, CXPhotoBrowserDataSource, CXPhotoBrowserDelegate, JSBubbleViewDelegate>
{
    /**
     *  是否正在加载
     */
    BOOL _isLoading;
    /**
     *  加载更多视图
     */
    LoadMoreView *_loadMoreView;
    /**
     *  发送消息的字典，key是messageId，value是indexPath.row
     */
    NSMutableDictionary *_sendMsgItem;
    /**
     *  发送图片的字典，key是messageId，value是indexpath
     */
    NSMutableDictionary *_sendImageIndexPathItem;
    
    NSIndexPath *_indexPath;
    
    /**
     *  消息发送者
     */
    UserInfo *_fromUserInfo;
    
    /**
     *  图片控制器
     */
    CXPhotoBrowser *_photoBrowser;
    /**
     *  图片控制器导航栏
     */
    CXBrowserNavBarView *_navBarView;
    /**
     *  图片数据源
     */
    NSMutableArray *_photoDataSource;
   
    /**
     *  是否查询的是离线消息
     */
    BOOL _isQueryOffline;
    /**
     *  是否在正在保存图片
     */
    BOOL _isSavePhotoing;
    
    /**
     *  请求数据时的菊花视图
     */
    UIActivityIndicatorView *_activityView;
    
    /**
     *  标题标签
     */
    UILabel *_titleLabel;
    
    /**
     *  标题
     */
    NSString *_navigationTitle;
    
    /**
     *  上传图片到服务器的block
     */
    UploadImageBlock _uploadImageBlock;

}


/**
 *  聊天室ID
 */
@property (nonatomic, copy) NSString *topicId;

/**
 *  消息数组
 */
@property (retain, nonatomic) NSMutableArray *messages;

/**
 *  消息接收者(如果是聊天室，为nil)
 */
@property (nonatomic, retain) UserInfo *toUserInfo;

/**
 *  结束加载状态, 刷新表格，滚动到上次数据位置
 */
- (void)endLoading:(NSNumber*)count;

/**
 *  查询消息
 */
- (void)queryMessages;

/**
 *  查询当前发送时间之前的消息
 */
- (void)queryLocalMessages;

/**
 *  查询之后，刷新表格
 *
 *  @param array   数据源
 *  @param pageNum 当前页数
 *  @param isAdd   是否添加到末尾
 */
- (void)reloadTableAfterQueryWithArray:(NSArray*)array withIsInit:(BOOL)isInit withIsAdd:(BOOL)isAdd;

/**
 *  获取最上面一条消息的发送时间
 *
 *  @return
 */
- (long long)getTheTopMessageTimeSend;

/**
 *  加载状态发生改变，触发的通知
 *
 *  @param notification
 */
- (void)changeLoadStatus:(NSNotification*)notification;

@end
