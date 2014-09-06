//
//  LocalWorkPlayer.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-31.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CLocalWorkPlayer_h
#define KwSing_CLocalWorkPlayer_h

#ifndef KwSing_MediaStatus_h
#include "MediaStatus.h"
#endif

#ifndef KwSing_CMediaInterface_h
#include "MediaInterface.h"
#endif

#include <string>

class CLocalWorkPlayer : public CMediaInterface {
public:
    virtual ~CLocalWorkPlayer(){};
    
    virtual bool InitPlayer(std::string str_play_file_name, UIView* p_view = NULL) = 0;
    virtual bool StartPlay() = 0;
    virtual bool PausePlay() = 0;
    virtual bool ContinuePlay() = 0;
    virtual bool Stop() = 0;
    virtual bool Seek(float f_seek_time) = 0;
    
    virtual bool DeinitPlayer() = 0;
    
    virtual int CurrentTime()const = 0;
    virtual unsigned int GetCurVolume(){return 0;};
    virtual int Duration()const = 0;
    virtual EMediaPlayStatus GetPlayStatus()const = 0;
};

#endif
