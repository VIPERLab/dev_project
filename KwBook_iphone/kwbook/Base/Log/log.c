/*
 *  log.c
 *  KwSing
 *
 *  Created by FelixLee on 11-4-7.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#include "log.h"
//#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include "nonstdlib.h"
#include "base64_.h"


pthread_mutex_t g_debuglog_mutex;
pthread_mutex_t g_clientlog_mutex;
pthread_mutex_t g_reallog_mutex;
char g_szPathDebugLog[MAX_PATH + 1] = {0};
char g_szPathClientLog[MAX_PATH + 1] = {0};
char g_szUserId[32] = {0};

void setDebugLogFile(const char* file)
{
	strncpy(g_szPathDebugLog, file, MAX_PATH);
}

const char* getDebugLogFile()
{
    return g_szPathDebugLog;
}

void setClientLogFile(const char* file)
{
	strncpy(g_szPathClientLog, file, MAX_PATH);
}

const char* getClientLogFile()
{
    return g_szPathClientLog;
}

void setUserId(const char* userid)
{
    strncpy(g_szUserId, userid, 31);
}

int GetCurTimeStr(char* szTime, int nSize)
{
	struct timeval tv;
    gettimeofday(&tv, NULL);
	struct tm tms = *localtime(&tv.tv_sec);
    //float sec = tms.tm_sec + (float)tv.tv_usec / 1000000;
    int length = snprintf(szTime, nSize-1, "%04d-%02d-%02d %02d:%02d:%02d.%03d", tms.tm_year+1900, tms.tm_mon+1, tms.tm_mday, tms.tm_hour, tms.tm_min, tms.tm_sec, tv.tv_usec / 1000);
	if (length > nSize-1) {
		length = nSize-1;
	}
    szTime[nSize-1] = 0;
	return length;
}

void c_KuwoDebugLog_start()
{
#ifdef KUWO_DEBUG_LOG
	pthread_mutex_lock (&g_debuglog_mutex);
    if (g_szPathDebugLog == NULL)
        return;
    FILE* fp = fopen(g_szPathDebugLog, "at");
    if (!fp)
    {
        pthread_mutex_unlock (&g_debuglog_mutex);
        return;
    }
	
	char szTime[64];
	GetCurTimeStr(szTime, ARRAYSIZE(szTime));
	char szTemp[512];
	int nlength = snprintf(szTemp, 512, "[%s]\t[%d]\t[START_UP]\tSTART_UP\r\n", szTime, DEBUG_LOG);
	//printf("%s", szTemp);
	if (nlength > 512)
		nlength = 512;
	
	fwrite("\r\n", 1, 2, fp);
	fwrite(szTemp, 1, nlength, fp);
	fclose(fp);
	pthread_mutex_unlock (&g_debuglog_mutex);
#endif
}

void c_KuwoDebugLog(const char* szModule, int nLevel, const char* szFormat, ...)
{
#ifdef	KUWO_DEBUG_LOG
	const int nAlloc = 1024;
	char szContent[nAlloc];
	va_list argList;
	va_start(argList, szFormat);
	vsnprintf(szContent, nAlloc, szFormat, argList);
	va_end(argList);
	
	c_KuwoDebugLog_f(szModule, nLevel, szContent);
#endif
}

void c_KuwoDebugLog_str(const char* szModule, int nLevel, const char* szContent)
{
#ifdef KUWO_DEBUG_LOG
	c_KuwoDebugLog_f(szModule, nLevel, szContent);
#endif
}

void c_KuwoDebugLog_f(const char* szModule, int nLevel, const char* szContent)
{
#ifdef KUWO_DEBUG_LOG
	pthread_mutex_lock (&g_debuglog_mutex);
    if (g_szPathDebugLog == NULL)
        return;
    FILE* fp = fopen(g_szPathDebugLog, "at");
    if (!fp)
    {
        pthread_mutex_unlock (&g_debuglog_mutex);
        return;
    }
	
	char szTime[64];
	GetCurTimeStr(szTime, ARRAYSIZE(szTime));
	char szTemp[2048];
	int nlength = snprintf(szTemp, 2048, "[%s]\t[%d]\t[%s]\t%s\r\n", szTime, nLevel, szModule, szContent);
	//printf("%s\n", szTemp);
	if (nlength > 2048)
		nlength = 2048;
		
	fwrite(szTemp, 1, nlength, fp);
	fclose(fp);
	pthread_mutex_unlock (&g_debuglog_mutex);
#endif
}

void c_KuwoDebugLog_binary(const char* szModule, int nLevel, const void* lpBuff, int cbSize)
{
#ifdef KUWO_DEBUG_LOG
	if (!lpBuff || cbSize < 0) {
		cbSize = 0;
	}
	
	pthread_mutex_lock (&g_debuglog_mutex);
    if (g_szPathDebugLog == NULL)
        return;
    FILE* fp = fopen(g_szPathDebugLog, "a+b");
    if (!fp)
    {
        pthread_mutex_unlock (&g_debuglog_mutex);
        return;
    }

	char szTime[256];
	char szBuff[256];
	GetCurTimeStr(szTime, ARRAYSIZE(szBuff));
	snprintf(szBuff, 255, "\r\n[%s]\t[%d]\t[%s]\t<BINARY DATA>(%d bytes)\r\n", szTime, nLevel, szModule, cbSize);
	szBuff[255] = 0;
	fwrite(szBuff, 1, strlen(szBuff), fp);
	
	if (cbSize > 0) {
		fwrite(lpBuff, 1, cbSize, fp);
	}
	
    fclose(fp);
	pthread_mutex_unlock (&g_debuglog_mutex);
#endif
}

void c_ErrorLog_binary(const void* lpBuff, int cbSize)
{
	char szLogFile[256];
	strcpy(szLogFile, g_szPathDebugLog);
	char *pos = strstr(szLogFile, "debug.txt");
	if (pos) {
		strcpy(pos, "iconv_error.txt");
		FILE *fLog = fopen(szLogFile, "a+b");
		if (fLog) {			
			fwrite(lpBuff, 1, cbSize, fLog);
			fwrite("\r\n*******\r\n\r\n", 1, strlen("\r\n*******\r\n\r\n"), fLog);
			fflush(fLog);
			fclose(fLog);
		}
	}
}

static const char* pszHexExamples = "0123456789abcdef";
char hex_ch_h(char ch)
{
	char cret = pszHexExamples[(((unsigned char)ch) & 0xF0) >> 4];
	return cret;//pszHexExamples[(((unsigned char)ch) & 0xF0) >> 4];
}
char hex_ch_l(char ch)
{
	char cret = pszHexExamples[(((unsigned char)ch) & 0x0F) >> 0];
	return cret;//pszHexExamples[(((unsigned char)ch) & 0x0F) >> 0];
}
void c_KuwoDebugLog_hex(const char* szModule, int nLevel, const void* lpBuff, int cbSize)
{
#ifdef KUWO_DEBUG_LOG
	if (!lpBuff) {
		return;
	}
    pthread_mutex_lock (&g_debuglog_mutex);
    if (g_szPathDebugLog == NULL)
        return;
    FILE* fp = fopen(g_szPathDebugLog, "a+b");
    if (!fp)
    {
        pthread_mutex_unlock (&g_debuglog_mutex);
        return;
    }
    
	if (cbSize == -1) {
		cbSize = strlen((const char*)lpBuff);
	}
	else if(cbSize < 0){
		cbSize = 0;
	}
	
    char szTime[256];
	char szHexHeader[256];
	GetCurTimeStr(szTime, ARRAYSIZE(szHexHeader));
	int len = snprintf(szHexHeader, 255, "[%s]\t[%d]\t[%s]\t<HEX DATA>(%d bytes)\t", szTime, nLevel, szModule, cbSize);
	if (len > 255) {
		len = 255;
	}
	szHexHeader[255] = 0;
	
	char *pszHex = malloc(sizeof(char) * (cbSize * 2 + len + 2));
	if(!pszHex)
		return;
	
	strcpy(pszHex, szHexHeader);
	char* pchDest = pszHex + len;
	const char* pchSrc = (const char*)lpBuff, *pchGuard = (const char*)lpBuff + cbSize;
	while( pchSrc < pchGuard )
	{
		*pchDest++ = hex_ch_h(*pchSrc);
		*pchDest++ = hex_ch_l(*pchSrc);
		++pchSrc;
	}
	*pchDest++ = '\n';
	*pchDest = '\0';
	
	fwrite(pszHex, 1, strlen(pszHex), fp);
	fclose(fp);
	pthread_mutex_unlock (&g_debuglog_mutex);
	
	free(pszHex);
#endif
}

void c_KuwoClientLog(const char* szFormat, ...)
{
	const int nAlloc = 1024;
	char szContent[nAlloc];
	va_list argList;
	va_start(argList, szFormat);
	vsnprintf(szContent, nAlloc, szFormat, argList);
	va_end(argList);
	
	c_KuwoClientLog_f(szContent);
}

void c_KuwoClientLog_f(const char* szContent)
{
    if (g_szPathClientLog == NULL)
        return;
    
	pthread_mutex_lock (&g_clientlog_mutex);
    FILE* fp = fopen(g_szPathClientLog, "at");
    if (!fp)
    {
        pthread_mutex_unlock (&g_clientlog_mutex);
        return;
    }
	
	char szTime[64];
	GetCurTimeStr(szTime, ARRAYSIZE(szTime));
	char szTemp[2048];
	int nlength = snprintf(szTemp, 2047, "[%s][%s]: %s\n", g_szUserId, szTime, szContent);
	if (nlength > 2047) {
		nlength = 2047;
	}
	szTemp[2047] = 0;
	
	fwrite(szTemp, 1, nlength, fp);
	fclose(fp);
	pthread_mutex_unlock (&g_clientlog_mutex);
}




