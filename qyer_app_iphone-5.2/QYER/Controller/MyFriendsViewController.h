//
//  MyFriendsViewController.h
//  QYER
//
//  Created by 我去 on 14-5-12.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ODRefreshControl;
typedef enum
{
	follow_state = 0,        //我的关注
	fans_state = 1,          //我的粉丝
} Selected_state;



@interface MyFriendsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    UIImageView                 *_headView;
    UIImageView                 *_imageView_failed;
    UIView                      *_toolBar;
    UIButton                    *_button_fans;
    UIButton                    *_button_follow;
    Selected_state              _selected_state;
    
    NSInteger                   _fans_pageNumber;
    NSInteger                   _follows_pageNumber;
    BOOL                        _flag_canLoadMore_fans;
    BOOL                        _flag_canLoadMore_follows;
    NSMutableArray              *_array_fansData;
    NSMutableArray              *_array_followsData;
    
    UITableView                 *_tableView_myFriends;
    UIView                      *_footView;
    UIActivityIndicatorView     *_activityView;
    UIImageView                 *_imageView_default;
    
    BOOL _reloading;
    
    //下拉刷新:
    ODRefreshControl *_refreshControl;
}

@property(nonatomic,assign) NSInteger user_id;
@property(nonatomic,retain) NSString *type;

@end
