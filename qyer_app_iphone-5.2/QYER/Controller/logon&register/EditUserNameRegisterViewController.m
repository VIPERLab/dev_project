//
//  EditUserNameRegisterViewController.m
//  QYER
//
//  Created by Leno on 14-5-23.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "EditUserNameRegisterViewController.h"

#import "QYAPIClient.h"
#import "Toast+UIView.h"
#import "Account.h"

@interface EditUserNameRegisterViewController ()

@end

@implementation EditUserNameRegisterViewController

@synthesize delegate = _delegate;
@synthesize infoDictionary = _infoDictionary;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc]init];
        self.infoDictionary = item;
        [item release];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(([[[UIDevice currentDevice] systemVersion] doubleValue] - 7. >= 0))
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 46)];
    if(ios7)
    {
        _headView.frame = CGRectMake(0, 0, 320, 46+20);
    }
    _headView.backgroundColor = [UIColor clearColor];
    _headView.image = [UIImage imageNamed:@"home_head"];
    _headView.userInteractionEnabled = YES;
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
    
    _backButton.hidden = YES;
    _titleLabel.text = @"修改用户名";
    
    _cancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _cancelButton.frame = CGRectMake(6, 6, 47, 33);
    if(ios7)
    {
        _cancelButton.frame = CGRectMake(6, 6+20, 47, 33);
    }
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"btn_more_cancel.png"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
    
    
    UIView * clearBackView = [[UIView alloc]initWithFrame:CGRectMake(14, 83, 292, 44)];
    if (ios7) {
        [clearBackView setFrame:CGRectMake(14, 102, 292, 44)];
    }
    [clearBackView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:clearBackView];
    [clearBackView release];
    
    
    UIView * inputBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 292, 44)];
    [inputBackView setBackgroundColor:[UIColor whiteColor]];
    [inputBackView setAlpha:0.2];
    [clearBackView addSubview:inputBackView];
    [inputBackView release];
    
    UILabel * leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    [leftLabel setText:@"   用户名"];
    [leftLabel setTextAlignment:NSTextAlignmentLeft];
    [leftLabel setTextColor:[UIColor whiteColor]];
    [leftLabel setFont:[UIFont systemFontOfSize:15]];
    [clearBackView addSubview:leftLabel];
    [leftLabel release];
    
    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(102, 0, 180, 44)];
    _usernameTextField.delegate = self;
    _usernameTextField.placeholder = @"输入新用户名";
    [_usernameTextField setText:[self.infoDictionary valueForKey:@"userName"]];
    _usernameTextField.textColor = [UIColor whiteColor];
    _usernameTextField.font = [UIFont systemFontOfSize:15];
    _usernameTextField.returnKeyType = UIReturnKeyDone;
    _usernameTextField.backgroundColor = [UIColor clearColor];
    _usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [clearBackView addSubview:_usernameTextField];
 
    
    UIButton *button_login = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    button_login.frame = CGRectMake( 90, clearBackView.frame.origin.y + 44 + 55, 139, 84/2);
    button_login.backgroundColor = [UIColor clearColor];
    [button_login setBackgroundImage:[UIImage imageNamed:@"登录.png"] forState:UIControlStateNormal];
    [button_login addTarget:self action:@selector(clickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_login];
    
    [self performSelector:@selector(showErrorCode) withObject:nil afterDelay:1.2f];
}

-(void)showErrorCode
{
    [self.view makeToast:[self.infoDictionary valueForKey:@"errorInfo"] duration:1.2f position:@"center" isShadow:NO];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clickLoginButton:nil];
    return YES;
}

-(void)clickLoginButton:(id)sender
{
    [_usernameTextField resignFirstResponder];

    if (_usernameTextField.text.length < 2 && _usernameTextField.text.length > 15) {
        [self.view makeToast:@"用户名长度必须在2到15个字符之间" duration:1.0 position:@"center" isShadow:NO];
    }
    
    else {
        [self.view makeToastActivity];
        
        NSLog(@"#### %@ #### %@ #### %@ #### %@ ####",[self.infoDictionary valueForKey:@"type"],[self.infoDictionary valueForKey:@"userToken"],[self.infoDictionary valueForKey:@"userID"],_usernameTextField.text);
        
        [[QYAPIClient sharedAPIClient]sendSNSToServerWithType:[self.infoDictionary valueForKey:@"type"]
                                                 Access_Token:[self.infoDictionary valueForKey:@"userToken"]
                                                          UID:[self.infoDictionary valueForKey:@"userID"]
                                                 SNS_Username:_usernameTextField.text
                                                      success:^(NSDictionary *dic) {
                                                                                                                    
                                                          [self.view hideToastActivity];
                                                          
                                                          NSInteger statusType = [[dic objectForKey:@"status"]integerValue];
                                                          
                                                          if (statusType == 1) {
                                                              
                                                              [self.view makeToast:@"注册成功" duration:1.2f position:@"center" isShadow:NO];
                                                              
                                                              NSDictionary * userInfo = [dic objectForKey:@"data"];
                                                              NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
                                                              
                                                              [myDefault setObject:[NSNumber numberWithBool:YES] forKey:@"qyerlogin"];
                                                              [myDefault setValue:[userInfo valueForKey:@"access_token"] forKey:@"user_access_token"];
                                                              [myDefault setObject:[userInfo objectForKey:@"user_id"] forKey:@"userid"];
                                                              [myDefault setValue:[userInfo objectForKey:@"username"] forKey:@"username"];
                                                              [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"usericon"];
                                                              [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"userid_im"];
                                                              [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"im_user_id"];
                                                              [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"avatar"];
                                                              [myDefault setValue:[userInfo objectForKey:@"title"] forKey:@"title"];
                                                              [myDefault synchronize];
                                                              
                                                              [[Account sharedAccount] initAccountWithDic:[dic objectForKey:@"data"]];

                                                              [self performSelector:@selector(didRegisterSuccess) withObject:nil afterDelay:1];
                                                          }
                                                          
                                                          else{
                                                              
                                                              NSString * infooo = [dic objectForKey:@"info"];
                                                              [self.view makeToast:infooo duration:1.2f position:@"center" isShadow:NO];
                                                          }
                                                          
//                                                          NSDictionary * dicttt = [dic objectForKey:@"data"];
//                                                          NSInteger resultType = [[dicttt objectForKey:@"result"]integerValue];
//                                                          
//                                                          if (resultType == 0) {
//                                                              [self.view makeToast:@"授权失败" duration:1.2f position:@"center" isShadow:NO];
//                                                          }
//                                                          
//                                                          if (resultType == 1) {
//                                                              [self.view makeToast:@"注册成功" duration:1.2f position:@"center" isShadow:NO];
//                                                              
//                                                              NSDictionary * userInfo = [[dic objectForKey:@"data"] objectForKey:@"user"];
//                                                              NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
//                                                              [myDefault setObject:[NSNumber numberWithBool:YES] forKey:@"qyerlogin"];
//                                                              [myDefault setValue:[userInfo valueForKey:@"access_token"] forKey:@"user_access_token"];
//                                                              [myDefault setObject:[userInfo objectForKey:@"user_id"] forKey:@"userid"];
//                                                              [myDefault setValue:[userInfo objectForKey:@"username"] forKey:@"username"];
//                                                              [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"usericon"];
//                                                              [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"userid_im"];
//                                                              [myDefault setValue:[userInfo objectForKey:@"im_user_id"] forKey:@"im_user_id"];
//                                                              [myDefault setValue:[userInfo objectForKey:@"avatar"] forKey:@"avatar"];
//                                                              [myDefault synchronize];
//                                                              
//                                                              [[Account sharedAccount] initAccountWithDic:[dic objectForKey:@"data"]];
//                                                              
//                                                              [self performSelector:@selector(didRegisterSuccess) withObject:nil afterDelay:1];
//                                                          }
//                                                          
//                                                          if (resultType == 2) {
//                                                              [self.view makeToast:@"授权用户名已存在" duration:1.2f position:@"center" isShadow:NO];
//                                                          }
                                                          
                                                      } failed:^{
                                                          [self.view hideToastActivity];
                                                          [self.view makeToast:@"网络错误，请稍后重试" duration:1.2f position:@"center" isShadow:NO];
                                                      }];
    }
    
}



-(void)didRegisterSuccess
{
    if ([_delegate respondsToSelector:@selector(didEditUserNameSuccess)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [_delegate didEditUserNameSuccess];
    }
}


-(void)clickCancelButton:(id)sender
{
    [MobClick event:@"loginCancel"];
    [self dismissViewControllerAnimated:YES completion:^{
    
    }];
}


-(void)dealloc
{    
    QY_VIEW_RELEASE(_cancelButton);
    QY_VIEW_RELEASE(_usernameTextField);
    
    self.infoDictionary = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
