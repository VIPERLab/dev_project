//
//  MyOrderQuankuanCell.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-19.
//
//

#import "MyOrderQuankuanCell.h"
#import "FunctionZhifuView.h"
#import "QYTime.h"
#import "QYCommonUtil.h"

#define k_Tips_Please              @"请在"
#define k_Tips_NotPay_Unlimit      @"订单已确认，请完成支付！"

#define Text_Finish                @"订单支付时间已过期！"
#define Text_Balance_Finish        @"余款支付已过期！"

//typedef enum {
//    QuankuanStyleNotPay,//未支付 可支付
//    QuankuanStyleSellOut,//已售罄 订单一旦生成则没有“已售罄”状态
//    QuankuanStyleFinish,//已过期
//    QuankuanStyleSucc,//支付成功
//    QuankuanStyleNotPayBalance,//不可支付余款
//    QuankuanStylePayBalance//可支付余款
//}  QuankuanStyle;

@interface MyOrderQuankuanCell()

@property (nonatomic, retain) UIImageView *bgImageView;

@property (nonatomic, retain) UILabel                   *titleLabel1;
@property (nonatomic, retain) UILabel                   *orderNumDetailLabel1;
@property (nonatomic, retain) UILabel                   *fukuanDetailLabel1;
@property (nonatomic, retain) UILabel                   *amountDetailLabel1;
@property (nonatomic, retain) UILabel                   *totalDetailLabel1;
@property (nonatomic, assign) LastminuteOrderStyle       lastminuteOrderStyle;
//1.未支付 可支付 2.已售罄 订单一旦生成则没有“已售罄”状态 3.已过期 4.支付成功 5.不可支付余款 6.可支付余款

@property (nonatomic, retain) UILabel                  *styleNotPayZaiTimeLabel;//请在
@property (nonatomic, retain) UIImageView              *styleNotPayContentView;//未支付
@property (nonatomic, retain) UIImageView              *styleSellOutContentView;//已售罄
@property (nonatomic, retain) UIImageView              *styleFinishContentView;//已过期
@property (nonatomic, retain) UIImageView              *styleSuccContentView;//支付成功
@property (nonatomic, retain) UIImageView              *styleNotPayBalanceContentView;//不可支付余款
@property (nonatomic, retain) UIImageView              *stylePayBalanceContentView;//可支付余款

@property (nonatomic, retain) UILabel                  *styleNotPayTimeLabel;//立即支付 在19分46秒内完成支付
@property (nonatomic, retain) UILabel                  *styleNotPayTimeTailLabel;//立即支付 内完成支付

@property (nonatomic, retain) UILabel                  *styleNotPayBalanceTimeLabel;//通知我 19分46秒后支付余款
@property (nonatomic, retain) UILabel                  *styleNotPayBalanceTimeTailLabel;//通知我 后支付余款

@property (nonatomic, retain) UIButton                 *styleFinishRebuyButton;
@property (nonatomic, retain) UILabel                  *styleFinishResultLabel;

@property (nonatomic, assign) __block int               timeout;
@property (nonatomic, assign) dispatch_queue_t          queue;
@property (nonatomic, assign) dispatch_source_t         timer;

@end

@implementation MyOrderQuankuanCell

-(void)dealloc
{
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
    
    QY_SAFE_RELEASE(_homeViewController);
    QY_SAFE_RELEASE(_userOrder);
    
    QY_VIEW_RELEASE(_bgImageView);
    
    QY_VIEW_RELEASE(_titleLabel1);
    QY_VIEW_RELEASE(_orderNumDetailLabel1);
    QY_VIEW_RELEASE(_fukuanDetailLabel1);
    QY_VIEW_RELEASE(_amountDetailLabel1);
    QY_VIEW_RELEASE(_totalDetailLabel1);
    
    QY_VIEW_RELEASE(_styleNotPayZaiTimeLabel);//请在
    QY_VIEW_RELEASE(_styleNotPayContentView);//未支付
    QY_VIEW_RELEASE(_styleSellOutContentView);//已售罄
    QY_VIEW_RELEASE(_styleFinishContentView);//已过期
    QY_VIEW_RELEASE(_styleSuccContentView);//支付成功
    QY_VIEW_RELEASE(_styleNotPayBalanceContentView);//不可支付余款
    QY_VIEW_RELEASE(_stylePayBalanceContentView);//可支付余款
    
    QY_VIEW_RELEASE(_styleNotPayTimeLabel);//立即支付 在19分46秒内完成支付
    QY_VIEW_RELEASE(_styleNotPayTimeTailLabel);//内完成支付
    QY_VIEW_RELEASE(_styleNotPayBalanceTimeLabel);//通知我 19分46秒后支付余款
    QY_VIEW_RELEASE(_styleNotPayBalanceTimeTailLabel);//通知我 后支付余款
    
    QY_VIEW_RELEASE(_styleFinishRebuyButton);
    QY_VIEW_RELEASE(_styleFinishResultLabel);
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];

        //背景图
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 225)];
        _bgImageView.image = [[UIImage imageNamed:@"y_cell_only.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:14];
        _bgImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_bgImageView];
        
        //title 点击button
        UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 63)];
        [titleButton setBackgroundImage:[[UIImage imageNamed:@"y_cell_top_highlighted_new.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:15] forState:UIControlStateHighlighted];
        [titleButton addTarget:self action:@selector(titleButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bgImageView addSubview:titleButton];
        [titleButton release];
        
        //卡塔尔航空北京/上海/广州/杭州/成都/重庆出发新年促销
        _titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 280, 40)];
        _titleLabel1.text = @"卡塔尔航空北京/上海/广州/杭州/成都/重庆出发新年促销";
        _titleLabel1.numberOfLines = 0;
        _titleLabel1.textColor = [UIColor colorWithRed:13.0/255.0f green:113.0/255.0f blue:190.0/255.0f alpha:1.0f];
        _titleLabel1.font = [UIFont systemFontOfSize:15];
        _titleLabel1.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:_titleLabel1];
        
        //分割线 title
        UIImageView *titleLineImgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 63, 300, 1)];
        titleLineImgView1.image = [UIImage imageNamed:@"y_myOrder_thinLine.png"];
        [_bgImageView addSubview:titleLineImgView1];
        [titleLineImgView1 release];
        
        //订单号：
        UILabel *orderNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 76, 100, 14)];
        orderNumLabel.text = @"订单号：";
        orderNumLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        orderNumLabel.font = [UIFont systemFontOfSize:12.0f];
        orderNumLabel.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:orderNumLabel];
        [orderNumLabel release];
        
        //订单号： 20134980870
        _orderNumDetailLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(68, 76, 240, 14)];
        _orderNumDetailLabel1.text = @"20134980870";
        _orderNumDetailLabel1.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        _orderNumDetailLabel1.font = [UIFont systemFontOfSize:12.0f];
        _orderNumDetailLabel1.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:_orderNumDetailLabel1];
        
        //付款类型：
        UILabel *fukuanLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 100, 14)];
        fukuanLabel.text = @"付款类型：";
        fukuanLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        fukuanLabel.font = [UIFont systemFontOfSize:12.0f];
        fukuanLabel.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:fukuanLabel];
        [fukuanLabel release];
        
        //付款类型：预付款
        _fukuanDetailLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(79, 100, 240, 14)];
        _fukuanDetailLabel1.text = @"预付款";
        _fukuanDetailLabel1.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        _fukuanDetailLabel1.font = [UIFont systemFontOfSize:12.0f];
        _fukuanDetailLabel1.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:_fukuanDetailLabel1];
        
        //数量：
        UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 124, 100, 14)];
        amountLabel.text = @"数量：";
        amountLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        amountLabel.font = [UIFont systemFontOfSize:12.0f];
        amountLabel.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:amountLabel];
        [amountLabel release];
        
        //数量：2
        _amountDetailLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(55, 124, 240, 14)];
        _amountDetailLabel1.text = @"2";
        _amountDetailLabel1.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        _amountDetailLabel1.font = [UIFont systemFontOfSize:12.0f];
        _amountDetailLabel1.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:_amountDetailLabel1];
        
        //总额：
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 149, 100, 14)];
        totalLabel.text = @"总额：";
        totalLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        totalLabel.font = [UIFont systemFontOfSize:12.0f];
        totalLabel.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:totalLabel];
        [totalLabel release];
        
        //总额：1818元
        _totalDetailLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(55, 149, 240, 14)];
        _totalDetailLabel1.text = @"1818元";
        _totalDetailLabel1.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        _totalDetailLabel1.font = [UIFont systemFontOfSize:12.0f];
        _totalDetailLabel1.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:_totalDetailLabel1];
        
        //粗分割线
        UIImageView *wideLineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 172, 300, 4)];
        wideLineImgView.image = [UIImage imageNamed:@"y_myOrder_wideLine.png"];
        [_bgImageView addSubview:wideLineImgView];
        [wideLineImgView release];
        
        //config bottom view
        [self drawBottomView];
        [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleNotPayBalance];


    
    }
    return self;
}

- (void)drawBottomView
{
    //未支付   ------------------------------------------------------------------------------------------
    _styleNotPayContentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, MyOrderQuankuanCellHeight-49, 320, 49)];//未支付
    _styleNotPayContentView.userInteractionEnabled = YES;
    _styleNotPayContentView.backgroundColor = [UIColor clearColor];
    [_bgImageView addSubview:_styleNotPayContentView];
    _styleNotPayContentView.hidden = YES;
    
    CGFloat xPadding = 12;
    
    //未支付 请在19分46秒内完成支付
    _styleNotPayZaiTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 166, 49)];
    _styleNotPayZaiTimeLabel.text = k_Tips_Please;//请在
    _styleNotPayZaiTimeLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    _styleNotPayZaiTimeLabel.font = [UIFont systemFontOfSize:12];
    _styleNotPayZaiTimeLabel.backgroundColor = [UIColor clearColor];//[UIColor clearColor];
    [_styleNotPayContentView addSubview:_styleNotPayZaiTimeLabel];
    
    //未支付 19分46秒
    _styleNotPayTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(32+xPadding, 0, 154, 49)];
    _styleNotPayTimeLabel.text = @"19分46秒";
    _styleNotPayTimeLabel.textAlignment = NSTextAlignmentCenter;
    _styleNotPayTimeLabel.textColor = Color_Orange;//[UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    _styleNotPayTimeLabel.font = [UIFont systemFontOfSize:12];
    _styleNotPayTimeLabel.backgroundColor = [UIColor clearColor];
    [_styleNotPayContentView addSubview:_styleNotPayTimeLabel];
    
    //未支付 内完成支付！
    _styleNotPayTimeTailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+xPadding, 0, 90, 49)];
    _styleNotPayTimeTailLabel.text = @"内完成支付！";
    _styleNotPayTimeTailLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    _styleNotPayTimeTailLabel.font = [UIFont systemFontOfSize:12];
    _styleNotPayTimeTailLabel.backgroundColor = [UIColor clearColor];
    [_styleNotPayContentView addSubview:_styleNotPayTimeTailLabel];

    
    //未支付 立即支付按钮
    UIButton *styleNotPayZhifuButton = [[UIButton alloc] initWithFrame:CGRectMake(186+14, 6, 100, 33)];
    [styleNotPayZhifuButton setTitle:@"立即支付" forState:UIControlStateNormal];
    styleNotPayZhifuButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [styleNotPayZhifuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [styleNotPayZhifuButton addTarget:self action:@selector(styleNotPayZhifuButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [styleNotPayZhifuButton setBackgroundImage:Image_MyOrder_Orange forState:UIControlStateNormal];
    [styleNotPayZhifuButton setBackgroundImage:Image_MyOrder_Orange_Highlighted forState:UIControlStateHighlighted];
    [_styleNotPayContentView addSubview:styleNotPayZhifuButton];
    [styleNotPayZhifuButton release];

    
    //已售罄   ------------------------------------------------------------------------------------------
    _styleSellOutContentView = [[UIImageView alloc] initWithFrame:_styleNotPayContentView.frame];//已售罄
    _styleSellOutContentView.userInteractionEnabled = YES;
    _styleSellOutContentView.backgroundColor = [UIColor clearColor];
    [_bgImageView addSubview:_styleSellOutContentView];
    _styleSellOutContentView.hidden = YES;
    
    //已售罄  失败icon
    UIImageView *styleSellOutIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 11, 24, 24)];
    [styleSellOutIconImageView setImage:[UIImage imageNamed:@"y_order_fail_icon.png"]];
    [_styleSellOutContentView addSubview:styleSellOutIconImageView];
    [styleSellOutIconImageView release];
    
    //已售罄  预付款已支付成功
    UILabel *styleSellOutResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 11, 265, 24)];
    styleSellOutResultLabel.text = @"订单支付时间已过期！产品已售罄！";
    styleSellOutResultLabel.textColor = Color_Orange;//[UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    styleSellOutResultLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    styleSellOutResultLabel.backgroundColor = [UIColor clearColor];
    [_styleSellOutContentView addSubview:styleSellOutResultLabel];
    [styleSellOutResultLabel release];

    
    //已过期   ------------------------------------------------------------------------------------------
    _styleFinishContentView = [[UIImageView alloc] initWithFrame:_styleNotPayContentView.frame];//已过期
    _styleFinishContentView.userInteractionEnabled = YES;
    _styleFinishContentView.backgroundColor = [UIColor clearColor];
    [_bgImageView addSubview:_styleFinishContentView];
    _styleFinishContentView.hidden = YES;
    
    //已售罄  失败icon
    UIImageView *styleFinishIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 11, 24, 24)];
    [styleFinishIconImageView setImage:[UIImage imageNamed:@"y_order_fail_icon.png"]];
    [_styleFinishContentView addSubview:styleFinishIconImageView];
    [styleFinishIconImageView release];
    
    //已售罄  预付款已支付成功
    _styleFinishResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 11, 265, 24)];
    _styleFinishResultLabel.text = Text_Finish;
    _styleFinishResultLabel.textColor = Color_Orange;//[UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    _styleFinishResultLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    _styleFinishResultLabel.backgroundColor = [UIColor clearColor];
    [_styleFinishContentView addSubview:_styleFinishResultLabel];
    
    //已过期 重新购买按钮
    _styleFinishRebuyButton = [[UIButton alloc] initWithFrame:CGRectMake(186+14, 6, 100, 33)];
    [_styleFinishRebuyButton setTitle:@"重新购买" forState:UIControlStateNormal];
    _styleFinishRebuyButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_styleFinishRebuyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_styleFinishRebuyButton setBackgroundImage:Image_MyOrder_Orange forState:UIControlStateNormal];
    [_styleFinishRebuyButton setBackgroundImage:Image_MyOrder_Orange_Highlighted forState:UIControlStateHighlighted];
    [_styleFinishRebuyButton addTarget:self action:@selector(styleFinishRebuyButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_styleFinishContentView addSubview:_styleFinishRebuyButton];

    
    //支付成功  ------------------------------------------------------------------------------------------
    _styleSuccContentView = [[UIImageView alloc] initWithFrame:_styleNotPayContentView.frame];//支付成功
    _styleSuccContentView.userInteractionEnabled = YES;
    _styleSuccContentView.backgroundColor = [UIColor clearColor];
    [_bgImageView addSubview:_styleSuccContentView];
    _styleSuccContentView.hidden = YES;
    
    
    //支付成功  成功icon
    UIImageView *styleSuccIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 11, 24, 24)];
    [styleSuccIconImageView setImage:[UIImage imageNamed:@"y_order_succ_comfirmIcon.png"]];
    [_styleSuccContentView addSubview:styleSuccIconImageView];
    [styleSuccIconImageView release];
    
    //支付成功  全款已支付成功
    UILabel *styleSuccResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 11, 265, 24)];
    styleSuccResultLabel.text = @"全款已支付成功";
    styleSuccResultLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
    styleSuccResultLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    styleSuccResultLabel.backgroundColor = [UIColor clearColor];
    [_styleSuccContentView addSubview:styleSuccResultLabel];
    [styleSuccResultLabel release];

    
    //不可支付余款 -----------------------------------------------------------------------------------------
    _styleNotPayBalanceContentView = [[UIImageView alloc] initWithFrame:_styleNotPayContentView.frame];//不可支付余款
    _styleNotPayBalanceContentView.userInteractionEnabled = YES;
    _styleNotPayBalanceContentView.backgroundColor = [UIColor clearColor];
    [_bgImageView addSubview:_styleNotPayBalanceContentView];
    _styleNotPayBalanceContentView.hidden = YES;
    
    //不可支付余款 预付款已支付成功
    UILabel *styleNotPayBalanceTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 166, 14)];
    styleNotPayBalanceTipLabel.text = @"预付款已支付成功";
    styleNotPayBalanceTipLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    styleNotPayBalanceTipLabel.font = [UIFont systemFontOfSize:12];
    styleNotPayBalanceTipLabel.backgroundColor = [UIColor clearColor];
    [_styleNotPayBalanceContentView addSubview:styleNotPayBalanceTipLabel];
    [styleNotPayBalanceTipLabel release];
    
    //不可支付余款 1天23小时59秒
    _styleNotPayBalanceTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 166, 14)];
    _styleNotPayBalanceTimeLabel.text = @"1天23小时59秒";
    _styleNotPayBalanceTimeLabel.textColor = Color_Orange;//[UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    _styleNotPayBalanceTimeLabel.font = [UIFont systemFontOfSize:11];
    _styleNotPayBalanceTimeLabel.backgroundColor = [UIColor clearColor];
    [_styleNotPayBalanceContentView addSubview:_styleNotPayBalanceTimeLabel];
    
    //不可支付余款 1天23小时59秒后支付余款
    _styleNotPayBalanceTimeTailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 166, 14)];
    _styleNotPayBalanceTimeTailLabel.text = @"后支付余款！";
    _styleNotPayBalanceTimeTailLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    _styleNotPayBalanceTimeTailLabel.font = [UIFont systemFontOfSize:11];
    _styleNotPayBalanceTimeTailLabel.backgroundColor = [UIColor clearColor];
    [_styleNotPayBalanceContentView addSubview:_styleNotPayBalanceTimeTailLabel];
    
    //不可支付余款 通知我
    UIButton *styleNotPayBalanceNotifyButton = [[UIButton alloc] initWithFrame:CGRectMake(186+14, 6, 100, 33)];
    [styleNotPayBalanceNotifyButton setTitle:@"通知我" forState:UIControlStateNormal];
    styleNotPayBalanceNotifyButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [styleNotPayBalanceNotifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [styleNotPayBalanceNotifyButton setBackgroundImage:Image_MyOrder_Green forState:UIControlStateNormal];
    [styleNotPayBalanceNotifyButton setBackgroundImage:Image_MyOrder_Green_Highlighted forState:UIControlStateHighlighted];
    [styleNotPayBalanceNotifyButton addTarget:self action:@selector(styleNotPayBalanceNotifyButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_styleNotPayBalanceContentView addSubview:styleNotPayBalanceNotifyButton];
    [styleNotPayBalanceNotifyButton release];

    
    //可支付余款 ------------------------------------------------------------------------------------------
    _stylePayBalanceContentView = [[UIImageView alloc] initWithFrame:_styleNotPayContentView.frame];//可支付余款
    _stylePayBalanceContentView.userInteractionEnabled = YES;
    _stylePayBalanceContentView.backgroundColor = [UIColor clearColor];
    [_bgImageView addSubview:_stylePayBalanceContentView];
    _stylePayBalanceContentView.hidden = YES;
    
    //可支付余款 支付余款按钮
    UIButton *stylePayBalanceZhifuButton = [[UIButton alloc] initWithFrame:CGRectMake(186+14, 6, 100, 33)];
    [stylePayBalanceZhifuButton setTitle:@"支付余款" forState:UIControlStateNormal];
    stylePayBalanceZhifuButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [stylePayBalanceZhifuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [stylePayBalanceZhifuButton setBackgroundImage:Image_MyOrder_Orange forState:UIControlStateNormal];
    [stylePayBalanceZhifuButton setBackgroundImage:Image_MyOrder_Orange_Highlighted forState:UIControlStateHighlighted];
    [stylePayBalanceZhifuButton addTarget:self action:@selector(stylePayBalanceZhifuButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_stylePayBalanceContentView addSubview:stylePayBalanceZhifuButton];
    [stylePayBalanceZhifuButton release];
    
    


}

//设置底部展示样式
- (void)showBottomViewWithLastminuteOrderStyle:(LastminuteOrderStyle)aLastminuteOrderStyle
{
    _lastminuteOrderStyle = aLastminuteOrderStyle;
    
    if (aLastminuteOrderStyle ==  LastminuteOrderStyleNotPay) {//未支付
        
        _styleNotPayContentView.hidden = NO;
        _styleSellOutContentView.hidden = YES;
        _styleFinishContentView.hidden = YES;
        _styleSuccContentView.hidden = YES;
        _styleNotPayBalanceContentView.hidden = YES;
        _stylePayBalanceContentView.hidden = YES;
        
    }else if (aLastminuteOrderStyle == LastminuteOrderStyleSellOut){//已售罄
        
        _styleNotPayContentView.hidden = YES;
        _styleSellOutContentView.hidden = NO;
        _styleFinishContentView.hidden = YES;
        _styleSuccContentView.hidden = YES;
        _styleNotPayBalanceContentView.hidden = YES;
        _stylePayBalanceContentView.hidden = YES;
        
    }else if (aLastminuteOrderStyle == LastminuteOrderStyleFinish){//已过期
        
        NSTimeInterval nowInterval = [QYTime nowAdjustTimeInterval];
        NSInteger firstPayEndTime = [self.userOrder.orderFirstpayEndTime intValue];
        _styleFinishRebuyButton.hidden = nowInterval>=firstPayEndTime?YES:NO;
        
        _styleNotPayContentView.hidden = YES;
        _styleSellOutContentView.hidden = YES;
        _styleFinishContentView.hidden = NO;
        _styleSuccContentView.hidden = YES;
        _styleNotPayBalanceContentView.hidden = YES;
        _stylePayBalanceContentView.hidden = YES;
        //@"订单支付时间已过期！"
        _styleFinishResultLabel.text = Text_Finish;
        
    }else if (aLastminuteOrderStyle == LastminuteOrderStyleBalanceFinish){//已过期
        
        NSTimeInterval nowInterval = [QYTime nowAdjustTimeInterval];
        NSInteger firstPayEndTime = [self.userOrder.orderFirstpayEndTime intValue];
        _styleFinishRebuyButton.hidden = nowInterval>=firstPayEndTime?YES:NO;
        
        _styleNotPayContentView.hidden = YES;
        _styleSellOutContentView.hidden = YES;
        _styleFinishContentView.hidden = NO;
        _styleSuccContentView.hidden = YES;
        _styleNotPayBalanceContentView.hidden = YES;
        _stylePayBalanceContentView.hidden = YES;
        //@"余款支付时间已过期！"
        _styleFinishResultLabel.text = Text_Balance_Finish;
        
    }else if (aLastminuteOrderStyle == LastminuteOrderStyleSucc){//支付成功
        
        _styleNotPayContentView.hidden = YES;
        _styleSellOutContentView.hidden = YES;
        _styleFinishContentView.hidden = YES;
        _styleSuccContentView.hidden = NO;
        _styleNotPayBalanceContentView.hidden = YES;
        _stylePayBalanceContentView.hidden = YES;
        
    }else if (aLastminuteOrderStyle == LastminuteOrderStyleNotPayBalance){//不可支付余款
        
        _styleNotPayContentView.hidden = YES;
        _styleSellOutContentView.hidden = YES;
        _styleFinishContentView.hidden = YES;
        _styleSuccContentView.hidden = YES;
        _styleNotPayBalanceContentView.hidden = NO;
        _stylePayBalanceContentView.hidden = YES;
        
        
    }else if (aLastminuteOrderStyle == LastminuteOrderStylePayBalance){//可支付余款
        
        _styleNotPayContentView.hidden = YES;
        _styleSellOutContentView.hidden = YES;
        _styleFinishContentView.hidden = YES;
        _styleSuccContentView.hidden = YES;
        _styleNotPayBalanceContentView.hidden = YES;
        _stylePayBalanceContentView.hidden = NO;
        
    }



}

-(void)setUserOrder:(LastMinuteUserOrder *)userOrder
{
    if (_userOrder) {
        QY_SAFE_RELEASE(_userOrder);
    }
    
    _userOrder = [userOrder retain];
    
    //折扣标题
    _titleLabel1.text = userOrder.orderLastminuteTitle;
    //订单号： 20134980870
    _orderNumDetailLabel1.text = [NSString stringWithFormat:@"%d", [userOrder.orderId intValue]];
    //付款类型：预付款
    switch (userOrder.orderProductsType) {
        case OrderProductTypeQuankuan:
            _fukuanDetailLabel1.text = @"全款";
            break;
        case OrderProductTypeYufukuan:
            _fukuanDetailLabel1.text = @"预付款";
            break;
        case OrderProductTypeWeikuan:
            _fukuanDetailLabel1.text = @"尾款";
            break;
            
        default:
            break;
    }
    //数量：2
    _amountDetailLabel1.text = [NSString stringWithFormat:@"%d", [userOrder.orderNum intValue]];
    //总额：1818元
    _totalDetailLabel1.text = [NSString stringWithFormat:@"%@元", userOrder.orderPrice];
    

    
    //Bottom view ----------------------------------------------------------------------------------------
    
    //TODO
    
    //获得当前时间戳
    NSTimeInterval nowInterval = [QYTime nowAdjustTimeInterval];//[[NSDate date] timeIntervalSince1970];
    
    if (userOrder.orderPayment==OrderPaymentPayed) {//已支付 ok
        
        if (userOrder.orderProductsType == OrderProductTypeQuankuan) {//如果是全款，则显示支付成功
            [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleSucc];
            
        }else if(userOrder.orderProductsType == OrderProductTypeYufukuan){//如果是预付款，则显示判断是否到支付尾款的时间
            
            if (nowInterval<[userOrder.orderSecondpayStartTime intValue]) {//不可支付余款
                //UI
                [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleNotPayBalance];
                //UI TIPS
                NSTimeInterval seconds = [userOrder.orderSecondpayStartTime intValue] - nowInterval;
                [self setTimeScheduleWithTimeInterval:seconds orderStyle:LastminuteOrderStyleNotPayBalance];
                
                //设置提醒
                [self setReminder];//TODO
                
            }else if (nowInterval<[userOrder.orderSecondpayEndTime intValue]-Time_One_Minute){//可支付余款
                
                //UI
                [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStylePayBalance];
                
            
            }else{//超时
                [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleBalanceFinish];
            }
            
        }
        
    }else if (userOrder.orderPayment==OrderPaymentNotPay){//未支付
        
        
        NSTimeInterval seconds = [userOrder.orderDeadlineTime intValue] - nowInterval-Time_One_Minute;
        if ([userOrder.orderDeadlineTime intValue]==0||seconds>0) {//可支付
            
            //UI
            [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleNotPay];
            
            //UI TIPS
            //未过期，可支付
            if ([self.userOrder.orderDeadlineTime intValue]==0) {//时间不限，无需倒计时
                _styleNotPayZaiTimeLabel.text = k_Tips_NotPay_Unlimit;
                _styleNotPayTimeLabel.hidden = YES;
                _styleNotPayTimeTailLabel.hidden = YES;
                
            }else{//限制时间，需要倒计时
                _styleNotPayZaiTimeLabel.text = k_Tips_Please;
                _styleNotPayTimeLabel.hidden = NO;
                _styleNotPayTimeTailLabel.hidden = NO;
                
                [self setTimeScheduleWithTimeInterval:seconds orderStyle:LastminuteOrderStyleNotPay];
            }
            
            
//            //test
//            //UI
//            [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleNotPayBalance];
//            //UI TIPS
//            NSTimeInterval seconds = [userOrder.orderDeadlineTime intValue] - nowInterval;
//            [self setTimeScheduleWithTimeInterval:seconds orderStyle:LastminuteOrderStyleNotPayBalance];
            
            
        }else{//超时
            
            if ([userOrder.orderStock intValue]==0) {//如果库存为0，则显示已售罄
                [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleSellOut];
            }else{
                [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleFinish];
            }
            
        }
        
    
    }else if (userOrder.orderPayment==OrderPaymentOutTime){//超时 已过期 ok
        
        if ([userOrder.orderStock intValue]==0) {//如果库存为0，则显示已售罄
            [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleSellOut];
        }else{
            [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleFinish];
        }
    
    }
    

    
}

//设置定时器
- (void)setTimeScheduleWithTimeInterval:(NSInteger)aTimeInterval orderStyle:(LastminuteOrderStyle)orderStyle
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
                
                //刷新我的订单界面
                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_MyOrder_Refresh object:nil];
                
            });
        }else{
            
            NSString *timeStr = [QYCommonUtil getTimeStrngWithSeconds:_timeout];//获得倒计时时间格式： 2天13小时19分54秒
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                
                if (orderStyle == LastminuteOrderStyleNotPay) {//立即支付倒计时
                    
                    NSString *strTime = [NSString stringWithFormat:@"%@", timeStr];
                    _styleNotPayTimeLabel.text = strTime;//@"在2天13小时19分54秒内完成支付！"
                    
                    //调整倒计时label frame
                    [self adjustStyleNotPayTimeLabel];
                    
                    
                }else if(orderStyle == LastminuteOrderStyleNotPayBalance){
                    NSString *strTime = [NSString stringWithFormat:@"%@", timeStr];
                    _styleNotPayBalanceTimeLabel.text = strTime;
                    
                    //调整倒计时label frame
                    [self adjuststyleNotPayBalanceTimeLabel];
                    
                }
                    
                    
                
            });
            _timeout--;
            
        }
    });
    dispatch_resume(_timer);
    
    
}

//调整倒计时label frame
- (void)adjuststyleNotPayBalanceTimeLabel
{
    CGSize size = [_styleNotPayBalanceTimeLabel.text sizeWithFont:_styleNotPayBalanceTimeLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _styleNotPayBalanceTimeLabel.frame.size.height) lineBreakMode:_styleNotPayBalanceTimeLabel.lineBreakMode];
    
    //2天13小时19分54秒
    CGFloat padding = 0;
    CGRect frame = _styleNotPayBalanceTimeLabel.frame;
    frame.size.width = size.width + padding;
    _styleNotPayBalanceTimeLabel.frame = frame;
    
    //内完成支付！
    frame = _styleNotPayBalanceTimeTailLabel.frame;
    frame.origin.x = _styleNotPayBalanceTimeLabel.frame.origin.x + _styleNotPayBalanceTimeLabel.frame.size.width;
    frame.size.width = 186.0 - frame.origin.x;
    _styleNotPayBalanceTimeTailLabel.frame = frame;

}

//调整倒计时label frame
- (void)adjustStyleNotPayTimeLabel
{
    CGSize size = [_styleNotPayTimeLabel.text sizeWithFont:_styleNotPayTimeLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _styleNotPayTimeLabel.frame.size.height) lineBreakMode:_styleNotPayTimeLabel.lineBreakMode];

    //2天13小时19分54秒
    CGFloat padding = 3;
    CGRect frame = _styleNotPayTimeLabel.frame;
    frame.size.width = size.width + padding;
    _styleNotPayTimeLabel.frame = frame;
    
    //内完成支付！
    frame = _styleNotPayTimeTailLabel.frame;
    frame.origin.x = _styleNotPayTimeLabel.frame.origin.x + _styleNotPayTimeLabel.frame.size.width;
    frame.size.width = 186 + 14 - frame.origin.x;
    _styleNotPayTimeTailLabel.frame = frame;

}

#pragma mark - click
//立即支付按钮
- (void)styleNotPayZhifuButtonClickAction:(id)sender
{
    
    if ([_delegate respondsToSelector:@selector(MyOrderQuankuanCellStyleNotPayZhifuButtonClickAction:cell:)]) {
        [_delegate MyOrderQuankuanCellStyleNotPayZhifuButtonClickAction:sender cell:self];
    }
    
    FunctionZhifuView *functionZhifuView = [[[FunctionZhifuView alloc] init] autorelease];
    functionZhifuView.userOrder = self.userOrder;
    functionZhifuView.homeViewController = self.homeViewController;
    [functionZhifuView show];

}

//支付余款按钮
- (void)stylePayBalanceZhifuButtonClickAction:(id)sender
{
    [LastMinuteUserOrder createLastMinuteBalanceOrderWithId:[self.userOrder.orderId intValue]
                                                    success:^(NSDictionary *dic) {
                                                        
                                                        //刷新我的订单界面
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_MyOrder_Refresh object:nil];
        
    
                                                    }failure:^(NSError *error) {
        
                                                    }];

}

//全款订单 重新购买按钮
- (void)styleFinishRebuyButtonClickAction:(id)sender
{
    [_delegate MyOrderQuankuanCellStyleFinishRebuyButtonClickAction:sender cell:self];

}

//不可支付余款 通知我
- (void)styleNotPayBalanceNotifyButtonClickAction:(id)sender
{
    [_delegate MyOrderQuankuanCellStyleNotPayBalanceNotifyButtonClickAction:sender cell:self];

}

//title button 点击
- (void)titleButtonClickAction:(id)sender
{
    [_delegate MyOrderQuankuanCellTitleButtonClickAction:sender cell:self];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    
    [super willTransitionToState:state];
    
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask) {
        
        for (UIView *subview in self.subviews) {
            
            if(ios7)
            {
                if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl_Legacy"]) {
                    
                    subview.hidden = YES;
                    subview.alpha = 0.0;
                }
            }
            else
            {
                if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                    
                    subview.hidden = YES;
                    subview.alpha = 0.0;
                }
            }
        }
    }
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
    
    [super didTransitionToState:state];
    
    if (state == UITableViewCellStateShowingDeleteConfirmationMask || state == UITableViewCellStateDefaultMask) {
        for (UIView *subview in self.subviews) {
            
            if(ios7)
            {
                if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl_Legacy"]) {
                    
                    UIView *deleteButtonView = (UIView *)[subview.subviews objectAtIndex:0];
                    CGRect f = deleteButtonView.frame;
                    f.origin.x -= 14;
                    f.origin.y -= 6;
                    deleteButtonView.frame = f;
                    
                    subview.hidden = NO;
                    
                    [UIView beginAnimations:@"anim" context:nil];
                    subview.alpha = 1.0;
                    [UIView commitAnimations];
                }
            }
            else
            {
                if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                    
                    UIView *deleteButtonView = (UIView *)[subview.subviews objectAtIndex:0];
                    CGRect f = deleteButtonView.frame;
                    f.origin.x -= 14;
                    f.origin.y -= 6;
                    deleteButtonView.frame = f;
                    
                    subview.hidden = NO;
                    
                    [UIView beginAnimations:@"anim" context:nil];
                    subview.alpha = 1.0;
                    [UIView commitAnimations];
                }
            }
        }
    }
}

//默认设置提醒功能
- (void)setReminder
{
    int timeInterval = [self.userOrder.orderSecondpayStartTime intValue]-LocalNotification_Ahead_Minute;
    int nowInterval = [[NSDate date] timeIntervalSince1970];
    
    
    if (timeInterval-nowInterval<=0) {
        //Noting to do
        
    }else{
        
        [MyOrderQuankuanCell setReminderWithUserOrder:self.userOrder timeInterval:timeInterval];
        
        
    }

}

//设置闹钟提醒
+ (void)setReminderWithUserOrder:(LastMinuteUserOrder*)aUserOrder timeInterval:(NSTimeInterval)aTimeInterval
{
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:aTimeInterval];
    NSString *key = [NSString stringWithFormat:@"%@%d", LocalNotification_Key_NotPayBalance, [aUserOrder.orderId intValue]];
    NSString *body = [NSString stringWithFormat:LocalNotification_Body_NotPayBalance];//LocalNotification_Body_NotPayBalance_Format, aUserOrder.orderLastminuteTitle];
    
    //设置提醒
    [QYCommonUtil setLocalAppReminderWithDate:startDate body:body key:key repeatInterval:0];

}


@end
