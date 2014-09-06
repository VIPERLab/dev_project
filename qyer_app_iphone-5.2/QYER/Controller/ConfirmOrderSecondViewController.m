//
//  ConfirmOrderSecondViewController.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-14.
//
//

#import "ConfirmOrderSecondViewController.h"
#import "FunctionZhifuView.h"
#import "ConfirmOrderSuccViewController.h"

//#import "ConfirmOrderFirstViewController.h"

#import "AddRemindViewController.h"
#import "QYCommonUtil.h"
#import "QYTime.h"
#import "QYCommonToast.h"

#define k_Tips_NotPay_Format       @"订单已确认，请在%@内完成支付！"//@"订单已确认，请在19分54秒内完成支付！"     //1.立即支付 button  （1.未支付 可支付）
#define k_Tips_NotPay_Unlimit      @"订单已确认，请完成支付！"
#define k_Tips_SellOut             @"订单支付时间已过期！产品已售罄！"    //2.再有类似折扣提醒我 button （2.已售罄）
#define k_Tips_Finish              @"订单支付时间已过期！您可以重新购买！"     //3.重新购买 button  （3.已过期）

#define Title_Delete_Cancel        @"取消订单"
#define Title_Delete_Delete        @"删除订单"

#define Tag_Alert_AlipaySucc      10001
#define Tag_Alert_DeleteOrder     10002
#define Tag_Alett_Close           10003

@interface ConfirmOrderSecondViewController ()
<
UIAlertViewDelegate
>

@property (nonatomic, retain) UIButton                 *deleteButton;

//Tips
@property (nonatomic, retain) UILabel                  *tipsLabel;
@property (nonatomic, retain) UILabel                  *timeTipsLabel;

//订单号
@property (nonatomic, retain) UIImageView              *numberBgImageView;
@property (nonatomic, retain) UILabel                  *numberLabel;

@property (nonatomic, retain) UIButton                 *payButton;//立即支付 button  （1.未支付 可支付）
@property (nonatomic, retain) UIButton                 *remindButton;//再有类似折扣提醒我 button （2.已售罄）
@property (nonatomic, retain) UIButton                 *rebuyButton;//重新购买 button  （3.已过期）

@property (nonatomic, assign) LastminuteOrderStyle      lastminuteOrderStyle;
//1.未支付 可支付 2.已售罄  3.已过期

@property (nonatomic, retain) FunctionZhifuView        *functionZhifuView;

@property (nonatomic, assign) BOOL                      isRequestingAlipay;

@property (nonatomic, assign) BOOL                      isRecordMobClick;//记录友盟统计

@property (nonatomic, assign) __block int               timeout;
@property (nonatomic, assign) dispatch_queue_t          queue;
@property (nonatomic, assign) dispatch_source_t         timer;

@end

@implementation ConfirmOrderSecondViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //倒计时功能
    if (_queue) {
        dispatch_release(_queue);
        _queue = nil;
    }
    if (_timer) {
        dispatch_source_cancel(_timer);
        dispatch_release(_timer);
        _timer = nil;
    }
    
    QY_VIEW_RELEASE(_deleteButton);
    QY_SAFE_RELEASE(_userOrder);
    QY_VIEW_RELEASE(_tipsLabel);
    QY_VIEW_RELEASE(_timeTipsLabel);
    QY_VIEW_RELEASE(_numberBgImageView);
    QY_VIEW_RELEASE(_numberLabel);
//    QY_VIEW_RELEASE(_comfirmButton);
    
    QY_VIEW_RELEASE(_payButton);
    QY_VIEW_RELEASE(_remindButton);
    QY_VIEW_RELEASE(_rebuyButton);
    
    QY_SAFE_RELEASE(_homeFillOrderViewController);
    QY_VIEW_RELEASE(_functionZhifuView);
    [super dealloc];
}

//关闭按钮
- (void)clickCloseButton:(id)sender
{
    
    UIAlertView *closeAlert = [[UIAlertView alloc] initWithTitle:nil message:@"马上要预订成功了，确认要退出么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    closeAlert.tag = Tag_Alett_Close;
    [closeAlert show];
    [closeAlert release];

}

-(id)init
{
    self = [super init];
    if (self) {
        _isRequestingAlipay = NO;
        _isRecordMobClick = NO;//没有记录友盟统计
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(void)loadView
//{
//    [super loadView];
//    
//}

//config bottom view
- (void)drawBottomView
{
    
    //bottom bg
    UIImageView *bottomBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-64, 320, 64)];
    bottomBgImageView.image = [UIImage imageNamed:@"x_bg_detail_bottom.png"];
    bottomBgImageView.userInteractionEnabled = YES;
    [self.view addSubview:bottomBgImageView];
    
    //立即支付 button  （1.未支付 可支付）
    _payButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 12, 300, 43)];
    [_payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _payButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [_payButton setTitle:@"立即支付" forState:UIControlStateNormal];
//    [_payButton setImage:[UIImage imageNamed:@"order_lijizhifu_btn.png"] forState:UIControlStateNormal];
//    [_payButton setImage:[UIImage imageNamed:@"order_lijizhifu_btn_highlighted.png"] forState:UIControlStateHighlighted];
    [_payButton setBackgroundImage:Image_MyOrder_Orange forState:UIControlStateNormal];
    [_payButton setBackgroundImage:Image_MyOrder_Orange_Highlighted forState:UIControlStateHighlighted];
    [_payButton addTarget:self action:@selector(payButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBgImageView addSubview:_payButton];
    _payButton.hidden = YES;
    
    //再有类似折扣提醒我 button （2.已售罄）
    _remindButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 12, 300, 43)];
    [_remindButton setImage:[UIImage imageNamed:@"x_order_remind_btn.png"] forState:UIControlStateNormal];
    [_remindButton setImage:[UIImage imageNamed:@"x_order_remind_btn_highlighted.png"] forState:UIControlStateHighlighted];
    [_remindButton addTarget:self action:@selector(remindButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBgImageView addSubview:_remindButton];
    _remindButton.hidden = YES;
    
    //重新购买 button  （3.已过期）
    _rebuyButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 12, 300, 43)];
    [_rebuyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rebuyButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [_rebuyButton setTitle:@"重新购买" forState:UIControlStateNormal];
//    [_rebuyButton setImage:[UIImage imageNamed:@"order_rebuy_btn.png"] forState:UIControlStateNormal];
//    [_rebuyButton setImage:[UIImage imageNamed:@"order_rebuy_btn_highlighted.png"] forState:UIControlStateHighlighted];
    [_rebuyButton setBackgroundImage:Image_MyOrder_Orange forState:UIControlStateNormal];
    [_rebuyButton setBackgroundImage:Image_MyOrder_Orange_Highlighted forState:UIControlStateHighlighted];
    [_rebuyButton addTarget:self action:@selector(rebuyButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBgImageView addSubview:_rebuyButton];
    _rebuyButton.hidden = YES;
    
    [bottomBgImageView release];
    
    
}

//设置底部展示样式
//1.未支付 可支付(LastminuteOrderStyleNotPay) 2.已售罄(LastminuteOrderStyleSellOut)  3.已过期(LastminuteOrderStyleFinish)
- (void)showBottomViewWithLastminuteOrderStyle:(LastminuteOrderStyle)aLastminuteOrderStyle
{
    _lastminuteOrderStyle = aLastminuteOrderStyle;
    
    
    if (aLastminuteOrderStyle ==  LastminuteOrderStyleEmpty) {
        _tipsLabel.hidden = YES;
        _timeTipsLabel.hidden = YES;
        
        _payButton.hidden = YES;
        _remindButton.hidden = YES;
        _rebuyButton.hidden = YES;
        
    }else if (aLastminuteOrderStyle ==  LastminuteOrderStyleNotPay) {//1.立即支付 button  （1.未支付 可支付）
        
        //取消订单
        [_deleteButton setTitle:Title_Delete_Cancel forState:UIControlStateNormal];
        
        //Tips
        _tipsLabel.hidden = YES;
        _timeTipsLabel.hidden = NO;
        
        _payButton.hidden = NO;
        _remindButton.hidden = YES;
        _rebuyButton.hidden = YES;
        
    }else if (aLastminuteOrderStyle == LastminuteOrderStyleSellOut){//2.再有类似折扣提醒我 button （2.已售罄）
        
        //删除订单
        [_deleteButton setTitle:Title_Delete_Delete forState:UIControlStateNormal];
        
        //Tips
        _tipsLabel.text = k_Tips_SellOut;
        _tipsLabel.hidden = NO;
        _timeTipsLabel.hidden = YES;
        
        _payButton.hidden = YES;
        _remindButton.hidden = NO;
        _rebuyButton.hidden = YES;
        
    }else if (aLastminuteOrderStyle == LastminuteOrderStyleFinish){//3.重新购买 button  （3.已过期）
        
        //删除订单
        [_deleteButton setTitle:Title_Delete_Delete forState:UIControlStateNormal];
        
        //Tips
        _tipsLabel.text = k_Tips_Finish;
        _tipsLabel.hidden = NO;
        _timeTipsLabel.hidden = YES;
        
        _payButton.hidden = YES;
        _remindButton.hidden = YES;
        _rebuyButton.hidden = NO;
        
    }
    
}

//请求折扣详情数据
- (void)requestForLastMinuteOrderInfoDetail{
    
    [self.view makeToastActivity];
    [LastMinuteUserOrder getLastMinuteOrderInfoDetailWithId:_orderId
                                                    success:^(NSArray *data) {
                                            
                                                        [self.view hideToastActivity];
                                            
                                                        if([data isKindOfClass:[NSArray class]] && [data count] > 0)
                                                        {
                                                
                                                            self.userOrder = [data objectAtIndex:0];
                                                                  //刷新数据
                                                            [self reloadData];
                                                        }
                                            
                                                    } failure:^(NSError *error) {
                                            
                                                        [self.view hideToastActivity];
                                            
                                                    }];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0 / 255.0 green:240.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];
    
    //Navigation bar
    _titleLabel.text = @"待支付订单";
    _backButton.hidden = YES;
    _closeButton.hidden = NO;
    
    self.mainContentView.frame = CGRectMake(0, 0, 320, 615+18-2+26);
    self.mainScrollView.contentSize = self.mainContentView.frame.size;
    
    //Navigation 删除按钮
    _deleteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _deleteButton.frame = CGRectMake(320-80-2, self.mainContentView.frame.size.height-18-64-8, 80, 18);
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_deleteButton setTitleColor:[UIColor colorWithRed:13.0/255.0f green:113.0/255.0f blue:190.0/255.0f alpha:1.0f] forState:UIControlStateNormal];
    _deleteButton.backgroundColor = [UIColor clearColor];
    [_deleteButton setTitle:Title_Delete_Cancel forState:UIControlStateNormal];
    //    [_deleteButton setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    //    [_deleteButton setBackgroundImage:[UIImage imageNamed:@"btn_back_highlighted.png"] forState:UIControlStateHighlighted];
    [_deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainContentView addSubview:_deleteButton];
    
    CGFloat yPadding = 5;
    
    //购买人信息
    [self initBuyerInfoViewWithPadding:73-yPadding];
    
    //商家信息
    [self initBusinessInfoViewWithPadding:218-yPadding];
    
    //购买详情
    [self initDetailInfoViewWithPadding:345-yPadding];
    
    //Tips 背景
    UIImageView *tipsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, 34)];
    tipsImageView.backgroundColor = [UIColor colorWithRed:252.0/255.0f green:219.0/255.0f blue:131.0/255.0f alpha:1.0f];//Color_Orange;//[UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    [self.view addSubview:tipsImageView];
    
    //Tips label
    _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tipsImageView.frame.size.width-10, tipsImageView.frame.size.height)];
    _tipsLabel.text = @"订单已确认，请在19分54秒内完成支付";
    _tipsLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:108.0/255.0 blue:75.0/255.0 alpha:1.0];//[UIColor whiteColor];
    _tipsLabel.font = [UIFont systemFontOfSize:14];
    _tipsLabel.backgroundColor = [UIColor clearColor];
    _tipsLabel.hidden = YES;
    [tipsImageView addSubview:_tipsLabel];
    
    //时间 Tips label
    _timeTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tipsImageView.frame.size.width-10, tipsImageView.frame.size.height)];
    _timeTipsLabel.text = @"订单已确认，请在19分54秒内完成支付";
    _timeTipsLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:108.0/255.0 blue:75.0/255.0 alpha:1.0];//[UIColor whiteColor];
    _timeTipsLabel.font = [UIFont systemFontOfSize:14];
    _timeTipsLabel.backgroundColor = [UIColor clearColor];
    [tipsImageView addSubview:_timeTipsLabel];
    _timeTipsLabel.hidden = YES;
    
    [tipsImageView release];
    
    //订单号 背景
    _numberBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 44, 60, 19)];
    _numberBgImageView.backgroundColor = [UIColor clearColor];
    //    _numberBgImageView.image = [[UIImage imageNamed:@"order_succ_numberBg.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [self.mainContentView addSubview:_numberBgImageView];
    _numberBgImageView.hidden = YES;
    
    //订单号 label  订单号：201401010101
    _numberLabel = [[UILabel alloc] initWithFrame:_numberBgImageView.bounds];
    _numberLabel.text = @"订单号：";
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.textColor = [UIColor colorWithRed:149.0/255.0f green:149.0/255.0f blue:149.0/255.0f alpha:1.0];//[UIColor whiteColor];
    _numberLabel.backgroundColor = [UIColor clearColor];
    _numberLabel.font = [UIFont systemFontOfSize:12];
    [_numberBgImageView addSubview:_numberLabel];
    
    //支付弹窗
    _functionZhifuView = [[FunctionZhifuView alloc] init];
    _functionZhifuView.homeViewController = self;
    
    //config bottom view
    [self drawBottomView];
    [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleEmpty];
    //调整总额label
    [self adjustFrameOfZongeLabel];

    
    

    //notification
    //支付宝支付成功 notification
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipaySuccWithNotification:) name:Notifination_Alipay_Succ object:nil];
    //支付宝支付失败 notification
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipayFailWithNotification:) name:Notifination_Alipay_Fail object:nil];
    
    //App 从后台进入前端
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDate) name:@"Notification_AppWillEnterForeground" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //请求折扣详情数据
    [self requestForLastMinuteOrderInfoDetail];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notifination_Alipay_Succ object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notifination_Alipay_Fail object:nil];

    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - click 
- (void)deleteButtonClick:(id)sender
{
    UIButton *button = sender;
    NSString *type = [button.titleLabel.text isEqualToString:Title_Delete_Cancel]?@"取消":@"删除";
    
    NSString *message = [NSString stringWithFormat:Alert_Message_Delete_Order_Format, type];//确定删除/取消此订单？
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = Tag_Alert_DeleteOrder;
    [alertView show];
    [alertView release];
    
    
    
    

}

//删除订单
- (void)deleteUserOrder
{
    [self.view makeToastActivity];
    [LastMinuteUserOrder deleteLastMinuteUserOrderWithId:_orderId success:^(NSDictionary *dic) {
        
        [self.view hideToastActivity];
        //返回折扣详情界面
        [self rebuyButtonClickAction:nil];
        
    } failure:^(NSError *error) {
        [self.view hideToastActivity];
        
        [self.view hideToast];
        [self.view makeToast:[error localizedDescription] duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//@"删除订单失败，请稍后重试！"
        
    }];

}

//立即支付 button  （1.未支付 可支付）
- (void)payButtonClickAction:(id)sender
{

    _functionZhifuView.userOrder = self.userOrder;
    [_functionZhifuView show];

}

//再有类似折扣提醒我 button （2.已售罄）
- (void)remindButtonClickAction:(id)sender
{
//    [self clickCloseButton:nil];

    //显示 添加提醒 界面
    AddRemindViewController *addRemindVC = [[[AddRemindViewController alloc] init] autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:addRemindVC] autorelease];
    navigationController.navigationBarHidden = YES;
//    [self presentModalViewController:navigationController animated:YES];
    [self presentViewController:navigationController animated:YES completion:NULL];
    
    
    //显示“我的订单”界面
//    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Tab_Remind object:nil];


}

//重新购买 button  （3.已过期）
- (void)rebuyButtonClickAction:(id)sender
{
    
    //pop ConfirmOrderFirstViewController
//    [[(ConfirmOrderFirstViewController*)self.homeViewController navigationController] popViewControllerAnimated:YES];
    
    //
    [[self.homeFillOrderViewController navigationController] popToViewController:self.homeFillOrderViewController.homeDetailViewController animated:YES];
    //dimiss 当前的ViewController
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];

}


//设置定时器
- (void)setTimeScheduleWithTimeInterval:(NSInteger)aTimeInterval
{
    
    if (_queue) {
        dispatch_release(_queue);
    }
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
    
    _timeout= aTimeInterval;//aTimeInterval; //倒计时时间
    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(_timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_release(_timer);
            _timer = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                
                //重新请求折扣详情数据
//                [self refreshDate];
                [self requestForLastMinuteOrderInfoDetail];
                
            });
        }else{
            
            NSString *timeStr = [QYCommonUtil getTimeStrngWithSeconds:_timeout];//获得倒计时时间格式： 2天13小时19分54秒
            NSString *strTime = [NSString stringWithFormat:k_Tips_NotPay_Format, timeStr];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                _timeTipsLabel.text = strTime;//@"订单已确认，请在2天13小时19分54秒内完成支付！"
            });
            _timeout--;
            
        }  
    });  
    dispatch_resume(_timer);


}

//折扣图、title、价格区域点击button Second order
- (void)buyerInfoDetailButtonClickAction:(id)sender
{
    [self rebuyButtonClickAction:nil];
    
}

//刷新数据
- (void)reloadData
{
    
    //判断订单状态
    NSTimeInterval nowInterval = [QYTime nowAdjustTimeInterval];//[[NSDate date] timeIntervalSince1970];
    NSTimeInterval seconds = [self.userOrder.orderDeadlineTime intValue]-nowInterval-Time_One_Minute;
    
    if ([self.userOrder.orderDeadlineTime intValue]==0||seconds>0) {//如果截止时间为0或大于当前时间，则显示可支付
        //未过期，可支付
        if ([self.userOrder.orderDeadlineTime intValue]==0) {//时间不限，无需倒计时
            _tipsLabel.text = k_Tips_NotPay_Unlimit;//订单已确认，请完成支付！
            _timeTipsLabel.text = k_Tips_NotPay_Unlimit;//订单已确认，请完成支付！
            
        }else{//限制时间，需要倒计时
            
            [self setTimeScheduleWithTimeInterval:seconds];
        
        }
        
        
        [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleNotPay];//1.立即支付 button  （1.未支付 可支付）
    }else{//已过期
        
        if ([self.userOrder.orderStock intValue]==0) {//判断库存是否为0或为null   2.已售罄(LastminuteOrderStyleSellOut)
            [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleSellOut];//2.已售罄 订单一旦生成则没有“已售罄”状态
        }else{//3.已过期(LastminuteOrderStyleFinish)
            [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleFinish];//3.已过期
        
        }
    
    }
    
    
    //订单号 label
    _numberLabel.text = [NSString stringWithFormat:@"订单号：%d", [self.userOrder.orderId intValue]];
    [self adjustFrameOfNumberLabel];

    
    //购买人信息------------------------------------------------------------------------------------
    
    //购买人信息 折扣图片
    [self.buyerInfoImageView setImageWithURL:[NSURL URLWithString:self.orderInfo.orderInfoPicUrl] placeholderImage:[UIImage imageNamed:@"x_lastminute_default63x42.png"]];
    
    //购买人信息 折扣 title
    self.buyerInfoTitleLabel.text = self.orderInfo.orderInfoTitle;
    
    //1818 元/起
    [self fillLastminuteTotalPriceWithOrderInfo:self.orderInfo];
    
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    //购买人信息 闫明超
    self.buyerInfoNameLabel.text = self.userOrder.orderBuyerInfoName;//[settings objectForKey:Settings_Buyer_Curr_Name];//Settings_Buyer_Name
    //购买人信息 13249593400
    self.buyerInfoPhoneLabel.text = self.userOrder.orderBuyerInfoPhone;//[settings objectForKey:Settings_Buyer_Curr_Phone];//Settings_Buyer_Phone
    //购买人信息 jiujiu_sife@qq.com
    self.buyerInfoEmailLabel.text = self.userOrder.orderBuyerInfoEmail;//[settings objectForKey:Settings_Buyer_Curr_Email];//Settings_Buyer_Email
    
    //商家信息 ------------------------------------------------------------------------------------
    //商家信息 在路上
    self.busiInfoFromLabel.text = self.userOrder.orderSupplierTitle;
    //商家信息 客服电话
    self.busiInfoPhoneLabel.text = self.userOrder.orderSupplierPhone;
    //穷游认证商家 logo
    self.busiInfoAuthImageView.hidden = self.userOrder.orderSupplierType==SupplierTypeNotAuth?YES:NO;
    
    //调整商家信息与穷游认证Logo 的Frame
    [self adjustFrameOfbusiInfoFromLabel];

    //购买详情 ------------------------------------------------------------------------------------
    //购买详情 付款类型
//    switch (self.userOrder.orderProductsType) {
//        case OrderProductTypeQuankuan:
//            self.detailInfoFukuanLabel.text = @"全款";
//            break;
//        case OrderProductTypeYufukuan:
//            self.detailInfoFukuanLabel.text = @"预付款";
//            break;
//        case OrderProductTypeWeikuan:
//            self.detailInfoFukuanLabel.text = @"尾款";
//            break;
//        default:
//            break;
//    }
    
    self.detailInfoFukuanLabel.text = [LastMinuteUserOrder typeNameWithProductType:self.userOrder.orderProductsType];
    
    //购买详情 产品类型 套餐2
    self.detailInfoChanpinLabel.text = self.userOrder.orderProductsTitle;
    //购买详情 出发日期
    self.detailInfoStartDateLabel.text = self.userOrder.orderStartDate;
    //购买详情 单价 1818元
    self.detailInfoDanjiaLabel.text = [NSString stringWithFormat:@"%@元", self.userOrder.orderUnitPrice];
    //购买详情 预订数量  2
    self.detailInfoYudingLabel.text = [NSString stringWithFormat:@"%d", [self.userOrder.orderNum intValue]];
    //购买详情 总额  3616元
    self.detailInfoZongeLabel.text = self.userOrder.orderPrice;
    [self adjustFrameOfZongeLabel];
    
    //如果已支付
    BOOL isWebViewShow = [[NSUserDefaults standardUserDefaults] boolForKey:Setting_Is_WebView_Show];
    NSLog(@"--------------isWebViewShow:%d", isWebViewShow);
    
    if (!isWebViewShow) {
        
        if (self.userOrder.orderPayment == OrderPaymentPayed&&_functionZhifuView.zhifuType==FunctionZhifuTypeWeb) {
            //显示订单成功界面
            //        [self showConfirmOrderSuccViewController];
            
            //显示支付成功的alert
            [self showSuccAlert];
            
        }
         _functionZhifuView.zhifuType = FunctionZhifuTypeNone;
    
    }
    
    //只记录一次友盟统计
    if (!_isRecordMobClick) {
        _isRecordMobClick = YES;
        
        //友盟统计
        NSString *orderId = [NSString stringWithFormat:@"%d", [self.userOrder.orderId intValue]];
        [QYCommonUtil umengEvent:@"orderconfirmed" attributes:@{@"orderid" : orderId, @"price" : self.userOrder.orderPrice} number:@(1)];
    }
    
    

}

//调整商家信息与穷游认证Logo 的Frame
- (void)adjustFrameOfbusiInfoFromLabel
{
    CGSize size = [self.busiInfoFromLabel.text sizeWithFont:self.busiInfoFromLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, self.busiInfoFromLabel.frame.size.height) lineBreakMode:self.busiInfoFromLabel.lineBreakMode];
    
    //折扣来自 在路上
    CGRect frame = self.busiInfoFromLabel.frame;
    frame.size.width = size.width;
    self.busiInfoFromLabel.frame = frame;
    
    CGFloat padding = 8.0f;
    
    //穷游认证商家
    frame = self.busiInfoAuthImageView.frame;
    frame.origin.x = self.busiInfoFromLabel.frame.origin.x + self.busiInfoFromLabel.frame.size.width + padding;
    self.busiInfoAuthImageView.frame = frame;

}

//调整订单号背景图的尺寸、位置
- (void)adjustFrameOfNumberLabel{
    
    CGSize size = [_numberLabel.text sizeWithFont:_numberLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _numberLabel.frame.size.height) lineBreakMode:_numberLabel.lineBreakMode];
    
    CGFloat padding = 0;//18;
    CGRect frame = _numberBgImageView.frame;
    frame.size.width = size.width + padding;
    _numberBgImageView.frame = frame;
    _numberLabel.frame =_numberBgImageView.bounds;
    _numberBgImageView.hidden = NO;
    
}

//调整总额尺寸、位置
- (void)adjustFrameOfZongeLabel{
    CGSize size = [self.detailInfoZongeLabel.text sizeWithFont:self.detailInfoZongeLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, self.detailInfoZongeLabel.frame.size.height) lineBreakMode:self.detailInfoZongeLabel.lineBreakMode];

    //3616
    CGFloat padding = 2;
    CGRect frame = self.detailInfoZongeLabel.frame;
    frame.size.width = size.width+padding;
    self.detailInfoZongeLabel.frame = frame;
    
    self.detailInfoZongeUnitLabel.hidden = [self.detailInfoZongeLabel.text length]>0?NO:YES;
    
    //元
    frame = self.detailInfoZongeUnitLabel.frame;
    frame.origin.x = self.detailInfoZongeLabel.frame.origin.x+self.detailInfoZongeLabel.frame.size.width;
    self.detailInfoZongeUnitLabel.frame = frame;
    

}


#pragma mark - notification
////支付宝支付成功 notification
//- (void)alipaySuccWithNotification:(NSNotification*)aNotification
//{
//    if (!_isRequestingAlipay) {
//        _isRequestingAlipay = YES;
//        
//        //如果支付宝支付成功,判断后台操作是否成功
//        [self.view makeToastActivity];
//        [LastMinuteUserOrder commonBackendAlipayQueryWithId:_orderId
//                                                    success:^(NSData *data) {
//                                                        [self.view hideToastActivity];
//                                                        _isRequestingAlipay = NO;
//                                                        
//                                                        //显示支付成功的alert
//                                                        [self showSuccAlert];
//                                                        
//                                                        
//                                                    } failure:^(NSError *error) {
//                                                        [self.view hideToastActivity];
//                                                        _isRequestingAlipay = NO;
//                                                        //删除缓存的 order
//                                                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:Setting_Alipay_OrderDic];
//                                                        [[NSUserDefaults standardUserDefaults] synchronize];
//                                                        
//                                                        //支付失败，如果你的支付宝账户显示已完成付款，请联系折扣客服
//                                                        [QYCommonUtil showAlertWithTitle:nil content:Toast_Alipay_Fail_Default];
//
//
//                                                    }];
//        
//    }
//
//}

//显示成功的Alert
- (void)showSuccAlert
{
    //恭喜你，订单已支付成功，稍后商家会联系你
    NSString *toast = [LastMinuteUserOrder toastWithProductType:self.userOrder.orderProductsType userOrder:self.userOrder];
    
    
    NSLog(@"----------second order succ:%@", toast);
    [QYCommonUtil showAlertWithTitle:nil content:toast delegate:self tag:Tag_Alert_AlipaySucc];

}


//显示支付失败toast
- (void)showToastWithPayFailed:(NSString*)aToast
{
    if (self.userOrder.orderPayment != OrderPaymentPayed) {//如果该页已经变成支付成功状态，则不提示toast
        [self.view hideToast];
        [self.view makeToast:aToast duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        
    }
    

}

//显示订单成功界面
- (void)showConfirmOrderSuccViewController//           *userOrder;
{
    //跳转到 确认订单成功界面
    ConfirmOrderSuccViewController *confirmOrderSuccViewController = [[ConfirmOrderSuccViewController alloc] init];
    confirmOrderSuccViewController.orderId = self.orderId;
    //    confirmOrderSuccViewController.userOrder = self.userOrder;
    confirmOrderSuccViewController.orderInfo = self.orderInfo;
    confirmOrderSuccViewController.homeViewController = self;
    [self presentViewController:confirmOrderSuccViewController animated:YES completion:^{
        [confirmOrderSuccViewController release];
        
    }];

}

////支付宝支付失败
//- (void)alipayFailWithNotification:(NSNotification*)aNotification
//{
//    //Nothing to do..
//    
////    [self.view hideToast];
////    [self.view makeToast:Toast_PayFailed duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
//    
//
//}

//刷新数据
- (void)refreshDate
{
    
//    if ([self.navigationController.topViewController isKindOfClass:[self class]]) {
//        [self requestForLastMinuteOrderInfoDetail];
//    }
    
    //该界面是present出来的，没有navigation
    [self requestForLastMinuteOrderInfoDetail];

}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case Tag_Alert_AlipaySucc:
        {
            //显示订单成功界面
            [self showConfirmOrderSuccViewController];
        
        }
            break;
        case Tag_Alert_DeleteOrder:
        {
            if (buttonIndex==0) {//取消
                
            }else if(buttonIndex==1){//删除
                //删除订单
                [self deleteUserOrder];

            }
            
        }
            break;
        case Tag_Alett_Close:
        {
            if (buttonIndex==0) {//取消
                
            }else if (buttonIndex==1){//确定
                //关闭 没有提示
//                [self closeWithoutAlert];
                
                [self rebuyButtonClickAction:nil];
            }
        }
            break;
            
        default:
            break;
    }

}

//关闭 没有提示
- (void)closeWithoutAlert
{
    [super clickCloseButton:nil];
    
    //显示“我的订单”界面
//    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Tab_Order object:nil];

}

@end
