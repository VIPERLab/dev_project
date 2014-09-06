//
//  LocalVideoPlayer.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CLocalVideoPlayer_h
#define KwSing_CLocalVideoPlayer_h

#include <string>

#import "KSAVAudioPlayer.h"
#import "KSVideoPlayer.h"

#ifndef _CAudioQueuePlayer_H
#include "AudioQueuePlayer.h"
#endif

#ifndef KwSing_IObserverApp_h
#include "IObserverApp.h"
#endif

#ifndef KwSing_AudioEffectType_h
#include "AudioEffectType.h"
#endif

#ifndef KwSing_MediaStatus_h
#include "MediaStatus.h"
#endif

#ifndef KwSing_IVideoStateObserver_h
#include "IVideoStateObserver.h"
#endif

#ifndef KwSing_CMediaReplay_h
#include "MediaReplay.h"
#endif

#ifndef KwSing_IAudioStateObserver_h
#include "IAudioStateObserver.h"
#endif

class CLocalVideoPlayer : public CMediaReplay, public IObserverApp, public IVideoStateObserver, public IAudioStateObserver{
public:
    CLocalVideoPlayer();
    virtual ~CLocalVideoPlayer();
public:
    bool InitPlayer(UIView* p_view = NULL);
    void SetAudioEchoEffect(EAudioEchoEffect echo_effect);
    bool StartPlay();
    bool PausePlay();
    bool ContinuePlay();
    bool Stop();
    bool Seek(float f_seek_time);
    bool DeinitPlayer();
    
    int CurrentTime()const;
    int Duration()const;
    EMediaPlayStatus GetPlayStatus()const;
    unsigned int GetCurVolume();
    
//    virtual void IVideoStateObserver_PlayStatusStop();
    virtual void IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset);
    virtual void IAudioStateObserver_PlayStatusStop();
    virtual void IObserverApp_CallInComing();
    
private:
    KSAVAudioPlayer* m_pSingPlayer;
    AVAudioPlayer* m_pAcomPlayer;
    EMediaPlayStatus m_CurPlayStatus;
    KSVideoPlayer* m_pMoviePlayer;
    std::string m_strRecordFilePath;
    int m_nMovieDuration;
    bool m_bStoped;
};

#endif
