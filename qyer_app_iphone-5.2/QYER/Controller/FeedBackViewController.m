//
//  FeedBackViewController.m
//  QyGuide
//
//  Created by 你猜你猜 on 13-9-4.
//
//

#import "FeedBackViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DeviceInfo.h"
#import "ASIFormDataRequest.h"
#import "UniqueIdentifier.h"
#import "NSString+SBJSON.h"
#import "Toast+UIView.h"
#import "MobClick.h"



#define     height_headerview                   (ios7 ? (44+20) : 44)

#define     positionX_textview_background       10
#define     positionY_textview_background       height_headerview+10
#define     width_textview_background           320-(positionX_textview_background)*2
#define     height_textview_background          (iPhone5 ? 200 : (200-88))
#define     positionX_textview                  0
#define     positionY_textview                  (ios7 ? 0 : 5)
#define     height_textview                     (ios7 ? height_textview_background : (height_textview_background-positionY_textview))

#define     positionX_placeholderLabel          (ios7 ? 5 : 10)
#define     positionY_placeholderLabel          (ios7 ? 4 : -3)

#define     positionX_mailview                  0
#define     positionY_mailview                  positionY_textview_background+height_textview_background+10
#define     width_mailview                      320-(positionX_mailview)*2
#define     height_mailview                     30


#define     placeholderContent_feedback         @"请在这里留下您的意见.如果希望我们联系您，请记得留下您的邮箱哦。"
#define     placeholderMailAddress_feedback     @" 留下您的联系方式，我们会及时联系您。"






@interface FeedBackViewController ()

@end






@implementation FeedBackViewController

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
    QY_VIEW_RELEASE(_headView);
    QY_VIEW_RELEASE(_placeholderLabel_textView);
    QY_VIEW_RELEASE(_textView_feedBack);
    QY_VIEW_RELEASE(_textfield_mail);
    QY_VIEW_RELEASE(_backGroundView_mail);
    
    [super dealloc];
}




#pragma mark -
#pragma mark --- viewWillAppear 和 viewWillDisappear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initHomeView];
    
    [MobClick beginLogPageView:@"意见反馈"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick beginLogPageView:@"意见反馈"];
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
    
    [self setRootView];
    [self setNavigationBar];
    
}
-(void)setRootView
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
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 11, 160, 30)];
    if(ios7)
    {
        titleLabel.frame = CGRectMake(80, 8+20, 160, 30);
    }
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"意见反馈";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    [_headView addSubview:titleLabel];
    [titleLabel release];
    
    
    _button_back = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_back.backgroundColor = [UIColor clearColor];
    _button_back.frame = CGRectMake(6, 6, 47, 33);
    if(ios7)
    {
        _button_back.frame = CGRectMake(6, 6+20, 47, 33);
    }
    [_button_back setBackgroundImage:[UIImage imageNamed:@"btn_more_cancel"] forState:UIControlStateNormal];
    [_button_back addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_button_back];
    
    
    _button_send = [UIButton buttonWithType:UIButtonTypeCustom];
    _button_send.frame = CGRectMake(267, 6, 47, 33);
    if(ios7)
    {
        _button_send.frame = CGRectMake(267, 6+20, 47, 33);
    }
    [_button_send setBackgroundImage:[UIImage imageNamed:@"btn_more_send"] forState:UIControlStateNormal];
    [_button_send addTarget:self action:@selector(clickSendButton:) forControlEvents:UIControlEventTouchUpInside];
    _button_send.enabled = NO;
    [_headView addSubview:_button_send];
}
-(void)initHomeView
{
    [self initTextView];
    [self initUserMailView];
}
-(void)initTextView
{
    //background - textview:
    UIView *textview_backgroundView = [[UIView alloc] initWithFrame:CGRectMake(positionX_textview_background, positionY_textview_background, width_textview_background, height_textview_background)];
    textview_backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textview_backgroundView];
    [textview_backgroundView.layer setBorderWidth:1];
    [textview_backgroundView.layer setBorderColor:[UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:0.2].CGColor];
    
    
    //textView:
    if(!_textView_feedBack)
    {
        _textView_feedBack = [[UITextView alloc] initWithFrame:CGRectMake(positionX_textview, positionY_textview, width_textview_background, height_textview)];
        _textView_feedBack.backgroundColor = [UIColor clearColor];
    }
    _textView_feedBack.delegate = self;
    [textview_backgroundView addSubview:_textView_feedBack];
    [_textView_feedBack becomeFirstResponder];
    
    
    //placeholderLabel - textView:
    if(!_placeholderLabel_textView)
    {
        if(ios7)
        {
            _placeholderLabel_textView = [[UILabel alloc] initWithFrame:CGRectMake(positionX_placeholderLabel, positionY_placeholderLabel, (_textView_feedBack.bounds.size.width-2*positionX_placeholderLabel), 36)];
        }
        else
        {
            _placeholderLabel_textView = [[UILabel alloc] initWithFrame:CGRectMake(positionX_placeholderLabel,positionY_placeholderLabel , (_textView_feedBack.bounds.size.width-2*positionX_placeholderLabel), 36)];
        }
        _placeholderLabel_textView.numberOfLines = 2;
        _placeholderLabel_textView.backgroundColor = [UIColor clearColor];
    }
    //_placeholderLabel_textView.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13];
    _placeholderLabel_textView.font = [UIFont systemFontOfSize:13];
    _placeholderLabel_textView.textColor = [UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:0.3];
    [_textView_feedBack addSubview:_placeholderLabel_textView];
    _placeholderLabel_textView.text = placeholderContent_feedback;
    
    [textview_backgroundView release];
}
-(void)initUserMailView
{
    //backGroundView - mail:
    if(!_backGroundView_mail)
    {
        _backGroundView_mail = [[UIView alloc] initWithFrame:CGRectMake(positionX_mailview, positionY_mailview, width_mailview, height_mailview)];
    }
    _backGroundView_mail.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_backGroundView_mail];
    
    
    //title - mail:
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, height_mailview)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"电子邮件";
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:13];
    [_backGroundView_mail addSubview:label];
    
    
    //textfield - mail:
    UIView *backGroundView_textfield = [[UIView alloc] initWithFrame:CGRectMake(label.frame.origin.x+label.frame.size.width, label.frame.origin.y, width_mailview-2*(label.frame.origin.x)-label.frame.size.width, height_mailview)];
    backGroundView_textfield.backgroundColor = [UIColor whiteColor];
    [backGroundView_textfield.layer setBorderWidth:1];
    [backGroundView_textfield.layer setBorderColor:[UIColor colorWithRed:100/255. green:100/255. blue:100/255. alpha:0.2].CGColor];
    if(!_textfield_mail)
    {
        _textfield_mail = [[UITextField alloc] initWithFrame:CGRectMake(2, 7, backGroundView_textfield.frame.size.width-2, height_mailview-7*2)];
        _textfield_mail.backgroundColor = [UIColor clearColor];
    }
    _textfield_mail.font = [UIFont systemFontOfSize:12];
    _textfield_mail.placeholder = placeholderMailAddress_feedback;
    [backGroundView_textfield addSubview:_textfield_mail];
    [_backGroundView_mail addSubview:backGroundView_textfield];
    [label release];
    [backGroundView_textfield release];
    
    [self performSelector:@selector(setMailText) withObject:Nil afterDelay:0.3];
}
-(void)setMailText
{
    //textfield - 默认邮箱内容:
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"userfeedback_mail"])
    {
        NSString *mailInfo = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userfeedback_mail"]];
        _textfield_mail.text = mailInfo;
    }
}



#pragma mark -
#pragma mark --- UITextView - Delegate
-(void)textViewDidChange:(UITextView *)textView
{
    if(_textView_feedBack.text.length > 0)
    {
        _placeholderLabel_textView.alpha = 0;
        _button_send.enabled = YES;
    }
    else
    {
        _placeholderLabel_textView.alpha = 1;
        _button_send.enabled = NO;
    }
}




#pragma mark -
#pragma mark --- 判断邮箱格式是否合法
-(BOOL)validateEmail:(NSString *)candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}


#pragma mark -
#pragma mark --- 发送反馈信息
-(void)clickSendButton:(id)sender
{
    if(!_textView_feedBack.text || _textView_feedBack.text.length == 0)
    {
        [self.view hideToast];
        [self.view makeToast:@"请完善反馈的内容" duration:1 position:@"center" isShadow:NO];
        
        return;
    }
    if(_textfield_mail.text.length > 0 && ![self validateEmail:_textfield_mail.text])
    {
        [self.view hideToast];
        [self.view makeToast:@"邮箱格式不正确" duration:1 position:@"center" isShadow:NO];
        
        return;
    }
    
    
    [self.view hideToast];
    [self.view makeToast:@"正在发送..." duration:0 position:@"center" isShadow:NO];
    
    
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"qyerlogin"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    if (isLogin == NO)
    {
        userName = @"游客";
    }
    
    
    NSString *mailInfo = _textfield_mail.text;
    if(_textfield_mail.text.length > 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:_textfield_mail.text forKey:@"userfeedback_mail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"userfeedback_mail"])
        {
            mailInfo = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userfeedback_mail"]];
        }
        else
        {
            mailInfo = @"无";
        }
    }
    
    
    NSString *content = @"";
    content = [NSString stringWithFormat:@"设备名称：%@|系统版本：%@|应用版本：%@|用户：%@|内容：%@|邮箱:%@",[DeviceInfo getDeviceName_detail],[DeviceInfo getDeviceSystemVersion],[DeviceInfo getAppVersion],userName,_textView_feedBack.text,mailInfo];
    [self postUserFeedBackWithContent:content];
}



#pragma mark -
#pragma mark --- clickBackButton
-(void)clickBackButton:(id)sender
{
    [self.view hideToast];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark --- didReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}








#pragma mark -
#pragma mark --- ASIHTTPRequest - 用户反馈统计:
-(void)postUserFeedBackWithContent:(NSString *)content
{
    NSString *urlStr =@"http://open.qyer.com/app_feedback/add";
    ASIFormDataRequest *request  = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    request.delegate = self;
    request.shouldRedirect = NO;
    [request addPostValue:ClientId_QY forKey:@"client_id"];
    [request addPostValue:[UniqueIdentifier getUniqueIdentifier] forKey:@"device_id"];
    [request addPostValue:content forKey:@"content"];
    [request addPostValue:[[NSDate date] description] forKey:@"modified"];
    
    NSString *lat_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lat_user"]];
    NSString *lon_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lon_user"]];
    if (![lat_user isEqualToString:@""] && ![lon_user isEqualToString:@""]) {
        [request setPostValue:lat_user forKey:@"lat"];
        [request setPostValue:lon_user forKey:@"lon"];
    }
    
    
    [request startAsynchronous];
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
        [self.view makeToast:@"发送成功" duration:0.6 position:@"center" isShadow:NO];
        
        [self performSelector:@selector(clickBackButton:) withObject:nil afterDelay:0.7];
    }
    else
    {
        [self.view hideToast];
        [self.view makeToast:@"反馈失败" duration:1 position:@"center" isShadow:NO];
    }
    
    //***(2)Use when fetching binary data
    //NSData *responseData = [request responseData];
    
    
    
    [responseString release];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSLog(@"requestFailed !!!!  requestFailed !!!!");
    NSString *responseString2 = [request responseString];
    if (responseString2) {
        NSMutableString *responseString = [[NSMutableString alloc] initWithString:responseString2];
        // NSLog(@"responseString (Failed)==== %@",responseString);
        [responseString release];
    }
    
    [self.view hideToast];
    [self.view makeToast:@"貌似网络有点不好，检查一下吧..." duration:1 position:@"center" isShadow:NO];
    
}





@end
