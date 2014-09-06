//
//  RemindTimeViewController.h
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-9-27.
//
//

#import <UIKit/UIKit.h>
//#import "QYBaseViewController.h"
#import "QYLMBaseViewController.h"

@protocol RemindTimeViewControllerDelegate;

@interface RemindTimeViewController : QYLMBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView         *_tableView;
    NSMutableArray      *_timeArray;
    
    id<RemindTimeViewControllerDelegate>    _delegate;
    NSString            *_selectedName;
}

@property (retain, nonatomic) NSMutableArray *timeArray;
@property (assign, nonatomic) id<RemindTimeViewControllerDelegate> delegate;
@property (retain, nonatomic) NSString *selectedName;

@end

@protocol RemindTimeViewControllerDelegate <NSObject>

- (void)remindTimeViewControllerDidSelectTime:(NSDictionary *)time;

@end
