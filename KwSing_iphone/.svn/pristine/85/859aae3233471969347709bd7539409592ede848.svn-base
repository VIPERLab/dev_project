//
//  KSInviteFriendViewController.m
//  KwSing
//
//  Created by 单 永杰 on 13-11-13.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import "KSInviteFriendViewController.h"
#import "KSAppDelegate.h"
#include "ImageMgr.h"
#include "globalm.h"
#include "User.h"
#include "KwTools.h"
#include "MessageManager.h"
#include "IInviteFriendObserver.h"
#include "SBJson.h"
#include "KSHttpRequest.h"

#define TAG_RET_BTN 101
#define TAG_DISTRIBUTE_BTN 102
#define TAG_TEXT_VIEW 103

#define TAG_SUCCESS_ALERT 104
#define TAG_FAIL_ALERT 105

#define URL_INVITE @"http://60.28.200.79:8180/kge/KgeUserBindOper?act=add&"

@interface KSInviteFriendViewController ()<UITextViewDelegate, UIAlertViewDelegate>{
    NSString* strInviteText;
    UIActivityIndicatorView* indicatorView;
    BOOL bInviteSuccess;
    BOOL _isOutOfLimit;
}
@property (retain , nonatomic) UIButton *distributeButton;
@property (retain , nonatomic) UILabel *wordNumLabel;
@end

@implementation KSInviteFriendViewController

@synthesize strNickName = _strNickName;
@synthesize strShareType = _strShareType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)dealloc{
    if (strInviteText) {
        [strInviteText release];
        strInviteText = nil;
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    bInviteSuccess = NO;
    
    [self setTitle:@"邀请用户"];
    
    
    [self.view setBackgroundColor:UIColorFromRGBValue(0xededed)];
    
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [label_title setText:self.title];
    [view_title addSubview:label_title];
    
    UIButton* btn_ret = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_ret.frame = CGRectMake(0, 0, 44, 44);
    [btn_ret setBackgroundColor:[UIColor clearColor]];
    btn_ret.imageEdgeInsets = UIEdgeInsetsMake(10, 14.5, 10, 14.5);
    [btn_ret setTag:TAG_RET_BTN];
    [btn_ret setImage:CImageMgr::GetImageEx("KgeReturnBtn.png") forState:(UIControlStateNormal)];
    [btn_ret addTarget:self action:@selector(ControlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view_title addSubview:btn_ret];
    self.distributeButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [self.distributeButton setTitle:@"发布" forState: UIControlStateNormal];
    [[self.distributeButton titleLabel] setShadowColor:[UIColor blackColor]];
    [[self.distributeButton titleLabel] setShadowOffset:CGSizeMake(0, 1)];
    [self.distributeButton setTag:TAG_DISTRIBUTE_BTN];
    [self.distributeButton setBackgroundImage:CImageMgr::GetImageEx("topReturnBtn_6.png") forState:UIControlStateNormal];
    [self.distributeButton setBackgroundImage:CImageMgr::GetImageEx("topReturnBtnDown_6.png") forState:UIControlStateHighlighted];
    self.distributeButton.titleLabel.font=[UIFont systemFontOfSize:14];
    self.distributeButton.frame = CGRectMake(263, 9, 47,28);
    [self.distributeButton addTarget:self action:@selector(CtrolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:self.distributeButton];
    
    UILabel* promp_label = [[[UILabel alloc] initWithFrame:CGRectMake(60, ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height + 20, 200, 20)] autorelease];
    [promp_label setText:@"您的邀请将会以微博的形式发出"];
    promp_label.Font = [UIFont systemFontOfSize:14];
    [promp_label setTextColor:UIColorFromRGBValue(0x898989)];
    [promp_label setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:promp_label];
    
    UITextView* text_view = [[[UITextView alloc] initWithFrame:CGRectMake(10, ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height + 60, 300, 100)] autorelease];
    [text_view setBackgroundColor:[UIColor whiteColor]];
    [text_view setTextColor:[UIColor blackColor]];
    text_view.text = @"我正在使用酷我K歌iPhone版，很棒哦，快来跟我一起玩吧！";
    text_view.returnKeyType = UIReturnKeyDone;
    text_view.keyboardType = UIKeyboardTypeDefault;
    text_view.scrollEnabled = YES;
    text_view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [text_view setTag:TAG_TEXT_VIEW];
    
    [text_view setDelegate:self];
    
    self.wordNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, ROOT_NAVAGATION_CONTROLLER_BOUNDS.size.height+160, 300, 15)];
    int numLeft = 100 - text_view.text.length;
    [self.wordNumLabel setTextColor:[UIColor blackColor]];
    [self.wordNumLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.wordNumLabel setText:[NSString stringWithFormat:@"还可以输入:%d个字",numLeft]];
    [self.view addSubview:self.wordNumLabel];
    _isOutOfLimit = NO;
    
    indicatorView = [[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)]autorelease];
    [indicatorView setCenter:CGPointMake(160, 100)];
    [[self view]addSubview:indicatorView];
    [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.hidden = true;
    
    [self.view addSubview:text_view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidEndEditing:(UITextView *)textView{
//    [textView resignFirstResponder];
    NSLog(@"finish writing!!!");
    if (strInviteText) {
        [strInviteText release];
        strInviteText = nil;
    }
    strInviteText = [[textView text] retain];
}

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    int numLeft = 100 - textView.text.length;
    if (numLeft > 0) {
        _isOutOfLimit = NO;
        [self.wordNumLabel setText:[NSString stringWithFormat:@"还可以输入:%d个字",numLeft]];
        [self.wordNumLabel setTextColor:[UIColor blackColor]];
    }
    else{
        _isOutOfLimit = YES;
        [self.wordNumLabel setText:[NSString stringWithFormat:@"输入已经超出字数限制啦!"]];
        [self.wordNumLabel setTextColor:[UIColor redColor]];
    }
}
- (void)CtrolBtnClick:(id)sender{
    UIButton* button = (UIButton*)sender;
    if (nil != button) {
        switch (button.tag) {
            case TAG_RET_BTN:{
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            
            case TAG_DISTRIBUTE_BTN:{
                if (_isOutOfLimit) {
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"提示" message:@"字数超出了限制" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] autorelease];
                    [alert show];
                    return;
                }
                [indicatorView startAnimating];
                indicatorView.hidden = NO;
                
                UIButton* ret_btn = (UIButton*)[self.view viewWithTag:TAG_RET_BTN];
                if (ret_btn) {
                    [ret_btn setEnabled:NO];
                }
                UIButton* distribute_btn = (UIButton*)[self.view viewWithTag:TAG_DISTRIBUTE_BTN];
                if (distribute_btn) {
                    [distribute_btn setEnabled:NO];
                }
                NSString* strShareContent = nil;
                UITextView* text_view = (UITextView*)[self.view viewWithTag:TAG_TEXT_VIEW];
                if (nil != text_view) {
                    strShareContent = [NSString stringWithFormat:@"%@%@", KwTools::Encoding::UrlEncode([text_view text]), @"https://itunes.apple.com/cn/app/ku-wok-ge/id594167995?mt=8"];
                }else{
                    return;
                }
                NSString* sharedURL = [NSString stringWithFormat:@"%@&type=%@&uid=%@&sid=%@&content=%@&name=%@",URL_INVITE,  _strShareType, User::GetUserInstance()->getUserId(), User::GetUserInstance()->getSid(), strShareContent, KwTools::Encoding::UrlEncode(_strNickName)];
                
                KS_BLOCK_DECLARE{
//                    BOOL bret = CHttpRequest::QuickSyncGet([sharedURL UTF8String], strOut);
                    NSData* ret_data = [KSHttpRequest SyncRequest:sharedURL];
                    //NSLog(@"share return:%@",[NSString stringWithUTF8String:strOut.c_str()]);
                    //没有对返回结果处理，只是关心我们的请求是否发送成功
                    KS_BLOCK_DECLARE
                    {
                        [indicatorView stopAnimating];
                        indicatorView.hidden = true;
                        
                        if (nil != ret_data) {
                            SBJsonParser *parser=[[SBJsonParser alloc] init];
                            NSDictionary *parserDic=[parser objectWithData:ret_data];
                            [parser release];
                            //NSLog(@"ret dic:%@",[parserDic description]);
                            NSString *retStat=[parserDic objectForKey:@"ret"];
                            
                            if (200 == [retStat integerValue]) {
                                UIAlertView* alert_view = [[[UIAlertView alloc] initWithTitle:nil message:@"发送成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] autorelease];
                                [alert_view setTag:TAG_SUCCESS_ALERT];
                                [alert_view show];
                            }else {
                                UIAlertView* alert_view = [[[UIAlertView alloc] initWithTitle:nil message:@"发送失败，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] autorelease];
                                [alert_view setTag:TAG_FAIL_ALERT];
                                [alert_view show];
                            }
                        }else {
                            UIAlertView* alert_view = [[[UIAlertView alloc] initWithTitle:nil message:@"发送失败，请重试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] autorelease];
                            [alert_view setTag:TAG_FAIL_ALERT];
                            [alert_view show];
                        }
                        
                    }
                    KS_BLOCK_SYNRUN();
                }
                KS_BLOCK_RUN_THREAD()
                
            }
            default:{
                break;
            }
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case TAG_SUCCESS_ALERT:
        {
            bInviteSuccess = YES;
            [self.navigationController popViewControllerAnimated:NO];
            SYN_NOTIFY(OBSERVER_ID_INVITESTATUS, IInviteStateObserver::InviteProcess, INVITE_SUCCESS);
            break;
        }
            
        case TAG_FAIL_ALERT:
        {
            bInviteSuccess = NO;
            UIButton* ret_btn = (UIButton*)[self.view viewWithTag:TAG_RET_BTN];
            if (ret_btn) {
                [ret_btn setEnabled:YES];
            }
            UIButton* distribute_btn = (UIButton*)[self.view viewWithTag:TAG_DISTRIBUTE_BTN];
            if (distribute_btn) {
                [distribute_btn setEnabled:YES];
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)isInviteSuccess{
    return bInviteSuccess;
}

@end
