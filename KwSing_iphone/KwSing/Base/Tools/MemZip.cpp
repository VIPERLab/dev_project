//
//  MemZip.cpp
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-7.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "MemZip.h"
#include <zlib.h>

namespace KwTools
{
	namespace Memzip
	{
		ZIP_RESULT Compress(void* ucDes, long* lDesLen, const void* ucSrc, long lSrcLen)
		{
			int iRet =  compress( (unsigned char*)ucDes,(unsigned long*) lDesLen,(unsigned char*)ucSrc,lSrcLen );
			switch( iRet )
			{
                case Z_OK:
                    return RESULT_SUC;
                case Z_MEM_ERROR:
                    return ERROR_MEM;
                case Z_BUF_ERROR:
                    return ERROR_BUFFER;
                case Z_DATA_ERROR:
                    return ERROR_DATA;
                default:
                    return ERROR_OTHER;
			}
		}
        
		ZIP_RESULT UnCompress( void* ucDes, long* lDesLen, const void* ucSrc, long lSrcLen )
		{
			try
			{
				int iRet = uncompress( (unsigned char*)ucDes,(unsigned long*) lDesLen,(unsigned char*)ucSrc,lSrcLen);
				switch( iRet )
				{
                    case Z_OK:
                        return RESULT_SUC;
                    case Z_MEM_ERROR:
                        return ERROR_MEM;
                    case Z_BUF_ERROR:
                        return ERROR_BUFFER;
                    case Z_DATA_ERROR:
                        return ERROR_DATA;
                    default:
                        return ERROR_OTHER;
				}
			}
			catch(...)
			{
				return ERROR_OTHER;
			}
		}
	}
}