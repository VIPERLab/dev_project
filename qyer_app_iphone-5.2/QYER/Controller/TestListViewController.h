//
//  TestListViewController.h
//  QYER
//
//  Created by 张伊辉 on 14-6-24.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QYBaseViewController.h"

@interface TestListViewController : QYBaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *muArrdata;
    UITableView *mainTable;
    int select;
}
@end
