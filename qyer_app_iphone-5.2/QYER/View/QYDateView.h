//
//  QYDateView.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-19.
//
//

#import <UIKit/UIKit.h>
#import "QYDateCategory.h"

#define k_date_width       43.0f
#define k_date_height      60.0f

@protocol QYDateViewDelegate;
@interface QYDateView : UIView

@property (nonatomic, assign) NSInteger                date;
@property (nonatomic, assign) BOOL                     isOtherDate;
@property (nonatomic, retain) QYDateCategory           *dateCategory;

@property (nonatomic, assign) id<QYDateViewDelegate>   delegate;


@end

@protocol QYDateViewDelegate <NSObject>

@optional
- (void)QYDateViewCategoryButtonClickAction:(id)sender view:(QYDateView*)aDateView;

@end
