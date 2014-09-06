//
//  VerifyCodeViewController.m
//  QYER
//
//  Created by Leno on 14-6-4.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "VerifyCodeViewController.h"
#import "ChangePassWordViewController.h"

#define     height_headerview           (ios7 ? (44+20) : 44)

#import "Toast+UIView.h"

@interface VerifyCodeViewController ()

@end

@implementation VerifyCodeViewController

@synthesize userPhoneNumber = _userPhoneNumber;
@synthesize verifyingCode = _verifyingCode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.userPhoneNumber = [NSString string];
        self.verifyingCode = [NSString string];
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
    _titleLabel.text = @"找回密码";
    
    
    UIView * viewwww = [[UIView alloc]initWithFrame:CGRectMake(0, height_headerview, 320, self.view.frame.size.height - height_headerview)];
    [viewwww setBackgroundColor:RGB(232, 243, 248)];
    [self.view addSubview:viewwww];
    [viewwww release];
    
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [viewwww addSubview:control];
    control.backgroundColor = [UIColor clearColor];
    [control addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [control release];
    
    UIImage * white = [UIImage imageNamed:@"whitee_bg"];

    UILabel * infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, height_headerview +10, 300, 20)];
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setTextColor:RGB(158, 163, 171)];
    [infoLabel setTextAlignment:NSTextAlignmentLeft];
    [infoLabel setText:[NSString stringWithFormat:@"短信验证码已发送至 %@",self.userPhoneNumber]];
    [infoLabel setFont:[UIFont systemFontOfSize:13]];
    [self.view addSubview:infoLabel];
    [infoLabel release];
    
    UIImageView * txfImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, height_headerview + 10 + 20 +10, 320, 44)];
    [txfImgView setUserInteractionEnabled:YES];
    [txfImgView setBackgroundColor:[UIColor clearColor]];
    [txfImgView setImage:white];
    [self.view addSubview:txfImgView];
    [txfImgView release];
    
    _codeTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 202, 44)];
    [_codeTextField setDelegate:self];
    [_codeTextField setBackgroundColor:[UIColor clearColor]];
    [_codeTextField setTextAlignment:NSTextAlignmentLeft];
    [_codeTextField setTextColor:RGB(102, 102, 102)];
    [_codeTextField setPlaceholder:@"输入收到的验证码"];
    [_codeTextField setFont:[UIFont systemFontOfSize:15]];
    _codeTextField.returnKeyType = UIReturnKeyNext;
    [_codeTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [_codeTextField setKeyboardAppearance:UIKeyboardAppearanceLight];
    [_codeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txfImgView addSubview:_codeTextField];
    
 
    UIImageView * lineee = [[UIImageView alloc]initWithFrame:CGRectMake(222, 3, 1, 38)];
    [lineee setBackgroundColor:[UIColor clearColor]];
    [lineee setImage:[UIImage imageNamed:@"phoneRegister_line"]];
    [txfImgView addSubview:lineee];
    [lineee release];
    
    
    UIButton * resendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [resendBtn setTag:10101];
    [resendBtn setBackgroundColor:[UIColor clearColor]];
    [resendBtn setFrame:CGRectMake(223, 0, 97, 44)];
    [resendBtn setTitle:@"重新发送(60)" forState:UIControlStateNormal];
    [resendBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [resendBtn setTitleColor:RGB(158, 163, 171) forState:UIControlStateNormal];
    [resendBtn setUserInteractionEnabled:NO];
    [txfImgView addSubview:resendBtn];
    
    
    
    _nextBtn = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    
    if (iPhone5) {
        [_nextBtn setFrame:CGRectMake(90, txfImgView.frame.origin.y + 44 + 73, 140, 34)];
    }
    else{
        [_nextBtn setFrame:CGRectMake(90, txfImgView.frame.origin.y + 44 + 53, 140, 34)];
    }
    
    
    [_nextBtn setBackgroundColor:[UIColor clearColor]];
    [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_btn_next"] forState:UIControlStateNormal];
    [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_press_btn_next"] forState:UIControlStateHighlighted];
    [_nextBtn addTarget:self action:@selector(veryingCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
    
    _seconds = 0;
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countSeconds:) userInfo:nil repeats:YES];
    
}

-(void)countSeconds:(id)sender
{
    _seconds = _seconds +1;

    UIButton * resendBtn = (UIButton *)[self.view viewWithTag:10101];
    [resendBtn setTitle:[NSString stringWithFormat:@"重新发送(%d)",60-_seconds] forState:UIControlStateNormal];
    
    if (_seconds > 60) {
        
        [resendBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        [resendBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [resendBtn setTitleColor:RGB(44, 179, 122) forState:UIControlStateNormal];
        [resendBtn setTitleColor:RGB(158, 163, 171) forState:UIControlStateHighlighted];
        [resendBtn setUserInteractionEnabled:YES];
        [resendBtn addTarget:self action:@selector(resendCode) forControlEvents:UIControlEventTouchUpInside];
    
        NSTimer  * timer = (NSTimer *)sender;
        [timer invalidate];
    }
}


-(void)resendCode
{
    _seconds = 0;
    
    UIButton * resendBtn = (UIButton *)[self.view viewWithTag:10101];
    [resendBtn setTitle:@"重新发送(60)" forState:UIControlStateNormal];
    [resendBtn setTitleColor:RGB(158, 163, 171) forState:UIControlStateNormal];
    [resendBtn setUserInteractionEnabled:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countSeconds:) userInfo:nil repeats:YES];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (toBeString.length == 0) {
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_btn_next"] forState:UIControlStateNormal];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_press_btn_next"] forState:UIControlStateHighlighted];
    }
    
    else{
        
        //限制输入的验证码字数
        if (toBeString.length>=6) {
            _codeTextField.text = [toBeString substringToIndex:5];
        }
        
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_btn_next_highlight"] forState:UIControlStateNormal];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_press_btn_next_highlight"] forState:UIControlStateHighlighted];
    }
    return YES;
}


-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_btn_next"] forState:UIControlStateNormal];
    [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_press_btn_next"] forState:UIControlStateHighlighted];
    return YES;
}




-(void)veryingCode:(id)sender
{
    if (_codeTextField.text.length != 6) {
        [self.view makeToast:@"请输入6位验证码" duration:1.2f position:@"center" isShadow:NO];
    }
    
    else{
        
        NSLog(@"-------判断验证码是否一致-----------");
        
        if ([_codeTextField.text isEqualToString:self.verifyingCode]) {
            [self.view makeToast:@"验证码一致" duration:0.5f position:@"center" isShadow:NO];
            [self performSelector:@selector(reSetPassWord) withObject:nil afterDelay:0.8];
        }
        else{
            [self.view makeToast:@"验证码错误，请核对后重新输入" duration:1.2f position:@"center" isShadow:NO];
        }
    }
}


-(void)reSetPassWord
{
    ChangePassWordViewController * passWordVC = [[ChangePassWordViewController alloc]init];
    passWordVC.userPhoneNumber = self.userPhoneNumber;
    [self.navigationController pushViewController:passWordVC animated:YES];
    [passWordVC release];
}


-(void)tap:(id)sender
{
    [_codeTextField resignFirstResponder];
}

-(void)dealloc
{
    QY_VIEW_RELEASE(_buttonback);
    QY_VIEW_RELEASE(_codeTextField);
    QY_VIEW_RELEASE(_nextBtn);
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
