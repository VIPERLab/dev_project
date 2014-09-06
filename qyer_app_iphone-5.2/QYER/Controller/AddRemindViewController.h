//
//  AddRemindViewController.h
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-9-25.
//
//

#import <UIKit/UIKit.h>
//#import "QYBaseViewController.h"
#import "QYLMBaseViewController.h"
#import "RemindTypeViewController.h"
#import "RemindTimeViewController.h"
#import "RemindStartPositionViewController.h"
#import "RemindLocationViewController.h"

@interface AddRemindViewController : QYLMBaseViewController
<
UITableViewDataSource,
UITableViewDelegate,
RemindTypeViewControllerDelegate,
RemindTimeViewControllerDelegate,
RemindStartPositionViewControllerDelegate,
RemindLocationViewControllerDelegate
>
{
    UITableView     *_tableView;
    UIButton        *_confirmButton;
    
    NSMutableArray  *_typeArray;
    NSMutableArray  *_timeArray;
    NSMutableArray  *_startPositionArray;
    NSMutableArray  *_countryArray;
    NSMutableArray  *_hotCountryArray;
    
    NSDictionary    *_type;
    NSDictionary    *_time;
    NSDictionary    *_startPosition;
    NSDictionary    *_location;
}

@property (retain, nonatomic) NSDictionary *type;
@property (retain, nonatomic) NSDictionary *time;
@property (retain, nonatomic) NSDictionary *startPosition;
@property (retain, nonatomic) NSDictionary *location;

@end
