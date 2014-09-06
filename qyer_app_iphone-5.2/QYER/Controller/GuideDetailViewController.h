//
//  GuideDetailViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideViewCell.h"
#import "QYGuide.h"
#import "GetRemoteNotificationData.h"
#import "MYActionSheet.h"
#import "GuideCoverCell.h"


typedef enum
{
	Guide_about = 0,
    Guide_comment = 1,
    Guide_related = 2
} State_tableView;




@interface GuideDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GuideViewCellDelegate,UIScrollViewDelegate,MYActionSheetDelegate,GuideCoverCellDelegate>
{
    QYGuide                 *_guide;
    State_tableView         _state_tableView;    //标识'关于/评论/相关锦囊'等状态
    NSMutableDictionary     *_dic_height;        //记录cell的高度
    
    UIControl               *_imageView_failed;
    UITableView             *_tableview_guideDetail;
    NSMutableArray          *_array_abountGuide;
    NSMutableArray          *_array_guideComment;
    NSMutableArray          *_array_relatedGuide;
    NSInteger               _maxId;                    //获取锦囊的评论时需要的id
    NSString                *_guideName_needUpdate;
    
    UIImageView             *_headView;
    UIButton                *_backButton;
    UIButton                *_shareButton;
    UILabel                 *_titleLabel;
    
    UITableView             *_myTableView;
    NSString                *_navigationTitle;
    UIButton                *_button_about;
    UIButton                *_button_comment;
    UIButton                *_button_relation;
    UIButton                *_button_fuction;
    UIImageView             *_imageView_speration;
    
    UIView                  *_footView;
    UIActivityIndicatorView *_activityView;
    BOOL                    _flag_isDownloadAllData;
    
    BOOL                    _flag_isRefresh;            //是否刷新cell的标志(开始下载/取消下载/下载成功,返回后需要刷新cell)
    
    NSInteger               _position_section_tapCell;  //点击cell的位置section
    NSInteger               _position_row_tapCell;      //点击cell的位置row
    
    GuideCoverCell            *cell_guideCover;
    GetRemoteNotificationData *pushClass;
    BOOL _flag_notLoginWhenCommentGuide;
    BOOL                    _flag_getDetailInfo; //是否需要获取锦囊详情
    BOOL                    _flag_getData; //获取数据是否成功
    BOOL                    _flag_new;     //是否已是最新的锦囊（不是本地缓存）
    BOOL                    _flag_delay;
}

@property(nonatomic,retain) NSString                *guideId;
@property(nonatomic,assign) BOOL                    fromPushFlag;  //标识是否从推送的消息推出的
@property(nonatomic,retain) NSString                *navigationTitle;
@property(nonatomic,retain) QYGuide                 *guide;
@property(nonatomic,retain) UIImage                 *image_share;
@property(nonatomic,assign) BOOL                    flag_downloadNewDataFlag;  //某次网络请求是否完成
@property(nonatomic,assign) BOOL                    flag_new;
@property(nonatomic,retain) NSString                *where_from;

-(void)getRemoteNotificationClass:(GetRemoteNotificationData *)class;

@end

