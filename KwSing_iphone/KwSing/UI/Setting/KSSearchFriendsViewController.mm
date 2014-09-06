//
//  KSSearchFriendsViewController.m
//  KwSing
//
//  Created by 单 永杰 on 13-10-30.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import "KSSearchFriendsViewController.h"
#import "KSSearchDetailViewController.h"
#import "KSAppDelegate.h"
#include "globalm.h"
#include "ImageMgr.h"
#include "User.h"
#include "IUserStatusObserver.h"
#import "LoginViewController.h"
#include "MessageManager.h"
#import "KSOtherLoginViewController.h"
#import "KSMvSongViewController.h"

#define ALERT_QQ_TAG 105
#define ALERT_SINA_TAG 106

@interface KSSearchFriendsViewController ()<IUserStatusObserver>{
    UIView* pNeedLoginMsgView;
}

@end

@implementation KSSearchFriendsViewController

@synthesize settingTableView=_settingTableView;
@synthesize cellTitle=_cellTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    if (pNeedLoginMsgView) {
        [pNeedLoginMsgView release];
        pNeedLoginMsgView = nil;
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setTitle:@"搜索好友"];
    

    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    [self setCellTitle:[NSArray arrayWithObjects:@"按昵称搜索好友", @"查找新浪微博好友", @"查找腾讯微博好友", nil]];
    
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
    [btn_ret addTarget:self action:@selector(ReturnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [view_title addSubview:btn_ret];
    
    CGRect rc=[self view].bounds;
    CGRect rcna=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
    rc=BottomRect(rc, rc.size.height-rcna.size.height, 0);
    
    _settingTableView = [[UITableView alloc] initWithFrame:rc style:UITableViewStyleGrouped];
    _settingTableView.delegate=self;
    _settingTableView.dataSource=self;
    _settingTableView.backgroundColor=[UIColor clearColor];
    _settingTableView.backgroundView.alpha=0;
    _settingTableView.scrollEnabled=NO;
    _settingTableView.sectionFooterHeight=100;
    [[self view] addSubview:[self settingTableView]];
    
}

- (void)showNeedLoginView
{
    if (!pNeedLoginMsgView) {
        CGRect rc=[self view].bounds;
        CGRect rcna=ROOT_NAVAGATION_CONTROLLER_BOUNDS;
        CGRect back=BottomRect(rc, rc.size.height-rcna.size.height, 0);
        pNeedLoginMsgView=[[UIView alloc] initWithFrame:back];
        [pNeedLoginMsgView setBackgroundColor:[UIColor whiteColor]];
        UIImage *needLoginImage=CImageMgr::GetImageEx("needLogin.png");
        UIImageView *needLoginView=[[UIImageView alloc] initWithFrame:CGRectMake(35, 116, needLoginImage.size.width,needLoginImage.size.height)];
        [needLoginView setImage:needLoginImage];
        [pNeedLoginMsgView addSubview:needLoginView];
        [needLoginView release];
        [self.view addSubview:pNeedLoginMsgView];
        
        UITapGestureRecognizer *tapGestureRecognize=[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapErrorViewGestureRecognizer:)] autorelease];
        tapGestureRecognize.numberOfTapsRequired=1;
        [pNeedLoginMsgView addGestureRecognizer:tapGestureRecognize];
    }
    pNeedLoginMsgView.hidden=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) ReturnBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)singleTapErrorViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    KSLoginViewController* loginController=[[[KSLoginViewController alloc] init] autorelease];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:loginController animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            
            return 1;
            
        case 1:
            
            return 2;
            
        default:
            return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger n_section = indexPath.section;
    NSInteger n_row = indexPath.row;
    
    static NSString* section_table_identifier = @"SectionSearchTableIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:section_table_identifier];
    
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:section_table_identifier] autorelease];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    switch (n_section) {
        case 0:{
            cell.textLabel.text = [_cellTitle objectAtIndex:0];
            break;
        }
        case 1:
        {
            if (0 == n_row) {
                cell.textLabel.text = [_cellTitle objectAtIndex:1];
            }else {
                cell.textLabel.text = [_cellTitle objectAtIndex:2];
            }
            break;
        }
        default:
            break;
    }
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    KSMvSongViewController* mv_song_view = [[[KSMvSongViewController alloc] init] autorelease];
//    
//    [self presentModalViewController:mv_song_view animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger n_section = indexPath.section;
    NSInteger n_row = indexPath.row;
    
//    if (0 == n_section) {
//        if (!User::GetUserInstance()->isOnline()) {
//            [self showNeedLoginView];
//            return;
//        }
//    }
    if (1 == n_section) {
        if (0 == n_row) {
            if (!User::GetUserInstance()->isSinaBind()) {
                UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的微博账号还未绑定，是否立即绑定" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] autorelease];
                [alert setTag:ALERT_SINA_TAG];
                [alert show];
                return;
            }
        }
        else if (!User::GetUserInstance()->isQQBind()) {
                UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的QQ账号还未绑定，是否立即绑定" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] autorelease];
                [alert setTag:ALERT_QQ_TAG];
                [alert show];
                return;
        }
    }
    
    
    KSSearchDetailViewController* detail_view = [[[KSSearchDetailViewController alloc] init] autorelease];
    
    if (0 == n_section) {
        detail_view.searchType = E_SEARCH_KUWO;
        
    }else {
        if (0 == n_row) {
            detail_view.searchType = E_SEARCH_SINA;
        }else{
            detail_view.searchType = E_SEARCH_QQ;
        }
    }
    
    [ROOT_NAVAGATION_CONTROLLER pushViewController:detail_view animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)IUserStatusObserver_LoginFinish:(LOGIN_TYPE) type :(LOGIN_TIME)first
{
    if (pNeedLoginMsgView) {
        [pNeedLoginMsgView removeFromSuperview];
        [pNeedLoginMsgView release];
        pNeedLoginMsgView=NULL;
    }
    
    if (!User::GetUserInstance()->isOnline()) {
        [self showNeedLoginView];
    }
}
-(void)IUserStatusObserver_Logout
{
    [self showNeedLoginView];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if (buttonIndex != 1) {
            return;
        }
        switch (alertView.tag) {
            case ALERT_SINA_TAG:
            {
                KSOtherLoginViewController *loginViewController=[[KSOtherLoginViewController alloc] initWithType:SINA];
                [loginViewController setIsShare:true];
                [ROOT_NAVAGATION_CONTROLLER pushViewController:loginViewController animated:YES];
                [loginViewController release];
                loginViewController = nil;
            }
                break;
            case ALERT_QQ_TAG:
            {
                KSOtherLoginViewController *loginViewController=[[KSOtherLoginViewController alloc] initWithType:QQ];
                [loginViewController setIsShare:true];
                [ROOT_NAVAGATION_CONTROLLER pushViewController:loginViewController animated:YES];
                [loginViewController release];
                loginViewController = nil;
            }
                break;

            default:
                break;
        }
}

@end
