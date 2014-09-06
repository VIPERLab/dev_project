//
//  ShareSettingViewController.m
//  KwSing
//
//  Created by 熊 改 on 12-11-26.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "ShareSettingViewController.h"
#import "KSAppDelegate.h"
#import "ImageMgr.h"
#import "globalm.h"
#import "FooterTabBar.h"
#import "User.h"
#import "Block.h"
#import "MessageManager.h"
#import "KSOtherLoginViewController.h"
#import "iToast.h"
#include "KSModalAlertView.h"

@implementation ShareSettingViewController
@synthesize shareTableView=_shareTableView;
@synthesize cellTitle=_cellTitle;

#define TITLE_LABEL_TAG 301
#define NAME_LABEL_TAG  302
#define COLON_LABEL_ATG 303

#define TAG_ALERT_QQ        401
#define TAG_ALERT_SINA      402
#define TAG_ALERT_RENREN    403

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //
         GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    }
    return self;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"分享设置"];
    [self setCellTitle:[NSArray arrayWithObjects:@"QQ空间",@"新浪微博",@"人人网",nil]];
    
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
    
    CGRect rc=[self view].bounds;
    CGRect rcna=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
    rc=BottomRect(rc, rc.size.height-rcna.size.height, 0);

    [[self view] setBackgroundColor:UIColorFromRGBValue(0xededed)];
    
    _shareTableView=[[UITableView alloc] initWithFrame:rc style:UITableViewStyleGrouped];
    [_shareTableView setDataSource:self];
    [_shareTableView setDelegate:self];
    [_shareTableView setBackgroundColor:[UIColor clearColor]];
    _shareTableView.backgroundView.alpha=0;
    _shareTableView.scrollEnabled=NO;
    _shareTableView.sectionFooterHeight=30;
    [[self view] addSubview:_shareTableView];
    
    
    UITextView *tipView=[[[UITextView alloc] initWithFrame:CGRectMake(2, 200, 316, 50)] autorelease];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        [tipView setFrame:CGRectMake(2, 220, 316, 50)];
    }
    [tipView setText:@"当您无法分享到已绑定的平台时，请重新绑定过期的账号"];
    [tipView setBackgroundColor:[UIColor clearColor]];
    [tipView setTextColor:[UIColor grayColor]];
    [tipView setUserInteractionEnabled:false];
    [[self view] addSubview:tipView];
    
    _waitingDialog=[[UIAlertView alloc] initWithTitle:@"正在注销,请稍后..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    UIActivityIndicatorView *activity=[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [activity setCenter:CGPointMake(150, 50)];
    [activity startAnimating];
    [_waitingDialog addSubview:activity];
}
-(void)viewDidUnload
{
    _shareTableView=nil;
    _cellTitle=nil;
    _waitingDialog=nil;
}
-(void)dealloc
{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    [_shareTableView release];
    [_cellTitle release];
    [_waitingDialog release];
    [super dealloc];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"] autorelease];
        UILabel *titleLabel=[[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 75, cell.frame.size.height)] autorelease];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTag:TITLE_LABEL_TAG];
        UILabel* colonLable=[[[UILabel alloc] initWithFrame:CGRectMake(75, 0, 5, cell.frame.size.height)] autorelease];
        [colonLable setText:@":"];
        [colonLable setTextAlignment:NSTextAlignmentLeft];
        [colonLable setBackgroundColor:[UIColor clearColor]];
        [colonLable setHidden:false];
        [colonLable setTag:COLON_LABEL_ATG];
        UILabel *nameLabel=[[[UILabel alloc] initWithFrame:CGRectMake(80, 0, 125, cell.frame.size.height)] autorelease];
        [nameLabel setTag:NAME_LABEL_TAG];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:titleLabel];
        [cell.contentView addSubview:colonLable];
        [cell.contentView addSubview:nameLabel];
    }
    UILabel* titleLabel=(UILabel*)[cell.contentView viewWithTag:TITLE_LABEL_TAG];
    [titleLabel setText:[_cellTitle objectAtIndex:indexPath.row]];
    UILabel* nameLabel=(UILabel*)[cell.contentView viewWithTag:NAME_LABEL_TAG];
    UILabel* colonlabel=(UILabel*)[cell.contentView viewWithTag:COLON_LABEL_ATG];
    switch ([indexPath row]) {
        case 0:
        {
            if (User::GetUserInstance()->isQQBind()) {
                [nameLabel setText:User::GetUserInstance()->getQQName()];
                [colonlabel setHidden:false];
                [nameLabel setHidden:false];
                if (User::GetUserInstance()->isQQValid()) {
                    [[cell detailTextLabel] setText:@"注销"];
                    [[cell detailTextLabel] setTextColor:UIColorFromRGBValue(0x0f72d8)];
                }
                else{
                    [[cell detailTextLabel] setText:@"重新绑定"];
                    [[cell detailTextLabel] setTextColor:[UIColor blackColor]];
                }
            }
            else{
                [colonlabel setHidden:true];
                [nameLabel setHidden:true];
                [[cell detailTextLabel] setTextColor:[UIColor blackColor]];
                [[cell detailTextLabel] setText:@"绑定"];
            }
        }
            break;
        case 1:
        {
            if (User::GetUserInstance()->isSinaBind()) {
                [nameLabel setText:User::GetUserInstance()->getSinaName()];
                [colonlabel setHidden:false];
                [nameLabel setHidden:false];
                if (User::GetUserInstance()->isSinaValid()) {
                    [[cell detailTextLabel] setText:@"注销"];
                    [[cell detailTextLabel] setTextColor:UIColorFromRGBValue(0x0f72d8)];
                }
                else{
                    [[cell detailTextLabel] setText:@"重新绑定"];
                    [[cell detailTextLabel] setTextColor:[UIColor blackColor]];
                }
                
            }
            else{
                [colonlabel setHidden:true];
                [nameLabel setHidden:true];
                [[cell detailTextLabel] setTextColor:[UIColor blackColor]];
                [[cell detailTextLabel] setText:@"绑定"];
            }
        }
            break;
        case 2:
        {
            if (User::GetUserInstance()->isRenrenBind()) {
                [nameLabel setText:User::GetUserInstance()->getRenrenName()];
                [colonlabel setHidden:false];
                [nameLabel setHidden:false];
                if (User::GetUserInstance()->isRenrenValid()) {
                    [[cell detailTextLabel] setText:@"注销"];
                    [[cell detailTextLabel] setTextColor:UIColorFromRGBValue(0x0f72d8)];
                }
                else{
                    [[cell detailTextLabel] setText:@"重新绑定"];
                    [[cell detailTextLabel] setTextColor:[UIColor blackColor]];
                }
                
            }
            else{
                [colonlabel setHidden:true];
                [nameLabel setHidden:true];
                [[cell detailTextLabel] setTextColor:[UIColor blackColor]];
                [[cell detailTextLabel] setText:@"绑定"];            }
        }
            break;
        default:
            break;
    }
    [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:14.0]];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_shareTableView deselectRowAtIndexPath:indexPath animated:YES];
    switch ([indexPath row]) {
        case 0:
            //qq zone
        {
            if (User::GetUserInstance()->isQQBind()&& User::GetUserInstance()->isQQValid()) {
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"提示" message:@"是否取消QQ绑定" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] autorelease];
                [alert setTag:TAG_ALERT_QQ];
                [alert show];
                return;
            }
            else{
                KSOtherLoginViewController *otherLogin=[[[KSOtherLoginViewController alloc] initWithType:QQ] autorelease];
                [ROOT_NAVAGATION_CONTROLLER pushViewController:otherLogin animated:YES];
            }
        }
            break;
        case 1:
        {
            if (User::GetUserInstance()->isSinaBind() && User::GetUserInstance()->isSinaValid()) {
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"提示" message:@"是否取消Sina绑定" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] autorelease];
                [alert setTag:TAG_ALERT_SINA];
                [alert show];
                return;            }
            else{
                KSOtherLoginViewController *otherLogin=[[[KSOtherLoginViewController alloc] initWithType:SINA] autorelease];
                [ROOT_NAVAGATION_CONTROLLER pushViewController:otherLogin animated:YES];
            }
        }
            break;
        case 2:
        {
            if (User::GetUserInstance()->isRenrenBind() && User::GetUserInstance()->isRenrenValid()) {
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"提示" message:@"是否取消RenRen绑定" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] autorelease];
                [alert setTag:TAG_ALERT_RENREN];
                [alert show];
                return;
            }
            else{
                KSOtherLoginViewController *otherLogin=[[[KSOtherLoginViewController alloc] initWithType:RENREN] autorelease];
                [ROOT_NAVAGATION_CONTROLLER pushViewController:otherLogin animated:YES];
            }
        }
            break;
        default:
            break;
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_QQ) {
        if (buttonIndex) {
            [_waitingDialog show];
            KS_BLOCK_DECLARE
            {
                BOOL bres=User::GetUserInstance()->cancelBindInfo(User::BIND_QQ);
                KS_BLOCK_DECLARE{
                    [_waitingDialog dismissWithClickedButtonIndex:0 animated:NO];
                    if (bres) {
                        [[[[iToast makeText:NSLocalizedString(@"注销成功", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                        [_shareTableView reloadData];
                    }
                    else{
                        [[[[iToast makeText:NSLocalizedString(@"注销失败", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                    }
                }KS_BLOCK_SYNRUN();
            }
            KS_BLOCK_RUN_THREAD();
        }
    }
    else if (alertView.tag == TAG_ALERT_SINA){
        if (buttonIndex) {
            [_waitingDialog show];
            KS_BLOCK_DECLARE
            {
                BOOL bres=User::GetUserInstance()->cancelBindInfo(User::BIND_SINA);
                KS_BLOCK_DECLARE{
                    [_waitingDialog dismissWithClickedButtonIndex:0 animated:NO];
                    if (bres) {
                        [[[[iToast makeText:NSLocalizedString(@"注销成功", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                        [_shareTableView reloadData];
                    }
                    else{
                        [[[[iToast makeText:NSLocalizedString(@"注销失败", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                    }
                }KS_BLOCK_SYNRUN();
            }
            KS_BLOCK_RUN_THREAD();
        }
    }
    else if (alertView.tag == TAG_ALERT_RENREN){
        if (buttonIndex) {
            [_waitingDialog show];
            KS_BLOCK_DECLARE
            {
                BOOL bres=User::GetUserInstance()->cancelBindInfo(User::BIND_RENREN);
                KS_BLOCK_DECLARE{
                    [_waitingDialog dismissWithClickedButtonIndex:0 animated:NO];
                    if (bres) {
                        [[[[iToast makeText:NSLocalizedString(@"注销成功", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                        [_shareTableView reloadData];
                    }
                    else{
                        [[[[iToast makeText:NSLocalizedString(@"注销失败", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                    }
                }KS_BLOCK_SYNRUN();
            }
            KS_BLOCK_RUN_THREAD();
        }

    }
}
-(void)ReturnBtnClick:(UIButton *)sender
{
    [ROOT_NAVAGATION_CONTROLLER popToRootViewControllerAnimated:YES];
}
-(void)IUserStatusObserver_AddBind:(LOGIN_TYPE)type :(BIND_RES)bindRes
{
    if (bindRes == BIND_SUCCESS) {
        //[[[[iToast makeText:NSLocalizedString(@"绑定成功", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
        [_shareTableView reloadData];
    }
//    else if (bindRes == BIND_FAIL){
//        [[[[iToast makeText:NSLocalizedString(@"绑定失败", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
//    }
//    else if (bindRes == BIND_REPEAT){
//        [[[[iToast makeText:NSLocalizedString(@"第三方账号已经绑定了其它的酷我账号", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
//    }
}
@end
