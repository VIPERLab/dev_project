//
//  MediaOnlinePlay.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CMediaOnlinePlay_h
#define KwSing_CMediaOnlinePlay_h

#ifndef KwSing_MediaStatus_h
#include "MediaStatus.h"
#endif

#ifndef KwSing_CMediaInterface_h
#include "MediaInterface.h"
#endif

#ifndef KwSing_SongInfo_h
#include "SongInfo.h"
#endif

class CMediaOnlinePlay : public CMediaInterface{
public:
    virtual ~CMediaOnlinePlay(){};
    
    virtual bool InitPlayer(MUSIC_RESOURCE *music_resource, UIView* p_view = NULL) = 0;
    
    virtual bool Play() = 0;
    virtual bool Pause() = 0;
    virtual bool Seek(float f_time) = 0;
    virtual bool ContinuePlay() = 0;
    virtual bool Stop() = 0;
    
    virtual int CurrentTime()const = 0;
    virtual int Duration()const = 0;
    
    virtual float GetDownloadProgress() = 0;
    
    virtual unsigned int GetCurVolume(){return 0;};
    
    virtual EMediaPlayStatus GetPlayingStatus()const = 0;
};

#endif
