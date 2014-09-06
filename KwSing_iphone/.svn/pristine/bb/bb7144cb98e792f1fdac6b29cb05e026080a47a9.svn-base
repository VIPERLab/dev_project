//
//  OriginSongViewController.m
//  KwSing
//
//  Created by Qian Hu on 12-8-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "OriginSongView.h"
#include "globalm.h"
#include "OnlineAudioPlayer.h"
#include "LocalMusicRequest.h"
#include "ImageMgr.h"
#include "AudioRecord.h"
#include "MediaModelFactory.h"
#include "KuwoLog.h"
#include "UMengLog.h"
#include "KwUMengElement.h"

#define REFRESH_CONTORL_INTERVAL    1 
#define WIDTH_DOWN_PROGRESS              127

@interface OriginSongView ()
{
    std::string strRecordId;
    COrigionSongPlayer * m_origionPlayer;
    NSTimer *timer;
    UISlider *slider;
    UILabel* msg1;
    UILabel* msg2;
    UIImageView *progressview;
    CMediaRecord * m_pmediaRecord;
    bool m_bSeek;   // 是否在seekmedia
}
-(void) ReturnClick:(id)sender;
@end

@implementation OriginSongView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        m_pmediaRecord = NULL;
        strRecordId = "";
        m_bSeek = false;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame Record:(std::string)rid Media:(CMediaRecord*)pmedia
{
    self = [self initWithFrame:frame];
    if (self) {
        strRecordId = rid;
        m_pmediaRecord = pmedia;
        self.backgroundColor = UIColorFromRGBAValue(0x000000,51);
        CGRect rcbk = CGRectMake(42, 123, 230, 155);
        UIImageView * bkimageView = [[[UIImageView alloc]init]autorelease];
        [bkimageView setFrame:rcbk];
        [bkimageView setImage:CImageMgr::GetImageEx("orginKsongbk_20_19.png")];
        [self addSubview:bkimageView];
        
        UIView * mainview = [[[UIView alloc]initWithFrame:rcbk]autorelease];
        [self addSubview:mainview];
        
        UILabel* lable = [[[UILabel alloc]initWithFrame:CGRectMake(17, 15, 100,14)]autorelease];
        lable.backgroundColor = [UIColor clearColor];
        lable.text = @"原唱试听";
        lable.font = [UIFont systemFontOfSize:14];
        lable.textColor = [UIColor blackColor];
        [mainview addSubview:lable];
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"继续K歌" forState: UIControlStateNormal];
        btn.frame = CGRectMake(48, 93, 133,34);
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        [btn setTitleColor:UIColorFromRGBValue(0x1199dd) forState:UIControlStateNormal];
        [btn setBackgroundImage:CImageMgr::GetImageEx("returnKSongBtnNormal_18.png") forState:UIControlStateNormal];
        [btn setBackgroundImage:CImageMgr::GetImageEx("returnKSongBtnDown_18.png") forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(ReturnClick:) forControlEvents:UIControlEventTouchUpInside];
        [mainview addSubview:btn];
        
        msg1 = [[[UILabel alloc]initWithFrame:CGRectMake(17, 55,35,14)]autorelease];
        msg1.backgroundColor = [UIColor clearColor];
        msg1.text = @"00:00";
        msg1.font = [UIFont systemFontOfSize:13];
        msg1.textColor = [UIColor grayColor];
        [mainview addSubview:msg1];
        
        msg2 = [[[UILabel alloc]initWithFrame:CGRectMake(185, 55, 35,14)]autorelease];
        msg2.backgroundColor = [UIColor clearColor];
        msg2.text = @"00:00";
        msg2.font = [UIFont systemFontOfSize:13];
        msg2.textColor = [UIColor grayColor];
        [mainview addSubview:msg2];
        
        progressview = [[[UIImageView alloc]initWithFrame:CGRectMake(52, 59,0, 7)]autorelease];
        progressview.image = CImageMgr::GetImageEx("playProgressDown_6.png");
        [mainview addSubview:progressview];
        
        slider = [[[UISlider alloc]initWithFrame:CGRectMake(50, 51, 132, 15)]autorelease];
        [slider setMaximumTrackImage:CImageMgr::GetImageEx("playSliderMax_6.png") forState:UIControlStateNormal];
        [slider setMinimumTrackImage:CImageMgr::GetImageEx("playSliderMin_6.png") forState:UIControlStateNormal];
        [mainview addSubview:slider];
        //[slider addTarget:self action:@selector(seekMedia:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(seekMedia:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(startSeekMedia:) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(endSeekMedia:) forControlEvents:UIControlEventTouchUpInside];
        
        m_origionPlayer = CMediaModelFactory::GetInstance()->CreateOrigionSongPlayer();
        if(m_origionPlayer && m_origionPlayer->Play(strRecordId))
        {
            RTLog_Play(AR_SUCCESS,"","",strRecordId.c_str(),ORIGINAL_MUSIC);
            UMengLog(KS_PLAY_MUSIC, "0");
        }
        else
        {
            RTLog_Play(AR_FAIL,"","",strRecordId.c_str(),ORIGINAL_MUSIC);
            UMengLog(KS_PLAY_MUSIC, "1");
        }
        
        timer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_CONTORL_INTERVAL target:self selector:@selector(onRefreshControl) userInfo:nil repeats:YES];
    }
    
    return self;
}


-(void) ReturnClick:(id)sender
{
    if (m_origionPlayer) {
        m_origionPlayer->Stop();
        m_origionPlayer=NULL;
    }
    
    CMediaModelFactory::GetInstance()->ReleaseOrigionSongPlayer();
    if(m_pmediaRecord) {
        m_pmediaRecord->ResumeRecord();
        m_pmediaRecord=NULL;
    }
        
    [timer invalidate];
    timer=NULL;
    
    [self removeFromSuperview];

}

-(void)onRefreshControl
{
    int nCurTime = m_origionPlayer->CurrentTime();
    int nDurTime = m_origionPlayer->Duration();
    float fpercent = 0;
    if(nDurTime)
        fpercent = float(nCurTime)/(float)nDurTime;
    if(!m_bSeek)
        [slider setValue:fpercent];

    int nCurMin,nCunSec;
    nCurMin = nCurTime/60000;
    nCunSec = (nCurTime/1000)%60;
    int nMin,nSecond;
    nMin = nDurTime/60000;
    nSecond = (nDurTime/1000)%60;
    if(!m_bSeek)
        msg1.text = [NSString stringWithFormat:@"%02d:%02d",nCurMin,nCunSec];
    msg2.text = [NSString stringWithFormat:@"%02d:%02d",nMin,nSecond];
    
    // 缓冲进度
    CGRect rcpro = progressview.frame;
    float fdown = m_origionPlayer->GetDownloadProgress();
    rcpro.size.width = WIDTH_DOWN_PROGRESS*fdown;
    progressview.frame = rcpro;
}

-(void)startSeekMedia:(id)sender
{
    m_bSeek = true;
}

-(void)endSeekMedia:(id)sender
{
    m_bSeek = false;
    float f = slider.value; //读取滑块的值
    if(m_origionPlayer)
        m_origionPlayer->Seek(f*m_origionPlayer->Duration());
}

-(void)seekMedia:(id)sender
{
    int nDurTime = m_origionPlayer->Duration();
    float f = slider.value;
    int nCurTime = nDurTime * f;
    int nCurMin,nCunSec;
    nCurMin = nCurTime/60000;
    nCunSec = (nCurTime/1000)%60;
    msg1.text = [NSString stringWithFormat:@"%02d:%02d",nCurMin,nCunSec];

}


@end
