//
//  MyPageViewController.m
//  KwSing
//
//  Created by 改 熊 on 12-8-6.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//
#include "MyPageViewController.h"
#include "KSWebView.h"
#include "globalm.h"
#include "KSMusicLibDelegate.h"
#include "MyPageEditViewController.h"
#include "ImageMgr.h"
#include "KSAppDelegate.h"
#include "FooterTabBar.h"
#include "User.h"
#include "KwTools.h"
#include "MessageManager.h"
#include "HttpRequest.h"
#include "LoginViewController.h"
#include "IUserStatusObserver.h"
#include "iToast.h"
#include "MobClick.h"
#include "MyMessageViewController.h"
#include "MyMessageManager.h"
#include "IMyMessageStateObserver.h"
#include "MainViewController.h"
#include "KBRefreshHeadView.h"
#include "CacheMgr.h"
#include "GDataXMLNode.h"
#import "KSFansFollowViewController.h"
#include "NowPlayViewController.h"

@interface OpusItem : NSObject

@property (retain, nonatomic) NSString* strKid;
@property (retain, nonatomic) NSString* strOpusName;
@property (retain, nonatomic) NSString* strOpusSrc;
@property (retain, nonatomic) NSString* strOpusTime;
@property (assign, nonatomic) int nOpusView;
@property (assign, nonatomic) int nOpusComment;
@property (assign, nonatomic) int nOpusFlower;

@end

@implementation OpusItem

@end

//#define MY_PAGE_URL @"http://60.28.200.79/kge/webmobile/ios/myhome.html"
#define MY_PAGE_URL @"http://changba.kuwo.cn/kge/mobile/User?id=%@&loginid=%@&sid=%@&ps=100"
#define DELETE_OPUS_URL @"http://changba.kuwo.cn/kge/mobile/DelKge?kid=%@&uid=%@&sid=%@"
#define TAG_MSG_NUM 229

#define TAG_BTN_FANS       230
#define TAG_BTN_FOLLOW     231
#define TAG_BTN_EDIT       232
#define TAG_BTN_PLAY       233

#define TAG_OPUS_NAME      234
#define TAG_OPUS_VIEW      235
#define TAG_OPUS_COMMENT   236
#define TAG_OPUS_FLOWER    237
#define TAG_OPUS_FROM      238
#define TAG_OPUS_HEAD_PIC  239

#define TAG_VIEW_FANS      240
#define TAG_VIEW_FOLLOW    241

#define TAG_LABEL_FANS     242
#define TAG_LABEL_FOLLOW   243

#define TAG_MYPAGE_HEAD_PIC  244
#define TAG_BTN_HEAD_PIC     245

#define TAG_IMAGE_SEX      246
#define TAG_LABEL_NAME     247
#define TAG_LABEL_ID       248
#define TAG_LABEL_AGE      249
#define TAG_LABEL_RESIDENT 250
#define TAG_LABEL_CITY     251

@interface MyPageViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,IUserStatusObserver,IMyMessageStateObserver, KBRefreshBaseViewDelegate>
{
    UITableView * tableMyOpus;
    UIAlertView *_waitingDialog;
    UIButton *btnMsg;
    UIView* pNeedLoginMsgView;
    KBRefreshHeadView* _foot_view;
    
    NSString* strUserName;
    int nSex;
    int nFans;
    int nFollow;
    NSString* strBirthCity;
    NSString* strResidentCity;
    int nAge;
    
    NSString* strHeadPicUrl;
    
    NSMutableArray* _opusArray;
}
@property (nonatomic,retain) UIAlertView *waitingDialog;

- (void)webViewRunActionWithParam:(KSWebView*)view action:(NSString*)act parameter:(NSDictionary*)paras;
-(BOOL)writeImage:(UIImage *)image ToFilePath:(NSString *)aPath;

- (void)showNeedLoginView;
-(void)IMyMessageStateObserver_MessageNumChanged;
@end

@implementation MyPageViewController

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _hasReturn=false;
        strUserName = nil;
        strBirthCity = nil;
        strResidentCity = nil;
        strHeadPicUrl = nil;
        nSex = 0;
        nAge = 0;
        nFans = 0;
        nFollow = 0;
        
        _opusArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_MY_MESSAGE, IMyMessageStateObserver);
    
    return self;
}
-(id)init
{
    self = [super init];
    if (self) {
        _hasReturn=false;
    }
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_MY_MESSAGE, IMyMessageStateObserver);
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView* view_title = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setImage:CImageMgr::GetImageEx("MyPageTitle.png")];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [label_title setText:@"个人主页"];
    [view_title addSubview:label_title];
    
    if (_hasReturn) {
        UIButton* returnButton= [UIButton buttonWithType:UIButtonTypeCustom];
        [returnButton setTag:1];
        [returnButton setTitle:@"返回" forState: UIControlStateNormal];
        [returnButton setBackgroundImage:CImageMgr::GetImageEx("topReturnBtn_6.png") forState:UIControlStateNormal];
        [returnButton setBackgroundImage:CImageMgr::GetImageEx("topReturnBtnDown_6.png") forState:UIControlStateHighlighted];
        [returnButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [returnButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        [returnButton.titleLabel setShadowColor:[UIColor blackColor]];
        returnButton.frame = CGRectMake(10, 9, 47,28);
        [returnButton addTarget:self action:@selector(ReturnBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:returnButton];
    }
    
    btnMsg = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *imgLocal = CImageMgr::GetImageEx("MyPageMessageBtn.png");
    [btnMsg setBackgroundImage:imgLocal forState:UIControlStateNormal];
    [btnMsg setBackgroundImage:CImageMgr::GetImageEx("MyPageMessageBtn.png.png") forState:UIControlStateHighlighted];
    btnMsg.frame = CGRectMake(277, 12, 27,21);
    [btnMsg addTarget:self action:@selector(onShowMyMessagePage) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:btnMsg];
    UIButton* messageNum=[[[UIButton alloc] init] autorelease];
    [messageNum setFrame:CGRectMake(btnMsg.bounds.size.width-10, 0, 10, 10)];
    [messageNum setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [messageNum setBackgroundImage:CImageMgr::GetImageEx("messageNum_29.png") forState:UIControlStateNormal];
    [messageNum.titleLabel setTextColor:[UIColor whiteColor]];
    [messageNum setTitleEdgeInsets:UIEdgeInsetsMake(-4,2,0,0)];
    [messageNum setUserInteractionEnabled:NO];
    [messageNum setHidden:false];
    [messageNum setTag:TAG_MSG_NUM];
    [btnMsg addSubview:messageNum];
    
    if (CMyMessageManager::GetInstance()->NumOfNewMessages()>0) 
        [messageNum setHidden:false];
    else
        [messageNum setHidden:true];
    
    tableMyOpus = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height - 44) ];
    [tableMyOpus setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:tableMyOpus];
    [tableMyOpus setDelegate:self];
    [tableMyOpus setDataSource:self];
    
    _foot_view = [KBRefreshHeadView header];
    [_foot_view setScrollView:tableMyOpus];
    [_foot_view setDelegate:self];
    [_foot_view setHidden:NO];

    
    if (!User::GetUserInstance()->isOnline()){
        [self showNeedLoginView];
    }
    
    _waitingDialog=[[UIAlertView alloc] initWithTitle:@"正在上传,请稍后..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    UIActivityIndicatorView *activity=[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [activity setCenter:CGPointMake(150, 50)];
    [activity startAnimating];
    [_waitingDialog addSubview:activity];

    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
    
    if (NETSTATUS_NONE != CHttpRequest::GetNetWorkStatus()) {
        [self updateMyPage];
    }
}
-(void)dealloc
{
    [tableMyOpus setDelegate:nil];
    [tableMyOpus setDataSource:nil];
    [tableMyOpus release];
    tableMyOpus = nil;
    
    [_waitingDialog release];
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS,IUserStatusObserver);
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_MY_MESSAGE, IMyMessageStateObserver);
    [MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
    if (_opusArray) {
        [_opusArray release];
        _opusArray = nil;
    }
    
    if (strUserName) {
        [strUserName release];
        strUserName = nil;
    }
    
    if (strBirthCity) {
        [strBirthCity release];
        strBirthCity = nil;
    }
    
    if (strResidentCity) {
        [strResidentCity release];
        strResidentCity = nil;
    }
    
    [super dealloc];
}
-(void)ReturnBtnClick
{
    [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];
}
- (void)onShowMyMessagePage
{
    MyMessageViewController* p=[[[MyMessageViewController alloc] init] autorelease];
    if (CMyMessageManager::GetInstance()->NumOfNewMessages() > 0) {
        [p reloadPage];
    }
    [(UIButton *)[[self view] viewWithTag:TAG_MSG_NUM]setHidden:true];
    CMyMessageManager::GetInstance()->ResetMessage();
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:p animated:YES];
}

- (void)webViewRunActionWithParam:(KSWebView*)view action:(NSString*)act parameter:(NSDictionary*)paras
{
    if([act isEqualToString:@"EditMyInfo"])
    {
        MyPageEditViewController * myPageEditController=[[MyPageEditViewController alloc] init];
        [ROOT_NAVAGATION_CONTROLLER pushViewController:myPageEditController animated:YES];
        [myPageEditController release];
    }
    else if ([act isEqualToString:@"EditMyHead"]) {
        UIActionSheet *chooseHead=[[[UIActionSheet alloc] initWithTitle:nil 
                                                              delegate:self 
                                                     cancelButtonTitle:@"取消" 
                                                destructiveButtonTitle:nil 
                                                     otherButtonTitles:@"从相册中选取图片",@"立即拍照", nil] autorelease];
        [chooseHead showInView:[UIApplication sharedApplication].keyWindow];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            //from lib
            UIImagePickerController* imagePicker=[[[UIImagePickerController alloc] init] autorelease];
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [imagePicker setDelegate:self];
            imagePicker.allowsEditing=YES;
            [[KSAppDelegate rootNavigationController] presentModalViewController:imagePicker animated:YES];
            break;
        }
        case 1:
        {
            //take photo now
            UIImagePickerController* imagePicker=[[[UIImagePickerController alloc] init] autorelease];
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                [imagePicker setDelegate:self];
                imagePicker.allowsEditing=YES;
                [[KSAppDelegate rootNavigationController] presentModalViewController:imagePicker animated:YES];
            }
            break;
        }
        default:
            break;
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[KSAppDelegate rootNavigationController] dismissModalViewControllerAnimated:YES];
    UIImage* headPic=[info objectForKey:UIImagePickerControllerEditedImage];
    [headPic retain];
    
    //write
    NSString *imagePath=[NSString stringWithFormat:@"%@/%@head.jpg",KwTools::Dir::GetPath(KwTools::Dir::PATH_USER),User::GetUserInstance()->getUserId()];
    //NSLog(@"path:%@",imagePath);
    if (KwTools::Dir::IsExistFile(imagePath)) {
        KwTools::Dir::DeleteFile(imagePath);
    }

    if ([self writeImage:headPic ToFilePath:imagePath]) {
        [_waitingDialog show];
        KS_BLOCK_DECLARE
        {
            NSString* url=[NSString stringWithFormat:@"http://changba.kuwo.cn/kge/mobile/UploadHead?id=%@&sid=%@&cat=userhead&comp=111&suf=jpg",User::GetUserInstance()->getUserId(),User::GetUserInstance()->getSid()];
            CHttpRequest *preq=new CHttpRequest([url UTF8String] ,[imagePath UTF8String]);
            BOOL res=preq->AsyncSendRequest();
            NSTimeInterval t=[NSDate timeIntervalSinceReferenceDate];
            while (!preq->IsFinished()) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                if ([NSDate timeIntervalSinceReferenceDate]-t>(CHttpRequest::GetNetWorkStatus()==NETSTATUS_WIFI?60:120)) {
                    //NSLog(@"UploadFileTimeOut!");
                    res=false;
                    break;
                }
            }
            if (res) {
                void * buf(NULL);
                unsigned l(0);
                preq->ReadAll(buf, l);
                std::string str((char*)buf,l);
                std::map<std::string, std::string> tokens;
                KwTools::StringUtility::TokenizeKeyValue(str, tokens,",",":");
                std::string picUrl=tokens[" \"pic\""];
                if (picUrl.length() >2) {
                    picUrl=picUrl.substr(1,picUrl.length()-3);
                }
                User::GetUserInstance()->setHeadPic([NSString stringWithUTF8String:picUrl.c_str()]);
                KS_BLOCK_DECLARE
                {
                    [_waitingDialog dismissWithClickedButtonIndex:0 animated:NO];
//                    [webView executeJavaScriptFunc:@"onHeadPic" parameter:[NSString stringWithUTF8String:picUrl.c_str()]];
                    [[[[iToast makeText:NSLocalizedString(@"上传成功", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                    [self updateMyPage];
                }KS_BLOCK_SYNRUN()
            }
            delete preq;
        }KS_BLOCK_RUN_THREAD();

    }
    [headPic release];
    [self dismissModalViewControllerAnimated:YES];
}
-(BOOL)writeImage:(UIImage *)image ToFilePath:(NSString *)aPath
{
    if ((image==nil) || (aPath==nil) ||[aPath isEqualToString:@""]) {
        return FALSE;
    }
    NSData *imageData=UIImagePNGRepresentation(image);
    if ((imageData == nil) || ([imageData length] <= 0)) {
        return FALSE;
    }
    [imageData writeToFile:aPath atomically:YES];
    return TRUE;
}

- (void)showNeedLoginView
{
    if (!pNeedLoginMsgView) {
        [btnMsg setHidden:true];
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

- (void)singleTapErrorViewGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    KSLoginViewController* loginController=[[[KSLoginViewController alloc] init] autorelease];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:loginController animated:YES];
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
    }else {
        [btnMsg setHidden:false];
        [self updateMyPage];
//        [webView loadUrl:[NSString stringWithFormat:@"%@?%d",MY_PAGE_URL,rand()]];
    }
}
-(void)IUserStatusObserver_Logout
{
    [self showNeedLoginView];
}
-(void)IUserStatusObserver_StateChange
{
//    [webView reload];
}
-(void)IMyMessageStateObserver_MessageNumChanged;
{
    if (CMyMessageManager::GetInstance()->NumOfNewMessages()>0) {
        [(UIButton *)[[self view]  viewWithTag:TAG_MSG_NUM]setHidden:false];
    }
    else{
        [(UIButton *)[[self view] viewWithTag:TAG_MSG_NUM]setHidden:true];
    }
}

#pragma mark table view delegate and data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_opusArray count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.row) {
        return 193;
    }
    return 70;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cur_cell = nil;
    if (0 == indexPath.row) {
        static NSString* s_str_header_identifier = @"stringHeaderCellIdentifier";
        cur_cell = [tableMyOpus dequeueReusableCellWithIdentifier:s_str_header_identifier];
        if (nil == cur_cell) {
            cur_cell = [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:s_str_header_identifier] autorelease];
            
            UIImageView* background_image = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 156)] autorelease];
            [background_image setImage:CImageMgr::GetImageEx("MyPageCellBackGround.png")];
            [cur_cell.contentView addSubview:background_image];
            
            UIImageView* image_head_pic = [[[UIImageView alloc] initWithFrame:CGRectMake(115, 10, 90, 90)] autorelease];
            [image_head_pic setTag:TAG_MYPAGE_HEAD_PIC];
            [cur_cell.contentView addSubview:image_head_pic];
            
            UIButton* btn_head_pic = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_head_pic.frame = CGRectMake(104.5, 4, 107.5, 107.5);
            [btn_head_pic setBackgroundColor:[UIColor clearColor]];
            [btn_head_pic setTag:TAG_BTN_HEAD_PIC];
            [btn_head_pic setBackgroundImage:CImageMgr::GetImageEx("MineHeadPicBtn.png") forState:(UIControlStateNormal)];
            [btn_head_pic addTarget:self action:@selector(onBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
            [cur_cell.contentView addSubview:btn_head_pic];
            
            UIImageView* image_sex = [[[UIImageView alloc] initWithFrame:CGRectMake(73, 108, 16.5, 17.5)] autorelease];
            [image_sex setTag:TAG_IMAGE_SEX];
            [cur_cell.contentView addSubview:image_sex];
            
            UILabel* label_id = [[[UILabel alloc] initWithFrame:CGRectMake(93, 108, 180, 16)] autorelease];
            [label_id setBackgroundColor:[UIColor clearColor]];
            [label_id setTextAlignment:(NSTextAlignmentLeft)];
            [label_id setTextColor:[UIColor blackColor]];
            [label_id setFont:[UIFont systemFontOfSize:12]];
            [label_id setTag:TAG_LABEL_ID];
            [cur_cell.contentView addSubview:label_id];
            
            UILabel* label_age = [[[UILabel alloc] initWithFrame:CGRectMake(55, 128, 210, 16)] autorelease];
            [label_age setBackgroundColor:[UIColor clearColor]];
            [label_age setTextAlignment:(NSTextAlignmentCenter)];
            [label_age setTextColor:[UIColor blackColor]];
            [label_age setFont:[UIFont systemFontOfSize:12]];
            [label_age setTag:TAG_LABEL_AGE];
            [cur_cell.contentView addSubview:label_age];
            
            UIView* view_fans = [[[UIView alloc] initWithFrame:CGRectMake(0, 158, 106, 35)] autorelease];
            [view_fans setBackgroundColor:UIColorFromRGBValue(0x22ab57)];
            [view_fans setTag:TAG_VIEW_FANS];
            [cur_cell.contentView addSubview:view_fans];
            
            UILabel* label_fans = [[[UILabel alloc] initWithFrame:CGRectMake(24, 3, 58, 16)] autorelease];
            [label_fans setBackgroundColor:[UIColor clearColor]];
            [label_fans setTextAlignment:(NSTextAlignmentCenter)];
            [label_fans setFont:[UIFont systemFontOfSize:14]];
            [label_fans setTag:TAG_LABEL_FANS];
            [label_fans setTextColor:[UIColor whiteColor]];
            [view_fans addSubview:label_fans];
            
            UILabel* label_fans_name = [[[UILabel alloc] initWithFrame:CGRectMake(42, 21, 22, 11)] autorelease];
            [label_fans_name setBackgroundColor:[UIColor clearColor]];
            [label_fans_name setTextAlignment:(NSTextAlignmentCenter)];
            [label_fans_name setFont:[UIFont systemFontOfSize:10]];
            [label_fans_name setTextColor:[UIColor whiteColor]];
            [label_fans_name setText:@"粉丝"];
            [view_fans addSubview:label_fans_name];
            
            UIButton* btn_fans = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_fans.frame = CGRectMake(0, 158, 106, 35);
            [btn_fans setBackgroundColor:[UIColor clearColor]];
            [btn_fans setTag:TAG_BTN_FANS];
            [btn_fans addTarget:self action:@selector(onBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
            [btn_fans addTarget:self action:@selector(onBtnTouchDown:) forControlEvents:(UIControlEventTouchDown)];
            [cur_cell.contentView addSubview:btn_fans];
            
            UIView* view_follow = [[[UIView alloc] initWithFrame:CGRectMake(107, 158, 106, 35)] autorelease];
            [view_follow setBackgroundColor:UIColorFromRGBValue(0x22ab57)];
            [view_follow setTag:TAG_VIEW_FOLLOW];
            [cur_cell.contentView addSubview:view_follow];
            
            UILabel* label_follow = [[[UILabel alloc] initWithFrame:CGRectMake(24, 3, 58, 16)] autorelease];
            [label_follow setBackgroundColor:[UIColor clearColor]];
            [label_follow setTextAlignment:(NSTextAlignmentCenter)];
            [label_follow setFont:[UIFont systemFontOfSize:14]];
            [label_follow setTag:TAG_LABEL_FOLLOW];
            [label_follow setTextColor:[UIColor whiteColor]];
            [view_follow addSubview:label_follow];
            
            UILabel* label_follow_name = [[[UILabel alloc] initWithFrame:CGRectMake(42, 21, 22, 11)] autorelease];
            [label_follow_name setBackgroundColor:[UIColor clearColor]];
            [label_follow_name setTextAlignment:(NSTextAlignmentCenter)];
            [label_follow_name setFont:[UIFont systemFontOfSize:10]];
            [label_follow_name setTextColor:[UIColor whiteColor]];
            [label_follow_name setText:@"关注"];
            [view_follow addSubview:label_follow_name];
            
            UIButton* btn_follow = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_follow.frame = CGRectMake(107, 158, 106, 35);
            [btn_follow setBackgroundColor:[UIColor clearColor]];
            [btn_follow setTag:TAG_BTN_FOLLOW];
            [btn_follow addTarget:self action:@selector(onBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
            [btn_follow addTarget:self action:@selector(onBtnTouchDown:) forControlEvents:(UIControlEventTouchDown)];
            [cur_cell.contentView addSubview:btn_follow];
            
            UIButton* btn_edit = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_edit.frame = CGRectMake(214, 158, 106, 35);
            [btn_edit setTag:TAG_BTN_EDIT];
            [btn_edit setImage:CImageMgr::GetImageEx("MyPageEditBtn.png") forState:(UIControlStateNormal)];
            [btn_edit setImage:CImageMgr::GetImageEx("MyPageEditBtnClick.png") forState:(UIControlStateHighlighted)];
            [btn_edit addTarget:self action:@selector(onBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
            [cur_cell.contentView addSubview:btn_edit];
        }
        
        UILabel* label_fans = (UILabel*)[cur_cell.contentView viewWithTag:TAG_LABEL_FANS];
        if (label_fans) {
            [label_fans setText:[NSString stringWithFormat:@"%d", nFans]];
        }
        
        UILabel* label_follow = (UILabel*)[cur_cell.contentView viewWithTag:TAG_LABEL_FOLLOW];
        if (label_follow) {
            [label_follow setText:[NSString stringWithFormat:@"%d", nFollow]];
        }
        
        UIImageView* image_head_pic = (UIImageView*)[cur_cell.contentView viewWithTag:TAG_MYPAGE_HEAD_PIC];
        if (image_head_pic && strHeadPicUrl) {
            [self startLoadHeadPic:image_head_pic imageUrl:strHeadPicUrl];
        }
        
        UIImageView* image_sex = (UIImageView*)[cur_cell.contentView viewWithTag:TAG_IMAGE_SEX];
        if (image_sex) {
            if (2 == nSex) {
                [image_sex setImage:CImageMgr::GetImageEx("MyPageGirl.png")];
            }else {
                [image_sex setImage:CImageMgr::GetImageEx("MyPageBoy.png")];
            }
        }
        
        UILabel* label_id = (UILabel*)[cur_cell.contentView viewWithTag:TAG_LABEL_ID];
        if (label_id) {
            if (strUserName) {
                [label_id setText:[NSString stringWithFormat:@"%@ ID: %@", strUserName, User::GetUserInstance()->getUserId()]];
            }else {
                [label_id setText:[NSString stringWithFormat:@"ID: %@", User::GetUserInstance()->getUserId()]];
            }
            
        }
        
        UILabel* label_age = (UILabel*)[cur_cell.contentView viewWithTag:TAG_LABEL_AGE];
        if (label_age) {
            NSDate* now = [NSDate date];
            NSCalendar* calendar_year = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSYearCalendarUnit;
            NSDateComponents* dateComponent = [calendar_year components:unitFlags fromDate:now];
            int n_year_now = [dateComponent year];
            if (strBirthCity && strResidentCity) {
                [label_age setText:[NSString stringWithFormat:@"%d0后 %@ 现居%@", (n_year_now - nAge) % 100 / 10, strBirthCity, strResidentCity]];
            }else {
                [label_age setText:[NSString stringWithFormat:@"%d0后", (n_year_now - nAge) % 100 / 10]];
            }
            
        }
    }
    
    else {
        static NSString* s_str_opus_cell_identifier = @"stringOpusCellIdentifier";
        
        cur_cell = [tableMyOpus dequeueReusableCellWithIdentifier:s_str_opus_cell_identifier];
        if (nil == cur_cell) {
            cur_cell = [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:s_str_opus_cell_identifier] autorelease];
            
            UIImageView* image_head_pic = [[[UIImageView alloc] initWithFrame:CGRectMake(3, 5, 60, 60)] autorelease];
            [image_head_pic setTag:TAG_OPUS_HEAD_PIC];
            [cur_cell.contentView addSubview:image_head_pic];
            
            UILabel* label_opus_name = [[[UILabel alloc] initWithFrame:CGRectMake(70, 5, 190, 20)] autorelease];
            [label_opus_name setTag:TAG_OPUS_NAME];
            [label_opus_name setFont:[UIFont systemFontOfSize:16]];
            [label_opus_name setBackgroundColor:[UIColor clearColor]];
            [cur_cell.contentView addSubview:label_opus_name];
            
            UIImageView* image_listen_cnt = [[[UIImageView alloc] initWithFrame:CGRectMake(70, 30, 10, 10)] autorelease];
            [image_listen_cnt setImage:CImageMgr::GetImageEx("MyPageView.png")];
            [cur_cell.contentView addSubview:image_listen_cnt];
            
            UILabel* label_listen_cnt = [[[UILabel alloc] initWithFrame:CGRectMake(82, 30, 36, 10)] autorelease];
            [label_listen_cnt setBackgroundColor:[UIColor clearColor]];
            [label_listen_cnt setFont:[UIFont systemFontOfSize:8]];
            [label_listen_cnt setTag:TAG_OPUS_VIEW];
            [cur_cell.contentView addSubview:label_listen_cnt];
            
            UIImageView* image_comment_cnt = [[[UIImageView alloc] initWithFrame:CGRectMake(120, 30, 10, 10)] autorelease];
            [image_comment_cnt setImage:CImageMgr::GetImageEx("MyPageComment.png")];
            [cur_cell.contentView addSubview:image_comment_cnt];
            
            UILabel* label_comment_cnt = [[[UILabel alloc] initWithFrame:CGRectMake(132, 30, 36, 10)] autorelease];
            [label_comment_cnt setBackgroundColor:[UIColor clearColor]];
            [label_comment_cnt setFont:[UIFont systemFontOfSize:8]];
            [label_comment_cnt setTag:TAG_OPUS_COMMENT];
            
            [cur_cell.contentView addSubview:label_comment_cnt];
            
            UIImageView* image_flower_cnt = [[[UIImageView alloc] initWithFrame:CGRectMake(170, 30, 10, 10)] autorelease];
            [image_flower_cnt setImage:CImageMgr::GetImageEx("MyPageFlower.png")];
            [cur_cell.contentView addSubview:image_flower_cnt];
            
            UILabel* label_flower_cnt = [[[UILabel alloc] initWithFrame:CGRectMake(182, 30, 36, 10)] autorelease];
            [label_flower_cnt setBackgroundColor:[UIColor clearColor]];
            [label_flower_cnt setFont:[UIFont systemFontOfSize:8]];
            [label_flower_cnt setTag:TAG_OPUS_FLOWER];
            [cur_cell.contentView addSubview:label_flower_cnt];
            
            UILabel* label_opus_from = [[[UILabel alloc] initWithFrame:CGRectMake(70, 53, 190, 13)] autorelease];
            [label_opus_from setBackgroundColor:[UIColor clearColor]];
            [label_opus_from setFont:[UIFont systemFontOfSize:10]];
            [label_opus_from setTextColor:[UIColor grayColor]];
            [label_opus_from setTag:TAG_OPUS_FROM];
            [cur_cell.contentView addSubview:label_opus_from];
            
            UIButton* btn_play = [[[UIButton alloc] initWithFrame:CGRectMake(269, 13, 42, 42)] autorelease];
            [btn_play setBackgroundImage:CImageMgr::GetImageEx("MyPagePlay.png") forState:(UIControlStateNormal)];
            [btn_play setBackgroundImage:CImageMgr::GetImageEx("MyPagePlayClick.png") forState:(UIControlStateHighlighted)];
            [btn_play setTag:TAG_BTN_PLAY];
            [btn_play addTarget:self action:@selector(onBtnClicked:) forControlEvents:(UIControlEventTouchUpInside)];
            [cur_cell.contentView addSubview:btn_play];
        }
        
        UILabel* label_title = (UILabel*)[cur_cell.contentView viewWithTag:TAG_OPUS_NAME];
        if (label_title) {
            [label_title setText:[NSString stringWithFormat:@"%@-%@", strUserName, ((OpusItem*)[_opusArray objectAtIndex:(indexPath.row - 1)]).strOpusName]];
        }
        
        UILabel* label_view = (UILabel*)[cur_cell.contentView viewWithTag:TAG_OPUS_VIEW];
        if (label_view) {
            [label_view setText:[NSString stringWithFormat:@"%d", ((OpusItem*)[_opusArray objectAtIndex:(indexPath.row - 1)]).nOpusView]];
        }
        
        UILabel* label_comment = (UILabel*)[cur_cell.contentView viewWithTag:TAG_OPUS_COMMENT];
        if (label_comment) {
            [label_comment setText:[NSString stringWithFormat:@"%d", ((OpusItem*)[_opusArray objectAtIndex:(indexPath.row - 1)]).nOpusComment]];
        }
        
        UILabel* label_flower = (UILabel*)[cur_cell.contentView viewWithTag:TAG_OPUS_FLOWER];
        if (label_flower) {
            [label_flower setText:[NSString stringWithFormat:@"%d", ((OpusItem*)[_opusArray objectAtIndex:(indexPath.row - 1)]).nOpusFlower]];
        }
        
        UILabel* label_from = (UILabel*)[cur_cell.contentView viewWithTag:TAG_OPUS_FROM];
        if (label_from) {
            [label_from setText:[NSString stringWithFormat:@"来自%@ %@", ((OpusItem*)[_opusArray objectAtIndex:(indexPath.row - 1)]).strOpusSrc, ((OpusItem*)[_opusArray objectAtIndex:(indexPath.row - 1)]).strOpusTime]];
        }
        
        [self startLoadImage:cur_cell imageUrl:strHeadPicUrl];
    }
    
    [cur_cell setSelectionStyle:(UITableViewCellSelectionStyleNone)];
    
    return cur_cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.row) {
        return UITableViewCellEditingStyleNone;
    }else {
        return UITableViewCellEditingStyleDelete;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.row) {
        return NO;
    }else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* str_del_url = [NSString stringWithFormat:DELETE_OPUS_URL, ((OpusItem*)[_opusArray objectAtIndex:(indexPath.row - 1)]).strKid, User::GetUserInstance()->getUserId(), User::GetUserInstance()->getSid()];
    if (NETSTATUS_NONE != CHttpRequest::GetNetWorkStatus()) {
        KS_BLOCK_DECLARE{
            std::string str_out = "";
            if(CHttpRequest::QuickSyncGet([str_del_url UTF8String], str_out)){
                std::map<std::string,std::string> mapTokens;
                KwTools::StringUtility::TokenizeKeyValue(str_out,mapTokens,"||","=",true);
                if (mapTokens["result"]=="ok") {
                    KS_BLOCK_DECLARE{
                        [_opusArray removeObjectAtIndex:(indexPath.row - 1)];
                        [tableMyOpus deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
                        [[[[iToast makeText:NSLocalizedString(@"删除成功", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                    }
                    KS_BLOCK_SYNRUN();
                }else {
                    KS_BLOCK_DECLARE{
                        [[[[iToast makeText:NSLocalizedString(@"删除失败，请稍后再试", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                    }
                    KS_BLOCK_SYNRUN();
                }
            }else {
                KS_BLOCK_DECLARE{
                    [[[[iToast makeText:NSLocalizedString(@"删除失败，请稍后再试", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
                }
                KS_BLOCK_SYNRUN();
            }
        }
        KS_BLOCK_RUN_THREAD();
    }else {
        [[[[iToast makeText:NSLocalizedString(@"网络连接失败，请稍后再试", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

#pragma mark button response
-(void) onBtnClicked : (id)sender{
    UIButton* cur_btn = (UIButton*)sender;
    
    UITableViewCell* cur_cell = nil;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        cur_cell = (UITableViewCell*)[[[(UIButton*)sender superview]superview] superview];
    }else {
        cur_cell = (UITableViewCell*)[[(UIButton*)sender superview]superview];
    }
    
    switch (cur_btn.tag) {
        case TAG_BTN_FANS:
        {
            if (cur_cell) {
                UIView* view_fans = (UIView*)[cur_cell.contentView viewWithTag:TAG_VIEW_FANS];
                if (view_fans) {
                    [view_fans setBackgroundColor:UIColorFromRGBValue(0x22ab57)];
                }
            }
            
            KSFansFollowViewController* fans_follow_view_controller = [[[KSFansFollowViewController alloc] initWithType:@"我的粉丝"] autorelease];
            
            [ROOT_NAVAGATION_CONTROLLER pushViewController:fans_follow_view_controller animated:YES];
            
            NSLog(@"fans clicked!");
            break;
        }
        case TAG_BTN_FOLLOW:
        {
            if (cur_cell) {
                UIView* view_follow = (UIView*)[cur_cell.contentView viewWithTag:TAG_VIEW_FOLLOW];
                if (view_follow) {
                    [view_follow setBackgroundColor:UIColorFromRGBValue(0x22ab57)];
                }
            }
            
            KSFansFollowViewController* fans_follow_view_controller = [[[KSFansFollowViewController alloc] initWithType:@"我的关注"] autorelease];
            
            [ROOT_NAVAGATION_CONTROLLER pushViewController:fans_follow_view_controller animated:YES];
            
            NSLog(@"follow clicked!");
            break;
        }
        case TAG_BTN_EDIT:
        {
            MyPageEditViewController * myPageEditController=[[MyPageEditViewController alloc] init];
            [ROOT_NAVAGATION_CONTROLLER pushViewController:myPageEditController animated:YES];
            [myPageEditController release];
            break;
        }
        case TAG_BTN_PLAY:
        {
            NSIndexPath* indexPath = [tableMyOpus indexPathForCell:cur_cell];
            if (indexPath) {
                NSString* str_kid = ((OpusItem*)[_opusArray objectAtIndex:(indexPath.row - 1)]).strKid;
                if (str_kid) {
                    NowPlayViewController* play_view = [[[NowPlayViewController alloc] init] autorelease];
                    [play_view setKid:str_kid];
                    [ROOT_NAVAGATION_CONTROLLER pushViewController:play_view animated:YES];
                }
            }
            break;
        }
            
        case TAG_BTN_HEAD_PIC:
        {
            UIActionSheet *chooseHead=[[[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"从相册中选取图片",@"立即拍照", nil] autorelease];
            [chooseHead showInView:[UIApplication sharedApplication].keyWindow];
        }
        default:
            break;
    }
}

- (void) onBtnTouchDown : (id)sender{
    UIButton* cur_btn = (UIButton*)sender;
    
    UITableViewCell* cur_cell = nil;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        cur_cell = (UITableViewCell*)[[[(UIButton*)sender superview]superview] superview];
    }else {
        cur_cell = (UITableViewCell*)[[(UIButton*)sender superview]superview];
    }
    
    switch (cur_btn.tag) {
        case TAG_BTN_FANS:
        {
            if (cur_cell) {
                UIView* view_fans = (UIView*)[cur_cell.contentView viewWithTag:TAG_VIEW_FANS];
                if (view_fans) {
                    [view_fans setBackgroundColor:UIColorFromRGBValue(0x898989)];
                }
            }
            break;
        }
        case TAG_BTN_FOLLOW:
        {
            if (cur_cell) {
                UIView* view_follow = (UIView*)[cur_cell.contentView viewWithTag:TAG_VIEW_FOLLOW];
                if (view_follow) {
                    [view_follow setBackgroundColor:UIColorFromRGBValue(0x898989)];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark head and foot delegate
- (void)refreshViewBeginRefreshing:(KBRefreshBaseView *)refreshView
{
    if (refreshView == _foot_view){
        [self updateMyPage];
    }
}
-(void)endRefresh
{
    [_foot_view endRefreshing];
}

-(void)updateMyPage{
    if (User::GetUserInstance()->isOnline()) {
        
        NSString* str_request_url = [NSString stringWithFormat:MY_PAGE_URL, User::GetUserInstance()->getUserId(), User::GetUserInstance()->getUserId(), User::GetUserInstance()->getSid()];
        
        NSLog(@"%@", str_request_url);
        
        KS_BLOCK_DECLARE{
            bool breadcache = false;
            
            void* pData(NULL);
            unsigned uiLen(0);
            if(CHttpRequest::QuickSyncGet([str_request_url UTF8String], pData, uiLen)){
                NSData* data=[NSData dataWithBytesNoCopy:pData length:uiLen freeWhenDone:YES];
                CCacheMgr::GetInstance()->Cache(T_SECOND, 72 * 60 * 60, [str_request_url UTF8String], [data bytes], data.length);
                breadcache = true;
            }else {
                CCacheMgr::GetInstance()->UpdateTimeToNow([str_request_url UTF8String]);
                
                breadcache = true;
            }
            
            if (breadcache) {
                void* XMLData(NULL);
                unsigned length(0);
                BOOL bOutTime;
                if (CCacheMgr::GetInstance()->Read([str_request_url UTF8String], XMLData, length, bOutTime) && length > 0) {
                    [_opusArray removeAllObjects];
                    
                    NSData *data=[NSData dataWithBytesNoCopy:XMLData length:length freeWhenDone:YES];
                    
                    GDataXMLDocument *doc = [[[GDataXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
                    
                    GDataXMLElement* rootElement = [doc rootElement];
                    
                    NSArray* arry_elem = [rootElement children];
                    if (strUserName) {
                        [strUserName release];
                        strUserName = nil;
                    }
                    strUserName = [[[[rootElement elementsForName:@"uname"] objectAtIndex:0] stringValue] retain];
                    nSex = [[[[rootElement elementsForName:@"sex"] objectAtIndex:0] stringValue] intValue];
                    
                    if (strBirthCity) {
                        [strBirthCity release];
                        strBirthCity = nil;
                    }
                    strBirthCity = [[[[rootElement elementsForName:@"birth_city"] objectAtIndex:0] stringValue] retain];
                    
                    if (strResidentCity) {
                        [strResidentCity release];
                        strResidentCity = nil;
                    }
                    strResidentCity = [[[[rootElement elementsForName:@"resident_city"] objectAtIndex:0] stringValue] retain];
                    
                    nAge = [[[[rootElement elementsForName:@"age"] objectAtIndex:0] stringValue] intValue];
                    
                    nFans = [[[[rootElement elementsForName:@"fans"] objectAtIndex:0] stringValue] intValue];
                    
                    nFollow = [[[[rootElement elementsForName:@"fav"] objectAtIndex:0] stringValue] intValue];
                    
                    if (strHeadPicUrl) {
                        [strHeadPicUrl release];
                        strHeadPicUrl = nil;
                    }
                    strHeadPicUrl = [[[[rootElement elementsForName:@"userpic"] objectAtIndex:0] stringValue] retain];
                    
                    NSArray* arry_opus_list = [[[rootElement elementsForName:@"kge_list"] objectAtIndex:0] elementsForName:@"kge"];
                    if ([arry_opus_list count]) {
                        for (GDataXMLElement* chapter in arry_opus_list) {
                            OpusItem* cur_opus = [[[OpusItem alloc] init] autorelease];
                            cur_opus.strKid = [[[[chapter elementsForName:@"id"] objectAtIndex:0] stringValue] retain];
                            cur_opus.strOpusName = [[[[chapter elementsForName:@"title"] objectAtIndex:0] stringValue] retain];
                            cur_opus.strOpusSrc = [[[[chapter elementsForName:@"src"] objectAtIndex:0] stringValue] retain];
                            cur_opus.strOpusTime = [[[chapter elementsForName:@"time"] objectAtIndex:0] stringValue];
                            cur_opus.nOpusComment = [[[[chapter elementsForName:@"comment"] objectAtIndex:0] stringValue] intValue];
                            cur_opus.nOpusFlower = [[[[chapter elementsForName:@"flower"] objectAtIndex:0] stringValue] intValue];
                            cur_opus.nOpusView = [[[[chapter elementsForName:@"view"] objectAtIndex:0] stringValue] intValue];
                            
                            [_opusArray addObject:cur_opus];
                        }
                    }
                }
                
            }
            
            KS_BLOCK_DECLARE{
                [tableMyOpus reloadData];
                [self endRefresh];
            }
            KS_BLOCK_SYNRUN();
        }
        KS_BLOCK_RUN_THREAD();
    }
}

-(void)startLoadImage : (UITableViewCell*)cell imageUrl : (NSString*)str_image_url
{
    __block void* imageData = NULL;
    __block unsigned length = 0;;
    __block BOOL outOfDate;
    if (CCacheMgr::GetInstance()->Read([str_image_url UTF8String], imageData, length, outOfDate)) {
        NSData *cacheImageData=[[[NSData alloc] initWithBytesNoCopy:imageData length:length freeWhenDone:YES] autorelease];
        UIImage *image = [[[UIImage alloc] initWithData:cacheImageData] autorelease];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView* image_view = (UIImageView*)[cell.contentView viewWithTag:TAG_OPUS_HEAD_PIC];
            [image_view setImage:image];
        });
    }
    else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:str_image_url]];
            if (imageData) {
                UIImage *image = [[[UIImage alloc] initWithData:imageData] autorelease];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImageView* image_view = (UIImageView*)[cell.contentView viewWithTag:TAG_OPUS_HEAD_PIC];
                    [image_view setImage:image];
                    
                    CCacheMgr::GetInstance()->Cache(T_DAY, 3, [str_image_url UTF8String], [imageData bytes], [imageData length]);
                });
            }
            else{
                UIImageView* image_view = (UIImageView*)[cell.contentView viewWithTag:TAG_OPUS_HEAD_PIC];
                [image_view setImage:CImageMgr::GetImageEx("defaultface.png")];
                NSLog(@"load image fail");
            }
        });
    }
}

-(void)startLoadHeadPic : (UIImageView*)head_pic imageUrl : (NSString*)str_image_url
{
    __block void* imageData = NULL;
    __block unsigned length = 0;;
    __block BOOL outOfDate;
    if (CCacheMgr::GetInstance()->Read([str_image_url UTF8String], imageData, length, outOfDate)) {
        NSData *cacheImageData=[[[NSData alloc] initWithBytesNoCopy:imageData length:length freeWhenDone:YES] autorelease];
        UIImage *image = [[[UIImage alloc] initWithData:cacheImageData] autorelease];
        dispatch_async(dispatch_get_main_queue(), ^{
            [head_pic setImage:image];
        });
    }
    else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:str_image_url]];
            if (imageData) {
                UIImage *image = [[[UIImage alloc] initWithData:imageData] autorelease];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [head_pic setImage:image];
                    
                    CCacheMgr::GetInstance()->Cache(T_DAY, 3, [str_image_url UTF8String], [imageData bytes], [imageData length]);
                });
            }
            else{
                [head_pic setImage:CImageMgr::GetImageEx("defaultface.png")];
                NSLog(@"load image fail");
            }
        });
    }
}

@end
