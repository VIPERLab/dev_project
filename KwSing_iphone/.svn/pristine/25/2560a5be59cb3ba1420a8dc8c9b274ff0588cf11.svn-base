//
//  VideoRecorder.mm
//  KwSing
//
//  Created by 永杰 单 on 12-8-22.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "VideoRecorder.h"
#include "MessageManager.h"
#include "KwDir.h"
#include "KSRecordTempPath.h"
#include "IVideoStateObserver.h"
#import "AudioHelper.h"
#include "AutoLock.h"
#include "KuwoLog.h"
#include "KwConfig.h"
#include "KwConfigElements.h"
#include "KwUMengElement.h"
#include "UMengLog.h"
#include "RecordTask.h"
#include "KwUMengElement.h"
#include "MobClick.h"

#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioServices.h>
//#import <MediaPlayer/MPMusicPlayerController.h>

static KwTools::CLock s_video_record_lock;

CVideoRecorder::CVideoRecorder(){
    m_pVideoRecorder = [[KSVideoRecord alloc] init];
    m_AudioDuration = 0;
    KwTools::Dir::DeleteDir([KSRecordTempPath getRecordTempPath]);
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver);
    GLOBAL_ATTACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
}

CVideoRecorder::~CVideoRecorder(){
    
    if (m_pVideoRecorder) {
        [m_pVideoRecorder release];
        m_pVideoRecorder = nil;
    }
    if (m_pAudioGraph) {
        [m_pAudioGraph release];
        m_pAudioGraph = nil;
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver);
    GLOBAL_DETACH_MESSAGE(OBSERVER_ID_APP, IObserverApp);
}

bool CVideoRecorder::StartRecord(UIView* p_view){
    if (!CRecordTask::GetInstance()->m_bIsFreeSing && !(KwTools::Dir::IsExistFile(CRecordTask::GetInstance()->m_strOrigionPath) && KwTools::Dir::IsExistFile(CRecordTask::GetInstance()->m_strAccompanyPath))) {
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordErr);
        return false;
    }

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
//    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    
    KS_BLOCK_DECLARE{
        std::string record_audio_file_path;
        std::string record_video_file_path;
        if (!CRecordTask::GetInstance()->m_bIsFreeSing) {
            std::string record_file_path = KwTools::Dir::GetFileName(CRecordTask::GetInstance()->m_strAccompanyPath);
            int n_index = record_file_path.rfind(".");
            record_file_path = [KSRecordTempPath getRecordTempPath] + "/" + record_file_path.substr(0, n_index);
            record_audio_file_path = record_file_path + "Record.wav";
            record_video_file_path = record_file_path + ".mp4";
        }else {
            record_audio_file_path = [KSRecordTempPath getRecordTempPath] + "/FreeSing.wav";
            record_video_file_path = [KSRecordTempPath getRecordTempPath] + "/FreeSing.mp4";
        }
        
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

        [MobClick beginEvent:[NSString stringWithUTF8String:KS_RECORD_TIME]];
        if (![m_pVideoRecorder initVideoCapture:p_view VideoFilePath:[NSString stringWithUTF8String:record_video_file_path.c_str()]]) {
            m_RecordStatus = RECORD_STATUS_ERR;
            SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordErr);
            RTLog_Record(AR_FAIL, 2);
            std::string str_umeng_log;
            UMengLog(KS_RECORD_MUSIC, str_umeng_log + "VideoRecord_" + (CRecordTask::GetInstance()->m_bIsFreeSing ? "FreeSing_" : "NoFreeSing_") + "Fail");
        }

        if (![m_pVideoRecorder startVideoCapture]) {
            [m_pVideoRecorder stopVideoCapture];
            m_RecordStatus = RECORD_STATUS_ERR;
            RTLog_Record(AR_FAIL, 2);
            std::string str_umeng_log;
            UMengLog(KS_RECORD_MUSIC, str_umeng_log + "VideoRecord_" + (CRecordTask::GetInstance()->m_bIsFreeSing ? "FreeSing_" : "NoFreeSing_") + "Fail");
            SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordErr);
        }
        
        [m_pAudioGraph startAUGraph];
        
        UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
        
        m_RecordStatus = RECORD_STATUS_RECORDING;
        
        RTLog_Record(AR_SUCCESS, 2);
        std::string str_umeng_log;
        UMengLog(KS_RECORD_MUSIC, str_umeng_log + "VideoRecord_" + (CRecordTask::GetInstance()->m_bIsFreeSing ? "FreeSing_" : "NoFreeSing_") + "Success");
        
        SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Recording);
    }
    KS_BLOCK_ASYNRUN(0);
    
    return true;
}

bool CVideoRecorder::PauseRecord(){
    
    [m_pVideoRecorder pauseVideoCapture];
    [m_pAudioGraph pauseAUGraph];
    
    m_RecordStatus = RECORD_STATUS_PAUSED;
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordPaused);
    
    return true;
}

bool CVideoRecorder::ResumeRecord(){
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    UInt32 audio_route_override = [[AudioHelper getInstance] hasHeadset] ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    
    [m_pVideoRecorder continueVideoCapture];
    [m_pAudioGraph resumeAUGraph];
    
    m_RecordStatus = RECORD_STATUS_RECORDING;
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Recording);
    
    return true;
}

bool CVideoRecorder::StopRecord(){
    [m_pVideoRecorder stopVideoCapture];
    [m_pAudioGraph stopAUGraph];
    
    m_RecordStatus = RECORD_STATUS_STOP;
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordStop);
    
    return true;
}

int CVideoRecorder::CurrentTime()const{
    return [m_pAudioGraph currentTime];
}

int CVideoRecorder::Duration()const{
    return [m_pAudioGraph getDuration];
}

EMediaRecordStatus CVideoRecorder::GetRecordStatus()const{
    return m_RecordStatus;
}

unsigned int CVideoRecorder::GetCurVolume(){
    return [m_pAudioGraph getSingVolume];
}

void CVideoRecorder::IAudioStateObserver_PlayStatusStop(){
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordFinish);
}

void CVideoRecorder::IAudioStateObserver_PlayStatusErr(){
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordErr);
    
    [MobClick endEvent:[NSString stringWithUTF8String:KS_RECORD_TIME]];

    [m_pVideoRecorder stopVideoCapture];
    [m_pAudioGraph stopAUGraph];
    
    m_RecordStatus = RECORD_STATUS_ERR;
}

void CVideoRecorder::IAudioStateObserver_RecordStatusFinish(){
    [MobClick endEvent:[NSString stringWithUTF8String:KS_RECORD_TIME]];

    [m_pVideoRecorder stopVideoCapture];
    [m_pAudioGraph stopAUGraph];
    
    m_RecordStatus = RECORD_STATUS_STOP;
}

void CVideoRecorder::IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset){
    UInt32 audio_route_override = bHasHeadset ? kAudioSessionOverrideAudioRoute_None : kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audio_route_override), &audio_route_override);
    if (!bHasHeadset) {
        [m_pAudioGraph setSingVolume:0.0];
        [m_pAudioGraph setEchoType:NO_EFFECT];
    }else{
        [m_pAudioGraph setSingVolume:CRecordTask::GetInstance()->GetSingVolume()];
        [m_pAudioGraph setEchoType:CRecordTask::GetInstance()->GetEchoType()];
    }
}

void CVideoRecorder::IObserverApp_CallInComing(){
    [m_pVideoRecorder pauseVideoCapture];
    [m_pAudioGraph pauseAUGraph];
    
    m_RecordStatus = RECORD_STATUS_PAUSED;
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordPaused);
}


bool CVideoRecorder::SwitchResource(){

    UMengLog(KS_OA_CHANGE, "Origion Accompany Swap");
    
    [m_pAudioGraph switchResource];
    
    return true;
}

bool CVideoRecorder::SetEchoType(EAudioEchoEffect e_echo_type){
    if (m_pAudioGraph) {
        [m_pAudioGraph setEchoType:e_echo_type];
    }
    
    return true;
}

bool CVideoRecorder::SetSingVolume(float f_volume){
    if (m_pAudioGraph) {
        [m_pAudioGraph setSingVolume:f_volume];
    }
    
    return true;
}

bool CVideoRecorder::SetAccompanyVolume(float f_volume){
    if (m_pAudioGraph) {
        [m_pAudioGraph setAcomVolume:f_volume];
    }
    
    return true;
}

bool CVideoRecorder::IsFreeSing()const{
    return CRecordTask::GetInstance()->m_bIsFreeSing;
}
