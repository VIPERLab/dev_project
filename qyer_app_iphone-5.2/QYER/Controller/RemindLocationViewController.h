//
//  RemindLocationViewController.h
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-9-27.
//
//

#import <UIKit/UIKit.h>
//#import "QYBaseViewController.h"
#import "QYLMBaseViewController.h"

@protocol RemindLocationViewControllerDelegate;

@interface RemindLocationViewController : QYLMBaseViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    UIImageView         *_searchBackImageView;
    UISearchBar         *_searchBar;
    UIButton            *_searchCancelButton;
    UITableView         *_tableView;
    UITableView         *_searchTableView;
    
    UIView              *_searchBackView;
    
    NSMutableArray      *_countryArray;
    NSMutableArray      *_hotCountryArray;
    NSMutableArray      *_searchArray;
    
    id<RemindLocationViewControllerDelegate>    _delegate;
}

@property (retain, nonatomic) NSMutableArray *countryArray;
@property (retain, nonatomic) NSMutableArray *hotCountryArray;
@property (assign, nonatomic) id<RemindLocationViewControllerDelegate> delegate;

@end

@protocol RemindLocationViewControllerDelegate <NSObject>

- (void)remindLocationViewControllerDidSelectHotLocation:(NSDictionary *)hotLocation;

@end