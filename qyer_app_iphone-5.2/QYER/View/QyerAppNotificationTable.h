//
//  QyerAppNotificationTable.h
//  QYER
//
//  Created by Qyer on 14-5-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QyerAppNotificationTableViewCell.h"
#import "LoadMoreView.h"

#import "BoardDetailViewController.h"

@interface QyerAppNotificationTable : UITableView<UITableViewDelegate,UITableViewDataSource,DeleteBoardMessgaeSuccessDelegate>{
    NSMutableArray *muArrData;
//    NSInteger _pageIndex;
//    BOOL isCanLoadData;
    
    BOOL isLoading;
    LoadMoreView *footView;
    int page;
}
@property(nonatomic,assign) UIViewController  *currentVC;
-(void)requestDataFromServer:(BOOL)isNeedLoadMore;
@end
