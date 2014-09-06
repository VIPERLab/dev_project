//
//  MyOrderYukuanCell.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-19.
//
//

#import "MyOrderYukuanCell.h"
#import "FunctionZhifuView.h"
#import "QYTime.h"
#import "QYCommonUtil.h"

#define k_Tips_Please              @"请在"
#define k_Tips_NotPay_Unlimit      @"订单已确认，请完成支付！"

//typedef enum {
//    YukuanStyleNotPay,//未支付
//    YukuanStyleFinish,//已过期
//    YukuanStyleSucc,//支付成功
//}  YukuanStyle;

@interface MyOrderYukuanCell()

@property (nonatomic, retain) UIImageView *bgImageView;

@property (nonatomic, retain) UILabel               *titleLabel1;
@property (nonatomic, retain) UILabel               *orderNumDetailLabel1;
@property (nonatomic, retain) UILabel               *fukuanDetailLabel1;
@property (nonatomic, retain) UILabel               *amountDetailLabel1;
@property (nonatomic, retain) UILabel               *totalDetailLabel1;

@property (nonatomic, retain) UILabel               *titleLabel2;
@property (nonatomic, retain) UILabel               *orderNumDetailLabel2;
@property (nonatomic, retain) UILabel               *fukuanDetailLabel2;
@property (nonatomic, retain) UILabel               *amountDetailLabel2;
@property (nonatomic, retain) UILabel               *totalDetailLabel2;

@property (nonatomic, assign) LastminuteOrderStyle   lastminuteOrderStyle;
//1.未支付 2.已过期 3.支付成功

@property (nonatomic, retain) UILabel               *styleNotPayZaiTimeLabel;//请在
@property (nonatomic, retain) UIImageView           *styleNotPayContentView;//未支付
@property (nonatomic, retain) UIImageView           *styleFinishContentView;//已过期
@property (nonatomic, retain) UIImageView           *styleSuccContentView;//支付成功

@property (nonatomic, retain) UILabel               *styleNotPayTimeLabel;//立即支付 在19分46秒内完成支付
@property (nonatomic, retain) UILabel               *styleNotPayTimeTailLabel;//立即支付 内完成支付

@property (nonatomic, assign) __block int            timeout;
@property (nonatomic, assign) dispatch_queue_t       queue;
@property (nonatomic, assign) dispatch_source_t      timer;

@end

@implementation MyOrderYukuanCell

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
    
    QY_VIEW_RELEASE(_titleLabel2);
    QY_VIEW_RELEASE(_orderNumDetailLabel2);
    QY_VIEW_RELEASE(_fukuanDetailLabel2);
    QY_VIEW_RELEASE(_amountDetailLabel2);
    QY_VIEW_RELEASE(_totalDetailLabel2);
    
    QY_VIEW_RELEASE(_styleNotPayZaiTimeLabel);//请在
    QY_VIEW_RELEASE(_styleNotPayContentView);//未支付
    QY_VIEW_RELEASE(_styleFinishContentView);//已过期
    QY_VIEW_RELEASE(_styleSuccContentView);//支付成功
    
    QY_SAFE_RELEASE(_styleNotPayTimeLabel);//立即支付 在19分46秒内完成支付
    QY_SAFE_RELEASE(_styleNotPayTimeTailLabel);//立即支付 内完成支付
    
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];

        //背景图
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 435)];
        _bgImageView.image = [[UIImage imageNamed:@"y_cell_only.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:14];
        _bgImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_bgImageView];
        
        //title 点击button
        UIButton *titleButton1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 63)];
        [titleButton1 setBackgroundImage:[[UIImage imageNamed:@"y_cell_top_highlighted_new.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:15] forState:UIControlStateHighlighted];
        [titleButton1 addTarget:self action:@selector(titleButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bgImageView addSubview:titleButton1];
        [titleButton1 release];
        
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
        
        //成功icon
        UIImageView *succIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 172, 24, 24)];
        [succIconImageView setImage:[UIImage imageNamed:@"y_order_succ_comfirmIcon.png"]];
        [_bgImageView addSubview:succIconImageView];
        [succIconImageView release];
        
        //预付款已支付成功
        UILabel *resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 172, 265, 24)];
        resultLabel.text = @"预付款已支付成功";
        resultLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
        resultLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        resultLabel.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:resultLabel];
        [resultLabel release];

        
        //虚线
        UIImageView *dashLineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 210, 286, 1)];
        dashLineImgView.image = [UIImage imageNamed:@"y_myOrder_dashLine.png"];
        [_bgImageView addSubview:dashLineImgView];
        [dashLineImgView release];
        
        //title 点击button
        UIButton *titleButton2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 210, 320, 63)];
        [titleButton2 setBackgroundImage:[[UIImage imageNamed:@"y_cell_middle_highlighted.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:15] forState:UIControlStateHighlighted];
        [titleButton2 addTarget:self action:@selector(titleButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bgImageView addSubview:titleButton2];
        [titleButton2 release];
        
        //卡塔尔航空北京/上海/广州/杭州/成都/重庆出发新年促销
        _titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 224, 280, 40)];
        _titleLabel2.text = @"卡塔尔航空北京/上海/广州/杭州/成都/重庆出发新年促销";
        _titleLabel2.numberOfLines = 0;
        _titleLabel2.textColor = [UIColor colorWithRed:13.0/255.0f green:113.0/255.0f blue:190.0/255.0f alpha:1.0f];
        _titleLabel2.font = [UIFont systemFontOfSize:15];
        _titleLabel2.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:_titleLabel2];
        
        
        //分割线 title
        UIImageView *titleLineImgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 273, 300, 1)];
        titleLineImgView2.image = [UIImage imageNamed:@"y_myOrder_thinLine.png"];
        [_bgImageView addSubview:titleLineImgView2];
        [titleLineImgView2 release];
        
        //订单号：
        UILabel *orderNumLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 76+211, 100, 14)];
        orderNumLabel2.text = @"订单号：";
        orderNumLabel2.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        orderNumLabel2.font = [UIFont systemFontOfSize:12.0f];
        orderNumLabel2.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:orderNumLabel2];
        [orderNumLabel2 release];
        
        //订单号： 20134980870
        _orderNumDetailLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(68, 76+211, 240, 14)];
        _orderNumDetailLabel2.text = @"20134980870";
        _orderNumDetailLabel2.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        _orderNumDetailLabel2.font = [UIFont systemFontOfSize:12.0f];
        _orderNumDetailLabel2.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:_orderNumDetailLabel2];
        
        //付款类型：
        UILabel *fukuanLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 100+211, 100, 14)];
        fukuanLabel2.text = @"付款类型：";
        fukuanLabel2.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        fukuanLabel2.font = [UIFont systemFontOfSize:12.0f];
        fukuanLabel2.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:fukuanLabel2];
        [fukuanLabel2 release];
        
        //付款类型：预付款
        _fukuanDetailLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(79, 100+211, 240, 14)];
        _fukuanDetailLabel2.text = @"预付款";
        _fukuanDetailLabel2.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        _fukuanDetailLabel2.font = [UIFont systemFontOfSize:12.0f];
        _fukuanDetailLabel2.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:_fukuanDetailLabel2];
        
        //数量：
        UILabel *amountLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 124+211, 100, 14)];
        amountLabel2.text = @"数量：";
        amountLabel2.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        amountLabel2.font = [UIFont systemFontOfSize:12.0f];
        amountLabel2.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:amountLabel2];
        [amountLabel2 release];
        
        //数量：2
        _amountDetailLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(55, 124+211, 240, 14)];
        _amountDetailLabel2.text = @"2";
        _amountDetailLabel2.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        _amountDetailLabel2.font = [UIFont systemFontOfSize:12.0f];
        _amountDetailLabel2.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:_amountDetailLabel2];
        
        //总额：
        UILabel *totalLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 149+211, 100, 14)];
        totalLabel2.text = @"总额：";
        totalLabel2.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        totalLabel2.font = [UIFont systemFontOfSize:12.0f];
        totalLabel2.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:totalLabel2];
        [totalLabel2 release];
        
        //总额：1818元
        _totalDetailLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(55, 149+211, 240, 14)];
        _totalDetailLabel2.text = @"1818元";
        _totalDetailLabel2.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
        _totalDetailLabel2.font = [UIFont systemFontOfSize:12.0f];
        _totalDetailLabel2.backgroundColor = [UIColor clearColor];
        [_bgImageView addSubview:_totalDetailLabel2];
        
        
        //粗分割线
        UIImageView *wideLineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 382, 300, 4)];
        wideLineImgView.image = [UIImage imageNamed:@"y_myOrder_wideLine.png"];
        [_bgImageView addSubview:wideLineImgView];
        [wideLineImgView release];
        
        
//        //余款支付已过期 icon
//        UIImageView *failIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 397, 24, 24)];
//        [failIconImageView setImage:[UIImage imageNamed:@"order_fail_icon.png"]];
//        [_bgImageView addSubview:failIconImageView];
//        [failIconImageView release];
//        
//        //余款支付已过期 title
//        UILabel *resultLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(39, 397, 265, 24)];
//        resultLabel2.text = @"余款支付已过期";
//        resultLabel2.textColor = [UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
//        resultLabel2.font = [UIFont boldSystemFontOfSize:15.0f];
//        resultLabel2.backgroundColor = [UIColor clearColor];
//        [_bgImageView addSubview:resultLabel2];
//        [resultLabel2 release];
        
        
        //config bottom view
        [self drawBottomView];
        [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleSucc];
        
        
        
    }
    return self;
}

- (void)drawBottomView
{
    
    //未支付   ------------------------------------------------------------------------------------------
    _styleNotPayContentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, MyOrderYukuanCellHeight-49, 320, 49)];//未支付
    _styleNotPayContentView.userInteractionEnabled = YES;
    _styleNotPayContentView.backgroundColor = [UIColor clearColor];
    [_bgImageView addSubview:_styleNotPayContentView];
    _styleNotPayContentView.hidden = YES;
    
    CGFloat xPadding = 12;
    
    //未支付 请在19分46秒内完成支付
    _styleNotPayZaiTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 166, 49)];
    _styleNotPayZaiTimeLabel.text = k_Tips_Please;
    _styleNotPayZaiTimeLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    _styleNotPayZaiTimeLabel.font = [UIFont systemFontOfSize:12];
    _styleNotPayZaiTimeLabel.backgroundColor = [UIColor clearColor];
    [_styleNotPayContentView addSubview:_styleNotPayZaiTimeLabel];
    
    //未支付 在19分46秒内完成支付
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
    _styleNotPayTimeTailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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
    
    
    //已过期   ------------------------------------------------------------------------------------------
    _styleFinishContentView = [[UIImageView alloc] initWithFrame:_styleNotPayContentView.frame];//已过期
    _styleFinishContentView.userInteractionEnabled = YES;
    _styleFinishContentView.backgroundColor = [UIColor clearColor];
    [_bgImageView addSubview:_styleFinishContentView];
    _styleFinishContentView.hidden = YES;
    
    //已过期  成功icon
    UIImageView *styleFinishIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 11, 24, 24)];
    [styleFinishIconImageView setImage:[UIImage imageNamed:@"y_order_fail_icon.png"]];
    [_styleFinishContentView addSubview:styleFinishIconImageView];
    [styleFinishIconImageView release];
    
    //已过期  余款支付已过期
    UILabel *styleFinishResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 11, 265, 24)];
    styleFinishResultLabel.text = @"余款支付已过期";
    styleFinishResultLabel.textColor = Color_Orange;//[UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    styleFinishResultLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    styleFinishResultLabel.backgroundColor = [UIColor clearColor];
    [_styleFinishContentView addSubview:styleFinishResultLabel];
    [styleFinishResultLabel release];
    
    
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
    
    //支付成功  余款已支付成功
    UILabel *styleSuccResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 11, 265, 24)];
    styleSuccResultLabel.text = @"余款已支付成功";
    styleSuccResultLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
    styleSuccResultLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    styleSuccResultLabel.backgroundColor = [UIColor clearColor];
    [_styleSuccContentView addSubview:styleSuccResultLabel];
    [styleSuccResultLabel release];

}

//设置底部展示样式
- (void)showBottomViewWithLastminuteOrderStyle:(LastminuteOrderStyle)aLastminuteOrderStyle
{
    _lastminuteOrderStyle = aLastminuteOrderStyle;
    
    if (aLastminuteOrderStyle ==  LastminuteOrderStyleNotPay) {//未支付
        
        _styleNotPayContentView.hidden = NO;
        _styleFinishContentView.hidden = YES;
        _styleSuccContentView.hidden = YES;
        
    }else if (aLastminuteOrderStyle == LastminuteOrderStyleFinish){//已过期
        
        _styleNotPayContentView.hidden = YES;
        _styleFinishContentView.hidden = NO;
        _styleSuccContentView.hidden = YES;
        
    }else if (aLastminuteOrderStyle == LastminuteOrderStyleSucc){//支付成功
        
        _styleNotPayContentView.hidden = YES;
        _styleFinishContentView.hidden = YES;
        _styleSuccContentView.hidden = NO;
        
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
    
    
    
    //尾款----------------------------------------------------------------------------------
    
    LastMinuteUserOrder *balanceOrder = userOrder.orderBalanceOrder;
    
    //折扣标题
    _titleLabel2.text = balanceOrder.orderLastminuteTitle;
    //订单号： 20134980870
    _orderNumDetailLabel2.text = [NSString stringWithFormat:@"%d", [balanceOrder.orderId intValue]];
    //付款类型：预付款
    switch (balanceOrder.orderProductsType) {
        case OrderProductTypeQuankuan:
            _fukuanDetailLabel2.text = @"全款";
            break;
        case OrderProductTypeYufukuan:
            _fukuanDetailLabel2.text = @"预付款";
            break;
        case OrderProductTypeWeikuan:
            _fukuanDetailLabel2.text = @"尾款";
            break;
            
        default:
            break;
    }
    //数量：2
    _amountDetailLabel2.text = [NSString stringWithFormat:@"%d", [balanceOrder.orderNum intValue]];
    //总额：1818元
    _totalDetailLabel2.text = [NSString stringWithFormat:@"%@元", balanceOrder.orderPrice];
    
    
    //Bottom view ----------------------------------------------------------------------------------------
   
    //获得当前时间戳
    NSTimeInterval nowInterval = [QYTime nowAdjustTimeInterval];//[[NSDate date] timeIntervalSince1970];
    if (balanceOrder.orderPayment==OrderPaymentPayed) {//已支付 ok
        
        [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleSucc];
        
//        //TEST
//        //UI
//        [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleNotPay];
//        
//        //UI TIPS
//        //未过期，可支付
//        if ([balanceOrder.orderDeadlineTime intValue]==0) {//时间不限，无需倒计时
//            _styleNotPayTimeLabel.text = k_Tips_NotPay_Unlimit;
//            
//        }else{//限制时间，需要倒计时
//            
//            NSTimeInterval seconds = 145259*60;//[balanceOrder.orderDeadlineTime intValue] - nowInterval;
//            [self setTimeScheduleWithTimeInterval:seconds orderStyle:LastminuteOrderStyleNotPay];
//            
//            
//        }
        
    }else if (balanceOrder.orderPayment==OrderPaymentNotPay){//未支付
        
        NSTimeInterval seconds = [balanceOrder.orderDeadlineTime intValue] - nowInterval-Time_One_Minute;
        if ([balanceOrder.orderDeadlineTime intValue]==0||seconds>0) {
            
            //UI
            [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleNotPay];
            
            //UI TIPS
            //未过期，可支付
            if ([balanceOrder.orderDeadlineTime intValue]==0) {//时间不限，无需倒计时
                _styleNotPayZaiTimeLabel.text = k_Tips_NotPay_Unlimit;
                _styleNotPayTimeLabel.hidden = YES;
                _styleNotPayTimeTailLabel.hidden = YES;
                
            }else{//限制时间，需要倒计时
                _styleNotPayZaiTimeLabel.text = k_Tips_Please;
                _styleNotPayTimeLabel.hidden = NO;
                _styleNotPayTimeTailLabel.hidden = NO;
                
                [self setTimeScheduleWithTimeInterval:seconds orderStyle:LastminuteOrderStyleNotPay];
            
            
            }
            
        }else{//超时
            [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleFinish];
        }
        
        
        
    }else if (balanceOrder.orderPayment==OrderPaymentOutTime){//超时 已过期
        [self showBottomViewWithLastminuteOrderStyle:LastminuteOrderStyleFinish];
    
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
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,_queue);
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
                    
                }
                
            });
            _timeout--;
            
        }
    });
    dispatch_resume(_timer);
    
    
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

#pragma mark - click
- (void)styleNotPayZhifuButtonClickAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(MyOrderYukuanCellStyleNotPayZhifuButtonClickAction:cell:)]) {
        [_delegate MyOrderYukuanCellStyleNotPayZhifuButtonClickAction:sender cell:self];
    }
    
    FunctionZhifuView *functionZhifuView = [[[FunctionZhifuView alloc] init] autorelease];
    functionZhifuView.userOrder = self.userOrder.orderBalanceOrder;
    functionZhifuView.homeViewController = self.homeViewController;
    [functionZhifuView show];

}

//title button 点击
- (void)titleButtonClickAction:(id)sender
{
    [_delegate MyOrderYukuanCellTitleButtonClickAction:sender cell:self];
    
}

@end
