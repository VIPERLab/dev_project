//
//  MyOrderQuankuanCell.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-19.
//
//

#import <UIKit/UIKit.h>
#import "LastMinuteUserOrder.h"

#define MyOrderQuankuanCellHeight   225.0f//235.0f   

@protocol MyOrderQuankuanCellDelegate;
@interface MyOrderQuankuanCell : UITableViewCell

@property (nonatomic, assign) id<MyOrderQuankuanCellDelegate>            delegate;
@property (nonatomic, retain) UIViewController                          *homeViewController;
@property (nonatomic, retain) LastMinuteUserOrder                       *userOrder;

//设置闹钟提醒
+ (void)setReminderWithUserOrder:(LastMinuteUserOrder*)aUserOrder timeInterval:(NSTimeInterval)aTimeInterval;

@end

@protocol MyOrderQuankuanCellDelegate <NSObject>

//全款订单 重新购买按钮
- (void)MyOrderQuankuanCellStyleFinishRebuyButtonClickAction:(id)sender cell:(MyOrderQuankuanCell*)aCell;
//不可支付余款 通知我
- (void)MyOrderQuankuanCellStyleNotPayBalanceNotifyButtonClickAction:(id)sender cell:(MyOrderQuankuanCell*)aCell;
//立即支付按钮
- (void)MyOrderQuankuanCellStyleNotPayZhifuButtonClickAction:(id)sender cell:(MyOrderQuankuanCell*)aCell;
//titile 按钮点击
- (void)MyOrderQuankuanCellTitleButtonClickAction:(id)sender cell:(MyOrderQuankuanCell*)aCell;

@end
