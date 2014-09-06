//
//  UserNameLogInViewController.m
//  QYER
//
//  Created by Leno on 14-6-3.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "UserNameLogInViewController.h"

#import <CommonCrypto/CommonDigest.h>   //md5
#import "ASIFormDataRequest.h"
#import "NSString+SBJSON.h"
#import "MobClick.h"
#import "Reachability.h"
#import "Account.h"
#import "Toast+UIView.h"


#define     height_headerview           (ios7 ? (44+20) : 44)

@interface UserNameLogInViewController ()

@end

@implementation UserNameLogInViewController

@synthesize commontFlag;
@synthesize delegate = _delegate;

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
    
    _scrollViewww = [[UIScrollView alloc]initWithFrame:self.view.frame];
    [_scrollViewww setBackgroundColor:[UIColor clearColor]];
    [_scrollViewww setScrollEnabled:NO];
    [_scrollViewww setContentSize:CGSizeMake(320, 600)];
    [self.view addSubview:_scrollViewww];
    
    
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    _buttonback = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    _buttonback.backgroundColor = [UIColor clearColor];
    _buttonback.frame = CGRectMake(0, 3, 40, 40);
    if(ios7)
    {
        _buttonback.frame = CGRectMake(0, 3+20, 40, 40);
    }
    [_buttonback setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [_buttonback addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_buttonback];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, 200, 30)];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    if(ios7)
    {
        _titleLabel.frame = CGRectMake(60, 10+20, 200, 26);
    }
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLabel];
    _titleLabel.text = @"用户名/邮箱登录";

    
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [_scrollViewww addSubview:control];
    control.backgroundColor = [UIColor clearColor];
    [control addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [control release];

    
    
    UIView *qyerLoginViewBG = [[UIView alloc] initWithFrame:CGRectMake(13, height_headerview +40, 294, 88)];
    qyerLoginViewBG.backgroundColor = [UIColor clearColor];
    qyerLoginViewBG.userInteractionEnabled = YES;
    [_scrollViewww addSubview:qyerLoginViewBG];
    [qyerLoginViewBG release];
    
    
    UIImageView * userIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 24, 24)];
    [userIcon setBackgroundColor:[UIColor clearColor]];
    [userIcon setImage:[UIImage imageNamed:@"loginVC_user"]];
    [qyerLoginViewBG addSubview:userIcon];
    [userIcon release];
    
    UILabel * userLabel = [[UILabel alloc]initWithFrame:CGRectMake(32, 10, 100, 24)];
    [userLabel setBackgroundColor:[UIColor clearColor]];
    [userLabel setTextAlignment:NSTextAlignmentLeft];
    [userLabel setTextColor:[UIColor whiteColor]];
    [userLabel setFont:[UIFont systemFontOfSize:17]];
    [userLabel setText:@"邮箱/用户名"];
    [qyerLoginViewBG addSubview:userLabel];
    [userLabel release];
    
    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(132, 10, 160, 24)];
    [_usernameTextField setBackgroundColor:[UIColor clearColor]];
    _usernameTextField.delegate = self;
    [_usernameTextField setTextAlignment:NSTextAlignmentLeft];
    _usernameTextField.textColor = [UIColor whiteColor];
    _usernameTextField.font = [UIFont systemFontOfSize:17];
    _usernameTextField.returnKeyType = UIReturnKeyNext;
    _usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [qyerLoginViewBG addSubview:_usernameTextField];
    
    
    //用户名下的白线
    UIView * topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 43, 294, 1)];
    [topLine setBackgroundColor:[UIColor whiteColor]];
    [topLine setAlpha:0.8];
    [qyerLoginViewBG addSubview:topLine];
    [topLine release];
    
    
    UIImageView * passWordIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 54, 24, 24)];
    [passWordIcon setBackgroundColor:[UIColor clearColor]];
    [passWordIcon setImage:[UIImage imageNamed:@"loginVC_password"]];
    [qyerLoginViewBG addSubview:passWordIcon];
    [passWordIcon release];
    
    UILabel * passwordLabel = [[UILabel alloc]initWithFrame:CGRectMake(32, 54, 100, 24)];
    [passwordLabel setBackgroundColor:[UIColor clearColor]];
    [passwordLabel setTextAlignment:NSTextAlignmentLeft];
    [passwordLabel setTextColor:[UIColor whiteColor]];
    [passwordLabel setFont:[UIFont systemFontOfSize:17]];
    [passwordLabel setText:@"密码"];
    [qyerLoginViewBG addSubview:passwordLabel];
    [passwordLabel release];

    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(132, 54, 160, 24)];
    [_passwordTextField setBackgroundColor:[UIColor clearColor]];
    _passwordTextField.delegate = self;
    [_passwordTextField setTextAlignment:NSTextAlignmentLeft];
    _passwordTextField.textColor = [UIColor whiteColor];
    _passwordTextField.font = [UIFont systemFontOfSize:17];
    _passwordTextField.returnKeyType = UIReturnKeyDone;
    [_passwordTextField setSecureTextEntry:YES];
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [qyerLoginViewBG addSubview:_passwordTextField];

    
    //密码下的白线
    UIView * bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 87, 294, 1)];
    [bottomLine setBackgroundColor:[UIColor whiteColor]];
    [bottomLine setAlpha:0.8];
    [qyerLoginViewBG addSubview:bottomLine];
    [bottomLine release];
 
    
    
    UIButton * topButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [topButton setFrame:CGRectMake(0, 0, 130, 44)];
    [topButton addTarget:self action:@selector(didClickUserName:) forControlEvents:UIControlEventTouchUpInside];
    [qyerLoginViewBG addSubview:topButton];
    
    UIButton * bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomButton setFrame:CGRectMake(0, 44, 130, 44)];
    [bottomButton addTarget:self action:@selector(didClickPassWord:) forControlEvents:UIControlEventTouchUpInside];
    [qyerLoginViewBG addSubview:bottomButton];
    
    
    
    UIButton * button_login = [UIButton buttonWithType:UIButtonTypeCustom];
    button_login.frame = CGRectMake(70, qyerLoginViewBG.frame.origin.y+qyerLoginViewBG.frame.size.height+ 60, 180, 40);
    button_login.backgroundColor = [UIColor clearColor];
    [button_login setBackgroundImage:[UIImage imageNamed:@"loginVC_login"] forState:UIControlStateNormal];
    [button_login setBackgroundImage:[UIImage imageNamed:@"loginVC_login_pressed"] forState:UIControlStateHighlighted];
    [button_login addTarget:self action:@selector(clickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollViewww addSubview:button_login];
    
}

-(void)didClickUserName:(id)sender
{
    [_usernameTextField becomeFirstResponder];
}
-(void)didClickPassWord:(id)sender
{
    [_passwordTextField becomeFirstResponder];
}

#pragma mark -
#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == _usernameTextField)
    {
        [_passwordTextField becomeFirstResponder];
    }
    else
    {
        [_scrollViewww setContentOffset:CGPointZero animated:YES];
        [self clickLoginButton:nil];
    }
    
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_scrollViewww setContentOffset:CGPointMake(0, 30) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_scrollViewww setContentOffset:CGPointZero animated:YES];
}


//点击登陆按钮:
- (void)clickLoginButton:(id)sender
{
    if([_usernameTextField.text length]<2 || [_passwordTextField.text length] == 0)
    {
        [self.view hideToast];
        [self.view makeToast:@"请完整填写" duration:1.0 position:@"center" isShadow:NO];
        
    }
    else if([_passwordTextField.text length] < 6 || [_passwordTextField.text length] > 16)
    {
        [self.view hideToast];
        [self.view makeToast:@"密码长度:6~16位" duration:1.0 position:@"center" isShadow:NO];
        
    }
    else
    {
        if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)
        {
            if(signFlag == 0)
            {
                signFlag = 1;
                
                [self.view hideToast];
                [self.view makeToast:@"正在登录..." duration:0.0 position:@"center" isShadow:NO];
                [self performSelector:@selector(doLogin) withObject:nil afterDelay:0];
            }
        }
        else
        {
            [self.view hideToast];
            [self.view makeToast:@"请检查网络连接" duration:1.0 position:@"center" isShadow:NO];
        }
    }
}

-(void)doLogin
{
    _flag_logSuccess = NO;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/qyer/user/login",DomainName];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *account_s=[self encodeAccountWithName:_usernameTextField.text password:_passwordTextField.text];
    ASIFormDataRequest *_loginRequest  = [[ASIFormDataRequest alloc] initWithURL:url];
    _loginRequest.delegate = self;
    _loginRequest.shouldRedirect = YES; //网页自动跳转[例:从'go2eu'跳转到'qyer']!!
    _loginRequest.timeOutSeconds = 10;
    
    [_loginRequest addPostValue:ClientId_QY forKey:@"client_id"];
    [_loginRequest addPostValue:ClientSecret_QY forKey:@"client_secret"];
    [_loginRequest addPostValue:_usernameTextField.text forKey:@"username"];
    [_loginRequest addPostValue:_passwordTextField.text forKey:@"password"];
    [_loginRequest addPostValue:@"password" forKey:@"grant_type"];
    [_loginRequest addPostValue:account_s forKey:@"account_s"];
    
    
    NSString *lat_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lat_user"]];
    NSString *lon_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lon_user"]];
    if (![lat_user isEqualToString:@""] && ![lon_user isEqualToString:@""]) {
        [_loginRequest setPostValue:lat_user forKey:@"lat"];
        [_loginRequest setPostValue:lon_user forKey:@"lon"];
    }
    
    [_loginRequest startAsynchronous];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
//    NSString *responseString2 = [request responseString];
//    NSMutableString *responseString = [[NSMutableString alloc] initWithString:responseString2];
    
    [self.view hideToast];
    [self.view makeToast:@"登录失败" duration:1 position:@"center" isShadow:NO];
    
    signFlag = 0;
//    [responseString release];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"##############");
    
    NSString *responseString2 = [request responseString];
    NSMutableString *responseString = [[NSMutableString alloc] initWithString:responseString2];
    
    signFlag = 0;
    
    NSMutableDictionary *dic = [responseString JSONValue];
    
    NSString *result = [NSString stringWithFormat:@"%@",[dic valueForKey:@"access_token"]];
    
    if([[dic valueForKey:@"info"] isEqualToString:@"账号或密码错误"])
    {
        [self.view hideToast];
        [self.view makeToast:@"您的账号和密码不符,请再试一次." duration:1 position:@"center" isShadow:NO];
    }
    else if([[dic valueForKey:@"error"] length] > 0)
    {
        [self.view hideToast];
        [self.view makeToast:@"您的账号和密码不符,请再试一次." duration:1 position:@"center" isShadow:NO];
    }
    else if([responseString rangeOfString:@"timed out"].location != NSNotFound)
    {
        [self.view hideToast];
        [self.view makeToast:@"登录失败" duration:1 position:@"center" isShadow:NO];
    }
    else if([result length] > 1)
    {
        [self.view hideToast];
        [self.view makeToast:@"登录成功" duration:1.6f position:@"center" isShadow:NO];
        
        [MobClick event:@"loginSucceed"];
        
        dic = [dic objectForKey:@"data"];
        NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
        [myDefault setObject:[NSNumber numberWithBool:YES] forKey:@"qyerlogin"];
        [myDefault setValue:[dic valueForKey:@"access_token"] forKey:@"user_access_token"];
        [myDefault setObject:[dic objectForKey:@"user_id"] forKey:@"userid"];
        [myDefault setValue:[dic objectForKey:@"username"] forKey:@"username"];
        [myDefault setValue:[dic objectForKey:@"avatar"] forKey:@"usericon"];
        [myDefault setValue:[dic objectForKey:@"im_user_id"] forKey:@"userid_im"];
        [myDefault setValue:[dic objectForKey:@"title"] forKey:@"title"];
        [myDefault synchronize];
        
        [[Account sharedAccount] initAccountWithDic:dic];
        
        _flag_logSuccess = YES;
        
        signFlag = 0;
        
        [_usernameTextField resignFirstResponder];
        [_passwordTextField resignFirstResponder];
        
        [self performSelector:@selector(doSomethingAfterLoginSuccessed) withObject:nil afterDelay:1.6f];
    }
    else
    {
        [self.view hideToast];
        [self.view makeToast:@"登录失败" duration:1.0 position:@"center" isShadow:NO];
    }
    [responseString release];
}


- (void)doSomethingAfterLoginSuccessed
{
    signFlag = 0;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"from_comment_to_login"] isEqualToString:@"1"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
    {
        NSLog(@"=========");
        
        [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"from_comment_to_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"from_comment_to_login"] isEqualToString:@"1"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
    {
        NSLog(@">>>>>>>>>>");
        
        [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:@"from_comment_to_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if(_flag_logSuccess == YES)
    {
        NSLog(@"...........");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logininsuccess" object:nil userInfo:nil];
    }
    
    if(commontFlag == 1)
    {
        NSLog(@",,,,,,,,,,,");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginToCommentClick" object:nil];
    }
    else
    {
        NSLog(@"'''''''''''");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginToCommentClick2" object:nil];
    }
    commontFlag = 0;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([_delegate respondsToSelector:@selector(UserNameDidLogInSuccess)]) {
        [_delegate UserNameDidLogInSuccess];
    }
}

- (NSString *)encodeAccountWithName:(NSString*)username password:(NSString *)password
{
    NSRange range;
    range.length = 2;
    range.location = 0;
    NSString *s1 = [username substringWithRange:range];
    NSString *s2 = [password substringWithRange:range];
    range.length = 2;
    range.location = [username length]-2;
    NSString *s3 = [username substringWithRange:range];
    
    range.length = 2;
    range.location = [password length]-2;
    NSString *s4 = [password substringWithRange:range];
    
    
    NSString *myOnlyString = [NSString stringWithFormat:@"%@%@%@%@",s1,s2,s3,s4];
    NSString *str = [self md5:myOnlyString];
    NSString *outStr = [self md5:str];
    return outStr;
    
}

-(NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr,strlen(cStr), result );
    
    NSString *outStr = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        result[0], result[1], result[2], result[3],
                        result[4], result[5], result[6], result[7],
                        result[8], result[9], result[10], result[11],
                        result[12], result[13], result[14], result[15]
                        ];
    return outStr;
}




#pragma mark -
#pragma mark --- tap
-(void)tap:(id)sender
{
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    [_scrollViewww setContentOffset:CGPointZero animated:YES];
}

-(void)clickBackButton:(id)sender
{
    signFlag = 0;

    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"from_comment_to_login"] isEqualToString:@"1"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"from_comment_to_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"from_comment_to_login"] isEqualToString:@"1"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] != YES)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:@"from_comment_to_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if(_flag_logSuccess == YES)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logininsuccess" object:nil userInfo:nil];
    }
    
    if(commontFlag == 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginToCommentClick" object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginToCommentClick2" object:nil];
    }
    
    commontFlag = 0;
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    QY_VIEW_RELEASE(_scrollViewww);
    QY_VIEW_RELEASE(_buttonback);
    QY_VIEW_RELEASE(_usernameTextField);
    QY_VIEW_RELEASE(_passwordTextField);
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
