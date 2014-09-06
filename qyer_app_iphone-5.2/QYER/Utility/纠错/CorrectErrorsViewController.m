//
//  CorrectErrorsViewController.m
//  QYGuide
//
//  Created by 回头蓦见 on 13-8-13.
//  Copyright (c) 2013年 an qing. All rights reserved.
//

#import "CorrectErrorsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>   //md5
#import "ASIFormDataRequest.h"
#import "NSString+SBJSON.h"
#import "GetInfo.h"
#import "TongjiFenxi.h"
#import "GetDeviceDetailInfo.h"
#import "Toast+UIView.h"



#define     height_headerview           (ios7 ? (44+20) : 44)
#define     positionY_titleLabel        (ios7 ? (6+20) : 6)
#define     height_titleLabel           (ios7 ? 30 : 34)
#define     positionY_backbutton        (ios7 ? (6+20) : 6)
#define     positionY_sendbutton        (ios7 ? (6+20) : 6)
#define     positionY_backGroungView    (ios7 ? (10+44+20) : 10+44)





@interface CorrectErrorsViewController ()

@end






@implementation CorrectErrorsViewController
@synthesize guide;
@synthesize pageNumber;

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
    
    
    [super dealloc];
}


#pragma mark -
#pragma mark --- 构建view
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initRootView];
    [self initNavigationBar];
    [self initTextView];
}
-(void)initRootView
{
    UIView *rootView;
    if(iPhone5)
    {
        rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480+88)];
    }
    else
    {
        rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    }
    self.view = rootView;
    [rootView setBackgroundColor:[UIColor colorWithRed:238/255. green:238/255. blue:238/255. alpha:1]];
    [rootView release];
}
-(void)initNavigationBar
{
    UIImageView *_headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home_head@2x" ofType:@"png"]];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, positionY_titleLabel, 160, height_titleLabel)];
    _titleLabel.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 3);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.text = @"纠错";
    [_headView addSubview:_titleLabel];
    [_titleLabel release];
    
    
    UIButton *_backButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.frame = CGRectMake(6, positionY_backbutton, 47, 33);
    [_backButton setBackgroundImage:[UIImage imageNamed:@"btn_more_cancel.png"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(doQuit) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backButton];
    
    
    _sendButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _sendButton.backgroundColor = [UIColor clearColor];
    _sendButton.frame = CGRectMake(267, positionY_sendbutton, 47, 33);
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"btn_more_send.png"] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(doSend) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_sendButton];
    _sendButton.enabled = NO;
    
    
    [_headView release];
}
-(void)initTextView
{
    UIView *backGroungView = [[UIView alloc] initWithFrame:CGRectMake(9, positionY_backGroungView, 302, 120+230+88)];;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 120+88, 300, 230)];
    _textView_correctErrors = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 120+88)];
    if(!iPhone5)
    {
        backGroungView.frame = CGRectMake(9, positionY_backGroungView, 302, 120+230);
        _textView_correctErrors.frame = CGRectMake(0, 0, 300, 120);
        view.frame = CGRectMake(0, 120, 300, 230);
    }
    [self.view addSubview:backGroungView];
    [backGroungView.layer setBorderWidth:1];
    [backGroungView.layer setBorderColor:[UIColor colorWithRed:214/255.0 green:214/255.0 blue:210/255.0 alpha:1].CGColor];
    [backGroungView setBackgroundColor:[UIColor whiteColor]];
    [_textView_correctErrors.layer setCornerRadius:1.0];
    _textView_correctErrors.delegate=self;
    //myTextView.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15.0f];
    _textView_correctErrors.font = [UIFont fontWithName:@"Arial" size:15];
    _textView_correctErrors.textColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1];
    
    [backGroungView addSubview:_textView_correctErrors];
    
    [self initTextViewPlaceholder];
    [_textView_correctErrors becomeFirstResponder];
    
    [view release];
    [backGroungView release];
}
-(void)initTextViewPlaceholder
{
    _label_textViewPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 280, 40)];
    _label_textViewPlaceholder.backgroundColor = [UIColor clearColor];
    _label_textViewPlaceholder.textColor = [UIColor grayColor];
    _label_textViewPlaceholder.font = [UIFont systemFontOfSize:15.];
    _label_textViewPlaceholder.numberOfLines = 2;
    _label_textViewPlaceholder.text = @"这本锦囊有错误？快开动您的火眼金睛给我们指出来吧，我们会尽快核实并更新...";
    [_textView_correctErrors addSubview:_label_textViewPlaceholder];
}



#pragma mark -
#pragma mark --- UITextView - Delegate
-(void)textViewDidChange:(UITextView *)textView
{
    if(_textView_correctErrors.text.length == 0)
    {
        _label_textViewPlaceholder.hidden = NO;
        _sendButton.enabled = NO;
    }
    else
    {
        _label_textViewPlaceholder.hidden = YES;
        _sendButton.enabled = YES;
    }
}



#pragma mark -
#pragma mark --- doSend
-(void)doSend
{
    [_textView_correctErrors resignFirstResponder];
    
    if([_textView_correctErrors.text length] > 0)
    {
        [self.view hideToast];
        [self.view makeToast:@"正在发送..." duration:0 position:@"center" isShadow:NO];
        
        [self performSelector:@selector(postData) withObject:nil afterDelay:0.];
    }
    else
    {
        [self.view hideToast];
        [self.view makeToast:@"请完善反馈的内容" duration:1.0 position:@"center" isShadow:NO];
    }
}
-(NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr,strlen(cStr), result );
    
    NSString *outStr = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                        result[0], result[1], result[2], result[3],
                        result[4], result[5], result[6], result[7],
                        result[8], result[9], result[10], result[11],
                        result[12], result[13], result[14], result[15]
                        ];
    return outStr;
}
-(void)postData
{
    NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
    NSString *myOnlyString = [GetInfo getMacaddress];
    [myDefault setValue:myOnlyString forKey:@"myonlystring"];
    NSString *str1 = [self md5:myOnlyString];
    NSString *string1 = [str1 substringToIndex:30];
    NSString *string2 = [str1 substringFromIndex:30];
    NSString *str = [NSString stringWithFormat:@"%@%@",string2,string1];
    NSString *outStr = [self md5:str];
    [myDefault setValue:outStr forKey:@"md5String"];
    [myDefault synchronize];
    
    
    
    NSString *deviceid = [[GetInfo getMacaddress] retain];
    NSString *authkeyStr = [[myDefault valueForKey:@"md5String"] retain];
    NSString *urlStr = [NSString stringWithFormat:@"%@/app_correctErrors/add",DomainName];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isLogin = [userDefault boolForKey:@"qyerlogin"];
    NSString *username = [userDefault valueForKey:@"username"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *updateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.guide.guideUpdate_time doubleValue]]];
    [dateFormatter release];
    if(isLogin == NO)
    {
        username = @"游客";
    }
    NSString *content = [NSString stringWithFormat:@"设备名称：%@|系统版本：%@|应用版本：%@|锦囊名称：%@|更新日期：%@|页码：%d|用户：%@|内容：%@",[[UIDevice currentDevice] localizedModel],[[UIDevice currentDevice] systemVersion],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],self.guide.guideName,updateTime,self.pageNumber+1,username,_textView_correctErrors.text];
    
    
    ASIFormDataRequest *request  = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    request.delegate = self;
    request.shouldRedirect = NO;
    [request addPostValue:ClientId_QY forKey:@"client_id"];
    [request addPostValue:[GetInfo getMacaddress] forKey:@"device_id"];
    [request addPostValue:content forKey:@"content"];
    [request addPostValue:[[NSDate date] description] forKey:@"modified"];
    [request startAsynchronous];
    
    
    //*** qyer后台统计:
    TongjiFenxi *_tongjifenxi = [[[TongjiFenxi alloc] init] autorelease];
    [_tongjifenxi postDataByUrlStr:urlStr andAppId:[NSString stringWithFormat:@"%d",3] andDeviceId:deviceid andType:@"errorcheck" andAboutId:@"allShare"];
    
    [deviceid release];
    [authkeyStr release];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //***(1)Use when fetching text data
    NSString *responseString2 = [request responseString];
    NSMutableString *responseString = [[NSMutableString alloc]initWithString:responseString2];
    //NSLog(@"responseString ==(requestFinished)== %@",responseString);
    
    NSMutableDictionary *dic = [responseString JSONValue];
    NSString *flag = [NSString stringWithFormat:@"%@",[dic valueForKey:@"status"]];
    if([flag isEqualToString:@"1"])
    {
        [self.view hideToast];
        [self.view makeToast:@"发送成功" duration:0.9 position:@"center" isShadow:NO];
        
        [self performSelector:@selector(doQuit) withObject:nil afterDelay:1.];
    }
    else
    {
        [self.view hideToast];
        [self.view makeToast:@"发送失败" duration:1.0 position:@"center" isShadow:NO];
    }
    
    
    //***(2)Use when fetching binary data
    //NSData *responseData = [request responseData];
    
    
    [responseString release];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSLog(@"requestFailed !!!!  requestFailed !!!!");
    NSString *responseString2 = [request responseString];
    if (responseString2)
    {
        NSMutableString *responseString = [[NSMutableString alloc] initWithString:responseString2];
        // NSLog(@"responseString (Failed)==== %@",responseString);
        [responseString release];
    }
    
    [self.view hideToast];
    [self.view makeToast:@"貌似网络有点不好，检查一下吧..." duration:1.0 position:@"center" isShadow:NO];
}



#pragma mark -
#pragma mark --- doQuit
-(void)doQuit
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doQuit) object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
