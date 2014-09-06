//
//  CityListViewController.h
//  QYER
//
//  Created by 张伊辉 on 14-3-17.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYBaseViewController.h"
#import "CityCell.h"


@interface CityListViewController : QYBaseViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray *cityListArray;
    UITableView *mainTable;
    BOOL isLoading;
    LoadMoreView *footView;
    
    int page;
}


//************ Insert By ZhangDong 2014.3.31 Start ***********
/**
 *  国家ID
 */
@property (nonatomic, retain) NSString *key;
//************ Insert By ZhangDong 2014.3.31 End **************
@end
