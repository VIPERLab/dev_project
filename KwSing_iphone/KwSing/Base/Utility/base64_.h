/*
 *  base64.h
 *  KWSING
 *
 *  Created by YeeLion on 11-2-25.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#ifndef _KUWO_BASE64_H__
#define _KUWO_BASE64_H__

#ifdef __cplusplus
extern "C" {
#endif
    
int base64_encode_length(int length);
int base64_encode(const char *data, int length, char* buffer, int size);

int base64_decode_length(int length);
int base64_decode(const char *bdata, int length, char* buffer, int size);

#ifdef __cplusplus
}
#endif

#endif // _KUWO_BASE64_H__