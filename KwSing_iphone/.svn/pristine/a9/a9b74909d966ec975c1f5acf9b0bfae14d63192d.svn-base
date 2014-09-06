
//
//  ShareViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-8-24.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "ShareViewController.h"
#include "ImageMgr.h"
#include "globalm.h"
#include "MessageManager.h"
#include "HttpRequest.h"
#include "User.h"
#import <QuartzCore/QuartzCore.h>
#include "iToast.h"
#include "KSOtherLoginViewController.h"
#include "KwTools.h"
#include "MobClick.h"
#include "KuwoLog.h"
#import "KSProgressView.h"
#import "KSOtherLoginViewController.h"
#import "KSAppDelegate.h"
#import "MyOpusData.h"
#import "MediaSaveInterface.h"
#import "MediaModelFactory.h"
#import "KSAudioLength.h"
#import "IMediaSaveProcessObserver.h"
#import "IMyOpusObserver.h"
#import "LoginViewController.h"
#import "RecordTask.h"
#include "UMengLog.h"
#include "KwUMengElement.h"
#include "KuwoConstants.h"
#include "SBJson.h"

#define URL_SHARE       @"http://changba.kuwo.cn/kge/mobile/pubWeiBo?"
//#define URL_SHARE       @"http://60.28.205.41/kge/mobile/pubWeiBo?"
#define SINA_BTN_TAG        101
#define QQ_BTN_TAG          102
//#define TENCENT_BTN_TAG     103
#define RENREN_BTN_TAG      104

#define SINA_ALERT_TAG      105
#define QQ_ALERT_TAG        106
//#define TENCNET_ALERT_TAG   107
#define RENREN_ALERT_TAG    108
#define KUWO_ALERT_TAG      109
#define CANCEL_ALERT_TAG   110
#define LOTTERY_ALERT_TAG   111
#define WAITING_LOTTERY_TAG 112
#define RESULT_TAG       113

#define SHARE_BTN_SIZE      30
#define SHARE_BTN_GAP       8

#define MIN_UPLOAD_LENGTH   60000

@interface ShareViewController ()<UITextViewDelegate>
{
    UILabel* labWordTip;
    UITextView * textviewShare;
    bool bReturn;
    UIActivityIndicatorView * indicatorView;
    UIButton* btnSend;
    UIView * popView;
    KSProgressView * progressView;
    UIButton *cancelBtn;
    
    UILabel* progressLabel;
    bool _isSinaSelected;
    bool _isTencentSelected;
    bool _isQQSelect;
    bool _isRenrenSelected;
    
    UIButton *SinaBtn;
    UIButton *QQBtn;
    UIButton *TencentBtn;
    UIButton *RenRenBtn;
    
    CMediaSaveInterface * m_mediaSave;
    
    BOOL        _isActivity;
    NSString   *_actiId;
    NSString   *_actiType;
    NSString   *_shareCont;
}
-(void)generateShareText;
-(void)generateShareURL:(NSString*)strkid;
-(int)baseUrlLength;
-(BOOL)hasOnePlatformtoShare;
@end

@implementation ShareViewController
@synthesize shareText=_shareText,isShare=_isShare,shareURL=_shareURL;

#pragma mark
#pragma mark init methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        labWordTip=nil;
        textviewShare=nil;
        indicatorView=nil;
        btnSend=nil;
        popView=nil;
        progressLabel=nil;
        progressView=nil;
        SinaBtn=nil;
        TencentBtn=nil;
        QQBtn=nil;
        RenRenBtn=nil;
        _shareSongInfo=nil;
        bReturn = false;
        _isShare=false;
        _isVideo=false;
        _isSinaSelected=User::GetUserInstance()->isSinaBind();
        _isTencentSelected=User::GetUserInstance()->isTencnetBind();
        _isQQSelect=User::GetUserInstance()->isQQBind();
        _isRenrenSelected=User::GetUserInstance()->isRenrenBind();
        
        _isActivity=false;
        _actiId=nil;
        _actiType=nil;
        
        if (CRecordTask::GetInstance()->m_bIsOtherActivity) {
            _isActivity = true;
            std::string tmpId = CRecordTask::GetInstance()->activityId;
            if (tmpId != "") {
                NSArray *array = CRecordTask::GetInstance()->m_ActivityArray;
                for (NSDictionary *dic in array) {
                    if (tmpId == [[dic objectForKey:@"bangId"] UTF8String]) {
                        _actiType = [dic objectForKey:@"type"];
                        _shareCont = [dic objectForKey:@"sharecont"];
                    }
                }
            }
        }
        
        GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS, IUserStatusObserver);
        GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_MEDIA_SAVE_PROGRESS,IMediaSaveProcessObserver);
        GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_MYOPUS, IMyOpusObserver);
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
    
    CGRect rc = [self view].bounds;
    CGRect rcnav = self.navigationController.navigationBar.bounds;
    rc = BottomRect(rc,rc.size.height-rcnav.size.height,0);
    
    UIView* view_title = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    [view_title setBackgroundColor:UIColorFromRGBValue(0x0a63a7)];
    [self.view addSubview:view_title];
    
    UILabel* label_title = [[[UILabel alloc] initWithFrame:CGRectMake(112.5, 8, 95, 28)] autorelease];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextAlignment:(NSTextAlignmentCenter)];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont systemFontOfSize:18]];
    [view_title addSubview:label_title];
    
    UIButton* btn_ret = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_ret.frame = CGRectMake(0, 0, 44, 44);
    [btn_ret setBackgroundColor:[UIColor clearColor]];
    btn_ret.imageEdgeInsets = UIEdgeInsetsMake(10, 14.5, 10, 14.5);
    [btn_ret setImage:CImageMgr::GetImageEx("KgeReturnBtn.png") forState:(UIControlStateNormal)];
    [btn_ret addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view_title addSubview:btn_ret];

    if(_isShare )
        label_title.text = @"分享作品";
    else
        label_title.text = @"上传作品";
    
    if (!_isShare) {
        if(_shareSongInfo && _shareSongInfo->eumLocalState !=CRecoSongInfo::STATE_NOSAVE){
            std::vector<CRecoSongInfo*> vec;
            CMyOpusData::GetInstance()->GetAllSongs(vec);
            _shareSongInfo=vec[_songIndex];
        }
        [self generateShareText];
    }
    
    labWordTip = [[[UILabel alloc]initWithFrame:CGRectMake(11, rcnav.size.height+136, 300,25)]autorelease];
    labWordTip.Font = [UIFont systemFontOfSize:15];
    labWordTip.backgroundColor = [UIColor clearColor];
    labWordTip.textColor = UIColorFromRGBValue(0x969696);
    labWordTip.textAlignment = UITextAlignmentRight;
    labWordTip.text = [NSString stringWithFormat:@"还可以输入%d个字",140-[_shareText length]-[self baseUrlLength]];
    [[self view ]addSubview:labWordTip];
    
    textviewShare = [[[UITextView alloc]initWithFrame:CGRectMake(8, rcnav.size.height+8, 304, 120)]autorelease];
    [textviewShare setText:_shareText];
    textviewShare.Font = [UIFont systemFontOfSize:15];
    
    [textviewShare setDelegate:self];
    textviewShare.layer.cornerRadius = 6;
    textviewShare.layer.masksToBounds = YES;
    textviewShare.returnKeyType = UIReturnKeyDefault;
    [[self view ]addSubview:textviewShare];
    
    [textviewShare becomeFirstResponder];
    
    SinaBtn=[[[UIButton alloc] initWithFrame:CGRectMake(SHARE_BTN_GAP, rcnav.size.height+136, SHARE_BTN_SIZE, SHARE_BTN_SIZE)] autorelease];
    [SinaBtn setTag:SINA_BTN_TAG];
    [SinaBtn setBackgroundImage:CImageMgr::GetImageEx("sinaShareDown.png") forState:UIControlStateNormal];
    [SinaBtn setBackgroundImage:CImageMgr::GetImageEx("sinaShare.png") forState:UIControlStateSelected];
    [SinaBtn addTarget:self action:@selector(onSelectShare:) forControlEvents:UIControlEventTouchUpInside];
    [SinaBtn setSelected:_isSinaSelected];
    [[self view] addSubview:SinaBtn];
    
    QQBtn=[[[UIButton alloc] initWithFrame:CGRectMake(2*SHARE_BTN_GAP+SHARE_BTN_SIZE, rcnav.size.height+136, SHARE_BTN_SIZE, SHARE_BTN_SIZE)] autorelease];
    [QQBtn setBackgroundImage:CImageMgr::GetImageEx("qqShareDown.png") forState:UIControlStateNormal];
    [QQBtn setBackgroundImage:CImageMgr::GetImageEx("qqShare.png") forState:UIControlStateSelected];
    [QQBtn setTag:QQ_BTN_TAG];
    [QQBtn addTarget:self action:@selector(onSelectShare:) forControlEvents:UIControlEventTouchUpInside];
    [QQBtn setSelected:_isQQSelect];
    [[self view] addSubview:QQBtn];
    /*
    TencentBtn=[[[UIButton alloc] initWithFrame:CGRectMake(3*SHARE_BTN_GAP+2*SHARE_BTN_SIZE, rcnav.size.height+136, SHARE_BTN_SIZE, SHARE_BTN_SIZE)] autorelease];
    [TencentBtn setBackgroundImage:CImageMgr::GetImageEx("tencentShareDown.png") forState:UIControlStateNormal];
    [TencentBtn setBackgroundImage:CImageMgr::GetImageEx("tencentShare.png") forState:UIControlStateSelected];
    [TencentBtn setTag:TENCENT_BTN_TAG];
    [TencentBtn addTarget:self action:@selector(onSelectShare:) forControlEvents:UIControlEventTouchUpInside];
    [TencentBtn setSelected:_isTencentSelected];
    [[self view] addSubview:TencentBtn];
    */
    RenRenBtn=[[[UIButton alloc] initWithFrame:CGRectMake(3*SHARE_BTN_GAP+2*SHARE_BTN_SIZE,rcnav.size.height+136, SHARE_BTN_SIZE, SHARE_BTN_SIZE)] autorelease];
    [RenRenBtn setBackgroundImage:CImageMgr::GetImageEx("renrenShareDown.png") forState:UIControlStateNormal];
    [RenRenBtn setBackgroundImage:CImageMgr::GetImageEx("renrenShare.png") forState:UIControlStateSelected];
    [RenRenBtn setTag:RENREN_BTN_TAG];
    [RenRenBtn addTarget:self action:@selector(onSelectShare:) forControlEvents:UIControlEventTouchUpInside];
    [RenRenBtn setSelected:_isRenrenSelected];
    [[self view] addSubview:RenRenBtn];
    
    btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    if (_isShare) {
        [btnSend setTitle:@"发布" forState: UIControlStateNormal];
    }
    else{
        [btnSend setTitle:@"上传" forState: UIControlStateNormal];
    }
    [btnSend setBackgroundImage:CImageMgr::GetImageEx("topReturnBtn_6.png") forState:UIControlStateNormal];
    [btnSend setBackgroundImage:CImageMgr::GetImageEx("topReturnBtnDown_6.png") forState:UIControlStateHighlighted];
    btnSend.titleLabel.font = [UIFont systemFontOfSize:14];
    btnSend.frame = CGRectMake(self.view.bounds.size.width-10-47, 9, 47,28);
    [btnSend setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [btnSend addTarget:self action:@selector(SendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:btnSend];
    
    indicatorView = [[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)]autorelease];
    [indicatorView setCenter:CGPointMake(160, 100)];
    [[self view]addSubview:indicatorView];
    [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.hidden = true;
    [[self view] setBackgroundColor:CImageMgr::GetBackGroundColor()];
    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
    
    
}
-(void)InitProgressView
{
    if(popView == nil)
    {
        popView = [[[UIView alloc]initWithFrame:self.view.bounds]autorelease];
        popView.backgroundColor = UIColorFromRGBAValue(0x000000,80);
        [[self view]addSubview:popView];
        
        CGRect rc = CenterRect(self.view.bounds, 180, 60);
        rc.origin.y -= 20;
        
        UIView * bkview = [[[UIView alloc]initWithFrame:rc]autorelease];
        bkview.backgroundColor = UIColorFromRGBAValue(0x000000,150);
        bkview.layer.cornerRadius = 4;
        bkview.layer.masksToBounds = true;
        [popView addSubview:bkview];
        
        progressLabel = [[[UILabel alloc]initWithFrame:CGRectMake(10,10, 160,20)] autorelease];
        progressLabel.textAlignment = UITextAlignmentCenter;
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.textColor = [UIColor whiteColor];
        progressLabel.font = [UIFont systemFontOfSize:14];
        [bkview addSubview:progressLabel];
        
        progressView = [[[KSProgressView alloc]initWithFrame:CGRectMake(10, 35, 160, 15)]autorelease];
        [progressView setOuterColor: [UIColor whiteColor]] ;
        [progressView setInnerColor: [UIColor whiteColor]];
        [bkview addSubview:progressView];
        
        
        CGRect btnRect=CGRectMake(rc.origin.x+rc.size.width-10, rc.origin.y-rc.size.height/2+20, 20, 20);
        cancelBtn=[[[UIButton alloc] initWithFrame:btnRect] autorelease];
        [cancelBtn setBackgroundImage:CImageMgr::GetImageEx("close_X.png") forState:UIControlStateNormal];
        [cancelBtn setEnabled:YES];
        [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setHidden:YES];
        
        [popView addSubview:cancelBtn];
    }
    [progressView setProgress:0];
}
-(void)cancelBtnClick
{
//    UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"是否取消上传？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] autorelease];
//    [alert setTag:CANCEL_ALERT_TAG];
//    [alert show];
//    NSLog(@"cancel click");
    CMyOpusData::GetInstance()->cancelUpload();
}
#pragma mark
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [textviewShare resignFirstResponder];
}
-(BOOL)hasOnePlatformtoShare
{
    if (_isSinaSelected || _isQQSelect || _isTencentSelected || _isRenrenSelected)
        return true;
    return false;
}
#pragma mark
#pragma mark set methods

-(void)setShareSongInfo:(CRecoSongInfo*)songInfo index:(int)songIndex isVideo:(BOOL)bVideo;
{
    _shareSongInfo=songInfo;
    _songIndex=songIndex;
    _isVideo=bVideo;
}
-(void)setShareSongInfo:(CRecoSongInfo *)songInfo index:(int)songIndex
{
    _shareSongInfo=songInfo;
    _songIndex=songIndex;
}
#pragma mark
-(void)generateShareText
{
    if(_shareSongInfo->strRid !=""){
        if (0 == _shareSongInfo->uiPoints) {
            _shareText = [[NSString stringWithFormat:@"我用#酷我K歌#iPhone版演唱了《%@》大家快来听听吧!",[NSString stringWithUTF8String:_shareSongInfo->strSongName.c_str()]] retain];
        }else {
            _shareText = [[NSString stringWithFormat:@"我用#酷我K歌#iPhone版演唱了《%@》，得到%d分，击败了全国%d%%的网友哦，大家快来听听吧!"
                           ,[NSString stringWithUTF8String:_shareSongInfo->strSongName.c_str()]
                           ,_shareSongInfo->uiPoints
                           ,_shareSongInfo->uiDefeat] retain];
        }
    }
    else
        _shareText=[[NSString stringWithFormat:@"我用#酷我K歌#iPhone版清唱了一首歌，大家快来听听吧!"] retain];
    
    if (CRecordTask::GetInstance()->m_bIsHrbActivity && User::GetUserInstance()->getPartInType()==PARTIN) {
        _shareText=[[NSString stringWithFormat:@"速来围观！我刚参加#哈尔滨啤酒畅享中国好声音#活动，你也快来一展歌喉，即唱即赢，上传作品得Lifetrons金属扬声器、手机话费、酷我VIP等大奖！马上猛戳"] retain];
    }
    
    if (_isActivity) {
        _shareText = [_shareCont copy];
    }
}

-(void)generateShareURL:(NSString*)strkid
{
    
    if (CRecordTask::GetInstance()->m_bIsHrbActivity && User::GetUserInstance()->getPartInType()==PARTIN){
        _shareURL=[[NSString stringWithFormat:@"http://changba.kuwo.cn/kge/webmobile/activity/hrb/wapplay.html?id=%@",strkid] retain];
        return;
    }
    _shareURL=[[NSString stringWithFormat:@"http://kzone.kuwo.cn/mlog/u%@/kge_%@.htm"
                ,User::GetUserInstance()->getUserId()
                ,strkid] retain];
}
-(int)baseUrlLength
{
    NSString* baseUrl=@"http://kzone.kuwo.cn/mlog/u%@/kge_.htm";
    return [baseUrl length]+10;
}
-(void)onSelectShare:(UIButton *)sender
{
    if (!User::GetUserInstance()->isOnline()) {
        UIAlertView * alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"您还未登录，是否立即登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] autorelease];
        [alert setTag:KUWO_ALERT_TAG];
        [alert show];
    }
    if (sender.selected) {
        sender.selected=false;
        if (sender.tag == SINA_BTN_TAG) {
            _isSinaSelected=false;
        }
        else if(sender.tag == QQ_BTN_TAG){
            _isQQSelect=false;
        }
        else if (sender.tag == RENREN_BTN_TAG){
           _isRenrenSelected=false;
        }
//        else{
//            _isRenrenSelected=false;
//        }
    }
    else{
        if (sender.tag == SINA_BTN_TAG) {
            if (User::GetUserInstance()->isSinaBind()) {
                _isSinaSelected=true;
                sender.selected=true;
            }
            else{
                UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的Sina账号还未绑定，是否先去绑定？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"绑定", nil] autorelease];
                [alert setTag:SINA_ALERT_TAG];
                [alert setDelegate:self];
                [alert show];
            }
        }
        else if(sender.tag == QQ_BTN_TAG){
            if (User::GetUserInstance()->isQQBind()) {
                _isQQSelect=true;
                sender.selected=true;
            }
            else{
                UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的QQ账号还未绑定，是否先去绑定？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"绑定", nil] autorelease];
                [alert setTag:QQ_ALERT_TAG];
                [alert setDelegate:self];
                [alert show];
            }
        }
//        else if (sender.tag == TENCENT_BTN_TAG){
//            if (User::GetUserInstance()->isTencnetBind()) {
//                _isTencentSelected=true;
//                sender.selected=true;
//            }
//            else{
//                UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的腾讯微博账号还未绑定，是否先去绑定？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"绑定", nil] autorelease];
//                [alert setTag:TENCNET_ALERT_TAG];
//                [alert setDelegate:self];
//                [alert show];
//            }
//        }
        else if(sender.tag == RENREN_BTN_TAG){
            if (User::GetUserInstance()->isRenrenBind()) {
                _isRenrenSelected=true;
                sender.selected=true;
            }
            else{
                UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的人人账号还未绑定，是否先去绑定？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"绑定", nil] autorelease];
                [alert setTag:RENREN_ALERT_TAG];
                [alert setDelegate:self];
                [alert show];
            }
        }

    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        switch (alertView.tag) {
            case SINA_ALERT_TAG:
            {
                KSOtherLoginViewController* sinaBindPage=[[KSOtherLoginViewController alloc] initWithType:SINA];
                [sinaBindPage setIsShare:YES];
                [ROOT_NAVAGATION_CONTROLLER pushViewController:sinaBindPage animated:YES];
                [sinaBindPage release];
            }
                break;
            case QQ_ALERT_TAG:
            {
                KSOtherLoginViewController* qqBindPage=[[KSOtherLoginViewController alloc] initWithType:QQ];
                [qqBindPage setIsShare:YES];
                [ROOT_NAVAGATION_CONTROLLER pushViewController:qqBindPage animated:YES];
                [qqBindPage release];
            }
                break;
//            case TENCNET_ALERT_TAG:
//            {
//                KSOtherLoginViewController* tencentBindPage=[[KSOtherLoginViewController alloc] initWithType:TENCENTWEIBO];
//                [tencentBindPage setIsShare:YES];
//                [ROOT_NAVAGATION_CONTROLLER pushViewController:tencentBindPage animated:YES];
//                [tencentBindPage autorelease];
//            }
//                break;
            case RENREN_ALERT_TAG:
            {
                KSOtherLoginViewController* renrenBindPage=[[KSOtherLoginViewController alloc] initWithType:RENREN];
                [renrenBindPage setIsShare:YES];
                [ROOT_NAVAGATION_CONTROLLER pushViewController:renrenBindPage animated:YES];
                [renrenBindPage release];
            }
                break;
            case KUWO_ALERT_TAG:
            {
                KSLoginViewController *loginViewController=[[KSLoginViewController alloc] init];
                [ROOT_NAVAGATION_CONTROLLER pushViewController:loginViewController animated:YES];
                [loginViewController release];
            }
                break;
            case CANCEL_ALERT_TAG:
            {
                //取消上传
                //CMyOpusData::GetInstance()->cancelUpload();
            }
                break;
            case LOTTERY_ALERT_TAG:
            {
                [self lotteryThread];
            }
                break;
            default:
                break;
        }
    }
    else if (buttonIndex == 0){
        if (alertView.tag == LOTTERY_ALERT_TAG || alertView.tag == RESULT_TAG) {
            [self CloseView];
        }
    }
}
- (void)textViewDidChange:(UITextView *)textView
{
    if([textView.text length]+[self baseUrlLength]>140)
    {
        labWordTip.text = [NSString stringWithFormat:@"%d",140-[textView.text length]-[self baseUrlLength]];
        labWordTip.textColor = [UIColor redColor];
    }
    else
    {
        labWordTip.text = [NSString stringWithFormat:@"还可以输入%d个字",140-[textView.text length]-[self baseUrlLength]];
        labWordTip.textColor = UIColorFromRGBValue(0x969696);
    }
}

-(void) ReturnBtnClick:(id)sender
{
    bReturn = true;
    [self CloseView];
}
//根据songinfo判断保存与否，保存的直接上传，未保存的先保存再上传
-(void)StartUpload
{
    [self InitProgressView];
    
    if(_shareSongInfo && _shareSongInfo->eumLocalState == CRecoSongInfo::STATE_NOSAVE)
    {
        popView.hidden = false;
        cancelBtn.hidden = true;
        progressLabel.text = @"正在合成录音...";
        [self SaveRecord];
    }
    else if(_shareSongInfo && _shareSongInfo->eumLocalState == CRecoSongInfo::STATE_NOUPLOAD)
    {
        popView.hidden = false;
        cancelBtn.hidden = false;
        progressLabel.text = @"正在上传录音...";
        bool bret = CMyOpusData::GetInstance()->UploadSong(_songIndex);
        if(!bret)
        {
            popView.hidden = true;
            UIAlertView *alert = [[[UIAlertView alloc]initWithTitle:@"上传" message:@"上传失败" delegate:nil cancelButtonTitle:@"确定"otherButtonTitles:nil]autorelease];
                [alert show];
        }
    }
    
}
-(void)SaveRecord
{
    NSString *strname = GetCurTimeToString();
    strname = [strname stringByReplacingOccurrencesOfString:@":" withString:@""];
    strname = [strname stringByReplacingOccurrencesOfString:@"-" withString:@""];
    // 拷贝图片
    if(!_isVideo)
    {
        if (CRecordTask::GetInstance()->m_bIsHrbActivity && User::GetUserInstance()->getPartInType()==PARTIN){
            NSString *strImgPath = KwTools::Dir::GetPath(KwTools::Dir::PATH_MYIMAGE);
            strImgPath = [strImgPath stringByAppendingPathComponent:strname];
            NSString *strScrPath = [[NSBundle mainBundle] pathForResource:@"HrbBkImage@2x" ofType:@"jpg"];
            NSString *strDesPath = [strImgPath stringByAppendingPathComponent:@"HrbBkImage.jpg"];
            if(!KwTools::Dir::IsExistFile(strImgPath))
                KwTools::Dir::MakeDir(strImgPath);
            NSFileManager *fileManage = [NSFileManager defaultManager];
            NSError *error;
            BOOL bRes=[fileManage copyItemAtPath:strScrPath toPath:strDesPath error:&error];
            if (bRes) {
                _shareSongInfo->strLocalPicPack = [strImgPath UTF8String];
            }
        }
        else{
            NSString * strImgPath = KwTools::Dir::GetPath(KwTools::Dir::PATH_MYIMAGE);
            strImgPath = [strImgPath stringByAppendingPathComponent:strname];
            NSString * strsrcpath = KwTools::Dir::GetPath(KwTools::Dir::PATH_BKIMAGE);
            if(KwTools::Dir::CopyDir(strsrcpath, strImgPath))
            {
                _shareSongInfo->strLocalPicPack = [strImgPath UTF8String];
            }
        }
    }
    if(m_mediaSave)
        CMediaModelFactory::GetInstance()->ReleaseMediaSaver();
    // 保存音频
    m_mediaSave = CMediaModelFactory::GetInstance()->CreateMediaSaver(_isVideo);
    NSString *strpath = KwTools::Dir::GetPath(KwTools::Dir::PATH_OPUS);
    
    NSString *opusname;
    std::string strlog;
    if(_isVideo)
    {
        strlog = "mp4";
        opusname = [NSString stringWithFormat:@"%@%s",strname,".mp4"];
        _shareSongInfo->recoRes.eumFormat = FMT_VIDEO;
    }
    else {
        strlog = "m4a";
        opusname = [NSString stringWithFormat:@"%@%s",strname,".m4a"];
        _shareSongInfo->recoRes.eumFormat = FMT_AAC_48;
    }
    strpath = [strpath stringByAppendingPathComponent:opusname];
    CRecordTask::GetInstance()->m_strSaveFilePath = [strpath UTF8String];
    _shareSongInfo->recoRes.strLocalPath = [strpath UTF8String];
    _shareSongInfo->recoRes.uiDuration = [KSAudioLength getRecordAudioLength:_shareSongInfo->accompanyRes.strLocalPath];
    bool bret = m_mediaSave->SaveFile();
    if(!bret)
    {
        popView.hidden = true;
        UIAlertView* alert = [[[UIAlertView alloc]initWithTitle:@"保存" message:@"保存失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil]autorelease];
        [alert show];
    }
}

-(void)ShareThread
{
    if (_isShare && ![self hasOnePlatformtoShare]) {
        popView.hidden = true;
        btnSend.enabled=true;
        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"你还没有选择要分享第三方平台,\n请先选择！" delegate:nil cancelButtonTitle:@"好的，我知道了" otherButtonTitles:nil, nil] autorelease];
        [alert show];
        return;
    }
    
    if (![self hasOnePlatformtoShare]) {
        if (CRecordTask::GetInstance()->m_bIsHrbActivity && User::GetUserInstance()->getPartInType() == PARTIN) {
            [popView setHidden:true];
            btnSend.enabled=true;
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"恭喜，参赛成功!" message:@"您获得了一次抽奖的机会，点击下面的按钮立即开始抽奖吧" delegate:self cancelButtonTitle:@"不了，谢谢" otherButtonTitles:@"开始抽奖", nil] autorelease];
            [alert setTag:LOTTERY_ALERT_TAG];
            [alert show];
        }
        else{
            [self CloseView];
        }
        return;
    }
    indicatorView.hidden = false;
    btnSend.enabled = false;
    [indicatorView startAnimating];
    KS_BLOCK_DECLARE
    {
        NSString *strtext = [NSString stringWithFormat:@"%@%@",textviewShare.text,_shareURL];

        NSString *strtype = [NSString stringWithFormat:@"%@%@%@%@",_isSinaSelected? @"weibo%7C":@"",_isQQSelect? @"qq%7C":@"",_isTencentSelected? @"tencentweibo%7C":@"",_isRenrenSelected? @"renren%7C":@""];
        if (_isSinaSelected) {
            UMengLog(KS_SHARE_MUSIC, "SinaBlog");
        }
        if (_isQQSelect) {
            UMengLog(KS_SHARE_MUSIC, "QQspace");
        }
        if (_isTencentSelected) {
            UMengLog(KS_SHARE_MUSIC, "WeiXin");
        }
        if (_isRenrenSelected) {
            UMengLog(KS_SHARE_MUSIC, "Renren");
        }
        NSString *strid = User::GetUserInstance()->getUserId();
        NSString * strsid = User::GetUserInstance()->getSid();
        strtext = KwTools::Encoding::UrlEncode(strtext);
        NSString *strURL = [NSString stringWithFormat:@"%@t=%@&uid=%@&sid=%@&src=%@&cont=%@",URL_SHARE,
                                                 strtype,strid,strsid,@"kwsing_ios",strtext];
        if (CRecordTask::GetInstance()->m_bIsHrbActivity) {
            strURL = [strURL stringByAppendingFormat:@"&from=hrb"];
        }
        else if (_isActivity){
            strURL = [strURL stringByAppendingFormat:@"&from=%@",_actiType];
        }
        std::string strOut;
        //NSLog(@"share url:%@",strURL);
        BOOL bret = CHttpRequest::QuickSyncGet([strURL UTF8String], strOut);
        //NSLog(@"share return:%@",[NSString stringWithUTF8String:strOut.c_str()]);
        //没有对返回结果处理，只是关心我们的请求是否发送成功
        KS_BLOCK_DECLARE
        {
            [indicatorView stopAnimating];
            indicatorView.hidden = true;
            btnSend.enabled = true;
            if(!bReturn)// 页面还没有返回
            {
                if(bret)
                {
                    //bReturn = true;
                    [[[[iToast makeText:NSLocalizedString(@"发送分享请求成功", @"")]setGravity:iToastGravityCenter  offsetLeft:0
                                                                        offsetTop:-30 ] setDuration:2000] show];
    
                    //RTLog_Share(AR_SUCCESS,m_nShareType,[textviewShare.text UTF8String]);
                }
                else {
                   // RTLog_Share(AR_FAIL,m_nShareType,[textviewShare.text UTF8String]);
                    [[[[iToast makeText:NSLocalizedString(@"发送分享请求失败", @"")]setGravity:iToastGravityCenter offsetLeft:0
                                                                            offsetTop:-30]setDuration:2000] show];
                }
                if (CRecordTask::GetInstance()->m_bIsHrbActivity && User::GetUserInstance()->getPartInType() == PARTIN) {
                    [popView setHidden:true];
                    btnSend.enabled=true;
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"恭喜，参赛成功!" message:@"您获得了一次抽奖的机会，点击下面的按钮立即开始抽奖吧" delegate:self cancelButtonTitle:@"不了，谢谢" otherButtonTitles:@"开始抽奖", nil] autorelease];
                    [alert setTag:LOTTERY_ALERT_TAG];
                    [alert show];
                }
                else{
                    [self CloseView];
                }            }
        }
        KS_BLOCK_SYNRUN();
    }
    KS_BLOCK_RUN_THREAD();
}

-(void)SendBtnClick:(id)sender
{
    [textviewShare resignFirstResponder];
    if([textviewShare.text length]+[self baseUrlLength] > 140)
    {
        [[[iToast makeText:NSLocalizedString(@"字数超过140字", @"")]setGravity:iToastGravityCenter  offsetLeft:0
                                                        offsetTop:-30 ]show];
        return;
    }
    if (_isShare) {
        [self ShareThread];
    }
    else{
        [self StartUpload];
    }
}

#define URL_LOTTERY     @"http://changba.kuwo.cn/kge/mobile/ActivityServer?act=draw"
//#define URL_LOTTERY     @"http://60.28.205.41/kge/mobile/ActivityServer?act=draw"
-(void)lotteryThread
{
    UIAlertView *alert=[[[UIAlertView alloc] init] autorelease];
    [alert setTitle:@"正在抽奖..."];
    [alert setDelegate:self];
    [alert setTag:WAITING_LOTTERY_TAG];
    [alert show];
    
    KS_BLOCK_DECLARE
    {
        NSString *url = [NSString stringWithFormat:@"%@&uid=%@&sid=%@&key=dxFLTEs6vVY&src=HRB&v=%s&kid=%s",
                         URL_LOTTERY,
                                              User::GetUserInstance()->getUserId(),
                                              User::GetUserInstance()->getSid(),
                         KWSING_CLIENT_VERSION_STRING,
                         _shareSongInfo->strKid.c_str()];
        std::string resStr;
        BOOL res = CHttpRequest::QuickSyncGet([url UTF8String], resStr);
        NSLog(@"lottery url:%@",url);
        if (!res){
            KS_BLOCK_DECLARE{
                [alert dismissWithClickedButtonIndex:0 animated:NO];
                UIAlertView *alertView=[[[UIAlertView alloc] initWithTitle:@"很遗憾，没有中奖!" message:@"你可以再演唱一首作品，上传分享后可以再次得到一次抽奖的机会" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] autorelease];
                [alertView setTag:RESULT_TAG];
                [alertView show];
            }KS_BLOCK_SYNRUN()
            return;
        }
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *retDic = [parser objectWithString:[NSString stringWithUTF8String:resStr.c_str()]];
        
        NSString *result = [retDic objectForKey:@"result"];
        NSString *isPartin = [retDic objectForKey:@"isdraw"];
        NSString *msg = [retDic objectForKey:@"msg"];
        
        if ([result isEqualToString:@"ok"]) {
            if ([isPartin isEqualToString:@"1"] && msg) {
                KS_BLOCK_DECLARE{
                    [alert dismissWithClickedButtonIndex:0 animated:NO];
                    NSString *message = [NSString stringWithFormat:@"%@",msg];
                    UIAlertView *alertView=[[[UIAlertView alloc] initWithTitle:@"哇，中奖啦!" message:message delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] autorelease];
                    [alertView setTag:RESULT_TAG];
                    [alertView show];
                }KS_BLOCK_SYNRUN()
            }
            else {
                KS_BLOCK_DECLARE{
                    [alert dismissWithClickedButtonIndex:0 animated:NO];
                    UIAlertView *alertView=[[[UIAlertView alloc] initWithTitle:@"很遗憾，没有中奖!" message:@"你可以再演唱一首作品，上传分享后可以再次得到一次抽奖的机会" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] autorelease];
                    [alertView setTag:RESULT_TAG];
                    [alertView show];
                }KS_BLOCK_SYNRUN()
            }
        }
        else{
            KS_BLOCK_DECLARE{
                [alert dismissWithClickedButtonIndex:0 animated:NO];
                UIAlertView *alertView=[[[UIAlertView alloc] initWithTitle:@"很遗憾，没有中奖!" message:@"你可以再演唱一首作品，上传分享后可以再次得到一次抽奖的机会" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] autorelease];
                [alertView setTag:RESULT_TAG];
                [alertView show];
            }KS_BLOCK_SYNRUN()
        }
    }KS_BLOCK_RUN_THREAD()
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (alertView.tag == WAITING_LOTTERY_TAG) {
        UIActivityIndicatorView *waitingIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [waitingIndicator setCenter:CGPointMake(alertView.bounds.size.width/2, alertView.bounds.size.height/2)];
        [alertView addSubview:waitingIndicator];
        [waitingIndicator startAnimating];
    }
}

-(void)CloseView
{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_MEDIA_SAVE_PROGRESS,IMediaSaveProcessObserver);
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_MYOPUS, IMyOpusObserver);
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_USERSTATUS, IUserStatusObserver);
    
    if(m_mediaSave)
        CMediaModelFactory::GetInstance()->ReleaseMediaSaver();
    m_mediaSave = NULL;
//    if(_shareSongInfo)
//        delete _shareSongInfo;
//    _shareSongInfo = NULL;
    [ROOT_NAVAGATION_CONTROLLER popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark observer for bindInfo
-(void)IUserStatusObserver_AddBind:(LOGIN_TYPE)type :(BIND_RES)bindRes
{
    if (bindRes == BIND_SUCCESS) {
        [[[[iToast makeText:NSLocalizedString(@"绑定成功", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
        switch (type) {
            case SINA:
            {
                _isSinaSelected = true;
                [SinaBtn setSelected:YES];
                break;
            }
            case QQ:
            {
                _isQQSelect=true;
                [QQBtn setSelected:YES];
                break;
            }
            case TENCENTWEIBO:
            {
                _isTencentSelected=true;
                [TencentBtn setSelected:YES];
                break;
            }
            case RENREN:
            {
                _isRenrenSelected=true;
                [RenRenBtn setSelected:YES];
                break;
            }
            default:
                break;
        }
    }
    else if (bindRes == BIND_REPEAT){
        [[[[iToast makeText:NSLocalizedString(@"第三方账号已经绑定了其它的酷我账号", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
    }
    else{
        [[[[iToast makeText:NSLocalizedString(@"绑定失败", @"")]setGravity:iToastGravityCenter] setDuration:2000] show];
    }
}
#pragma mark
#pragma mark observer for save
-(void)IMediaSaveProcessObserver_SaveProgressChanged:(float)f_progress
{
    if (progressView) {
        [progressView setProgress:f_progress];
    }
}

-(void)IMediaSaveProcessObserver_SaveStatusFinish:(EFileSaveStatus)e_status : (int)n_save_time
{
    if(e_status == E_SAVE_FAIL)
    {
        popView.hidden = true;
        UIAlertView *alert= [[[UIAlertView alloc]initWithTitle:@"保存" message:@"保存失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil]autorelease];
        [alert show];
    }
    else {
        _shareSongInfo->eumLocalState = CRecoSongInfo::STATE_NOUPLOAD;
        NSLog(@"local pic:%s",_shareSongInfo->strLocalPicPack.c_str());
        BOOL bSaveRet = CMyOpusData::GetInstance()->AddSong(_shareSongInfo);
        if(bSaveRet){
            progressLabel.text = @"保存成功";
            bool res=CMyOpusData::GetInstance()->UploadSong(0);
            KS_BLOCK_DECLARE{
                if (!res) {
                    popView.hidden = true;
                    btnSend.enabled = true;
                    UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"上传失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] autorelease];
                    [alert show];
                }
                else{
                    popView.hidden = false;
                    btnSend.enabled = false;
                    cancelBtn.hidden = false;
                    [progressView setProgress:0.0f];
                    progressLabel.text = @"正在上传录音...";
                }
            }
            KS_BLOCK_ASYNRUN(1000);
        }
        else {
            popView.hidden=true;
            btnSend.enabled=true;
            progressLabel.text = @"保存失败";
        }
    }
}
#pragma mark
#pragma mark observer for upload
- (void)IMyOpusObserver_UploadProgress:(unsigned)idx :(CRecoSongInfo*)pSong :(unsigned)percent
{
    if (progressView) {
        [progressView setProgress:percent*1.0/100];
    }
}

- (void)IMyOpusObserver_FinishUploadOne:(unsigned)idx :(CRecoSongInfo*)pSong :(CMyOpusData::SEND_RESULT)sendRes
{
    _shareSongInfo->strKid=pSong->strKid;
    if(sendRes == CMyOpusData::SEND_SUCCESS)
    {
        progressLabel.text = @"上传成功";
        [self generateShareURL:[NSString stringWithUTF8String:pSong->strKid.c_str()]];
        KS_BLOCK_DECLARE
        {
            progressLabel.text = @"正在分享录音...";
            popView.hidden = false;
            [self ShareThread];
        }
        KS_BLOCK_ASYNRUN(1000);
    }
    else if (sendRes == CMyOpusData::SEND_BEYOND_LIMIT){
        popView.hidden = true;
        btnSend.enabled=true;
        UIAlertView *alert = [[[UIAlertView alloc]initWithTitle:@"提示" message:@"上传达到最大限制" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil]autorelease];
        [alert show];
    }
    else if (sendRes == CMyOpusData::SEND_TIMEOUT){
        popView.hidden = true;
        btnSend.enabled=true;
        UIAlertView *alert = [[[UIAlertView alloc]initWithTitle:@"提示" message:@"取消成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil]autorelease];
        [alert show];
    }
    else {
        popView.hidden = true;
        btnSend.enabled=true;
        UIAlertView *alert = [[[UIAlertView alloc]initWithTitle:@"提示" message:@"上传失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil]autorelease];
        [alert show];
    }
}
#pragma mark viewController methods
- (void)viewDidUnload
{
    [super viewDidUnload];
    _shareText=nil;
    _shareURL=nil;
    // Release any retained subviews of the main view.
}
-(void)dealloc
{
    [_shareURL release];
    [_shareText release];
    [super dealloc];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
