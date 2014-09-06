/*
 *  iconvTranscode.c
 *  KwSing
 *
 *  Created by FelixLee on 11-5-25.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */


#include "iconvTranscode.h"
#include <iconv.h>
#include <string.h>
#include <stdio.h>
#include "nonstdlib.h"
//#include <stdlib.h>
#include "log.h"
#include <errno.h>

extern int errno;
extern int safe_iconv(const char *fromCode, const char *toCode, 
                      char* to, int* pDstlen, const char* from, int len);


int TransUTF8ToGBK(char* to, int* pDstlen, const char* from, int len)
{
    return safe_iconv("GB18030", "UTF-8", to, pDstlen, from, len);
}

int TransGBKToUTF8(char* to, int* pDstlen, const char* from, int len)
{
    return safe_iconv("UTF-8", "GB18030", to, pDstlen, from, len);
}

int safe_iconv(const char *toCode, const char *fromCode, 
               char* to, int* pDstlen, const char* from, int len)
{
    if (to == NULL || from == NULL) {
		return 1;
	}
    int errno_save = 0;
	const char *src = from;
	size_t srclen = len==-1? strlen(from) : len;
	char *dst = to;
	iconv_t cd = iconv_open(toCode, fromCode);
    int iconvRet = 0;
    size_t dstlen = *pDstlen;
    int i = 0;
    while (srclen > 0 && dstlen > 0 && i++ < 3) {//最多容错50次，相当于50个字节
        iconvRet = iconv(cd, (char**)&src, &srclen, &dst, &dstlen);
        if (iconvRet >= 0) {
            errno_save = 0;
            break;
        }
        
        errno_save = errno;
        if (errno_save == EILSEQ) {
            fprintf(stderr, "iconv from %s to %s error EILSEQ\n", fromCode, toCode);
            src++;
            srclen--;
            *dst = '?';
            dst++;
            dstlen--;
        }
        else {
            fprintf(stderr, "iconv error E2BIG = %d, EINVAL = %d, errno = %d\n", E2BIG, EINVAL, errno_save);
            break;
        }
    }
    iconv_close(cd);
    *pDstlen -= dstlen;
	return (errno_save) ? -1 : 0;	
}
