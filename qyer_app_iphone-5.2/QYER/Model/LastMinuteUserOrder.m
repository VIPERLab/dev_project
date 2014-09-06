//
//  LastMinuteDetail.m
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-16.
//
//

#import "LastMinuteUserOrder.h"
#import "QYAPIClient.h"
#import "QYCommonUtil.h"
#import "QYTime.h"
//#import "PartnerConfig.h"//支付宝配置
#import "QYCommonToast.h"
#import "NSString+MD5.h"

@implementation LastMinuteUserOrder

@synthesize orderId =_orderId;//订单号

@synthesize orderBuyerInfoName = _orderBuyerInfoName;
@synthesize orderBuyerInfoPhone = _orderBuyerInfoPhone;
@synthesize orderBuyerInfoEmail = _orderBuyerInfoEmail;

@synthesize orderPid = _orderPid;
@synthesize orderNum = _orderNum;//购买数量
@synthesize orderName = _orderName;
@synthesize orderPhone = _orderPhone;
@synthesize orderEmail = _orderEmail;
@synthesize orderUid = _orderUid;
@synthesize orderUnitPrice = _orderUnitPrice;//购买单价
@synthesize orderPrice = _orderPrice;//购买总价
@synthesize orderPayment = _orderPayment;//订单状态  1 已支付 0未支付 -1超时
@synthesize orderStock = _orderStock;//库存数
@synthesize orderDatetime = _orderDatetime;
@synthesize orderFirstpay = _orderFirstpay;
@synthesize orderRelid = _orderRelid;
@synthesize orderBuyerEmail = _orderBuyerEmail;
@synthesize orderBuyerId = _orderBuyerId;
@synthesize orderNotifyId = _orderNotifyId;
@synthesize orderNotifyTime = _orderNotifyTime;
@synthesize orderNotifyType = _orderNotifyType;
@synthesize orderPaymentType = _orderPaymentType;
@synthesize orderSellerEmail = _orderSellerEmail;
@synthesize orderSellerId = _orderSellerId;
@synthesize orderSign = _orderSign;
@synthesize orderSignType = _orderSignType;
@synthesize orderTotalFee = _orderTotalFee;
@synthesize orderTradeNo = _orderTradeNo;
@synthesize orderTradeStatus = _orderTradeStatus;
@synthesize orderTeturnType = _orderTeturnType;
@synthesize orderReturnTime = _orderReturnTime;//支付成功时间戳
@synthesize orderDeadlineTime = _orderDeadlineTime;//截止时间
@synthesize orderLastminuteId = _orderLastminuteId;////折扣id
@synthesize orderLastminuteTitle = _orderLastminuteTitle;//折扣标题
@synthesize orderLastminutePrice = _orderLastminutePrice;//折扣价格
@synthesize orderProductsType = _orderProductsType;//产品类型  0为全款 1为预付款 2为尾款
@synthesize orderProductsTitle = _orderProductsTitle;//产品标题
@synthesize orderAlipayAccount = _orderAlipayAccount;//商家支付宝号
@synthesize orderSupplierTitle = _orderSupplierTitle;//商家名称
@synthesize orderSupplierType = _orderSupplierType;//商家类型 1，非认证商家 0，认证商家
@synthesize orderSupplierPhone = _orderSupplierPhone;//商家电话
@synthesize orderBalanceOrder = _orderBalanceOrder;
@synthesize orderSecondpayStartTime = _orderSecondpayStartTime;//余款开始时间戳
@synthesize orderSecondpayEndTime = _orderSecondpayEndTime;//余款结束时间戳
@synthesize orderPayType = _orderPayType;//支付方式  0 未支付 1 web端支付 2 app端支付

@synthesize orderFirstpayEndTime = _orderFirstpayEndTime;//订单第一次购买结束时间戳
@synthesize orderStartDate = _orderStartDate;

- (id)copyWithZone:(NSZone *)zone
{
    LastMinuteUserOrder *userOrder = [[[self class] allocWithZone:zone] init];
    
    userOrder.orderId = _orderId;//订单号
    
    userOrder.orderBuyerInfoName = _orderBuyerInfoName;
    userOrder.orderBuyerInfoPhone = _orderBuyerInfoPhone;
    userOrder.orderBuyerInfoEmail = _orderBuyerInfoEmail;
    
    userOrder.orderPid = _orderPid;
    userOrder.orderNum = _orderNum;//购买数量
    userOrder.orderName = _orderName;
    userOrder.orderPhone = _orderPhone;
    userOrder.orderEmail = _orderEmail;
    userOrder.orderUid = _orderUid;
    userOrder.orderUnitPrice = _orderUnitPrice;//购买单价
    userOrder.orderPrice = _orderPrice;//购买总价
    userOrder.orderPayment = _orderPayment;//订单状态  1 已支付 0未支付 -1超时
    userOrder.orderStock = _orderStock;//库存数
    userOrder.orderDatetime = _orderDatetime;
    userOrder.orderFirstpay = _orderFirstpay;
    userOrder.orderRelid = _orderRelid;
    userOrder.orderBuyerEmail = _orderBuyerEmail;
    userOrder.orderBuyerId = _orderBuyerId;
    userOrder.orderNotifyId = _orderNotifyId;
    userOrder.orderNotifyTime = _orderNotifyTime;
    userOrder.orderNotifyType = _orderNotifyType;
    userOrder.orderPaymentType = _orderPaymentType;
    userOrder.orderSellerEmail = _orderSellerEmail;
    userOrder.orderSellerId = _orderSellerId;
    userOrder.orderSign = _orderSign;
    userOrder.orderSignType = _orderSignType;
    userOrder.orderTotalFee = _orderTotalFee;
    userOrder.orderTradeNo = _orderTradeNo;
    userOrder.orderTradeStatus = _orderTradeStatus;
    userOrder.orderTeturnType = _orderTeturnType;
    userOrder.orderReturnTime = _orderReturnTime;//支付成功时间戳
    userOrder.orderDeadlineTime = _orderDeadlineTime;//截止时间
    userOrder.orderLastminuteId = _orderLastminuteId;//折扣id
    userOrder.orderLastminuteTitle = _orderLastminuteTitle;//折扣标题
    userOrder.orderLastminutePrice = _orderLastminutePrice;//折扣价格
    userOrder.orderProductsType = _orderProductsType;//产品类型  0为全款 1为预付款 2为尾款
    userOrder.orderProductsTitle = _orderProductsTitle;//产品标题
    userOrder.orderAlipayAccount = _orderAlipayAccount;//商家支付宝号
    userOrder.orderSupplierTitle = _orderSupplierTitle;//商家名称
    userOrder.orderSupplierType = _orderSupplierType;//商家类型 1，非认证商家 0，认证商家
    userOrder.orderSupplierPhone = _orderSupplierPhone;//商家电话
    userOrder.orderBalanceOrder = _orderBalanceOrder;
    userOrder.orderSecondpayStartTime = _orderSecondpayStartTime;
    userOrder.orderSecondpayEndTime = _orderSecondpayEndTime;
    userOrder.orderPayType = _orderPayType;//支付方式  0 未支付 1 web端支付 2 app端支付
    
    userOrder.orderFirstpayEndTime = _orderFirstpayEndTime;//订单第一次购买结束时间戳
    userOrder.orderStartDate = _orderStartDate;
    
    return userOrder;
}

- (id)initWithAttribute:(NSDictionary *)attribute
{
    self = [super init];
    if(self != nil)
    {
        if(attribute != nil)
        {
            
            self.orderId = [NSNumber numberWithInt:[[attribute objectForKey:@"id"] intValue]];//订单号
            
            self.orderBuyerInfoName = [attribute objectForKey:@"buyerinfo_name"];
            self.orderBuyerInfoPhone = [attribute objectForKey:@"buyerinfo_phone"];
            self.orderBuyerInfoEmail = [attribute objectForKey:@"buyerinfo_email"];
            
            self.orderPid = [NSNumber numberWithInt:[[attribute objectForKey:@"pid"] intValue]];
            self.orderNum = [attribute objectForKey:@"num"]!=[NSNull null]?[NSNumber numberWithInt:[[attribute objectForKey:@"num"] intValue]]:[NSNumber numberWithInteger:0];//购买数量
            self.orderName = [attribute objectForKey:@"name"];
            self.orderPhone = [attribute objectForKey:@"phone"];
            self.orderEmail = [attribute objectForKey:@"email"];
            self.orderUid = [NSNumber numberWithInt:[[attribute objectForKey:@"uid"] intValue]];
            self.orderUnitPrice = [attribute objectForKey:@"unit_price"];//购买单价
            self.orderPrice = [attribute objectForKey:@"price"]!=[NSNull null]?[attribute objectForKey:@"price"]:@"";//购买总价
            self.orderPayment = [[attribute objectForKey:@"payment"] intValue];//订单状态  1 已支付 0未支付 -1超时
            self.orderStock = [attribute objectForKey:@"stock"]!=[NSNull null]?[NSNumber numberWithInt:[[attribute objectForKey:@"stock"] intValue]]:[NSNumber numberWithInt:0];//库存数
            self.orderDatetime = [NSNumber numberWithInt:[[attribute objectForKey:@"datetime"] intValue]];
            self.orderFirstpay = [attribute objectForKey:@"firstpay"];
            self.orderRelid = [attribute objectForKey:@"relid"]!=[NSNull null]?[NSNumber numberWithInt:[[attribute objectForKey:@"relid"] intValue]]:[NSNumber numberWithInt:0];
            self.orderBuyerEmail = [attribute objectForKey:@"buyer_email"];
            self.orderBuyerId = [attribute objectForKey:@"buyer_id"];
            self.orderNotifyId = [attribute objectForKey:@"notify_id"];
            self.orderNotifyTime = [attribute objectForKey:@"notify_time"];
            self.orderNotifyType = [attribute objectForKey:@"notify_type"];
            self.orderPaymentType = [attribute objectForKey:@"payment_type"];
            self.orderSellerEmail = [attribute objectForKey:@"seller_email"];
            self.orderSellerId = [attribute objectForKey:@"seller_id"];
            self.orderSign = [attribute objectForKey:@"sign"];
            self.orderSignType = [attribute objectForKey:@"sign_type"];
            self.orderTotalFee = [attribute objectForKey:@"total_fee"];
            self.orderTradeNo = [attribute objectForKey:@"trade_no"];
            self.orderTradeStatus = [attribute objectForKey:@"trade_status"];
            self.orderTeturnType = [attribute objectForKey:@"return_type"];
            self.orderReturnTime = [attribute objectForKey:@"return_time"]!=[NSNull null]?[NSNumber numberWithInt:[[attribute objectForKey:@"return_time"] intValue]]:[NSNumber numberWithInt:0];//支付成功时间戳
            self.orderDeadlineTime = [NSNumber numberWithInt:[[attribute objectForKey:@"lastalipaydatetime"] intValue]];//截止时间
            self.orderLastminuteId = [NSNumber numberWithInt:[[[attribute objectForKey:@"lastminute"] objectForKey:@"id"] intValue]];//折扣id
            self.orderLastminuteTitle = [attribute objectForKey:@"lastminute_title"];//折扣标题
            self.orderStartDate = [attribute objectForKey:@"products_departure_date"];//出发日期
            self.orderLastminutePrice = [attribute objectForKey:@"lastminute_price"];//折扣价格
            self.orderProductsType = [[attribute objectForKey:@"products_type"] intValue];//产品类型  0为全款 1为预付款 2为尾款
            self.orderProductsTitle = [attribute objectForKey:@"products_title"];//产品标题
            self.orderAlipayAccount = [attribute objectForKey:@"alipay_account"];//商家支付宝号
            self.orderSupplierTitle = [attribute objectForKey:@"supplier_title"];//商家名称
            self.orderSupplierType = [[attribute objectForKey:@"supplier_type"] intValue];//商家类型 1，非认证商家 0，认证商家
            self.orderSupplierPhone = [attribute objectForKey:@"supplier_phone"];//商家电话
            self.orderSecondpayStartTime = [attribute objectForKey:@"secondpay_start_time"]!=[NSNull null]?[NSNumber numberWithInt:[[attribute objectForKey:@"secondpay_start_time"] intValue]]:[NSNumber numberWithInt:0];//余款开始时间戳
            self.orderSecondpayEndTime = [attribute objectForKey:@"secondpay_end_time"]!=[NSNull null]?[NSNumber numberWithInt:[[attribute objectForKey:@"secondpay_end_time"] intValue]]:[NSNumber numberWithInt:0];//余款结束时间戳
            self.orderPayType = [attribute objectForKey:@"pay_type"]!=[NSNull null]?[[attribute objectForKey:@"pay_type"] intValue]:0;//支付方式  0 未支付 1 web端支付 2 app端支付
            
            self.orderFirstpayEndTime = [NSNumber numberWithInt:[[[attribute objectForKey:@"lastminute"] objectForKey:@"firstpay_end_time"] intValue]];//订单第一次购买结束时间戳
            
            if ([attribute objectForKey:@"balanceorder"]) {//余款订单
                LastMinuteUserOrder *orderInfo = [[LastMinuteUserOrder alloc] initWithAttribute:[attribute objectForKey:@"balanceorder"]];
                self.orderBalanceOrder = orderInfo;
                [orderInfo release];
                
            }
        
            
        }
    }
    
    return self;
}

- (void)dealloc
{
    
    QY_SAFE_RELEASE(_orderId);//订单号
    QY_SAFE_RELEASE(_orderPid);
    QY_SAFE_RELEASE(_orderNum);//购买数量
    QY_SAFE_RELEASE(_orderName);
    QY_SAFE_RELEASE(_orderPhone);
    QY_SAFE_RELEASE(_orderEmail);
    QY_SAFE_RELEASE(_orderUid);
    QY_SAFE_RELEASE(_orderUnitPrice);//购买单价
    QY_SAFE_RELEASE(_orderPrice);//购买总价
    QY_SAFE_RELEASE(_orderDatetime);
    QY_SAFE_RELEASE(_orderStock);//库存数
    QY_SAFE_RELEASE(_orderFirstpay);
    QY_SAFE_RELEASE(_orderRelid);
    QY_SAFE_RELEASE(_orderBuyerEmail);
    QY_SAFE_RELEASE(_orderBuyerId);
    QY_SAFE_RELEASE(_orderNotifyId);
    QY_SAFE_RELEASE(_orderNotifyTime);
    QY_SAFE_RELEASE(_orderNotifyType);
    QY_SAFE_RELEASE(_orderPaymentType);
    QY_SAFE_RELEASE(_orderSellerEmail);
    QY_SAFE_RELEASE(_orderSellerId);
    QY_SAFE_RELEASE(_orderSign);
    QY_SAFE_RELEASE(_orderSignType);
    QY_SAFE_RELEASE(_orderTotalFee);
    QY_SAFE_RELEASE(_orderTradeNo);
    QY_SAFE_RELEASE(_orderTradeStatus);
    QY_SAFE_RELEASE(_orderTeturnType);
    QY_SAFE_RELEASE(_orderReturnTime);//支付成功时间戳
    QY_SAFE_RELEASE(_orderDeadlineTime);//截止时间
    QY_SAFE_RELEASE(_orderLastminuteId);//折扣id
    QY_SAFE_RELEASE(_orderLastminuteTitle);//折扣标题
    QY_SAFE_RELEASE(_orderLastminutePrice);//折扣价格
    QY_SAFE_RELEASE(_orderProductsTitle);//产品标题
    QY_SAFE_RELEASE(_orderAlipayAccount);//商家支付宝号
    QY_SAFE_RELEASE(_orderSupplierTitle);//商家名称
    QY_SAFE_RELEASE(_orderSupplierPhone);//商家电话
    QY_SAFE_RELEASE(_orderBalanceOrder);
    QY_SAFE_RELEASE(_orderSecondpayStartTime);
    QY_SAFE_RELEASE(_orderSecondpayEndTime);
    
    QY_SAFE_RELEASE(_orderFirstpayEndTime);//订单第一次购买结束时间戳
    QY_SAFE_RELEASE(_orderStartDate);//出发日期

    
    [super dealloc];
}

+ (NSArray *)parseFromeDictionary:(NSDictionary *)aDictionary{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    
//    NSDictionary *dictionary = (NSDictionary *)[[QYAPIClient sharedAPIClient] responseJSON:data];
    NSDictionary *dataDic = [aDictionary objectForKey:@"data"];
    
    if([dataDic objectForKey:@"res"])
    {
        dataDic = [dataDic objectForKey:@"res"];
    }
    
    if([dataDic isKindOfClass:[NSArray class]])
    {
        for(NSDictionary *attribute in (NSArray *)dataDic)
        {
            LastMinuteUserOrder *orderInfo = [[LastMinuteUserOrder alloc] initWithAttribute:attribute];
            [mutableArray addObject:orderInfo];
            [orderInfo release];
        }
    }
    else if([dataDic isKindOfClass:[NSDictionary class]])
    {
        LastMinuteUserOrder *orderInfo = [[LastMinuteUserOrder alloc] initWithAttribute:aDictionary];
        [mutableArray addObject:orderInfo];
        [orderInfo release];
        
    }
    
    return mutableArray;
}

+ (NSArray *)parseFromeDetailDictionary:(NSDictionary *)aDictionary{
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
//    NSDictionary *dictionary = (NSDictionary *)[[QYAPIClient sharedAPIClient] responseJSON:data];
    
    if([aDictionary objectForKey:@"data"])
    {
        aDictionary = [aDictionary objectForKey:@"data"];
    }
    
    if([aDictionary isKindOfClass:[NSArray class]])
    {
        for(NSDictionary *attribute in (NSArray *)aDictionary)
        {
            LastMinuteUserOrder *orderInfo = [[LastMinuteUserOrder alloc] initWithAttribute:attribute];
            [mutableArray addObject:orderInfo];
            [orderInfo release];
        }
    }
    else if([aDictionary isKindOfClass:[NSDictionary class]])
    {
        LastMinuteUserOrder *orderInfo = [[LastMinuteUserOrder alloc] initWithAttribute:aDictionary];
        [mutableArray addObject:orderInfo];
        [orderInfo release];
        
    }
    
    return mutableArray;

}


//获取折扣订单详情
+ (void)getLastMinuteOrderInfoDetailWithId:(NSUInteger)orderId
                                   success:(QYLastMinuteUserOrderSuccessBlock)successBlock
                                   failure:(QYLastMinuteUserOrderFailureBlock)failureBlock
{
    [[QYAPIClient sharedAPIClient] getLastMinuteOrderInfoDetailWithId:orderId
                                                              success:^(NSDictionary *dic) {
                                                                  if(successBlock)
                                                                  {
                                                                      successBlock([LastMinuteUserOrder parseFromeDetailDictionary:dic]);
                                                                  }
                                                              }
                                                              failure:^(NSError *error) {
                                                                  if(failureBlock)
                                                                  {
                                                                      failureBlock(error);
                                                                  }
                                                              }];



}

//获取用户订单列表
+ (void)getLastMinuteUserOrderListWithCount:(NSUInteger)aCount
                                       page:(NSUInteger)aPage
                                    success:(QYLastMinuteUserOrderListSuccessBlock)successBlock
                                    failure:(QYLastMinuteUserOrderFailureBlock)failureBlock
{

    [[QYAPIClient sharedAPIClient] getLastMinuteUserOrderListWithCount:aCount
                                                                  page:aPage
                                                               success:^(NSDictionary *dic) {
                                                                   if(successBlock)
                                                                   {
                                                                       
                                                                       NSInteger count = 0;
                                                                       
//                                                                       NSDictionary *dictionary = (NSDictionary *)[[QYAPIClient sharedAPIClient] responseJSON:data];
                                                                       NSDictionary *dataDic = [dic objectForKey:@"data"];
                                                                       if ([dataDic objectForKey:@"counts"]) {
                                                                           count = [[dataDic objectForKey:@"counts"] intValue];
                                                                       }
                                                                       successBlock([LastMinuteUserOrder parseFromeDictionary:dic], count);
                                                                   }
                                                                   
                                                               } failure:^(NSError *error) {
                                                                   if(failureBlock)
                                                                   {
                                                                       failureBlock(error);
                                                                   }
                                                                   
                                                               }];

}

//删除折扣订单详情
+ (void)deleteLastMinuteUserOrderWithId:(NSUInteger)orderId
                                success:(QYLastMinuteUserOrderDictionarySuccessBlock)successBlock
                                failure:(QYLastMinuteUserOrderFailureBlock)failureBlock;
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[NSString stringWithFormat:@"%d", orderId] forKey:@"id"];

    [[QYAPIClient sharedAPIClient] deleteLastMinuteUserOrderWithParams:params success:^(NSDictionary *dic) {
        if (successBlock) {
            successBlock(dic);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];


}

//生成尾款订单
+ (void)createLastMinuteBalanceOrderWithId:(NSUInteger)orderId
                                   success:(QYLastMinuteUserOrderDictionarySuccessBlock)successBlock
                                   failure:(QYLastMinuteUserOrderFailureBlock)failureBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[NSString stringWithFormat:@"%d", orderId] forKey:@"id"];
    
    [[QYAPIClient sharedAPIClient] createLastMinuteBalanceOrderWithParams:params
                                                                  success:^(NSDictionary *dic) {
        if (successBlock) {
            successBlock(dic);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];


}

//通知后台主动查询支付宝
+ (void)backendAlipayQueryWithId:(NSUInteger)orderId
                         success:(QYLastMinuteUserOrderDataSuccessBlock)successBlock
                         failure:(QYLastMinuteUserOrderFailureBlock)failureBlock
{
    
    [[QYAPIClient sharedAPIClient] backendAlipayQueryWithId:orderId
                                                    success:^(NSData *data) {
                                                        if (successBlock) {
                                                            successBlock(data);
                                                        }
                                                        
                                                    } failure:^(NSError *error) {
                                                        if (failureBlock) {
                                                            failureBlock(error);
                                                        }
                                                        
                                                    }];


}

//封装通知后台主动查询支付宝的逻辑，包括两次请求
+ (void)commonBackendAlipayQueryWithId:(NSUInteger)orderId
                               success:(QYLastMinuteUserOrderDataSuccessBlock)successBlock
                               failure:(QYLastMinuteUserOrderFailureBlock)failureBlock
{

    
    //主动请求支付宝
    [self backendAlipayQueryWithId:orderId
                           success:^(NSData *data) {
                               
                               [self doSomethingAfterSucc];
                               if (successBlock) {
                                   successBlock(data);
                               }
                               
                            } failure:^(NSError *error) {
                                //如果失败，则再次要求后台主动请求支付宝
                                [self backendAlipayQueryWithId:orderId
                                                       success:^(NSData *data) {

                                                           [self doSomethingAfterSucc];
                                                           if (successBlock) {
                                                               successBlock(data);
                                                           }
                                                           
                                                        } failure:^(NSError *error) {
                                                                                                                        
                                                            if (failureBlock) {
                                                                failureBlock(error);
                                                            }
                                                            
                                                            //1_5订单支付失败（内详）
                                                            [MobClick event:@"orderpayfailed" label:[error localizedDescription]];

                                                            
                  
                                                        }];
                                              
                                              
                            }];



}

+ (void)doSomethingAfterSucc
{

//    //友盟统计
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//    NSDictionary *orderDic = [settings objectForKey:Setting_Alipay_OrderDic];
//    NSString *orderId = [NSString stringWithFormat:@"%d", [[orderDic objectForKey:Setting_Alipay_OrderDic_Id] intValue]];
//    NSString *price = [orderDic objectForKey:Setting_Alipay_OrderDic_Price];
//    
//    //友盟统计
//    [MobClick event:@"ordersuccess" label:@"支付宝钱包"];
//    //友盟统计
//    [QYCommonUtil umengEvent:@"ordersuccesstwo" attributes:@{@"orderid" : orderId, @"price" : price} number:@(1)];
//    
//    //删除缓存的 order
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:Setting_Alipay_OrderDic];
//    [[NSUserDefaults standardUserDefaults] synchronize];


}

//产品类型  0为全款 1为预付款 2为尾款
+ (NSString*)typeNameWithProductType:(OrderProductType)aType
{
    NSString *typeName = @"全款";
    switch (aType) {
        case OrderProductTypeQuankuan:
            typeName=@"全款";
            break;
        case OrderProductTypeYufukuan:
            typeName=@"预付款";
            break;
        case OrderProductTypeWeikuan:
            typeName=@"尾款";
            break;
            
        default:
            break;
    }
    
    return typeName;
}

//产品类型  0为全款 1为预付款 2为尾款
+ (NSString*)toastWithProductType:(OrderProductType)aType userOrder:(LastMinuteUserOrder*)aUserOrder
{
    NSString *toast = @"恭喜你，订单已支付成功，稍后商家会直接联系你";
    
    switch (aType) {
        case OrderProductTypeQuankuan:
            //Nothing to do..
            break;
        case OrderProductTypeYufukuan:
        {
            NSTimeInterval nowInterval = [QYTime nowAdjustTimeInterval];
            NSInteger secondpayStartTime = [aUserOrder.orderSecondpayStartTime intValue];
            NSInteger seconds = secondpayStartTime-nowInterval;
            if (seconds>0) {
                NSString *timeStr = [QYCommonUtil getTimeStrngWithSeconds:seconds];//获得倒计时时间格式： 2天13小时19分54秒
                toast=[NSString stringWithFormat:@"恭喜你，订单已支付成功，%@后支付余款", timeStr];

            }else{
                toast=[NSString stringWithFormat:@"恭喜你，订单已支付成功，可以支付余款"];
            }
        }
            break;
        case OrderProductTypeWeikuan:
            //Nothing to do..
            break;
            
        default:
            break;
    }
    
    return toast;


}


////支付宝需要提供信息
//- (NSString*)alipayDescription
//{
//    NSTimeInterval nowInterval = [QYTime nowAdjustTimeInterval];//[[NSDate date] timeIntervalSince1970];
//    NSTimeInterval seconds = [self.orderDeadlineTime intValue]-nowInterval;//传给支付宝的时间
//    NSInteger minute = seconds/60;
//    NSInteger maxMinute = 15*24*60;
//    NSInteger alipayMinute = MAX(MIN(minute, maxMinute), 1);//限定时间在1m~15d（m:分钟 d:天）
//    NSLog(@"-------------minute:%d", minute);
//    
//    NSMutableString * discription = [NSMutableString string];
//    
//    [discription appendFormat:@"service=\"%@\"", @"mobile.securitypay.pay"];
//	[discription appendFormat:@"&partner=\"%@\"", PartnerID];
//    [discription appendFormat:@"&_input_charset=\"%@\"", @"utf-8"];
// 
//    [discription appendFormat:@"&out_trade_no=\"%@%d\"", kOrderIdPrefix, self.orderId ? [self.orderId intValue] : 0];
//    [discription appendFormat:@"&subject=\"%@\"", self.orderLastminuteTitle ? self.orderLastminuteTitle : @""];
//    [discription appendFormat:@"&payment_type=\"%@\"", @"1"];
//	[discription appendFormat:@"&seller_id=\"%@\"", self.orderAlipayAccount ? self.orderAlipayAccount : @""];
//	[discription appendFormat:@"&total_fee=\"%@\"", self.orderPrice ? self.orderPrice : @""];
//	[discription appendFormat:@"&body=\"%@\"", self.orderProductsTitle ? self.orderProductsTitle : @""];
//	
//	[discription appendFormat:@"&notify_url=\"%@\"", [kAlipayCallBackUrl URLEncodedString]];
//
//    //未付款交易的超时时间
//    [discription appendFormat:@"&it_b_pay=\"%@\"", [NSString stringWithFormat:@"%d", alipayMinute]];
//    
////    //下面的这些参数，如果没有必要（value为空），则无需添加
////	[discription appendFormat:@"&return_url=\"%@\"", self.returnUrl ? self.returnUrl : @"www.xxx.com"];
//	
////	[discription appendFormat:@"&show_url=\"%@\"", self.showUrl ? self.showUrl : @"www.xxx.com"];
//    
//    
////	for (NSString * key in [self.extraParams allKeys]) {
////		[discription appendFormat:@"&%@=\"%@\"", key, [self.extraParams objectForKey:key]];
////	}
//    
//	return discription;
//
//
//
//}

@end
