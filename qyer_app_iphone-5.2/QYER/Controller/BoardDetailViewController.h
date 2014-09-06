//
//  BoardDetailViewController.h
//  QYER
//
//  Created by Leno on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BaseViewController.h"
#import "UIPlaceHolderTextView.h"

#import "BoadDetailTopCell.h"
#import "BoardDetailCommentCell.h"

@protocol DeleteBoardMessgaeSuccessDelegate;


@interface BoardDetailViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,DidClickTopUserAvatarDelegate,DidClickCommentsUserAvatarDelegate,UIAlertViewDelegate>
{
    UITableView * _detailTableView;
    
    NSInteger     _commentNumberIndex;

    NSMutableArray     * _topInfoArray;
    NSMutableArray     * _commentsArray;
    
    
    UIImageView             * _bottomImgView;//底部的背景图
    UIImageView             * _txvBackImgView;//评论背景
    UIPlaceHolderTextView   * _commentTextView;//回复评论的TXV
    UIButton                * _sendButton;
    
    float                   _keyBoradOrigin;
    float                   _keyBoardHeight;

    float                   _topPhotoHeight;
    
    int                     _pageIndex;
    BOOL                    _canLoadMoreComments;
    BOOL                    _isLoadingMoreComments;
    
    UIView                  * _refreshMoreView;
    UILabel                 * _refreshMoreLabel;
    UIActivityIndicatorView * _activityIndicatior;
    
    UIView                 * _noCommentsVIew;
    
    UIImage                 * _photoImage;
    
    BOOL                    _shouldShowNewComment;

    
}

@property (assign, nonatomic) id<DeleteBoardMessgaeSuccessDelegate> delegate;

@property(retain,nonatomic)NSString * wallID;

@property(retain,nonatomic)NSString * photoURL;

@property(assign,nonatomic)NSInteger boardPosterUserID;

@property(assign,nonatomic)BOOL      enteredFromNotification;   //判断是否从提醒中进入


@end


@protocol DeleteBoardMessgaeSuccessDelegate<NSObject>

-(void)didDeleteMessageSuccess;//删除黑板成功

-(void)didAddCommentSuccess;

@end


