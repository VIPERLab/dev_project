//
//  RecommendViewController.h
//  QYER
//
//  Created by 我去 on 14-3-16.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDActivityIndicatorView.h"
#import "chatroomAdvertiseView.h"
#import "ODRefreshControl.h"
#import "XLCycleScrollView.h"
#import "DiscountCell.h"
#import "LoadMoreView.h"
#import "QYBaseViewController.h"
@class UserInfo;

@interface RecommendViewController : QYBaseViewController<chatroomAdvertiseViewDelegate,UITableViewDelegate,UITableViewDataSource,XLCycleScrollViewDelegate,XLCycleScrollViewDatasource,DiscountCellDelegate,UIAlertViewDelegate>
{
   // UIImageView         *_headView;
    UIImageView         *_titleImageLogo;
    
    UIButton            *_chatButton;
    UILabel            *_YouMayLikeLable;
    UIButton            *_YouMayLikeButton;
    NSDictionary        *_dic;
    
    UserInfo            *_userInfo;
    NSInteger           displayChatroomStaus;
    CDActivityIndicatorView *_activityView;
    
    //UIView*              chatroomAdvertiseView;
    
    
    //UIButton *button_meassage;
    
    chatroomAdvertiseView* _chatchatroomAdvertiseView;
    

    /**
     重做View
     */
    UITableView *myTableView;
    UIView *tableHeadView;
    XLCycleScrollView *_topScrollView;
    /**
     *  运营图
     */
    NSMutableArray *imagesArray;
    /**
     *  目的地
     */
    NSMutableArray *placesArray;
    /**
     *  折扣
     */
    NSMutableArray *discountArray;
    /**
     *  游记
     */
    NSMutableArray *tripsArray;
    
    ODRefreshControl *refeshControl;
    
    BOOL isLoading;
    LoadMoreView *footView;
    int page;
   
    /**
     *  限制事件
     */
    BOOL limitMultiple;
    
    /**
     *  聊天室成员人数
     */
    NSInteger _roomMemberCount;
    /**
     *  箭扣异常
     */
    BOOL _isArrowExcption;
    
}

@property(nonatomic,retain) UIViewController  *currentVC;
@property(nonatomic,retain) NSDictionary        *dic;

-(void)clickBackButton:(id)sender;

-(void)goChatroomButton:(id)sender;

-(void)connectIMServer;
@end
