//
//  KuwoLog.h
//  KwSing
//
//  Created by FelixLee on 11-4-6.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "log.h"


__BEGIN_DECLS

void checkDebugLogFile(NSString *pathDebugLog);
void checkClientLogFile(NSString *pathClientLog);

void kuwoDebugLog(NSString *module, NSInteger level, NSString *format, ...);
void kuwoDebugLog_str(NSString *module, NSInteger level, NSString *content);
	
void kuwoClientLog(NSString *format, ...);

typedef enum _ACTION_TYPE {
    ACTION_STARTUP = 0,         // startup
    ACTION_EXIT,                // exit client
    ACTION_ACTIVATE,            // activate client first time
    ACTION_AUTHORIZATION,       // check user area authorization
    ACTION_LYRIC,               // download lyric
    ACTION_GET_SONG_URL,        // get song real url
    ACTION_DOWNLOAD_MUSIC,      // downliad music
    ACTION_PLAY,                // play a music
    ACTION_RECORD,              // record a music
    ACTION_SEARCH,              // search music
    ACTION_UPDATE,              // update client
    ACTION_CONFIG,              // download configure files
    ACTION_SONGLIST,            // download top music list
    ACTION_LOGIN,               // user login
    ACTION_SHARE,               // share music
    ACTION_SAVE_MUSIC,          // save music
    ACTION_UPLOAD_MUSIC,
    ACTION_COUNT
} ACTION_TYPE;

typedef enum _ACTION_RESULT {
    AR_SUCCESS = 0,     // 0. success
    AR_FAIL,            // 1. failed, this value is REVOKED now
    AR_CANCEL,          // 2. user canceled
    AR_CACHE,           // 3. use cached resources
    AR_LOCAL_RC,        // 4. use local resources
    AR_NETSRC_ERROR,    // 5. get net resources error,TP=none
    AR_CONN_ERROR,      // 6. net connection error
    AR_READ_ERROR,      // 7. read/receive data error
    AR_NO_NETWORK,      // 8. no network available
    AR_REJECT,          // 9. some result is evaluated, but is rejected by user
    AR_RESULT_COUNT
} ACTION_RESULT;

typedef enum _MUSIC_TYPE {
	ONLINE_MUSIC = 1,
	ACCOMPANY_MUSIC,
	ORIGINAL_MUSIC
} MUSIC_TYPE;

int BuildLog(char* buffer, int size, const char* format, ...);

void RTLogString(const char* str, int length);
void RTLog(ACTION_TYPE type, const char* network, const char* body);

void RTLogEx(ACTION_TYPE type, const char* network, const char* buff, ACTION_RESULT result);

int BuildLogActivate(char* buffer, int size, 
                     const char* uid/*, const char* version, const char* install_src, const char* device*/);

//void RealLog_Activate (const char* uid, const char* version, const char* install_src, const char* device);

//void LogRealMsg(const char* str,int length);
    
//void RTLog_Startup (/*const char* version, const char* install_src*/);
void RTLog_Exit (/*const char* version, const char* install_src*/);
    
void RTLog_Authorization(ACTION_RESULT result, const char* network, 
                         const char* uid, const char* ip, const char* area, int authorized/*, const char* version, const char* install_src, const char* device*/);

void RTLog_Update (const char* network, const char* last_version, const char* last_install_src);

void RTLog_Login (ACTION_RESULT result, const char* network,
                  const char* uid, const char* username,
				  const char* datetime, BOOL autoLogin,const char* source);

void RTLog_Play (ACTION_RESULT result, const char* title,
                 const char* artist, const char* rid, MUSIC_TYPE type);

void RTLog_DownloadLyric (ACTION_RESULT result, const char* network,
						  const char* title, const char* artist, const char* rid, int type);

void RTLog_Record(ACTION_RESULT result, int n_type);


void RTLog_GetMusicUrl(ACTION_RESULT result, const char* network, 
                       const char* title, const char* artist, int nType,int64_t rid);

void RTLog_DownloadMusic (ACTION_RESULT result, const char* network, 
						  const char* title, const char* artist,const char* rid,
						  const char* format, int bitRate);

void RTLog_DownloadConfig (ACTION_RESULT result, const char* network//, 
						   /*const char* version, const char* install_src*/);

void RTLog_DownloadSongList (ACTION_RESULT result, const char* network, const char* title);

void RTLog_SearchMusic (ACTION_RESULT result, const char* network, const char* keys);

void RTLog_Share(ACTION_RESULT result, int target, const char* text);

void RTLog_SaveMusic(ACTION_RESULT result, const char* title, const char* artist,const char* rid,const char* format,
                     int npicnum, int eumecho, int nduration, int nsavetime, int nscore);

void RTLog_UpLoadMusic (ACTION_RESULT result, const char* title, const char* artist,
                        const char* rid, const char* format, int nTime);

__END_DECLS
