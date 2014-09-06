//
//  FillOrderViewController.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-16.
//
//

//#import "QYBaseViewController.h"
#import "QYLMBaseViewController.h"
#import "LastMinuteDetailViewControllerNew.h"
#import "LastMinuteProduct.h"
#import "LastMinuteOrderInfo.h"


@interface FillOrderViewController : QYLMBaseViewController

@property (nonatomic, assign) NSUInteger                            lastMinuteId;

@property (nonatomic, retain) LastMinuteDetailViewControllerNew        *homeDetailViewController;

@end
