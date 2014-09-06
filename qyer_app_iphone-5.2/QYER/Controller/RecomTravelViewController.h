//
//  RecomTravelViewController.h
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"

@interface RecomTravelViewController : QYBaseViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray  *   userPlanListArray;
    UITableView     *   userPlanTable;
    LoadMoreView    *   userPlanTableFootView;
    BOOL                userPlanListIsLoading;

    
    NSMutableArray  *   officalPlanListArray;
    UITableView     *   officalPlanTable;
    LoadMoreView    *   officalPlanTableFootView;
    BOOL                officialPlanListIsLoading;
    
    
    int _userPlanPage;
    int _officalPlanPage;
    
    UIScrollView * _switchScrollView;
    UIButton * _officalPlanBtn;
    UIButton * _userPlanBtn;
    
}


@property(nonatomic,assign)int type;

@property(nonatomic,retain)NSString *key;

@end

