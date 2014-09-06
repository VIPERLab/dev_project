//
//  CAppInit.h
//  kwbook
//
//  Created by 熊 改 on 13-12-20.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#ifndef KbSing_AppInit_h
#define KbSing_AppInit_h

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

