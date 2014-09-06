//
//  LastMinuteDetail.h
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-16.
//
//

#import <Foundation/Foundation.h>
#import "QYCommonToast.h"

typedef void(^QYLastMinuteUserOrderSuccessBlock) (NSArray *data);
typedef void(^QYLastMinuteUserOrderListSuccessBlock) (NSArray *data, NSInteger count);
typedef void(^QYLastMinuteUserOrderDataSuccessBlock) (NSData *data);
typedef void(^QYLastMinuteUserOrderDictionarySuccessBlock) (NSDictionary *dic);
typedef void(^QYLastMinuteUserOrderFailureBlock) (NSError *error);

@interface LastMinuteUserOrder : NSObject <NSCopying>
{
    
    NSNumber            *_orderId;//订单号
    
    NSString            *_orderBuyerInfoName;//默认购买人姓名
    NSString            *_orderBuyerInfoPhone;//默认购买人电话
    NSString            *_orderBuyerInfoEmail;//默认购买人邮箱
    
    NSNumber            *_orderPid;
    NSNumber            *_orderNum;//购买数量
    NSString            *_orderName;
    NSString            *_orderPhone;
    NSString            *_orderEmail;
    NSNumber            *_orderUid;
    NSString            *_orderUnitPrice;//购买单价
    NSString            *_orderPrice;//购买总价
    OrderPayment         _orderPayment;//订单状态  1 已支付 0未支付 -1超时
    NSNumber            *_orderStock;//库存数
    NSNumber            *_orderDatetime;
    NSString            *_orderFirstpay;
    NSNumber            *_orderRelid;
    NSString            *_orderBuyerEmail;
    NSString            *_orderBuyerId;
    NSString            *_orderNotifyId;
    NSString            *_orderNotifyTime;
    NSString            *_orderNotifyType;
    NSString            *_orderPaymentType;
    NSString            *_orderSellerEmail;
    NSString            *_orderSellerId;
    NSString            *_orderSign;
    NSString            *_orderSignType;
    NSString            *_orderTotalFee;
    NSString            *_orderTradeNo;
    NSString            *_orderTradeStatus;
    NSString            *_orderTeturnType;
    NSNumber            *_orderReturnTime;
    NSNumber            *_orderDeadlineTime;//截止时间
    NSNumber            *_orderLastminuteId;//折扣id
    NSString            *_orderLastminuteTitle;//折扣标题
    NSString            *_orderLastminutePrice;//折扣价格
    OrderProductType     _orderProductsType;//产品类型  0为全款 1为预付款 2为尾款
    NSString            *_orderProductsTitle;//产品标题
    NSString            *_orderAlipayAccount;//商家支付宝号
    NSString            *_orderSupplierTitle;//商家名称
    SupplierType         _orderSupplierType;//商家类型 1，非认证商家 0，认证商家
    NSString            *_orderSupplierPhone;//商家电话
    LastMinuteUserOrder *_orderBalanceOrder;
    NSNumber            *_orderSecondpayStartTime;//余款开始时间戳
    NSNumber            *_orderSecondpayEndTime;//余款结束时间戳
    OrderPayType         _orderPayType;//支付方式 0.App支付 1.Web支付
    
    NSNumber            *_orderFirstpayEndTime;//订单第一次购买结束时间戳
    NSString            *_orderStartDate;//出发日期：2014/06/25
    
    
}

@property (retain, nonatomic) NSNumber            *orderId;//订单号

@property (retain, nonatomic) NSString            *orderBuyerInfoName;//默认购买人姓名
@property (retain, nonatomic) NSString            *orderBuyerInfoPhone;//默认购买人电话
@property (retain, nonatomic) NSString            *orderBuyerInfoEmail;//默认购买人邮箱

@property (retain, nonatomic) NSNumber            *orderPid;
@property (retain, nonatomic) NSNumber            *orderNum;//购买数量
@property (retain, nonatomic) NSString            *orderName;
@property (retain, nonatomic) NSString            *orderPhone;
@property (retain, nonatomic) NSString            *orderEmail;
@property (retain, nonatomic) NSNumber            *orderUid;
@property (retain, nonatomic) NSString            *orderUnitPrice;//购买单价
@property (retain, nonatomic) NSString            *orderPrice;//购买总价
@property (assign, nonatomic) OrderPayment         orderPayment;//订单状态  1 已支付 0未支付 -1超时
@property (retain, nonatomic) NSNumber            *orderStock;//库存数
@property (retain, nonatomic) NSNumber            *orderDatetime;
@property (retain, nonatomic) NSString            *orderFirstpay;
@property (retain, nonatomic) NSNumber            *orderRelid;
@property (retain, nonatomic) NSString            *orderBuyerEmail;
@property (retain, nonatomic) NSString            *orderBuyerId;
@property (retain, nonatomic) NSString            *orderNotifyId;
@property (retain, nonatomic) NSString            *orderNotifyTime;
@property (retain, nonatomic) NSString            *orderNotifyType;
@property (retain, nonatomic) NSString            *orderPaymentType;
@property (retain, nonatomic) NSString            *orderSellerEmail;
@property (retain, nonatomic) NSString            *orderSellerId;
@property (retain, nonatomic) NSString            *orderSign;
@property (retain, nonatomic) NSString            *orderSignType;
@property (retain, nonatomic) NSString            *orderTotalFee;
@property (retain, nonatomic) NSString            *orderTradeNo;
@property (retain, nonatomic) NSString            *orderTradeStatus;
@property (retain, nonatomic) NSString            *orderTeturnType;
@property (retain, nonatomic) NSNumber            *orderReturnTime;//支付成功时间戳
@property (retain, nonatomic) NSNumber            *orderDeadlineTime;//截止时间
@property (retain, nonatomic) NSNumber            *orderLastminuteId;//折扣id
@property (retain, nonatomic) NSString            *orderLastminuteTitle;//折扣标题
@property (retain, nonatomic) NSString            *orderLastminutePrice;//折扣价格
@property (assign, nonatomic) OrderProductType     orderProductsType;//产品类型  0为全款 1为预付款 2为尾款
@property (retain, nonatomic) NSString            *orderProductsTitle;//产品标题
@property (retain, nonatomic) NSString            *orderAlipayAccount;//商家支付宝号
@property (retain, nonatomic) NSString            *orderSupplierTitle;//商家名称
@property (assign, nonatomic) SupplierType         orderSupplierType;//商家类型 1，非认证商家 0，认证商家
@property (retain, nonatomic) NSString            *orderSupplierPhone;//商家电话
@property (retain, nonatomic) LastMinuteUserOrder *orderBalanceOrder;
@property (retain, nonatomic) NSNumber            *orderSecondpayStartTime;//余款开始时间戳
@property (retain, nonatomic) NSNumber            *orderSecondpayEndTime;//余款结束时间戳
@property (assign, nonatomic) OrderPayType         orderPayType;//支付方式  0 未支付 1 web端支付 2 app端支付

@property (retain, nonatomic) NSNumber            *orderFirstpayEndTime;//订单第一次购买结束时间戳
@property (retain, nonatomic) NSString            *orderStartDate;//出发日期：2014/06/25

//- (NSString*)alipayDescription;

- (id)initWithAttribute:(NSDictionary *)attribute;
//+ (NSArray *)parseFromeData:(NSData *)data;
//+ (NSArray *)parseFromeDetailData:(NSData *)data;


//获取折扣订单详情
+ (void)getLastMinuteOrderInfoDetailWithId:(NSUInteger)orderId
                                   success:(QYLastMinuteUserOrderSuccessBlock)successBlock
                                   failure:(QYLastMinuteUserOrderFailureBlock)failureBlock;

//获取用户订单列表
+ (void)getLastMinuteUserOrderListWithCount:(NSUInteger)aCount
                                       page:(NSUInteger)aPage
                                    success:(QYLastMinuteUserOrderListSuccessBlock)successBlock
                                    failure:(QYLastMinuteUserOrderFailureBlock)failureBlock;

//删除折扣订单详情
+ (void)deleteLastMinuteUserOrderWithId:(NSUInteger)orderId
                                success:(QYLastMinuteUserOrderDictionarySuccessBlock)successBlock
                                failure:(QYLastMinuteUserOrderFailureBlock)failureBlock;

//生成尾款订单
+ (void)createLastMinuteBalanceOrderWithId:(NSUInteger)orderId
                                   success:(QYLastMinuteUserOrderDictionarySuccessBlock)successBlock
                                   failure:(QYLastMinuteUserOrderFailureBlock)failureBlock;

//通知后台主动查询支付宝
+ (void)backendAlipayQueryWithId:(NSUInteger)orderId
                         success:(QYLastMinuteUserOrderDataSuccessBlock)successBlock
                         failure:(QYLastMinuteUserOrderFailureBlock)failureBlock;

//封装通知后台主动查询支付宝的逻辑，包括两次请求 (外用)
+ (void)commonBackendAlipayQueryWithId:(NSUInteger)orderId
                               success:(QYLastMinuteUserOrderDataSuccessBlock)successBlock
                               failure:(QYLastMinuteUserOrderFailureBlock)failureBlock;


//产品类型  0为全款 1为预付款 2为尾款
+ (NSString*)typeNameWithProductType:(OrderProductType)aType;

//产品类型  0为全款 1为预付款 2为尾款
+ (NSString*)toastWithProductType:(OrderProductType)aType userOrder:(LastMinuteUserOrder*)aUserOrder;


@end
