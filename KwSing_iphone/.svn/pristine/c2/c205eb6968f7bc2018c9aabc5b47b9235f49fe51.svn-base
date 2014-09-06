//
//  CommentViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-8-29.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "CommentViewController.h"
#include "KSWebView.h"
#include "ImageMgr.h"
#include "globalm.h"
#import <QuartzCore/QuartzCore.h>
#include "CommentDetailViewController.h"
#include "BaseWebViewController.h"
#include "KSAppDelegate.h"
#include "MobClick.h"
#include "User.h"
#include "LoginViewController.h"
#include "MessageManager.h"
#include "IUserStatusObserver.h"
#include "KwUMengElement.h"
#include "UMengLog.h"

#define WEBURL_DISCUSS     @"http://changba.kuwo.cn/kge/webmobile/ios/discuss.html"

@interface CommentViewController ()<UITextViewDelegate,KSWebViewDelegate,IUserStatusObserver>
{
//    UIView *commentView;
//    UITextView *commentTextView;
    KSWebView * webView;
    std::string m_strMusicID;
    std::string m_strSID;
    std::string m_strUserID;
//    bool bTextViewUp;
}
-(void)IUserStatusObserver_LoginFinish:(LOGIN_TYPE) type :(LOGIN_TIME)first;
-(void)IUserStatusObserver_Logout;
@end

@implementation CommentViewController

-(void)SetMusicId:(std::string) musicID subjectID:(std::string)sid UserID:(std::string)userid
{
    m_strMusicID = musicID;
    m_strSID = sid;
    m_strUserID = userid;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        bTextViewUp = false;
    }
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    
    return self;
}

- (void)dealloc{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        [[self view] setFrame:CGRectMake(0,0, 320, [UIScreen mainScreen].bounds.size.height-20)];
    }
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [label_title setText:@"评论"];
    [view_title addSubview:label_title];
    
    UIButton* btn_ret = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_ret.frame = CGRectMake(0, 0, 44, 44);
    [btn_ret setBackgroundColor:[UIColor clearColor]];
    btn_ret.imageEdgeInsets = UIEdgeInsetsMake(10, 14.5, 10, 14.5);
    [btn_ret setImage:CImageMgr::GetImageEx("KgeReturnBtn.png") forState:(UIControlStateNormal)];
    [btn_ret addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view_title addSubview:btn_ret];
    
    UIButton* reportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [reportBtn setTag:1];
    [reportBtn setTitle:@"举报" forState: UIControlStateNormal];
    [[reportBtn titleLabel] setShadowColor:[UIColor blackColor]];
    [[reportBtn titleLabel] setShadowOffset:CGSizeMake(0, 1)];
    [reportBtn setBackgroundImage:CImageMgr::GetImageEx("topReturnBtn_6.png") forState:UIControlStateNormal];
    [reportBtn setBackgroundImage:CImageMgr::GetImageEx("topReturnBtnDown_6.png") forState:UIControlStateHighlighted];
    [reportBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    reportBtn.frame = CGRectMake(260, 9, 47,28);
    [reportBtn addTarget:self action:@selector(ReportBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:reportBtn];
    
    CGRect rc = [self view].bounds;
    CGRect rcnav = self.navigationController.navigationBar.bounds;
    rc = BottomRect(rc,rc.size.height-rcnav.size.height-49,49);
    webView = [[[KSWebView alloc]initWithFrame:rc allowBounce:FALSE useLoading:YES opaque:NO]autorelease];
    NSString *strURL = [NSString stringWithFormat:@"%@?id=%s&sid=%s&uid=%s",WEBURL_DISCUSS,m_strMusicID.c_str(),m_strSID.c_str(),m_strUserID.c_str()];
    [webView loadUrl:strURL];
    [webView setDelegate:self];
    [[self view] addSubview:webView];

    CGRect rcbottom = BottomRect(self.view.bounds,49,0);
    UIView *bottomview  = [[[UIView alloc]initWithFrame: rcbottom]autorelease];
    [[self view] addSubview:bottomview];
    
    UIImageView *bottombkview = [[[UIImageView alloc]initWithImage:CImageMgr::GetImageEx("recordbottombk.png")]autorelease];
    bottombkview.frame = bottomview.bounds;
    [bottomview addSubview:bottombkview];
    
    UIButton* btnComment = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnComment setTitle:@"发表评论" forState: UIControlStateNormal];
    [btnComment setImage:CImageMgr::GetImageEx("KsongReadyBtnNormal_18.png") forState:UIControlStateNormal];
    [btnComment setBackgroundImage:CImageMgr::GetImageEx("KsongReadyBtnDown_18.png") forState:UIControlStateHighlighted];
    btnComment.titleLabel.font = [UIFont systemFontOfSize:16];
    btnComment.frame = CGRectMake(110.5, 8, 99, 35);
    [btnComment addTarget:self action:@selector(CommentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomview addSubview:btnComment];
    [[self view] setBackgroundColor:CImageMgr::GetBackGroundColor()];
    
    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}

#define URL_USERHOME    @"http://changba.kuwo.cn/kge/webmobile/ios/userhome.html"
- (void)webViewRunActionWithParam:(KSWebView*)view action:(NSString*)act parameter:(NSDictionary*)paras
{
    if([act isEqualToString:@"ReplyComment"])
    { 
        NSString* Name = [paras objectForKey:@"name"];
        NSString* uid = [paras objectForKey:@"uid"];
        if(Name!=nil && uid != nil)
        {
            NSString *str = [NSString stringWithFormat:@"回复%@:  ",Name];
            
            CommentDetailViewController * view = [[[CommentDetailViewController alloc]init]autorelease];
            [view SetWebView: webView Text:[str UTF8String] ReplyUID: [uid UTF8String]];
            [self.navigationController pushViewController:view animated:YES];
        }
    }
    else if([act isEqualToString:@"UserPage"])
    {
        NSString* strUserid = [paras objectForKey:@"id"];
        NSString* strName = [paras objectForKey:@"name"];
        if(strUserid != nil)
        {
            BaseWebViewController * temp = [[[BaseWebViewController alloc]init]autorelease];
            temp.title = [NSString stringWithFormat:@"%@的个人主页",strName];
            temp.strUrl = [NSString stringWithFormat:@"%@?=777=%@",URL_USERHOME,strUserid];
            [ROOT_NAVAGATION_CONTROLLER pushViewController:temp animated:YES];

        }
    }

}

-(void) ReturnBtnClick:(id)sender
{
    [webView setDelegate:nil];
    [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];
    [MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}
-(void)ReportBtnClick:(id)sender
{
    [self reportSong];
}
-(void)reportSong
{
    NSLog(@"report song %s",m_strMusicID.c_str());
    UMengLog(KS_BLUE_COMMENT, m_strMusicID);
    UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"感谢您的反馈" message:@"我们回认真处理您的反馈，努力为大家创造一个良好的K歌环境" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] autorelease];
    [alert show];
}
//-(void) SendBtnClick:(id)sender
//{
//    if(![commentTextView.text isEqualToString:@""])
//    {
//        [webView executeJavaScriptFunc: @"onSendComment" parameter:commentTextView.text];
//        commentTextView.text = @"";
//        [commentTextView resignFirstResponder];
//    }
//}


-(void) CommentBtnClick:(id)sender
{
    if(!User::GetUserInstance()->isOnline())
    {
        UIAlertView * loginAlertView = [[[UIAlertView alloc]initWithTitle:@"" message:@"您还未登录，是否要登录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil]autorelease];
        [loginAlertView show];
        return;
    }
    
    //commentView.hidden = false;
    CommentDetailViewController * view = [[[CommentDetailViewController alloc]init]autorelease];
    [view SetWebView:webView Text:"" ReplyUID:""];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:view animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if(buttonIndex == 1)
        {
            KSLoginViewController* loginController=[[[KSLoginViewController alloc] init]autorelease];
            [ROOT_NAVAGATION_CONTROLLER pushViewController:loginController animated:YES];
        }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
//{
//    NSTimeInterval animationDuration=0.30f;
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    float width=commentView.frame.size.width;
//    float height = commentView.frame.size.height;
//    CGRect rect=CGRectMake(0.0f,commentView.frame.origin.y-320,width,height);
//    commentView.frame=rect;
//    CGRect rcText = commentTextView.frame;   
//    //rcText.size.height = 60;
//    commentTextView.frame = rcText;
//    [UIView commitAnimations];
//    return true;
//}
//
//- (BOOL)textViewShouldEndEditing:(UITextView *)textView
//{
//    NSTimeInterval animationDuration=0.30f;
//    [UIView beginAnimations:@"ResizeForKeyboard1" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    float width=commentView.frame.size.width;
//    float height = commentView.frame.size.height;
//    CGRect rect=CGRectMake(0.0f,commentView.frame.origin.y+320,width,height);
//    commentView.frame=rect;
//    CGRect rcText = commentTextView.frame;
//    //rcText.size.height = 45;
//    commentTextView.frame = rcText;
//    [UIView commitAnimations];
//    return  true;
//}

#pragma mark - UITextView Delegate Methods  
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text  
{  
    if ([text isEqualToString:@"\n"]) {  
        [textView resignFirstResponder];  
        return NO;  
    }  
    return YES;  
}  

//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if(commentTextView)
//        [commentTextView resignFirstResponder];
//}

-(void)IUserStatusObserver_LoginFinish:(LOGIN_TYPE) type :(LOGIN_TIME)first
{
    if (type != FAIL_LOGIN && type != REPEAT_LOGIN) {
        [webView reload];
    }

}
-(void)IUserStatusObserver_Logout
{
    [webView reload];
}


@end
