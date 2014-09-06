//
//  OrigionSongPlayer.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-31.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_COrigionSongPlayer_h
#define KwSing_COrigionSongPlayer_h

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

#ifndef KwSing_IObserverApp_h
#include "IObserverApp.h"
#endif

#include <string>

class COrigionSongPlayer{
public:
    COrigionSongPlayer();
    virtual ~COrigionSongPlayer();
    
public:
    bool Play(std::string str_song_rid);
    bool Pause();
    bool Seek(float f_time);
    bool ContinuePlay();
    bool Stop();
    
    int CurrentTime()const;
    int Duration()const;
    
    float GetDownloadProgress()const;
    
    EMediaPlayStatus GetPlayingStatus()const;
    
    virtual void IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset);
private:
    KSAVPlayer* m_pAVPlayer;
    EMediaPlayStatus m_CurPlayingStatus;
};

#endif
