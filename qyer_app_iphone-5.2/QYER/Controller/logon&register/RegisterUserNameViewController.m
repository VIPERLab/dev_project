//
//  RegisterUserNameViewController.m
//  QYER
//
//  Created by Leno on 14-6-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "RegisterUserNameViewController.h"

#import "Toast+UIView.h"
#define     height_headerview           (ios7 ? (44+20) : 44)

@interface RegisterUserNameViewController ()

@end

@implementation RegisterUserNameViewController

@synthesize userPhoneNumber = _userPhoneNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

//        self.userPhoneNumber = [NSString string];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height_headerview)];
    _headView.backgroundColor = [UIColor clearColor];
    _headView.userInteractionEnabled = YES;
    _headView.image = [UIImage imageNamed:@"home_head"];
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
    _titleLabel.text = @"注册";
    
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, height_headerview, 320, self.view.frame.size.height - height_headerview)];
    [_scrollView setBackgroundColor:RGB(232, 243, 248)];
    [_scrollView setContentSize:CGSizeMake(320, 600)];
    [_scrollView setScrollEnabled:NO];
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [_scrollView addSubview:control];
    control.backgroundColor = [UIColor clearColor];
    [control addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [control release];
    
    UIImage * white = [UIImage imageNamed:@"whitee_bg"];
    white = [white stretchableImageWithLeftCapWidth:0 topCapHeight:20];
    
    UILabel * infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 300, 20)];
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setTextColor:RGB(158, 163, 171)];
    [infoLabel setTextAlignment:NSTextAlignmentLeft];
    [infoLabel setText:@"输入您的登录用户名及密码"];
    [infoLabel setFont:[UIFont systemFontOfSize:13]];
    [_scrollView addSubview:infoLabel];
    [infoLabel release];
    
    UIImageView * txfImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10 + 20 +10, 320, 88 +44)];
    [txfImgView setUserInteractionEnabled:YES];
    [txfImgView setBackgroundColor:[UIColor clearColor]];
    [txfImgView setImage:white];
    [_scrollView addSubview:txfImgView];
    [txfImgView release];
    
    UIView * gapLine1 = [[UIView alloc]initWithFrame:CGRectMake(10, 44, 310, 1)];
    [gapLine1 setBackgroundColor:RGB(158, 163, 171)];
    [gapLine1 setAlpha:0.5];
    [txfImgView addSubview:gapLine1];
    [gapLine1 release];
    
    UIView * gapLine2 = [[UIView alloc]initWithFrame:CGRectMake(10, 88, 310, 1)];
    [gapLine2 setBackgroundColor:RGB(158, 163, 171)];
    [gapLine2 setAlpha:0.5];
    [txfImgView addSubview:gapLine2];
    [gapLine2 release];
    
    
    _userNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 305, 44)];
    [_userNameTextField setDelegate:self];
    [_userNameTextField setBackgroundColor:[UIColor clearColor]];
    [_userNameTextField setTextAlignment:NSTextAlignmentLeft];
    [_userNameTextField setTextColor:RGB(158, 163, 171)];
    [_userNameTextField setPlaceholder:@"用户名"];
    [_userNameTextField setFont:[UIFont systemFontOfSize:15]];
    _userNameTextField.returnKeyType = UIReturnKeyNext;
    _userNameTextField.secureTextEntry = YES;
    [_userNameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txfImgView addSubview:_userNameTextField];
    
    
    _passWordTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 44, 305, 44)];
    [_passWordTextField setDelegate:self];
    [_passWordTextField setBackgroundColor:[UIColor clearColor]];
    [_passWordTextField setTextAlignment:NSTextAlignmentLeft];
    [_passWordTextField setTextColor:RGB(158, 163, 171)];
    [_passWordTextField setPlaceholder:@"密码长度:6~16位"];
    [_passWordTextField setFont:[UIFont systemFontOfSize:15]];
    _passWordTextField.returnKeyType = UIReturnKeyNext;
    [_passWordTextField setKeyboardType:UIKeyboardTypeAlphabet];
    _passWordTextField.secureTextEntry = YES;
    [_passWordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txfImgView addSubview:_passWordTextField];
    
    
    _passWordRepeatTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 88, 305, 44)];
    [_passWordRepeatTextField setDelegate:self];
    [_passWordRepeatTextField setBackgroundColor:[UIColor clearColor]];
    [_passWordRepeatTextField setTextAlignment:NSTextAlignmentLeft];
    [_passWordRepeatTextField setTextColor:RGB(158, 163, 171)];
    [_passWordRepeatTextField setPlaceholder:@"确认密码"];
    [_passWordRepeatTextField setFont:[UIFont systemFontOfSize:15]];
    _passWordRepeatTextField.returnKeyType = UIReturnKeyDone;
    [_passWordRepeatTextField setKeyboardType:UIKeyboardTypeAlphabet];
    _passWordRepeatTextField.secureTextEntry = YES;
    [_passWordRepeatTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txfImgView addSubview:_passWordRepeatTextField];

    
    UIButton * checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkBtn setFrame:CGRectMake( 233,10 + 20 +10 + 88 +44 +10, 23, 23)];
    [checkBtn setBackgroundColor:[UIColor clearColor]];
    [checkBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_unchecked"] forState:UIControlStateNormal];
    [checkBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_checked"] forState:UIControlStateSelected];
    [checkBtn addTarget:self action:@selector(shouldShowPassword:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:checkBtn];
    
    UILabel * showLabel = [[UILabel alloc]initWithFrame:CGRectMake(260,10 + 20 +10 + 88 +44 +10, 55, 23)];
    [showLabel setBackgroundColor:[UIColor clearColor]];
    [showLabel setTextColor:RGB(158, 163, 171)];
    [showLabel setTextAlignment:NSTextAlignmentLeft];
    [showLabel setText:@"显示密码"];
    [showLabel setFont:[UIFont systemFontOfSize:13]];
    [_scrollView addSubview:showLabel];
    [showLabel release];
    
    
    _doneBtn = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    if (iPhone5) {
        [_doneBtn setFrame:CGRectMake(90, 10 + 20 +10 + 88 + 44 + 73, 140, 34)];
    }
    else{
        [_doneBtn setFrame:CGRectMake(90,10 + 20 +10 + 88 + 44 + 48, 140, 34)];
    }
    [_doneBtn setSelected:NO];
    [_doneBtn setBackgroundColor:[UIColor clearColor]];
    [_doneBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_btn_finish_highlight"] forState:UIControlStateNormal];
    [_doneBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_press_btn_finish_highlight"] forState:UIControlStateHighlighted];
    [_doneBtn addTarget:self action:@selector(registerrrrrrrr) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_doneBtn];

}

-(void)shouldShowPassword:(id)sender
{
    UIButton * checkBtn = (UIButton *)sender;
    
    BOOL isSelected = checkBtn.selected;
    
    [checkBtn setSelected:!isSelected];
    
    if (!isSelected) {
        [_passWordTextField setSecureTextEntry:NO];
        [_passWordRepeatTextField setSecureTextEntry:NO];
    }
    else
    {
        [_passWordTextField setSecureTextEntry:YES];
        [_passWordRepeatTextField setSecureTextEntry:YES];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (!iPhone5) {
        if ([textField isEqual:_userNameTextField]) {
            [_scrollView setContentOffset:CGPointZero animated:YES];
        }
        if ([textField isEqual:_passWordTextField]) {
            [_scrollView setContentOffset:CGPointZero animated:YES];
        }
        if ([textField isEqual:_passWordRepeatTextField]) {
            [_scrollView setContentOffset:CGPointMake(0, 44) animated:YES];
        }
    }
    
    NSLog(@"##########");
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_userNameTextField])
    {
        [_passWordTextField becomeFirstResponder];
    }
    if ([textField isEqual:_passWordTextField])
    {
        [_passWordRepeatTextField becomeFirstResponder];
    }
    if ([textField isEqual:_passWordRepeatTextField] && _passWordRepeatTextField.text.length >0)
    {
        [self registerrrrrrrr];
    }
    
    return YES;
}

    
-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}



-(void)registerrrrrrrr
{
    NSString * userNameText = _userNameTextField.text;
    NSString * passWordText = _passWordTextField.text;
    NSString * passWordRepeatText = _passWordRepeatTextField.text;
    
    if ([userNameText isEqualToString:@""] || [passWordText isEqualToString:@""] || [passWordRepeatText isEqualToString:@""]) {
        [self.view makeToast:@"用户名及密码不能为空" duration:1.2f position:@"center" isShadow:NO];
    }
}

    
-(void)clickBackButton:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)tap:(id)sender
{
    [_passWordTextField resignFirstResponder];
    [_passWordRepeatTextField resignFirstResponder];
    
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

-(BOOL) isEmpty:(NSString *) str {
    
    if (!str) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}

-(void)dealloc
{
    QY_SAFE_RELEASE(_userPhoneNumber);
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
