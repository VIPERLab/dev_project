//
//  ErrorCorrectionViewController.m
//  QYGuide
//
//  Created by 我去 on 14-2-8.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "ErrorCorrectionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+SBJSON.h"
#import "MobClick.h"
#import "ASIFormDataRequest.h"
#import <CommonCrypto/CommonDigest.h>   //md5
#import "TongjiFenxi.h"
#import "GetInfo.h"
#import "TongjiFenxi.h"
#import "GetDeviceDetailInfo.h"
#import "Toast+UIView.h"
#import "UniqueIdentifier.h"




@interface ErrorCorrectionViewController ()

@end





@implementation ErrorCorrectionViewController
@synthesize myTextView;
@synthesize updateTime;
@synthesize guideName;
@synthesize strPageNumber;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [receiveData release];
    QY_VIEW_RELEASE(_titleLabel);
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_banView);
    QY_VIEW_RELEASE(alertLabel);
    QY_VIEW_RELEASE(smallBlackView);
    QY_VIEW_RELEASE(_label_placeholder);
    QY_VIEW_RELEASE(myTextView);
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
    
    
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
    if(ios7)
    {
        _headView.frame = CGRectMake(0, 0, 320, 46+20);
    }
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 13, 160, 30)];
    if(ios7)
    {
        _titleLabel.frame = CGRectMake(80, 6+20, 160, 30);
    }
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"给锦囊纠错";
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    [_headView addSubview:_titleLabel];
    
    _cancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _cancelButton.frame = CGRectMake(6, 6, 47, 33);
    if(ios7)
    {
        _cancelButton.frame = CGRectMake(6, 6+20, 47, 33);
    }
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_more_cancel"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_cancelButton];
    
    
    _sendButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _sendButton.frame = CGRectMake(267, 6, 47, 33);
    if(ios7)
    {
        _sendButton.frame = CGRectMake(267, 6+20, 47, 33);
    }
    [_sendButton setBackgroundImage:[UIImage imageNamed:@"btn_more_send"] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(doSend) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_sendButton];
    _sendButton.enabled = NO;
    
    
    
    if(myTextView)
    {
        [myTextView release];
        myTextView = nil;
    }
    
    UIView *backGroungView;
    UIView *view ;
    if(iPhone5)
    {
        backGroungView = [[UIView alloc] initWithFrame:CGRectMake(9, 10+44, 302, 120+230+88)];
        myTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 120+88)];
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 120+88, 300, 230)];
    }
    else
    {
        backGroungView = [[UIView alloc] initWithFrame:CGRectMake(9, 10+44, 302, 120+230)];
        myTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 120)];
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 120, 300, 230)];
    }
    if(ios7)
    {
        CGRect frame = backGroungView.frame;
        frame.origin.y = 10+44+20;
        backGroungView.frame = frame;
    }
    
    [self.view addSubview:backGroungView];
    [backGroungView.layer setBorderWidth:1];
    [backGroungView.layer setBorderColor:[UIColor colorWithRed:214/255. green:214/255. blue:210/255. alpha:1].CGColor];
    [backGroungView setBackgroundColor:[UIColor whiteColor]];
    [backGroungView release];
    [myTextView.layer setCornerRadius:1];
    myTextView.delegate = self;
    myTextView.font = [UIFont fontWithName:@"Arial" size:15];
    myTextView.textColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1];
    [backGroungView addSubview:myTextView];
    myTextView.selectedRange=NSMakeRange(0,0);
    [myTextView becomeFirstResponder];
    myTextView.backgroundColor = [UIColor clearColor];
    //[backGroungView addSubview:view];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view release];
    
    
    if(ios7)
    {
        _label_placeholder = [[UILabel alloc] initWithFrame:CGRectMake(6, 5, myTextView.frame.size.width-6, 40)];
    }
    else
    {
        _label_placeholder = [[UILabel alloc] initWithFrame:CGRectMake(9, 8, myTextView.frame.size.width-9, 40)];
    }
    _label_placeholder.backgroundColor = [UIColor clearColor];
    _label_placeholder.numberOfLines = 0;
    _label_placeholder.font = [UIFont fontWithName:@"Arial" size:15];
    _label_placeholder.textColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:0.3];
    _label_placeholder.text = @"这本锦囊有错误？快开动您的火眼金睛给我们指出来吧，我们会尽快核实并更新...";
    [myTextView addSubview:_label_placeholder];
    _label_placeholder.alpha = 1;
    
    
    
    _banView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    _banView.backgroundColor = [UIColor clearColor];
}

-(void)doBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)doSend
{
    [myTextView resignFirstResponder];
    
    if([myTextView.text length] > 0)
    {
        [self.view hideToast];
        [self.view makeToast:@"正在发送..." duration:0 position:@"center" isShadow:NO];
        
        [self performSelector:@selector(postData) withObject:nil afterDelay:0];
    }
    else
    {
        [self.view hideToast];
        [self.view makeToast:@"请完善反馈的内容" duration:1 position:@"center" isShadow:NO];
    }
}

-(NSString *)getMyIp
{
    NSError *error;
    NSURL *ipUrl = [NSURL URLWithString:@"http://automation.whatismyip.com/n09230945.asp"];
    NSString *ip = [NSString stringWithContentsOfURL:ipUrl encoding:NSUTF8StringEncoding error:&error];
    
    //return ip?ip:[error localizedDescription];
    return ip?ip:@"172.0.0.9";
}

-(void)showSendStatus
{
    [smallBlackView release];
    smallBlackView = [[UIView alloc] initWithFrame:CGRectMake(90, 140, 140, 50)];
    [smallBlackView setBackgroundColor:[UIColor blackColor]];
    [smallBlackView setAlpha:0.97];
    //[smallBlackView.layer setBorderWidth:3];
    [smallBlackView.layer setBorderColor:[[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8] CGColor]];
    [self.view addSubview:smallBlackView];
    [smallBlackView.layer setCornerRadius:9.0];
    
    [alertLabel release];
    alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 7, 130, 40)];
    
    [alertLabel setFont:[UIFont fontWithName:@"HiraKakuProN-W3" size:14.0f]];
    
    [alertLabel setBackgroundColor:[UIColor clearColor]];
    [alertLabel setTextColor:[UIColor whiteColor]];
    [alertLabel setTextAlignment:NSTextAlignmentCenter];
    [smallBlackView addSubview:alertLabel];
    alertLabel.text = @"正在发送...";
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView.text.length >= 1)
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
-(void)doBecomeActive
{
    myTextView.text = @"";
    myTextView.textColor=[UIColor blackColor];
    myTextView.font = [UIFont systemFontOfSize:16];
    [myTextView becomeFirstResponder];
}
-(void)doResigntTextfield
{
    [myTextView resignFirstResponder];
}




#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
NSString *macaddress1()
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        //BFLog("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        //BFLog("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        //BFLog("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        //BFLog("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%X:%X:%X:%X:%X:%X",*ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
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
/******************    POST提交数据 BEGIN     **********************/
+(NSString *)createUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    CFRelease(uuidObject);
    return [uuidStr autorelease];
}


-(void)postData//:(NSMutableDictionary *)dic
{
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:_banView];
    
    NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
    //    NSString *myOnlyString = macaddress1();
    NSString *myOnlyString = [UniqueIdentifier getUniqueIdentifier];
    [myDefault setValue:myOnlyString forKey:@"myonlystring"];
    //    NSString *str1 = [self md5:myOnlyString];
    //    NSString *string1 = [str1 substringToIndex:30];
    //    NSString *string2 = [str1 substringFromIndex:30];
    //    NSString *str = [NSString stringWithFormat:@"%@%@",string2,string1];
    //    NSString *outStr = [self md5:str];
    NSString *outStr = [UniqueIdentifier getUniqueIdentifierMd5String];
    [myDefault setValue:outStr forKey:@"md5String"];
    [myDefault synchronize];
    
    
    
    NSString *deviceid = [[myDefault valueForKey:@"myonlystring"] retain];
    NSString *authkeyStr = [[myDefault valueForKey:@"md5String"] retain];
    //NSString *urlStr = [NSString stringWithFormat:@"http://place.qyer.com/interface/mobile_action_submitcomment_deviceid_%@_authkey_%@",deviceid,authkeyStr];
    NSString *urlStr = @"http://open.qyer.com/app_feedback/add";
    
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL flag_login = [userDefault boolForKey:@"qyerlogin"];
    NSString *username = [userDefault valueForKey:@"username"];
    if(flag_login == NO)
    {
        username = @"游客";
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    self.updateTime = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.updateTime doubleValue]]];
    [dateFormatter release];
    
    
    NSString *content = [NSString stringWithFormat:@"设备名称:%@ | 系统版本:%@ | 应用版本:%@ | 锦囊名称:%@ | 更新日期:%@ | 页码:%@ | 用户:%@ | 内容:%@",[[UIDevice currentDevice] localizedModel],[[UIDevice currentDevice] systemVersion],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],self.guideName,self.updateTime,self.strPageNumber,username,self.myTextView.text];
    //NSLog(@"  content : %@",content);
    
    ASIFormDataRequest *request  = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    request.delegate = self;
    request.shouldRedirect = NO;
    [request addPostValue:ClientId_QY forKey:@"client_id"];
    //[request addPostValue:macaddress1() forKey:@"device_id"];
    [request addPostValue:[UniqueIdentifier getUniqueIdentifier] forKey:@"device_id"];
    [request addPostValue:content forKey:@"content"];
    [request addPostValue:[[NSDate date] description] forKey:@"modified"];
    [request startAsynchronous];
    
    [deviceid release];
    [authkeyStr release];
    
    
    //
    //    //(3)post的方式
    //    NSMutableURLRequest *myRequest = [NSMutableURLRequest requestWithURL:url];
    //    NSString *myBoundary=@"*****************************"; //这个很重要，用于区别输入的域
    //    NSString *myContent=[NSString stringWithFormat:@"multipart/form-data;boundary=%@",myBoundary]; //意思是要提交的是表单数据
    //    NSMutableData *body=[NSMutableData data]; //这个用于暂存你要提交的数据
    //    [myRequest setValue:myContent forHTTPHeaderField:@"Content-type"];//定义内容类型
    //    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",myBoundary] dataUsingEncoding:NSUTF8StringEncoding]];//表示开始
    //
    //
    //    //(3.1)
    //    [body appendData:[[NSString stringWithString:@"Content-Disposition:form-data;name=\"appid\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]]; //第1个字段开始，类型于<input type="text" name="user">
    //    [body appendData:[[NSString stringWithString:[dic valueForKey:@"appid"]] dataUsingEncoding:NSUTF8StringEncoding]]; //第1个字段的内容，即leve
    //    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",myBoundary]dataUsingEncoding:NSUTF8StringEncoding]];//字段间区分开，也意味着第一个字段结束
    //
    //
    //    //(3.2)
    //    [body appendData:[[NSString stringWithString:@"Content-Disposition:form-data;name=\"content\"\r\n\r\n"]dataUsingEncoding:NSUTF8StringEncoding]];//第2个字段开始，<input type="text" name="password">
    //    [body appendData:[[NSString stringWithString:[dic valueForKey:@"content"]]dataUsingEncoding:NSUTF8StringEncoding]];//第2个字段的内容
    //    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",myBoundary]dataUsingEncoding:NSUTF8StringEncoding]];//结束
    //
    //
    //    //(3.3)
    //    [body appendData:[[NSString stringWithString:@"Content-Disposition:form-data;name=\"direction\"\r\n\r\n"]dataUsingEncoding:NSUTF8StringEncoding]];//第3个字段开始，<input type="text" name="password">
    //    [body appendData:[[NSString stringWithString:[dic valueForKey:@"direction"]] dataUsingEncoding:NSUTF8StringEncoding]];//第3个字段的内容
    //    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",myBoundary]dataUsingEncoding:NSUTF8StringEncoding]];//结束
    //
    //
    //    //(3.4)
    //    [body appendData:[[NSString stringWithString:@"Content-Disposition:form-data;name=\"ip\"\r\n\r\n"]dataUsingEncoding:NSUTF8StringEncoding]];//第4个字段开始，<input type="text" name="sw_subway_id">
    //    [body appendData:[[NSString stringWithString:[dic valueForKey:@"ip"]]dataUsingEncoding:NSUTF8StringEncoding]];//第4个字段的内容
    //    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",myBoundary]dataUsingEncoding:NSUTF8StringEncoding]];//结束
    //
    //
    //    //(3.5)
    //    [body appendData:[[NSString stringWithString:@"Content-Disposition:form-data;name=\"deviceID\"\r\n\r\n"]dataUsingEncoding:NSUTF8StringEncoding]];//第4个字段开始，<input type="text" name="sw_subway_id">
    //    [body appendData:[[NSString stringWithString:[dic valueForKey:@"deviceID"]]dataUsingEncoding:NSUTF8StringEncoding]];//第4个字段的内容
    //    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",myBoundary]dataUsingEncoding:NSUTF8StringEncoding]];//结束
    //
    //
    //    [myRequest setHTTPMethod:@"POST"]; //定义方法为post.所以如果在PHP端接收的话，以$_POST["user"],$_POST["password"]结收数据
    //    [myRequest setHTTPBody:body]; //将内容加载到请求中
    //    NSString *msgLength = [NSString stringWithFormat:@"%d", [body length]];
    //    [myRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    //
    //    //****勿删!!!!!!!!!!!  打印POST的内容
    //    //NSLog(@"body ======== %@",[[NSString alloc]initWithData:body encoding:NSUTF8StringEncoding]);
    //
    //    [[[NSURLConnection alloc] initWithRequest:myRequest delegate:self] autorelease];
    //    [dic release];
    
    
    
    //NSString *strUrl = [NSString stringWithFormat:@"http://place.qyer.com/interface/mobile_action_addtrack_deviceid_%@_authkey_%@",deviceid,authkeyStr];
    
    TongjiFenxi *_tongjifenxi = [[[TongjiFenxi alloc] init] autorelease];
    [_tongjifenxi postDataByUrlStr:urlStr andAppId:[NSString stringWithFormat:@"%d",3] andDeviceId:deviceid andType:@"errorcheck" andAboutId:@"allShare"];
    
}
-(void)doRemoveAlertView
{
    [_banView removeFromSuperview];
    
    [smallBlackView removeFromSuperview];
    [self doBack];
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
        [self.view makeToast:@"发送成功" duration:1 position:@"center" isShadow:NO];
        [self performSelector:@selector(doRemoveAlertView) withObject:nil afterDelay:1];
    }
    else
    {
        [_banView removeFromSuperview];
    }
    
    
    //***(2)Use when fetching binary data
    //NSData *responseData = [request responseData];
    
    
    
    [responseString release];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_banView removeFromSuperview];
    
    //NSLog(@"requestFailed !!!!  requestFailed !!!!");
    NSString *responseString2 = [request responseString];
    if (responseString2) {
        NSMutableString *responseString = [[NSMutableString alloc] initWithString:responseString2];
        // NSLog(@"responseString (Failed)==== %@",responseString);
        [responseString release];
    }
    
    [self.view hideToast];
    [self.view makeToast:@"貌似网络有点不好，检查一下吧..." duration:1.0 position:@"center" isShadow:NO];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [alertView cancelButtonIndex])
    {
        [self performSelector:@selector(doBack) withObject:nil afterDelay:0.1];
        return;
    }
    else
    {
        [myTextView becomeFirstResponder];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
