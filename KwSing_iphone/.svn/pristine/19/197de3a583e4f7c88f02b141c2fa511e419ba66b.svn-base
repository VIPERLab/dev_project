//
//  KSKSongViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-8-9.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSongViewController.h"
#include "KSAppDelegate.h"
#include "ImageMgr.h"
#include "KSongLyricView.h"
#include "KSLineLyricView.h"
#include "playPicturesView.h"
#include "globalm.h"
#include "SongInfo.h"
#include "OriginSongView.h"
#include "FrequencyDrawView.h"
#include "KwTools.h"
#include "MessageManager.h"
#include "KFinishViewController.h"
#include "log.h"
#include "LocalMusicRequest.h"
#include "MediaModelFactory.h"
#include "MobClick.h"
#include "KuwoLog.h"
#include "KSAdjustSoundView.h"
#include "KSUIControlShowDelegate.h"
#include "UMengLog.h"
#include "KwUMengElement.h"
#include "RecordTask.h"
#import "HttpRequest.h"

#define REFRESH_CONTORL_INTERVAL    1 

#define HEIHGT_LYRICVIEW            80
//#define FEED_BACK_URL               @"http://60.28.205.41/kge/mobile/KgeRidException?rid="
#define FEED_BACK_URL                 @"http://changba.kuwo.cn/kge/mobile/KgeRidException?"
@interface KSKSongViewController ()<IAudioStateObserver,UIActionSheetDelegate,UIAlertViewDelegate,IObserverApp,KSUIControlShowDelegate>
{
    std::string m_strSongRid;
    UIButton* btnplay;
    UIButton* btnpause;
    UIView *  vedioView;
    UILabel* labmsg;
    UIButton * OriginBtn;
    NSTimer *timer;
    
    UIActionSheet *menu;
    
    UIView *lyricView;
    playPicturesView * picView;
    KSFrequencyDrawView* pFreqView;
    UIProgressView * progressView;
    
    std::string strRecordId;
    bool  bRecord;  //是回放或录音
    bool  bVideo;   //是否是视频
    
    CMediaRecord * m_mediaRecord;
    CMediaReplay * m_mediaReplay;
    CLyricInfo * m_pLyricInfo;
   
    NSTimeInterval m_tLastClickPauseContinueBtnTime;
    
    KSWebView *m_EmigratedWebView;
}
-(void)onRefreshControl;
-(void)feedBack;
@end

@implementation KSKSongViewController

-(void)SetEmigrated: (bool)bEmigrated : (KSWebView*)emiWebView
{
    m_EmigratedWebView = emiWebView;
}

-(void)SetRecordId:(std::string) rid Record:(bool)brecord Video:(bool)bvedio
{
    strRecordId = rid;
    bRecord = brecord;
    bVideo = bvedio;
}

- (void)dealloc
{
    if (m_pLyricInfo) {
        delete m_pLyricInfo;
        m_pLyricInfo = NULL;
    }
    if(m_mediaRecord)
        CMediaModelFactory::GetInstance()->ReleaseMediaRecord();
    m_mediaRecord = NULL;
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
    [super dealloc];
}

const int Tag_AdjustSoundView = 100;
const int Tag_EffectBtn = 101;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        [[self view] setFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height-20)];
    }
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_AUDIOSTATUS,IAudioStateObserver);
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
    
    CGRect rcpic = [[self view]bounds];
    rcpic.size.height = 320;
    
    CRecordTask::GetInstance()->m_bIsAccompany = true;
    
    vedioView = [[[UIView alloc]initWithFrame:rcpic]autorelease];
    [[self view] addSubview:vedioView];
    
    if (CRecordTask::GetInstance()->m_bIsHrbActivity) {
        NSLog(@"is activity");
        picView = nil;
        UIImageView *hrbBkImage = [[[UIImageView alloc] initWithFrame:rcpic] autorelease];
        [hrbBkImage setImage:CImageMgr::GetImageEx("HrbBkImage.jpg")];
        [[self view] addSubview:hrbBkImage];
    }
    else{
        picView = [[[playPicturesView alloc] initWithFrame:rcpic]autorelease];
        [[self view] addSubview:picView];
        [self InitPicShow];
    }
    
    if(!bVideo)
        [vedioView setHidden:true];
    else {
        [picView setHidden:true];
    }
    

    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:CImageMgr::GetImageEx("KSongCloseNormal.png") forState:UIControlStateNormal];
    [btn setBackgroundImage:CImageMgr::GetImageEx("KSongCloseDown.png") forState:UIControlStateHighlighted];
    btn.frame = CGRectMake(self.view.bounds.size.width-44, 10, 34,34);
    [btn addTarget:self action:@selector(ReturnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:btn];
    
    CSongInfoBase * songinfo = NULL;
    if(strRecordId != "")   //清唱
    {
        songinfo = CLocalMusicRequest::GetInstance()->GetLocalMusic(strRecordId);
    }
    
    UILabel* lable = [[[UILabel alloc]initWithFrame:CGRectMake(10, 13, self.view.bounds.size.width-54,17)] autorelease];
    lable.textAlignment = UITextAlignmentLeft;
    lable.backgroundColor = [UIColor clearColor];
    lable.textColor = [UIColor whiteColor];
    lable.font = [UIFont systemFontOfSize:18];
    [lable setShadowOffset:CGSizeMake(1, 1)];
    [lable setShadowColor:[UIColor grayColor]];
    if(songinfo)
    {
        std::string strinfo = songinfo->strSongName + "-" + songinfo->strArtist.c_str();
        lable.text = [NSString stringWithUTF8String:strinfo.c_str()];
    }
    else {
        lable.text = @"自由清唱";
    }

    [[self view] addSubview:lable];
    
    UIImage * tipimg = CImageMgr::GetImageEx("tipRecording.png");
    UIImageView * imageview = [[[UIImageView alloc]initWithFrame:CGRectMake(12, 43, tipimg.size.width, tipimg.size.height)] autorelease];
    imageview.image = tipimg;
    [self.view addSubview:imageview];
    
    labmsg = [[[UILabel alloc]initWithFrame:CGRectMake(29, 41, self.view.bounds.size.width-54,14)] autorelease];
    labmsg.textAlignment = UITextAlignmentLeft;
    labmsg.backgroundColor = [UIColor clearColor];
    labmsg.font = [UIFont systemFontOfSize:14];
    [labmsg setShadowOffset:CGSizeMake(1, 1)];
    [labmsg setShadowColor:[UIColor grayColor]];
    labmsg.textColor = [UIColor whiteColor];
    [[self view] addSubview:labmsg];
    
    
    UIImageView * bottombkView = [[[UIImageView alloc]init]autorelease];
    CGRect rcbkbottom = BottomRect([[self view]bounds],self.view.bounds.size.height-320,0);
    [bottombkView setFrame:rcbkbottom];
    //[bottombkView setImage:CImageMgr::GetImageEx("bottomKSongBK.png")];
    bottombkView.backgroundColor = UIColorFromRGBValue(0xededed);
    [[self view] addSubview:bottombkView];
    
    CGRect rcfreq = BottomRect([[self view]bounds], FREQUENCY_VIEW_HEIGHT, 49);
    
    if(songinfo)
    {
        std::string strpath = [self GetLyricPath:songinfo->strRid];
        if(m_pLyricInfo == NULL)
            m_pLyricInfo = new CLyricInfo;
        m_pLyricInfo->ReadFromFile(strpath);
        CGRect rclyric = BottomRect(rcpic, HEIHGT_LYRICVIEW , 0);
        if ((LYRIC_CLASSIC == m_pLyricInfo->GetLyricType()) || (LYRIC_LRCX == m_pLyricInfo->GetLyricType())) {
            lyricView = [[[KSLineLyricView alloc] initWithFrame:rclyric] autorelease];
        }else if (LYRIC_KDTX){
            lyricView = [[[KSongLyricView alloc]initWithFrame:rclyric]autorelease];
        }else {
            lyricView = nil;
        }
        [[self view]addSubview:lyricView];
        
        pFreqView=[[KSFrequencyDrawView alloc] initWithFrame:rcfreq];
        [self.view addSubview:pFreqView];
        [pFreqView release];
        
    }
    else  //清唱
    {
        UIImageView * bottombkView = [[[UIImageView alloc]init]autorelease];
        CGRect rcbkbottom = BottomRect([[self view]bounds],140, 0);
        [bottombkView setFrame:rcbkbottom];
        bottombkView.backgroundColor = UIColorFromRGBValue(0xededed);
        //[bottombkView setImage:CImageMgr::GetImageEx("bottomKSongBK.png")];
        [[self view] addSubview:bottombkView];
        
        int gapLabel=0;
        int gapProgress=0;
        if (IsIphone5()) {
            gapLabel=-50;
            gapProgress=-20;
        }
        if(bRecord)
        {
            UILabel * lab1 = [[[UILabel alloc]initWithFrame:CGRectMake(12, rcbkbottom.origin.y+14+gapLabel, 250,14)] autorelease];
            lab1.textAlignment = UITextAlignmentLeft;
            lab1.backgroundColor = [UIColor clearColor];
            lab1.font = [UIFont systemFontOfSize:14];
            lab1.text = @"你现在可以录制5分钟的音频啦！";
            [[self view] addSubview:lab1];
         }   
            progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(12, rcbkbottom.origin.y+50+gapProgress, 280, 10)];
            [[self view] addSubview:progressView];
            [progressView setProgress:0];
        

    }
    
    CGRect rcbottom = [[self view]bounds];
    rcbottom = BottomRect(rcbottom,49,0);
    UIImageView * imagebottomView = [[[UIImageView alloc]init]autorelease];
    [imagebottomView setFrame:rcbottom];
    [imagebottomView setImage:CImageMgr::GetImageEx("recordbottombk.png")];
    [[self view] addSubview:imagebottomView];

    UIImage * imgplay = CImageMgr::GetImageEx("playBtn.png");
    btnplay = [UIButton buttonWithType:UIButtonTypeCustom];
    btnplay.frame = CGRectMake(rcbottom.origin.x + 90, rcbottom.origin.y+8 , imgplay.size.width ,imgplay.size.height);
    [btnplay setTag:1];
    [btnplay setImage:imgplay forState:UIControlStateNormal];
    [btnplay setBackgroundImage:CImageMgr::GetImageEx("controlBtnDown.png") forState:UIControlStateHighlighted];
    [btnplay addTarget:self action:@selector(ControlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:btnplay];
    [btnplay setHidden:true];

    UIImage * imgpause = CImageMgr::GetImageEx("pauseBtn.png");
    btnpause = [UIButton buttonWithType:UIButtonTypeCustom];
    btnpause.frame = CGRectMake(rcbottom.origin.x +90, rcbottom.origin.y+8 , imgpause.size.width,imgpause.size.height);
    [btnpause setTag:2];
    [btnpause setImage:imgpause forState:UIControlStateNormal];
    [btnpause setBackgroundImage:CImageMgr::GetImageEx("controlBtnDown.png") forState:UIControlStateHighlighted];
    [btnpause addTarget:self action:@selector(ControlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:btnpause];

    UIImage * downimage = CImageMgr::GetImageEx("operateBtnDown.png");
    if(bRecord)
    {
        UIButton* moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.frame = CGRectMake(rcbottom.size.width - 7 - downimage.size.width, rcbottom.origin.y + 8, downimage.size.width,downimage.size.height);
        [moreBtn setImage:CImageMgr::GetImageEx("moreBtn.png") forState:UIControlStateNormal];
        [moreBtn setImage:CImageMgr::GetImageEx("moreBtnDown.png") forState:UIControlStateHighlighted];
        moreBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [moreBtn addTarget:self action:@selector(MoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:moreBtn];
        if (CRecordTask::GetInstance()->m_bIsHrbActivity) {
            [moreBtn setEnabled:false];
        }
    }

    if(strRecordId != "" && bRecord)
    {
        OriginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [OriginBtn setFrame:CGRectMake(rcbottom.origin.x+7, rcbottom.origin.y+8, imgplay.size.width,imgplay.size.height)];
        [OriginBtn setImage:CImageMgr::GetImageEx("OriginBtn.png") forState:UIControlStateNormal];

        OriginBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [OriginBtn addTarget:self action:@selector(SongBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:OriginBtn];  
    }
    
    if(!CRecordTask::GetInstance()->m_bIsAccompany)
        [OriginBtn setImage:CImageMgr::GetImageEx("AcompanyBtn.png") forState:UIControlStateNormal];
    else
        [OriginBtn setImage:CImageMgr::GetImageEx("OriginBtn.png") forState:UIControlStateNormal];
    
    UIButton* btnstop = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * imgstop = CImageMgr::GetImageEx("finishBtn.png");
    btnstop.frame=CGRectMake(rcbottom.origin.x + 166, rcbottom.origin.y + 8, imgstop.size.width ,imgstop.size.height);
    [btnstop setTag:3];
    btnstop.titleLabel.font = [UIFont systemFontOfSize:16];
    [btnstop setImage:imgstop forState:UIControlStateNormal];
    [btnstop setBackgroundImage:downimage forState:UIControlStateHighlighted];
    [btnstop addTarget:self action:@selector(ControlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnstop setTitle:@"完成" forState:UIControlStateNormal];
    [[self view] addSubview:btnstop];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_CONTORL_INTERVAL target:self selector:@selector(onRefreshControl) userInfo:nil repeats:YES];
    
    c_KuwoDebugLog("KSONG",DEBUG_LOG,"InitPlaySong");
    if(bRecord)
        [self InitRecord];
    else {
        [self InitReplay];
    }
    c_KuwoDebugLog("KSONG",DEBUG_LOG,"StartPlaySongOver");
    
    if(songinfo)
    {
        switch (m_pLyricInfo->GetLyricType()) {
            case LYRIC_KDTX:
                [(KSongLyricView*)lyricView SetLyricInfo:m_pLyricInfo];
                break;
                
            case LYRIC_LRCX:
                [(KSLineLyricView*)lyricView SetLyricInfo:m_pLyricInfo];
                break;
                
            case LYRIC_CLASSIC:
                [(KSLineLyricView*)lyricView SetLyricInfo:m_pLyricInfo];
                break;
                
            default:
                break;
        }
        
        [pFreqView setLyric:m_pLyricInfo recalculatePoints:bRecord];
        [pFreqView start];
        
    }
    
    if(bRecord)
    {
         UIButton* btneffect = [UIButton buttonWithType:UIButtonTypeCustom];
        [btneffect setBackgroundImage:CImageMgr::GetImageEx("EffectBtn.png") forState:UIControlStateNormal];
        [btneffect setBackgroundImage:CImageMgr::GetImageEx("EffectBtnDown.png") forState:UIControlStateHighlighted];
        btneffect.frame = CGRectMake(274, 135, 46,33);
        btneffect.tag = Tag_EffectBtn;
        [btneffect addTarget:self action:@selector(EffectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:btneffect];
        
        KSAdjustSoundView * adjustview = [[[KSAdjustSoundView alloc]initWithFrame:self.view.bounds Media:m_mediaRecord]autorelease];
        adjustview.tag = Tag_AdjustSoundView;
        adjustview.delegate = self;
        adjustview.hidden = true;
        [self.view addSubview:adjustview];
    }
    
    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}

//- (void)viewWillDisappear:(BOOL)animated{
//    
//}

-(void)stopPlay{
    if (m_mediaRecord) {
        m_mediaRecord->StopRecord();
    }
    
    [timer invalidate];
    timer = NULL;
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_AUDIOSTATUS,IAudioStateObserver);
}

-(void)InitRecord
{
    if(m_mediaRecord)
        CMediaModelFactory::GetInstance()->ReleaseMediaRecord();
    m_mediaRecord = CMediaModelFactory::GetInstance()->CreateMediaRecord(bVideo);
    //m_mediaRecord->SetEchoType(CRecordTask::GetInstance()->GetEchoType());
    if(strRecordId == ""){
        CRecordTask::GetInstance()->Init(NULL);
        //m_mediaRecord->SetEchoType(CRecordTask::GetInstance()->GetEchoType());
        m_mediaRecord->StartRecord(vedioView);
    }
    else {
        CSongInfoBase * songinfo = CLocalMusicRequest::GetInstance()->GetLocalMusic(strRecordId);
        CRecordTask::GetInstance()->Init(songinfo);
        //m_mediaRecord->SetEchoType(CRecordTask::GetInstance()->GetEchoType());
        if(songinfo)
        {
            bool bret = m_mediaRecord->StartRecord(vedioView);
            if(bret)
            {
                RTLog_Play(AR_SUCCESS,songinfo->strSongName.c_str(),songinfo->strArtist.c_str(),songinfo->strRid.c_str(),ACCOMPANY_MUSIC);
                UMengLog(KS_PLAY_MUSIC, "0");
                
                switch (m_pLyricInfo->GetLyricType()) {
                    case LYRIC_KDTX:
                        [(KSongLyricView*)lyricView SetMedia:m_mediaRecord];
                        break;
                        
                    case LYRIC_CLASSIC:
                        [(KSLineLyricView*)lyricView SetMedia:m_mediaRecord];;
                        break;
                        
                    case LYRIC_LRCX:
                        [(KSLineLyricView*)lyricView SetMedia:m_mediaRecord];;
                        break;
                        
                    default:
                        break;
                }

                [pFreqView setMediaInterface:m_mediaRecord];
            }
            else
            {
                RTLog_Play(AR_FAIL,songinfo->strSongName.c_str(),songinfo->strArtist.c_str(),songinfo->strRid.c_str(),ACCOMPANY_MUSIC);
                UMengLog(KS_PLAY_MUSIC, "1");
            }

        }
    }
}

-(void)InitReplay
{
    if(m_mediaReplay)
        CMediaModelFactory::GetInstance()->ReleaseMediaReplay();
    m_mediaReplay = CMediaModelFactory::GetInstance()->CreateMediaReplay(bVideo);
    
    if(strRecordId == "")
    {
        CRecordTask::GetInstance()->Init(NULL);
        bool bret = m_mediaReplay->InitPlayer(vedioView);
        if(!bret)
            return;
        m_mediaReplay->SetAudioEchoEffect(CRecordTask::GetInstance()->GetEchoType());
        m_mediaReplay->StartPlay();
    }
    else {
        CSongInfoBase * songinfo = CLocalMusicRequest::GetInstance()->GetLocalMusic(strRecordId);
        CRecordTask::GetInstance()->Init(songinfo);
        if(songinfo)
        {
            bool bret = m_mediaReplay->InitPlayer(vedioView);
            if(!bret)
                return;
            m_mediaReplay->SetAudioEchoEffect(CRecordTask::GetInstance()->GetEchoType());
            m_mediaReplay->StartPlay();
//            [lyricView SetMedia:m_mediaReplay];
            [pFreqView setMediaInterface:m_mediaReplay];
        }
    }
}

-(std::string) GetLyricPath :(std::string)strid
{
    std::string strpath;
    KwTools::Dir::GetPath(KwTools::Dir::PATH_LYRIC,strpath);
    strpath += "/ac";
    strpath += strid;
    strpath += ".lrc";
    return strpath;
}

-(void)InitPicShow
{
    NSString * strpath = KwTools::Dir::GetPath(KwTools::Dir::PATH_BKIMAGE);
    if(strpath != nil)
    {
        NSError * err = nil;
        NSArray *filearr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:strpath error:&err]; 
        if(err == nil)
        {
            vector<NSString*>vectemp;
            for (NSString * str in filearr){
                str = [strpath stringByAppendingPathComponent:str];
                vectemp.push_back(str);
            }
            [picView setImageList:vectemp];
        }
    }
}

-(void)onRefreshControl
{
    if(bRecord)
    {
        if(m_mediaRecord == NULL)
            return;
        int nCurTime = m_mediaRecord->CurrentTime();
        int nCurMin,nCunSec;
        nCurMin = nCurTime/60000;
        nCunSec = (nCurTime/1000)%60;
        int nDurTime = m_mediaRecord->Duration();
        int nMin,nSecond;
        nMin = nDurTime/60000;
        nSecond = (nDurTime/1000)%60;
        if(m_mediaRecord->GetRecordStatus() == RECORD_STATUS_RECORDING)
        {
            labmsg.text = [NSString stringWithFormat:@"正在录制 %02d:%02d/%02d:%02d",nCurMin,nCunSec,nMin,nSecond];
        }
        else if(m_mediaRecord->GetRecordStatus() == RECORD_STATUS_PAUSED)
        {
            labmsg.text = [NSString stringWithFormat:@"暂停录制 %02d:%02d/%02d:%02d",nCurMin,nCunSec,nMin,nSecond];
        }
        else if(m_mediaRecord->GetRecordStatus() == RECORD_STATUS_STOP){
            labmsg.text = [NSString stringWithFormat:@"停止录制"];
        }
        else if(m_mediaRecord->GetRecordStatus() == RECORD_STATUS_NONE){
            labmsg.text = [NSString stringWithFormat:@"正在准备..."];
        }
        else if(m_mediaRecord->GetRecordStatus() == RECORD_STATUS_ERR)
        {
             labmsg.text = [NSString stringWithFormat:@"录制失败"];
        }
        
        
        if(progressView)
        {
            float fpro = 0;
            if(nDurTime)
                fpro = nCurTime*1.0/nDurTime;
            [progressView setProgress:fpro];
        }

    }
    else {
        if(m_mediaReplay == NULL)
            return;
        int nCurTime = m_mediaReplay->CurrentTime();
        int nCurMin,nCunSec;
        nCurMin = nCurTime/60000;
        nCunSec = (nCurTime/1000)%60;
        int nDurTime = m_mediaReplay->Duration();
        int nMin,nSecond;
        nMin = nDurTime/60000;
        nSecond = (nDurTime/1000)%60;
        if(m_mediaReplay->GetPlayStatus() == PLAY_STATUS_PLAYING)
        {
            labmsg.text = [NSString stringWithFormat:@"正在播放 %02d:%02d/%02d:%02d",nCurMin,nCunSec,nMin,nSecond];
        }
        else if(m_mediaReplay->GetPlayStatus() == PLAY_STATUS_PAUSED)
        {
            labmsg.text = [NSString stringWithFormat:@"暂停播放 %02d:%02d/%02d:%02d",nCurMin,nCunSec,nMin,nSecond];
        }
        else if(m_mediaReplay->GetPlayStatus() == PLAY_STATUS_STOP){
            labmsg.text = [NSString stringWithFormat:@"停止播放"];
        } 
        else if(m_mediaReplay->GetPlayStatus() == PLAY_STATUS_NONE){
            labmsg.text = [NSString stringWithFormat:@"正在准备..."];
        }
        if(progressView)
        {
            float fpro = 0;
            if(nDurTime)
                fpro = nCurTime*1.0/nDurTime;
            [progressView setProgress:fpro];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) ReturnBtnClick:(id)sender
{
    if(bRecord)
    {
        UIAlertView * alertview = [[[UIAlertView alloc]initWithTitle:@"离开将不能保存录音，确定要离开吗？" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil]autorelease];
        [alertview show];
    }
    else {
        GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_AUDIOSTATUS,IAudioStateObserver);
        if(m_mediaReplay)
            m_mediaReplay->Stop();
        [self CloseView];
    }
    [MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"alertView clickedButtonAtIndex");
    if(buttonIndex == 0)
    {
        m_mediaRecord->StopRecord();
        UMengLog(KS_CLOSE_RECORD, "CloseWhenRecord");
        [self CloseView];
    }
}

-(void) ControlBtnClick : (id)sender
{
    if ([NSDate timeIntervalSinceReferenceDate]-m_tLastClickPauseContinueBtnTime<.2) {
        return;
    }
    m_tLastClickPauseContinueBtnTime=[NSDate timeIntervalSinceReferenceDate];
    
    if(((UIButton*)sender).tag == 1)
    {
        if(bRecord)
        {
            if (m_mediaRecord) {
                m_mediaRecord->ResumeRecord();
            }
        }
        else {
            if(m_mediaReplay)
                m_mediaReplay->ContinuePlay();
        }
    }
    else if(((UIButton*)sender).tag == 2)
    {
        if(bRecord)
        {
            if(m_mediaRecord)
                m_mediaRecord->PauseRecord();
        }
        else {
            if(m_mediaReplay)
                m_mediaReplay->PausePlay();
        }
    }
    else if(((UIButton*)sender).tag == 3)
    {
        if(bRecord)
        {
            if(m_mediaRecord)
                m_mediaRecord->StopRecord();
            KFinishViewController * ksongView = [[[KFinishViewController alloc]init]autorelease];
            unsigned point = 0;
            if(strRecordId != "")
                point = [pFreqView getTotalPoint];
            [ksongView SetRecordId:strRecordId Vedio:bVideo Point:point];
            [self CloseView];
            [ROOT_NAVAGATION_CONTROLLER pushViewController:ksongView animated:YES];
        }
        else {
            if(m_mediaReplay)
                m_mediaReplay->Stop();
//            [self CloseView];
        }
    }
}

-(void) MoreBtnClick:(id)sender
{
    //if(m_mediaRecord)
    //    m_mediaRecord->PauseRecord();
    NSString* changeModStr = @"录制视频";
    //todo case audio changeModStr=@"录制视频" case video changeModStr=@"录制音频";
    if (bVideo) {
        changeModStr=@"录制音频";
    }
    if (CRecordTask::GetInstance()->m_bIsFreeSing) {
        menu=[[[UIActionSheet alloc] initWithTitle:@""
                                          delegate:self
                                 cancelButtonTitle:@"取消"
                            destructiveButtonTitle:nil otherButtonTitles:changeModStr, nil] autorelease];
    }
    else{
        menu = [[[UIActionSheet alloc]
                 initWithTitle: @""
                 delegate:self
                 cancelButtonTitle:@"取消"
                 destructiveButtonTitle:nil
                 otherButtonTitles:changeModStr,@"反馈歌曲资源错误",nil] autorelease];

    }
    //menu.destructiveButtonIndex = 2;
    [menu showInView:self.view];
    
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    if (buttonIndex ==  actionSheet.firstOtherButtonIndex) {
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [pFreqView setLyric:m_pLyricInfo recalculatePoints:YES];
            
            if (bVideo) {
                //change to audio
                bVideo=false;
                [vedioView setHidden:true];
                [picView setHidden:false];
            }
            else{
                //change to video
                bVideo=true;
                [vedioView setHidden:false];
                [picView setHidden:true];
            }
            if(m_mediaRecord)
            {
                m_mediaRecord->StopRecord();
            }
            [self InitRecord];
            
            KSAdjustSoundView * adjustview = (KSAdjustSoundView*)[self.view viewWithTag:Tag_AdjustSoundView];
            [adjustview setMediaRecord:m_mediaRecord];
        }
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex+1){
        UIAlertView *alert=[[[UIAlertView alloc] initWithTitle:@"提示" message:@"谢谢您的反馈，我们会尽快处理。" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] autorelease];
        [alert show];
        [self feedBack];
    }
}

-(void)feedBack
{
    if(strRecordId == "")
        return;
    CSongInfoBase * songinfo = NULL;
    songinfo = CLocalMusicRequest::GetInstance()->GetLocalMusic(strRecordId);
    int lyricType=-1;
    if (m_pLyricInfo) {
        lyricType=m_pLyricInfo->GetLyricType();
    }
    NSString * feedBackurl=[NSString stringWithFormat:@"%@rid=%s&lyricType=%d",
                            FEED_BACK_URL,songinfo->strRid.c_str(),
                            lyricType];
    KS_BLOCK_DECLARE
    {
        std::string strRet;
        CHttpRequest::QuickSyncGet([feedBackurl UTF8String], strRet);
//        NSLog(@"feedback:%@,return:%@",feedBackurl,[NSString stringWithFormat:@"%s",strRet.c_str()]);
    }
    KS_BLOCK_RUN_THREAD()
}

-(void) SongBtnClick:(id)sender
{
    m_mediaRecord->SwitchResource();
    if(!CRecordTask::GetInstance()->m_bIsAccompany)
        [OriginBtn setImage:CImageMgr::GetImageEx("AcompanyBtn.png") forState:UIControlStateNormal];
    else
        [OriginBtn setImage:CImageMgr::GetImageEx("OriginBtn.png") forState:UIControlStateNormal];
}

-(void)ShowEffectView
{
    KSAdjustSoundView * adjustview = (KSAdjustSoundView*)[self.view viewWithTag:Tag_AdjustSoundView];
    adjustview.frame = CGRectMake(320, 0, 0, 0);
    CGRect rcend = self.view.frame;
    [UIView animateWithDuration:0.2 animations:^{
        [adjustview setFrame:rcend];
        adjustview.hidden = false;
    } ];

}

-(void)showHidedControl
{
    UIButton * btneffect = (UIButton*)[self.view viewWithTag:Tag_EffectBtn];
    btneffect.hidden = false;
}

-(void) EffectBtnClick:(id)sender
{
    KSAdjustSoundView * adjustview = (KSAdjustSoundView*)[self.view viewWithTag:Tag_AdjustSoundView];
    UMengLog(KS_EFFECT_ADJUST, "EffectAdjust");
    adjustview.hidden = false;
    UIButton * btneffect = (UIButton*)[self.view viewWithTag:Tag_EffectBtn];
    btneffect.hidden = true;
}

-(void)IObserverApp_VolumeControlChanged
{
    KSAdjustSoundView * adjustview = (KSAdjustSoundView*)[self.view viewWithTag:Tag_AdjustSoundView];
    adjustview.hidden = false;
    UIButton * btneffect = (UIButton*)[self.view viewWithTag:Tag_EffectBtn];
    btneffect.hidden = true;
}


-(void)IAudioStateObserver_RecordStatusRecording
{
    [btnpause setHidden:false];
    [btnplay setHidden:true];
    [picView startPlay];
    [self onRefreshControl];
}

-(void)IAudioStateObserver_RecordStatusPaused
{
    [btnpause setHidden:true];
    [btnplay setHidden:false];
    [picView stop];
    [self onRefreshControl];
}

-(void)IAudioStateObserver_RecordStatusFinish
{
    KFinishViewController * ksongView = [[[KFinishViewController alloc]init]autorelease];

    unsigned point = 0;
    if(strRecordId != "")
        point = [pFreqView getTotalPoint];
    [ksongView SetRecordId:strRecordId Vedio:bVideo Point:point];
    [self CloseView];
    [ROOT_NAVAGATION_CONTROLLER pushViewController:ksongView animated:YES];
}

-(void)IAudioStateObserver_RecordStatusErr
{
    [self onRefreshControl];
}

-(void)CloseView
{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_AUDIOSTATUS,IAudioStateObserver);
    
    [timer invalidate];
    timer=NULL;
    
    if (m_pLyricInfo) {
        switch (m_pLyricInfo->GetLyricType()) {
            case LYRIC_CLASSIC:
                [(KSLineLyricView*)lyricView StopRefresh];
                break;
                
            case LYRIC_LRCX:
                [(KSLineLyricView*)lyricView StopRefresh];
                break;
                
            case LYRIC_KDTX:
                [(KSongLyricView*)lyricView StopRefresh];
                break;
                
            default:
                break;
        }
        lyricView=NULL;
    }
    
    [picView stop];
    picView=NULL;
    
    [pFreqView stop];
    pFreqView=NULL;
    
    if(m_mediaRecord)
        CMediaModelFactory::GetInstance()->ReleaseMediaRecord();
    m_mediaRecord = NULL;
    if(m_mediaReplay)
        CMediaModelFactory::GetInstance()->ReleaseMediaReplay();
    m_mediaReplay = NULL;
    [self.navigationController popViewControllerAnimated:NO];
}


@end
