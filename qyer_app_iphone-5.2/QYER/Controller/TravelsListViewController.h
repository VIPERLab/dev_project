//
//  TravelsListViewController.h
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"
@interface TravelsListViewController : QYBaseViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray *travelsListArray;
    UITableView *mainTable;
    BOOL isLoading;
    LoadMoreView *footView;
    
    int page;
 
}
@property (nonatomic, retain) NSString *key;
@property (nonatomic,assign)int type;
@end
