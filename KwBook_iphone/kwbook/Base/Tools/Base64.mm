//
//  Base64.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-29.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "Base64.h"
#include "base64_.h"

namespace KwTools
{
	namespace Base64
	{
        int Base64EncodeLength(int nSrcLen)
        {
            return base64_encode_length(nSrcLen);
        }
        
        int Base64Encode(const char *pSrc, int nSrcLen, char* pDes, int nDesLen)
        {
            return base64_encode(pSrc, nSrcLen, pDes, nDesLen);
        }
        
        int Base64Encode(NSString* pSrc, char* pDes, int nDesLen)
        {
            return base64_encode([pSrc UTF8String], [pSrc lengthOfBytesUsingEncoding:NSUTF8StringEncoding]+1, pDes, nDesLen);
        }
        
        int Base64DecodeLength(int nSrcLen)
        {
            return base64_decode_length(nSrcLen);
        }
        
        int Base64Decode(const char *pSrc, int nSrcLen, char* pDes, int nDesLen)
        {
            return base64_decode(pSrc, nSrcLen, pDes, nDesLen);
        }
        
        int Base64Decode(NSString* pSrc, char* pDes, int nDesLen)
        {
            return base64_decode([pSrc UTF8String], [pSrc lengthOfBytesUsingEncoding:NSUTF8StringEncoding], pDes, nDesLen);
        }
    }
}