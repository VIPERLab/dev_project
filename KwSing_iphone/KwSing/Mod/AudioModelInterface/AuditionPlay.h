//
//  AuditionPlay.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-17.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CAuditionPlay_h
#define KwSing_CAuditionPlay_h

#import "KSAVAudioPlayer.h"

#ifndef _CAudioQueuePlayer_H
#include "AudioQueuePlayer.h"
#endif

#ifndef KwSing_IObserverApp_h
#include "IObserverApp.h"
#endif

#ifndef KwSing_IAudioStateObserver_h
#include "IAudioStateObserver.h"
#endif

#ifndef KwSing_AudioEffectType_h
#include "AudioEffectType.h"
#endif

#ifndef KwSing_CMediaReplay_h
#include "MediaReplay.h"
#endif

class CAuditionPlay : public CMediaReplay, public IObserverApp, public IAudioStateObserver{
public:
    bool InitPlayer(UIView* p_view = NULL);
    void SetAudioEchoEffect(EAudioEchoEffect echo_effect);
    bool StartPlay();
    bool PausePlay();
    bool ContinuePlay();
    bool Stop();
    bool Seek(float f_seek_time);
    bool DeinitPlayer(){return true;}
    
    int CurrentTime()const;
    int Duration()const;
    EMediaPlayStatus GetPlayStatus()const;
    unsigned int GetCurVolume();
    
    virtual void IAudioStateObserver_PlayStatusStop();
    virtual void IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset);
    virtual void IObserverApp_CallInComing();
    
public:
    CAuditionPlay();
    ~CAuditionPlay();
    
private:
    KSAVAudioPlayer* m_pSingPlayer;
    AVAudioPlayer* m_pAcomPlayer;
    EMediaPlayStatus m_CurPlayStatus;
    int m_nAudioDuration;
};

#endif
