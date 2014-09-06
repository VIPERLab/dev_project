//
//  loadCDWebViewShellViewController.m
//  QYER
//
//  Created by Qyer on 14-4-10.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "loadCDWebViewShellViewController.h"
#import "QyerSns.h"

#define     positionY_sharebutton       (ios7 ? (2+20) : 2)

static  NSString* strInfo=@"在#穷游APP#里发现了一个有特色的目的地专题，小伙伴们快下来个穷游app吧，有更多精彩目的地等着你的发现哦！戳我戳我--->:http://www.qyer.com/getapp/guide?campaign=app_share_qy&category=iPhone_app";
 
@interface loadCDWebViewShellViewController ()

@end

@implementation loadCDWebViewShellViewController
@synthesize _redicteUrl;
@synthesize _titleLabel;
@synthesize notReachableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTitle:(NSString *)_titleValue
{
    self = [super init];
    if (self) {
        title=_titleValue;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self initHeadView];
    
    
}
-(void)initHeadView
{
    float height_naviViewHeight = (ios7 ? 20+46 : 46);
    UIView * _headView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height_naviViewHeight)] autorelease];
    _headView.backgroundColor = RGB(43, 171, 121);
    [self.view addSubview:_headView];
    
    float positionY_titleLabel = (ios7 ? 23 : 3);
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, positionY_titleLabel, 240, 40)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];

//    _titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//    _titleLabel.shadowOffset = CGSizeMake(0, 1);

    _titleLabel.text=title;
    [_headView addSubview:_titleLabel];
    
    
    [_titleLabel release];
    
    float _positionY_backbutton = ios7 ? 23 : 3;
    UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(0, _positionY_backbutton, 40, 40);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
    cdMianWeb=[[CDVWebRedicteViewController alloc] init];
    ((CDVWebRedicteViewController*)cdMianWeb)._redicteUrl=_redicteUrl;
    CGRect viewBounds = [[UIScreen mainScreen] applicationFrame];
    
    if(!_shareButton)
    {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.frame = CGRectMake(279, positionY_sharebutton, 40, 40);
        [_shareButton setBackgroundImage:[UIImage imageNamed:@"btn_detail_share"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(clickShareButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    [_headView addSubview:_shareButton];
    
    if (ios7) {
        viewBounds.origin.y += 44;
    }else{
        viewBounds.origin.y += 24;
    }
    ((CDVWebRedicteViewController*)cdMianWeb).currentVc=self;
    viewBounds.size.height -= 34;
    cdMianWeb.view.frame = viewBounds;
    
    [self.view addSubview:cdMianWeb.view];
    
   
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)doBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)dealloc{
    [cdMianWeb.navigationController popViewControllerAnimated:NO];
    [_titleLabel release];
    [_redicteUrl release];
    [title release];
    [super dealloc];
}

#pragma mark -
#pragma mark --- clickShareButton
-(void)clickShareButton:(id)sender
{
    [self initActionSheetView];
}

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

#pragma mark -
#pragma mark --- 分享
-(void)shareToMail
{
    [[QyerSns sharedQyerSns] shareToMailWithMailTitle:@"Hi~我发现了一个出境游的APP#穷游#，你也来下载吧！" andMailInfo:@"在#穷游APP#里发现了一个有特色的目的地专题，小伙伴们快来下个穷游app吧，有更多精彩目的地等着你的发现哦！+戳我戳我（http://www.qyer.com/getapp/guide?campaign=app_share_qy&category=iPhone_app）\n\n\t关于出境游，这一切，尽在穷游。\n\t只需免费下载穷游APP，你就进入了穷游的世界，这里不仅有准确的指南和给力的折扣，这里还有由经验丰富的穷游网友所组成的社区，通过问答和发帖，大家可以彼此互助。\n\t从此，你将永远不会独行，伴随你旅行始终的，将是穷游和穷游的几千万新老朋友。\n\t有了穷游APP，你就放心出行吧。\n\t穷游，陪你体验整个世界的精彩。" andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}

-(void)sendmessage
{
    
    [[QyerSns sharedQyerSns] shareWithShortMessage:@"在#穷游APP#里发现了一个有特色的目的地专题，小伙伴们快来下个穷游app吧，有更多精彩目的地等着你的发现哦！点击下载》http://www.qyer.com/getapp/guide?campaign=app_share_qy&category=iPhone_app" inViewController:self];
}

-(void)shareToWeixinFriend
{
    [[QyerSns sharedQyerSns] shareToWeixinWithAPPTitle:@"穷游APP" andDescription:@"在#穷游APP#里发现了个有趣的目的地专题，下载APP还可以看到更多！" andImage:[UIImage imageNamed:@"120icon"] andUrl:@"http://www.qyer.com/getapp/guide?campaign=app_share_qy&category=iPhone_app"];
}

-(void)shareToWeixinFriendCircle
{
    [[QyerSns sharedQyerSns] shareToWeixinFriendCircleWithAPPTitle:@"在#穷游APP#里发现了个有趣的目的地专题，小伙伴们快来下载看全部！" andDescription:@"" andImage:[UIImage imageNamed:@"120icon"] andUrl:@"http://www.qyer.com/getapp/guide?campaign=app_share_qy&category=iPhone_app"];
}

-(void)shareToSinaWeibo
{
    [[QyerSns sharedQyerSns] shareToSinaWeiboWithTitle:@"分享到新浪微博" andText:@"在#穷游APP#里发现了一个有特色的目的地专题，小伙伴们快下来个穷游app吧，有更多精彩目的地等着你的发现哦！戳我戳我--->http://www.qyer.com/getapp/guide?campaign=app_share_qy&category=iPhone_app" andImage:[UIImage imageNamed:@"iphone_sina_sns"] inViewController:self];
}
-(void)shareToTencentWeibo
{
    [[QyerSns sharedQyerSns] shareToTencentWeiboWithText:@"在#穷游APP#里发现了一个有特色的目的地专题，小伙伴们快来下个穷游app吧，有更多精彩目的地等着你的发现哦！+http://www.qyer.com/getapp/guide?campaign=app_share_qy&category=iPhone_app" andImage:[UIImage imageNamed:@"iphone_sina_sns"] andDelegate:self];
}

@end
