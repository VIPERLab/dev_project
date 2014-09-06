//
//  ChangePassWordViewController.m
//  QYER
//
//  Created by Leno on 14-6-4.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "ChangePassWordViewController.h"

#import "Toast+UIView.h"

#define     height_headerview           (ios7 ? (44+20) : 44)

@interface ChangePassWordViewController ()

@end

@implementation ChangePassWordViewController

@synthesize userPhoneNumber = _userPhoneNumber;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    white = [white stretchableImageWithLeftCapWidth:0 topCapHeight:20];
    
    UILabel * infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, height_headerview +10, 300, 20)];
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setTextColor:RGB(158, 163, 171)];
    [infoLabel setTextAlignment:NSTextAlignmentLeft];
    [infoLabel setText:@"输入您要设置的新密码"];
    [infoLabel setFont:[UIFont systemFontOfSize:13]];
    [self.view addSubview:infoLabel];
    [infoLabel release];
    
    UIImageView * txfImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, height_headerview + 10 + 20 +10, 320, 88)];
    [txfImgView setUserInteractionEnabled:YES];
    [txfImgView setBackgroundColor:[UIColor clearColor]];
    [txfImgView setImage:white];
    [self.view addSubview:txfImgView];
    [txfImgView release];

    UIView * gapLine = [[UIView alloc]initWithFrame:CGRectMake(10, 44, 310, 1)];
    [gapLine setBackgroundColor:RGB(158, 163, 171)];
    [gapLine setAlpha:0.7];
    [txfImgView addSubview:gapLine];
    [gapLine release];
    
    
//    UILabel * topLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 55, 44)];
//    [topLabel setBackgroundColor:[UIColor clearColor]];
//    [topLabel setTextColor:RGB(158, 163, 171)];
//    [topLabel setTextAlignment:NSTextAlignmentLeft];
//    [topLabel setText:@"新密码"];
//    [topLabel setFont:[UIFont systemFontOfSize:17]];
//    [txfImgView addSubview:topLabel];
//    [topLabel release];
//
//    UILabel * bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 44, 55, 44)];
//    [bottomLabel setBackgroundColor:[UIColor clearColor]];
//    [bottomLabel setTextColor:RGB(158, 163, 171)];
//    [bottomLabel setTextAlignment:NSTextAlignmentLeft];
//    [bottomLabel setText:@"确认密码"];
//    [bottomLabel setFont:[UIFont systemFontOfSize:17]];
//    [txfImgView addSubview:bottomLabel];
//    [bottomLabel release];
    
    
    _topTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 305, 44)];
    [_topTextField setDelegate:self];
    [_topTextField setBackgroundColor:[UIColor clearColor]];
    [_topTextField setTextAlignment:NSTextAlignmentLeft];
    [_topTextField setTextColor:RGB(158, 163, 171)];
    [_topTextField setPlaceholder:@"密码长度:6~16位"];
    [_topTextField setFont:[UIFont systemFontOfSize:15]];
    _topTextField.returnKeyType = UIReturnKeyNext;
    [_topTextField setKeyboardType:UIKeyboardTypeAlphabet];
    _topTextField.secureTextEntry = YES;
    [_topTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txfImgView addSubview:_topTextField];
    
    
    _bottomTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 44, 305, 44)];
    [_bottomTextField setDelegate:self];
    [_bottomTextField setBackgroundColor:[UIColor clearColor]];
    [_bottomTextField setTextAlignment:NSTextAlignmentLeft];
    [_bottomTextField setTextColor:RGB(158, 163, 171)];
    [_bottomTextField setPlaceholder:@"确认密码"];
    [_bottomTextField setFont:[UIFont systemFontOfSize:15]];
    _bottomTextField.returnKeyType = UIReturnKeyDone;
    [_bottomTextField setKeyboardType:UIKeyboardTypeAlphabet];
    _bottomTextField.secureTextEntry = YES;
    [_bottomTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [txfImgView addSubview:_bottomTextField];
    
    
    
    UIButton * checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkBtn setFrame:CGRectMake( 233, height_headerview + 10 + 20 +10 + 88 +10, 23, 23)];
    [checkBtn setBackgroundColor:[UIColor clearColor]];
    [checkBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_unchecked"] forState:UIControlStateNormal];
    [checkBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_checked"] forState:UIControlStateSelected];
    [checkBtn addTarget:self action:@selector(shouldShowPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkBtn];
    
    UILabel * showLabel = [[UILabel alloc]initWithFrame:CGRectMake(260, height_headerview + 10 + 20 +10 + 88 +10, 55, 23)];
    [showLabel setBackgroundColor:[UIColor clearColor]];
    [showLabel setTextColor:RGB(158, 163, 171)];
    [showLabel setTextAlignment:NSTextAlignmentLeft];
    [showLabel setText:@"显示密码"];
    [showLabel setFont:[UIFont systemFontOfSize:13]];
    [self.view addSubview:showLabel];
    [showLabel release];
    
    
    _doneBtn = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    if (iPhone5) {
        [_doneBtn setFrame:CGRectMake(90, height_headerview + 10 + 20 +10 + 88 + 73, 140, 34)];
    }
    else{
        [_doneBtn setFrame:CGRectMake(90, height_headerview + 10 + 20 +10 + 88 + 53, 140, 34)];
    }
    [_doneBtn setSelected:NO];
    [_doneBtn setBackgroundColor:[UIColor clearColor]];
    [_doneBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_btn_finish_highlight"] forState:UIControlStateNormal];
    [_doneBtn setBackgroundImage:[UIImage imageNamed:@"phoneRegister_press_btn_finish_highlight"] forState:UIControlStateHighlighted];
    [_doneBtn addTarget:self action:@selector(didChangePassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneBtn];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_topTextField]) {
        [_bottomTextField becomeFirstResponder];
    }
    if ([textField isEqual:_bottomTextField] && _bottomTextField.text.length >0) {
        [self didChangePassword];
    }
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(void)shouldShowPassword:(id)sender
{
    UIButton * checkBtn = (UIButton *)sender;
    
    BOOL isSelected = checkBtn.selected;

    [checkBtn setSelected:!isSelected];
    
    if (!isSelected) {
        [_topTextField setSecureTextEntry:NO];
        [_bottomTextField setSecureTextEntry:NO];
    }
    else
    {
        [_topTextField setSecureTextEntry:YES];
        [_bottomTextField setSecureTextEntry:YES];
    }
}

-(void)clickBackButton:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)tap:(id)sender
{
    [_topTextField resignFirstResponder];
    [_bottomTextField resignFirstResponder];
}

-(void)didChangePassword
{
    NSString * topText = _topTextField.text;
    NSString * bottomText = _bottomTextField.text;
    
    if ([topText isEqualToString:@""] || [bottomText isEqualToString:@""]) {
        [self.view makeToast:@"密码不能为空" duration:1.2f position:@"center" isShadow:NO];
    }
    
    else{
        [_doneBtn setEnabled:YES];

        NSCharacterSet *nameCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
       
        //判断字符串是否在指定的字符集范围内
        NSRange topRange = [topText rangeOfCharacterFromSet:nameCharacters];
        NSRange bottomRange = [bottomText rangeOfCharacterFromSet:nameCharacters];
        
        if (topRange.location != NSNotFound || bottomRange.location != NSNotFound) {
            [self.view makeToast:@"密码只限大小写英文及数字" duration:1.2f position:@"center" isShadow:NO];
        }
        else{
            if (topText.length >= 6 && topText.length <= 16 && bottomText.length >= 6 && bottomText.length<= 16) {
                
                if ([topText isEqualToString:bottomText]) {
                    [self.view makeToastActivity];
                }
                else{
                    [self.view makeToast:@"两次密码不一致" duration:1.2f position:@"center" isShadow:NO];
                }
            }
            else{
                [self.view makeToast:@"密码长度6~16位" duration:1.2f position:@"center" isShadow:NO];
            }
        }
    }
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
    QY_VIEW_RELEASE(_buttonback);
    QY_VIEW_RELEASE(_topTextField);
    QY_VIEW_RELEASE(_bottomTextField);
    QY_VIEW_RELEASE(_doneBtn);
    
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
