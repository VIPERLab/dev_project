//
//  CommentDetailViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-9-24.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "CommentDetailViewController.h"
#include "ImageMgr.h"
#include "globalm.h"
#import <QuartzCore/QuartzCore.h>
#include "KSWebView.h"
#include "KSAppDelegate.h"
#include "MobClick.h"

@interface CommentDetailViewController ()<UITextViewDelegate>
{
    UITextView *commentTextView;
    std::string m_strUserID;
    KSWebView * m_webView;
    std::string m_strText;
    std::string m_strReplyUserID;
}

@end

@implementation CommentDetailViewController

-(void)SetWebView:(KSWebView*)view Text:(std::string)text ReplyUID:(std::string)uid
{
    m_webView = view;
    m_strText = text;
    m_strReplyUserID = uid;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] == NSOrderedSame) {
//        [[self view] setFrame:CGRectMake(0, 20, 320, [UIScreen mainScreen].bounds.size.height-20)];
//    }
//    NSLog(@"self view:%@",[self.view description]);
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [label_title setText:@"新评论"];
    [view_title addSubview:label_title];
    
    UIButton* btn_ret = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_ret.frame = CGRectMake(0, 0, 44, 44);
    [btn_ret setBackgroundColor:[UIColor clearColor]];
    btn_ret.imageEdgeInsets = UIEdgeInsetsMake(10, 14.5, 10, 14.5);
    [btn_ret setImage:CImageMgr::GetImageEx("KgeReturnBtn.png") forState:(UIControlStateNormal)];
    [btn_ret addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view_title addSubview:btn_ret];
    
    UIButton* btnsend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnsend setTitle:@"发送" forState: UIControlStateNormal];
    [btnsend setBackgroundImage:CImageMgr::GetImageEx("topReturnBtn_6.png") forState:UIControlStateNormal];
    [btnsend setBackgroundImage:CImageMgr::GetImageEx("topReturnBtnDown_6.png") forState:UIControlStateHighlighted];
    btnsend.titleLabel.font = [UIFont systemFontOfSize:14];
    btnsend.frame = CGRectMake(self.view.bounds.size.width-10-47, 9, 47,28);
    [btnsend addTarget:self action:@selector(SendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:btnsend];

    CGRect rc = [self view].bounds;
    CGRect rcnav = ROOT_NAVAGATION_CONTROLLER_BOUNDS;
    rc = BottomRect(rc,rc.size.height-rcnav.size.height,0);

    commentTextView = [[[UITextView alloc]initWithFrame:CGRectMake(10,rc.origin.y + 10, rc.size.width - 20, 100)]autorelease];
    commentTextView.Font = [UIFont systemFontOfSize:15];
    [commentTextView setDelegate:self];
    commentTextView.contentInset = UIEdgeInsetsZero; 
    commentTextView.layer.cornerRadius = 6;
    commentTextView.layer.masksToBounds = YES;
    [[self view] addSubview:commentTextView];
    commentTextView.text = [NSString stringWithUTF8String:m_strText.c_str()];
    [commentTextView becomeFirstResponder];
    commentTextView.returnKeyType = UIReturnKeyDefault;
    
    [[self view] setBackgroundColor:CImageMgr::GetBackGroundColor()];
    
    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) SendBtnClick:(id)sender
{
    if(![commentTextView.text isEqualToString:@""])
    {
        NSString *strvalue;
        if(m_strReplyUserID == "")
            strvalue = commentTextView.text;
        else
            strvalue = [NSString stringWithFormat:@"%@||%s",commentTextView.text,m_strReplyUserID.c_str()];
        [m_webView executeJavaScriptFunc: @"onSendComment" parameter:strvalue];
        commentTextView.text = @"";
        [commentTextView resignFirstResponder];
        //[self dismissModalViewControllerAnimated:NO];
        [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];
    }
}

-(void) ReturnBtnClick:(id)sender
{
    [MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
    //[self dismissModalViewControllerAnimated:NO];
    [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];
}

@end
