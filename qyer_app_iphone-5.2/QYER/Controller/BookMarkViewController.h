//
//  BookMarkViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-6.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookMarkViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    UIImageView         *_headView;
    UITableView         *_tableview_BookMarkVC;
    NSMutableArray      *_array_guideName;
    NSMutableDictionary *_dic_bookMark;
    UIImageView         *_imageView_default;
    UIViewController    *_currentVC;
}

@property(nonatomic,retain) UIViewController    *currentVC;
@property(nonatomic,assign) BOOL                flag_navigation;

@end
