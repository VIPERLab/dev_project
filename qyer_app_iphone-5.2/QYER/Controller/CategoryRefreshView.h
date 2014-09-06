//
//  CategoryRefreshView.h
//  LastMinute
//
//  Created by lide on 13-7-1.
//
//

#import <UIKit/UIKit.h>

typedef enum _CategoryType
{
    CategoryLastMinute = 0,
    CategoryTime = 1,
    CategoryPOI = 2,
    CategoryDeparture = 3,
}CategoryType;

@protocol CategoryRefreshViewDelegate;

@interface CategoryRefreshView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    UIImageView                 *_backgroundImageView;
    UIActivityIndicatorView     *_activiayIndicator;
    UILabel                     *_label;
    UIImageView                 *_shadowImageView;
    
    UITableView                 *_tableView;
    NSMutableArray              *_categoryArray;
    UITableView                 *_countryTableView;
    
    NSString                    *_selectedName;
    
    id<CategoryRefreshViewDelegate> _delegate;
    CategoryType                _type;
    
    NSUInteger                  _selectIndex;
}

@property (retain, nonatomic) NSMutableArray *categoryArray;
@property (retain, nonatomic) NSString *selectedName;

@property (assign, nonatomic) id<CategoryRefreshViewDelegate> delegate;
@property (assign, nonatomic) CategoryType type;
@property (assign, nonatomic) NSUInteger selectIndex;

- (void)show;
- (void)hide;

@end

@protocol CategoryRefreshViewDelegate <NSObject>

- (void)categoryRefreshViewDidSelectWithDictionary:(NSDictionary *)dictionary;
- (void)categoryRefreshViewDidSelectWithDictionary:(NSDictionary *)dictionary withIndex:(NSIndexPath *)indexPath;

@end
