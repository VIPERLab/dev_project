//
//  GroupChatRoomViewController.h
//  QYER
//
//  Created by Leno on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "ChatViewController.h"

#import "AddBoardMessgeViewController.h"
#import "BoardDetailViewController.h"

#import "EGORefreshTableHeaderView.h"

#import "ODRefreshControl.h"


@interface GroupChatRoomViewController : ChatViewController<UITableViewDataSource,UITableViewDelegate,AddBoardMessgaeSuccessDelegate,DeleteBoardMessgaeSuccessDelegate>
{
//    EGORefreshTableHeaderView *_refreshHeaderView;
    
    ODRefreshControl *  _refeshControl;

    
    UIImageView     * _topSwitchImgView;//切换聊天&小黑板的按钮背景图
    UIButton        * _groupChatBtn;//切换聊天的按钮
    UIButton        * _blackBoardBtn;//切换小黑板的按钮
    
    UIScrollView    * _switchScrollView;//左右切换显示聊天内容&小黑板内容的ScrollView
    
    UITableView     * _blackBoardTable;//显示小黑板的Table
    NSMutableArray  * _wallListArray;

    NSInteger         _getWallListPageIndex;//获取小黑板的page
    BOOL              _isLoadingWallLists;//判断是否在进行列表加载
    BOOL              _canLoadMoreWallLists;//判断能否加载更多
    
    UIView                      *_refreshMoreView;
    UILabel                     *_refreshMoreLabel;
    UIActivityIndicatorView     *_activityIndicatior;

    
    int                          _detailIndex;
    
    NSString       *_blackBoardToken;
    
    BOOL            _isAddNewBoard; //是否刚添加小黑板
}


@property(retain,nonatomic)NSDictionary * roomInfoDictionary;
@property (nonatomic, assign) NSInteger roomMemberCount;

@end
