//
//  BaseOrderViewController.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-14.
//
//

#import "BaseOrderViewController.h"
#import "QYCommonToast.h"

@interface BaseOrderViewController ()


@end

@implementation BaseOrderViewController

- (void)dealloc
{
    QY_VIEW_RELEASE(_mainScrollView);
    QY_VIEW_RELEASE(_mainContentView);
    
    QY_VIEW_RELEASE(_buyerInfoContentView);
    QY_VIEW_RELEASE(_businessInfoContentView);
    QY_VIEW_RELEASE(_detailInfoContentView);
    QY_VIEW_RELEASE(_orderDetailInfoContentView);
    
    //购买人信息
    QY_VIEW_RELEASE(_buyerInfoImageView);
    QY_VIEW_RELEASE(_buyerInfoTitleLabel);
    QY_VIEW_RELEASE(_buyerInfoPrefixLabel);
    QY_VIEW_RELEASE(_buyerInfoPriceLabel);
    QY_VIEW_RELEASE(_buyerInfoPriceUnitLabel);
    QY_VIEW_RELEASE(_buyerInfoNameLabel);
    QY_VIEW_RELEASE(_buyerInfoPhoneLabel);
    QY_VIEW_RELEASE(_buyerInfoEmailLabel);
    QY_VIEW_RELEASE(_buyerInfoEditButton);
    
    //商家信息
    QY_VIEW_RELEASE(_busiInfoFromLabel);
    QY_VIEW_RELEASE(_busiInfoPhoneLabel);
    QY_VIEW_RELEASE(_busiInfoAuthImageView);
    
    //购买详情
    QY_VIEW_RELEASE(_detailInfoFukuanLabel);
    QY_VIEW_RELEASE(_detailInfoChanpinLabel);
    QY_VIEW_RELEASE(_detailInfoStartDateLabel);
    QY_VIEW_RELEASE(_detailInfoDanjiaLabel);
    QY_VIEW_RELEASE(_detailInfoYudingLabel);
    QY_VIEW_RELEASE(_detailInfoZongeLabel);
    QY_VIEW_RELEASE(_detailInfoZongeUnitLabel);
    
    //订单详情
    QY_VIEW_RELEASE(_orderInfoImageView);
    QY_VIEW_RELEASE(_orderInfoTitleLabel);
    QY_VIEW_RELEASE(_orderInfoPrefixLabel);
    QY_VIEW_RELEASE(_orderInfoPriceLabel);
    QY_VIEW_RELEASE(_orderInfoPriceUnitLabel);
    QY_VIEW_RELEASE(_orderInfoFukuanLabel);
    QY_VIEW_RELEASE(_orderInfoChanpinLabel);
    QY_VIEW_RELEASE(_orderInfoStartDateLabel);
    QY_VIEW_RELEASE(_orderInfoDanjiaLabel);
    QY_VIEW_RELEASE(_orderInfoYudingLabel);
    QY_VIEW_RELEASE(_orderInfoZongeLabel);
    QY_VIEW_RELEASE(_orderInfoFromLabel);
    QY_VIEW_RELEASE(_orderInfoPhoneLabel);
    QY_VIEW_RELEASE(_orderInfoAuthImageView);
    QY_VIEW_RELEASE(_orderInfoZhifuImageView);
    QY_VIEW_RELEASE(_orderInfoSuccTimeLabel);
    
    [super dealloc];
}

#pragma mark - super
- (id)init
{
    self = [super init];
    if(self != nil)
    {
        //_panEnable = YES;
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0 / 255.0 green:240.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];
    
    //mainScrollView
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-_headView.frame.size.height)];
    _mainScrollView.backgroundColor = [UIColor  clearColor];
    [self.view addSubview:_mainScrollView];
    
    //mainContentView
    _mainContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mainScrollView.frame.size.width, 505)];
    _mainContentView.backgroundColor = [UIColor clearColor];
    
    [_mainScrollView addSubview:_mainContentView];
    _mainScrollView.contentSize = _mainContentView.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//填充折扣总价
- (void)fillLastminuteTotalPriceWithOrderInfo:(LastMinuteOrderInfo*)anOrderInfo
{
    self.buyerInfoPrefixLabel.text = @"";
    self.buyerInfoPriceLabel.text = @"";
    self.buyerInfoPriceUnitLabel.text = @"";
    
    NSString *priceStr = anOrderInfo.orderInfoPrice;
    NSArray *array = [priceStr componentsSeparatedByString:@"<em>"];
    
    if ([array count] > 1) {
        
        self.buyerInfoPrefixLabel.text = (NSString *)[array objectAtIndex:0];
        
        CGFloat offsetX = 0;
        CGSize prefixSize = [self.buyerInfoPrefixLabel.text sizeWithFont:self.buyerInfoPrefixLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, self.buyerInfoPrefixLabel.frame.size.height) lineBreakMode:self.buyerInfoPrefixLabel.lineBreakMode];
        
        CGRect frame = self.buyerInfoPrefixLabel.frame;
        frame.size.width = prefixSize.width;
        self.buyerInfoPrefixLabel.frame = frame;
        offsetX += prefixSize.width + self.buyerInfoPrefixLabel.frame.origin.x;
        
        NSArray *anotherArray = [(NSString *)[array objectAtIndex:1] componentsSeparatedByString:@"</em>"];
        self.buyerInfoPriceLabel.text = [anotherArray objectAtIndex:0];
        
        CGSize priceSize = [self.buyerInfoPriceLabel.text sizeWithFont:self.buyerInfoPriceLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, self.buyerInfoPriceLabel.frame.size.height) lineBreakMode:self.buyerInfoPriceLabel.lineBreakMode];
        
        frame = self.buyerInfoPriceLabel.frame;
        frame.origin.x = offsetX;
        frame.size.width = priceSize.width;
        self.buyerInfoPriceLabel.frame = frame;
        offsetX += priceSize.width;
        
        if ([anotherArray count] > 1) {
            self.buyerInfoPriceUnitLabel.text = [anotherArray objectAtIndex:1];
            CGSize suffixSize = [self.buyerInfoPriceUnitLabel.text sizeWithFont:self.buyerInfoPriceUnitLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, self.buyerInfoPriceUnitLabel.frame.size.height) lineBreakMode:self.buyerInfoPriceUnitLabel.lineBreakMode];
            
            frame = self.buyerInfoPriceUnitLabel.frame;
            frame.origin.x = offsetX;
            frame.size.width = suffixSize.width;
            self.buyerInfoPriceUnitLabel.frame = frame;
        }
        
    }else{
        self.buyerInfoPriceLabel.text = priceStr;
        
    }
    
}

//填充订单成功折扣总价
- (void)fillOrderLastminuteTotalPriceWithOrderInfo:(LastMinuteOrderInfo*)anOrderInfo
{
    self.orderInfoPrefixLabel.text = @"";
    self.orderInfoPriceLabel.text = @"";
    self.orderInfoPriceUnitLabel.text = @"";
    
    NSString *priceStr = anOrderInfo.orderInfoPrice;
    NSArray *array = [priceStr componentsSeparatedByString:@"<em>"];
    
    if ([array count] > 1) {
        
        self.orderInfoPrefixLabel.text = (NSString *)[array objectAtIndex:0];
        
        CGFloat offsetX = 0;
        CGSize prefixSize = [self.orderInfoPrefixLabel.text sizeWithFont:self.orderInfoPrefixLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, self.orderInfoPrefixLabel.frame.size.height) lineBreakMode:self.orderInfoPrefixLabel.lineBreakMode];
        
        CGRect frame = self.orderInfoPrefixLabel.frame;
        frame.size.width = prefixSize.width;
        self.orderInfoPrefixLabel.frame = frame;
        offsetX += prefixSize.width + self.orderInfoPrefixLabel.frame.origin.x;
        
        NSArray *anotherArray = [(NSString *)[array objectAtIndex:1] componentsSeparatedByString:@"</em>"];
        self.orderInfoPriceLabel.text = [anotherArray objectAtIndex:0];
        
        CGSize priceSize = [self.orderInfoPriceLabel.text sizeWithFont:self.orderInfoPriceLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, self.orderInfoPriceLabel.frame.size.height) lineBreakMode:self.orderInfoPriceLabel.lineBreakMode];
        
        frame = self.orderInfoPriceLabel.frame;
        frame.origin.x = offsetX;
        frame.size.width = priceSize.width;
        self.orderInfoPriceLabel.frame = frame;
        offsetX += priceSize.width;
        
        if ([anotherArray count] > 1) {
            self.orderInfoPriceUnitLabel.text = [anotherArray objectAtIndex:1];
            CGSize suffixSize = [self.orderInfoPriceUnitLabel.text sizeWithFont:self.orderInfoPriceUnitLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, self.orderInfoPriceUnitLabel.frame.size.height) lineBreakMode:self.orderInfoPriceUnitLabel.lineBreakMode];
            
            frame = self.orderInfoPriceUnitLabel.frame;
            frame.origin.x = offsetX;
            frame.size.width = suffixSize.width;
            self.orderInfoPriceUnitLabel.frame = frame;
        }
        
    }else{
        self.orderInfoPriceLabel.text = priceStr;
        
    }

}


//购买人信息
- (void)initBuyerInfoViewWithPadding:(CGFloat)aPadding
{
    _buyerInfoContentView = [[UIView alloc] initWithFrame:CGRectMake(0, aPadding, 320, 140)];
//    _buyerInfoContentView.backgroundColor = [UIColor redColor];
    [_mainContentView addSubview:_buyerInfoContentView];
    
    //背景图
    UIImageView *buyerInfoBgImgView = [[UIImageView alloc] initWithFrame:_buyerInfoContentView.bounds];
    buyerInfoBgImgView.image = [UIImage imageNamed:@"x_order_buyerInfo_bg.png"];
    [_buyerInfoContentView addSubview:buyerInfoBgImgView];
    [buyerInfoBgImgView release];
    
    //折扣图、title、价格区域点击button
    UIButton *buyerInfoDetailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 62)];
    buyerInfoDetailButton.backgroundColor = [UIColor clearColor];
    [buyerInfoDetailButton setBackgroundImage:[UIImage imageNamed:@"x_order_succ_detailInfo_bg_highlighted.png"] forState:UIControlStateHighlighted];
    [buyerInfoDetailButton addTarget:self action:@selector(buyerInfoDetailButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_buyerInfoContentView addSubview:buyerInfoDetailButton];
    [buyerInfoDetailButton release];
    
//    //购买人 label
//    UILabel *goumairenLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 91, 200, 19)];
//    goumairenLabel.text = @"购买人";
//    goumairenLabel.backgroundColor = [UIColor clearColor];
//    goumairenLabel.textColor = [UIColor blackColor];
//    goumairenLabel.font = [UIFont systemFontOfSize:17];
//    [_buyerInfoContentView addSubview:goumairenLabel];
//    [goumairenLabel release];
    
    //折扣图片
    _buyerInfoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 63, 42)];
    [_buyerInfoImageView setImage:[UIImage imageNamed:@"x_lastminute_default63x42.png"]];
    _buyerInfoImageView.backgroundColor = [UIColor purpleColor];
    [_buyerInfoContentView addSubview:_buyerInfoImageView];
    
    
    //上海往返巴沙+香港5天4晚自...
    _buyerInfoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 2, 216, 36)];//CGRectMake(93, 10, 216, 18)
    _buyerInfoTitleLabel.text = @"";
    _buyerInfoTitleLabel.numberOfLines = 0;
    _buyerInfoTitleLabel.backgroundColor = [UIColor clearColor];
    _buyerInfoTitleLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _buyerInfoTitleLabel.font = [UIFont systemFontOfSize:14];
    [_buyerInfoContentView addSubview:_buyerInfoTitleLabel];
    
    
    //prefix
    _buyerInfoPrefixLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 40, 70, 14)];
    _buyerInfoPrefixLabel.text = @"";
    _buyerInfoPrefixLabel.backgroundColor = [UIColor clearColor];
    _buyerInfoPrefixLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    _buyerInfoPrefixLabel.font = [UIFont systemFontOfSize:12];
    [_buyerInfoContentView addSubview:_buyerInfoPrefixLabel];
    
    //1818
    _buyerInfoPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 34, 200, 23)];
    _buyerInfoPriceLabel.text = @"";
    _buyerInfoPriceLabel.backgroundColor = [UIColor clearColor];
    _buyerInfoPriceLabel.textColor = Color_Orange;//[UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    _buyerInfoPriceLabel.font = [UIFont boldSystemFontOfSize:21];
    [_buyerInfoContentView addSubview:_buyerInfoPriceLabel];
    
    //元/起
    _buyerInfoPriceUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(_buyerInfoPriceLabel.frame.origin.x+_buyerInfoPriceLabel.frame.size.width, 40, 70, 14)];
    _buyerInfoPriceUnitLabel.text = @"";
    _buyerInfoPriceUnitLabel.backgroundColor = [UIColor clearColor];
    _buyerInfoPriceUnitLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    _buyerInfoPriceUnitLabel.font = [UIFont systemFontOfSize:12];
    [_buyerInfoContentView addSubview:_buyerInfoPriceUnitLabel];
    
    //闫明超
    _buyerInfoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 74, 209, 19)];
    _buyerInfoNameLabel.text = @"";
    _buyerInfoNameLabel.backgroundColor = [UIColor clearColor];
    _buyerInfoNameLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _buyerInfoNameLabel.font = [UIFont systemFontOfSize:15];
    [_buyerInfoContentView addSubview:_buyerInfoNameLabel];
    
    //18734292300
    _buyerInfoPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 96, 209, 14)];
    _buyerInfoPhoneLabel.text = @"";
    _buyerInfoPhoneLabel.backgroundColor = [UIColor clearColor];
    _buyerInfoPhoneLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _buyerInfoPhoneLabel.font = [UIFont systemFontOfSize:12];
    [_buyerInfoContentView addSubview:_buyerInfoPhoneLabel];
    
    //kevinsumon@gmail.com
    _buyerInfoEmailLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 111, 209, 14)];
    _buyerInfoEmailLabel.text = @"";
    _buyerInfoEmailLabel.backgroundColor = [UIColor clearColor];
    _buyerInfoEmailLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _buyerInfoEmailLabel.font = [UIFont systemFontOfSize:12];
    [_buyerInfoContentView addSubview:_buyerInfoEmailLabel];
    
    
    //修改 button
    _buyerInfoEditButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 66, 52, 29)];
    _buyerInfoEditButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_buyerInfoEditButton setTitleColor:[UIColor colorWithRed:13.0/255.0f green:113.0/255.0f blue:190.0/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [_buyerInfoEditButton setTitle:@"修改" forState:UIControlStateNormal];
    [_buyerInfoContentView addSubview:_buyerInfoEditButton];
    _buyerInfoEditButton.hidden = YES;
    

}

//商家信息
- (void)initBusinessInfoViewWithPadding:(CGFloat)aPadding
{
    
    _businessInfoContentView = [[UIView alloc] initWithFrame:CGRectMake(0, aPadding, 320, 122)];
//    _businessInfoContentView.backgroundColor = [UIColor blueColor];
    [_mainContentView addSubview:_businessInfoContentView];
    
    //背景图
    UIImageView *businessInfoBgImgView = [[UIImageView alloc] initWithFrame:_businessInfoContentView.bounds];
    businessInfoBgImgView.image = [UIImage imageNamed:@"x_order_businessInfo_bg.png"];
    [_businessInfoContentView addSubview:businessInfoBgImgView];
    [businessInfoBgImgView release];
    
    //商家信息 label
    UILabel *shangjiaLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 14, 200, 19)];
    shangjiaLabel.text = @"商家信息";
    shangjiaLabel.backgroundColor = [UIColor clearColor];
    shangjiaLabel.textColor = [UIColor blackColor];
    shangjiaLabel.font = [UIFont systemFontOfSize:17];
    [_businessInfoContentView addSubview:shangjiaLabel];
    [shangjiaLabel release];
    
    
    //折扣来自
    UILabel *busiFromLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 62, 200, 16)];
    busiFromLabel.text = @"折扣来自:";
    busiFromLabel.backgroundColor = [UIColor clearColor];
    busiFromLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    busiFromLabel.font = [UIFont systemFontOfSize:14];
    [_businessInfoContentView addSubview:busiFromLabel];
    [busiFromLabel release];
    
    //在路上
    _busiInfoFromLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, 62, 50, 16)];
    _busiInfoFromLabel.text = @"";
    _busiInfoFromLabel.backgroundColor = [UIColor clearColor];
    _busiInfoFromLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _busiInfoFromLabel.font = [UIFont systemFontOfSize:14];
    [_businessInfoContentView addSubview:_busiInfoFromLabel];
    
    //穷游认证商家 logo
    _busiInfoAuthImageView = [[UIImageView alloc] initWithFrame:CGRectMake(146, 62, 60, 16)];
    _busiInfoAuthImageView.image = [UIImage imageNamed:@"x_busiInfo_auth_logo.png"];
    [_businessInfoContentView addSubview:_busiInfoAuthImageView];
    _busiInfoAuthImageView.hidden = YES;
    
    
    //客服电话
    UILabel *busiPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 86, 200, 16)];
    busiPhoneLabel.text = @"客服电话:";
    busiPhoneLabel.backgroundColor = [UIColor clearColor];
    busiPhoneLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    busiPhoneLabel.font = [UIFont systemFontOfSize:14];
    [_businessInfoContentView addSubview:busiPhoneLabel];
    [busiPhoneLabel release];
    
    //400-820-0088
    _busiInfoPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, 86, 214, 16)];
    _busiInfoPhoneLabel.text = @"";
    _busiInfoPhoneLabel.backgroundColor = [UIColor clearColor];
    _busiInfoPhoneLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _busiInfoPhoneLabel.font = [UIFont systemFontOfSize:14];
    [_businessInfoContentView addSubview:_busiInfoPhoneLabel];
    

    
    

}

//购买详情
- (void)initDetailInfoViewWithPadding:(CGFloat)aPadding
{
    _detailInfoContentView = [[UIView alloc] initWithFrame:CGRectMake(0, aPadding, 320, 198+26)];
    _detailInfoContentView.userInteractionEnabled = YES;
    _detailInfoContentView.backgroundColor = [UIColor clearColor];
//    _detailInfoContentView.backgroundColor = [UIColor yellowColor];
    [_mainContentView addSubview:_detailInfoContentView];
    
    //背景图
    UIImageView *detailInfoBgImgView = [[UIImageView alloc] initWithFrame:_detailInfoContentView.bounds];
    detailInfoBgImgView.image = [UIImage imageNamed:@"x_order_detailInfo_bg.png"];
    detailInfoBgImgView.userInteractionEnabled = YES;
    [_detailInfoContentView addSubview:detailInfoBgImgView];
    [detailInfoBgImgView release];
    
    //购买详情 label
    UILabel *goumaiLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 14, 200, 19)];
    goumaiLabel.text = @"购买详情";
    goumaiLabel.backgroundColor = [UIColor clearColor];
    goumaiLabel.textColor = [UIColor blackColor];
    goumaiLabel.font = [UIFont systemFontOfSize:17];
    [_detailInfoContentView addSubview:goumaiLabel];
    [goumaiLabel release];
    
    //付款类型 label
    UILabel *detailFukuanLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 62, 200, 16)];
    detailFukuanLabel.text = @"付款类型:";
    detailFukuanLabel.backgroundColor = [UIColor clearColor];
    detailFukuanLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    detailFukuanLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:detailFukuanLabel];
    [detailFukuanLabel release];
    
    //全款
    _detailInfoFukuanLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 62, 200, 16)];
    _detailInfoFukuanLabel.text = @"";
    _detailInfoFukuanLabel.backgroundColor = [UIColor clearColor];
    _detailInfoFukuanLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _detailInfoFukuanLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:_detailInfoFukuanLabel];
    
    //产品类型 label
    UILabel *detailChanpinLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 86, 200, 16)];
    detailChanpinLabel.text = @"产品类型:";
    detailChanpinLabel.backgroundColor = [UIColor clearColor];
    detailChanpinLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    detailChanpinLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:detailChanpinLabel];
    [detailChanpinLabel release];
    
    //套餐2
    _detailInfoChanpinLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 86, 200, 16)];
    _detailInfoChanpinLabel.text = @"";
    _detailInfoChanpinLabel.backgroundColor = [UIColor clearColor];
    _detailInfoChanpinLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _detailInfoChanpinLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:_detailInfoChanpinLabel];
    
    //出发日期
    UILabel *detailStartDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 102, 200, 33)];
    detailStartDateLabel.text = @"出发日期:";
    detailStartDateLabel.backgroundColor = [UIColor clearColor];
    detailStartDateLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    detailStartDateLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:detailStartDateLabel];
    [detailStartDateLabel release];
    
    //出发日期
    _detailInfoStartDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 102, 200, 33)];
    _detailInfoStartDateLabel.text = @"";
    _detailInfoStartDateLabel.backgroundColor = [UIColor clearColor];
    _detailInfoStartDateLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _detailInfoStartDateLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:_detailInfoStartDateLabel];
    
    
    
    
    CGFloat yPadding = 26;
    
    //单价
    UILabel *detailDanjiaLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 109+yPadding, 200, 16)];
    detailDanjiaLabel.text = @"单      价:";
    detailDanjiaLabel.backgroundColor = [UIColor clearColor];
    detailDanjiaLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    detailDanjiaLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:detailDanjiaLabel];
    [detailDanjiaLabel release];
    
    //1818元
    _detailInfoDanjiaLabel  = [[UILabel alloc] initWithFrame:CGRectMake(95, 109+yPadding, 200, 16)];
    _detailInfoDanjiaLabel.text = @"";
    _detailInfoDanjiaLabel.backgroundColor = [UIColor clearColor];
    _detailInfoDanjiaLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _detailInfoDanjiaLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:_detailInfoDanjiaLabel];
    
    //预订数量
    UILabel *detailYudingLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 134+yPadding, 200, 16)];
    detailYudingLabel.text = @"预订数量:";
    detailYudingLabel.backgroundColor = [UIColor clearColor];
    detailYudingLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    detailYudingLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:detailYudingLabel];
    [detailYudingLabel release];
    
    //2
    _detailInfoYudingLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 134+yPadding, 200, 16)];
    _detailInfoYudingLabel.text = @"";
    _detailInfoYudingLabel.backgroundColor = [UIColor clearColor];
    _detailInfoYudingLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _detailInfoYudingLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:_detailInfoYudingLabel];
    
    //总额
    UILabel *detailZongeLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 158+yPadding, 200, 16)];
    detailZongeLabel.text = @"总      额:";
    detailZongeLabel.backgroundColor = [UIColor clearColor];
    detailZongeLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    detailZongeLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:detailZongeLabel];
    [detailZongeLabel release];
    
    //3616
    _detailInfoZongeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 153+yPadding, 59, 23)];
    _detailInfoZongeLabel.text = @"";
    _detailInfoZongeLabel.backgroundColor = [UIColor clearColor];
    _detailInfoZongeLabel.textColor = Color_Orange;//[UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    _detailInfoZongeLabel.font = [UIFont boldSystemFontOfSize:21];
    [_detailInfoContentView addSubview:_detailInfoZongeLabel];
    
    //元
    _detailInfoZongeUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(_detailInfoZongeLabel.frame.origin.x+_detailInfoZongeLabel.frame.size.width, 158+yPadding, 200, 16)];
    _detailInfoZongeUnitLabel.text = @"元";
    _detailInfoZongeUnitLabel.backgroundColor = [UIColor clearColor];
    _detailInfoZongeUnitLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _detailInfoZongeUnitLabel.font = [UIFont systemFontOfSize:14];
    [_detailInfoContentView addSubview:_detailInfoZongeUnitLabel];
    _detailInfoZongeUnitLabel.hidden = YES;
    
    

}

//订单详情
- (void)initOrderDetailInfoViewWithPadding:(CGFloat)aPadding
{
    _orderDetailInfoContentView = [[UIView alloc] initWithFrame:CGRectMake(0, aPadding, 320, 297+26)];
//    _orderDetailInfoContentView.backgroundColor = [UIColor purpleColor];
    [_mainContentView addSubview:_orderDetailInfoContentView];
    
    //背景图
    UIImageView *orderDetailInfoBgImgView = [[UIImageView alloc] initWithFrame:_orderDetailInfoContentView.bounds];
    orderDetailInfoBgImgView.image = [UIImage imageNamed:@"x_order_succ_detailInfo_bg.png"];
    [_orderDetailInfoContentView addSubview:orderDetailInfoBgImgView];
    [orderDetailInfoBgImgView release];
    
    //折扣图、title、价格区域点击button
    UIButton *orderInfoDetailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 62)];
    orderInfoDetailButton.backgroundColor = [UIColor clearColor];
    [orderInfoDetailButton setBackgroundImage:[UIImage imageNamed:@"x_order_succ_detailInfo_bg_highlighted.png"] forState:UIControlStateHighlighted];
    [orderInfoDetailButton addTarget:self action:@selector(orderInfoDetailButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_orderDetailInfoContentView addSubview:orderInfoDetailButton];
    [orderInfoDetailButton release];
    
    //折扣图片
    _orderInfoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 63, 42)];
    [_orderInfoImageView setImage:[UIImage imageNamed:@"x_lastminute_default63x42.png"]];
    _orderInfoImageView.backgroundColor = [UIColor purpleColor];
    [_orderDetailInfoContentView addSubview:_orderInfoImageView];
    
    //上海往返沙巴+香港5天4晚自...
    _orderInfoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 2, 217, 36)];//CGRectMake(93, 10, 217, 18)
    _orderInfoTitleLabel.text = @"";
    _orderInfoTitleLabel.numberOfLines = 0;
    _orderInfoTitleLabel.backgroundColor = [UIColor clearColor];
    _orderInfoTitleLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _orderInfoTitleLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:_orderInfoTitleLabel];
    
    
    //prefix
    _orderInfoPrefixLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 40, 70, 14)];
    _orderInfoPrefixLabel.text = @"";
    _orderInfoPrefixLabel.backgroundColor = [UIColor clearColor];
    _orderInfoPrefixLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    _orderInfoPrefixLabel.font = [UIFont systemFontOfSize:12];
    [_orderDetailInfoContentView addSubview:_orderInfoPrefixLabel];
    
    //1818
    _orderInfoPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 34, 200, 23)];
    _orderInfoPriceLabel.text = @"";
    _orderInfoPriceLabel.backgroundColor = [UIColor clearColor];
    _orderInfoPriceLabel.textColor = Color_Orange;//[UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    _orderInfoPriceLabel.font = [UIFont boldSystemFontOfSize:21];
    [_orderDetailInfoContentView addSubview:_orderInfoPriceLabel];
    
    //元起
    _orderInfoPriceUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(_orderInfoPriceLabel.frame.origin.x+_orderInfoPriceLabel.frame.size.width, 40, 70, 14)];
    _orderInfoPriceUnitLabel.text = @"";
    _orderInfoPriceUnitLabel.backgroundColor = [UIColor clearColor];
    _orderInfoPriceUnitLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    _orderInfoPriceUnitLabel.font = [UIFont systemFontOfSize:12];
    [_orderDetailInfoContentView addSubview:_orderInfoPriceUnitLabel];
    
    //付款类型
    UILabel *orderFukuanLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 73, 200, 16)];
    orderFukuanLabel.text = @"付款类型:";
    orderFukuanLabel.backgroundColor = [UIColor clearColor];
    orderFukuanLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    orderFukuanLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:orderFukuanLabel];
    [orderFukuanLabel release];
    
    //付款类型 全款
    _orderInfoFukuanLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 73, 221, 16)];
    _orderInfoFukuanLabel.text = @"";
    _orderInfoFukuanLabel.backgroundColor = [UIColor clearColor];
    _orderInfoFukuanLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _orderInfoFukuanLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:_orderInfoFukuanLabel];
    
    //产品类型
    UILabel *orderChanpinLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 97, 200, 16)];
    orderChanpinLabel.text = @"产品类型:";
    orderChanpinLabel.backgroundColor = [UIColor clearColor];
    orderChanpinLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    orderChanpinLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:orderChanpinLabel];
    [orderChanpinLabel release];
    
    //产品类型 套餐2
    _orderInfoChanpinLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 97, 221, 16)];
    _orderInfoChanpinLabel.text = @"";
    _orderInfoChanpinLabel.backgroundColor = [UIColor clearColor];
    _orderInfoChanpinLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _orderInfoChanpinLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:_orderInfoChanpinLabel];
    
    CGFloat yPadding = 26.0f;
    
    //出发日期
    UILabel *orderStartDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 113, 200, 33)];
    orderStartDateLabel.text = @"出发日期:";
    orderStartDateLabel.backgroundColor = [UIColor clearColor];
    orderStartDateLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    orderStartDateLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:orderStartDateLabel];
    [orderStartDateLabel release];
    
    //出发日期
    _orderInfoStartDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 113, 200, 33)];
    _orderInfoStartDateLabel.text = @"";
    _orderInfoStartDateLabel.backgroundColor = [UIColor clearColor];
    _orderInfoStartDateLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _orderInfoStartDateLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:_orderInfoStartDateLabel];
    
    //单价
    UILabel *orderDanjiaLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 121+yPadding, 200, 16)];
    orderDanjiaLabel.text = @"单      价:";
    orderDanjiaLabel.backgroundColor = [UIColor clearColor];
    orderDanjiaLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    orderDanjiaLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:orderDanjiaLabel];
    [orderDanjiaLabel release];
    
    //单价 1818元
    _orderInfoDanjiaLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 121+yPadding, 221, 16)];
    _orderInfoDanjiaLabel.text = @"";
    _orderInfoDanjiaLabel.backgroundColor = [UIColor clearColor];
    _orderInfoDanjiaLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _orderInfoDanjiaLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:_orderInfoDanjiaLabel];

    
    //预订数量
    UILabel *orderYudingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 145+yPadding, 200, 16)];
    orderYudingLabel.text = @"预订数量:";
    orderYudingLabel.backgroundColor = [UIColor clearColor];
    orderYudingLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    orderYudingLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:orderYudingLabel];
    [orderYudingLabel release];
    
    //预订数量 2
    _orderInfoYudingLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 145+yPadding, 221, 16)];
    _orderInfoYudingLabel.text = @"";
    _orderInfoYudingLabel.backgroundColor = [UIColor clearColor];
    _orderInfoYudingLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _orderInfoYudingLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:_orderInfoYudingLabel];
    
    //总额
    UILabel *orderZongeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 169+yPadding, 200, 16)];
    orderZongeLabel.text = @"总      额:";
    orderZongeLabel.backgroundColor = [UIColor clearColor];
    orderZongeLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    orderZongeLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:orderZongeLabel];
    [orderZongeLabel release];
    
    //总额 3616元
    _orderInfoZongeLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 169+yPadding, 221, 16)];
    _orderInfoZongeLabel.text = @"";
    _orderInfoZongeLabel.backgroundColor = [UIColor clearColor];
    _orderInfoZongeLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _orderInfoZongeLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:_orderInfoZongeLabel];
    
    //提供商家
    UILabel *orderShangjiaLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 193+yPadding, 200, 16)];
    orderShangjiaLabel.text = @"提供商家:";
    orderShangjiaLabel.backgroundColor = [UIColor clearColor];
    orderShangjiaLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    orderShangjiaLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:orderShangjiaLabel];
    [orderShangjiaLabel release];
    
    //提供商家 在路上
    _orderInfoFromLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 193+yPadding, 221, 16)];
    _orderInfoFromLabel.text = @"";
    _orderInfoFromLabel.backgroundColor = [UIColor clearColor];
    _orderInfoFromLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _orderInfoFromLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:_orderInfoFromLabel];
    
    //穷游认证商家
    _orderInfoAuthImageView = [[UIImageView alloc] initWithFrame:CGRectMake(141, 193+yPadding, 60, 16)];
    _orderInfoAuthImageView.image = [UIImage imageNamed:@"x_busiInfo_auth_logo.png"];
    [_orderDetailInfoContentView addSubview:_orderInfoAuthImageView];
    _orderInfoAuthImageView.hidden = YES;
    
    //联系电话
    UILabel *orderPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 217+yPadding, 200, 16)];
    orderPhoneLabel.text = @"联系电话:";
    orderPhoneLabel.backgroundColor = [UIColor clearColor];
    orderPhoneLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    orderPhoneLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:orderPhoneLabel];
    [orderPhoneLabel release];
    
    //联系电话 400-820-0088
    _orderInfoPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 217+yPadding, 221, 16)];
    _orderInfoPhoneLabel.text = @"";
    _orderInfoPhoneLabel.backgroundColor = [UIColor clearColor];
    _orderInfoPhoneLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _orderInfoPhoneLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:_orderInfoPhoneLabel];
    
    //支付方式
    UILabel *orderZhifuLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 241+yPadding, 200, 16)];
    orderZhifuLabel.text = @"支付方式:";
    orderZhifuLabel.backgroundColor = [UIColor clearColor];
    orderZhifuLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    orderZhifuLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:orderZhifuLabel];
    [orderZhifuLabel release];
    
    //支付方式 支付宝
    _orderInfoZhifuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(89, 241+yPadding, 60, 18)];
//    _orderInfoZhifuImageView.image = [UIImage imageNamed:@"order_zhifubao_logo.png"];
    [_orderDetailInfoContentView addSubview:_orderInfoZhifuImageView];
    
    //支付成功时间
    UILabel *orderSuccTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 265+yPadding, 200, 16)];
    orderSuccTimeLabel.text = @"支付成功时间:";
    orderSuccTimeLabel.backgroundColor = [UIColor clearColor];
    orderSuccTimeLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    orderSuccTimeLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:orderSuccTimeLabel];
    [orderSuccTimeLabel release];
    
    //支付成功时间 2014年1月1日15时34分
    _orderInfoSuccTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(117, 265+yPadding, 191, 16)];
    _orderInfoSuccTimeLabel.text = @"";//@"2014年1月1日15时34分";
    _orderInfoSuccTimeLabel.backgroundColor = [UIColor clearColor];
    _orderInfoSuccTimeLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _orderInfoSuccTimeLabel.font = [UIFont systemFontOfSize:14];
    [_orderDetailInfoContentView addSubview:_orderInfoSuccTimeLabel];
    


}

#pragma mark - button click
//折扣图、title、价格区域点击button Succ
- (void)orderInfoDetailButtonClickAction:(id)sender
{
    //Nothing to do..
}

//折扣图、title、价格区域点击button Second order
- (void)buyerInfoDetailButtonClickAction:(id)sender
{
    //Nothing to do..
}

@end
