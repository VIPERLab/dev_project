//
//  RegistViewController.m
//  KwSing
//
//  Created by 改 熊 on 12-8-28.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//
#import "User.h"
#import "RegistViewController.h"
#import "ImageMgr.h"
#import "globalm.h"
#import "KuwoConstants.h"
#import "KSAppDelegate.h"
#import "FooterTabBar.h"
#import "AddInformationViewController.h"
#import "KSOtherLoginViewController.h"
#import "RegexKitLite.h"
#import "MessageManager.h"
#import "IUserStatusObserver.h"
#import "HttpRequest.h"
#import "iToast.h"

@implementation RegistViewController
@synthesize userName=_userName;
@synthesize passWord=_passWord;
@synthesize showPWD=_showPWD;
@synthesize myTableView=_myTableView;
@synthesize dataSource;
@synthesize waitingDialog=_waitingDialog;

const int ViewTag=1;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"快速注册"];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    self.dataSource=[NSArray arrayWithObjects:self.userName,self.passWord, nil];
    
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [label_title setText:self.title];
    [view_title addSubview:label_title];
    
    UIButton* btn_ret = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_ret.frame = CGRectMake(0, 0, 44, 44);
    [btn_ret setBackgroundColor:[UIColor clearColor]];
    btn_ret.imageEdgeInsets = UIEdgeInsetsMake(10, 14.5, 10, 14.5);
    [btn_ret setImage:CImageMgr::GetImageEx("KgeReturnBtn.png") forState:(UIControlStateNormal)];
    [btn_ret addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view_title addSubview:btn_ret];
    
    
    //UIButton* registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
    UILabel* lable = [[UILabel alloc]initWithFrame:CGRectMake(60, 15, self.navigationController.navigationBar.bounds.size.width-120,18)];
    lable.textAlignment = UITextAlignmentCenter;
    lable.text = [self title];
    lable.Font = [UIFont systemFontOfSize:18];
    [lable setShadowColor:UIColorFromRGBAValue(0x000000,50)];
    [lable setShadowOffset:CGSizeMake(1, 1)];
    lable.backgroundColor = [UIColor clearColor];
    lable.textColor = [UIColor whiteColor];
    [[self view] addSubview:lable];
    [lable release];
    
    
    UIImageView * topshadow=[[UIImageView alloc] init];
    CGRect rcshadow=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
    rcshadow.origin.y+=rcshadow.size.height;
    rcshadow.size.height=5;
    [topshadow setFrame:rcshadow];
    [topshadow setImage:CImageMgr::GetImageEx("topShadow.png")];
    [[self view] addSubview:topshadow];
    [topshadow release];
    
    CGRect rc=[self view].bounds;
    CGRect rcna=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
    rc=BottomRect(rc, rc.size.height-rcna.size.height, 0);
    _myTableView=[[UITableView alloc] initWithFrame:rc style:UITableViewStyleGrouped];
    _myTableView.delegate=self;
    _myTableView.dataSource=self;
    _myTableView.backgroundColor=[UIColor clearColor];
    _myTableView.backgroundView.alpha=0;
    _myTableView.scrollEnabled=NO;
    _myTableView.sectionFooterHeight=100;
    [[self view] addSubview:self.myTableView];

    CGRect footRect=[[self view] bounds];
    footRect.size.height=60;


    _showPWD=[UIButton buttonWithType:UIButtonTypeCustom];
    _showPWD.backgroundColor=[UIColor clearColor];
    _showPWD.titleLabel.font=[UIFont systemFontOfSize:16.0];
    [_showPWD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_showPWD setFrame:CGRectMake(10, 170, 120, 40)];
    [_showPWD setImage:CImageMgr::GetImageEx("checkboxUnchecked.png") forState:UIControlStateNormal];
    [_showPWD setImage:CImageMgr::GetImageEx("checkboxChecked.png") forState:UIControlStateSelected];
    [_showPWD  setTitle:@"显示密码" forState:UIControlStateNormal];
    [_showPWD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[_showPWD titleLabel] setFont:[UIFont systemFontOfSize:15]];
    [_showPWD setSelected:YES];
    [_showPWD addTarget:self action:@selector(onSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_showPWD];
    
    
    UIButton * registButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [registButton setFrame:CGRectMake(140, 170, 170, 40)];
    [registButton setTitle:@"注册" forState:UIControlStateNormal];
    [[registButton titleLabel] setFont:[UIFont systemFontOfSize:20]];
    [registButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registButton setBackgroundImage:CImageMgr::GetImageEx("loginButton.png") forState:UIControlStateNormal];
    [registButton setBackgroundImage:CImageMgr::GetImageEx("loginButtonDown.png") forState:UIControlStateHighlighted];
    registButton.titleLabel.shadowOffset=CGSizeMake(0, -1);
    registButton.titleLabel.shadowColor=UIColorFromRGBValue(0x000000);
    [registButton addTarget:self action:@selector(registClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_showPWD];
    [[self view] addSubview:registButton];

    [[self view] bringSubviewToFront:topshadow];
    
    _waitingDialog=[[UIAlertView alloc] initWithTitle:@"正在注册，请稍后" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView *activity=[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [activity setCenter:CGPointMake(150, 50)];
    [_waitingDialog addSubview:activity];
    [activity startAnimating];
    
    [[self view] setBackgroundColor:UIColorFromRGBValue(0xededed)];
}

-(void)viewDidUnload
{
    _userName=nil;
    _passWord=nil;
    _myTableView=nil;
    dataSource=nil;
    
    _waitingDialog=nil;
}
-(void)dealloc
{
    [_userName release];
    [_passWord release];
    [_myTableView release];
    [dataSource release];
    [_waitingDialog release];
    [super dealloc];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 100;
    }
    else
        return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 3;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sec=indexPath.section;
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"registCell"];
    switch (sec) {
        case 0:
        {
            if (cell==nil) {
                cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"registCell"] autorelease];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            else {
                UIView * viewToCheck=[cell.contentView viewWithTag:ViewTag];
                if (viewToCheck) {
                    [viewToCheck removeFromSuperview];
                }
            }
            UITextField *textField=[dataSource objectAtIndex:[indexPath row]];
            [cell.contentView addSubview:textField];

        }
            break;
        case 1:
        {
            if (cell == nil) {
                cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"registCell"] autorelease];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            else{
                UIView * viewToCheck=[cell.contentView viewWithTag:ViewTag];
                if (viewToCheck) {
                    [viewToCheck removeFromSuperview];
                }
            }
            UIImageView *image=[[[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)] autorelease];
            UILabel *label=[[[UILabel alloc] initWithFrame:CGRectMake(80, 0, 200, 40)] autorelease];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont systemFontOfSize:18.0]];
            if (indexPath.row == 0) {
                //sina
                [image setImage:CImageMgr::GetImageEx("sinaImage")];
                [label setText:@"用新浪微博注册"];
            }
            else if(indexPath.row == 1){
                [image setImage:CImageMgr::GetImageEx("qqImage")];
                [label setText:@"用QQ账号注册"];
            }
//            else if (indexPath.row == 2){
//                [image setImage:CImageMgr::GetImageEx("tencentShare.png")];
//                [label setText:@"用腾讯微博注册"];
//            }
            else if (indexPath.row == 2){
                [image setImage:CImageMgr::GetImageEx("renrenShare.png")];
                [label setText:@"用人人账号注册"];
            }
            [cell.contentView addSubview:image];
            [cell.contentView addSubview:label];
        }
            break;
        default:
            break;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [self doLoginWithIndex:indexPath];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
	return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //在密文的状态下二次输入应该是自动清空，但是需求要继续输入，所以只有记下来再填进去～～
    NSString* existText=textField.text;
    [textField setText:existText];
}
-(UITextField*)userName{
    if (_userName == nil) {
        CGRect frame = CGRectMake(10,10, 285, 30);
		_userName = [[UITextField alloc] initWithFrame:frame];
		
		_userName.borderStyle = UITextBorderStyleNone;//UITextBorderStyleLine;
		_userName.textColor = [UIColor blackColor];
		_userName.font = [UIFont systemFontOfSize:16.0];
        _userName.textAlignment = UITextAlignmentLeft;
        _userName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_userName.placeholder = @"字母/数字/汉字 2-20位";
		_userName.backgroundColor = [UIColor clearColor];
		_userName.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		_userName.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_userName.keyboardType = UIKeyboardTypeDefault;
		_userName.returnKeyType = UIReturnKeyDone;
		
		_userName.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		_userName.tag = ViewTag;		// tag this control so we can remove it later for recycled cells
		
		_userName.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
        
        CGRect rect = CGRectMake(0, 0, 85, 44);
        UILabel* tmp = [[[UILabel alloc] initWithFrame:rect] autorelease ];
        tmp.backgroundColor = [UIColor clearColor];
        //tmp.font = [UIFont skinFontOfSize:16];
        [tmp setText:@"注册账号:"];
        
        _userName.leftView = tmp;
        _userName.leftViewMode = UITextFieldViewModeAlways;
    }
    return _userName;
}
-(UITextField*)passWord{
    if (_passWord == nil) {
        CGRect frame = CGRectMake(10 ,10, 285, 30);
		_passWord = [[UITextField alloc] initWithFrame:frame];
		
		_passWord.borderStyle = UITextBorderStyleNone;//UITextBorderStyleRoundedRect;
		_passWord.textColor = [UIColor blackColor];
		_passWord.font = [UIFont systemFontOfSize:16.0];
        _passWord.textAlignment = UITextAlignmentLeft;
        _passWord.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_passWord.placeholder = @"长度6-16位";
		_passWord.backgroundColor = [UIColor clearColor];
		_passWord.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		_passWord.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_passWord.keyboardType = UIKeyboardTypeASCIICapable;
		_passWord.returnKeyType = UIReturnKeyDone;
        //[_passWord setText:_passWord.text];
		//_passWord.secureTextEntry = _showPWD.selected;
		_passWord.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		_passWord.tag = ViewTag;		// tag this control so we can remove it later for recycled cells
		
		_passWord.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
        
        CGRect rect = CGRectMake(0, 0, 85, 44);
        UILabel* tmp = [[[UILabel alloc] initWithFrame:rect] autorelease ];
        tmp.backgroundColor = [UIColor clearColor];
        //tmp.font = [UIFont skinFontOfSize:16];
        [tmp setText:@"注册密码:"];
        _passWord.leftView = tmp;
        _passWord.leftViewMode = UITextFieldViewModeAlways;
    }
    return _passWord;
}

-(void)onSwitch:(UIButton *)sender
{
    BOOL res=sender.selected=!sender.selected;
    [self.passWord setEnabled:NO];
    [self.passWord setEnabled:YES];
    [self.passWord setSecureTextEntry:!res];
    [self.passWord becomeFirstResponder];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.userName resignFirstResponder];
    [self.passWord resignFirstResponder];
}
-(void)ReturnBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)doLoginWithIndex:(NSIndexPath*)indexPath
{
    LOGIN_TYPE type;
    switch (indexPath.row) {
        case 0:
            type=SINA;
            break;
        case 1:
            type=QQ;
            break;
        case 2:
            type=RENREN;
            break;
        default:
            break;
    }
    KSOtherLoginViewController *ologinController=[[[KSOtherLoginViewController alloc] initWithType:type] autorelease];
    [ologinController setIsRegist:true];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:ologinController animated:YES];
}

-(void)registClick:(id)sender
{
    if (CHttpRequest::GetNetWorkStatus() == NETSTATUS_NONE) {
        UIAlertView * alertView=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"没有网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease];
        [alertView show];
        return;
    }
    NSString* name=[[self userName] text];
    NSString* pwd=[[self passWord] text];
    if ([name length]==0) 
    {
        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入账号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
        [alert show];
        [self.userName becomeFirstResponder];
        return;
    }
    if ([pwd length]==0) {
        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
        [alert show];
        [self.passWord becomeFirstResponder];
        return;
    }
    NSString* regEx = @"^[a-zA-Z0-9\\u4e00-\\u9fa5]+$";//汉字，字母，数字
    if(![self.userName.text isMatchedByRegex:regEx] || 
       [self.userName.text length] > 20 || 
       [self.userName.text length] <2)
    {
        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入2-20位字母/数字/汉字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
        [alert show];
        [self.userName becomeFirstResponder];
        return;
    }
    NSString * numRegEx = @"^\\d";//数字开头
    if([self.userName.text isMatchedByRegex:numRegEx])
    {
        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"账号不能以数字开头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
        [alert show];
        [self.userName becomeFirstResponder];
        return;
    }
    if( [self.passWord.text length] < 6 || [self.passWord.text length] > 16)
    {
        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入6-16位密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
        [alert show];
        [self.passWord becomeFirstResponder];
        return;
    }
    [_waitingDialog show];
    
    NSString* uName=[_userName text];
    NSString* uPwd=[_passWord text];
    
     KS_BLOCK_DECLARE
    {
        NSString * returnString;
        BOOL res=User::GetUserInstance()->Regist(uName, uPwd, nil, [NSString stringWithUTF8String:KWSING_CLIENT_VERSION_STRING], nil,returnString);
        KS_BLOCK_DECLARE{
            
            if (res) {
                [_waitingDialog dismissWithClickedButtonIndex:0 animated:NO];
                //注册连接成功，下面处理返回结果
                std::string res=[returnString UTF8String];
                if (res.substr(0,5)== "#200#") {
                    //注册成功

                    [[[[iToast makeText:NSLocalizedString(@"注册成功", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                    std::string uid=res.substr(6,res.length()-6);
                    User::GetUserInstance()->setUserId([NSString stringWithUTF8String:uid.c_str()]);
                    User::GetUserInstance()->setUserName([_userName text]);
                    User::GetUserInstance()->setUserPwd([_passWord text]);
                    SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::LoginStart,KUWO);
                    User::GetUserInstance()->Login();
                    SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::LoginFinish,KUWO,NOT_FIRST);
                    [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:NO];
                    [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];
                }
                else if(res.substr(0,5) == "#550#")
                {
                    if (res.substr(6,1) == "1")
                    {
                        //用户名存在
                        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"注册失败" message:@"该账号已被占用" delegate:self
                                                             cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease];
                        [alert show];
                    }
                    else 
                    {
                        //操作失败
                        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"注册失败" message:@"操作失败" delegate:self
                                                             cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease];
                        [alert show];
                    }
                }
            }
            else 
            {
                //NSLog(@"link error");
            }
        }
        KS_BLOCK_SYNRUN();
    }
    KS_BLOCK_RUN_THREAD();
    }
@end
