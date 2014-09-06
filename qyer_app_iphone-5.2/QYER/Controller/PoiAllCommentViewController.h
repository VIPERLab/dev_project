//
//  PoiAllCommentViewController.h
//  QyGuide
//
//  Created by an qing on 13-2-26.
//
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"
#import "PoiRateView.h"


@interface PoiAllCommentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,DYRateViewDelegate>
{
    UIImageView             *_headView;
    UILabel                 *_titleLabel;
    UIButton                *_backButton;
    NSString                *_navigationTitle;
    
    UITableView             *_tableView_poiAllComment;
    NSMutableArray          *_poiCommentDataArray;   //存放所有评论的数组
    NSMutableArray          *_userCommentDataArray;  //用户的评论
    
    DYRateView              *_rateView;
    NSInteger               _userRate;
    PoiRateView             *_poiRateView;
    NSString                *_user_access_token;
    
    
    BOOL                    isDownloadAllComment;    //是否已下载完所有的评论
    BOOL                    downloadNewDataFlag;     //某一次下载数据是否完成(完成为0,未完成为1)
    NSMutableDictionary     *_heightDic;             //记录用户评论字符串的高度
    
    NSString                *_userInstruction;       //用户的评论
    NSString                *_userCommentRate;       //用户的评星
    NSString                *_userCommentRateCopy;   //用户的评星
    
    UIView                  *_toolBar;
    NSString                *_allCommentNumberStr;   //用户对该POI的评价总数
    
    NSInteger               _commentId;              //获取评论列表时用到的max_id
    
    UIView                  *_footView;
    UIActivityIndicatorView *_activityView;
    
    UILabel                 *_commentLabel;
    
    NSInteger               _userRateWhenTapStar;
}

@property(nonatomic,assign) NSInteger   poiId;
@property(nonatomic,retain) NSString    *commentId_user;
@property(nonatomic,retain) NSString    *navigationTitle;
@property(nonatomic,retain) NSString    *allCommentNumberStr;
@property(nonatomic,retain) NSString    *userCommentRate;
@property(nonatomic,retain) NSString    *userInstruction;
@property(nonatomic,assign) NSInteger   commentId;
@property(nonatomic,retain) NSString    *userCommentRateCopy;

@end

