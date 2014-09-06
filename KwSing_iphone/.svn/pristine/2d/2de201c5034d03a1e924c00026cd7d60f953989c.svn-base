//
//  KSMvRecord.m
//  KwSing
//
//  Created by 单 永杰 on 13-11-8.
//  Copyright (c) 2013年 酷我音乐. All rights reserved.
//

#import "KSMvRecord.h"
#import "VMediaPlayer.h"
#import "VMediaPlayerDelegate.h"
#import "AudioUnitRecorder.h"
#include "KwTools.h"
#import "KSRecordTempPath.h"
#include "RecordTask.h"
#include "MessageManager.h"
#include "IAudioStateObserver.h"

@interface KSMvRecord () <VMediaPlayerDelegate>{
    VMediaPlayer* video_player;
    CAudioUnitRecorder* audio_recorder;
}

@end

@implementation KSMvRecord

- (void) initRecorder : (CSongInfoBase*) song_info withView : (UIView*)view{
    video_player = [VMediaPlayer sharedInstance];
    [video_player reset];
    [video_player setupPlayerWithCarrierView:view withDelegate:self];
//    [video_player setDataSource:[NSURL fileURLWithPath:[NSString stringWithUTF8String:song_info->mvRes.strLocalPath.c_str()]]];
    
    std::string record_file_path;
    record_file_path = KwTools::Dir::GetFileName(CRecordTask::GetInstance()->m_strAccompanyPath);
    int n_index = record_file_path.rfind(".");
    record_file_path = [KSRecordTempPath getRecordTempPath] + "/" + record_file_path.substr(0, n_index) + "Record.wav";
    NSString* str_output_file_path = [NSString stringWithFormat:@"%s", record_file_path.c_str()];
    
    audio_recorder = new CAudioUnitRecorder;
    audio_recorder->initAudioUnit(str_output_file_path);
    audio_recorder->SetEchoType(NO_EFFECT);
    
    [video_player prepareAsync];
}

- (bool) pause{
    [video_player pause];
    audio_recorder->pauseRecord();
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordPaused);
    
    return true;
}
- (bool) resume{
    [video_player start];
    audio_recorder->startRecord();
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Recording);
    
    return true;
}
- (bool) stop{
    [video_player pause];
    audio_recorder->stopRecord();
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordStop);
    
    return true;
}
- (bool) setSingVolume : (float)f_sing_volume{
    audio_recorder->SetReplayVolume(f_sing_volume);
    
    return true;
}
- (bool) setAcomVolume : (float)f_acom_volume{
    [video_player setVolume:f_acom_volume];
    
    return true;
}

- (bool) switchOrigAcom : (bool)b_Orig{
    if (b_Orig) {
        [video_player setChannelVolumeLeft:-1.0 right:1.0];
    }else {
        [video_player setChannelVolumeLeft:1.0 right:-1.0];
    }
    
    return true;
}

- (long) currentTime{
    return [video_player getCurrentPosition];
}

- (long) duration{
    return [video_player getDuration];
}

- (bool) reset{
    audio_recorder->dispose();
    
    if (audio_recorder) {
        delete audio_recorder;
        audio_recorder = NULL;
    }
    
    [video_player reset];
    
    return true;
}

- (void)mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg{
    audio_recorder->startRecord();
    [video_player start];
    
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::Recording);
}

- (void)mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg{
    audio_recorder->dispose();
    
    if (audio_recorder) {
        delete audio_recorder;
        audio_recorder = NULL;
    }
    
    [video_player reset];
    
    //通知播放结束；
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordStop);
}

- (void)mediaPlayer:(VMediaPlayer *)player error:(id)arg{
    audio_recorder->dispose();
    
    if (audio_recorder) {
        delete audio_recorder;
        audio_recorder = NULL;
    }
    
    [video_player reset];
    
    //通知播放错误
    SYN_NOTIFY(OBSERVER_ID_AUDIOSTATUS, IAudioStateObserver::RecordErr);
}

@end
