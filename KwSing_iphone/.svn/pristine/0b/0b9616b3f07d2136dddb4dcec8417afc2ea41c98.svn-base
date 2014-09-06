//
//  VideoWorkPlayer.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-31.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CVideoWorkPlayer_h
#define KwSing_CVideoWorkPlayer_h

//#ifndef KwSing_CLocalWorkPlayer_h
//#include "LocalWorkPlayer.h"
//#endif

#ifndef KwSing_CMediaOnlinePlay_h
#include "MediaOnlinePlay.h"
#endif

#import "KSVideoPlayer.h"

#ifndef KwSing_IObserverApp_h
#include "IObserverApp.h"
#endif

class CVideoWorkPlayer : public IObserverApp, public CMediaOnlinePlay, public IVideoStateObserver {
public:
    CVideoWorkPlayer();
    virtual ~CVideoWorkPlayer();
public:
    virtual bool InitPlayer(MUSIC_RESOURCE *music_resource, UIView* p_view = NULL);
    virtual bool Play();
    virtual bool Pause();
    virtual bool Seek(float f_time);
    virtual bool ContinuePlay();
    virtual bool Stop();
    
    virtual int CurrentTime()const;
    virtual int Duration()const;
    
    bool DeinitPlayer();
    
    virtual float GetDownloadProgress(){return 1.0;};
    
    virtual unsigned int GetCurVolume(){return 0;};
    
    virtual EMediaPlayStatus GetPlayingStatus()const;
    
    virtual void IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset);
    virtual void IObserverApp_ResignActive();
    virtual void IVideoStateObserver_PlayStatusStop();
    virtual void IObserverApp_CallInComing();
    
private:
    KSVideoPlayer* m_pVideoPlayer;
    EMediaPlayStatus m_CurStatus;
};

#endif
