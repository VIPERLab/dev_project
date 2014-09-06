//
//  PictureListController.h
//  QYER
//
//  Created by 张伊辉 on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QYBaseViewController.h"
#import "CustomPickerImageDelegate.h"
@interface PictureListController : QYBaseViewController<UITableViewDelegate,UITableViewDataSource,CustomPickerImageDelegate>
{
    UITableView *mainTable;
    int rowCount;
}
@property (nonatomic,retain) UIViewController *viewController;
@property (nonatomic,assign) id delegate;
@property (nonatomic,retain) NSMutableDictionary *photoDict;
@end
