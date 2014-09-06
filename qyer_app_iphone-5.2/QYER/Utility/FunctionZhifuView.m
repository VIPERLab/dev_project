//
//  FunctionZhifuView.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-18.
//
//

#import "FunctionZhifuView.h"
#import "WebViewController.h"
//#import "AlixLibService.h"
//#import "DataSigner.h"

//#import "MyOrderViewController.h"
#import "ConfirmOrderSecondViewController.h"
#import "QYCheckBox.h"
#import "QYCommonUtil.h"
//#import "PartnerConfig.h"

//#define Tag_Alert_CancelBtn    100001

#define yAdjustPadding 28

typedef void(^FunctionZhifuViewCompletionBlock) (void);

@interface FunctionZhifuView()
<
UIAlertViewDelegate
>

@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) UIImageView *backgroundSingleImageView;
@property (nonatomic, retain) UIImageView *curBackgroundImageView;

- (void)hideWithCompletion:(FunctionZhifuViewCompletionBlock)completionBlock;

@end

@implementation FunctionZhifuView

-(void)dealloc
{
    QY_SAFE_RELEASE(_userOrder);
    QY_SAFE_RELEASE(_homeViewController);
    QY_VIEW_RELEASE(_backgroundImageView);
    QY_VIEW_RELEASE(_backgroundSingleImageView);
    QY_VIEW_RELEASE(_curBackgroundImageView);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        
        _zhifuType = FunctionZhifuTypeNone;
        
        CGRect mainBounds = [[UIScreen mainScreen] bounds];
        if (ios7) {
            self.frame =  mainBounds;
        }else{
            self.frame = CGRectMake(0, 0, mainBounds.size.width, mainBounds.size.height-20);
        }
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        self.userInteractionEnabled = YES;
        
        //判断显示哪种UI
        [self checkAndDecideUI];
        
    }
    
    return self;

}

//包含支付宝钱包、支付宝Web端
- (void)configBackgroundImageView
{

    //背景图
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-193, 320, 193)];//285
    _backgroundImageView.image = [UIImage imageNamed:@"x_func_zhifu_bg.png"];
    _backgroundImageView.userInteractionEnabled = YES;
    [self addSubview:_backgroundImageView];
    
    //点击后背景关闭
    UIButton *closeBgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height-_backgroundImageView.frame.size.height)];
    closeBgButton.backgroundColor = [UIColor clearColor];
    [closeBgButton addTarget:self action:@selector(cancelButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBgButton];
    [closeBgButton release];
    
    //关闭按钮
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(250, -48, 96, 96)];
    [closeButton setImage:[UIImage imageNamed:@"x_func_closeBtn.png"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"x_func_closeBtn_highlighted.png"] forState:UIControlStateHighlighted];
//    [closeButton setBackgroundColor:[UIColor redColor]];
    [closeButton addTarget:self action:@selector(cancelButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundImageView addSubview:closeButton];
    [closeButton release];
    
    //选择支付方式
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 300, 19)];
    titleLabel.text = @"选择支付方式";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.backgroundColor = [UIColor clearColor];
    [_backgroundImageView addSubview:titleLabel];
    [titleLabel release];
    
    
    
    //支付宝钱包
    UIButton *zhifubaoAppButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 54+28-yAdjustPadding, 320, 64)];
    [zhifubaoAppButton addTarget:self action:@selector(zhifubaoAppButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [zhifubaoAppButton setBackgroundImage:[[UIImage imageNamed:@"x_cell_top.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:15] forState:UIControlStateNormal];
    [zhifubaoAppButton setBackgroundImage:[[UIImage imageNamed:@"x_cell_top_highlighted.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:15] forState:UIControlStateHighlighted];
    [_backgroundImageView addSubview:zhifubaoAppButton];
    
    //支付宝钱包 分割线
    UIImageView *zhifubaoAppLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, 63, 300, 1)];
    zhifubaoAppLine.image = [UIImage imageNamed:@"x_cell_line.png"];
    [zhifubaoAppButton addSubview:zhifubaoAppLine];
    [zhifubaoAppLine release];
    
    //支付宝钱包 logo
    UIImageView *zhifubaoAppLogoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 40, 40)];
    zhifubaoAppLogoImgView.image = [UIImage imageNamed:@"x_zhifubaoApp_icon.png"];
    [zhifubaoAppButton addSubview:zhifubaoAppLogoImgView];
    [zhifubaoAppLogoImgView release];
    
    //支付宝钱包 支付宝钱包支付
    UILabel *zhifubaoAppTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 12, 240, 18)];
    zhifubaoAppTitleLabel.text = @"支付宝钱包支付";
    zhifubaoAppTitleLabel.textColor = [UIColor blackColor];
    zhifubaoAppTitleLabel.font = [UIFont systemFontOfSize:16];
    zhifubaoAppTitleLabel.backgroundColor = [UIColor clearColor];
    [zhifubaoAppButton addSubview:zhifubaoAppTitleLabel];
    [zhifubaoAppTitleLabel release];
    
    //支付宝钱包 推荐
    UILabel *zhifubaoAppSubTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 39, 240, 14)];
    zhifubaoAppSubTitleLabel.text = @"推荐";
    zhifubaoAppSubTitleLabel.textColor = [UIColor colorWithRed:106.0/255.0f green:112.0/255.0f blue:124.0/255.0f alpha:1.0];
    zhifubaoAppSubTitleLabel.font = [UIFont systemFontOfSize:12];
    zhifubaoAppSubTitleLabel.backgroundColor = [UIColor clearColor];
    [zhifubaoAppButton addSubview:zhifubaoAppSubTitleLabel];
    [zhifubaoAppSubTitleLabel release];
    
    [zhifubaoAppButton release];
    
    
    //------------------------------------------------
    
    //支付宝Web
    UIButton *zhifubaoWebButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 54+64+28-yAdjustPadding, 320, 64+5)];
    [zhifubaoWebButton addTarget:self action:@selector(zhifubaoWebButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [zhifubaoWebButton setBackgroundImage:[[UIImage imageNamed:@"x_cell_bottom.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5] forState:UIControlStateNormal];
    [zhifubaoWebButton setBackgroundImage:[[UIImage imageNamed:@"x_cell_bottom_highlighted.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5] forState:UIControlStateHighlighted];
    [_backgroundImageView addSubview:zhifubaoWebButton];
    
//    //支付宝Web 分割线
//    UIImageView *zhifubaoWebLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, 63, 300, 1)];
//    zhifubaoWebLine.image = [UIImage imageNamed:@"x_cell_line.png"];
//    [zhifubaoWebButton addSubview:zhifubaoWebLine];
//    [zhifubaoWebLine release];
    
    //支付宝Web logo
    UIImageView *zhifubaoWebLogoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 40, 40)];
    zhifubaoWebLogoImgView.image = [UIImage imageNamed:@"x_zhifubaoWeb_icon.png"];
    [zhifubaoWebButton addSubview:zhifubaoWebLogoImgView];
    [zhifubaoWebLogoImgView release];
    
    //支付宝Web 支付宝网页端支付
    UILabel *zhifubaoWebTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 12, 240, 18)];
    zhifubaoWebTitleLabel.text = @"支付宝网页端支付";
    zhifubaoWebTitleLabel.textColor = [UIColor blackColor];
    zhifubaoWebTitleLabel.font = [UIFont systemFontOfSize:16];
    zhifubaoWebTitleLabel.backgroundColor = [UIColor clearColor];
    [zhifubaoWebButton addSubview:zhifubaoWebTitleLabel];
    [zhifubaoWebTitleLabel release];
    
    //支付宝Web 推荐
    UILabel *zhifubaoWebSubTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 39, 240, 14)];
    zhifubaoWebSubTitleLabel.text = @"建议不能使用支付宝钱包的用户使用";
    zhifubaoWebSubTitleLabel.textColor = [UIColor colorWithRed:106.0/255.0f green:112.0/255.0f blue:124.0/255.0f alpha:1.0];
    zhifubaoWebSubTitleLabel.font = [UIFont systemFontOfSize:12];
    zhifubaoWebSubTitleLabel.backgroundColor = [UIColor clearColor];
    [zhifubaoWebButton addSubview:zhifubaoWebSubTitleLabel];
    [zhifubaoWebSubTitleLabel release];
    
    [zhifubaoWebButton release];
    
//    //稍后支付
//    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 54+64+64+28, 320, 64)];
//    [cancelButton setTitle:@"稍后支付" forState:UIControlStateNormal];
//    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
//    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [cancelButton setBackgroundImage:[[UIImage imageNamed:@"x_cell_bottom.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5] forState:UIControlStateNormal];
//    [cancelButton setBackgroundImage:[[UIImage imageNamed:@"x_cell_bottom_highlighted.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5] forState:UIControlStateHighlighted];
////    [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
//    [cancelButton addTarget:self action:@selector(cancelButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_backgroundImageView addSubview:cancelButton];
//    [cancelButton release];


}

//只包含支付宝Web端
- (void)configBackgroundSingleImageView
{
    
    //背景图
    _backgroundSingleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-129, 320, 129)];//221
    _backgroundSingleImageView.image = [UIImage imageNamed:@"x_func_zhifu_single_bg.png"];
    _backgroundSingleImageView.userInteractionEnabled = YES;
    [self addSubview:_backgroundSingleImageView];
    
    //点击后背景关闭
    UIButton *closeBgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height-_backgroundSingleImageView.frame.size.height)];
    closeBgButton.backgroundColor = [UIColor clearColor];
    [closeBgButton addTarget:self action:@selector(cancelButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBgButton];
    [closeBgButton release];
    
    //关闭按钮
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(270, -28, 56, 56)];
    [closeButton setImage:[UIImage imageNamed:@"x_func_closeBtn.png"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"x_func_closeBtn_highlighted.png"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(cancelButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundSingleImageView addSubview:closeButton];
    [closeButton release];
    

    //选择支付方式
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 300, 19)];
    titleLabel.text = @"选择支付方式";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.backgroundColor = [UIColor clearColor];
    [_backgroundSingleImageView addSubview:titleLabel];
    [titleLabel release];
    
//    //checkbox
//    QYCheckBox *directionCheckBox = [[QYCheckBox alloc] initWithFrame:CGRectMake(10, 46+7, 24, 24)];
//    directionCheckBox.checkedImage = [UIImage imageNamed:@"direction_checked.png"];
//    directionCheckBox.unCheckedImage = [UIImage imageNamed:@"direction_unchecked.png"];
//    directionCheckBox.highlightedImage = [UIImage imageNamed:@"direction_unchecked_highlighted.png"];
//    directionCheckBox.disabledImage = [UIImage imageNamed:@"direction_disabled.png"];
//    [directionCheckBox addTarget:self action:@selector(directionCheckBoxClickAction:) forControlEvents:UIControlEventTouchUpInside];
//    directionCheckBox.selected = _isDirectionChecked;
//    [_backgroundSingleImageView addSubview:directionCheckBox];
//    [directionCheckBox release];
//    
//    //接受穷游网穷游折扣产品
//    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 46, 300, 35)];
//    tipLabel.text = @"接受穷游网穷游折扣产品";
//    tipLabel.font = [UIFont systemFontOfSize:15];
//    tipLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
//    tipLabel.backgroundColor = [UIColor clearColor];
//    [_backgroundSingleImageView addSubview:tipLabel];
//    [tipLabel release];
//    
//    //预订说明
//    UIButton *directionButton = [[UIButton alloc] initWithFrame:CGRectMake(207, 47, 60, 35)];
//    [directionButton setTitle:@"预订说明" forState:UIControlStateNormal];
//    [directionButton setTitleColor:[UIColor colorWithRed:13.0/255.0f green:113.0/255.0f blue:190.0/255.0f alpha:1.0] forState:UIControlStateNormal];
//    directionButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
//    [directionButton addTarget:self action:@selector(directionButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_backgroundSingleImageView addSubview:directionButton];
//    [directionButton release];


    
    //支付宝Web
    UIButton *zhifubaoWebButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 54+28-yAdjustPadding, 320, 64)];
    [zhifubaoWebButton addTarget:self action:@selector(zhifubaoWebButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [zhifubaoWebButton setBackgroundImage:[[UIImage imageNamed:@"y_cell_only.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:14] forState:UIControlStateNormal];
    [zhifubaoWebButton setBackgroundImage:[[UIImage imageNamed:@"x_cell_only_highlighted.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:14] forState:UIControlStateHighlighted];
    [_backgroundSingleImageView addSubview:zhifubaoWebButton];
    
//    //支付宝Web 分割线
//    UIImageView *zhifubaoWebLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, 63, 300, 1)];
//    zhifubaoWebLine.image = [UIImage imageNamed:@"x_cell_line.png"];
//    [zhifubaoWebButton addSubview:zhifubaoWebLine];
//    [zhifubaoWebLine release];
    
    //支付宝Web logo
    UIImageView *zhifubaoWebLogoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 40, 40)];
    zhifubaoWebLogoImgView.image = [UIImage imageNamed:@"x_zhifubaoWeb_icon.png"];
    [zhifubaoWebButton addSubview:zhifubaoWebLogoImgView];
    [zhifubaoWebLogoImgView release];
    
    //支付宝Web 支付宝网页端支付
    UILabel *zhifubaoWebTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 12, 240, 40)];//CGRectMake(70, 12, 240, 18)
    zhifubaoWebTitleLabel.text = @"支付宝支付";
    zhifubaoWebTitleLabel.textColor = [UIColor blackColor];
    zhifubaoWebTitleLabel.font = [UIFont systemFontOfSize:16];
    zhifubaoWebTitleLabel.backgroundColor = [UIColor clearColor];
    [zhifubaoWebButton addSubview:zhifubaoWebTitleLabel];
    [zhifubaoWebTitleLabel release];
    
    //支付宝Web 推荐
//    UILabel *zhifubaoWebSubTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 39, 240, 14)];
//    zhifubaoWebSubTitleLabel.text = @"建议不能使用支付宝钱包的用户使用";
//    zhifubaoWebSubTitleLabel.textColor = [UIColor colorWithRed:106.0/255.0f green:112.0/255.0f blue:124.0/255.0f alpha:1.0];
//    zhifubaoWebSubTitleLabel.font = [UIFont systemFontOfSize:12];
//    zhifubaoWebSubTitleLabel.backgroundColor = [UIColor clearColor];
//    [zhifubaoWebButton addSubview:zhifubaoWebSubTitleLabel];
//    [zhifubaoWebSubTitleLabel release];
    
    [zhifubaoWebButton release];
    
    
//    //稍后支付
//    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 54+64+28, 320, 64)];
//    [cancelButton setTitle:@"稍后支付" forState:UIControlStateNormal];
//    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
//    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [cancelButton setBackgroundImage:[[UIImage imageNamed:@"x_cell_bottom.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5] forState:UIControlStateNormal];
//    [cancelButton setBackgroundImage:[[UIImage imageNamed:@"x_cell_bottom_highlighted.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5] forState:UIControlStateHighlighted];
////    [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
//    [cancelButton addTarget:self action:@selector(cancelButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_backgroundSingleImageView addSubview:cancelButton];
//    [cancelButton release];



}

//判断显示哪种UI
- (void)checkAndDecideUI
{
    if ([QYCommonUtil checkIfAppInstalled:kAlipayOrgAppScheme]) {
        
        //包含支付宝钱包、支付宝Web端
        [self configBackgroundImageView];
        
        _backgroundImageView.hidden = NO;
        _backgroundSingleImageView.hidden = YES;
        self.curBackgroundImageView = _backgroundImageView;
    }else{
        
        //只包含支付宝Web端
        [self configBackgroundSingleImageView];
        
        _backgroundImageView.hidden = YES;
        _backgroundSingleImageView.hidden = NO;
        self.curBackgroundImageView = _backgroundSingleImageView;
    }
    

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)show
{
//    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [self.homeViewController.view addSubview:self];
    [self addSubview:_curBackgroundImageView];
    
    self.alpha = 0.0;
    _curBackgroundImageView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, _curBackgroundImageView.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        _curBackgroundImageView.transform = CGAffineTransformIdentity;
        self.alpha = 1.0;
    }];


}

- (void)hideWithCompletion:(FunctionZhifuViewCompletionBlock)completionBlock
{
    [UIView animateWithDuration:0.3 animations:^{
        _curBackgroundImageView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, _curBackgroundImageView.frame.size.height);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
        if (completionBlock) {
            completionBlock();
        }
        
    }];


}

- (void)hide
{
    
    [self hideWithCompletion:NULL];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        _backgroundImageView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, _backgroundImageView.frame.size.height);
//        self.alpha = 0.0;
//    } completion:^(BOOL finished) {
//        
//        [self removeFromSuperview];
//    }];

}

#pragma mark - click
//支付宝钱包支付
- (void)zhifubaoAppButtonClickAction:(id)sender
{
//    [MobClick event:@"paystyle" label:@"支付宝钱包"];
//    _zhifuType = FunctionZhifuTypeApp;
//    
//    [self hideWithCompletion:^{
//        NSString* orderInfo = [self.userOrder alipayDescription];//[self getOrderInfo:indexPath.row];
//        NSString* signedStr = [self doRsa:orderInfo];
//        NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
//                                 orderInfo, signedStr, @"RSA"];
//        
//        NSLog(@"-----------request Alipay Rsa:'%@'", orderString);
//        
//        
//        NSDictionary *orderDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.userOrder.orderId, self.userOrder.orderPrice, nil] forKeys:[NSArray arrayWithObjects:Setting_Alipay_OrderDic_Id, Setting_Alipay_OrderDic_Price, nil]];
//        
//        //Settings
//        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//        [settings setBool:YES forKey:Setting_Alipay_CallBack];
//        [settings setObject:orderDic forKey:Setting_Alipay_OrderDic];
//        [settings synchronize];
//        
//        [AlixLibService payOrder:orderString AndScheme:kAlipayAppScheme seletor:NULL target:self];
//        
//    }];


}

//支付宝网页端支付
- (void)zhifubaoWebButtonClickAction:(id)sender
{
    [MobClick event:@"paystyle" label:@"支付宝网页端"];
    _zhifuType = FunctionZhifuTypeWeb;
    
    [self hideWithCompletion:^{
        
        WebViewController *webVC = [[[WebViewController alloc] init] autorelease];
        webVC.titleString = @"在线支付";
        webVC.needRequestCookie = YES;
        webVC.loadingURL = [NSString stringWithFormat:@"%@&id=%d", kAlipayHtml5URI, [self.userOrder.orderId intValue]];//@"http://www.baidu.com";
        [self.homeViewController presentViewController:webVC animated:YES completion:^{
            
        }];
        
    }];
    
}

//关闭弹窗
- (void)cancelButtonClickAction:(id)sender
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付" message:@"马上要预订成功了，确定要退出么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    alert.tag = Tag_Alert_CancelBtn;
//    [alert show];
//    [alert release];
//    
    [self hide];


}



//-(NSString*)doRsa:(NSString*)orderInfo
//{
//    id<DataSigner> signer;
//    signer = CreateRSADataSigner(PartnerPrivKey);
//    NSString *signedString = [signer signString:orderInfo];
//    return signedString;
//}

#pragma mark - UIAlertViewDelegate
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == Tag_Alert_CancelBtn) {
//        if (buttonIndex==0) {//取消
//            //Nothing to do
//        }else if(buttonIndex==1){//确定
//            [self hide];
//        }
//    }
//    
//
//}

@end
