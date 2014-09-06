//
//  FunctionFillOrderCell.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-18.
//
//

#import <UIKit/UIKit.h>
#import "LastMinuteProduct.h"
#import "QYCheckBox.h"

#define k_Cell_Padding              10

#define k_ProductTitle_Format       @"%@"//@"%@（库存：%d）"
#define k_ProductName_Width         192
#define k_ProductName_Width_Long    254
#define k_ProductName_Font          [UIFont systemFontOfSize:13.0]

@protocol FunctionFillOrderCellDelegate;
@interface FunctionFillOrderCell : UITableViewCell

@property (nonatomic, assign) id<FunctionFillOrderCellDelegate>       delegate;
@property (nonatomic, retain) LastMinuteProduct                      *product;
@property (nonatomic, retain) QYCheckBox                             *contentBgButton;

+ (CGFloat)heightForCellWithProduct:(LastMinuteProduct*)aProduct;

//设置文字颜色
- (void)setColorOfContentWithSelected:(BOOL)isSelected;

@end

@protocol FunctionFillOrderCellDelegate <NSObject>

- (void)FunctionFillOrderCellContentBgButtonClick:(id)sender cell:(FunctionFillOrderCell*)aCell;

@end
