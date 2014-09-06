//
//  KSAdjustSoundView.m
//  KwSing
//
//  Created by 单 永杰 on 12-12-12.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSAdjustSoundView.h"
#import <QuartzCore/QuartzCore.h>
#include "globalm.h"
#include "ImageMgr.h"
#import "AudioHelper.h"
#include "MessageManager.h"
#import "KwConfig.h"
#import "KwConfigElements.h"
#include "RecordTask.h"

#define NORMALIZE(x) ((x)/2)

@interface KSAdjustSoundView (){
    UIView* m_pMainView;
    
    UILabel* m_pAccompanyLabel;
    UISlider* m_pAccompanyVolumeSlider;
    
    UILabel* m_pSingLabel;
    UISlider* m_pSingVolumeSlider;
    
    UIImageView* m_pAlertView;
    UILabel* m_pAlertLabel;
    
    UIButton* m_pOrigionEchoBtn;
    UIButton* m_pKtvEchoBtn;
    UIButton* m_pHallEchoBtn;
    UIButton* m_pTheatreEchoBtn;
    UIButton* m_pSquareEchoBtn;
    
    CGRect m_rectMainView;
}

@end

@implementation KSAdjustSoundView

@synthesize accompanyVolume=m_nAccompanyVolume, singVolume=m_nSingVolume, echoType=m_nEchoType, mediaRecord=m_pMediaRecord, delegate;

- (void)dealloc{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
    if (m_pAlertLabel) {
        [m_pAlertLabel release];
        m_pAlertLabel = nil;
    }
    
    if (m_pMainView) {
        [m_pMainView release];
        m_pMainView = nil;
    }
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_pMediaRecord = NULL;
        KwConfig::GetConfigureInstance()->GetConfigIntValue(AUDIO_EFFECT_GROUP, VOLUME_SING, m_nSingVolume, 1.0);
        KwConfig::GetConfigureInstance()->GetConfigIntValue(AUDIO_EFFECT_GROUP, VOLUME_ACCOMPANY, m_nAccompanyVolume, 1.0);
        KwConfig::GetConfigureInstance()->GetConfigIntValue(AUDIO_EFFECT_GROUP, ECHO_TYPE, m_nEchoType, 1);
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame Media:(CMediaRecord*)p_media{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_pMediaRecord = p_media;
        KwConfig::GetConfigureInstance()->GetConfigIntValue(AUDIO_EFFECT_GROUP, VOLUME_SING, m_nSingVolume, 100);
        KwConfig::GetConfigureInstance()->GetConfigIntValue(AUDIO_EFFECT_GROUP, VOLUME_ACCOMPANY, m_nAccompanyVolume, 100);
        KwConfig::GetConfigureInstance()->GetConfigIntValue(AUDIO_EFFECT_GROUP, ECHO_TYPE, m_nEchoType, 1);
        
        UIImage* p_frame_image = CImageMgr::GetImageEx("SingEffectFrame");
//        NSLog(@"width = %f height = %f", NORMALIZE(p_frame_image.size.width), NORMALIZE(p_frame_image.size.height));
        m_rectMainView = CGRectMake(22.5, 71, (p_frame_image.size.width), (p_frame_image.size.height));
        UIView * mainview = [[[UIView alloc]initWithFrame:m_rectMainView] autorelease];
        UIImageView* p_background_view = [[[UIImageView alloc] initWithImage:p_frame_image] autorelease];
        [p_background_view setFrame:CGRectMake(0, 0, (p_frame_image.size.width), (p_frame_image.size.height))];
        [mainview addSubview:p_background_view];
        
        m_pMainView = [mainview retain];
        
        m_pAccompanyLabel = [[[UILabel alloc] initWithFrame:CGRectMake(18, 28, NORMALIZE(121), NORMALIZE(41))] autorelease];
        m_pAccompanyLabel.backgroundColor = [UIColor clearColor];
        m_pAccompanyLabel.text = @"伴   奏 :";
        [m_pAccompanyLabel setTextAlignment:NSTextAlignmentRight];
        m_pAccompanyLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        m_pAccompanyLabel.textColor = [UIColor blackColor];
        [mainview addSubview:m_pAccompanyLabel];
        
        UIImage * p_left_image = CImageMgr::GetImageEx("playSliderMin_6.png");
        UIImage* p_right_image = CImageMgr::GetImageEx("playSliderMax_6.png");
        m_pAccompanyVolumeSlider = [[[UISlider alloc] initWithFrame:CGRectMake(NORMALIZE(188), NORMALIZE(55), NORMALIZE(330), NORMALIZE(p_left_image.size.height))] autorelease];
        [m_pAccompanyVolumeSlider setMinimumTrackImage:p_left_image forState:UIControlStateNormal];
        [m_pAccompanyVolumeSlider setMaximumTrackImage:p_right_image forState:UIControlStateNormal];
        [mainview addSubview:m_pAccompanyVolumeSlider];
        [m_pAccompanyVolumeSlider addTarget:self action:@selector(endSeekAccompanyVolume:) forControlEvents:UIControlEventTouchUpInside];
        
        m_pSingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(18, 59, NORMALIZE(121), NORMALIZE(41))] autorelease];
        m_pSingLabel.backgroundColor = [UIColor clearColor];
        m_pSingLabel.text = @"麦克风 :";
        [m_pSingLabel setTextAlignment:NSTextAlignmentRight];
        m_pSingLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        m_pSingLabel.textColor = [UIColor blackColor];
        [mainview addSubview:m_pSingLabel];
        
        m_pSingVolumeSlider = [[[UISlider alloc] initWithFrame:CGRectMake(NORMALIZE(188), NORMALIZE(108 + p_left_image.size.height), NORMALIZE(330), NORMALIZE(p_left_image.size.height))] autorelease];
        [m_pSingVolumeSlider setMinimumTrackImage:p_left_image forState:UIControlStateNormal];
        [m_pSingVolumeSlider setMaximumTrackImage:p_right_image forState:UIControlStateNormal];
        [mainview addSubview:m_pSingVolumeSlider];
        [m_pSingVolumeSlider addTarget:self action:@selector(endSeekSingVolume:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage * p_down_image = CImageMgr::GetImageEx("EchoEffectDown.png");
        UIImage * p_up_image = CImageMgr::GetImageEx("EchoEffectUp.png");
        UIColor* p_btn_color = UIColorFromRGB(11, 108, 157);
        
        m_pOrigionEchoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        m_pOrigionEchoBtn.frame = CGRectMake(NORMALIZE(18), NORMALIZE(195), NORMALIZE(p_down_image.size.width), NORMALIZE(p_down_image.size.height));
        [m_pOrigionEchoBtn setTag:1];
        m_pOrigionEchoBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [m_pOrigionEchoBtn setTitleColor:p_btn_color forState:UIControlStateNormal];
        [m_pOrigionEchoBtn setBackgroundImage:p_up_image forState:UIControlStateNormal];
        [m_pOrigionEchoBtn setBackgroundImage:p_down_image forState:UIControlStateSelected];
        [m_pOrigionEchoBtn addTarget:self action:@selector(echoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [m_pOrigionEchoBtn setTitle:@"原声" forState:UIControlStateNormal];
        [mainview addSubview:m_pOrigionEchoBtn];
        
        m_pKtvEchoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        m_pKtvEchoBtn.frame = CGRectMake(NORMALIZE(29 + p_down_image.size.width), NORMALIZE(195), NORMALIZE(p_down_image.size.width), NORMALIZE(p_down_image.size.height));
        [m_pKtvEchoBtn setTag:2];
        m_pKtvEchoBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [m_pKtvEchoBtn setTitleColor:p_btn_color forState:UIControlStateNormal];
        [m_pKtvEchoBtn setBackgroundImage:p_up_image forState:UIControlStateNormal];
        [m_pKtvEchoBtn setBackgroundImage:p_down_image forState:UIControlStateSelected];
        [m_pKtvEchoBtn addTarget:self action:@selector(echoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [m_pKtvEchoBtn setTitle:@"KTV" forState:UIControlStateNormal];
        [mainview addSubview:m_pKtvEchoBtn];
        
        m_pHallEchoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        m_pHallEchoBtn.frame = CGRectMake(NORMALIZE(40 + 2 * p_down_image.size.width), NORMALIZE(195), NORMALIZE(p_down_image.size.width), NORMALIZE(p_down_image.size.height));
        [m_pHallEchoBtn setTag:3];
        m_pHallEchoBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [m_pHallEchoBtn setTitleColor:p_btn_color forState:UIControlStateNormal];
        [m_pHallEchoBtn setBackgroundImage:p_up_image forState:UIControlStateNormal];
        [m_pHallEchoBtn setBackgroundImage:p_down_image forState:UIControlStateSelected];
        [m_pHallEchoBtn addTarget:self action:@selector(echoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [m_pHallEchoBtn setTitle:@"大厅" forState:UIControlStateNormal];
        [mainview addSubview:m_pHallEchoBtn];
        
        m_pTheatreEchoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        m_pTheatreEchoBtn.frame = CGRectMake(NORMALIZE(51 + 3 * p_down_image.size.width), NORMALIZE(195), NORMALIZE(p_down_image.size.width), NORMALIZE(p_down_image.size.height));
        [m_pTheatreEchoBtn setTag:4];
        m_pTheatreEchoBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [m_pTheatreEchoBtn setTitleColor:p_btn_color forState:UIControlStateNormal];
        [m_pTheatreEchoBtn setBackgroundImage:p_up_image forState:UIControlStateNormal];
        [m_pTheatreEchoBtn setBackgroundImage:p_down_image forState:UIControlStateSelected];
        [m_pTheatreEchoBtn addTarget:self action:@selector(echoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [m_pTheatreEchoBtn setTitle:@"剧场" forState:UIControlStateNormal];
        [mainview addSubview:m_pTheatreEchoBtn];
        
        m_pSquareEchoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        m_pSquareEchoBtn.frame = CGRectMake(NORMALIZE(62 + 4 * p_down_image.size.width), NORMALIZE(195), NORMALIZE(p_down_image.size.width), NORMALIZE(p_down_image.size.height));
        [m_pSquareEchoBtn setTag:5];
        m_pSquareEchoBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [m_pSquareEchoBtn setTitleColor:p_btn_color forState:UIControlStateNormal];
        [m_pSquareEchoBtn setBackgroundImage:p_up_image forState:UIControlStateNormal];
        [m_pSquareEchoBtn setBackgroundImage:p_down_image forState:UIControlStateSelected];
        [m_pSquareEchoBtn addTarget:self action:@selector(echoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [m_pSquareEchoBtn setTitle:@"广场" forState:UIControlStateNormal];
        [mainview addSubview:m_pSquareEchoBtn];
        
        
        UIImage* p_alert_image = CImageMgr::GetImageEx("SingEffectAlert.png");
        m_pAlertView = [[[UIImageView alloc] initWithImage:p_alert_image] autorelease];
        [m_pAlertView setFrame:CGRectMake(0, 0, NORMALIZE(p_alert_image.size.width), NORMALIZE(p_alert_image.size.height))];
        
        m_pAlertLabel = [[UILabel alloc] initWithFrame:CGRectMake(NORMALIZE(18), NORMALIZE(191), NORMALIZE(p_alert_image.size.width), NORMALIZE(p_alert_image.size.height))];
        [m_pAlertLabel addSubview:m_pAlertView];
        
        UILabel* p_sub_label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, NORMALIZE(p_alert_image.size.width), NORMALIZE(p_alert_image.size.height))] autorelease];
        p_sub_label.backgroundColor = [UIColor clearColor];
        
        p_sub_label.text = @"插入耳机开启混音";
        p_sub_label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        [p_sub_label setTextAlignment:NSTextAlignmentCenter];
        p_sub_label.textColor = [UIColor blackColor];
        [m_pAlertLabel addSubview:p_sub_label];
        
        if (![[AudioHelper getInstance] hasHeadset]) {
            [mainview addSubview:m_pAlertLabel];
            [m_pOrigionEchoBtn setEnabled:NO];
            [m_pKtvEchoBtn setEnabled:NO];
            [m_pHallEchoBtn setEnabled:NO];
            [m_pTheatreEchoBtn setEnabled:NO];
            [m_pSquareEchoBtn setEnabled:NO];
            [m_pSingVolumeSlider setEnabled:NO];
        }
        
        CGRect rect_screen = [UIScreen mainScreen].bounds;
        UIView* p_view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, rect_screen.size.width, rect_screen.size.height - 20)] autorelease];
        p_view.backgroundColor = UIColorFromRGBAValue(0xffffff, 0);
        
        [p_view addSubview:mainview];
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:p_view];
    }
    
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_APP,IObserverApp);
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (m_pAccompanyVolumeSlider) {
        [m_pAccompanyVolumeSlider setValue:m_nAccompanyVolume / (float)100];
    }
    
    if (m_pMediaRecord->IsFreeSing()) {
        [m_pAccompanyVolumeSlider setValue:1.0];
        [m_pAccompanyVolumeSlider setEnabled:NO];
    }
    
    if (m_pSingVolumeSlider) {
        [m_pSingVolumeSlider setValue:m_nSingVolume / (float)100];
    }
    
    switch (m_nEchoType) {
        case 0:
        {
            [m_pOrigionEchoBtn setSelected:YES];
            [m_pKtvEchoBtn setSelected:NO];
            [m_pHallEchoBtn setSelected:NO];
            [m_pTheatreEchoBtn setSelected:NO];
            [m_pSquareEchoBtn setSelected:NO];
            break;
        }
        case 1:
        {
            [m_pOrigionEchoBtn setSelected:NO];
            [m_pKtvEchoBtn setSelected:YES];
            [m_pHallEchoBtn setSelected:NO];
            [m_pTheatreEchoBtn setSelected:NO];
            [m_pSquareEchoBtn setSelected:NO];
            break;
        }
        case 2:
        {
            [m_pOrigionEchoBtn setSelected:NO];
            [m_pKtvEchoBtn setSelected:NO];
            [m_pHallEchoBtn setSelected:YES];
            [m_pTheatreEchoBtn setSelected:NO];
            [m_pSquareEchoBtn setSelected:NO];
            break;
        }
        case 3:
        {
            [m_pOrigionEchoBtn setSelected:NO];
            [m_pKtvEchoBtn setSelected:NO];
            [m_pHallEchoBtn setSelected:NO];
            [m_pTheatreEchoBtn setSelected:YES];
            [m_pSquareEchoBtn setSelected:NO];
            break;
        }
        case 4:
        {
            [m_pOrigionEchoBtn setSelected:NO];
            [m_pKtvEchoBtn setSelected:NO];
            [m_pHallEchoBtn setSelected:NO];
            [m_pTheatreEchoBtn setSelected:NO];
            [m_pSquareEchoBtn setSelected:YES];
            break;
        }
            
        default:
            break;
    }
}

-(void)endSeekAccompanyVolume : (id)sender{
    m_nAccompanyVolume = [m_pAccompanyVolumeSlider value] * 100;
    if (m_pMediaRecord && RECORD_STATUS_RECORDING == m_pMediaRecord->GetRecordStatus()) {
        m_pMediaRecord->SetAccompanyVolume(m_nAccompanyVolume / (float)100);
    }
    CRecordTask::GetInstance()->SetAccompanyVolume(m_nAccompanyVolume / (float)100);
}

-(void)endSeekSingVolume : (id)sender{
    m_nSingVolume = [m_pSingVolumeSlider value] * 100;
    if (m_pMediaRecord && RECORD_STATUS_RECORDING == m_pMediaRecord->GetRecordStatus()) {
        m_pMediaRecord->SetSingVolume(m_nSingVolume / (float)100);
    }
    CRecordTask::GetInstance()->SetSingVolume(m_nSingVolume / (float)100);
}

-(void) echoBtnClick : (id)sender{
    if ([((UIButton*)sender) isSelected]) {
        return;
    }
    
    switch (((UIButton*)sender).tag) {
        case 1:
        {
            m_nEchoType = NO_EFFECT;
            [m_pOrigionEchoBtn setSelected:YES];
            [m_pKtvEchoBtn setSelected:NO];
            [m_pHallEchoBtn setSelected:NO];
            [m_pTheatreEchoBtn setSelected:NO];
            [m_pSquareEchoBtn setSelected:NO];
            break;
        }
        case 2:
        {
            m_nEchoType = SMALL_ROOM_EFFECT;
            [m_pOrigionEchoBtn setSelected:NO];
            [m_pKtvEchoBtn setSelected:YES];
            [m_pHallEchoBtn setSelected:NO];
            [m_pTheatreEchoBtn setSelected:NO];
            [m_pSquareEchoBtn setSelected:NO];
            break;
        }
        case 3:
        {
            m_nEchoType = MID_ROOM_EFFECT;
            [m_pOrigionEchoBtn setSelected:NO];
            [m_pKtvEchoBtn setSelected:NO];
            [m_pHallEchoBtn setSelected:YES];
            [m_pTheatreEchoBtn setSelected:NO];
            [m_pSquareEchoBtn setSelected:NO];
            break;
        }
        case 4:
        {
            m_nEchoType = BIG_ROOM_EFFECT;
            [m_pOrigionEchoBtn setSelected:NO];
            [m_pKtvEchoBtn setSelected:NO];
            [m_pHallEchoBtn setSelected:NO];
            [m_pTheatreEchoBtn setSelected:YES];
            [m_pSquareEchoBtn setSelected:NO];
            break;
        }
        case 5:
        {
            m_nEchoType = BIG_HALL_EFFECT;
            [m_pOrigionEchoBtn setSelected:NO];
            [m_pKtvEchoBtn setSelected:NO];
            [m_pHallEchoBtn setSelected:NO];
            [m_pTheatreEchoBtn setSelected:NO];
            [m_pSquareEchoBtn setSelected:YES];
            break;
        }
            
        default:
            break;
    }
    if (m_pMediaRecord) {
        m_pMediaRecord->SetEchoType((EAudioEchoEffect)m_nEchoType);
    }
    CRecordTask::GetInstance()->SetEchoType((EAudioEchoEffect)m_nEchoType);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSArray* p_touches = [touches allObjects];
    int n_obj_num = [touches count];
    for (int n_index = 0; n_index < n_obj_num; ++n_index) {
        UITouch* p_cur_touch = (UITouch*)p_touches[n_index];
        if (CGRectContainsPoint(m_rectMainView, [p_cur_touch locationInView : self])) {
            continue;
        }else {
            self.hidden = YES;
            if (nil != delegate) {
                [delegate showHidedControl];
            }
            
            return;
        }
    }
}

-(void)IObserverApp_HeadsetStatusChanged:(BOOL)bHasHeadset{
    if (bHasHeadset) {
        [m_pOrigionEchoBtn setEnabled:YES];
        [m_pKtvEchoBtn setEnabled:YES];
        [m_pHallEchoBtn setEnabled:YES];
        [m_pTheatreEchoBtn setEnabled:YES];
        [m_pSquareEchoBtn setEnabled:YES];
        [m_pSingVolumeSlider setEnabled:YES];
        [m_pAlertLabel removeFromSuperview];
    }else {
        [m_pOrigionEchoBtn setEnabled:NO];
        [m_pKtvEchoBtn setEnabled:NO];
        [m_pHallEchoBtn setEnabled:NO];
        [m_pTheatreEchoBtn setEnabled:NO];
        [m_pSquareEchoBtn setEnabled:NO];
        [m_pSingVolumeSlider setEnabled:NO];
        [m_pMainView addSubview:m_pAlertLabel];
    }
}

@end
