//
//  CityRegisterViewController.m
//  CityGuide
//
//  Created by lide on 13-3-9.
//  Copyright (c) 2013年 com.qyer. All rights reserved.
//

#import "CityRegisterViewController.h"
#import <CommonCrypto/CommonDigest.h>   //md5
#import "ASIFormDataRequest.h"
#import "Toast+UIView.h"
#import "NSString+SBJSON.h"
//#import "CheckNetStatus.h"
#import "MobClick.h"
#import "Reachability.h"
//#import "QYSignConstant.h"
//#import "AFJSONRequestOperation.h"
//#import "AFHTTPClient.h"
//#import "MBProgressHUD.h"
//#import "NSString+MD5.h"


#define getdatamaxtime 10    //注册时-请求超时时间

#define     offsetY (iPhone5 ? 20:40)


@interface CityRegisterViewController ()

@end




@implementation CityRegisterViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MobClick beginLogPageView:@"注册"];
    
    //[_emailTextField becomeFirstResponder];
    [_emailTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.3];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    zhuceFlag = 0;
    
    [MobClick endLogPageView:@"注册"];
    
    
    [self.view hideToast];
    [self.view hideToastActivity];
}



#pragma mark - private

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

- (void)clickRegisterButton:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        
        if(ios7)
        {
            _inputImageView.frame = CGRectMake((320-584/2)/2, 194/2, 584/2, 266/2);
        }
        else
        {
            _inputImageView.frame = CGRectMake((320-584/2)/2, 33+46, 584/2, 266/2);
        }
        button_register.frame = CGRectMake(40, _inputImageView.frame.origin.y + _inputImageView.frame.size.height + 110/2, 240, 41);
        
    } completion:^(BOOL finished){
        
    }];
    
    
    
    
    NSLog(@" 注册的用户名 -- : %@",_usernameTextField.text);
    NSLog(@" 注册的密码 ---- : %@",_passwordTextField.text);
    NSLog(@" 注册的邮箱 ---- : %@",_emailTextField.text);
    
    
    if(_emailTextField.text.length == 0)
    {
        [self.view hideToast];
        [self.view makeToast:@"请完整填写" duration:1 position:@"center" isShadow:NO];
        
    }
    else if(_usernameTextField.text.length == 0)
    {
        [self.view hideToast];
        [self.view makeToast:@"请完整填写" duration:1 position:@"center" isShadow:NO];
        
    }
    else if(_passwordTextField.text.length == 0)
    {
        [self.view hideToast];
        [self.view makeToast:@"请完整填写" duration:1 position:@"center" isShadow:NO];
        
    }
    else if([_passwordTextField.text length] > 5  && [_usernameTextField.text length] >= 2  && [_emailTextField.text length] >= 5)
    {
        //if([checkNetStatus netStatus])
        if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)
        {
            if(zhuceFlag == 0)
            {
                zhuceFlag = 1;
                
                [self.view hideToast];
                [self.view makeToast:@"正在注册..." duration:0 position:@"center" isShadow:NO];
                
                [self performSelector:@selector(doRegister) withObject:nil afterDelay:0];
            }
        }
        else
        {
            [self.view hideToast];
            [self.view makeToast:@"请检查网络连接" duration:1 position:@"center" isShadow:NO];
            
        }
    }
    else
    {
        [self.view hideToast];
        [self.view makeToast:@"输入有误" duration:1 position:@"center" isShadow:NO];
    }
}


-(void)doRegister
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/qyer/user/signup",DomainName];
    
    NSString *account_s = [self encodeAccountWithName:_usernameTextField.text password:_passwordTextField.text];
    
    [_emailTextField resignFirstResponder];
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    ASIFormDataRequest *myRequest;
    myRequest  = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    myRequest.delegate = self;
    myRequest.shouldRedirect = YES; //网页自动跳转[例:从'go2eu'跳转到'qyer']!!
    myRequest.timeOutSeconds = getdatamaxtime;
    [myRequest addPostValue:_usernameTextField.text forKey:@"username"];
    [myRequest addPostValue:_passwordTextField.text forKey:@"password"];
    [myRequest addPostValue:_emailTextField.text forKey:@"email"];
    [myRequest addPostValue:account_s forKey:@"account_s"];
    [myRequest addPostValue:ClientId_QY forKey:@"client_id"];
    [myRequest addPostValue:ClientSecret_QY forKey:@"client_secret"];
    
    
    NSString *lat_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lat_user"]];
    NSString *lon_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lon_user"]];
    if (![lat_user isEqualToString:@""] && ![lon_user isEqualToString:@""]) {
        [myRequest setPostValue:lat_user forKey:@"lat"];
        [myRequest setPostValue:lon_user forKey:@"lon"];
    }
    
    [myRequest startAsynchronous];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //***(1)Use when fetching text data
    NSString *responseString2 = [request responseString];
    NSMutableString *responseString = [[NSMutableString alloc]initWithString:responseString2];
    //NSLog(@"responseString ==(requestFinished)== %@",responseString);

    //***(2)Use when fetching binary data
    //NSData *responseData = [request responseData];
    
    
    zhuceFlag = 0;
    
    if([responseString rangeOfString:@"timed out"].location != NSNotFound)
    {
        [self.view hideToast];
        [self.view makeToast:@"注册失败" duration:1.0 position:@"center" isShadow:NO];
    }
    else
    {
        NSMutableDictionary *dic = [responseString JSONValue];
        NSString *status = [NSString stringWithFormat:@"%@",[dic valueForKey:@"status"]];
        NSString *info = [NSString stringWithFormat:@"%@",[dic objectForKey:@"info"]];
        NSLog(@" dic = %@",dic);
        NSLog(@" info = %@",info);
        
        if(status && [status isEqualToString:@"1"])
        {
            [MobClick event:@"signupSucceed"];
            
            [self.view hideToast];
            [self.view makeToast:@"注册成功" duration:1 position:@"center" isShadow:NO];
            
            [self.navigationController popViewControllerAnimated:YES];
            //[self performSelector:@selector(doBack) withObject:nil afterDelay:1.5];
            [self performSelector:@selector(postZhuceStatus) withObject:nil afterDelay:1.6];
        }
        else if(info)
        {
            [self.view hideToast];
            [self.view makeToast:info duration:1 position:@"center" isShadow:NO];
        }
        else
        {
            [self.view hideToast];
            [self.view makeToast:@"注册失败" duration:1 position:@"center" isShadow:NO];
        }
    }
    
    [responseString release];
}
-(void)postZhuceStatus
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_usernameTextField.text forKey:@"username"];
    [dic setObject:_passwordTextField.text forKey:@"password"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REGISTER_SUCCESS" object:nil userInfo:dic];
    [dic release];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSLog(@"requestFailed !!!!  requestFailed !!!!");
    NSString *responseString2 = [request responseString];
    NSMutableString *responseString = [[NSMutableString alloc] initWithString:responseString2];
    
    [self.view hideToast];
    [self.view makeToast:@"网络错误,请稍候再试" duration:1.0 position:@"center" isShadow:NO];
    
    zhuceFlag = 0;
    
    [responseString release];
}


#pragma mark - super

- (id)init
{
    self = [super init];
    if(self != nil)
    {
    }
    return self;
}

- (void)dealloc
{
    QY_VIEW_RELEASE(_inputImageView);
    QY_VIEW_RELEASE(_emailLabel);
    QY_VIEW_RELEASE(_emailTextField);
    QY_VIEW_RELEASE(_usernameLabel);
    QY_VIEW_RELEASE(_usernameTextField);
    QY_VIEW_RELEASE(_passwordLabel);
    QY_VIEW_RELEASE(_passwordTextField);
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    [self.view setMultipleTouchEnabled:NO];
    
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
    if(ios7)
    {
        _headView.frame = CGRectMake(0, 0, 320, 46+20);
    }
    _headView.backgroundColor = [UIColor clearColor];
    _headView.userInteractionEnabled = YES;
    [self.view addSubview:_headView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, 200, 30)];
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    if(ios7)
    {
        _titleLabel.frame = CGRectMake(60, 10+20, 200, 26);
    }
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_headView addSubview:_titleLabel];
    
    
    
    
    UIButton *button_cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    button_cancel.frame = CGRectMake(6, 2, 40, 40);
    if(ios7)
    {
        button_cancel.frame = CGRectMake(6, 2+20, 40, 40);
    }
    button_cancel.backgroundColor = [UIColor clearColor];
    [button_cancel setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    //[_cancelButton setTitleColor:[UIColor colorWithRed:50.0 / 255.0 green:50.0 / 255.0 blue:50.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    //[_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    //_cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [button_cancel addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:button_cancel];
    
    
    _titleLabel.text = @"注册";
    _titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
    //_titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    //_titleLabel.shadowOffset = CGSizeMake(0, 1);
    
    
    
    float positionY = 46;
    if(ios7)
    {
        positionY = 46+20;
    }
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, positionY, 320, [[UIScreen mainScreen] bounds].size.height - positionY)];
    self.view.userInteractionEnabled = YES;
    [self.view addSubview:control];
    [self.view bringSubviewToFront:_headView];
    control.backgroundColor = [UIColor clearColor];
    [control addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [control release];
    
    
    
    _inputImageView = [[UIImageView alloc] initWithFrame:CGRectMake((320-584/2)/2, 46+33, 584/2, 266/2)];
    if(ios7)
    {
        _inputImageView.frame = CGRectMake((320-584/2)/2, 194/2, 584/2, 266/2);
    }
    _inputImageView.backgroundColor = [UIColor clearColor];
    _inputImageView.image = [UIImage imageNamed:@"bg_register_input.png"];
    _inputImageView.userInteractionEnabled = YES;
    [self.view addSubview:_inputImageView];
    
    _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, 60, 20)];
    _emailLabel.backgroundColor = [UIColor clearColor];
    _emailLabel.textColor = [UIColor colorWithRed:207/255. green:207/255. blue:207/255. alpha:1.];
    _emailLabel.text = @"邮箱";
    _emailLabel.font = [UIFont systemFontOfSize:15];
    [_inputImageView addSubview:_emailLabel];
    
    _emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 12, 220, 20)];
    _emailTextField.delegate = self;
    _emailTextField.backgroundColor = [UIColor clearColor];
    _emailTextField.placeholder = @"请填写真实邮箱";
    _emailTextField.font = [UIFont systemFontOfSize:15];
    _emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailTextField.returnKeyType = UIReturnKeyNext;
    _emailTextField.tag = 1001;
    _emailTextField.textColor = [UIColor whiteColor];
    _emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_inputImageView addSubview:_emailTextField];
    
    _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 56, 60, 20)];
    _usernameLabel.backgroundColor = [UIColor clearColor];
    _usernameLabel.textColor = [UIColor colorWithRed:207/255. green:207/255. blue:207/255. alpha:1.];
    _usernameLabel.text = @"用户名";
    _usernameLabel.font = [UIFont systemFontOfSize:15];
    [_inputImageView addSubview:_usernameLabel];
    
    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 56, 220, 20)];
    _usernameTextField.delegate = self;
    _usernameTextField.backgroundColor = [UIColor clearColor];
    _usernameTextField.placeholder = @"注册后无法修改";
    _usernameTextField.font = [UIFont systemFontOfSize:15];
    _usernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _usernameTextField.returnKeyType = UIReturnKeyNext;
    _usernameTextField.tag = 1002;
    _usernameTextField.textColor = [UIColor whiteColor];
    _usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_inputImageView addSubview:_usernameTextField];
    
    _passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 100, 60, 20)];
    _passwordLabel.backgroundColor = [UIColor clearColor];
    _passwordLabel.textColor = [UIColor colorWithRed:207/255. green:207/255. blue:207/255. alpha:1];
    _passwordLabel.text = @"密码";
    _passwordLabel.font = [UIFont systemFontOfSize:15];
    [_inputImageView addSubview:_passwordLabel];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 100, 220, 20)];
    _passwordTextField.delegate = self;
    _passwordTextField.backgroundColor = [UIColor clearColor];
    _passwordTextField.placeholder = @"不少于6位";
    _passwordTextField.font = [UIFont systemFontOfSize:15];
    _passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.returnKeyType = UIReturnKeyDone;
    _passwordTextField.tag = 1003;
    _passwordTextField.textColor = [UIColor whiteColor];
    _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_inputImageView addSubview:_passwordTextField];
    
    
    button_register = [UIButton buttonWithType:UIButtonTypeCustom];
    button_register.frame = CGRectMake(40, _inputImageView.frame.origin.y + _inputImageView.frame.size.height + 110/2, 240, 41);
    button_register.backgroundColor = [UIColor clearColor];
    [button_register setBackgroundImage:[UIImage imageNamed:@"btn_logout.png"] forState:UIControlStateNormal];
    //[button_register setTitle:@"注册" forState:UIControlStateNormal];
    [button_register setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button_register.titleLabel.font = [UIFont systemFontOfSize:16];
    button_register.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    button_register.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [button_register addTarget:self action:@selector(clickRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_register];
    
    
    [self.view bringSubviewToFront:_headView];
}


#pragma mark -
#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.2 animations:^{
        
        if(textField.tag == 1001)
        {
            if(ios7)
            {
                _inputImageView.frame = CGRectMake((320-584/2)/2, 194/2, 584/2, 266/2);
            }
            else
            {
                _inputImageView.frame = CGRectMake((320-584/2)/2, 33+46, 584/2, 266/2);
            }
        }
        else if(textField.tag == 1002)
        {
            if(ios7)
            {
                _inputImageView.frame = CGRectMake((320-584/2)/2, 194/2-offsetY, 584/2, 266/2);
            }
            else
            {
                _inputImageView.frame = CGRectMake((320-584/2)/2, 33+46-offsetY, 584/2, 266/2);
            }
        }
        else if(textField.tag == 1003)
        {
            if(ios7)
            {
                _inputImageView.frame = CGRectMake((320-584/2)/2, 194/2-offsetY*2, 584/2, 266/2);
            }
            else
            {
                _inputImageView.frame = CGRectMake((320-584/2)/2, 33+46-offsetY*2, 584/2, 266/2);
            }
        }
        button_register.frame = CGRectMake(40, _inputImageView.frame.origin.y + _inputImageView.frame.size.height + 110/2, 240, 41);
        
    } completion:^(BOOL finished){
        
    }];
    
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == _emailTextField)
    {
        [_usernameTextField becomeFirstResponder];
    }
    else if(textField == _usernameTextField)
    {
        [_passwordTextField becomeFirstResponder];
    }
    else
    {
        [self clickRegisterButton:nil];
    }
    
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
//    checkNetStatus = [[CheckNetStatus alloc] init];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark --- tap
- (void)tap:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        
        if(ios7)
        {
            _inputImageView.frame = CGRectMake((320-584/2)/2, 194/2, 584/2, 266/2);
        }
        else
        {
            _inputImageView.frame = CGRectMake((320-584/2)/2, 33+46, 584/2, 266/2);
        }
        button_register.frame = CGRectMake(40, _inputImageView.frame.origin.y + _inputImageView.frame.size.height + 110/2, 240, 41);
        
    } completion:^(BOOL finished){
        
    }];
    
    
    [_emailTextField resignFirstResponder];
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
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
#pragma mark --- clickCancelButton
- (void)clickCancelButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doRegister) object:nil];
}



@end

