//
//  PoiDetailViewController.h
//  QyGuide
//
//  Created by an qing on 13-2-21.
//
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"
#import "DYRateView.h"
@class GetPoiDetailInfo;
@class GetHotelNearbyPoi;
@class PoiDetailInfoControl;
@class PoiRateView;


#if NS_BLOCKS_AVAILABLE
typedef void (^finishedBlock)(void);
typedef void (^failedBlock)(void);
#endif




@interface PoiDetailViewController : UIViewController<UIScrollViewDelegate,UIWebViewDelegate,NotReachableViewDelegate>
{
    UIImageView          *_headView;
    UILabel              *_chineseTitleLabel;
    UILabel              *_englishTitleLabel;
    UIButton             *_mapButton;
    UIButton             *_backButton;
    NSString             *_navigationTitle;
    NSInteger            poiId;
    
    
    
    
    UIImageView         *_poiImageView;
    UIControl           *_control_poiImageView;
    UIImageView         *_bgView_imageCount;
    UIView *_mapButBackBgView;
    UIView *_commentBackBgView;
    UILabel             *_label_introduction;
    UIImageView         *_imageView_background_introduction;
    UIImageView         *_contentLabelBG_poiIntroduction;
    UILabel             *_contentLabel_poiIntroduction;
    PoiDetailInfoControl *_control_poiIntroduction;
    UIImageView         *_arrowImageView;
    UIImageView         *_imageView_background_poiDetailInfo;
    UILabel             *_label_poiDetailInfo;
    UIImageView         *_imageView_PoiDetail;
    UIImageView         *_imageView_background_tips;
    UIImageView         *_imageView_tipsBG_tips;
    UILabel             *_tipsLabel;
    UIImageView         *_imageView_logo;
    UIImageView         *_imageView_background_comment;
    UILabel             *_typeLabel_comment;
    UIImageView         *_imageView_commentBackGround;
    UIImageView         *_imageView_background_nearby;
    UILabel             *_typeLabel_nearby;
    UIImageView         *_nearbyBackBgView;
    BOOL                _flag_show;
    BOOL                _flag_reDrow_comment;
    PoiDetailInfoControl *_control_comment;
    UILabel *_label_infoComment;
    
    
    
    NSString            *_chineseTitle;
    NSString            *_englishTitle;
    NSInteger           _cate_id;
    UIImage             *_typeImage;   //标示:景点／餐饮／住宿／⋯⋯
    float               lat;           //纬度
    float               lng;           //经度
    
    UIActivityIndicatorView *_activityView;
    
    GetPoiDetailInfo     *_getPoiDetailInfo_fromServer;
    
    UIWebView            *_contentTipsWebView;
    
    
    float                orginY;
    float                orginYCopy;            //记录分割线在基本信息模块的初始位置
    UIScrollView         *_myScrollView;
    NSMutableDictionary  *_dataDic;             //存放poi详情
    NSMutableArray       *_commentDataArray;    //存放poi的评论信息
    NSMutableArray       *_detailinfokeyArray;
    NSMutableDictionary  *_heightDic;           //存放poi每部分内容的高度
    
    float                _commentHeight;        //3条评论内容的总高度
    float                _commentStartHeight;
    
    
    UIImageView     *_userCommentRateView1;     //用户评星1
    UIImageView     *_userCommentRateView2;     //用户评星2
    UIImageView     *_userCommentRateView3;     //用户评星3
    UIImageView     *_userCommentRateView4;     //用户评星4
    UIImageView     *_userCommentRateView5;     //用户评星5
    
    UIImageView     *_userCommentRateView11;    //用户评星1
    UIImageView     *_userCommentRateView22;    //用户评星2
    UIImageView     *_userCommentRateView33;    //用户评星3
    UIImageView     *_userCommentRateView44;    //用户评星4
    UIImageView     *_userCommentRateView55;    //用户评星5
    
    UILabel  *_commentNumLabel;
    NSString *allCommentNumber;
    NSString *_overMerit;                       //所有用户对该poi的综合评价
    
    
    GetHotelNearbyPoi    *_getHotelNearbyPoi_fromServer;
    NSMutableArray       *_hotelDataArray;
    BOOL                  _hasGetHotelNearbyPoiDone;
    NSString             *_bookingUrlStr;
    
    BOOL didReceiveMemoryWarningFlag;
    
    
    UIImageView *_bottomToolBar;
    BOOL        _flag_postBeento;
    BOOL        _flag_postWantgo;
    BOOL        _flag_login;
    NSString    *_type_beforeLogin;
    
    
    //热度必去，图片和文字 by zhangyihui
    DYRateView *_rateView;
    UILabel *_hotLevelLbl;
    
    /**
     *  处理用户多手指操作
     */
    BOOL isUserClick;
    
    
    BOOL _flag_init;
    BOOL _flag_commitPoi;
    BOOL _flag_changeComment;
}

@property(nonatomic,retain) NSString    *navigationTitle;
@property(nonatomic,retain) UIImage     *typeImage;
@property(nonatomic,assign) NSInteger   poiId;
@property(nonatomic,assign) NSString    *overMerit;
@property(nonatomic,retain) NSMutableDictionary  *dataDic;
@property(nonatomic,retain) NSString *userComment;
@property(nonatomic,retain) NSString *userCommentRate;
@property(nonatomic,assign) NSInteger commentId;

@property(nonatomic,retain) UIImageView     *userCommentRateView1;
@property(nonatomic,retain) UIImageView     *userCommentRateView2;
@property(nonatomic,retain) UIImageView     *userCommentRateView3;
@property(nonatomic,retain) UIImageView     *userCommentRateView4;
@property(nonatomic,retain) UIImageView     *userCommentRateView5;


/**
 *  是否显示没有网络视图
 */
- (void)setNotReachableView:(BOOL)isVisible;
@end


