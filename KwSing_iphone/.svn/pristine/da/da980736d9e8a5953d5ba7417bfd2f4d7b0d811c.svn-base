//
//  COnlineVideoPlayer.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_COnlineVideoPlayer_h
#define KwSing_COnlineVideoPlayer_h

#import "KSOnlineVideoPlayer.h"

#include "SongInfo.h"

#ifndef KwSing_CMediaOnlinePlay_h
#include "MediaOnlinePlay.h"
#endif

class COnlineVideoPlayer : public CMediaOnlinePlay{
public:
    COnlineVideoPlayer();
    virtual ~COnlineVideoPlayer();
    
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
    
private:
    KSOnlineVideoPlayer* m_pMoviePlayer;
    float m_fCurDownload;
};

#endif
