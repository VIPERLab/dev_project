//
//  GuideDownloadingViewController.h
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-21.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuideViewCell.h"

@interface GuideDownloadingViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GuideViewCellDelegate>
{
    UIImageView             *_headView;
    UIButton                *_backButton;
    UILabel                 *_titleLabel;
    
    UITableView             *_tableView_downloadingVC;
    NSMutableArray          *_array_guideDownloading;
}
@property(nonatomic,retain) NSMutableArray *array_guideDownloading;

-(void)initView;
-(void)startDownload;

@end
