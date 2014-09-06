//
//  IObserverApp.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-16.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_IObserverApp_h
#define KwSing_IObserverApp_h

#include "IMessageObserver.h"

enum KSNetworkStatus
{
    NETSTATUS_NONE
    ,NETSTATUS_WWAN
    ,NETSTATUS_WIFI
};

@protocol IObserverApp <NSObject>
@optional
-(void)IObserverApp_SplashFinished:(UIView*)pRootView;
-(void)IObserverApp_SvrConfigUpdateFinished;
-(void)IObserverApp_ResignActive;
-(void)IObserverApp_BecomeActive;
-(void)IObserverApp_EnterBackground;
-(void)IObserverApp_EnterForeground;
-(void)IObserverApp_NetWorkStatusChanged:(KSNetworkStatus)enumStatus;
-(void)IObserverApp_HeadsetStatusChanged:(BOOL)bHasHeadset;
-(void)IObserverApp_MicrophoneStatusChanged:(BOOL)bHasMicrophone;
-(void)IObserverApp_CallInComing;
-(void)IObserverApp_CallDisconnected;
-(void)IObserverApp_MemoryWarning;
-(void)IObserverApp_VolumeControlChanged;
@end

class IObserverApp:public IMessageObserver
{
public:
    //启动画面显示完毕
    virtual void IObserverApp_SplashFinished(UIView* pRootView){}
    //服务器配置更新完毕
    virtual void IObserverApp_SvrConfigUpdateFinished(){}
    //非活跃，比如来电
    virtual void IObserverApp_ResignActive(){}
    //恢复活跃
    virtual void IObserverApp_BecomeActive(){}
    //转入后台
    virtual void IObserverApp_EnterBackground(){}
    //转入后台后没被杀掉，再次运行被唤醒
    virtual void IObserverApp_EnterForeground(){}
    //网络状态切换
    virtual void IObserverApp_NetWorkStatusChanged(KSNetworkStatus enumStatus){}
    //Headset Status Changed
    virtual void IObserverApp_HeadsetStatusChanged(BOOL bHasHeadset){}
    //Microphone Status Changed
    virtual void IObserverApp_MicrophoneStatusChanged(BOOL bHasMicrophone){}
    //来电
    virtual void IObserverApp_CallInComing(){}
    //挂断
    virtual void IObserverApp_CallDisconnected(){}
    //内存警告
    virtual void IObserverApp_MemoryWarning(){}
    //Volume Control button is clicked
    virtual void IObserverApp_VolumeControlChanged(){}
    
    
    enum eumMethod
    {
        SplashFinished
        ,SvrConfigUpdateFinished
        ,ResignActive
        ,BecomeActive
        ,EnterBackground
        ,EnterForeground
        ,NetWorkStatusChanged
        ,HeadsetStatusChanged
        ,MicrophoneStatusChanged
        ,CallInComing
        ,CallDisconnecte
        ,MemoryWarning
        ,VolumeControlChanged
    };
    
    MESSAGE_OBSERVER_NOTIFY_BEGIN(IObserverApp)
        NOTIFY_CASE_ITEM(SplashFinished,IObserverApp_SplashFinished,_1PARA);
        NOTIFY_CASE_ITEM(SvrConfigUpdateFinished,IObserverApp_SvrConfigUpdateFinished,_0PARA);
        NOTIFY_CASE_ITEM(ResignActive,IObserverApp_ResignActive,_0PARA);
        NOTIFY_CASE_ITEM(BecomeActive,IObserverApp_BecomeActive,_0PARA);
        NOTIFY_CASE_ITEM(EnterBackground,IObserverApp_EnterBackground,_0PARA);
        NOTIFY_CASE_ITEM(EnterForeground,IObserverApp_EnterForeground,_0PARA);
        NOTIFY_CASE_ITEM(NetWorkStatusChanged,IObserverApp_NetWorkStatusChanged,_1PARA);
        NOTIFY_CASE_ITEM(HeadsetStatusChanged,IObserverApp_HeadsetStatusChanged,_1PARA);
        NOTIFY_CASE_ITEM(MicrophoneStatusChanged,IObserverApp_MicrophoneStatusChanged,_1PARA);
        NOTIFY_CASE_ITEM(CallInComing,IObserverApp_CallInComing,_0PARA);
        NOTIFY_CASE_ITEM(CallDisconnecte,IObserverApp_CallDisconnected,_0PARA);
        NOTIFY_CASE_ITEM(MemoryWarning,IObserverApp_MemoryWarning,_0PARA);
        NOTIFY_CASE_ITEM(VolumeControlChanged,IObserverApp_VolumeControlChanged,_0PARA);
    MESSAGE_OBSERVER_NOTIFY_END();
};

#endif

