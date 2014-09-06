//
//  MyGuideViewController.h
//  QYER
//
//  Created by 我去 on 14-5-6.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "QYBaseViewController.h"

@class DownloadViewController;
@class BookMarkViewController;


typedef enum
{
	download_state = 0,          //已下载
	bookmark_state = 1,          //书签
} SelectedView_state;




@interface MyGuideViewController : UIViewController
{
    UIImageView                 *_headView;
    
    UIView                      *_toolBar;
    UIButton                    *_button_bookmark;
    UIButton                    *_button_download;
    SelectedView_state          _selectedView_state;
    
    DownloadViewController      *_downloadVC;
    BookMarkViewController      *_bookmarkVC;
}

@end
