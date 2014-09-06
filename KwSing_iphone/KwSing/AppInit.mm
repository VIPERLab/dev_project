//
//  AppInit.mm
//  KwSing
//
//  Created by 海平 翟 on 12-7-16.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include <CoreText/CoreText.h>
#include "AppInit.h"
#include "MessageManager.h"
#include "IObserverApp.h"
#include "KwUpdate.h"
#include "KwConfig.h"
#include "KuwoLog.h"
#include "CacheMgr.h"
#include "MainViewController.h"
#include "LocalMusicRequest.h"
#include "KSAppDelegate.h"
#include "AudioHelper.h"
#include "ASIHttpRequest.h"
#include "KuwoConstants.h"
#include "User.h"
#include "IUserStatusObserver.h"
#include "AuthorityInfoManager.h"
#include "MyMessageManager.h"
#include "KwConfigElements.h"
#include "KwTools.h"
#include "WXApi.h"
#include "SBJson.h"
#include "RecordTask.h"

CAppInit* CAppInit::GetInstance()
{
    static CAppInit sAppInit;
    return &sAppInit;
}

CAppInit::CAppInit()
:m_nStartTimes(0)
{
}

BOOL CAppInit::IsFirstStart()
{
    return GetStartTimes()==1;
}

unsigned CAppInit::GetStartTimes()
{
    if (m_nStartTimes==0) {
        KwConfig::GetConfigureInstance()->GetConfigIntValue("App", "starttimes"KWSING_VERSION_STRING, m_nStartTimes);
        KwConfig::GetConfigureInstance()->SetConfigIntValue("App", "starttimes"KWSING_VERSION_STRING, ++m_nStartTimes);
        KwConfig::GetConfigureInstance()->SaveConfig();
    }
    return m_nStartTimes;
}

#define URL_GET_HRBID  "http://changba.kuwo.cn/kge/mobile/ActivityServer?act=banglistid"
//#define URL_GET_HRBID  "http://60.28.205.41/kge/mobile/ActivityServer?act=banglistid"
//刚刚进入main函数
void CAppInit::OnAppStart()
{
    //初始化
    CCacheMgr::GetInstance();
    [AudioHelper getInstance];
    [ASIHTTPRequest hideNetworkActivityIndicator];
    KwConfig::GetConfigureInstance()->InitConfig();
    
    if (IsFirstStart()) {
        _SaveLastVersionInfo();
        _LogUpdateInfo();
        KwUpdate::GetUpdateInstance()->SendActiveRealLog();
        KwConfig::GetConfigureInstance()->SetConfigBoolValue(SECTION_COMMENT, BOOL_NEED_PROMPT, true);
        KwConfig::GetConfigureInstance()->SetConfigBoolValue(SPRING_MATCH_GROUP, SPRING_MATCH_ENABLE, true);
        KwConfig::GetConfigureInstance()->SetConfigBoolValue(SPRING_MATCH_GROUP, SPRING_MATCH_JOIN, false);
        CFUUIDRef p_uuid = CFUUIDCreate(nil);
        CFStringRef str_uuid = CFUUIDCreateString(nil, p_uuid);
        NSString* str_uuid_result = (NSString*)CFStringCreateCopy(NULL, str_uuid);
        KwConfig::GetConfigureInstance()->SetConfigStringValue(DEVICE_INFO, DEVICE_UUID, [str_uuid_result UTF8String]);
        
        CFRelease(p_uuid);
        CFRelease(str_uuid);
        [str_uuid_result release];
        
        NSString* str_library_localMusic = [NSString stringWithFormat:@"%@/LocalMusic", KwTools::Dir::GetPath(KwTools::Dir::PATH_CASHE) ];
        if (KwTools::Dir::IsExistFile(str_library_localMusic)) {
            NSString* dest_path = KwTools::Dir::GetPath(KwTools::Dir::PATH_LOCALMUSIC);
            KwTools::Dir::CopyDir(str_library_localMusic, dest_path);
            KwTools::Dir::SkipBackupDirectory(dest_path);
            KwTools::Dir::DeleteDir(str_library_localMusic);
        }
        
        NSString* str_library_myOpus = [NSString stringWithFormat:@"%@/MyOpus", KwTools::Dir::GetPath(KwTools::Dir::PATH_CASHE) ];
        if (KwTools::Dir::IsExistFile(str_library_myOpus)) {
            NSString* dest_path = KwTools::Dir::GetPath(KwTools::Dir::PATH_OPUS);
            KwTools::Dir::CopyDir(str_library_myOpus, dest_path);
            KwTools::Dir::SkipBackupDirectory(dest_path);
            KwTools::Dir::DeleteDir(str_library_myOpus);
        }
        
        NSString* str_library_lyric = [NSString stringWithFormat:@"%@/Lyric", KwTools::Dir::GetPath(KwTools::Dir::PATH_CASHE) ];
        if (KwTools::Dir::IsExistFile(str_library_lyric)) {
            NSString* dest_path = KwTools::Dir::GetPath(KwTools::Dir::PATH_LYRIC);
            KwTools::Dir::CopyDir(str_library_lyric, dest_path);
            KwTools::Dir::SkipBackupDirectory(dest_path);
            KwTools::Dir::DeleteDir(str_library_lyric);
        }
    }
    
    KS_BLOCK_DECLARE
    {//第一次调用这个字体函数会卡很久，这玩意需要6s多来执行。。。提前后台load一下
       CFRelease(CTFontCreateWithName((CFStringRef)@"宋体",12,NULL));
    }
    KS_BLOCK_RUN_THREAD(KS_BLOCK_PRIORITY_LOW);
    
    KS_BLOCK_DECLARE
    {
        std::string strRet;
        CHttpRequest::QuickSyncGet(URL_GET_HRBID, strRet);
        if (strRet.size() != 0) {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *retDic = [parser objectWithString:[NSString stringWithUTF8String:strRet.c_str()]];
            [parser release];
            NSLog(@"activity info:%@",[retDic description]);
            NSString *result = [retDic objectForKey:@"result"];
            if ([result isEqualToString:@"ok"] ) {
                NSArray *activityArray = [retDic objectForKey:@"activity"];
                NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
                for (NSDictionary *actiInfo in activityArray) {
                    NSString *type = [actiInfo objectForKey:@"type"];
                    NSString *bangId = [actiInfo objectForKey:@"bangId"];
                    if (([type isEqualToString:@"HRB"] || [type isEqualToString:@"hrb"]) && bangId) {
                        KwConfig::GetConfigureInstance()->SetConfigStringValue(ACTIVITY_GROUP, HRB_ID, [bangId UTF8String]);
                    }
                    else{
                        [tmpArray addObject:actiInfo];
                    }
                }
                if ([tmpArray count] > 0) {
                    CRecordTask::GetInstance()->m_ActivityArray=[tmpArray copy];
                    [tmpArray release];
                }
            }
        }
    }KS_BLOCK_RUN_THREAD()
}

//刚刚alloc完window
void CAppInit::OnLaunchFinished()
{
    KwUpdate::GetUpdateInstance()->BackupLogFile();
    KwUpdate::GetUpdateInstance()->UpdateConfig();
    CLocalMusicRequest::GetInstance()->LoadAllTask();
    
    if(CHttpRequest::GetNetWorkStatus() == NETSTATUS_WIFI)
    {
        KwUpdate::GetUpdateInstance()->SendClientLogToServer();
    }
    
    //冒泡提示数字
    CMyMessageManager::GetInstance()->StartQuery();
}

//启动画面显示完毕
void CAppInit::OnSplashFinished(UIView* pRoot)
{
    ASYN_NOTIFY(OBSERVER_ID_APP,IObserverApp::SplashFinished,0,pRoot);
    
    //是否在授权区域
    CAuthorityInfoManager::GetAuthorityInfo();
    //自动登陆
    KS_BLOCK_DECLARE
    {
        bool isAutoLogin(false);
        KwConfig::GetConfigureInstance()->GetConfigBoolValue(USER_GROUP, USER_AUTOLOGIN, isAutoLogin);
        if (isAutoLogin) {
//            string name;
//            string base64Pwd;
//            KwConfig::GetConfigureInstance()->GetConfigStringValue(USER_GROUP, USER_NAME, name);
//            KwConfig::GetConfigureInstance()->GetConfigStringValue(USER_GROUP, USER_PWD, base64Pwd);
//            int nLength=KwTools::Base64::Base64DecodeLength(base64Pwd.length());
//            char *pDecodePwd=new char[nLength];
//            memset(pDecodePwd, 0, nLength);
//            KwTools::Base64::Base64Decode(base64Pwd.c_str(), base64Pwd.length(), pDecodePwd, nLength);
//            string password(pDecodePwd,nLength);
//            delete []pDecodePwd;
                User::GetUserInstance()->autoLogin();
        }
    }
    KS_BLOCK_ASYNRUN(1000);
}

//非活跃，比如来电或者按home键等
void CAppInit::OnResignActive()
{
    SYN_NOTIFY(OBSERVER_ID_APP,IObserverApp::ResignActive);    
}

//恢复活跃
void CAppInit::OnBecomeActive()
{
    SYN_NOTIFY(OBSERVER_ID_APP,IObserverApp::BecomeActive);    
}

//转入后台，在这之前会先触发OnResignActive
void CAppInit::OnEnterBackground()
{
    //清理超期缓存
    CCacheMgr::GetInstance()->CleanOutOfDate();
    //保存配置数据
    KwConfig::GetConfigureInstance()->SaveConfig();
    
    SYN_NOTIFY(OBSERVER_ID_APP,IObserverApp::EnterBackground);
}

//转入后台后没被杀掉，再次运行被唤醒，在这之后会触发OnBecomeActive
void CAppInit::OnEnterForeground()
{
    SYN_NOTIFY(OBSERVER_ID_APP,IObserverApp::EnterForeground);   
}

void CAppInit::_SaveLastVersionInfo()
{
    std::string strLastVersion;
    std::string strLastInstallSrc;
    KwConfig::GetConfigureInstance()->GetConfigStringValue("App", "NowVersion", strLastVersion);
    KwConfig::GetConfigureInstance()->GetConfigStringValue("App", "NowInstallSrc", strLastInstallSrc);
    if (strLastVersion!=KWSING_VERSION_STRING) {
        KwConfig::GetConfigureInstance()->SetConfigStringValue("App", "LastVersion", strLastVersion);
        KwConfig::GetConfigureInstance()->SetConfigStringValue("App", "LastInstallSrc", strLastInstallSrc);
    }
    KwConfig::GetConfigureInstance()->SetConfigStringValue("App", "NowVersion", KWSING_VERSION_STRING);
    KwConfig::GetConfigureInstance()->SetConfigStringValue("App", "NowInstallSrc", KWSING_INSTALL_SOURCE);
    KwConfig::GetConfigureInstance()->SaveConfig();
}

void CAppInit::_LogUpdateInfo()
{
    std::string strLastVersion;
    std::string strLastInstallSrc;
    KwConfig::GetConfigureInstance()->GetConfigStringValue("App", "LastVersion", strLastVersion);
    KwConfig::GetConfigureInstance()->GetConfigStringValue("App", "LastInstallSrc", strLastInstallSrc);
    if (strLastVersion.empty()) {
        return;
    }
    RTLog_Update(CHttpRequest::GetNetWorkProviderName().c_str(), strLastVersion.c_str(), strLastInstallSrc.c_str());
}






