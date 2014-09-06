//
//  KuwoLog.mm
//  KwSing
//
//  Created by FelixLee on 11-4-6.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import "nonstdlib.h"
#import "debug.h"
#import "KuwoLog.h"
#import "KuwoConstants.h"
#import "iconvTranscode.h"

void kuwoDebugLog(NSString *module, NSInteger level, NSString *format, ...)
{
#ifdef KUWO_DEBUG_LOG
	const char* szModule = [module UTF8String];
	int nLevel = level;
	
	va_list argList;
	va_start(argList, format);
	NSString *content = [[NSString alloc] initWithFormat:format arguments:argList];
	va_end(argList);
	
	const char *szContent = [content UTF8String];
	c_KuwoDebugLog_f(szModule, nLevel, szContent);
	[content release];
#endif
}

void kuwoDebugLog_str(NSString *module, NSInteger level, NSString *content)
{
#ifdef KUWO_DEBUG_LOG
	const char* szModule = [module UTF8String];
	int nLevel = level;
	
	const char *szContent = [content UTF8String];
	c_KuwoDebugLog_str(szModule, nLevel, szContent);
#endif
}

void kuwoClientLog(NSString *format, ...)
{		
	va_list argList;
	va_start(argList, format);
	NSString *content = [[NSString alloc] initWithFormat:format arguments:argList];
	va_end(argList);
	const char *szContent = [content UTF8String];
	
	c_KuwoClientLog_f(szContent);
	[content release];
}

static const char* s_szActionTypes[] = {
    "KS_STARTUP",
    "KS_CLOSE",
    "KS_ACTIVATE",
    "KS_AUTHORIZATION",
    "KS_DOWN_LYRIC",
    "KS_GET_SONGURL",
    "KS_DOWN_MUSIC",
    "KS_PLAY_MUSIC",
    "KS_RECORD_MUSIC",
    "KS_SEARCH_MUSIC",
    "KS_UPDATE",
    "KS_DOWN_SET",
    "KS_DOWN_SONGLIST",
    "KS_USER_LOGIN",
    "KS_SHARE_MUSIC",
    "KS_SAVE_MUCIC",
    "KS_UPLOAD_MUSIC"
};

int BuildLog(char* buffer, int size, const char* format, ...)
{
	va_list args;
	va_start(args, format);
	int length = vsnprintf(buffer, size - 1, format, args);
    buffer[size - 1] = 0;
	va_end(args);
    return length;
}

void RTLogString(const char* str, int length)
{
	ASSERT(length > 0);
    int size = length * 2 + 1;
    char* temp = malloc(size);

    if (0 == TransUTF8ToGBK(temp, &size, str, strlen(str)))
    {
        c_KuwoClientLog_f(temp);
    }
    free(temp);
}

void RTLog(ACTION_TYPE type, const char* network, const char* buff)
{
	int logLen = 1024;
	char *log = (char*)malloc(logLen);
	memset(log, logLen, logLen);
	if (log == nil) {
		return;
	}

    if (network) {
        logLen = BuildLog(log, logLen, "|ACT:%s|%s|NE:%s", s_szActionTypes[type], buff, network);
    }
    else {
        logLen = BuildLog(log, logLen, "|ACT:%s|%s", s_szActionTypes[type], buff);
    }
    
    RTLogString(log, logLen);
    
	free(log);
}

void RTLogEx(ACTION_TYPE type, const char* network, const char* buff, ACTION_RESULT result)
{
	int logLen = 1024;
	char *log = (char*)malloc(logLen);
	memset(log, logLen, logLen);
	if (log == nil) {
		return;
	}
	ASSERT(ARRAYSIZE(s_szActionTypes) == ACTION_COUNT);
    if (network) {
        logLen = BuildLog(log, logLen, "|ACT:%s|%s|NE:%s|RET:%d", s_szActionTypes[type], buff, network, result);
    }
    else {
        logLen = BuildLog(log, logLen, "|ACT:%s|%s|RET:%d", s_szActionTypes[type], buff, result);
    }

	RTLogString(log, logLen);
    
    free(log);
}

int BuildLogActivate(char* buffer, int size, 
                     const char* uid/*, const char* version, const char* install_src, const char* device*/)
{
    ASSERT(buffer);
    return BuildLog(buffer, size, "2%%09<ACT:KS_ACTIVATE|U:%s|SRC:%s|DEV:%s|{%s}>", uid, KWSING_CLIENT_VERSION_STRING, DEVICE_TYPE, KWSING_INSTALL_SOURCE);
}

//void RealLog_Activate (const char* uid, const char* version, const char* install_src, const char* device)
//{
//    // not need log head
//	char buff[512] = { 0 };
//    int len = BuildLogActivate(buff, 512, uid,version,install_src,device);
//    
//    LogRealMsg(buff, len);
//
//}

//void LogRealMsg(const char* str,int length)
//{
//    ASSERT(length > 0);
//    int size = length * 2 + 1;
//    char* temp = malloc(size);
//    
//    if (0 == TransUTF8ToGBK(temp, &size, str, strlen(str)))
//    {
//        c_KuwoLogRealMsg(temp);
//    }
//    free(temp);
//    
//}

void RTLog_Exit (/*const char* version, const char* install_src*/)
{
	char buff[256] = { 0 };
	//BuildLog(buff, 256, "V:%s|SRC:%s", KWSING_CLIENT_VERSION_STRING, KWSING_INSTALL_SOURCE);
	BuildLog(buff, 256, "V:%s|SRC:%s|DEV:%s|SYS:%s", KWSING_CLIENT_VERSION_STRING, KWSING_INSTALL_SOURCE, DEVICE_TYPE, DEVICE_OS_VERSION);
	RTLog(ACTION_EXIT, nil, buff);
}

void RTLog_Authorization(ACTION_RESULT result, const char* network, 
                         const char* uid, const char* ip, const char* area, int authorized/*, const char* version, const char* install_src, const char* device*/)
{
	char buff[512] = { 0 };
	BuildLog(buff, 512, "UID:%s|DEV:%s|V:%s|SRC:%s|IP:%s|AREA:%s|AUT:%d", uid, DEVICE_TYPE, KWSING_CLIENT_VERSION_STRING, KWSING_INSTALL_SOURCE, ip, area, authorized);
	RTLogEx(ACTION_AUTHORIZATION, network, buff, result);
}

void RTLog_Update (const char* network, const char* last_version, const char* last_install_src)
{
	char buff[512] = { 0 };
	BuildLog(buff, 512, "V1:%s|V2:%s|SRC1:%s|SRC2:%s", last_version, KWSING_CLIENT_VERSION_STRING, last_install_src, KWSING_INSTALL_SOURCE);
	RTLogEx(ACTION_UPDATE, network, buff, AR_SUCCESS);
}

void RTLog_Login (ACTION_RESULT result, const char* network, 
                  const char* uid, const char* username,
                  const char* datetime, BOOL autoLogin,const char* source)
{
	char buff[512] = { 0 };
	BuildLog(buff, 512, "|UID:%s|UNAME:%s|TIME:%s|TYPE:%d|SRC:%s", uid, username, datetime, autoLogin,source);
	RTLogEx(ACTION_LOGIN, network, buff, result);
}

void RTLog_Play (ACTION_RESULT result, const char* title,
                 const char* artist, const char* rid, MUSIC_TYPE type)
{
	char buff[1024] = { 0 };
	BuildLog(buff, 1024, "NA:%s|AR:%s|RID:%s|T:%d",
			 title, artist, rid, type);
	RTLogEx(ACTION_PLAY, nil, buff, result);
}

void RTLog_Record(ACTION_RESULT result, int n_type){
    char buff[1024] = { 0 };
	BuildLog(buff, 1024, "T:%d",
			 n_type);
	RTLogEx(ACTION_RECORD, nil, buff, result);
}

void RTLog_DownloadLyric (ACTION_RESULT result, const char* network,
						  const char* title, const char* artist, const char* rid, int type)
{
	char buff[1024] = { 0 };
	BuildLog(buff, 1024, "NA:%s|AR:%s|RID:%s|T:%d", title, artist, rid, type);
	RTLogEx(ACTION_LYRIC, network, buff, result);
}

void RTLog_GetMusicUrl(ACTION_RESULT result, const char* network, 
                       const char* title, const char* artist, int nType, int64_t rid)
{
    char buff[1024] = {0};
    BuildLog(buff, 1024, "NA:%s|AR:%s|T:%d|RID:%lld|S:", title, artist, nType ,rid);
    RTLogEx(ACTION_GET_SONG_URL, network, buff, result);
}

void RTLog_DownloadMusic (ACTION_RESULT result, const char* network,
						  const char* title, const char* artist, const char* rid,
						  const char* format, int bitRate)
{
	char buff[1024] = { 0 };
	BuildLog(buff, 1024, "NA:%s|AR:%s|RID:%s|F:%s|B:%d", 
			 title, artist, rid, format, bitRate);
	RTLogEx(ACTION_DOWNLOAD_MUSIC, network, buff, result);
}

void RTLog_DownloadConfig (ACTION_RESULT result, const char* network//, 
                           /*const char* version, const char* install_src*/)
{
	char buff[156] = { 0 };
	BuildLog(buff, 256, "V:%s|SRC:%s", KWSING_CLIENT_VERSION_STRING, KWSING_INSTALL_SOURCE);
	RTLogEx(ACTION_CONFIG, network, buff, result);
}

void RTLog_DownloadSongList (ACTION_RESULT result, const char* network, const char* title)
{
	char buff[256] = { 0 };
	BuildLog(buff, 256, "NA:%s", title);
	RTLogEx(ACTION_SONGLIST, network, buff, result);
}

void RTLog_SearchMusic (ACTION_RESULT result, const char* network, const char* keys)
{
	char buff[512] = { 0 };
	BuildLog(buff, 512, "KEY_ALL:%s", keys);
	RTLogEx(ACTION_SEARCH, network, buff, result);
}

void RTLog_Share(ACTION_RESULT result, int target, const char* text)
{
    char buff[512] = { 0 };
	BuildLog(buff, 512, "TARGET:%d|TEXT:%s",target, text);
	RTLogEx(ACTION_SHARE, NULL, buff, result);
}

void RTLog_SaveMusic(ACTION_RESULT result, const char* title, const char* artist,const char* rid,const char* format,
                     int npicnum, int eumecho, int nduration, int nsavetime, int nscore)
{
    char buff[1024] = { 0 };
	BuildLog(buff, 1024,  "NA:%s|AR:%s|RID:%s|F:%s|PIC:%d|EC:%d|D:%d|S_TIME:%d|SCORE:%d", title, artist, rid, format, npicnum, eumecho, nduration, nsavetime, nscore);
	RTLogEx(ACTION_SAVE_MUSIC, NULL, buff, result);
}

void RTLog_UpLoadMusic (ACTION_RESULT result, const char* title, const char* artist,
                        const char* rid, const char* format, int nTime)
{
    char buff[1024] = { 0 };
	BuildLog(buff, 1024, "NA:%s|AR:%s|RID:%s|F:%s|TIME:%d",
			 title, artist, rid, format, nTime);
	RTLogEx(ACTION_UPLOAD_MUSIC, NULL, buff, result);
}
