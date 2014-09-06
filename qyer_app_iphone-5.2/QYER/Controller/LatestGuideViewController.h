//
//  LatestGuideViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-2.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideViewCell.h"

@interface LatestGuideViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,GuideViewCellDelegate>
{
    UIImageView         *_headView;
    UITableView         *_tableview_latestGuideVC;
    NSMutableArray      *_array_guide;
    BOOL                _initFlag;
    NSString            *_guideName_needUpdate;
    NSInteger           position;   //查看锦囊详情页时点击的位置
    NSInteger           _position_section_tapCell;  //点击cell的位置section
    NSInteger           _position_row_tapCell;      //点击cell的位置row
}

@end

