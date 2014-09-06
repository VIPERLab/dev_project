//
//  StartDateCell.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-19.
//
//

#import <UIKit/UIKit.h>
#import "QYSectionCategory.h"
#import "QYDateView.h"

#define k_date_header_height   73.0f


@protocol StartDateCellDelegate;
@interface StartDateCell : UITableViewCell

@property (nonatomic, retain) QYSectionCategory *sectionCategory;

@property (nonatomic, assign) id<StartDateCellDelegate> delegate;

@end

@protocol StartDateCellDelegate <NSObject>
@optional
- (void)StartDateCellCategoryButtonClickAction:(id)sender cell:(StartDateCell*)aCell dateCategory:(QYDateCategory*)aDateCategory;

@end
