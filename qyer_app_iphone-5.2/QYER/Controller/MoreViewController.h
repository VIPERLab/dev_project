//
//  MoreViewController.h
//  QyGuide
//
//  Created by 你猜你猜 on 13-8-28.
//
//

#import <UIKit/UIKit.h>
#import "MYActionSheet.h"

@interface MoreViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MYActionSheetDelegate>
{
    UIViewController    *_currentVC;
    
    UIImageView         *_headView;
    UIButton            *_buttonback;
    UITableView         *_tableView_moreVC;
    
    NSMutableArray      *_array_section;
    NSMutableArray      *_array_basicSetting;
    NSMutableArray      *_array_other;
    NSMutableArray      *_array_otherApp;
    NSMutableArray      *_applicationArray;
    
}

@property(nonatomic,retain) UIViewController    *currentVC;

@end
