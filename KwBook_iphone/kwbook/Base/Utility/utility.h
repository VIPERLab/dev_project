/*
 *  utility.h
 *  KWPlayer
 *
 *  Created by YeeLion on 11-2-25.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include "nonstdlib.h"
#include "debug.h"

#ifndef _KUWO_UTILITY_H__
#define _KUWO_UTILITY_H__

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_PATH            255
#define MAX_PATH_CAPACITY   (MAX_PATH + 1)

const char* GetFilePath(const char* lpszFilePath, char szPath[MAX_PATH_CAPACITY]);
const char* GetFilename(const char* lpszFilePath, char szFilename[MAX_PATH_CAPACITY]);
const char* GetFilenameEx(const char* lpszFilePath, char szFilename[MAX_PATH_CAPACITY]);
const char* GetFileExtension(const char* lpszFilePath, char szFileExtension[MAX_PATH_CAPACITY]);

// size of szHex should be at least size * 2 + 1
char* GetHexString(char* szHex, void* pbData, int size);

char* GetMd5HashString(char szHash[33], const char* pbData, int length);
char* GetMd5HashString16(char szHash[17], const char* pbData, int length);

int TimevalToString(const struct timeval* lptmv, char* buffer, int size);
int GetCurrentTimeString(char* buffer, int size);
	
int64_t GetTimeElapsed(const struct timeval* lptmv1, struct timeval* lptmv2);


#ifdef __cplusplus
}
#endif

#endif // _KUWO_UTILITY_H__