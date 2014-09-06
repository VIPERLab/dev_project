/*
 *  iconvTranscode.h
 *  KwSing
 *
 *  Created by FelixLee on 11-5-25.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#ifndef ICONV_TRANSCODE_H
#define ICONV_TRANSCODE_H

#ifdef __cplusplus
extern "C" {
#endif
	
int TransUTF8ToGBK(char* to, int* pDstlen, const char* from, int len);
	
int TransGBKToUTF8(char* to, int* pDstlen, const char* from, int len);
	
#ifdef __cplusplus
}
#endif

#endif //ICONV_TRANSCODE_H