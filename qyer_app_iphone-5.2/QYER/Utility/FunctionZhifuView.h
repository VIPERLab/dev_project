//
//  FunctionZhifuView.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-18.
//
//

#import <UIKit/UIKit.h>
#import "LastMinuteUserOrder.h"

typedef enum {
    FunctionZhifuTypeNone = -1,
    FunctionZhifuTypeWeb = 0,//支付宝网页端
    FunctionZhifuTypeApp = 1//支付宝钱包
} FunctionZhifuType;

@interface FunctionZhifuView : UIView

@property (nonatomic, assign) FunctionZhifuType       zhifuType;
@property (nonatomic, retain) LastMinuteUserOrder    *userOrder;
@property (nonatomic, retain) UIViewController       *homeViewController;

- (void)show;

@end
