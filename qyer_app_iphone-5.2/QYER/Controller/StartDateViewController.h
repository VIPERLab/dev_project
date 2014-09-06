//
//  StartDateViewController.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-17.
//
//

//#import "QYBaseViewController.h"
#import "QYLMBaseViewController.h"
#import "QYDateCategory.h"

@protocol StartDateViewControllerDelegate;
@interface StartDateViewController : QYLMBaseViewController

@property (nonatomic, assign) NSUInteger                               produectId;

@property (nonatomic, assign) id<StartDateViewControllerDelegate>      delegate;

@end

@protocol StartDateViewControllerDelegate <NSObject>

@optional
- (void)StartDateViewControllerCategoryButtonClickAction:(id)sender viewController:(StartDateViewController*)aViewController dateCategory:(QYDateCategory*)aDateCategory;

@end
