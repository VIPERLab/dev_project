//
//  MemZip.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-8-7.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__MemZip__
#define __KwSing__MemZip__

namespace KwTools
{
	namespace Memzip
	{
		enum ZIP_RESULT
		{
			ERROR_MEM = 0,		//内存不够
			ERROR_DATA,			//数据错误
			ERROR_BUFFER,		//Buffer不够
			ERROR_OTHER,		//其他错误
			RESULT_SUC			//操作成功
		};
        
		ZIP_RESULT Compress (void* ucDes, long* lDesLen, const void* ucSrc, long lSrcLen);
        
		ZIP_RESULT UnCompress(void* ucDes, long* lDesLen, const void* ucSrc, long lSrcLen );
	}
}

#endif 
