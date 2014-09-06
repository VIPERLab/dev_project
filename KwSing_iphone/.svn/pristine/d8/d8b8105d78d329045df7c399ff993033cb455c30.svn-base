//
//  OnlineAudioPlayer.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-15.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_COnlineAudioPlayer_h
#define KwSing_COnlineAudioPlayer_h

#import "KSAVPlayer.h"

#ifndef KwSing_IAudioStateObserver_h
#include "IAudioStateObserver.h"
#endif

#ifndef KwSing_IObserverApp_h
#include "IObserverApp.h"
#endif

#ifndef KwSing_CMediaOnlinePlay_h
#include "MediaOnlinePlay.h"
#endif

#ifndef KwSing_KwDir_h
#include "KwDir.h"
#endif

#ifndef KwSing_SongInfo_h
#include "SongInfo.h"
#endif

#include <string>

class COnlineAudioPlayer : public CMediaOnlinePlay, public IAudioStateObserver, public IObserverApp{
public:
    COnlineAudioPlayer();
    virtual ~COnlineAudioPlayer();
    
public:
    bool InitPlayer(MUSIC_RESOURCE *music_resource, UIView* p_view = NULL);
    
    bool Play();
    bool Pause();
    bool Seek(float f_time);
    bool ContinuePlay();
    bool Stop();
    
    int CurrentTime()const;
    int Duration()const;
    
    float GetDownloadProgress();
    
    EMediaPlayStatus GetPlayingStatus()const;
    
    virtual void IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset);
    virtual void IObserverApp_CallInComing();
    
private:
    KSAVPlayer* m_pAVPlayer;
    EMediaPlayStatus m_CurPlayingStatus;
    float m_fDownloadRange;
};

#endif
