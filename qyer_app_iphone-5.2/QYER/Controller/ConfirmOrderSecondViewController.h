//
//  ConfirmOrderSecondViewController.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-14.
//
//

#import "BaseOrderViewController.h"
//#import "LastMinuteOrderInfoDetail.h"
#import "LastMinuteOrderInfo.h"
#import "LastMinuteUserOrder.h"
//#import "ConfirmOrderFirstViewController.h"
#import "FillOrderViewController.h"

@interface ConfirmOrderSecondViewController : BaseOrderViewController

@property (nonatomic, assign) NSInteger                             orderId;
@property (nonatomic, retain) LastMinuteUserOrder                  *userOrder;
@property (nonatomic, retain) LastMinuteOrderInfo                  *orderInfo;

@property (nonatomic, retain) FillOrderViewController              *homeFillOrderViewController;


//刷新数据
- (void)refreshDate;
//点击重新购买按钮
- (void)rebuyButtonClickAction:(id)sender;

//关闭 没有提示
- (void)closeWithoutAlert;

@end
