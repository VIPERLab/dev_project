//
//  ConfirmOrderSuccViewController.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-14.
//
//

#import "ConfirmOrderSuccViewController.h"
#import "WebViewViewController.h"

#import "ConfirmOrderSecondViewController.h"
#import "QYCommonUtil.h"

#define Text_Succ_Format       @"%@已支付成功"//全款已支付成功

@interface ConfirmOrderSuccViewController ()

@property (nonatomic, retain) LastMinuteUserOrder           *userOrder;

@property (nonatomic, retain) UIImageView                   *numberBgImageView;
@property (nonatomic, retain) UILabel                       *numberLabel;
@property (nonatomic, retain) UILabel                       *succContentLabel;

@end

@implementation ConfirmOrderSuccViewController

-(void)dealloc
{
    QY_SAFE_RELEASE(_homeViewController);
    QY_SAFE_RELEASE(_userOrder);
    QY_SAFE_RELEASE(_orderInfo);
    QY_VIEW_RELEASE(_numberBgImageView);
    QY_VIEW_RELEASE(_numberLabel);
    QY_VIEW_RELEASE(_succContentLabel);
    [super dealloc];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0 / 255.0 green:240.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];
    
    _titleLabel.text = @"支付成功";
    _backButton.hidden = YES;
    _closeButton.hidden = NO;
    
    self.mainContentView.frame = CGRectMake(0, 0, 320, 505);
    self.mainScrollView.contentSize = self.mainContentView.frame.size;
    self.mainContentView.hidden = YES;
    
    CGFloat yPadding = 5;
    
    //订单详情
    [self initOrderDetailInfoViewWithPadding:80-yPadding];
    
    //成功icon
    UIImageView *succIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(99, 18, 24, 24)];
    [succIconImageView setImage:[UIImage imageNamed:@"y_order_succ_comfirmIcon.png"]];
    [self.mainContentView addSubview:succIconImageView];
    [succIconImageView release];
    
    //全款已支付成功
    _succContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(119, 18, 190, 24)];
    //    _succContentLabel.text = @"全款已支付成功";
    _succContentLabel.font = [UIFont boldSystemFontOfSize:15];
    _succContentLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
    _succContentLabel.backgroundColor = [UIColor clearColor];
    [self.mainContentView addSubview:_succContentLabel];
    
    //订单号 背景
    _numberBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 50, 159, 19)];
    _numberBgImageView.backgroundColor = [UIColor clearColor];
    //    _numberBgImageView.image = [[UIImage imageNamed:@"order_succ_numberBg.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [self.mainContentView addSubview:_numberBgImageView];
    _numberBgImageView.hidden = YES;
    
    //订单号 label @"订单号：201401010101"
    _numberLabel = [[UILabel alloc] initWithFrame:_numberBgImageView.bounds];
    _numberLabel.text = @"";
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.textColor = [UIColor colorWithRed:149.0/255.0f green:149.0/255.0f blue:149.0/255.0f alpha:1.0];///[UIColor whiteColor];
    _numberLabel.backgroundColor = [UIColor clearColor];
    _numberLabel.font = [UIFont systemFontOfSize:12];
    [_numberBgImageView addSubview:_numberLabel];
    
    //如何退款
    UIButton *refundButton = [[UIButton alloc] initWithFrame:CGRectMake(235, 375, 85, 27)];
    refundButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [refundButton setTitleColor:[UIColor colorWithRed:13.0/255.0f green:113.0/255.0f blue:190.0/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [refundButton setTitle:@"如何退款?" forState:UIControlStateNormal];
    [refundButton addTarget:self action:@selector(refundButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.mainContentView addSubview:refundButton];
    [refundButton release];
    
    //确定按钮
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(93, 410-yPadding, 134, 34)];
    //    [cancelBtn setImage:[UIImage imageNamed:@"order_succ_cancelBtn.png"] forState:UIControlStateNormal];
    //    [cancelBtn setImage:[UIImage imageNamed:@"order_succ_cancelBtn_highlighted.png"] forState:UIControlStateHighlighted];
    [confirmButton setImage:[UIImage imageNamed:@"x_btn_comfirm.png"] forState:UIControlStateNormal];
    [confirmButton setImage:[UIImage imageNamed:@"x_btn_comfirm_highlighted.png"] forState:UIControlStateHighlighted];
    [confirmButton addTarget:self action:@selector(confirmButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainContentView addSubview:confirmButton];
    [confirmButton release];

    
    
    
    
    
    
    
//    //刷新数据
//    [self reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //请求折扣详情数据
    
    if (self.userOrder) {
        [self reloadData];
    }else{
        [self requestForLastMinuteOrderInfoDetail];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - click
//关闭按钮
- (void)clickCloseButton:(id)sender
{

    //显示“折扣详情界面”界面
    [self backToLastMinuteDetailViewController];
    
//    [self clickCloseButton:sender completion:^{
//        //显示“我的订单”界面
//        [(ConfirmOrderSecondViewController*)_homeViewController closeWithoutAlert];//clickCloseButton:sender
//    }];
    
    
}

//确定按钮
- (void)confirmButtonClickAction:(id)sender
{
    [self clickCloseButton:sender];
}

//如何退款？
- (void)refundButtonClickAction:(id)sender
{
    WebViewViewController *webVC = [[[WebViewViewController alloc] init] autorelease];
    webVC.label_title.text = @"如何退款";
    webVC.startURL = @"http://www.baidu.com";
    [self presentViewController:webVC animated:YES completion:^{
        
    }];
    
    
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

//刷新数据
- (void)reloadData
{
    
    self.mainContentView.hidden = self.userOrder?NO:YES;
    
    //订单号 label
    _numberLabel.text = [NSString stringWithFormat:@"订单号：%d", [self.userOrder.orderId intValue]];
    [self adjustFrameOfNumberLabel];
    
    //订单详情 ---------------------------------------------------------------------------------------------
    //折扣图片
    [self.orderInfoImageView setImageWithURL:[NSURL URLWithString:self.orderInfo.orderInfoPicUrl] placeholderImage:[UIImage imageNamed:@"x_lastminute_default63x42.png"]];
    
    //购买人信息 折扣 title
    self.orderInfoTitleLabel.text = self.orderInfo.orderInfoTitle;
    
    //1818 元/起
    //填充订单成功折扣总价
    [self fillOrderLastminuteTotalPriceWithOrderInfo:self.orderInfo];
    
    //购买详情 付款类型
//    switch (self.userOrder.orderProductsType) {
//        case OrderProductTypeQuankuan:
//            self.orderInfoFukuanLabel.text = @"全款";
//            break;
//        case OrderProductTypeYufukuan:
//            self.orderInfoFukuanLabel.text = @"预付款";
//            break;
//        case OrderProductTypeWeikuan:
//            self.orderInfoFukuanLabel.text = @"尾款";
//            break;
//        default:
//            break;
//    }
    
    self.orderInfoFukuanLabel.text = [LastMinuteUserOrder typeNameWithProductType:self.userOrder.orderProductsType];
    _succContentLabel.text = [NSString stringWithFormat:Text_Succ_Format, [LastMinuteUserOrder typeNameWithProductType:self.userOrder.orderProductsType]];
    
    //购买详情 产品类型 套餐2
    self.orderInfoChanpinLabel.text = self.userOrder.orderProductsTitle;
    
    //购买详情 出发日期
    self.orderInfoStartDateLabel.text = self.userOrder.orderStartDate;
    
    //购买详情 单价 1818元
    self.orderInfoDanjiaLabel.text = [NSString stringWithFormat:@"%@元", self.userOrder.orderUnitPrice];
    
    //购买详情 预订数量  2
    self.orderInfoYudingLabel.text = [NSString stringWithFormat:@"%d", [self.userOrder.orderNum intValue]];

    //购买详情 总额  3616元
    self.orderInfoZongeLabel.text = [NSString stringWithFormat:@"%@元", self.userOrder.orderPrice];
    
    //商家信息 在路上
    self.orderInfoFromLabel.text = self.userOrder.orderSupplierTitle;
    
    //商家信息 客服电话
    self.orderInfoPhoneLabel.text = self.userOrder.orderSupplierPhone;
    
    //穷游认证商家 logo
    self.orderInfoAuthImageView.hidden = self.userOrder.orderSupplierType==SupplierTypeNotAuth?YES:NO;
    
    //调整商家信息与穷游认证Logo 的Frame
    [self adjustFrameOforderInfoFromLabel];

    //支付成功时间 2014年1月1日15时34分
    if ([self.userOrder.orderReturnTime intValue]>0) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setLocale:[NSLocale currentLocale]];
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormat setDateFormat:@"yyyy年M月d日HH时mm分"];
        self.orderInfoSuccTimeLabel.text = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.userOrder.orderReturnTime intValue]]];//@"2014年1月1日15时34分";
        [dateFormat release];
    }
    
    if (self.userOrder.orderPayType == OrderPayTypeWeb ) {

        //友盟统计
        [MobClick event:@"ordersuccess" label:@"支付宝网页端"];
        //友盟统计
        NSString *orderId = [NSString stringWithFormat:@"%d", [self.userOrder.orderId intValue]];
        [QYCommonUtil umengEvent:@"ordersuccesstwo" attributes:@{@"orderid" : orderId, @"price" : self.userOrder.orderPrice} number:@(1)];

        
        self.orderInfoZhifuImageView.image = [UIImage imageNamed:Image_PayType_Web];
        
    }else if (self.userOrder.orderPayType == OrderPayTypeApp){

        self.orderInfoZhifuImageView.image = [UIImage imageNamed:Image_PayType_App];
        
    }
    
    

}

//调整商家信息与穷游认证Logo 的Frame
- (void)adjustFrameOforderInfoFromLabel
{
    //调整“商家信息”frame
    CGSize size = [self.orderInfoFromLabel.text sizeWithFont:self.orderInfoFromLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, self.orderInfoFromLabel.frame.size.height) lineBreakMode:self.orderInfoFromLabel.lineBreakMode];
    
    CGRect frame = self.orderInfoFromLabel.frame;
    frame.size = size;
    self.orderInfoFromLabel.frame = frame;
    
    CGFloat padding = 8.0f;
    
    //调整穷游认证商家 logo frame
    frame = self.orderInfoAuthImageView.frame;
    frame.origin.x = self.orderInfoFromLabel.frame.origin.x + self.orderInfoFromLabel.frame.size.width + padding;
    self.orderInfoAuthImageView.frame = frame;


}

#pragma mark - button click
//折扣图、title、价格区域点击button
- (void)orderInfoDetailButtonClickAction:(id)sender
{
    //显示“折扣详情界面”界面
    [self backToLastMinuteDetailViewController];

}

//显示“折扣详情界面”界面
- (void)backToLastMinuteDetailViewController
{
    [self clickCloseButton:nil completion:^{
        //显示“折扣详情界面”界面
        [(ConfirmOrderSecondViewController*)_homeViewController rebuyButtonClickAction:nil];
    }];
}

@end
