//
//  LastMinuteDetailViewController.m
//  LastMinute
//
//  Created by lide（蔡小雨） on 13-5-10.
//
//

#import "LastMinuteDetailViewControllerNew.h"
//#import "DetailItem.h"
#import "UIImageView+WebCache.h"
//#import "ImageDetailViewController.h"
//#import "WebViewController.h"
#import "WebViewViewController.h"
//#import "QYShareKit.h"
#import "QyerSns.h"
#import "MYActionSheet.h"
//#import "MBProgressHUD.h"
//#import "LoginViewController.h"
#import "CityLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "QYAPIClient.h"
#import "Reachability.h"
#import "MobClick.h"
#import "QYCommonUtil.h"
//#import "FunctionFillOrderView.h"

//#import "LastMinuteOrderInfo.h"
//#import "LastMinuteProduct.h"
//#import "ConfirmOrderFirstViewController.h"
#import "EditBuyerInfoViewController.h"

#import "AddRemindViewController.h"
#import "FillOrderViewController.h"

#import "QYTime.h"

#import "QYCommonToast.h"

//timeTable
#define  xPadding                 10.0f
#define  yPadding                 35.0f-2
#define  widthTip                 23.0f//56
#define  widthUnit                11.0f//天

#define ImageName_Bottom          @"x_bg_detail_bottomNew.png"


typedef enum {
    BottomStyleEmpty,
    BottomStyleNormal,
    BottomStyleNormalNotStart,
    BottomStyleNotStart,
    BottomStyleStarting,
    BottomStyleFinish,
    BottomStyleSellOut
} BottomStyle;

@interface LastMinuteDetailViewControllerNew ()
<
UIWebViewDelegate,
MYActionSheetDelegate
//FunctionFillOrderViewDelegate
>

@property (nonatomic, retain) LastMinuteDetail         *detail;
@property (nonatomic, retain) NSString                 *shareTitle;
//@property (nonatomic, retain) LastMinuteOrderInfo      *orderInfo;

//@property (nonatomic, retain) FunctionFillOrderView    *functionFillOrderView;

@property (nonatomic, retain) UIButton                 *collectButton;
@property (nonatomic, retain) UIButton                 *cancelCollectButton;

@property (nonatomic, retain) UIWebView                *mainWebView;

@property (nonatomic, retain) UIImageView              *styleEmptyContentView;//空白
@property (nonatomic, retain) UIImageView              *styleNormalContentView;//不能进行购买
@property (nonatomic, retain) UIImageView              *styleNormalNotStartContentView;//不能进行购买
@property (nonatomic, retain) UIImageView              *styleNotStartContentView;//未开始
@property (nonatomic, retain) UIImageView              *styleStartingContentView;//已开始
@property (nonatomic, retain) UIImageView              *styleFinishContentView;//已结束
@property (nonatomic, retain) UIImageView              *styleSellOutContentView;//已售罄
@property (nonatomic, assign) BottomStyle              bottomStyle;

//@property (nonatomic, retain) UILabel                  *styleNotStartTipDaysLabel;//@"1天23小时57秒"
//@property (nonatomic, retain) UILabel                  *styleStartingTipLabel;//@"1天23小时57秒"

////未开始 Tip
//@property (nonatomic, retain) UILabel                  *styleNotStartTipDaysLabel;//天
//@property (nonatomic, retain) UILabel                  *styleNotStartTipHoursLabel;//小时
//@property (nonatomic, retain) UILabel                  *styleNotStartTipMinutesLabel;//分
//@property (nonatomic, retain) UILabel                  *styleNotStartTipSecondsLabel;//秒
//
////未开始
//@property (nonatomic, retain) UILabel                  *styleNotStartDaysLabel;//天
//@property (nonatomic, retain) UILabel                  *styleNotStartHoursLabel;//小时
//@property (nonatomic, retain) UILabel                  *styleNotStartMinutesLabel;//分
//@property (nonatomic, retain) UILabel                  *styleNotStartSecondsLabel;//秒


@property (nonatomic, retain) UIView                   *timeTableContentView;

//已开始 Tip
@property (nonatomic, retain) UILabel                  *styleStartingTipDaysLabel;//天
@property (nonatomic, retain) UILabel                  *styleStartingTipHoursLabel;//小时
@property (nonatomic, retain) UILabel                  *styleStartingTipMinutesLabel;//分
@property (nonatomic, retain) UILabel                  *styleStartingTipSecondsLabel;//秒

//已开始
@property (nonatomic, retain) UILabel                  *styleStartingDaysLabel;//天
@property (nonatomic, retain) UILabel                  *styleStartingHoursLabel;//小时
@property (nonatomic, retain) UILabel                  *styleStartingMinutesLabel;//分
@property (nonatomic, retain) UILabel                  *styleStartingSecondsLabel;//秒


@property (nonatomic, assign) __block int               timeout;
@property (nonatomic, assign) dispatch_queue_t          queue;
@property (nonatomic, assign) dispatch_source_t         timer;

@end

@implementation LastMinuteDetailViewControllerNew

//@synthesize lastMinute = _lastMinute;
@synthesize lastMinuteId = _lastMinuteId;
//@synthesize lastMinuteTitle = _lastMinuteTitle;

#pragma mark - private

- (void)clickCollectButton:(id)sender
{
    [MobClick event:@"detailClickFavor"];
    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue])
    {
        
        //判断是否显示登陆框
        [self showLoginAlertWithMessage:@"收藏该折扣需要先登录？"];
        
        return;
    }
    
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        //        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        hud.mode = MBProgressHUDModeText;
        //        hud.labelText = @"请检查网络连接";
        //        hud.yOffset -= 35;
        //        dispatch_time_t popTime;
        //        popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (TOAST_DURATION * NSEC_PER_SEC));
        //        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //            [MBProgressHUD hideHUDForView:self.view animated:YES];
        //        });
        
        [self.view hideToast];
        [self.view makeToast:@"请检查网络连接" duration:1.0 position:@"center" isShadow:NO];
        
        return;
    }
    
    if(_isLoading)
    {
        return;
    }
    _isLoading = YES;
    
    [self.view makeToastActivity];
    [[QYAPIClient sharedAPIClient] lastMinuteAddFavorWithId:[_detail.lastMinuteId intValue]
                                                    success:^(NSDictionary *dic) {
                                                        
                                                        [self.view hideToastActivity];
                                                        [self.view hideToast];
                                                        [self.view makeToast:@"添加收藏成功" duration:1.2f position:@"center" isShadow:NO];
                                                        
                                                        //                                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                        //                                                        hud.mode = MBProgressHUDModeText;
                                                        //                                                        hud.labelText = @"添加收藏成功";
                                                        //                                                        dispatch_time_t popTime;
                                                        //                                                        popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.0 * NSEC_PER_SEC));
                                                        //                                                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                        //                                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                        //                                                        });
                                                        
                                                        _collectButton.hidden = YES;
                                                        _cancelCollectButton.hidden = NO;
                                                        
                                                        _isLoading = NO;
                                                        
                                                    } failure:^ {
                                                        
                                                        [self.view hideToastActivity];
                                                        [self.view hideToast];
                                                        [self.view makeToast:@"添加收藏失败" duration:1.2f position:@"center" isShadow:NO];
                                                        
                                                        //                                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                        //                                                        hud.mode = MBProgressHUDModeText;
                                                        //                                                        hud.labelText = @"添加收藏失败";
                                                        //                                                        dispatch_time_t popTime;
                                                        //                                                        popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.0 * NSEC_PER_SEC));
                                                        //                                                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                        //                                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                        //                                                        });
                                                        
                                                        _isLoading = NO;
                                                        
                                                    }];
}

- (void)clickCancelCollectButton:(id)sender
{
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        //        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        hud.mode = MBProgressHUDModeText;
        //        hud.labelText = @"请检查网络连接";
        //        hud.yOffset -= 35;
        //        dispatch_time_t popTime;
        //        popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (TOAST_DURATION * NSEC_PER_SEC));
        //        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //            [MBProgressHUD hideHUDForView:self.view animated:YES];
        //        });
        
        [self.view hideToast];
        [self.view makeToast:@"请检查网络连接" duration:1 position:@"center" isShadow:NO];
        
        return;
    }
    
    if(_isLoading)
    {
        return;
    }
    _isLoading = YES;
    
    [self.view makeToastActivity];
    [[QYAPIClient sharedAPIClient] lastMinuteDeleteFavorWithId:[_detail.lastMinuteId intValue]
                                                       success:^(NSDictionary *dic) {
                                                           
                                                           [self.view hideToastActivity];
                                                           [self.view hideToast];
                                                           [self.view makeToast:@"取消收藏成功" duration:1.2f position:@"center" isShadow:NO];
                                                           
                                                           //                                                           MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                           //                                                           hud.mode = MBProgressHUDModeText;
                                                           //                                                           hud.labelText = @"取消收藏成功";
                                                           //                                                           dispatch_time_t popTime;
                                                           //                                                           popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.0 * NSEC_PER_SEC));
                                                           //                                                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                           //                                                               [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                           //                                                           });
                                                           
                                                           _collectButton.hidden = NO;
                                                           _cancelCollectButton.hidden = YES;
                                                           
                                                           _isLoading = NO;
                                                           
                                                       } failure:^ {
                                                           
                                                           [self.view hideToastActivity];
                                                           [self.view hideToast];
                                                           [self.view makeToast:@"取消收藏失败" duration:1.2f position:@"center" isShadow:NO];
                                                           
                                                           //                                                           MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                           //                                                           hud.mode = MBProgressHUDModeText;
                                                           //                                                           hud.labelText = @"取消收藏失败";
                                                           //                                                           dispatch_time_t popTime;
                                                           //                                                           popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.0 * NSEC_PER_SEC));
                                                           //                                                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                           //                                                               [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                           //                                                           });
                                                           
                                                           _isLoading = NO;
                                                           
                                                       }];
}

- (void)clickShareButton:(id)sender
{
    //    [[QYShareKit sharedInstance] show];
    //    [[QYShareKit sharedInstance] setDetail:_detail];
    ////    [[QYShareKit sharedInstance] setShareImage:_lmImageView.image];
    
    BOOL flag = [[QyerSns sharedQyerSns] getIsWeixinInstalled];
    NSString *versonStr = [[QyerSns sharedQyerSns] getWeixinVerson];
    BOOL SMSFlag = [[QyerSns sharedQyerSns] isCanSendSMS];
    
    if (SMSFlag)
    {
        if(flag == 1 && iPhone5)
        {
            MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",@"短信", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo", @"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
            actionSheet.delegate = self;
            
            [actionSheet show];
            [actionSheet release];
        }
        else
        {
            if(flag == 0 || [versonStr floatValue] - 1.1 < 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"腾讯微博",@"邮件", @"短信", nil] imageArray:[NSArray arrayWithObjects: @"btn_actionsheet_weibo",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
            else if(flag == 1 && [versonStr floatValue] - 1.1 >= 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",@"短信",  nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo",@"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail",@"btn_actionsheet_message", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
        }
    }
    else
    {
        if(flag == 1 && iPhone5)
        {
            MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo", @"btn_actionsheet_weixin", @"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
            actionSheet.delegate = self;
            
            [actionSheet show];
            [actionSheet release];
        }
        else
        {
            if(flag == 0 || [versonStr floatValue] - 1.1 < 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"腾讯微博",@"邮件", nil] imageArray:[NSArray arrayWithObjects:@"btn_actionsheet_weibo",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
                actionSheet.delegate = self;
                [actionSheet show];
                [actionSheet release];
            }
            else if(flag == 1 && [versonStr floatValue]  - 1.1 >= 0)
            {
                MYActionSheet *actionSheet = [[MYActionSheet alloc] initWithTitleArray:[NSArray arrayWithObjects:@"新浪微博",@"微信",@"微信朋友圈",@"腾讯微博",@"邮件",  nil] imageArray:[NSArray arrayWithObjects: @"btn_actionsheet_weibo", @"btn_actionsheet_weixin",@"btn_actionsheet_people",@"btn_actionsheet_tengxun",@"btn_actionsheet_mail", nil]];
                actionSheet.delegate = self;
                
                [actionSheet show];
                [actionSheet release];
            }
        }
    }
}

#pragma mark - MYActionSheetDelegate
-(void)actionSheetButtonDidClickWithType:(NSString*)type
{
    if([type isEqualToString:@"邮件"])
    {
        //[MobClick event:@"setting" label:@"邮件分享"];
        [self youjianfenxiang];
    }
    if([type isEqualToString:@"短信"])
    {
        //[MobClick event:@"setting" label:@"短信"];
        [self sendmessage];
    }
    else if([type isEqualToString:@"新浪微博"])
    {
        //[MobClick event:@"setting" label:@"新浪微博分享"];
        [self shareToSinaWeibo];
    }
    else if([type isEqualToString:@"微信"])
    {
        //[MobClick event:@"setting" label:@"微信分享"];
        [self shareToWeixinFriend];
    }
    else if([type isEqualToString:@"微信朋友圈"])
    {
        //[MobClick event:@"setting" label:@"微信朋友圈"];
        [self shareToWeixinFriendCircle];
    }
    else if([type isEqualToString:@"腾讯微博"])
    {
        [self shareToTencentWeibo];
    }
}

#pragma mark --- 分享
-(void)youjianfenxiang
{
    NSString * shareURL = _detail.qyerURL;//[self.dealInfoDictionary objectForKey:@"qyer_url"];
    
    [[QyerSns sharedQyerSns] shareToMailWithMailTitle:[NSString stringWithFormat:@"Hi~我在#穷游APP#里发现一条给力折扣【%@】",self.shareTitle] andMailInfo:[NSString stringWithFormat:@"Hi~\n\t我在#穷游APP#里发现一条给力折扣【%@】，已经hold不住准备拿下啦！\n\t你要不要？也来抢一发呗！折扣详情→_→ %@ \n\n\t关于出境游，这一切，尽在穷游。\n\t只需免费下载穷游APP，你就进入了穷游的世界，这里不仅有准确的指南和给力的折扣，这里还有由经验丰富的穷游网友所组成的社区，通过问答和发帖，大家可以彼此互助。\n\t从此，你将永远不会独行，伴随你旅行始终的，将是穷游和穷游的几千万新老朋友。\n\t有了穷游APP，你就放心出行吧。 穷游，陪你体验整个世界的精彩。\n\t穷游App有iPhone、Android和iPad版本，扫描二维码即可轻松下载！",self.shareTitle,shareURL] andImage: [UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)sendmessage
{
    NSString * shareURL = _detail.qyerURL;//[self.dealInfoDictionary objectForKey:@"qyer_url"];
    [[QyerSns sharedQyerSns] shareWithShortMessage:[NSString stringWithFormat:@"在#穷游APP#里发现一条给力折扣【%@】，我已经hold不住准备拿下啦！你要不要？也来抢一发呗！折扣详情→_→ %@",self.shareTitle,shareURL] inViewController:self];
}

-(void)shareToWeixinFriend
{
    NSString * shareURL = _detail.qyerURL;//[self.dealInfoDictionary objectForKey:@"qyer_url"];
    
    [[QyerSns sharedQyerSns] shareToWeixinWithAPPTitle:@"穷游APP" andDescription:[NSString stringWithFormat:@"在#穷游APP#里发现一条给力折扣【%@】，已经hold不住，准备拿下啦！你要不要？也来抢一发呗！",self.shareTitle] andImage:[UIImage imageNamed:@"120icon"] andUrl:shareURL];
}

-(void)shareToWeixinFriendCircle
{
    NSString * shareURL = _detail.qyerURL;//[self.dealInfoDictionary objectForKey:@"qyer_url"];
    
    [[QyerSns sharedQyerSns] shareToWeixinFriendCircleWithAPPTitle:[NSString stringWithFormat:@"在#穷游APP#里发现一条给力折扣【%@】，超级给力、无法淡定。我准备拿下了，大家快抢！折扣详情→_→",self.shareTitle] andDescription:@"" andImage:[UIImage imageNamed:@"120icon"] andUrl:shareURL];
}

-(void)shareToSinaWeibo
{
    NSString * shareURL = _detail.qyerURL;//[self.dealInfoDictionary objectForKey:@"qyer_url"];
    
    [[QyerSns sharedQyerSns] shareToSinaWeiboWithTitle:@"分享到新浪微博" andText:[NSString stringWithFormat:@"在#穷游APP#里发现一条给力折扣【%@】，超级给力、无法淡定。我准备拿下了，大家快抢！折扣详情→_→ %@",self.shareTitle,shareURL] andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)shareToTencentWeibo
{
    NSString * shareURL = _detail.qyerURL;//[self.dealInfoDictionary objectForKey:@"qyer_url"];
    [[QyerSns sharedQyerSns] shareToTencentWeiboWithText:[NSString stringWithFormat:@"在#穷游APP#里发现一条给力折扣【%@】，超级给力、无法淡定。我准备拿下了，大家快抢！折扣详情→_→ %@",self.shareTitle,shareURL] andImage:[UIImage imageNamed:@"iphone_sina_sns"] andDelegate:self];
}


- (void)loginSucceed:(NSNotification *)notification
{
    //    [self clickBookButton:nil];
    [MobClick event:@"detailLoginSuccess"];
}

- (void)registerSucceed:(NSNotification *)notification
{
    [MobClick event:@"detailSignUpSuccess"];
}

- (void)clickBookButton:(id)sender
{
    [MobClick event:@"detailClickBook" label:_lmBookButton.titleLabel.text];//@"在线预订"];
    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] && [_detail.qyerOnlyFlag intValue] == 1)
    {
        
        //判断是否显示登陆框
        [self showLoginAlertWithMessage:@"预定该折扣需要先登录？"];
        
        return;
    }
    
    if([_detail.orderInfoArray count] > 0)
    {
        
        if(_detail.lastMinuteDiscountCode && ![_detail.lastMinuteDiscountCode isEqualToString:@""])
        {
            BookView *bookView = [[BookView alloc] initWithOrderArray:_detail.orderInfoArray
                                                           titleArray:_detail.orderTitleArray
                                                          dicountCode:_detail.lastMinuteDiscountCode
                                                            orderType:[_detail.orderType intValue]];
            bookView.delegate = self;
            [bookView show];
        }
        else
        {
            BookView *bookView = [[BookView alloc] initWithOrderArray:_detail.orderInfoArray
                                                           titleArray:_detail.orderTitleArray
                                                            orderType:[_detail.orderType intValue]];
            bookView.delegate = self;
            [bookView show];
        }
    }
    else if([_detail.orderInfoArray count] == 0)
    {
        return;
    }
    //    else
    //    {
    //        if([_detail.orderType intValue] == 0)
    //        {
    //            WebViewController *webVC = [[[WebViewController alloc] init] autorelease];
    //            webVC.loadingURL = [_detail.orderInfoArray objectAtIndex:0];
    //            [self.navigationController pushViewController:webVC animated:YES];
    //        }
    //        else
    //        {
    //            if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
    //                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"确定拨打电话?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //                alertView.tag = 16652;
    //                [alertView show];
    //                [alertView release];
    //
    //            }
    //            else
    //            {
    //                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //                hud.mode = MBProgressHUDModeText;
    //                hud.labelText = @"您的设备不支持拨打电话";
    //                dispatch_time_t popTime;
    //                popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.0 * NSEC_PER_SEC));
    //                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //                    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //                });
    //            }
    //        }
    //    }
}

//- (void)refreshWithShortInfo
//{
//    if(_lastMinute == nil)
//    {
//        return;
//    }

//    [_lmImageView setImageWithURL:[NSURL URLWithString:_lastMinute.lastMinutePicture] placeholderImage:[UIImage imageNamed:@"place_holder_large.png"]];

//    _lmTitleLabel.text = _lastMinute.lastMinuteTitle;
//    _lmTimeLabel.text = _lastMinute.lastMinuteFinishDate;
//    NSString *string = _lastMinute.lastMinutePrice;

//    NSArray *array = [string componentsSeparatedByString:@"<em>"];

//    if([array count] > 1)
//    {
//        CGSize titleSize = [_lastMinuteTitle sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:CGSizeMake(304, 200) lineBreakMode:NSLineBreakByWordWrapping];
//        CGFloat height = titleSize.height;
//        if (height < 20)
//        {
//            height = 20;
//        }

//        CGFloat offsetX = 0;
//        CGSize prefixSize = [(NSString *)[array objectAtIndex:0] sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(200, 200) lineBreakMode:NSLineBreakByWordWrapping];
//        _prefixLabel.frame = CGRectMake(195, 47 + height - 20, prefixSize.width, 13);
//        _prefixLabel.text = [array objectAtIndex:0];
//        offsetX += prefixSize.width + _prefixLabel.frame.origin.x;

//        NSArray *anotherArray = [(NSString *)[array objectAtIndex:1] componentsSeparatedByString:@"</em>"];

//        UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:21.0];
//        if(font == nil)
//        {
//            font = [UIFont fontWithName:@"HiraKakuProN-W3" size:21.0];
//        }

//        CGSize priceSize = [(NSString *)[anotherArray objectAtIndex:0] sizeWithFont:font constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByWordWrapping];
//        _priceLabel.frame = CGRectMake(offsetX, _priceLabel.frame.origin.y, priceSize.width, _priceLabel.frame.size.height);
//        _priceLabel.text = [anotherArray objectAtIndex:0];
//        offsetX += priceSize.width;

//        if([anotherArray count] > 1)
//        {
//            CGSize suffixSize = [(NSString *)[anotherArray objectAtIndex:1] sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByWordWrapping];
//            _suffixLabel.frame = CGRectMake(offsetX, 47 + height - 20, suffixSize.width, 13);
//            _suffixLabel.text = [anotherArray objectAtIndex:1];
//        }
//    }
//    else
//    {
//        _priceLabel.text = _lastMinute.lastMinutePrice;
//    }

//    if([_lastMinute.qyerOnlyFlag intValue])
//    {
//        _qyerOnlyImageView.hidden = NO;
//    }
//    else
//    {
//        _qyerOnlyImageView.hidden = YES;
//    }

//    if([_lastMinute.qyerFirstFlag intValue])
//    {
//        _qyerFirstImageView.hidden = NO;
//    }
//    else
//    {
//        _qyerFirstImageView.hidden = YES;
//    }
//}

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
                
                //刷新我的订单界面
                //                [[NSNotificationCenter defaultCenter] postNotificationName:Notification_MyOrder_Refresh object:nil];
                
                //刷新界面数据
                [self refreshView];
                
            });
        }else{
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                
                
                //            NSString *timeStr = [QYCommonUtil getTimeStrngWithSeconds:timeout];//获得倒计时时间格式： 2天13小时19分54秒
                NSDictionary *timeInfo = [QYCommonUtil getTimeInfoWithSeconds:_timeout];//获得倒计时时间格式： 2天13小时19分54秒
                [self setTimeTableWithTimeInfo:timeInfo];
                
                //                if (aBottomStyle == BottomStyleNotStart) {//未开始（设置提醒） 倒计时
                //
                //                    NSString *strTime = [NSString stringWithFormat:@"%@", timeStr];
                ////                    _styleNotStartTipLabel.text = strTime;//@"在2天13小时19分54秒内完成支付！"
                //
                //                }else if (aBottomStyle == BottomStyleStarting){//已开始（立即预订）倒计时
                //                    NSString *strTime = [NSString stringWithFormat:@"%@", timeStr];
                ////                    _styleStartingTipLabel.text = strTime;//@"在2天13小时19分54秒内完成支付！"
                //
                //                }
                
            });
            _timeout--;
            
        }
    });
    dispatch_resume(_timer);
    
    
}

- (void)setTimeTableWithTimeInfo:(NSDictionary*)aTimeInfo
{
    
    int days = [[aTimeInfo objectForKey:Key_Time_Days] intValue];
    int hours = [[aTimeInfo objectForKey:Key_Time_Hours] intValue];
    int minutes = [[aTimeInfo objectForKey:Key_Time_Minutes] intValue];
    int seconds = [[aTimeInfo objectForKey: Key_Time_Seconds] intValue];
    
    
    CGFloat x = xPadding;
    CGFloat tPadding = 2;//调整天、小时、分、秒之间的间隔
    
    if (days>0) {//显示 天
        _styleStartingTipDaysLabel.hidden = NO;
        _styleStartingDaysLabel.hidden = NO;
        _styleStartingTipDaysLabel.text = [NSString stringWithFormat:@"%d", days];
        
        CGSize size = [_styleStartingTipDaysLabel.text sizeWithFont:_styleStartingTipDaysLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _styleStartingTipDaysLabel.frame.size.height) lineBreakMode:_styleStartingTipDaysLabel.lineBreakMode];
        CGFloat width = size.width + tPadding;
        
        CGRect frame = _styleStartingTipDaysLabel.frame;
        frame.origin.x = x;
        frame.size.width = width;
        _styleStartingTipDaysLabel.frame = frame;
        
        x += width;
        
        frame = _styleStartingDaysLabel.frame;
        frame.origin.x = x;
        _styleStartingDaysLabel.frame = frame;
        
        x += widthUnit;
        
    }else{
        _styleStartingTipDaysLabel.hidden = YES;
        _styleStartingDaysLabel.hidden = YES;
    }
    
    if (hours>0) {//显示 小时
        _styleStartingTipHoursLabel.hidden = NO;
        _styleStartingHoursLabel.hidden = NO;
        _styleStartingTipHoursLabel.text = [NSString stringWithFormat:@"%d", hours];
        
        CGSize size = [_styleStartingTipHoursLabel.text sizeWithFont:_styleStartingTipHoursLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _styleStartingTipHoursLabel.frame.size.height) lineBreakMode:_styleStartingTipHoursLabel.lineBreakMode];
        CGFloat width = size.width + tPadding;
        
        CGRect frame = _styleStartingTipHoursLabel.frame;
        frame.origin.x = x;
        frame.size.width = width;
        _styleStartingTipHoursLabel.frame = frame;
        
        x += width;
        
        frame = _styleStartingHoursLabel.frame;
        frame.origin.x = x;
        _styleStartingHoursLabel.frame = frame;
        
        x += widthUnit*2;
        
    }else{
        _styleStartingTipHoursLabel.hidden = YES;
        _styleStartingHoursLabel.hidden = YES;
    }
    
    if (minutes>0) {//显示 分
        _styleStartingTipMinutesLabel.hidden = NO;
        _styleStartingMinutesLabel.hidden = NO;
        _styleStartingTipMinutesLabel.text = [NSString stringWithFormat:@"%d", minutes];
        
        CGSize size = [_styleStartingTipMinutesLabel.text sizeWithFont:_styleStartingTipMinutesLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _styleStartingTipMinutesLabel.frame.size.height) lineBreakMode:_styleStartingTipMinutesLabel.lineBreakMode];
        CGFloat width = size.width + tPadding;
        
        CGRect frame = _styleStartingTipMinutesLabel.frame;
        frame.origin.x = x;
        frame.size.width = width;
        _styleStartingTipMinutesLabel.frame = frame;
        
        x += width;
        
        frame = _styleStartingMinutesLabel.frame;
        frame.origin.x = x;
        _styleStartingMinutesLabel.frame = frame;
        
        x += widthUnit;
        
    }else{
        _styleStartingTipMinutesLabel.hidden = YES;
        _styleStartingMinutesLabel.hidden = YES;
    }
    
    if (seconds>0) {//显示 秒
        _styleStartingTipSecondsLabel.hidden = NO;
        _styleStartingSecondsLabel.hidden = NO;
        _styleStartingTipSecondsLabel.text = [NSString stringWithFormat:@"%d", seconds];
        
        CGSize size = [_styleStartingTipSecondsLabel.text sizeWithFont:_styleStartingTipSecondsLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _styleStartingTipSecondsLabel.frame.size.height) lineBreakMode:_styleStartingTipSecondsLabel.lineBreakMode];
        CGFloat width = size.width + tPadding;
        
        CGRect frame = _styleStartingTipSecondsLabel.frame;
        frame.origin.x = x;
        frame.size.width = width;
        _styleStartingTipSecondsLabel.frame = frame;
        
        x += width;
        
        frame = _styleStartingSecondsLabel.frame;
        frame.origin.x = x;
        _styleStartingSecondsLabel.frame = frame;
        
        x += widthUnit;
        
    }else{
        _styleStartingTipSecondsLabel.hidden = YES;
        _styleStartingSecondsLabel.hidden = YES;
    }
    
    
}

//刷新界面数据
- (void)refreshView
{
    
    //请求折扣详情数据
    [self requestForLastMinuteDetail];
    
    //请求折扣预订信息
    //    [self requestForOrderInfo];
    
}

- (void)loadWebViewFromUrl:(NSString*)aUrl
{
    //
    //    DataManager *dataManager = [DataManager sharedManager];
    //    BOOL isCached = [dataManager webFileExistsFromCache:aUrl];
    //    if (isCached) {
    //
    //    }else{
    //        [_mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:aUrl]]];
    //
    //    }
    
    [_mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:aUrl]]];
    
    
}

//刷新分享Title的数据 by 大App
- (void)reloadShareTitle
{
    NSString * titleee = _detail.lastMinuteTitle;//[[dic objectForKey:@"data"] objectForKey:@"title"];
    NSMutableString *priceee = [NSMutableString stringWithString:_detail.lastMinutePrice];//[NSMutableString stringWithString:[[dic objectForKey:@"data"] objectForKey:@"price"]];
    NSRange frontRange = [priceee rangeOfString:@"<em>"];
    if(frontRange.length != 0)
    {
        [priceee deleteCharactersInRange:frontRange];
    }
    NSRange backRange = [priceee rangeOfString:@"</em>"];
    if(backRange.length != 0)
    {
        [priceee deleteCharactersInRange:backRange];
    }
    self.shareTitle = [NSString stringWithFormat:@"%@ %@",titleee,priceee];
}

//刷新数据
- (void)reloadData
{
    //刷新分享Title的数据 by 大App
    [self reloadShareTitle];
    
    //获得当前时间戳
    NSTimeInterval nowInterval = [QYTime nowAdjustTimeInterval];//[[NSDate date] timeIntervalSince1970];
    //判断bottomView的显示类型
    if (_detail.app_booktype == BookTypeNotPay) {
        
        NSLog(@"----------app_endDate:%d", [_detail.app_endDate intValue]);
        
        if (_detail.onsaleType == OnsaleTypeOff) {//已售罄
            
            [self showBottomViewWithBottomStyle:BottomStyleSellOut];//已售罄
            
        }else if(_detail.onsaleType == OnsaleTypeOn){//在售
            
            if (nowInterval < [_detail.app_endDate intValue]) {
                
                //UI
                [self showBottomViewWithBottomStyle:BottomStyleNormalNotStart];
                //UI TIPS
                NSTimeInterval seconds = [_detail.app_endDate intValue] - nowInterval;
                [self setTimeScheduleWithTimeInterval:seconds];
                
            }else{
                
                [self showBottomViewWithBottomStyle:BottomStyleFinish];//BottomStyleNormal];
                
            }
            
        }
        
    }else{
        
        if (nowInterval < [_detail.app_firstpayStartTime intValue]) {//未开始
            
            //UI
            [self showBottomViewWithBottomStyle:BottomStyleNotStart];
            //UI TIPS
            NSTimeInterval seconds = [_detail.app_firstpayStartTime intValue] - nowInterval;
            [self setTimeScheduleWithTimeInterval:seconds];
            
            
        }else if(nowInterval<[_detail.app_firstpayEndTime intValue]-Time_One_Minute){//已开始 &&nowInterval<[_detail.app_secondpaypayEndTime intValue]-Time_One_Minute
            
            if ([_detail.app_stock intValue]>0) {
                
                //UI
                [self showBottomViewWithBottomStyle:BottomStyleStarting];//已开始
                //UI TIPS
                NSTimeInterval seconds = [_detail.app_firstpayEndTime intValue] - nowInterval-Time_One_Minute;
                [self setTimeScheduleWithTimeInterval:seconds];
                
            }else{
                [self showBottomViewWithBottomStyle:BottomStyleSellOut];//已售罄
            }
            
        }else{//已结束
            [self showBottomViewWithBottomStyle:BottomStyleFinish];//已结束
            
        }
        
    }
    
    _lmTimeLabel.text = _detail.lastMinuteFinishDate;
    
    
    //加载WebView
    [self loadWebViewFromUrl:_detail.app_url];
    
    if([_detail.favoredFlag intValue])
    {
        _collectButton.hidden = YES;
        _cancelCollectButton.hidden = NO;
    }
    else
    {
        _collectButton.hidden = NO;
        _cancelCollectButton.hidden = YES;
    }
    
    if([_detail.orderType intValue] == 0)
    {
        [_lmBookButton setTitle:@"在线预订" forState:UIControlStateNormal];
    }
    else
    {
        [_lmBookButton setTitle:@"电话预订" forState:UIControlStateNormal];
    }
    
    
    
    
    
    
    
    
    
    
    //    [_lmImageView setImageWithURL:[NSURL URLWithString:_detail.lastMinutePicture] placeholderImage:[UIImage imageNamed:@"place_holder_large.png"]];
    
    //    _lmTitleLabel.text = _detail.lastMinuteTitle;
    
    //    NSString *string = _detail.lastMinutePrice;
    
    //    NSArray *array = [string componentsSeparatedByString:@"<em>"];
    
    //    if([array count] > 1)
    //    {
    //        CGSize titleSize = [_lastMinuteTitle sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:CGSizeMake(304, 200) lineBreakMode:NSLineBreakByWordWrapping];
    //        CGFloat height = titleSize.height;
    //        if (height < 20)
    //        {
    //            height = 20;
    //        }
    
    //        CGFloat offsetX = 0;
    //        CGSize prefixSize = [(NSString *)[array objectAtIndex:0] sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(200, 200) lineBreakMode:NSLineBreakByWordWrapping];
    //        _prefixLabel.frame = CGRectMake(195, 47 + height - 20, prefixSize.width, 13);
    //        _prefixLabel.text = [array objectAtIndex:0];
    //        offsetX += prefixSize.width + _prefixLabel.frame.origin.x;
    
    //        NSArray *anotherArray = [(NSString *)[array objectAtIndex:1] componentsSeparatedByString:@"</em>"];
    
    //        UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:21.0];
    //        if(font == nil)
    //        {
    //            font = [UIFont fontWithName:@"HiraKakuProN-W3" size:21.0];
    //        }
    
    //        CGSize priceSize = [(NSString *)[anotherArray objectAtIndex:0] sizeWithFont:font constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByWordWrapping];
    //        _priceLabel.frame = CGRectMake(offsetX, _priceLabel.frame.origin.y, priceSize.width, _priceLabel.frame.size.height);
    //        _priceLabel.text = [anotherArray objectAtIndex:0];
    //        offsetX += priceSize.width;
    
    //        if([anotherArray count] > 1)
    //        {
    //            CGSize suffixSize = [(NSString *)[anotherArray objectAtIndex:1] sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(300, 300) lineBreakMode:NSLineBreakByWordWrapping];
    //            _suffixLabel.frame = CGRectMake(offsetX, 47 + height - 20, suffixSize.width, 13);
    //            _suffixLabel.text = [anotherArray objectAtIndex:1];
    //        }
    //    }
    //    else
    //    {
    //        _priceLabel.text = _detail.lastMinutePrice;
    //    }
    
    //    _codeLabel.text = _detail.lastMinuteDiscountCode;
    
    //    if([_detail.qyerOnlyFlag intValue])
    //    {
    //        _qyerOnlyImageView.hidden = NO;
    //    }
    //    else
    //    {
    //        _qyerOnlyImageView.hidden = YES;
    //    }
    
    //    if([_detail.qyerFirstFlag intValue])
    //    {
    //        _qyerFirstImageView.hidden = NO;
    //    }
    //    else
    //    {
    //        _qyerFirstImageView.hidden = YES;
    //    }
    
    //    if(_detail.lastMinuteDiscountCode == nil || [_detail.lastMinuteDiscountCode isEqualToString:@""])
    //    {
    //        _lmDiscountLabel.hidden = YES;
    //    }
    //    else
    //    {
    //        _lmDiscountLabel.hidden = NO;
    //    }
    
    //    _lmDiscountLabel.hidden = YES;
    //    _codeLabel.hidden = YES;
    //    if([[NSUserDefaults standardUserDefaults] boolForKey:@"qyerlogin"])
    //    {
    //        if(_detail && [_detail.loginVisibleFlag intValue])
    //        {
    //            _codeLabel.hidden = NO;
    ////            _lmDiscountLabel.hidden = NO;
    //        }
    //    }
    
    //    [_detailArray removeAllObjects];
    
    //    if(_detail.lastMinuteDetail && ![_detail.lastMinuteDetail isEqualToString:@""])
    //    {
    //        DetailItem *aItem = [[[DetailItem alloc] init] autorelease];
    //        aItem.type = DetailBrief;
    //        aItem.content = _detail.dealInfo;
    //        [_detailArray addObject:aItem];
    //    }
    
    //    if(_detail.dealInfo && ![_detail.dealInfo isEqualToString:@""])
    //    {
    //        DetailItem *bItem = [[[DetailItem alloc] init] autorelease];
    //        bItem.type = DetailInfo;
    //        bItem.content = _detail.lastMinuteDetail;
    //        [_detailArray addObject:bItem];
    //    }
    
    //    if(_detail.useIf && ![_detail.useIf isEqualToString:@""])
    //    {
    //        DetailItem *cItem = [[[DetailItem alloc] init] autorelease];
    //        cItem.type = DetailCondition;
    //        cItem.content = _detail.useIf;
    //        [_detailArray addObject:cItem];
    //    }
    
    //    if(_detail.detailThumbnailArray && [_detail.detailThumbnailArray count] != 0)
    //    {
    //        DetailItem *dItem = [[[DetailItem alloc] init] autorelease];
    //        dItem.type = DetailImage;
    //        dItem.imageArray = _detail.detailThumbnailArray;
    //        [_detailArray addObject:dItem];
    //    }
    
    //    if(_detail.relatedArray && [_detail.relatedArray count] != 0)
    //    {
    //        DetailItem *eItem = [[[DetailItem alloc] init] autorelease];
    //        eItem.type = DetailRelation;
    //        eItem.relationArray = _detail.relatedArray;
    //        [_detailArray addObject:eItem];
    //    }
    
    //    [_relatedArray removeAllObjects];
    //    [_relatedArray addObjectsFromArray:_detail.relatedArray];
    
    //    [_tableView reloadData];
    
    //    _tableView.tableFooterView = _tableFooterView;
}

#pragma mark - super

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        //        _panEnable = YES;//do it later
        
        //        _detailArray = [[NSMutableArray alloc] initWithCapacity:0];
        //        _relatedArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

- (void)dealloc
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
    
    QY_SAFE_RELEASE(_source);
    
    QY_SAFE_RELEASE(_shareTitle);
    QY_VIEW_RELEASE(_lmTimeLabel);
    QY_VIEW_RELEASE(_lmBookButton);
    QY_SAFE_RELEASE(_detail);
    //    QY_SAFE_RELEASE(_orderInfo);
    
    QY_VIEW_RELEASE(_collectButton);
    QY_VIEW_RELEASE(_cancelCollectButton);
    
    QY_VIEW_RELEASE(_mainWebView);
    
    QY_VIEW_RELEASE(_styleEmptyContentView);
    QY_VIEW_RELEASE(_styleNormalContentView);
    QY_VIEW_RELEASE(_styleNormalNotStartContentView);
    QY_VIEW_RELEASE(_styleNotStartContentView);
    QY_VIEW_RELEASE(_styleStartingContentView);
    QY_VIEW_RELEASE(_styleFinishContentView);
    QY_VIEW_RELEASE(_styleSellOutContentView);
    
    //    QY_VIEW_RELEASE(_functionFillOrderView);
    
    //    QY_VIEW_RELEASE(_styleNotStartTipLabel);
    //    QY_VIEW_RELEASE(_styleStartingTipLabel);
    
    //    //未开始
    //    QY_VIEW_RELEASE(_styleNotStartTipDaysLabel);//天
    //    QY_VIEW_RELEASE(_styleNotStartTipHoursLabel);//小时
    //    QY_VIEW_RELEASE(_styleNotStartTipMinutesLabel);//分
    //    QY_VIEW_RELEASE(_styleNotStartTipSecondsLabel);//秒
    //
    //    //未开始
    //    QY_VIEW_RELEASE(_styleNotStartDaysLabel);//天
    //    QY_VIEW_RELEASE(_styleNotStartHoursLabel);//小时
    //    QY_VIEW_RELEASE(_styleNotStartMinutesLabel);//分
    //    QY_VIEW_RELEASE(_styleNotStartSecondsLabel);//秒
    
    QY_VIEW_RELEASE(_timeTableContentView);
    
    //已开始
    QY_VIEW_RELEASE(_styleStartingTipDaysLabel);//天
    QY_VIEW_RELEASE(_styleStartingTipHoursLabel);//小时
    QY_VIEW_RELEASE(_styleStartingTipMinutesLabel);//分
    QY_VIEW_RELEASE(_styleStartingTipSecondsLabel);//秒
    
    //已开始
    QY_VIEW_RELEASE(_styleStartingDaysLabel);//天
    QY_VIEW_RELEASE(_styleStartingHoursLabel);//小时
    QY_VIEW_RELEASE(_styleStartingMinutesLabel);//分
    QY_VIEW_RELEASE(_styleStartingSecondsLabel);//秒
    
    
    
    //    QY_VIEW_RELEASE(_shareButton);
    //    QY_VIEW_RELEASE(_tableView);
    //    QY_VIEW_RELEASE(_tableHeaderView);
    //    QY_VIEW_RELEASE(_tableFooterView);
    //    QY_VIEW_RELEASE(_lmTitleLabel);
    //    QY_VIEW_RELEASE(_lmImageView);
    //    QY_VIEW_RELEASE(_lmImageMask);
    //    QY_VIEW_RELEASE(_qyerOnlyImageView);
    //    QY_VIEW_RELEASE(_qyerFirstImageView);
    //    QY_VIEW_RELEASE(_iconTime);
    //    QY_VIEW_RELEASE(_lineImageView);
    //    QY_VIEW_RELEASE(_iconPrice);
    
    //    QY_VIEW_RELEASE(_prefixLabel);
    //    QY_VIEW_RELEASE(_priceLabel);
    //    QY_VIEW_RELEASE(_suffixLabel);
    //    QY_VIEW_RELEASE(_lmDiscountLabel);
    //    QY_VIEW_RELEASE(_codeLabel);
    
    //    QY_SAFE_RELEASE(_detailArray);
    //    QY_SAFE_RELEASE(_relatedArray);
    //    QY_SAFE_RELEASE(_lastMinute);
    
    //    QY_SAFE_RELEASE(_lastMinuteTitle);
    
    [super dealloc];
}

//- (void)loadView
//{
//    [super loadView];
//
//
//}

//请求折扣详情数据
- (void)requestForLastMinuteDetail{
    
    [self.view makeToastActivity];
    [LastMinuteDetail getLastMinuteDetailWithId:_lastMinuteId
                                         source:_source
                                        success:^(NSArray *data) {
                                            
                                            [self.view hideToastActivity];
                                            
                                            if([data isKindOfClass:[NSArray class]] && [data count] > 0)
                                            {
                                                
                                                self.detail = [data objectAtIndex:0];
                                                [self reloadData];
                                            }else{
                                                [self.view hideToast];
                                                [self.view makeToast:Toast_Loading_Fail duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
                                                
                                            }
                                            
                                        } failure:^{
                                            
                                            [self.view hideToastActivity];
                                            
                                            [self.view hideToast];
                                            [self.view makeToast:Toast_Loading_Fail duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
                                            
                                        }];
    
    
}

////请求折扣预订信息
//- (void)requestForOrderInfo{
//
////    [self.view makeToastActivity];
//    [LastMinuteOrderInfo getLastMinuteOrderInfoWithId:_lastMinuteId
//                                              success:^(NSArray *data) {
//
////                                              [self.view hideToastActivity];
//
//                                                  if([data isKindOfClass:[NSArray class]] && [data count] > 0)
//                                                  {
//
//                                                      self.orderInfo = [data objectAtIndex:0];
////                                                      [self reloadData];
//
//                                                      [_functionFillOrderView refreshDataWithOrderInfo:self.orderInfo];
//
//                                                  }
//
//                                                } failure:^(NSError *error) {
//
////                                                  [self.view hideToastActivity];
//
//                                                }];
//
//
//
//}

//config bottom view
- (void)drawBottomView
{
    
    //空白   ------------------------------------------------------------------------------------------
    _styleEmptyContentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, 320, 60)];
    _styleEmptyContentView.backgroundColor = [UIColor clearColor];
    _styleEmptyContentView.image = [UIImage imageNamed:ImageName_Bottom];//x
    _styleEmptyContentView.userInteractionEnabled = YES;
    [self.view addSubview:_styleEmptyContentView];
    
    //不能进行购买  ------------------------------------------------------------------------------------------
    _styleNormalContentView = [[UIImageView alloc] initWithFrame:_styleEmptyContentView.frame];
    _styleNormalContentView.backgroundColor = [UIColor clearColor];
    _styleNormalContentView.image = [UIImage imageNamed:ImageName_Bottom];//x
    _styleNormalContentView.userInteractionEnabled = YES;
    [self.view addSubview:_styleNormalContentView];
    _styleNormalContentView.hidden = YES;
    
    
    //    //2014.03.31结束
    //    UILabel *limitTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 165, 60)];
    //    limitTimeLabel.text = @"2014.03.31结束";
    //    limitTimeLabel.backgroundColor = [UIColor clearColor];
    //    limitTimeLabel.textColor = [UIColor blackColor];
    //    limitTimeLabel.font = [UIFont systemFontOfSize:12.0f];
    //    [_styleNormalContentView addSubview:limitTimeLabel];
    //    [limitTimeLabel release];
    
    //不能进行购买  2014.03.31结束
    _lmTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 165, 60)];
    _lmTimeLabel.text = @"2014.03.31结束";
    _lmTimeLabel.backgroundColor = [UIColor clearColor];
    _lmTimeLabel.textColor = [UIColor blackColor];
    _lmTimeLabel.font = [UIFont systemFontOfSize:12.0f];
    [_styleNormalContentView addSubview:_lmTimeLabel];
    
    
    
    
    //不能进行购买 Not Start ------------------------------------------------------------------------------------------
    _styleNormalNotStartContentView = [[UIImageView alloc] initWithFrame:_styleEmptyContentView.frame];
    _styleNormalNotStartContentView.backgroundColor = [UIColor clearColor];
    _styleNormalNotStartContentView.image = [UIImage imageNamed:ImageName_Bottom];//x
    _styleNormalNotStartContentView.userInteractionEnabled = YES;
    [self.view addSubview:_styleNormalNotStartContentView];
    _styleNormalNotStartContentView.hidden = YES;
    
    
    //已开始  离折扣结束还有
    UILabel *normalNotStartTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 16+1, 159, 14)];
    normalNotStartTipLabel.text = @"离折扣结束还有";
    normalNotStartTipLabel.font = [UIFont systemFontOfSize:12];
    normalNotStartTipLabel.textColor = [UIColor blackColor];
    normalNotStartTipLabel.backgroundColor = [UIColor clearColor];
    [_styleNormalNotStartContentView addSubview:normalNotStartTipLabel];
    [normalNotStartTipLabel release];
    
    
    
    //未开始  ------------------------------------------------------------------------------------------
    _styleNotStartContentView = [[UIImageView alloc] initWithFrame:_styleEmptyContentView.frame];
    _styleNotStartContentView.backgroundColor = [UIColor clearColor];
    _styleNotStartContentView.image = [UIImage imageNamed:ImageName_Bottom];//x
    _styleNotStartContentView.userInteractionEnabled = YES;
    [self.view addSubview:_styleNotStartContentView];
    _styleNotStartContentView.hidden = YES;
    
    //未开始  离折扣开始还有
    UILabel *notStartTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 16+1, 159, 14)];
    notStartTipLabel.text = @"离折扣开始还有";
    notStartTipLabel.font = [UIFont systemFontOfSize:12];
    notStartTipLabel.textColor = [UIColor blackColor];
    notStartTipLabel.backgroundColor = [UIColor clearColor];
    [_styleNotStartContentView addSubview:notStartTipLabel];
    [notStartTipLabel release];
    
    //未开始 1天23小时57秒
    //    _styleNotStartTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 166, 14)];
    //    _styleNotStartTipLabel.text = @"1天23小时57秒";
    //    _styleNotStartTipLabel.font = [UIFont systemFontOfSize:12];
    //    _styleNotStartTipLabel.textColor = [UIColor blackColor];
    //    _styleNotStartTipLabel.backgroundColor = [UIColor clearColor];
    //    [_styleNotStartContentView addSubview:_styleNotStartTipLabel];
    
    
    //drawTimeTable
    
    //未开始  折扣开始时提前通知我
    UIButton *notStartRemindButton = [[UIButton alloc] initWithFrame:CGRectMake(196, 17, 114, 33)];
    [notStartRemindButton setTitle:@"提前通知我" forState:UIControlStateNormal];
    notStartRemindButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [notStartRemindButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [notStartRemindButton setBackgroundImage:Image_MyOrder_Green forState:UIControlStateNormal];
    [notStartRemindButton setBackgroundImage:Image_MyOrder_Green_Highlighted forState:UIControlStateHighlighted];
    [notStartRemindButton addTarget:self action:@selector(notStartRemindButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_styleNotStartContentView addSubview:notStartRemindButton];
    [notStartRemindButton release];
    
    
    
    //已开始  ------------------------------------------------------------------------------------------
    _styleStartingContentView = [[UIImageView alloc] initWithFrame:_styleEmptyContentView.frame];
    _styleStartingContentView.backgroundColor = [UIColor clearColor];
    _styleStartingContentView.image = [UIImage imageNamed:ImageName_Bottom];//x
    _styleStartingContentView.userInteractionEnabled = YES;
    [self.view addSubview:_styleStartingContentView];
    _styleStartingContentView.hidden = YES;
    
    //已开始  离折扣结束还有
    UILabel *startingTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 16+1, 159, 14)];
    startingTipLabel.text = @"离折扣结束还有";
    startingTipLabel.font = [UIFont systemFontOfSize:12];
    startingTipLabel.textColor = [UIColor blackColor];
    startingTipLabel.backgroundColor = [UIColor clearColor];
    [_styleStartingContentView addSubview:startingTipLabel];
    [startingTipLabel release];
    
    //已开始  1天23小时57秒
    //    _styleStartingTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 166, 14)];
    //    _styleStartingTipLabel.text = @"1天23小时57秒";
    //    _styleStartingTipLabel.font = [UIFont systemFontOfSize:12];
    //    _styleStartingTipLabel.textColor = [UIColor blackColor];
    //    _styleStartingTipLabel.backgroundColor = [UIColor clearColor];
    //    [_styleStartingContentView addSubview:_styleStartingTipLabel];
    
    
    
    
    //已开始  立即预订
    UIButton *startingRemindButton = [[UIButton alloc] initWithFrame:CGRectMake(176, 17, 134, 33)];
    [startingRemindButton setTitle:@"立即抢购" forState:UIControlStateNormal];
    startingRemindButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [startingRemindButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [startingRemindButton setBackgroundImage:[UIImage imageNamed:@"detail_buy_btn.png"] forState:UIControlStateNormal];
    //    [startingRemindButton setBackgroundImage:[UIImage imageNamed:@"detail_buy_btn_highlighted.png"] forState:UIControlStateHighlighted];
    [startingRemindButton setBackgroundImage:Image_MyOrder_Orange forState:UIControlStateNormal];
    [startingRemindButton setBackgroundImage:Image_MyOrder_Orange_Highlighted forState:UIControlStateHighlighted];
    
    [startingRemindButton addTarget:self action:@selector(startingRemindButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_styleStartingContentView addSubview:startingRemindButton];
    [startingRemindButton release];
    
    
    //已结束 ------------------------------------------------------------------------------------------
    _styleFinishContentView = [[UIImageView alloc] initWithFrame:_styleEmptyContentView.frame];
    _styleFinishContentView.backgroundColor = [UIColor clearColor];
    _styleFinishContentView.image = [UIImage imageNamed:ImageName_Bottom];//x
    _styleFinishContentView.userInteractionEnabled = YES;
    [self.view addSubview:_styleFinishContentView];
    _styleFinishContentView.hidden = YES;
    
    //已结束 label
    //    UILabel *finishLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 4, 95, 60)];
    //    finishLabel.text = @"已结束!";
    //    finishLabel.textColor = [UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    //    finishLabel.font = [UIFont boldSystemFontOfSize:15];
    //    finishLabel.backgroundColor = [UIColor clearColor];
    //    [_styleFinishContentView addSubview:finishLabel];
    //    [finishLabel release];
    
    //已结束logo
    UIImageView *finishImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _styleFinishContentView.frame.size.height-54, 124, 54)];
    finishImageView.image = [UIImage imageNamed:@"x_lastminute_detail_finish.png"];
    [_styleFinishContentView addSubview:finishImageView];
    [finishImageView release];
    
    //已结束 再有类似折扣通知我
    UIButton *finishRemindButton = [[UIButton alloc] initWithFrame:CGRectMake(142, 17, 168, 33)];
    [finishRemindButton setTitle:@"类似折扣提醒我" forState:UIControlStateNormal];
    finishRemindButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [finishRemindButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishRemindButton setBackgroundImage:[UIImage imageNamed:@"x_detail_remind_btn.png"] forState:UIControlStateNormal];
    [finishRemindButton setBackgroundImage:[UIImage imageNamed:@"x_detail_remind_btn_highlighted.png"] forState:UIControlStateHighlighted];
    [finishRemindButton addTarget:self action:@selector(remindButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_styleFinishContentView addSubview:finishRemindButton];
    [finishRemindButton release];
    
    //已售罄 ------------------------------------------------------------------------------------------
    _styleSellOutContentView = [[UIImageView alloc] initWithFrame:_styleEmptyContentView.frame];
    _styleSellOutContentView.backgroundColor = [UIColor clearColor];
    _styleSellOutContentView.image = [UIImage imageNamed:ImageName_Bottom];//x
    _styleSellOutContentView.userInteractionEnabled = YES;
    [self.view addSubview:_styleSellOutContentView];
    _styleSellOutContentView.hidden = YES;
    
    //    //已售罄 label
    //    UILabel *sellOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 4, 95, 60)];
    //    sellOutLabel.text = @"已售罄!";
    //    sellOutLabel.textColor = [UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    //    sellOutLabel.font = [UIFont boldSystemFontOfSize:15];
    //    sellOutLabel.backgroundColor = [UIColor clearColor];
    //    [_styleSellOutContentView addSubview:sellOutLabel];
    //    [sellOutLabel release];
    
    //已售罄logo
    UIImageView *sellOutImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _styleFinishContentView.frame.size.height-54, 124, 54)];
    sellOutImageView.image = [UIImage imageNamed:@"x_lastminute_detail_sellout.png"];
    [_styleSellOutContentView addSubview:sellOutImageView];
    [sellOutImageView release];
    
    //已售罄 再有类似折扣通知我
    UIButton *sellOutRemindButton = [[UIButton alloc] initWithFrame:CGRectMake(142, 17, 168, 33)];
    [sellOutRemindButton setTitle:@"类似折扣提醒我" forState:UIControlStateNormal];
    sellOutRemindButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [sellOutRemindButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sellOutRemindButton setBackgroundImage:[UIImage imageNamed:@"x_detail_remind_btn.png"] forState:UIControlStateNormal];
    [sellOutRemindButton setBackgroundImage:[UIImage imageNamed:@"x_detail_remind_btn_highlighted.png"] forState:UIControlStateHighlighted];
    [sellOutRemindButton addTarget:self action:@selector(remindButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_styleSellOutContentView addSubview:sellOutRemindButton];
    [sellOutRemindButton release];
    
    
    //在线预订按钮
    [self drawlmBookButton];
    
    //drawTimeTable
    [self drawTimeTable];
    
}

//test
//- (void)testButtonClick:(id)sender
//{
//    NSLog(@"-----------test button click-----------");
//
//    [self showFillOrderViewController];
//
//}

//再有类似折扣通知我
- (void)remindButtonClickAction:(id)sender
{
    [MobClick event:@"detailClickBook" label:@"类似折扣提醒我"];
    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue])
    {
        //判断是否显示登陆框
        [self showLoginAlertWithMessage:@"设置通知前需要先登录？"];
        
        return;
    }
    
    //显示 添加提醒 界面
    AddRemindViewController *addRemindVC = [[[AddRemindViewController alloc] init] autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:addRemindVC] autorelease];
    navigationController.navigationBarHidden = YES;
    //    [self presentModalViewController:navigationController animated:YES];
    [self presentViewController:navigationController animated:YES completion:NULL];
    
    
    //显示“我的订单”界面
    //    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Tab_Remind object:nil];
    
}

//立即预订
- (void)startingRemindButtonClickAction:(id)sender
{
    [MobClick event:@"detailClickBook" label:@"立即抢购"];
    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue])
    {
        
        //判断是否显示登陆框
        [self showLoginAlertWithMessage:@"预订该折扣需要先登录？"];
        
        return;
    }
    
    //    [_functionFillOrderView show];弹层
    
    [self showFillOrderViewController];
    
}

//折扣开始时提前通知我
- (void)notStartRemindButtonClickAction:(id)sender
{
    [MobClick event:@"detailClickBook" label:@"提前通知我"];
    
    int timeInterval = [_detail.app_firstpayStartTime intValue]-LocalNotification_Ahead_Minute;
    int nowInterval = [QYTime nowAdjustTimeInterval];//[[NSDate date] timeIntervalSince1970];
    
    
    if (timeInterval-nowInterval<=0) {
        //提示toast
        [self.view hideToast];
        [self.view makeToast:LocalNotification_Body_In_Minutes duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
    }else{
        NSTimeInterval adjustTimeInterval = [QYTime adjustTimeInterval:timeInterval];
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:adjustTimeInterval];
        
        NSString *key = [NSString stringWithFormat:@"%@%d", LocalNotification_Key_Not_Start, [self.detail.lastMinuteId intValue]];
        NSString *body = [NSString stringWithFormat:LocalNotification_Body_Not_Start];//LocalNotification_Body_Not_Start_Format, self.detail.lastMinuteTitle];
        
        //设置提醒
        [QYCommonUtil setLocalAppReminderWithDate:startDate body:body key:key repeatInterval:0];
        
        //提示toast
        [self.view hideToast];
        [self.view makeToast:LocalNotification_Body_In_Minutes_Succ duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        
    }
    
}

- (void)drawlmBookButton
{
    //不能进行购买  在线预订
    CGRect frame = _styleEmptyContentView.frame;
    frame.origin.x = 176;
    frame.origin.y = frame.origin.y+17;
    frame.size = CGSizeMake(134, 33);
    
    _lmBookButton = [[UIButton alloc] initWithFrame:frame];//CGRectMake(176, 17, 134, 33)
    [_lmBookButton setTitle:@"在线预订" forState:UIControlStateNormal];
    _lmBookButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [_lmBookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [_lmBookButton setBackgroundImage:[UIImage imageNamed:@"detail_buy_btn.png"] forState:UIControlStateNormal];
    //    [_lmBookButton setBackgroundImage:[UIImage imageNamed:@"detail_buy_btn_highlighted.png"] forState:UIControlStateHighlighted];
    [_lmBookButton setBackgroundImage:Image_MyOrder_Orange forState:UIControlStateNormal];
    [_lmBookButton setBackgroundImage:Image_MyOrder_Orange_Highlighted forState:UIControlStateHighlighted];
    
    [_lmBookButton addTarget:self action:@selector(clickBookButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_lmBookButton];//_styleNormalContentView
    [self.view bringSubviewToFront:_lmBookButton];
    _lmBookButton.hidden = YES;
    
}

//设置底部展示样式
- (void)drawTimeTable
{
    
    CGRect frame = _styleEmptyContentView.frame;
    frame.size.width = 186.0f;
    _timeTableContentView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:_timeTableContentView];
    [self.view bringSubviewToFront:_timeTableContentView];
    _timeTableContentView.hidden = YES;
    
    
    //---------------------------------------------------------------------------
    UIFont *Font_Tip = [UIFont boldSystemFontOfSize:16];
    UIFont *Font_Unit = [UIFont systemFontOfSize:11];
    
    // 天 tip
    _styleStartingTipDaysLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPadding, yPadding, widthTip, 19)];
    _styleStartingTipDaysLabel.text = @"1";
    _styleStartingTipDaysLabel.textAlignment = NSTextAlignmentCenter;
    _styleStartingTipDaysLabel.font = Font_Tip;
    _styleStartingTipDaysLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
    _styleStartingTipDaysLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingTipDaysLabel];
    _styleStartingTipDaysLabel.hidden = YES;
    
    // 小时 tip
    _styleStartingTipHoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(33, yPadding, widthTip, 19)];
    _styleStartingTipHoursLabel.text = @"23";
    _styleStartingTipHoursLabel.textAlignment = NSTextAlignmentCenter;
    _styleStartingTipHoursLabel.font = Font_Tip;
    _styleStartingTipHoursLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
    _styleStartingTipHoursLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingTipHoursLabel];
    _styleStartingTipHoursLabel.hidden = YES;
    
    // 分 tip
    _styleStartingTipMinutesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yPadding, widthTip, 19)];
    _styleStartingTipMinutesLabel.text = @"1";
    _styleStartingTipMinutesLabel.textAlignment = NSTextAlignmentCenter;
    _styleStartingTipMinutesLabel.font = Font_Tip;
    _styleStartingTipMinutesLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
    _styleStartingTipMinutesLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingTipMinutesLabel];
    _styleStartingTipMinutesLabel.hidden = YES;
    
    // 秒 tip
    _styleStartingTipSecondsLabel = [[UILabel alloc] initWithFrame:CGRectMake(82, yPadding, widthTip, 19)];
    _styleStartingTipSecondsLabel.text = @"59";
    _styleStartingTipSecondsLabel.textAlignment = NSTextAlignmentCenter;
    _styleStartingTipSecondsLabel.font = Font_Tip;
    _styleStartingTipSecondsLabel.textColor = [UIColor colorWithRed:34.0/255.0f green:185.0/255.0f blue:119.0/255.0f alpha:1.0f];
    _styleStartingTipSecondsLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingTipSecondsLabel];
    _styleStartingTipSecondsLabel.hidden = YES;
    
    CGFloat yPaddingUnit = 39.0-2;
    
    // 天
    _styleStartingDaysLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, yPaddingUnit, widthUnit, 14)];
    _styleStartingDaysLabel.text = @"天";
    _styleStartingDaysLabel.font = Font_Unit;
    _styleStartingDaysLabel.textColor = [UIColor blackColor];
    _styleStartingDaysLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingDaysLabel];
    _styleStartingDaysLabel.hidden = YES;
    
    // 小时
    _styleStartingHoursLabel = [[UILabel alloc] initWithFrame:CGRectMake(58, yPaddingUnit, widthUnit*2, 14)];
    _styleStartingHoursLabel.text = @"小时";
    _styleStartingHoursLabel.font = Font_Unit;
    _styleStartingHoursLabel.textColor = [UIColor blackColor];
    _styleStartingHoursLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingHoursLabel];
    _styleStartingHoursLabel.hidden = YES;
    
    // 分
    _styleStartingMinutesLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, yPaddingUnit, widthUnit, 14)];
    _styleStartingMinutesLabel.text = @"分";
    _styleStartingMinutesLabel.font = Font_Unit;
    _styleStartingMinutesLabel.textColor = [UIColor blackColor];
    _styleStartingMinutesLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingMinutesLabel];
    _styleStartingMinutesLabel.hidden = YES;
    
    // 秒
    _styleStartingSecondsLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, yPaddingUnit, widthUnit, 14)];
    _styleStartingSecondsLabel.text = @"秒";
    _styleStartingSecondsLabel.font = Font_Unit;
    _styleStartingSecondsLabel.textColor = [UIColor blackColor];
    _styleStartingSecondsLabel.backgroundColor = [UIColor clearColor];
    [_timeTableContentView addSubview:_styleStartingSecondsLabel];
    _styleStartingSecondsLabel.hidden = YES;
    
}


//设置底部展示样式
- (void)showBottomViewWithBottomStyle:(BottomStyle)aBottomStyle
{
    
    _bottomStyle = aBottomStyle;
    
    if (aBottomStyle ==  BottomStyleNormal) {//不能进行购买
        
        _styleNormalContentView.hidden = NO;
        _styleNormalNotStartContentView.hidden = YES;
        _styleNotStartContentView.hidden = YES;
        _styleStartingContentView.hidden = YES;
        _styleFinishContentView.hidden = YES;
        _styleSellOutContentView.hidden = YES;
        //显示“在线预订”按钮
        _lmBookButton.hidden = NO;
        //隐藏 倒计时
        _timeTableContentView.hidden = YES;
        
    }if (aBottomStyle ==  BottomStyleNormalNotStart) {//不能进行购买
        
        _styleNormalContentView.hidden = YES;
        _styleNormalNotStartContentView.hidden = NO;
        _styleNotStartContentView.hidden = YES;
        _styleStartingContentView.hidden = YES;
        _styleFinishContentView.hidden = YES;
        _styleSellOutContentView.hidden = YES;
        //显示“在线预订”按钮
        _lmBookButton.hidden = NO;
        //显示 倒计时
        _timeTableContentView.hidden = NO;
        
    }else if (aBottomStyle == BottomStyleNotStart){//未开始
        
        _styleNormalContentView.hidden = YES;
        _styleNormalNotStartContentView.hidden = YES;
        _styleNotStartContentView.hidden = NO;
        _styleStartingContentView.hidden = YES;
        _styleFinishContentView.hidden = YES;
        _styleSellOutContentView.hidden = YES;
        //隐藏 “在线预订”按钮
        _lmBookButton.hidden = YES;
        //显示 倒计时
        _timeTableContentView.hidden = NO;
        
    }else if (aBottomStyle == BottomStyleStarting){//已开始
        
        _styleNormalContentView.hidden = YES;
        _styleNormalNotStartContentView.hidden = YES;
        _styleNotStartContentView.hidden = YES;
        _styleStartingContentView.hidden = NO;
        _styleFinishContentView.hidden = YES;
        _styleSellOutContentView.hidden = YES;
        //隐藏 “在线预订”按钮
        _lmBookButton.hidden = YES;
        //显示 倒计时
        _timeTableContentView.hidden = NO;
        
    }else if (aBottomStyle == BottomStyleFinish){//已结束
        
        _styleNormalContentView.hidden = YES;
        _styleNormalNotStartContentView.hidden = YES;
        _styleNotStartContentView.hidden = YES;
        _styleStartingContentView.hidden = YES;
        _styleFinishContentView.hidden = NO;
        _styleSellOutContentView.hidden = YES;
        //隐藏 “在线预订”按钮
        _lmBookButton.hidden = YES;
        //隐藏 倒计时
        _timeTableContentView.hidden = YES;
        
    }else if (aBottomStyle == BottomStyleSellOut){//已售罄
        
        _styleNormalContentView.hidden = YES;
        _styleNormalNotStartContentView.hidden = YES;
        _styleNotStartContentView.hidden = YES;
        _styleStartingContentView.hidden = YES;
        _styleFinishContentView.hidden = YES;
        _styleSellOutContentView.hidden = NO;
        //隐藏 “在线预订”按钮
        _lmBookButton.hidden = YES;
        //隐藏 倒计时
        _timeTableContentView.hidden = YES;
        
        
    }
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:229.0 / 255.0 green:229.0 / 255.0 blue:229.0 / 255.0 alpha:1.0];//[UIColor colorWithRed:240.0 / 255.0 green:240.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];
    
    _titleLabel.text = @"折扣详情";
    
    
    //    //test
    //    UIButton *testButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 0, 50, 35)];
    //    [testButton addTarget:self action:@selector(testButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //    [testButton setBackgroundColor:[UIColor redColor]];
    //    [_headView addSubview:testButton];
    //    [testButton release];
    
    
    //navigation 分享按钮
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(self.view.frame.size.width-40-40-10-6, _headView.frame.size.height-2-40, 40, 40);
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"x_nav_btn_share.png"] forState:UIControlStateNormal];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"x_nav_btn_share_highlighted.png"] forState:UIControlStateHighlighted];
    [shareButton addTarget:self action:@selector(clickShareButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:shareButton];
    
    //navigation 收藏按钮
    self.collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.collectButton.frame = CGRectMake(self.view.frame.size.width-40-6, _headView.frame.size.height-2-40, 40, 40);
    self.collectButton.backgroundColor = [UIColor clearColor];
    [self.collectButton setBackgroundImage:[UIImage imageNamed:@"x_nav_btn_like.png"] forState:UIControlStateNormal];
    [self.collectButton setBackgroundImage:[UIImage imageNamed:@"x_nav_btn_like_highlighted.png"] forState:UIControlStateHighlighted];
    [self.collectButton addTarget:self action:@selector(clickCollectButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:self.collectButton];
    
    //navigation 取消收藏按钮
    self.cancelCollectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelCollectButton.frame = self.collectButton.frame;
    self.cancelCollectButton.backgroundColor = [UIColor clearColor];
    [self.cancelCollectButton setBackgroundImage:[UIImage imageNamed:@"x_nav_btn_liked.png"] forState:UIControlStateNormal];
    [self.cancelCollectButton setBackgroundImage:[UIImage imageNamed:@"x_nav_btn_liked_highlighted.png"] forState:UIControlStateHighlighted];
    [self.cancelCollectButton addTarget:self action:@selector(clickCancelCollectButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:self.cancelCollectButton];
    self.cancelCollectButton.hidden = YES;
    
    
    //mainWebView
    _mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, 320, self.view.frame.size.height-_headView.frame.size.height- 60 + 6)];
    _mainWebView.backgroundColor = [UIColor clearColor];
    _mainWebView.scalesPageToFit = YES;
    _mainWebView.delegate = self;
    [self.view addSubview:_mainWebView];
    
    //config bottom view
    [self drawBottomView];
    [self showBottomViewWithBottomStyle:BottomStyleEmpty];
    
    //预订信息界面
    //    if (!_functionFillOrderView) {
    //        _functionFillOrderView = [[FunctionFillOrderView alloc] init];
    //        _functionFillOrderView.delegate = self;
    //    }
    
    
    
    
    
    //    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _adjustView.frame.size.height, 320, self.view.frame.size.height - _adjustView.frame.size.height - 50) style:UITableViewStylePlain];
    //    _tableView.backgroundColor = [UIColor clearColor];
    //    _tableView.separatorColor = [UIColor clearColor];
    //    _tableView.delegate = self;
    //    _tableView.dataSource = self;
    //    _tableView.bounces = NO;
    //    [self.view addSubview:_tableView];
    
    //    CGSize titleSize = [_lastMinuteTitle sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:CGSizeMake(304, 200) lineBreakMode:NSLineBreakByWordWrapping];
    //    CGFloat height = titleSize.height;
    //    if (height < 20)
    //    {
    //        height = 20;
    //    }
    
    //    _tableHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 157 + height - 20)];
    //    _tableHeaderView.backgroundColor = [UIColor clearColor];
    //    _tableHeaderView.image = [UIImage imageNamed:@"bg_detail_top.png"];
    //    _tableHeaderView.userInteractionEnabled = YES;
    //    _tableView.tableHeaderView = _tableHeaderView;
    
    //    _lmTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 14, 304, 20 + height - 20)];
    //    _lmTitleLabel.backgroundColor = [UIColor clearColor];
    //    _lmTitleLabel.textColor = [UIColor blackColor];
    //    _lmTitleLabel.text = _lastMinuteTitle;
    //    _lmTitleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    //    _lmTitleLabel.numberOfLines = 0;
    //    [_tableHeaderView addSubview:_lmTitleLabel];
    
    //    _lmImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8 + 3.5, 40 + 3.5 + height - 20, 144, 96)];
    //    _lmImageView.backgroundColor = [UIColor clearColor];
    //    [_tableHeaderView addSubview:_lmImageView];
    
    //    _lmImageMask = [[UIImageView alloc] initWithFrame:CGRectMake(8, 40 + height - 20, 151, 103)];
    //    _lmImageMask.backgroundColor = [UIColor clearColor];
    //    _lmImageMask.image = [UIImage imageNamed:@"detail_image_mask.png"];
    //    [_tableHeaderView addSubview:_lmImageMask];
    
    //    _qyerOnlyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 41 + height - 20, 43, 43)];
    //    _qyerOnlyImageView.backgroundColor = [UIColor clearColor];
    //    _qyerOnlyImageView.image = [UIImage imageNamed:@"icon_only.png"];
    //    _qyerOnlyImageView.hidden = YES;
    //    [_tableHeaderView addSubview:_qyerOnlyImageView];
    
    //    _qyerFirstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 41 + height - 20, 43, 43)];
    //    _qyerFirstImageView.backgroundColor = [UIColor clearColor];
    //    _qyerFirstImageView.image = [UIImage imageNamed:@"icon_first.png"];
    //    _qyerFirstImageView.hidden = YES;
    //    [_tableHeaderView addSubview:_qyerFirstImageView];
    
    //    _iconTime = [[UIImageView alloc] initWithFrame:CGRectMake(172, 75 + height - 20, 12, 12)];
    //    _iconTime.backgroundColor = [UIColor clearColor];
    //    _iconTime.image = [UIImage imageNamed:@"icon_time.png"];
    //    [_tableHeaderView addSubview:_iconTime];
    
    //    _lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(172, 68 + height - 20, 131, 1)];
    //    _lineImageView.backgroundColor = [UIColor clearColor];
    //    _lineImageView.image = [UIImage imageNamed:@"detail_line.png"];
    //    [_tableHeaderView addSubview:_lineImageView];
    
    //    _iconPrice = [[UIImageView alloc] initWithFrame:CGRectMake(172, 44 + height - 20, 12, 12)];
    //    _iconPrice.backgroundColor = [UIColor clearColor];
    //    _iconPrice.image = [UIImage imageNamed:@"icon_price"];
    //    [_tableHeaderView addSubview:_iconPrice];
    
    //    _lmTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 75 + height - 20, 108, 13)];
    //    _lmTimeLabel.backgroundColor = [UIColor clearColor];
    //    _lmTimeLabel.textColor = [UIColor colorWithRed:100.0 / 255.0 green:100.0 / 255.0 blue:100.0 / 255.0 alpha:1.0];
    //    _lmTimeLabel.font = [UIFont systemFontOfSize:12.0f];
    //    [_tableHeaderView addSubview:_lmTimeLabel];
    
    //    _prefixLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 47 + height - 20, 20, 13)];
    //    _prefixLabel.backgroundColor = [UIColor clearColor];
    //    _prefixLabel.textColor = [UIColor colorWithRed:100.0 / 255.0 green:100.0 / 255.0 blue:100.0 / 255.0 alpha:1.0];
    //    _prefixLabel.font = [UIFont systemFontOfSize:12.0f];
    //    [_tableHeaderView addSubview:_prefixLabel];
    
    //    UIFont *font = [UIFont fontWithName:@"HiraKakuProN-W6" size:21.0];
    //    if(font == nil)
    //    {
    //        font = [UIFont fontWithName:@"HiraKakuProN-W3" size:21.0];
    //    }
    
    //    CGSize fontSize = [@"888" sizeWithFont:font forWidth:200 lineBreakMode:NSLineBreakByWordWrapping];
    
    //    if(ios7)
    //    {
    //        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 62 - fontSize.height + height - 20, 90, fontSize.height)];
    //    }
    //    else
    //    {
    //        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 72 - fontSize.height + height - 20, 90, fontSize.height)];
    //    }
    //    _priceLabel.backgroundColor = [UIColor clearColor];
    
    //    _priceLabel.font = font;
    //    _priceLabel.textColor = [UIColor colorWithRed:242.0 / 255.0 green:100.0 / 255.0 blue:38.0 / 255.0 alpha:1.0];
    //    _priceLabel.text = @"399";
    //    [_tableHeaderView addSubview:_priceLabel];
    
    //    CGSize size = [@"399" sizeWithFont:font forWidth:100 lineBreakMode:NSLineBreakByWordWrapping];
    //    _suffixLabel = [[UILabel alloc] initWithFrame:CGRectMake(_priceLabel.frame.origin.x + size.width + 4, 47 + height - 20, 30, 13)];
    //    _suffixLabel.backgroundColor = [UIColor clearColor];
    //    _suffixLabel.textColor = [UIColor colorWithRed:100.0 / 255.0 green:100.0 / 255.0 blue:100.0 / 255.0 alpha:1.0];
    //    _suffixLabel.font = [UIFont systemFontOfSize:12.0f];
    ////    _suffixLabel.text = @"元起";
    //    [_tableHeaderView addSubview:_suffixLabel];
    
    //    _tableFooterView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 64, 320, 64)];
    //    _tableFooterView.backgroundColor = [UIColor clearColor];
    //    _tableFooterView.image = [UIImage imageNamed:@"bg_detail_bottom.png"];
    //    _tableFooterView.userInteractionEnabled = YES;
    //    [self.view addSubview:_tableFooterView];
    //    _tableFooterView.hidden = YES;
    
    
    //    _collectButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    //    _collectButton.frame = CGRectMake(0, 2, 70, 50);
    //    _collectButton.backgroundColor = [UIColor clearColor];
    //    [_collectButton setBackgroundImage:[UIImage imageNamed:@"btn_collect.png"] forState:UIControlStateNormal];
    //    [_collectButton setBackgroundImage:[UIImage imageNamed:@"btn_collect_highlight.png"] forState:UIControlStateHighlighted];
    //    [_collectButton addTarget:self action:@selector(clickCollectButton:) forControlEvents:UIControlEventTouchUpInside];
    //    [_tableFooterView addSubview:_collectButton];
    
    //    _cancelCollectButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    //    _cancelCollectButton.frame = CGRectMake(0, 2, 70, 50);
    //    _cancelCollectButton.backgroundColor = [UIColor clearColor];
    //    [_cancelCollectButton setBackgroundImage:[UIImage imageNamed:@"btn_collected.png"] forState:UIControlStateNormal];
    //    [_cancelCollectButton setBackgroundImage:[UIImage imageNamed:@"btn_collected_highlight.png"] forState:UIControlStateHighlighted];
    //    [_cancelCollectButton addTarget:self action:@selector(clickCancelCollectButton:) forControlEvents:UIControlEventTouchUpInside];
    //    [_tableFooterView addSubview:_cancelCollectButton];
    //    _cancelCollectButton.hidden = YES;
    
    //    _shareButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    //    _shareButton.frame = CGRectMake(70, 2, 70, 50);
    //    _shareButton.backgroundColor = [UIColor clearColor];
    ////    [_shareButton setTitle:@"分享" forState:UIControlStateNormal];
    ////    [_shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    ////    [_shareButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 18, 0, 0)];
    ////    _shareButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    ////    _shareButton.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    ////    _shareButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    //    [_shareButton setAdjustsImageWhenHighlighted:NO];
    //    [_shareButton setBackgroundImage:[UIImage imageNamed:@"btn_share.png"] forState:UIControlStateNormal];
    //    [_shareButton setBackgroundImage:[UIImage imageNamed:@"btn_share_detail_highlight.png"] forState:UIControlStateHighlighted];
    //    [_shareButton addTarget:self action:@selector(clickShareButton:) forControlEvents:UIControlEventTouchUpInside];
    //    [_tableFooterView addSubview:_shareButton];
    
    
    //    if(_lastMinute != nil)
    //    {
    //        [self.view makeToastActivity];
    //
    //        [LastMinuteDetail getLastMinuteDetailWithId:[_lastMinute.lastMinuteId intValue]
    //                                            success:^(NSArray *data) {
    //
    //                                                [self.view hideToastActivity];
    //
    //                                                if([data isKindOfClass:[NSArray class]] && [data count] > 0)
    //                                                {
    //                                                    if(_detail != nil)
    //                                                    {
    //                                                        QY_SAFE_RELEASE(_detail);
    //                                                    }
    //
    //                                                    _detail = [[data objectAtIndex:0] copy];
    //                                                    [self refresh];
    //                                                }
    //
    //                                            } failure:^(NSError *error) {
    //
    //                                                [self.view hideToastActivity];
    //
    //                                            }];
    //
    ////        [self refreshWithShortInfo];
    //    }
    //    else
    //    {
    //        [self.view makeToastActivity];
    //
    //        [LastMinuteDetail getLastMinuteDetailWithId:_lastMinuteId
    //                                            success:^(NSArray *data) {
    //
    //                                                [self.view hideToastActivity];
    //
    //                                                if([data isKindOfClass:[NSArray class]] && [data count] > 0)
    //                                                {
    //                                                    if(_detail != nil)
    //                                                    {
    //                                                        QY_SAFE_RELEASE(_detail);
    //                                                    }
    //
    //                                                    _detail = [[data objectAtIndex:0] copy];
    //                                                    [self refresh];
    //                                                }
    //
    //                                            } failure:^(NSError *error) {
    //
    //                                                [self.view hideToastActivity];
    //
    //                                            }];
    //    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //各页面进入折扣详情 统计
    [MobClick event:@"listClickDeal"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceed:) name:@"LastMinuteUserLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerSucceed:) name:@"REGISTER_SUCCESS" object:nil];
    
    //App 从后台进入前端
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDate) name:@"Notification_AppWillEnterForeground" object:nil];
    
    
    
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];

//    _codeLabel.hidden = YES;
////    _lmDiscountLabel.hidden = YES;
//    if([[NSUserDefaults standardUserDefaults] boolForKey:@"qyerlogin"])
//    {
//        if(_detail && [_detail.loginVisibleFlag intValue])
//        {
//            _codeLabel.hidden = NO;
////            _lmDiscountLabel.hidden = NO;
//        }
//    }
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _mainWebView.delegate = self;
    
    //刷新界面数据
    [self refreshView];//如果放在viewDidLoad中会出现界面一片白的情况
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_mainWebView stopLoading];
    _mainWebView.delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.view hideToastActivity];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - UITableViewDataSource

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if(section == 0)
//    {
//        return 8;
//    }
//
//    return 0;
//}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if(section == 0)
//    {
//        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 8)] autorelease];
//        view.backgroundColor = [UIColor clearColor];
//        return view;
//    }
//
//    return nil;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    switch (indexPath.section)
//    {
//        case 0:
//        {
//            DetailItem *item = [_detailArray objectAtIndex:indexPath.row];
//
//            if(item.type == DetailImage)
//            {
//                NSUInteger count = [item.imageArray count];
//
//                NSUInteger row = 0;
//
//                if(count % 3 == 0)
//                {
//                    row = count / 3;
//                }
//                else
//                {
//                    row = count / 3 + 1;
//                }
//
//                if(row > 1)
//                {
//                    return 73 + row * 94 + (row - 1) * 5;
//                }
//                else
//                {
//                    return 73 + row * 94;
//                }
//            }
//            else if(item.type == DetailRelation)
//            {
//                return 47 + [item.relationArray count] * 40;
//            }
//            else
//            {
//                CGSize size = [item.content sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(274, 2000) lineBreakMode:NSLineBreakByWordWrapping];
//
//                if(size.height < 20)
//                {
//                    return 89;
//                }
//                else
//                {
//                    return 89 + size.height - 20;
//                }
//            }
//        }
//            break;
//        default:
//        {
//            return 0;
//        }
//    }
//
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    switch (section)
//    {
//        case 0:
//        {
//            return [_detailArray count];
//        }
//            break;
//        default:
//        {
//            return 0;
//        }
//            break;
//    }
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LastMinuteDetailViewControllerIdentifier"];
//    if(cell == nil)
//    {
//        cell = [[[DetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LastMinuteDetailViewControllerIdentifier"] autorelease];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
//
//    DetailItem *item = [_detailArray objectAtIndex:indexPath.row];
//
//    switch (item.type) {
//        case DetailBrief:
//        {
//            cell.iconImageView.image = [UIImage imageNamed:@"icon_brief.png"];
//            cell.titleLabel.text = @"折扣简介";
//            cell.imageArray = nil;
//            cell.relationArray = nil;
//            cell.contentLabel.text = item.content;
//        }
//            break;
//        case DetailInfo:
//        {
//            cell.iconImageView.image = [UIImage imageNamed:@"icon_info.png"];
//            cell.titleLabel.text = @"折扣详情";
//            cell.imageArray = nil;
//            cell.relationArray = nil;
//            cell.contentLabel.text = item.content;
//        }
//            break;
//        case DetailCondition:
//        {
//            cell.iconImageView.image = [UIImage imageNamed:@"icon_condition.png"];
//            cell.titleLabel.text = @"小贴士";
//            cell.imageArray = nil;
//            cell.relationArray = nil;
//            cell.contentLabel.text = item.content;
//        }
//            break;
//        case DetailImage:
//        {
//            cell.iconImageView.image = [UIImage imageNamed:@"icon_image.png"];
//            cell.titleLabel.text = @"图片详情";
//            cell.imageArray = item.imageArray;
//            cell.relationArray = nil;
//            cell.contentLabel.text = @"";
//            cell.delegate = self;
//        }
//            break;
//        case DetailRelation:
//        {
//            cell.titleLabel.text = @"相关折扣";
//            cell.imageArray = nil;
//            cell.contentLabel.text = @"";
//            cell.relationArray = item.relationArray;
//            cell.delegate = self;
//        }
//            break;
//        default:
//            break;
//    }
//
//    [cell setItem:[_detailArray objectAtIndex:indexPath.row]];
//
//    return cell;
//}
//
//#pragma mark - UITableViewDelegate
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return nil;
//}

//#pragma mark - DetailCellDelegate
//
//- (void)detailCellImageViewDidClick:(NSUInteger)index
//{
//    NSLog(@"%i", index);
//
//    ImageDetailViewController *imageDetailVC = [[[ImageDetailViewController alloc] init] autorelease];
//    imageDetailVC.imageArray = _detail.detailPictureArray;
//    imageDetailVC.selectedIndex = index;
//    [self presentModalViewController:imageDetailVC animated:YES];
//}

//- (void)relationButtonDidclick:(NSUInteger)buttonIndex
//{
//    [MobClick event:@"detailClickRelatedDeal"];
//
//    NSDictionary *dictionary = [_relatedArray objectAtIndex:buttonIndex];
//    if(dictionary && [dictionary isKindOfClass:[NSDictionary class]])
//    {
//        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
//        CGContextRef contentRef = UIGraphicsGetCurrentContext();
//        [self.view.layer renderInContext:contentRef];
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//
//        LastMinuteDetailViewController *lastMinuteDetailVC = [[[LastMinuteDetailViewController alloc] init] autorelease];
//        [lastMinuteDetailVC setLastMinuteId:[[dictionary objectForKey:@"id"] intValue]];
////        [lastMinuteDetailVC setLastMinuteTitle:[dictionary objectForKey:@"title"]];
//        [lastMinuteDetailVC setPopImage:image];
//        [self.navigationController pushViewController:lastMinuteDetailVC animated:YES];
//    }
//}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
            //        case 17890:
            //        {
            //
            //        }
            //            break;
            //        case 16782:
            //        {
            //
            //        }
            //            break;
            //        case 16652:
            //        {
            //            if(buttonIndex == 0)
            //            {
            //
            //            }
            //            else
            //            {
            //                NSMutableString *phone = [NSMutableString stringWithString:[_detail.orderInfoArray objectAtIndex:0]];
            //
            //                NSMutableString *callNumber = [NSMutableString stringWithCapacity:0];
            //                for(NSUInteger i = 0; i < [phone length]; i++)
            //                {
            //                    NSString *string = [phone substringWithRange:NSMakeRange(i, 1)];
            //                    if([string integerValue] != 0 || [string isEqualToString:@"0"] || [string isEqualToString:@"+"])
            //                    {
            //                        if([string isEqualToString:@"+"])
            //                        {
            //                            if([callNumber rangeOfString:@"+"].length != 0)
            //                            {
            //                                [callNumber insertString:string atIndex:[callNumber length]];
            //                            }
            //                        }
            //                        else
            //                        {
            //                            [callNumber insertString:string atIndex:[callNumber length]];
            //                        }
            //                    }
            //                }
            //
            //                if([callNumber length] == 0)
            //                {
            //                    [callNumber insertString:@"0" atIndex:0];
            //                }
            //
            //                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", callNumber]];
            //                [[UIApplication sharedApplication] openURL:url];
            //            }
            //        }
            //            break;
        case 12537:
        {
            if(buttonIndex == 0)
            {
                
            }
            else
            {
                CityLoginViewController *cityLoginVC = [[CityLoginViewController alloc] init];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cityLoginVC];
                navigationController.navigationBarHidden = YES;
                //                [self presentModalViewController:navigationController animated:YES];
                [self presentViewController:navigationController animated:YES completion:NULL];
                [cityLoginVC release];
                [navigationController release];
                
            }
        }
        default:
            break;
    }
}

//显示WebViewController
- (void)showWebViewControllerWithUrl:(NSString*)aUrl
{
    WebViewViewController *webVC = [[[WebViewViewController alloc] init] autorelease];
    [webVC setStartURL:aUrl];
    webVC.label_title.text = @"在线预订";
    //    webVC.loadingURL = aUrl;
    //        [self.navigationController pushViewController:webVC animated:YES];//old by jessie
    [self presentViewController:webVC animated:YES completion:^{
        
    }];
    
}




#pragma - mark BookViewDelegate

- (void)bookViewButtonDidClicked:(id)sender
{
    [MobClick event:@"bookpopupclick" label:_lmBookButton.titleLabel.text];
    
    if([_detail.orderType intValue] == 0)
    {
        NSString *url = [_detail.orderInfoArray objectAtIndex:[sender tag]];
        NSLog(@"--------------url:%@", url);
        
        if ([QYCommonUtil isLastMinuteDetailWithUrl:url]) {
            
            NSInteger lastMinuteId = [QYCommonUtil getIdFromLastMinuteDetailUrl:url];
            [self showLastMinuteDetailViewControllerWithId:lastMinuteId];
            
        }else{
            [self showWebViewControllerWithUrl:url];
        }
        
    }
    else
    {
        if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"])
        {
            NSMutableString *phone = [NSMutableString stringWithString:[_detail.orderInfoArray objectAtIndex:[sender tag]]];
            
            NSMutableString *callNumber = [NSMutableString stringWithCapacity:0];
            for(NSUInteger i = 0; i < [phone length]; i++)
            {
                NSString *string = [phone substringWithRange:NSMakeRange(i, 1)];
                if([string integerValue] != 0 || [string isEqualToString:@"0"] || [string isEqualToString:@"+"])
                {
                    if([string isEqualToString:@"+"])
                    {
                        if([callNumber rangeOfString:@"+"].length != 0)
                        {
                            [callNumber insertString:string atIndex:[callNumber length]];
                        }
                    }
                    else
                    {
                        [callNumber insertString:string atIndex:[callNumber length]];
                    }
                }
            }
            
            if([callNumber length] == 0)
            {
                [callNumber insertString:@"0" atIndex:0];
            }
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", callNumber]];
            [[UIApplication sharedApplication] openURL:url];
        }
        else
        {
            
            [self.view hideToast];
            [self.view makeToast:@"您的设备不支持拨打电话" duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//@"姓名不能为空"
            
            //            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //            hud.mode = MBProgressHUDModeText;
            //            hud.labelText = @"您的设备不支持拨打电话";
            //            dispatch_time_t popTime;
            //            popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.0 * NSEC_PER_SEC));
            //            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //                [MBProgressHUD hideHUDForView:self.view animated:YES];
            //            });
        }
    }
}

//显示"编辑个人联系人信息"界面
- (void)showEditBuyerInfoViewController
{
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue])
    {
        //判断是否显示登陆框
        [self showLoginAlertWithMessage:@"绑定联系人信息需要先登录？"];
        
        return;
    }
    
    //    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
    //    CGContextRef contentRef = UIGraphicsGetCurrentContext();
    //    [self.view.layer renderInContext:contentRef];
    //    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    
    EditBuyerInfoViewController *editBuyerInfoViewController = [[EditBuyerInfoViewController alloc] init];
    //    [editBuyerInfoViewController setPopImage:image];
    [self.navigationController pushViewController:editBuyerInfoViewController animated:YES];
    [editBuyerInfoViewController release];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //    NSLog(@"------------url:%@", [request.URL absoluteString]);
    //    NSLog(@"--------app-url:%@", _detail.app_url);
    
    //填写联系人信息 跳转到 “确认购买人信息”界面
    NSString *url = [request.URL absoluteString];
    if ([url rangeOfString:@"app_edit_person_info"].length>0) {
        //显示"编辑个人联系人信息"界面
        [self showEditBuyerInfoViewController];
        return NO;
    }
    
    //除了折扣详情h5界面，否则不加载
    if ([url isEqualToString:_detail.app_url]) {
        return YES;
    }else{
        return NO;
    }
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.view makeToastActivity];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.view hideToastActivity];
    
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.view hideToastActivity];
    
    
}

//#pragma mark - FunctionFillOrderViewDelegate
//- (void)FunctionFillOrderViewComfirmButtonClickAction:(id)sender view:(FunctionFillOrderView*)aView
//{
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//
//    NSString *buyerName = [settings objectForKey:Settings_Buyer_Name];
//    NSString *buyerPhone = [settings objectForKey:Settings_Buyer_Phone];
//    NSString *buyerEmail = [settings objectForKey:Settings_Buyer_Email];
//
//
//    if ([buyerName length]==0||[buyerPhone length]==0||[buyerEmail length]==0) {
//        //显示编辑购买人信息界面
//        [self showEditBuyerInfoViewControllerWithFillOrderView:aView];
//
//        return;
//
//    }
//    //显示确认订单界面
//    [self showConfirmOrderFirstViewControllerWithFillOrderView:aView];
//
//}

////修改 click
//- (void)showEditBuyerInfoViewControllerWithFillOrderView:(FunctionFillOrderView*)aView
//{
//    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
//    CGContextRef contentRef = UIGraphicsGetCurrentContext();
//    [self.view.layer renderInContext:contentRef];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    EditBuyerInfoViewController *editBuyerInfoViewController = [[EditBuyerInfoViewController alloc] init];
//    editBuyerInfoViewController.fillOrderView = aView;
//    editBuyerInfoViewController.homeDetailViewController = self;
//    [editBuyerInfoViewController setPopImage:image];
//    [self.navigationController pushViewController:editBuyerInfoViewController animated:YES];
//    [editBuyerInfoViewController release];
//}

//显示提交订单界面
- (void)showFillOrderViewController
{
    
    //    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
    //    CGContextRef contentRef = UIGraphicsGetCurrentContext();
    //    [self.view.layer renderInContext:contentRef];
    //    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    
    FillOrderViewController *fillOrderViewController = [[FillOrderViewController alloc] init];
    fillOrderViewController.lastMinuteId = _lastMinuteId;
    fillOrderViewController.homeDetailViewController = self;
    //    [fillOrderViewController setPopImage:image];
    [self.navigationController pushViewController:fillOrderViewController animated:YES];
    [fillOrderViewController release];
    
    
}

////显示确认订单界面
//- (void)showConfirmOrderFirstViewControllerWithFillOrderView:(FunctionFillOrderView*)aView
//{
//    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
//    CGContextRef contentRef = UIGraphicsGetCurrentContext();
//    [self.view.layer renderInContext:contentRef];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    ConfirmOrderFirstViewController *confirmOrderFirstViewController = [[ConfirmOrderFirstViewController alloc] init];
//    confirmOrderFirstViewController.orderInfo = aView.orderInfo;
//    confirmOrderFirstViewController.homeDetailViewController = self;
//    confirmOrderFirstViewController.selectedProduct = aView.selectedProduct;//[aView.orderInfo.orderInfoProductsArray lastObject];//objectAtIndex:0];
//    [confirmOrderFirstViewController setPopImage:image];
//    [self.navigationController pushViewController:confirmOrderFirstViewController animated:YES];
//    [confirmOrderFirstViewController release];
//
//}


//显示折扣详情界面
- (void)showLastMinuteDetailViewControllerWithId:(NSInteger)aId
{
    //    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
    //    CGContextRef contentRef = UIGraphicsGetCurrentContext();
    //    [self.view.layer renderInContext:contentRef];
    //    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    
    LastMinuteDetailViewControllerNew *lastMinuteDetailVC = [[LastMinuteDetailViewControllerNew alloc] init];
    [lastMinuteDetailVC setLastMinuteId:aId];
    lastMinuteDetailVC.source = NSStringFromClass([self class]);
    //    [lastMinuteDetailVC setLastMinute:lastMinute];
    //    [lastMinuteDetailVC setLastMinuteTitle:lastMinute.lastMinuteTitle];
    //    [lastMinuteDetailVC setPopImage:image];
    
    [self.navigationController pushViewController:lastMinuteDetailVC animated:YES];
    [lastMinuteDetailVC release];
    
    
    
}

//判断是否显示登陆框
- (void)showLoginAlertWithMessage:(NSString*)aMessage
{
    
    [MobClick event:@"detailLoginDialogPopUp"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:aMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 12537;
    [alertView show];
    [alertView release];
    
    
    
}

//刷新数据
- (void)refreshDate
{
    
    if ([self.navigationController.topViewController isKindOfClass:[self class]]) {
        //刷新界面数据
        [self refreshView];
    }
    
    
}


@end
