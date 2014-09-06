//
//  DownloadViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-6-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideViewCell.h"
@class GuideDownloadingViewController;
@class QYGuide;

@interface DownloadViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GuideViewCellDelegate>
{
    UIViewController                *_currentVC;
    UIImageView                     *_headView;
    BOOL                            _flag_show;
    
    UITableView                     *_tableView_downloadVC;
    NSMutableArray                  *_array_download;
    NSMutableArray                  *_array_downloading;
    NSMutableArray                  *_array_needToBeUpdated;
    UIImageView                     *_imageView_default;
    
    UIView                          *_backGroundView_update;
    UIButton                        *_button_update;
    UIButton                        *_button_close;
    
    NSInteger                       _position_row_tapCell;
    NSInteger                       _position_section_tapCell;
    
    NSMutableArray                  *_array_guideName_needUpdate;
    NSString                        *_guideName_needUpdate;
    
    GuideDownloadingViewController  *_guideDownloadingVC;
    QYGuide                         *_guide_needUpdeted;
    BOOL                            _flag_new;
    BOOL                            _flag_delay;
}

@property(nonatomic,retain) UIViewController *currentVC;
@property(nonatomic,assign) BOOL showNavigationBar;

-(void)didShow;
-(void)reloadTableView;
-(void)freshDownloadAndDownloadingData;

@end

