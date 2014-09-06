//
//  AudioPlayerManager.h
//  kwbook
//
//  Created by 单 永杰 on 13-12-2.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#ifndef __kwbook__AudioPlayerManager__
#define __kwbook__AudioPlayerManager__

#include <iostream>
#include "PlayBookList.h"
#include "KBLocalAudioPlayer.h"
#include "KBNetAudioPlayer.h"
#include "IObserverAudioPlayState.h"
#include "IObserverApp.h"

class CAudioPlayerManager : public IObserverAudioPlayState, public IObserverApp{
public:
    virtual ~CAudioPlayerManager();
    
    static CAudioPlayerManager* getInstance();
    
    bool play();
    void pause();
    void resume();
    void stop();
    void seek(float f_time_sec);
    float currentTime()const;
    float duration()const;
    float bufferRation();
    AudioPlayState getCurPlayState()const;
    void playNextChapter();
    void playPreChapter();
    
    void setChapterTimming(const int n_chapter_timming);
    bool isChapterTimerSet();
    int chapterLeft()const;
    
    virtual void IObserverAudioPlayStateChanged(AudioPlayState enumStatus);
    //转入后台
    virtual void IObserverApp_EnterBackground();
    //转入后台后没被杀掉，再次运行被唤醒
    virtual void IObserverApp_EnterForeground();

    virtual void IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset);
    virtual void IObserverApp_CallDialing();
    virtual void IObserverApp_CallDisconnected();
    
    bool IsLocalPlay()const;
    
private:
    CAudioPlayerManager();
    void beginBackgroundTask();
    void endBackgroundTask();
    void savePlaylist();
private:
    KBLocalAudioPlayer* m_pLocalPlayer;
    KBNetAudioPlayer* m_pNetPlayer;
    bool m_bLocalChapter;
    bool m_bBackground;
    UIBackgroundTaskIdentifier _bgTaskId;
    AudioPlayState m_PlayState;
    bool m_bChapterTiming;
    float m_fCurBufferRatio;
};

#endif /* defined(__kwbook__AudioPlayerManager__) */
