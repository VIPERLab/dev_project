//
//  MyPostsViewController.h
//  QYER
//
//  Created by 我去 on 14-7-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>




typedef enum
{
	travel_state = 1,    //我的游记
	collect_state = 2,   //我的收藏
} Select_state;



@interface MyPostsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    UIImageView         *_headView;
    UIView              *_toolBar;
    UIButton            *_button_travel;
    UIButton            *_button_collector;
    UITableView         *_tableView_myPost;
    NSMutableArray      *_array_travel;
    NSMutableArray      *_array_collect;
    Select_state        _select_state;
    NSInteger           _page_user;
    NSInteger           _page_userCollect;
    
    UIImageView         *_imageView_default;
    
    UIView              *_footerView;
    BOOL                _flag_getMore_collect;  //是否还可以加载更多数据
    BOOL                _flag_getMore_travel;   //是否还可以加载更多数据
    BOOL                _flag_pullToLoading_travel;    //是否正在上拉加载更多
    BOOL                _flag_pullToLoading_collect;   //是否正在上拉加载更多
}

@property(nonatomic,assign) NSInteger user_id;

@end
