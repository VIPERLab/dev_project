//
//  RegisterByPhoneViewController.m
//  QYER
//
//  Created by Leno on 14-6-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "RegisterByPhoneViewController.h"

#import "RegisterVerifyViewController.h"

#import "MobClick.h"
#import "Reachability.h"
#import "Account.h"
#import "Toast+UIView.h"

#define     height_headerview           (ios7 ? (44+20) : 44)

@interface RegisterByPhoneViewController ()

@end

@implementation RegisterByPhoneViewController

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
    
    
    UIView * viewwww = [[UIView alloc]initWithFrame:CGRectMake(0, height_headerview, 320, self.view.frame.size.height - height_headerview)];
    [viewwww setBackgroundColor:RGB(232, 243, 248)];
    [self.view addSubview:viewwww];
    [viewwww release];
    
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [viewwww addSubview:control];
    control.backgroundColor = [UIColor clearColor];
    [control addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [control release];
    
    UIView * countryBackView = [[UIView alloc]initWithFrame:CGRectMake(0, height_headerview + 10, 320, 44)];
    [countryBackView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:countryBackView];
    [countryBackView release];
    
    
    UIImage * white = [UIImage imageNamed:@"whitee_bg"];
    UIImage * grayy = [UIImage imageNamed:@"grayyy_bg"];
    
    
    UIButton * countryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [countryBtn setFrame:CGRectMake(0,0, 320, 44)];
    [countryBtn setBackgroundColor:[UIColor clearColor]];
    [countryBtn setBackgroundImage:white forState:UIControlStateNormal];
    [countryBtn setBackgroundImage:grayy forState:UIControlStateHighlighted];
    [countryBtn addTarget:self action:@selector(chooseCountry) forControlEvents:UIControlEventTouchUpInside];
    [countryBackView addSubview:countryBtn];
    
    
    _numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 53, 44)];
    [_numberLabel setBackgroundColor:[UIColor clearColor]];
    [_numberLabel setText:@"+86"];
    [_numberLabel setTextColor:RGB(68, 68, 68)];
    [_numberLabel setTextAlignment:NSTextAlignmentCenter];
    [_numberLabel setFont:[UIFont systemFontOfSize:15]];
    [countryBtn addSubview:_numberLabel];
    
    
    UIImageView * lineee = [[UIImageView alloc]initWithFrame:CGRectMake(54, 3, 1, 38)];
    [lineee setBackgroundColor:[UIColor clearColor]];
    [lineee setImage:[UIImage imageNamed:@"phoneRegister_line"]];
    [countryBtn addSubview:lineee];
    [lineee release];
    
    _countryLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 0, 160, 44)];
    [_countryLabel setBackgroundColor:[UIColor clearColor]];
    [_countryLabel setText:@"中国"];
    [_countryLabel setTextColor:RGB(68, 68, 68)];
    [_countryLabel setTextAlignment:NSTextAlignmentCenter];
    [_countryLabel setFont:[UIFont systemFontOfSize:15]];
    [countryBtn addSubview:_countryLabel];
    
    
    UIImageView * arrowImgView = [[UIImageView alloc]initWithFrame:CGRectMake(292, 10, 24, 24)];
    [arrowImgView setBackgroundColor:[UIColor clearColor]];
    [arrowImgView setImage:[UIImage imageNamed:@"phoneRegister_arrow"]];
    [countryBtn addSubview:arrowImgView];
    [arrowImgView release];
    
    
    UIImageView * txfImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, height_headerview + 44 + 20, 320, 44)];
    [txfImgView setUserInteractionEnabled:YES];
    [txfImgView setBackgroundColor:[UIColor clearColor]];
    [txfImgView setImage:white];
    [self.view addSubview:txfImgView];
    [txfImgView release];
    
    
    _phoneNumberTxtField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 300, 44)];
    [_phoneNumberTxtField setDelegate:self];
    [_phoneNumberTxtField setBackgroundColor:[UIColor clearColor]];
    [_phoneNumberTxtField setTextAlignment:NSTextAlignmentLeft];
    [_phoneNumberTxtField setTextColor:RGB(68, 68, 68)];
    [_phoneNumberTxtField setPlaceholder:@"输入您的手机号码"];
    [_phoneNumberTxtField setFont:[UIFont systemFontOfSize:15]];
    _phoneNumberTxtField.returnKeyType = UIReturnKeyNext;
    [_phoneNumberTxtField setKeyboardType:UIKeyboardTypeNumberPad];
    [_phoneNumberTxtField setKeyboardAppearance:UIKeyboardAppearanceLight];
    [_phoneNumberTxtField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txfImgView addSubview:_phoneNumberTxtField];
    
    
    UILabel * infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, height_headerview + 88 + 20 +10, 180, 20)];
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setTextColor:RGB(158, 163, 171)];
    [infoLabel setTextAlignment:NSTextAlignmentLeft];
    [infoLabel setText:@"短信验证码将发送至您的手机"];
    [infoLabel setFont:[UIFont systemFontOfSize:13]];
    [self.view addSubview:infoLabel];
    [infoLabel release];
    
    
    
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (iPhone5) {
        [_nextBtn setFrame:CGRectMake(90, txfImgView.frame.origin.y + 44 + 73, 140, 34)];
    }
    else{
        [_nextBtn setFrame:CGRectMake(90, txfImgView.frame.origin.y + 44 + 53, 140, 34)];
    }
    
    
    [_nextBtn setBackgroundColor:[UIColor clearColor]];
    [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_btn_next"] forState:UIControlStateNormal];
    [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_press_btn_next"] forState:UIControlStateHighlighted];
    [_nextBtn addTarget:self action:@selector(veryingPhoneNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
    
}

-(void)didChooseCountry:(NSString *)country Number:(NSString *)number//用户选择国家及编码
{
    [_numberLabel setText:number];
    [_countryLabel setText:country];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (toBeString.length == 0) {
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_btn_next"] forState:UIControlStateNormal];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_press_btn_next"] forState:UIControlStateHighlighted];
    }
    
    else{
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_btn_next_highlight"] forState:UIControlStateNormal];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_press_btn_next_highlight"] forState:UIControlStateHighlighted];
    }
    
    return YES;
}


-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    NSLog(@"####################");
    [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_btn_next"] forState:UIControlStateNormal];
    [_nextBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_press_btn_next"] forState:UIControlStateHighlighted];
    return YES;
}


-(void)veryingPhoneNumber:(id)sender
{
    if (_phoneNumberTxtField.text.length == 0) {
        
    }
    else{
        NSLog(@"验证..........");
        
        RegisterVerifyViewController * verifyVC = [[RegisterVerifyViewController alloc]init];
        verifyVC.userPhoneNumber = [NSString stringWithFormat:@"%@ %@",_numberLabel.text,_phoneNumberTxtField.text];
        verifyVC.verifyingCode = [NSString stringWithFormat:@"%d",123456];
        [self.navigationController pushViewController:verifyVC animated:YES];
        [verifyVC release];
    }
}



-(void)chooseCountry
{
    CountryNumberViewController * countryVC = [[CountryNumberViewController alloc]init];
    [countryVC setDelegate:self];
    [self presentViewController:countryVC animated:YES completion:nil];
    [countryVC release];
}

-(void)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tap:(id)sender
{
    [_phoneNumberTxtField resignFirstResponder];
}


-(void)dealloc
{
    QY_VIEW_RELEASE(_buttonback);
    QY_VIEW_RELEASE(_numberLabel);
    QY_VIEW_RELEASE(_countryLabel);
    QY_VIEW_RELEASE(_phoneNumberTxtField);
    
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
