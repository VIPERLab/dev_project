//
//  AppInit.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-13.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_AppInit_h
#define KwSing_AppInit_h

class CAppInit
{
public:
    static CAppInit* GetInstance();
    
public:
    BOOL IsFirstStart();
    
    unsigned GetStartTimes();
    
public:
    void OnAppStart();
    
    void OnLaunchFinished();
    
    void OnSplashFinished(UIView* pRoot);
    
    void OnResignActive();
    
    void OnBecomeActive();
    
    void OnEnterBackground();
    
    void OnEnterForeground();
    
private:
    CAppInit();
    ~CAppInit(){}
    
    void _SaveLastVersionInfo();
    void _LogUpdateInfo();
    
    int m_nStartTimes;
};


#endif
