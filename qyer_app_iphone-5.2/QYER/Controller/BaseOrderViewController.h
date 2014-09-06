//
//  BaseOrderViewController.h
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-14.
//
//

//#import "QYBaseViewController.h"
#import "QYLMBaseViewController.h"
#import "UIImageView+WebCache.h"

#import "LastMinuteOrderInfo.h"

@interface BaseOrderViewController : QYLMBaseViewController

@property (nonatomic, retain) UIScrollView      *mainScrollView;
@property (nonatomic, retain) UIView            *mainContentView;

@property (nonatomic, retain) UIView            *buyerInfoContentView;
@property (nonatomic, retain) UIView            *businessInfoContentView;
@property (nonatomic, retain) UIView            *detailInfoContentView;
@property (nonatomic, retain) UIView            *orderDetailInfoContentView;

//购买人信息
@property (nonatomic, retain) UIImageView       *buyerInfoImageView;
@property (nonatomic, retain) UILabel           *buyerInfoTitleLabel;
@property (nonatomic, retain) UILabel           *buyerInfoPrefixLabel;
@property (nonatomic, retain) UILabel           *buyerInfoPriceLabel;
@property (nonatomic, retain) UILabel           *buyerInfoPriceUnitLabel;
@property (nonatomic, retain) UILabel           *buyerInfoNameLabel;
@property (nonatomic, retain) UILabel           *buyerInfoPhoneLabel;
@property (nonatomic, retain) UILabel           *buyerInfoEmailLabel;
@property (nonatomic, retain) UIButton          *buyerInfoEditButton;

//商家信息
@property (nonatomic, retain) UILabel           *busiInfoFromLabel;
@property (nonatomic, retain) UILabel           *busiInfoPhoneLabel;
@property (nonatomic, retain) UIImageView       *busiInfoAuthImageView;

//购买详情
@property (nonatomic, retain) UILabel           *detailInfoFukuanLabel;
@property (nonatomic, retain) UILabel           *detailInfoChanpinLabel;
@property (nonatomic, retain) UILabel           *detailInfoStartDateLabel;
@property (nonatomic, retain) UILabel           *detailInfoDanjiaLabel;
@property (nonatomic, retain) UILabel           *detailInfoYudingLabel;
@property (nonatomic, retain) UILabel           *detailInfoZongeLabel;
@property (nonatomic, retain) UILabel           *detailInfoZongeUnitLabel;

//订单详情
@property (nonatomic, retain) UIImageView       *orderInfoImageView;
@property (nonatomic, retain) UILabel           *orderInfoTitleLabel;
@property (nonatomic, retain) UILabel           *orderInfoPrefixLabel;
@property (nonatomic, retain) UILabel           *orderInfoPriceLabel;
@property (nonatomic, retain) UILabel           *orderInfoPriceUnitLabel;
@property (nonatomic, retain) UILabel           *orderInfoFukuanLabel;
@property (nonatomic, retain) UILabel           *orderInfoChanpinLabel;
@property (nonatomic, retain) UILabel           *orderInfoStartDateLabel;//出发日期
@property (nonatomic, retain) UILabel           *orderInfoDanjiaLabel;
@property (nonatomic, retain) UILabel           *orderInfoYudingLabel;
@property (nonatomic, retain) UILabel           *orderInfoZongeLabel;
@property (nonatomic, retain) UILabel           *orderInfoFromLabel;
@property (nonatomic, retain) UILabel           *orderInfoPhoneLabel;
@property (nonatomic, retain) UIImageView       *orderInfoAuthImageView;
@property (nonatomic, retain) UIImageView       *orderInfoZhifuImageView;
@property (nonatomic, retain) UILabel           *orderInfoSuccTimeLabel;

//填充折扣总价
- (void)fillLastminuteTotalPriceWithOrderInfo:(LastMinuteOrderInfo*)anOrderInfo;
//填充订单成功折扣总价
- (void)fillOrderLastminuteTotalPriceWithOrderInfo:(LastMinuteOrderInfo*)anOrderInfo;

//购买人信息
- (void)initBuyerInfoViewWithPadding:(CGFloat)aPadding;
//商家信息
- (void)initBusinessInfoViewWithPadding:(CGFloat)aPadding;
//购买详情
- (void)initDetailInfoViewWithPadding:(CGFloat)aPadding;
//订单详情
- (void)initOrderDetailInfoViewWithPadding:(CGFloat)aPadding;


@end
