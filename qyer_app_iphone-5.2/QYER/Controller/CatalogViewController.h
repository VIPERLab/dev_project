//
//  CatalogViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-7.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYGuide;

@interface CatalogViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    UIImageView             *_headView;
    UIButton                *_button_back;
    UIButton                *_button_continue;
    UILabel                 *_titleLabel;
    NSString                *_title_navigation;
    
    NSString                *_str_guideName;
    
    UITableView             *_tableview_CatalogVC;
    NSMutableArray          *_array_catalog;
    NSMutableArray          *_array_bookmark;
    BOOL                    _flag_fromReadVC;
}
@property(nonatomic,assign) BOOL        flag_fromReadVC;
@property(nonatomic,assign) BOOL        flag_isShowGuideCover;
@property(nonatomic,assign) NSInteger   position;
@property(nonatomic,retain) NSString    *str_guideName;
@property(nonatomic,retain) QYGuide     *guide;

@end
