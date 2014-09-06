//
//  MyOrderYukuanCell.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-19.
//
//

#import <UIKit/UIKit.h>
#import "LastMinuteUserOrder.h"

#define MyOrderYukuanCellHeight   435.0f//444.0f

@protocol MyOrderYukuanCellDelegate;
@interface MyOrderYukuanCell : UITableViewCell

@property (nonatomic, assign) id<MyOrderYukuanCellDelegate>      delegate;
@property (nonatomic, retain) UIViewController                  *homeViewController;
@property (nonatomic, retain) LastMinuteUserOrder               *userOrder;


@end

@protocol MyOrderYukuanCellDelegate <NSObject>

- (void)MyOrderYukuanCellStyleNotPayZhifuButtonClickAction:(id)sender cell:(MyOrderYukuanCell*)aCell;
//title button 点击
- (void)MyOrderYukuanCellTitleButtonClickAction:(id)sender cell:(MyOrderYukuanCell*)aCell;

@end
