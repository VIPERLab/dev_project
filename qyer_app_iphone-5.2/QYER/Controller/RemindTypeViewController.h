//
//  RemindTypeViewController.h
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-9-27.
//
//

#import <UIKit/UIKit.h>
//#import "QYBaseViewController.h"
#import "QYLMBaseViewController.h"

@protocol RemindTypeViewControllerDelegate;

@interface RemindTypeViewController : QYLMBaseViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView         *_tableView;
    NSMutableArray      *_typeArray;
    
    id<RemindTypeViewControllerDelegate>    _delegate;
    
    NSString            *_selectedName;
}

@property (retain, nonatomic) NSMutableArray *typeArray;
@property (assign, nonatomic) id<RemindTypeViewControllerDelegate> delegate;
@property (retain, nonatomic) NSString *selectedName;

@end

@protocol RemindTypeViewControllerDelegate <NSObject>

- (void)remindTypeViewControllerDidSelectType:(NSDictionary *)type;

@end
