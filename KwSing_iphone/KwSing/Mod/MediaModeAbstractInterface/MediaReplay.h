//
//  MediaReplay.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CMediaReplay_h
#define KwSing_CMediaReplay_h

#ifndef KwSing_MediaStatus_h
#include "MediaStatus.h"
#endif

#ifndef KwSing_CMediaInterface_h
#include "MediaInterface.h"
#endif

class CMediaReplay : public CMediaInterface{
public:
    virtual ~CMediaReplay(){};
    
    virtual bool InitPlayer(UIView* p_view = NULL) = 0;
    virtual void SetAudioEchoEffect(EAudioEchoEffect echo_effect) = 0;
    virtual bool StartPlay() = 0;
    virtual bool PausePlay() = 0;
    virtual bool ContinuePlay() = 0;
    virtual bool Stop() = 0;
    virtual bool Seek(float f_seek_time) = 0;
    virtual bool DeinitPlayer() = 0;
    
    virtual int CurrentTime()const = 0;
    virtual int Duration()const = 0;
    virtual EMediaPlayStatus GetPlayStatus()const = 0;
    virtual unsigned int GetCurVolume() = 0;
};

#endif
