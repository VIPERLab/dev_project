/*
 *  utility.cpp
 *  KWPlayer
 *
 *  Created by YeeLion on 11-2-25.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>
#include <CommonCrypto/CommonDigest.h>
#include "utility.h"

const char* GetFilePath(const char* lpszFilePath, char szPath[MAX_PATH_CAPACITY])
{
    if (!lpszFilePath)
        return NULL;
    
    const char* p = strrchr(lpszFilePath, '/');
    if (!p)
        return NULL;

    int len = p - lpszFilePath;
    if (len > MAX_PATH)
        len = MAX_PATH;
    
    strncpy(szPath, lpszFilePath, len);
    szPath[len] = 0;
    
    return szPath;
}

const char* GetFilename(const char* lpszFilePath, char szFilename[MAX_PATH_CAPACITY])
{
    if (!lpszFilePath)
        return NULL;
    
    const char* p = strrchr(lpszFilePath, '/');
    if (!p)
        return NULL;
    
    p++;
    int len = MAX_PATH;
    const char* p2 = strrchr(p, '.');
    if (p2) {
        len = p2 - p;
        if (len > MAX_PATH) 
            len = MAX_PATH;
    }
    
    strncpy(szFilename, p, len);
    szFilename[len] = 0;
    
    return szFilename;
}

const char* GetFilenameEx(const char* lpszFilePath, char szFilename[MAX_PATH_CAPACITY])
{
    if (!lpszFilePath)
        return NULL;
    
    const char* p = strrchr(lpszFilePath, '/');
    if (!p)
        return NULL;
    
    ++p;
	int len = strlen(p);
	len = MIN(len, MAX_PATH);
    strncpy(szFilename, p, len);
    szFilename[len] = 0;
    
    return szFilename;
}

const char* GetFileExtension(const char* lpszFilePath, char szFileExtension[MAX_PATH_CAPACITY])
{
    if (!lpszFilePath)
        return NULL;
    
    const char* p = strrchr(lpszFilePath, '/');
    if (!p)
        return NULL;

    p++;
    const char* p2 = strrchr(p + 1, '.');
    if (!p2 || !*(++p2))
        return NULL;
    
	int len = strlen(p2);
	len = MIN(len, MAX_PATH);
    strncpy(szFileExtension, p2, len);
    szFileExtension[len] = 0;
    
    return szFileExtension;
}



static char szHexNums[] = { "0123456789abcdef" };

static char hex_char_h(char ch)
{
    return szHexNums[(((unsigned char)ch) & 0xF0) >> 4];
}

static char hex_char_l(char ch)
{
    return szHexNums[(((unsigned char)ch) & 0x0F) >> 0];
}

// size of szHex should be at least size * 2 + 1
char* GetHexString(char* szHex, void* pbData, int size)
{
    ASSERT(szHex != NULL && pbData != NULL);
    char* pchDest = szHex;
    const char* pchSrc = (const char*)pbData;
    const char* pchGuard = (const char*)pbData + size;
    while( pchSrc < pchGuard )
    {
        *pchDest++ = hex_char_h(*pchSrc);
        *pchDest++ = hex_char_l(*pchSrc);
        ++pchSrc;
    }
    //*pchDest++ ='\0';
    *pchDest = '\0';

    return szHex;
}

char* GetMd5HashString(char szHash[33], const char* pbData, int length)
{
    ASSERT(szHash != NULL);
    if (!pbData)
        pbData = "";
    if (length < 0)
        length = strlen(pbData);
    unsigned char hash[16];
    CC_MD5(pbData, length, hash);
    return GetHexString(szHash, hash, 16);
}

char* GetMd5HashString16(char szHash[17], const char* pbData, int length)
{
    ASSERT(szHash != NULL);
    if (!pbData)
        pbData = "";
    if (length < 0)
        length = strlen(pbData);
    unsigned char hash[16];
    CC_MD5(pbData, length, hash);
    return GetHexString(szHash, hash + 4, 8);
}

int TimevalToString(const struct timeval* lptmv, char* buffer, int size)
{
    if (!lptmv || !buffer || size <= 0) {
        ASSERT(0);
        return 0;
    }
    
    struct tm tms = *localtime(&lptmv->tv_sec);
	int length = snprintf(buffer, size-1, "[%04d-%02d-%02d %02d:%02d:%02d.%03d] ", tms.tm_year, tms.tm_mon+1, tms.tm_mday, tms.tm_hour, tms.tm_min, tms.tm_sec, lptmv->tv_usec);
	if (length > size-1) {
		length = size-1;
	}
    buffer[size-1] = 0;
    return length;
}

int GetCurrentTimeString(char* buffer, int size)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return TimevalToString(&tv, buffer, size);
}

int64_t GetTimeElapsed(const struct timeval* lptmv1, struct timeval* lptmv2)
{
    uint64_t elapsed = 1000*(lptmv2->tv_sec - lptmv1->tv_sec);
	return elapsed;
}

