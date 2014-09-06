//
//  UsefulGuideController.m
//  QYER
//
//  Created by 张伊辉 on 14-3-18.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "UsefulGuideController.h"
#import "WebViewViewController.h"

#import "QyerSns.h"


@interface UsefulGuideController ()

@end

@implementation UsefulGuideController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString *string = nil;
    
    switch (_type) {
        case 1:
            string = @"国家实用指南";
            break;
        case 2:
            string = @"城市实用指南";
            break;
        case 3:
            string = @"城市精选酒店";
            break;
        case 4:
            string = @"推荐行程详情";
            break;
            
        default:
            break;
    }
    [MobClick beginLogPageView:string];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    NSString *string = nil;

    
    switch (_type) {
        case 1:
            string = @"国家实用指南";
            break;
        case 2:
            string = @"城市实用指南";
            break;
        case 3:
            string = @"城市精选酒店";
            break;
        case 4:
            string = @"推荐行程详情";
            break;
            
        default:
            
            break;
    }
    [MobClick endLogPageView:string];
    
    
}
- (void)hideGradientBackground:(UIView*)theView

{
    
    for(UIView* subview in theView.subviews)
        
    {
        
        if([subview isKindOfClass:[UIImageView class]])
            
            subview.hidden = YES;
        [self hideGradientBackground:subview];
        
    }
    
}

-(void)touchesView{
    
    [self requestDataFromServer];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel.text = self.strTitle;
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, UIWidth, UIHeight - height_need_reduce -64)];
    
    if (!ios7) {
        [_webView setFrame:CGRectMake(0
                                      , 44, UIWidth, UIHeight - height_need_reduce -44)];
    }
    
    _webView.backgroundColor = [UIColor clearColor];
    _webView.delegate = self;
    _webView.opaque = NO;
    _webView.scrollView.decelerationRate = 5.0;
    [self.view addSubview:_webView];
    [_webView release];
    
    [self.view sendSubviewToBack:_webView];
    [self hideGradientBackground:_webView];

//    [ChangeTableviewContentInset changeTableView:_webView.scrollView withOffSet:0];
   
    
    if (_type == 4) {
        
        [_rightButton setImage:[UIImage imageNamed:@"btn_detail_share"] forState:UIControlStateNormal];
        _rightButton.enabled = YES;
    }
    
    [self requestDataFromServer];
    
	// Do any additional setup after loading the view.
}
-(void)requestDataFromServer{
    
    if (isNotReachable) {
        
        [super setNotReachableView:YES];
        return;
        
    }else{
        
        [super setNotReachableView:NO];
        [self.view makeToastActivity];
        
        _didLoadWebSuccess = NO;//初始未加载完成

        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10]];
    }
    
}

-(void)clickRightButton:(UIButton *)btn{
    
    [self initActionSheetView];
    
    NSLog(@"点击分享");
}

#pragma mark
#pragma mark webviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if (_type == 3) {
        
        NSURL *url = [request URL];
        NSString *strURL  = [url absoluteString];
        
        NSLog(@"strURL is %@",strURL);
        NSRange range = [strURL rangeOfString:@"alert"];

        if (range.length != 0) {
            
            strURL = [strURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            
            NSString *strAlert;
            NSArray *arr = [strURL componentsSeparatedByString:@"?"];
           
            strAlert = [arr objectAtIndex:1];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:strAlert delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
            
            return NO;
        }
        
        if ([strURL hasPrefix:@"http://appview.qyer.com/"]) {
            
            return YES;
            
        }else{
            
            WebViewViewController *webVC = [[WebViewViewController alloc] init] ;
            [webVC setStartURL:strURL];
            [self presentViewController:[QYToolObject getControllerWithBaseController:webVC] animated:YES completion:nil];
            [webVC release];
            
            return NO;
        }
    }
    
    //为实用贴士页面
    else if (_type == 1 || _type == 2){
        if (_didLoadWebSuccess) {
            return NO;
        }
        else{
            return YES;
        }
    }
    
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    _didLoadWebSuccess = YES;//初始未加载完成
    
    [self.view hideToastActivity];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    
    [super setNotReachableView:YES];
    
    
//    if (isLoadData == YES) {
//        
//        if (_type == 1 || _type == 2) {
//            
//            _notDataImageView.hidden = NO;
//            _notDataImageView.image = [UIImage imageNamed:@"not_uguide"];
//            [self.view bringSubviewToFront:_notDataImageView];
//        }
//    }else{
//        
//        [super setNotReachableView:YES];
//    }
    
   
    [self.view hideToastActivity];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark --- clickShareButton


-(void)initActionSheetView
{
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



#pragma mark -
#pragma mark --- MYActionSheet - Delegate
-(void)cancelButtonDidClick:(MYActionSheet *)actionSheet
{
    
}
-(void)actionSheetButtonDidClickWithType:(NSString*)type
{
    if([type isEqualToString:@"邮件"])
    {
        //[MobClick event:@"setting" label:@"邮件分享"];
        [self shareToMail];
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



-(void)shareToMail
{
    NSLog(@"-------%@------",self.url);
    
    [[QyerSns sharedQyerSns] shareToMailWithMailTitle:[NSString stringWithFormat:@"Hi，我在@穷游网 的#穷游APP#里发现了一个旅行计划【%@】",self.strTitle] andMailInfo:[NSString stringWithFormat:@"Hi~\n\t我在@穷游网 的#穷游APP#里发现了一个旅行计划【%@】：景点美食购物闲逛都包括啦！\n\t非常靠谱的行程，你也来看看吧→_→ %@\n\t关于出境游，这一切，尽在穷游。\n\n只需免费下载穷游APP，你就进入了穷游的世界，这里不仅有准确的指南和给力的折扣，这里还有由经验丰富的穷游网友所组成的社区，通过问答和发帖，大家可以彼此互助。\n\n从此，你将永远不会独行，伴随你旅行始终的，将是穷游和穷游的几千万新老朋友。\n\n有了穷游APP，你就放心出行吧。 穷游，陪你体验整个世界的精彩。\n\n穷游App有iPhone、Android和iPad版本，扫描二维码即可轻松下载！http://www.qyer.com/getapp/guide?campaign=app_share_qy&category=iPhone_plan",self.strTitle,self.url] andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)sendmessage
{
    [[QyerSns sharedQyerSns] shareWithShortMessage:[NSString stringWithFormat:@"Hi，我在@穷游网 的#穷游APP#里发现了一个旅行计划【%@】：景点美食购物闲逛都包括啦！非常靠谱的行程，你也来看看吧→_→ %@",self.strTitle,self.url] inViewController:self];
}

-(void)shareToWeixinFriend
{
    [[QyerSns sharedQyerSns] shareToWeixinWithAPPTitle:@"穷游APP" andDescription:[NSString stringWithFormat:@"我在@穷游网 的#穷游APP#里发现了一个旅行计划【%@】：景点美食购物闲逛都包括啦！非常靠谱的行程，你也来看看吧→_→",self.strTitle] andImage:[UIImage imageNamed:@"120icon"] andUrl:self.url];
}

-(void)shareToWeixinFriendCircle
{
    [[QyerSns sharedQyerSns] shareToWeixinFriendCircleWithAPPTitle:[NSString stringWithFormat:@"我在@穷游网 的#穷游APP#里发现了一个旅行计划【%@】：景点美食购物闲逛都包括啦！非常靠谱的行程，分享给大家！详细行程来这里看→_→",self.strTitle] andDescription:@"" andImage:[UIImage imageNamed:@"120icon"] andUrl:self.url];
}

-(void)shareToSinaWeibo
{
    [[QyerSns sharedQyerSns] shareToSinaWeiboWithTitle:@"分享到新浪微博" andText:[NSString stringWithFormat:@"我在@穷游网 的#穷游APP#里发现了一个旅行计划【%@】：景点美食购物闲逛都包括啦！非常靠谱的行程，分享给大家！详细行程来这里看→_→ %@", self.strTitle,self.url] andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)shareToTencentWeibo
{
    [[QyerSns sharedQyerSns] shareToTencentWeiboWithText:[NSString stringWithFormat:@"我在@穷游网 的#穷游APP#里发现了一个旅行计划【%@】：景点美食购物闲逛都包括啦！非常靠谱的行程，分享给大家！详细行程来这里看→_→ %@",self.strTitle,self.url] andImage:[UIImage imageNamed:@"iphone_sina_sns"] andDelegate:self];
}


-(void)dealloc{
    
    self.strTitle = nil;
    self.url = nil;
    [super dealloc];
}
@end
