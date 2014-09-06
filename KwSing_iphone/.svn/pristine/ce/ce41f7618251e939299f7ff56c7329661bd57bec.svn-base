//
//  Header.h
//  KwSing
//
//  Created by Qian Hu on 12-7-23.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_Update_h
#define KwSing_Update_h

#include "IObserverApp.h"

//更新配置，上传日志，发送实时日志(第一次联网时发送)
class KwUpdate : public IObserverApp{
private:
    KwUpdate();
    ~KwUpdate();
public:
    static KwUpdate* GetUpdateInstance();
    
public:
    BOOL SendClientLogToServer();
    BOOL BackupLogFile();
    BOOL UpdateConfig();
    
    BOOL SendRealLogToServer(const char* content, int len);
    BOOL SendActiveRealLog();
    
    virtual void IObserverApp_NetWorkStatusChanged(KSNetworkStatus enumStatus);
    
protected:
    BOOL CreateUploadLogFile(const char* logFile, const char* uploadFile);
    BOOL UploadLogFileThread(NSString* file);
    void UpdateConfigThread();
    
private:
    bool mUploadLogFlag;

};


#endif
