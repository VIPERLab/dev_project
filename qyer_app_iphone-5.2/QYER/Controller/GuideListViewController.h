//
//  GuideListViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-25.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideViewCell.h"
@class QYGuide;



@interface GuideListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GuideViewCellDelegate>
{
    UIImageView             *_headView;
    UIButton                *_backButton;
    UILabel                 *_titleLabel;
    NSString                *_continentName; //大洲名字
    
    UITableView             *_tableView_guideListVC;
    NSMutableArray          *_array_guide;
    NSString                *_guideName_needUpdate;
    
    NSInteger               _position_section_tapCell;  //点击cell的位置section
    NSInteger               _position_row_tapCell;      //点击cell的位置row
    
    BOOL                    _flag_delay;
    
    UIImageView             *_imageView_failed;
}

@property(nonatomic,retain) NSString *type;    //标识国家或城市
@property(nonatomic,retain) NSString *type_id; //标识国家或城市的id
@property(nonatomic,assign) NSString *where_from;

@end
