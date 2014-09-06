//
//  MediaModelFactory.h
//  KwSing
//
//  Created by 永杰 单 on 12-8-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_CMediaModelFactory_h
#define KwSing_CMediaModelFactory_h

#ifndef KwSing_CAudioRecord_h
#include "AudioRecord.h"
#endif

#ifndef KwSing_CVideoRecorder_h
#include "VideoRecorder.h"
#endif

#ifndef KwSing_COnlineAudioPlayer_h
#include "OnlineAudioPlayer.h"
#endif

#ifndef KwSing_CAuditionPlay_h
#include "AuditionPlay.h"
#endif

#ifndef KwSing_CLocalVideoPlayer_h
#include "LocalVideoPlayer.h"
#endif

#ifndef KwSing_COnlineVideoPlayer_h
#include "COnlineVideoPlayer.h"
#endif

#ifndef KwSing_CSaveAudio_h
#include "SaveAudio.h"
#endif

#ifndef KwSing_CSaveVideo_h
#include "SaveVideo.h"
#endif

#ifndef KwSing_COrigionSongPlayer_h
#include "OrigionSongPlayer.h"
#endif

#ifndef KwSing_CLocalWorkPlayer_h
#include "LocalWorkPlayer.h"
#endif

class CMediaModelFactory {
private:
    CMediaModelFactory();
    virtual ~CMediaModelFactory();
    
public:
    static CMediaModelFactory* GetInstance();
    
    CMediaRecord* CreateMediaRecord(bool b_is_video);
    void ReleaseMediaRecord();
    
    CMediaReplay* CreateMediaReplay(bool b_is_video);
    void ReleaseMediaReplay();
    
    CMediaOnlinePlay* CreateMediaOnlinePlay(bool b_is_video);
    void ReleaseMediaOnlinePlayer();
    
    CMediaSaveInterface* CreateMediaSaver(bool b_is_video);
    void ReleaseMediaSaver();
    
    COrigionSongPlayer* CreateOrigionSongPlayer();
    void ReleaseOrigionSongPlayer();
    
    CMediaOnlinePlay* CreateLocalWorkPlayer(bool b_is_video);
    void ReleaseLocalWorkPlayer();
    
private:
    CMediaRecord* m_pMediaRecord;
    CMediaReplay* m_pMediaReplay;
    CMediaOnlinePlay* m_pMediaOnlinePlay;
    CMediaSaveInterface* m_pMediaSaver;
    COrigionSongPlayer* m_pOrigionSongPlayer;
    CMediaOnlinePlay* m_pLocalWorkPlayer;
};

#endif
