//
//  QYCommonToast.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-3-25.
//
//

//支付宝 scheme
#define kAlipayOrgAppScheme   @"alipays"
#define kAlipayAppScheme      @"QyerAlipayScheme"
//    #define kAlipayCallBackUrl    @"http://apitest.qyer.com:7777/m/appalipaynotify.php"//test
#define kAlipayCallBackUrl    @"http://api.qyer.com/m/appalipaynotify.php"//正式

#define kAlipayHtml5URI       @"http://m.qyer.com/lastminute/orderform.php?action=lastminuteorderformshow&source=app"

#define kOrderIdPrefix  @"QYER"//正式
//    #define kOrderIdPrefix  @"TYER"//测试


//预订说明
#define kDirection_Url                        @"http://static.qyer.com/m/lm_clause.html"//@"http://static.qyer.com/html/m/lm_clause.html"

//提前时间 5分钟
#define LocalNotification_Ahead_Minute        5*60//15*60
#define TOAST_DURATION_NEW                    1.2
#define TOAST_DURATION                        1.0


//image Name
#define Image_PayType_Web                             @"x_order_zhifubaoWeb_logo.png"
#define Image_PayType_App                             @"x_order_zhifubaoApp_logo.png"

//颜色
#define Image_MyOrder_Orange                          [[UIImage imageNamed:@"x_myOrder_orange.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20]
#define Image_MyOrder_Orange_Highlighted              [[UIImage imageNamed:@"x_myOrder_orange_highlighted.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20]
#define Image_MyOrder_Green                           [[UIImage imageNamed:@"x_myOrder_green.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:0]
#define Image_MyOrder_Green_Highlighted               [[UIImage imageNamed:@"x_myOrder_green_highlighted.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:0]

//新的橘红色
#define Color_Orange                                  [UIColor colorWithRed:250.0/255.0f green:79.0/255.0f blue:62.0/255.0f alpha:1.0f]//[UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f]



//toast 文案
#define Toast_Loading_Fail                            @"加载数据出错，请稍后重试！"
#define Toast_Post_Order_Fail                         @"提交订单失败，请稍后重试！"

#define Toast_Select_Product_First                    @"请先选择你希望购买的套餐！"
#define Toast_Select_Product_Num                      @"请选择你希望购买套餐的数量！"
#define Toast_Select_Start_Date                       @"请选择出发日期！"

#define Toast_Complete_PersonInfo                     @"请完整填写购买人信息！"
#define Toast_Complete_PersonInfo_Name                @"请填写您的真实姓名！"
#define Toast_Complete_PersonInfo_Phone               @"请填写您的手机号码！"
#define Toast_Complete_PersonInfo_Email               @"请填写您的电子邮箱！"
#define Toast_Complete_PersonInfo_Phone_Correct       @"手机号码格式不正确，目前只支持国内手机号预订"
#define Toast_Complete_PersonInfo_Email_Correct       @"邮箱格式不正确"

#define Toast_Direction_Confirm                       @"请确认穷游预订条款"//@"需要接受穷游预订条款才能支付"
#define Toast_PayFailed                               @"支付失败！"

#define Toast_Login_Succ                              @"登录成功！"


//Alipay
#define Toast_Alipay_Fail_8000                             @"订单正在支付过程中，请尽快完成付款"
#define Toast_Alipay_Fail_4000                             @"订单支付失败，请稍后再试"
#define Toast_Alipay_Fail_6001                             @"订单支付取消，请尽快完成付款"
#define Toast_Alipay_Fail_6002                             @"订单支付失败，请检查网络后再试"
#define Toast_Alipay_Fail_OutTime                          @"订单支付已过期，请重新下单"//需要测试实际出现的情况 暂时未用
#define Toast_Alipay_Fail_Default                          @"支付失败，如果你的支付宝账户显示已完成付款，请联系折扣客服"



//Local Notification
#define LocalNotification_Key_App_Reminder           @"LocalNotification_Key_App_Reminder"
#define LocalNotification_Key_Not_Start              @"LocalNotification_Key_Not_Start"
#define LocalNotification_Key_NotPayBalance          @"LocalNotification_Key_NotPayBalance"//我的订单 余款开始通知

//LocalNotification 文案
#define LocalNotification_Body_App_Format             @"点击查看%@最新折扣汇总"//点击查看N月N日最新折扣汇总     18：00
#define LocalNotification_Body_Not_Start              @"你关注的折扣还有5分钟就开卖了，点击立即查看"//@"%@即将开始预订！"//18：00     Test
#define LocalNotification_Body_NotPayBalance          @"你预订的折扣可以支付余款了，点击立即查看"//@"%@即将开始支付余款！"//18：00     Test

#define LocalNotification_Body_In_Minutes             @"还有不到5分钟就开始了哦~"//@"折扣即将开始！不能设置提醒！"
#define LocalNotification_Body_In_Minutes_Succ        @"操作成功，折扣开始前5分钟会提前通知你…"//@"折扣即将开始！不能设置提醒！"

//Notification
#define Notification_MyOrder_Refresh                  @"Notification_MyOrder_Refresh"


//判断WebViewController是否显示
#define Setting_Is_WebView_Show                       @"Setting_Is_WebView_Show"

#define Alert_Message_Delete_Order                    @"确定删除此订单？"
#define Alert_Message_Delete_Order_Format             @"确定%@此订单？"



typedef enum {
    SupplierTypeAuth = 0,//认证商家
    SupplierTypeNotAuth = 1//非认证商家
} SupplierType;

typedef enum {
    OrderProductTypeQuankuan = 0,//全款
    OrderProductTypeYufukuan = 1,//预付款
    OrderProductTypeWeikuan = 2//尾款
} OrderProductType;

typedef enum {
    OrderPaymentOutTime = -1,//超时
    OrderPaymentNotPay = 0,//未支付
    OrderPaymentPayed = 1//已支付
} OrderPayment;

typedef enum {
    OrderPayTypeNone = 0,//未支付
    OrderPayTypeWeb = 1,//Web端支付
    OrderPayTypeApp = 2//App端支付
    
} OrderPayType;

//订单类型
typedef enum {
    LastminuteOrderStyleEmpty,//0.空白状态
    LastminuteOrderStyleNotPay,//1.未支付 可支付
    LastminuteOrderStyleSellOut,//2.已售罄 订单一旦生成则没有“已售罄”状态
    LastminuteOrderStyleFinish,//3.已过期
    LastminuteOrderStyleBalanceFinish,//3.余款已过期
    LastminuteOrderStyleSucc,//4.支付成功
    LastminuteOrderStyleNotPayBalance,//5.不可支付余款
    LastminuteOrderStylePayBalance//6.可支付余款
}  LastminuteOrderStyle;


