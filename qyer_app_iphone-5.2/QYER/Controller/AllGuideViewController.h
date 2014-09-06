//
//  AllGuideViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideCell.h"
#import "GuideViewCell.h"
#import "GuideCell.h"




@interface AllGuideViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GuideViewCellDelegate,GuideCellDelegate>
{
    UIImageView                 *_headView;
    UIViewController            *_currentVC;
    UIView                      *_scrollView_background;
    UITableView                 *_tableView_GuideVC;
    UITableView                 *_tableView_category;
    NSInteger                   _selectedButtont_state;
    
    NSMutableArray              *_array_allGuideCategory;
    NSMutableArray              *_array_allGuide;
    NSMutableDictionary         *_dic_guide;
    NSMutableArray              *_array_country;
    
    NSInteger                   _position_section_tapCell;  //点击cell的位置section
    NSInteger                   _position_row_tapCell;      //点击cell的位置row
    NSInteger                   _getData_status;            //是否已从服务器下载下了数据(getall成功)
    BOOL                        _flag_delay;
    BOOL                        _flag_freshData;            //重新刷新数据得标志
    BOOL                        _flag_timeout;              //超时flag
}

@property(nonatomic,retain) UIViewController   *currentVC;
-(void)reloadTableView;
-(void)initGuideData;
-(void)initGuideDataFromServe;
-(void)getData;
-(void)cancleGetGuideData;
@end
