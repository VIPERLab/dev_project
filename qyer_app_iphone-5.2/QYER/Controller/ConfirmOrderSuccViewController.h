//
//  ConfirmOrderSuccViewController.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-14.
//
//

#import "BaseOrderViewController.h"
#import "LastMinuteUserOrder.h"
#import "LastMinuteOrderInfo.h"

@interface ConfirmOrderSuccViewController : BaseOrderViewController

@property (nonatomic, assign) NSInteger                      orderId;
@property (nonatomic, retain) LastMinuteOrderInfo           *orderInfo;

@property (nonatomic, retain) UIViewController              *homeViewController;

@end
