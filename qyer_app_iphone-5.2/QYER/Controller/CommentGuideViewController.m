//
//  CommentGuideViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-7-3.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "CommentGuideViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SendMyComment.h"
#import "MobClick.h"
#import "Toast+UIView.h"



#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titlelabel        (ios7 ? (20+8) : 6)
#define     height_titleLabel           (ios7 ? 30 : 34)
#define     positionY_backbutton        (ios7 ? (8+20) : 3)
#define     positionY_sendbutton        (ios7 ? (8+20) : 3)





@interface CommentGuideViewController ()

@end




@implementation CommentGuideViewController
@synthesize str_title = _str_title;
@synthesize str_guideId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    self.str_title = nil;
    self.str_guideId = nil;
    
    QY_VIEW_RELEASE(_label_placeholder);
    QY_VIEW_RELEASE(_textView);
    
    [super dealloc];
}


#pragma mark -
#pragma mark --- view - Appear & Disappear
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [MobClick beginLogPageView:@"锦囊评论页"];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
    [MobClick beginLogPageView:@"锦囊评论页"];
    
}



#pragma mark -
#pragma mark --- 构建View
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    [self initRootView];
    [self setNavigationBar];
    [self initTextView];
}
-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
}
-(void)setNavigationBar
{
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home_head@2x" ofType:@"png"]];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, positionY_titlelabel, 220, height_titleLabel)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = _str_title;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    [_titleLabel release];
    
    
    UIButton *_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(6, positionY_backbutton, 47, 33);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"btn_more_cancel.png"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(doQuit) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
    
    
    _sendButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _sendButton.frame = CGRectMake(267, positionY_sendbutton, 47, 33);
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"btn_more_send.png"] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(doSend) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_sendButton];
    _sendButton.enabled = NO;
    
}
-(void)initTextView
{
    UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(10, _headView.frame.size.height+10, 300, 400)];
    backGroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backGroundView];
    
    
    if(iPhone5)
    {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 120+88)];
    }
    else
    {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 120)];
    }
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textColor = [UIColor grayColor];
    _textView.font = [UIFont fontWithName:@"Arial" size:15];
    _textView.delegate = self;
    _textView.backgroundColor = [UIColor whiteColor];
    [_textView becomeFirstResponder];
    _textView.textColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1];
    [backGroundView.layer setBorderWidth:1];
    [backGroundView.layer setBorderColor:[UIColor colorWithRed:214/255. green:214/255. blue:210/255. alpha:1].CGColor];
    [backGroundView addSubview:_textView];
    [backGroundView release];
    
    
    // *** placeholder
    if(!_label_placeholder)
    {
        if(ios7)
        {
            _label_placeholder = [[UILabel alloc] initWithFrame:CGRectMake(8, 3, 290, 40)];
        }
        else
        {
            _label_placeholder = [[UILabel alloc] initWithFrame:CGRectMake(8, 3, 290, 60)];
        }
    }
    _label_placeholder.numberOfLines = 0;
    _label_placeholder.backgroundColor = [UIColor clearColor];
    _label_placeholder.text = @"在这里您可以和其它也下载此锦囊的用户进行交流";
    _label_placeholder.alpha = 1;
    [_textView addSubview:_label_placeholder];
    _label_placeholder.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
    _label_placeholder.textColor = [UIColor grayColor];
}



#pragma mark -
#pragma mark --- UITextView - Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0)
    {
        _label_placeholder.alpha = 0;
        _sendButton.enabled = YES;
    }
    else
    {
        _label_placeholder.alpha = 1;
        _sendButton.enabled = NO;
    }
}


#pragma mark -
#pragma mark --- doQuit
-(void)doQuit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)doSend
{
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    
    
    [self.view hideToast];
    [self.view makeToast:@"正在发送..." duration:0 position:@"center" isShadow:NO];
    
    [SendMyComment sendMyCommentByAccessToken:access_token
                                   andGuideId:self.str_guideId
                               andCommentText:_textView.text
                                     finished:^{
                                         NSLog(@"添加评论成功");
                                         
                                         [self.view hideToast];
                                         [self.view makeToast:@"评论成功" duration:1 position:@"center" isShadow:NO];
                                         
                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"commentGuide_success" object:nil userInfo:nil];
                                         [self performSelector:@selector(doQuit) withObject:nil afterDelay:1];
                                     }
                                       failed:^(NSString *info){
                                           NSLog(@"添加评论失败");
                                           NSLog(@" info : %@",info);
                                           
                                           [self.view hideToast];
                                           if(info)
                                           {
                                               [self.view makeToast:info duration:2 position:@"center" isShadow:NO];
                                           }
                                           else
                                           {
                                               [self.view makeToast:@"评论失败" duration:1 position:@"center" isShadow:NO];
                                           }
                                           
                                       }];
}




#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
