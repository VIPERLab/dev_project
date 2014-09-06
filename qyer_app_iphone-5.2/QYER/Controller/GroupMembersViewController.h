//
//  GroupMembersViewController.h
//  QYER
//
//  Created by 张伊辉 on 14-5-13.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"
@interface GroupMembersViewController : QYBaseViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray *dataArray;
    
    UITableView *mainTable;
    
    BOOL isLoading;
    LoadMoreView *footView;
    NSMutableArray *imUserIds;
    
    
    int page;
    int pageSize;
    
    UITableView *_tableView;
}
/**
 *  聊天室ID
 */
@property (nonatomic, retain) NSString *topicId;
@end
