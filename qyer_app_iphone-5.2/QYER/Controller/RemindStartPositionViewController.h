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

@protocol RemindStartPositionViewControllerDelegate;

@interface RemindStartPositionViewController : QYLMBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView                                      *_tableView;
    NSMutableArray                                   *_startPositionArray;
    id<RemindStartPositionViewControllerDelegate>    _delegate;
    NSString                                         *_selectedName;
}

@property (retain, nonatomic) NSMutableArray                                  *startPositionArray;
@property (assign, nonatomic) id<RemindStartPositionViewControllerDelegate>   delegate;
@property (retain, nonatomic) NSString                                        *selectedName;

@end

@protocol RemindStartPositionViewControllerDelegate <NSObject>

- (void)remindStartPositionViewControllerDidSelectStartPosition:(NSDictionary *)startPosition;

@end
