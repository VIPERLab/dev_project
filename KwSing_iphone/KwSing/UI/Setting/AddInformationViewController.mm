//
//  AddInformationViewController.m
//  KwSing
//
//  Created by 改 熊 on 12-8-28.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "AddInformationViewController.h"
#import "ImageMgr.h"
#import "globalm.h"
#import "KSAppDelegate.h"
#import "FooterTabBar.h"
#import "User.h"
#import "IUserStatusObserver.h"
#import "MessageManager.h"
#import "HttpRequest.h"
#import "KwTools.h"
#import "iToast.h"

@implementation AddInformationViewController
@synthesize userNickname=_userNickname;
@synthesize myTableView=_myTableView;

const int ViewTag=1;
const int TAG_MALE=11;
const int TAG_FEMALE=10;

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
    
    [self setTitle:@"完善资料"];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
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
    
    UIButton* returnButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [returnButton setTag:1];
    [returnButton setTitle:@"确定" forState: UIControlStateNormal];
    [returnButton setBackgroundImage:CImageMgr::GetImageEx("topReturnBtn_6.png") forState:UIControlStateNormal];
    [returnButton setBackgroundImage:CImageMgr::GetImageEx("topReturnBtnDown_6.png") forState:UIControlStateHighlighted];
    returnButton.titleLabel.font=[UIFont systemFontOfSize:14];
    returnButton.frame = CGRectMake(260, 9, 47,28);
    [returnButton addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:returnButton];
    
    CGRect rc=[self view].bounds;
    CGRect rcna=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
    rc=BottomRect(rc, rc.size.height-rcna.size.height, 0);
    
    CGRect tableRect=CGRectMake(rc.origin.x, rc.origin.y+20, rc.size.width, 150);
    _myTableView=[[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    _myTableView.delegate=self;
    _myTableView.dataSource=self;
    _myTableView.backgroundColor=[UIColor clearColor];
    _myTableView.backgroundView.alpha=0;
    _myTableView.scrollEnabled=NO;
    [[self view] addSubview:self.myTableView];
    
    _waitingDialog=[[UIAlertView alloc] initWithTitle:@"正在修改用户信息,请稍后..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    UIActivityIndicatorView *activity=[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [activity setCenter:CGPointMake(150, 50)];
    [activity startAnimating];
    [_waitingDialog addSubview:activity];
    
    [[self view] setBackgroundColor:CImageMgr::GetBackGroundColor()];
}
-(void)viewDidUnload
{
    _waitingDialog=nil;
    _userNickname=nil;
    _myTableView=nil;
}
-(void)dealloc
{
    [_waitingDialog release];
    [_userNickname release];
    [_myTableView release];
    [super dealloc];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nickCell"] autorelease];
    switch ([indexPath row]) {
        case 0:{
            [[cell contentView] addSubview:self.userNickname];
            break;
        }
        case 1:
        {
            UILabel *sexLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
            [sexLabel setText:@"性别(设置后不可更改):"];
            [sexLabel setBackgroundColor:[UIColor clearColor]];
            UIButton *femaleButton=[[UIButton alloc] initWithFrame:CGRectMake(180, 5, 50, 30)];
            [sexLabel setUserInteractionEnabled:NO];
            UIButton *maleButton=[[UIButton alloc] initWithFrame:CGRectMake(240, 5, 50, 30)];
            [femaleButton setSelected:YES];
            [femaleButton setTag:TAG_FEMALE];
            [femaleButton setImage:CImageMgr::GetImageEx("unselectedButton.png") forState:UIControlStateNormal];
            [femaleButton setImage:CImageMgr::GetImageEx("selectedButton.png") forState:UIControlStateSelected];
            [femaleButton setTitle:@"女" forState:UIControlStateNormal];
            [femaleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [femaleButton addTarget:self action:@selector(onFemaleClick:) forControlEvents:UIControlEventTouchUpInside];
            [maleButton setSelected:NO];
            [maleButton setTag:TAG_MALE];
            [maleButton setImage:CImageMgr::GetImageEx("unselectedButton.png") forState:UIControlStateNormal];
            [maleButton setImage:CImageMgr::GetImageEx("selectedButton.png") forState:UIControlStateSelected];
            [maleButton setTitle:@"男" forState:UIControlStateNormal];
            [maleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [maleButton addTarget:self action:@selector(onMaleClick:) forControlEvents:UIControlEventTouchUpInside];
            [[cell contentView] addSubview:sexLabel];
            [[cell contentView] addSubview:femaleButton];
            [[cell contentView] addSubview:maleButton];
            [femaleButton release];
            [maleButton release];
            [sexLabel release];
            break;
        }
        default:
            break;
    }
    return cell;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
	return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.userNickname resignFirstResponder];
}
-(void)onFemaleClick:(UIButton*)sender
{
    sender.selected=!sender.selected;
    ((UIButton*)[[self view] viewWithTag:TAG_MALE]).selected=!sender.selected;
}
-(void)onMaleClick:(UIButton *)sender
{
    sender.selected=!sender.selected;
    ((UIButton*)[[self view] viewWithTag:TAG_FEMALE]).selected=!sender.selected;
}
-(void)ReturnBtnClick:(id)sender
{
    if ([_userNickname.text length] == 0) {
        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入昵称" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease];
        [alert show];
        return;
    }
    if ([_userNickname.text length] > 15) {
        UIAlertView * alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"昵称长度不能超过15个字符" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease];
        [alert show];
        return;
    }
    int sex(0);
    if (((UIButton*)[[self view] viewWithTag:TAG_MALE]).selected) {
        sex=1;
    }
    else{
        sex=2;
    }
    NSString* nick=[_userNickname text];
    nick=KwTools::Encoding::UrlEncode(nick);
    NSString* sendString=[NSString stringWithFormat:@"http://changba.kuwo.cn/kge/mobile/ModProfile?uid=%@&sid=%@&nickname=%@&sex=%d&birth_city=&resident_city=&birthday=&act=mod",User::GetUserInstance()->getUserId(),User::GetUserInstance()->getSid(),nick,sex];
    
    [_waitingDialog show];
    KS_BLOCK_DECLARE
    {
        std::string outString;
        bool res=CHttpRequest::QuickSyncGet([sendString UTF8String], outString);
        //NSLog(@"set nickname return:%@",[NSString stringWithUTF8String:outString.c_str()]);
        KS_BLOCK_DECLARE
        {
            [_waitingDialog dismissWithClickedButtonIndex:0 animated:NO];
            if (res) {
                User::GetUserInstance()->setNickName(_userNickname.text);
                SYN_NOTIFY(OBSERVER_ID_USERSTATUS,IUserStatusObserver::StateChange);
                [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:NO];
                [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];

            }
            else
            {
                [[[[iToast makeText:NSLocalizedString(@"网络连接失败，请稍后再试", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
            }
        }KS_BLOCK_SYNRUN()

    }KS_BLOCK_RUN_THREAD()

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43.5;
}
-(UITextField*)userNickname
{
    if (_userNickname == nil) {
        CGRect frame = CGRectMake(10,10, 285, 30);
		_userNickname = [[UITextField alloc] initWithFrame:frame];
		[_userNickname setText:User::GetUserInstance()->getNickName()];
		_userNickname.borderStyle = UITextBorderStyleNone;//UITextBorderStyleLine;
		_userNickname.textColor = [UIColor blackColor];
		_userNickname.font = [UIFont systemFontOfSize:16.0];
        _userNickname.textAlignment = UITextAlignmentLeft;
        _userNickname.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		//_userNickname.placeholder = @"注册账号";
		_userNickname.backgroundColor = [UIColor clearColor];
		_userNickname.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		_userNickname.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_userNickname.keyboardType = UIKeyboardTypeDefault;
		_userNickname.returnKeyType = UIReturnKeyDone;
		
		_userNickname.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		_userNickname.tag = ViewTag;		// tag this control so we can remove it later for recycled cells
		
		_userNickname.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
		
        
        CGRect rect = CGRectMake(0, 0, 85, 44);
        UILabel* tmp = [[[UILabel alloc] initWithFrame:rect] autorelease ];
        tmp.backgroundColor = [UIColor clearColor];
        //tmp.font = [UIFont skinFontOfSize:16];
        [tmp setText:@"用户昵称"];
        
        _userNickname.leftView = tmp;
        _userNickname.leftViewMode = UITextFieldViewModeAlways;
    }
    return _userNickname;

}
@end
