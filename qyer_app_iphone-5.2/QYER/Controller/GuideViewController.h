//
//  GuideViewController.h
//  QYER
//
//  Created by 我去 on 14-3-20.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DownloadViewController;
@class AllGuideViewController;


typedef enum
{
	allGuide_state = 0,          //全部
	download_state = 1,          //已下载
} SelectedView_state;


@interface GuideViewController : UIViewController
{
    UIImageView                 *_headView;
    UIViewController            *_currentVC;
    UIControl                   *_firstLoad_failed;
    
    UIView                      *_toolBar;
    UIButton                    *_button_all;
    UIButton                    *_button_download;
    SelectedView_state          _selectedView_state;
    
    DownloadViewController      *_downloadVC;
    AllGuideViewController      *_allGuideVC;
}

@property(nonatomic,retain) UIViewController   *currentVC;

-(void)reloadTableView;

@end
