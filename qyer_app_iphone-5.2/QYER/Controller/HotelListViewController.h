//
//  HotelListViewController.h
//  TempGuide
//
//  Created by 张伊辉 on 14-3-10.
//  Copyright (c) 2014年 yihui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"
@interface HotelListViewController : QYBaseViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray *hotelListArray;
    UITableView *mainTable;
    BOOL isLoading;
    LoadMoreView *footView;
}
@end
