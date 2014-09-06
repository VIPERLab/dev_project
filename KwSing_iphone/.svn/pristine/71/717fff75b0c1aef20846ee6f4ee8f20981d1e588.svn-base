/*
 *  log.h
 *  KwSing
 *
 *  Created by FelixLee on 11-4-7.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */


#ifndef _KUWO_LOG_H__
#define _KUWO_LOG_H__

#include <pthread.h>
#include <stdio.h>

//#ifdef _DEBUG || DEBUG
//#define KUWO_DEBUG_LOG
//#endif

#if  (defined DEBUG) || (defined _DEBUG)
#define KUWO_DEBUG_LOG
#endif

#define CLIENT_LOG  0
#define ERROR_LOG   1
#define WARNING_LOG 2
#define DEBUG_LOG   3

#define MAX_PATH 255

__BEGIN_DECLS

void c_KuwoDebugLog_start();

void setDebugLogFile(const char* path);
const char* getDebugLogFile();
    
void setClientLogFile(const char* path);
const char* getClientLogFile();

void setUserId(const char* userid);

void c_KuwoDebugLog(const char* szModule, int nLevel, const char* szFormat, ...);
void c_KuwoDebugLog_f(const char* szModule, int nLevel, const char* szContent);
void c_KuwoDebugLog_str(const char* szModule, int nLevel, const char* szContent);
void c_KuwoDebugLog_binary(const char* szModule, int nLevel, const void* lpBuff, int cbSize);
void c_KuwoDebugLog_hex(const char* szModule, int nLevel, const void* lpBuff, int cbSize);
	
void c_ErrorLog_binary(const void* lpBuff, int cbSize);

void c_KuwoClientLog(const char* szFormat, ...);
void c_KuwoClientLog_f(const char* szContent);


__END_DECLS

#endif  // _KUWO_LOG_H__