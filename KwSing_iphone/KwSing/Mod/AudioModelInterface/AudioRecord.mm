//
//  AudioRecord.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-15.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "AudioRecord.h"
#include "MessageManager.h"
#include "KSRecordTempPath.h"
#include "KwDir.h"
#import "AudioHelper.h"
#include "KuwoLog.h"
#include "AutoLock.h"
#include "KwConfig.h"
#include "KwConfigElements.h"
#include "KwUMengElement.h"
#include "UMengLog.h"
#include "RecordTask.h"

#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioServices.h>
#include "MobClick.h"
#include "KwUMengElement.h"

static KwTools::CLock s_record_lock;

CAudioRecord::CAudioRecord(){
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver);
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
    m_AudioDuration = 0;
    KwTools::Dir::DeleteDir([KSRecordTempPath getRecordTempPath]);
}

CAudioRecord::~CAudioRecord(){
    if (m_pAudioGraph) {
        [m_pAudioGraph release];
        m_pAudioGraph = nil;
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver);
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
}

bool CAudioRecord::StartRecord(UIView* p_view){
    
    if (!CRecordTask::GetInstance()->m_bIsFreeSing && !(KwTools::Dir::IsExistFile(CRecordTask::GetInstance()->m_strOrigionPath) && KwTools::Dir::IsExistFile(CRecordTask::GetInstance()->m_strAccompanyPath))) {
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordErr);
        return false;
    }

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
//    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    
    KS_BLOCK_DECLARE{
        m_pAudioGraph = [[KSAudioGraph alloc] init];
        [m_pAudioGraph initAudioGraph];
        
        if (![[AudioHelper getInstance] hasHeadset]) {
            [m_pAudioGraph setEchoType:NO_EFFECT];
        }
        
        [m_pAudioGraph setAcomVolume:CRecordTask::GetInstance()->GetAccompanyVolume()];
        if ([[AudioHelper getInstance] hasHeadset]) {
            [m_pAudioGraph setSingVolume:CRecordTask::GetInstance()->GetSingVolume()];
        }else {
            [m_pAudioGraph setSingVolume:0.0];
        }
        
        
        [m_pAudioGraph startAUGraph];
        
        UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
        
        m_RecordStatus = RECORD_STATUS_RECORDING;
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Recording);
        std::string str_umeng_log;
        UMengLog(KS_RECORD_MUSIC, str_umeng_log + "AudioRecord_" + (CRecordTask::GetInstance()->m_bIsFreeSing ? "FreeSing_" : "NoFreeSing_") + "Success");
    }
    KS_BLOCK_RUN_THREAD();
    
    return true;
}

bool CAudioRecord::PauseRecord(){
    [m_pAudioGraph pauseAUGraph];
    
    m_RecordStatus = RECORD_STATUS_PAUSED;
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordPaused);
    
    return true;
}

bool CAudioRecord::ResumeRecord(){
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    
    [m_pAudioGraph resumeAUGraph];
    
    m_RecordStatus = RECORD_STATUS_RECORDING;
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Recording);
    
    return true;
}

bool CAudioRecord::StopRecord(){
    [m_pAudioGraph stopAUGraph];
    
    m_RecordStatus = RECORD_STATUS_STOP;
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordStop);
    
    return true;
}

int CAudioRecord::CurrentTime()const{
    if (nil != m_pAudioGraph) {
        return [m_pAudioGraph currentTime];
    }else {
        return 0;
    }
}

int CAudioRecord::Duration()const{
    if (nil != m_pAudioGraph) {
        return [m_pAudioGraph getDuration];
    }else {
        return 0;
    }
}

EMediaRecordStatus CAudioRecord::GetRecordStatus()const{
    return m_RecordStatus;
}

unsigned int CAudioRecord::GetCurVolume(){
    return [m_pAudioGraph getSingVolume];
}

void CAudioRecord::IAudioStateObserver_PlayStatusStop(){    
    
    m_RecordStatus = RECORD_STATUS_STOP;
    
    [MobClick endEvent:[NSString stringWithUTF8String:KS_RECORD_TIME]];
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordFinish);
}

void CAudioRecord::IAudioStateObserver_FreeSingFinish(){
    
    [MobClick endEvent:[NSString stringWithUTF8String:KS_RECORD_TIME]];
    
    m_RecordStatus = RECORD_STATUS_STOP;
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordFinish);
}

void CAudioRecord::IAudioStateObserver_PlayStatusErr(){
    
    [MobClick endEvent:[NSString stringWithUTF8String:KS_RECORD_TIME]];
    
    [m_pAudioGraph stopAUGraph];
    
    m_RecordStatus = RECORD_STATUS_ERR;
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordErr);
}

void CAudioRecord::IAudioStateObserver_RecordStatusFinish(){
    [m_pAudioGraph stopAUGraph];
        
    [MobClick endEvent:[NSString stringWithUTF8String:KS_RECORD_TIME]];
        
    m_RecordStatus = RECORD_STATUS_STOP;
}

void CAudioRecord::IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset){
    if (!bHasHeadset) {
        [m_pAudioGraph setSingVolume:0.0];
        [m_pAudioGraph setEchoType:NO_EFFECT];
    }else{
        [m_pAudioGraph setSingVolume:CRecordTask::GetInstance()->GetSingVolume()];
        [m_pAudioGraph setEchoType:CRecordTask::GetInstance()->GetEchoType()];
    }
    
    AVAudioSession* audio_session = [AVAudioSession sharedInstance];
    [audio_session setActive:YES error:nil];
    UInt32 un_audio_override = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(un_audio_override), &un_audio_override);
}

void CAudioRecord::IObserverApp_CallInComing(){
    [m_pAudioGraph pauseAUGraph];
    
    m_RecordStatus = RECORD_STATUS_PAUSED;
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordPaused);
}

bool CAudioRecord::SwitchResource(){
    UMengLog(KS_OA_CHANGE, "Origion Accompany Swap");
    
    [m_pAudioGraph switchResource];
    
    return true;
}

bool CAudioRecord::SetEchoType(EAudioEchoEffect e_echo_type){
    if (m_pAudioGraph) {
        [m_pAudioGraph setEchoType:e_echo_type];
    }
    
    return true;
}

bool CAudioRecord::SetSingVolume(float f_volume){

    [m_pAudioGraph setSingVolume:f_volume];
    
    return true;
}

bool CAudioRecord::SetAccompanyVolume(float f_volume){

    [m_pAudioGraph setAcomVolume:f_volume];
    
    return true;
}

bool CAudioRecord::IsFreeSing()const{
    return CRecordTask::GetInstance()->m_bIsFreeSing;
}
